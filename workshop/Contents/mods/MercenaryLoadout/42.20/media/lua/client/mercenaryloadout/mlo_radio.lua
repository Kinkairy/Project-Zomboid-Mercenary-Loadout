local M = MercenaryLoadout
local players = {}

local function unregister(state, item)
    if state.registered then
        getZomboidRadio():UnRegisterDevice(item)
        state.registered = nil
    end
end

-- Native Radio.update() only keeps DeviceData's private FMOD emitter alive while
-- getEquipedRadio() points at the item. A backpack Hotbar attachment is not an
-- equipped radio, so that emitter is cleaned every native item update. Keep the
-- mounted media voice on the owning character emitter instead; this is local
-- audio only and is stopped as soon as the item leaves the mounted-media state.
local function stopMountedMediaAudio(state)
    local emitter, sound = state.mediaEmitter, state.mediaSound
    state.mediaEmitter = nil
    state.mediaSound = nil
    if emitter and sound and sound ~= 0 then
        pcall(function() emitter:stopSound(sound) end)
    end
end

function M.clearMountedRadioPlayback(playerNum)
    for item, state in pairs(players[playerNum] or {}) do
        unregister(state, item)
        stopMountedMediaAudio(state)
    end
    players[playerNum] = nil
end

-- MP broadcast delivery already owns reception, chat history and mood effects.
-- Its native head-chat branch requires isEquipped, unlike CD's Radio overload.
-- Add just that missing visual line; never fire OnDeviceText again.
function M.onMountedBroadcastText(guid, codes, x, y, z, line, source)
    if not isClient() or isServer() or not source or not instanceof(source, "Radio") then return end
    local player = source:getPlayer()
    if not player or not player:isLocalPlayer() or player:isDead()
        or source:getContainer() ~= player:getInventory()
        or not player:isAttachedItem(source) or player:isEquipped(source) then return end
    local data = source:getDeviceData()
    if not data or not data:getIsTurnedOn() or data:getDeviceVolume() <= 0
        or data:isPlayingMedia() or not line or line == "" then return end
    -- OnDeviceText supplies no RGB; use neutral white with native formatting.
    player:addLineChatElement(line, 1, 1, 1, UIFont.Medium,
        data:getDeviceVolumeRange(), "default", true, true, true, false, false, true)
    M.logOnce("mounted-broadcast:" .. tostring(source:getID()),
        "mounted broadcast subtitle received channel=" .. tostring(data:getChannel()))
end
Events.OnDeviceText.Add(M.onMountedBroadcastText)

-- Build 42.20.3 can report isPlayingMedia=true while the private Java
-- playingMedia pointer is nil after a hand -> mounted transition. In that state
-- DeviceData.updateMediaPlaying() silently does nothing: no error and no next
-- subtitle. Mounted playback therefore mirrors only the public RecordedMedia
-- line progression and feeds each line back through Radio.AddDeviceText(),
-- preserving the stock head-chat/history/codes path.

local function utf8Length(text)
    text = tostring(text or "")
    local count = 0
    for index = 1, #text do
        local byte = string.byte(text, index)
        if byte < 128 or byte >= 192 then count = count + 1 end
    end
    return count
end

local function mountedLineCounter(text)
    local counter = utf8Length(text) / 10 * 60
    if counter < 90 then return 90 end
    if counter > 300 then return 300 end
    return counter
end

local function beginMountedMediaMirror(item, data, state)
    local mediaIndex = tonumber(data:getMediaIndex())
    local okMedia, media = pcall(function() return data:getMediaData() end)
    M.logOnce("mounted-media-observed:" .. tostring(item:getID()) .. ":" .. tostring(mediaIndex),
        "mounted media playback observed hasMedia=" .. tostring(data:hasMedia())
            .. " index=" .. tostring(mediaIndex)
            .. " mediaData=" .. tostring(okMedia and media ~= nil))
    if not okMedia then error(media) end
    if not media then
        M.logOnce("mounted-media-data:" .. tostring(item:getID()) .. ":" .. tostring(mediaIndex),
            "mounted media data unavailable index=" .. tostring(mediaIndex))
        return false
    end
    state.mediaMirror = {
        data = media,
        mediaIndex = mediaIndex,
        lineIndex = 0,
        counter = 150,
        stopping = false,
    }
    local okCount, lineCount = pcall(function() return media:getLineCount() end)
    M.logOnce("mounted-media-mirror:" .. tostring(item:getID()) .. ":" .. tostring(mediaIndex),
        "mounted media subtitle mirror active index=" .. tostring(mediaIndex)
            .. " lines=" .. tostring(okCount and lineCount or "?"))
    return true
end

local function dispatchMountedMediaLine(player, item, data, line, mediaIndex, lineIndex)
    local text = line:getTranslatedText()
    local r, g, b = line:getR(), line:getG(), line:getB()
    local guid, codes = line:getTextGuid(), line:getCodes()

    local itemPlayer = nil
    pcall(function() itemPlayer = item:getPlayer() end)
    local allowConversation = true
    pcall(function() allowConversation = player:isAllowConversation() end)

    local equippedRadio = nil
    pcall(function() equippedRadio = player:getEquipedRadio() end)
    local equippedRadioOn = nil
    if equippedRadio and equippedRadio:getDeviceData() then
        pcall(function() equippedRadioOn = equippedRadio:getDeviceData():getIsTurnedOn() end)
    end

    local usedDirectFallback = false
    local fallbackTag = "radio"

    if itemPlayer == player then
        -- Radio.AddDeviceText ultimately enters IsoGameCharacter.ProcessSay(),
        -- which silently drops radio lines while allowConversation is false.
        -- Preserve its normal radio-history/codes path, but temporarily open
        -- that gate for this media line only.
        if allowConversation == false then player:setAllowConversation(true) end
        local ok, reason = pcall(function()
            item:AddDeviceText(text, r, g, b, guid, codes, 0)
        end)
        if allowConversation == false then player:setAllowConversation(false) end
        if not ok then error(reason) end

        -- IsoGameCharacter.renderlast hides every "radio" chat line when its
        -- tracked equipped radio exists but is turned off. A backpack-mounted
        -- CD is not that tracked hand/back-clothing radio, so an unrelated
        -- stale/off tracked radio can hide otherwise valid mounted subtitles.
        -- Add one visible fallback line only in that exact hidden-render state.
        if equippedRadio and equippedRadioOn == false then
            fallbackTag = "default"
            player:addLineChatElement(text, r, g, b, UIFont.Medium,
                data:getDeviceVolumeRange(), fallbackTag,
                true, true, true, false, false, true)
            usedDirectFallback = true
        end
    else
        -- The mounted updater already owns the actual player reference. If the
        -- Radio item's container-parent bridge cannot resolve that same player,
        -- bypass Radio.getPlayer()/SayRadio for the head subtitle rather than
        -- silently losing it.
        fallbackTag = (equippedRadio and equippedRadioOn == false) and "default" or "radio"
        player:addLineChatElement(text, r, g, b, UIFont.Medium,
            data:getDeviceVolumeRange(), fallbackTag,
            true, true, true, false, false, true)
        pcall(function() item:doReceiveSignal(0) end)
        if codes ~= nil then
            triggerEvent("OnDeviceText", guid, codes, -1, -1, -1, text, item)
        end
        usedDirectFallback = true
    end

    print("[MercenaryLoadout] mounted media subtitle line dispatched index="
        .. tostring(mediaIndex)
        .. " line=" .. tostring(lineIndex)
        .. " nextCounter=" .. tostring(mountedLineCounter(text))
        .. " itemPlayerMatch=" .. tostring(itemPlayer == player)
        .. " allowConversation=" .. tostring(allowConversation)
        .. " equippedRadio=" .. tostring(equippedRadio and equippedRadio:getID() or nil)
        .. " equippedRadioOn=" .. tostring(equippedRadioOn)
        .. " fallback=" .. tostring(usedDirectFallback)
        .. " tag=" .. tostring(fallbackTag))
end

local function mountedExtendedLoopEnabled(item)
    local ss = SurvivorsSong
    if not ss or type(ss.isCDPlayer) ~= "function"
        or type(ss.getPlaybackDurationMinutes) ~= "function" then
        return false, 0
    end

    local okDevice, isDevice = pcall(ss.isCDPlayer, item)
    if not okDevice or isDevice ~= true then return false, 0 end

    local okDuration, duration = pcall(ss.getPlaybackDurationMinutes)
    duration = okDuration and tonumber(duration) or 0
    return duration ~= nil and duration > 0, duration or 0
end

local function advanceMountedMediaMirror(player, item, data, state)
    local playing = data:isPlayingMedia()
    if state.mediaPollPlaying ~= playing then
        state.mediaPollPlaying = playing
        local mediaIndex = nil
        pcall(function() mediaIndex = tonumber(data:getMediaIndex()) end)
        print("[MercenaryLoadout] mounted media state playing=" .. tostring(playing)
            .. " hasMedia=" .. tostring(data:hasMedia())
            .. " index=" .. tostring(mediaIndex)
            .. " item=" .. tostring(item:getID()))
    end

    if not playing then
        state.mediaMirror = nil
        return
    end

    local mediaIndex = tonumber(data:getMediaIndex())
    if not state.mediaMirror or state.mediaMirror.mediaIndex ~= mediaIndex then
        if not beginMountedMediaMirror(item, data, state) then return end
    end

    local mirror = state.mediaMirror
    if mirror.stopping then return end

    local multiplier = tonumber(getGameTime():getMultiplier()) or 1
    mirror.counter = mirror.counter - 1.25 * multiplier

    local now = getTimestampMs()
    if not mirror.nextProgressLogAt or now >= mirror.nextProgressLogAt then
        mirror.nextProgressLogAt = now + 5000
        print("[MercenaryLoadout] mounted media subtitle progress index="
            .. tostring(mediaIndex)
            .. " line=" .. tostring(mirror.lineIndex)
            .. " counter=" .. tostring(mirror.counter)
            .. " multiplier=" .. tostring(multiplier)
            .. " playing=" .. tostring(data:isPlayingMedia()))
    end

    if mirror.counter > 0 then return end

    local line = mirror.data:getLine(mirror.lineIndex)
    if not line then
        local extendedLoop, duration = mountedExtendedLoopEnabled(item)
        if extendedLoop and data:isPlayingMedia() then
            mirror.loops = (mirror.loops or 0) + 1
            mirror.lineIndex = 0
            mirror.counter = 150
            print("[MercenaryLoadout] mounted media subtitle loop restart index="
                .. tostring(mediaIndex)
                .. " loop=" .. tostring(mirror.loops)
                .. " durationMinutes=" .. tostring(duration))
            return
        end

        mirror.stopping = true
        print("[MercenaryLoadout] mounted media subtitle mirror reached end index="
            .. tostring(mediaIndex)
            .. " lines=" .. tostring(mirror.lineIndex)
            .. " extendedLoop=" .. tostring(extendedLoop))
        data:StopPlayMedia()
        return
    end

    local lineIndex = mirror.lineIndex
    dispatchMountedMediaLine(player, item, data, line, mediaIndex, lineIndex)
    mirror.lineIndex = lineIndex + 1
    mirror.counter = mountedLineCounter(line:getTranslatedText())
end

local function upkeepMediaAudio(player, data, state)
    -- Headphones keep the original private-listening behavior. With speakers,
    -- mirror the native RadioTalk loop on the character emitter because the
    -- Radio item's own DeviceData emitter is destroyed by native Radio.update()
    -- whenever the item is attached to the backpack instead of held.
    if not data:isPlayingMedia() or data:getDeviceVolume() <= 0 then
        stopMountedMediaAudio(state)
        return
    end
    local emitter = player:getEmitter()
    if not emitter then error("character emitter unavailable") end
    local playing = false
    if state.mediaEmitter == emitter and state.mediaSound and state.mediaSound ~= 0 then
        local ok, value = pcall(function() return emitter:isPlaying(state.mediaSound) end)
        playing = ok and value == true
    end
    if not playing then
        stopMountedMediaAudio(state)
        local ok, sound = pcall(function() return emitter:playSoundImpl("RadioTalk", nil) end)
        if not ok or not sound or sound == 0 then
            ok, sound = pcall(function() return emitter:playSound("RadioTalk") end)
        end
        if not ok or not sound or sound == 0 then
            error(ok and "RadioTalk returned no sound handle" or tostring(sound))
        end
        state.mediaEmitter = emitter
        state.mediaSound = sound
        local mediaIndex = nil
        pcall(function() mediaIndex = tonumber(data:getMediaIndex()) end)
        M.logOnce("mounted-media-audio:" .. tostring(state.itemId or "?"),
            "mounted media RadioTalk audio active hasMedia=" .. tostring(data:hasMedia())
                .. " index=" .. tostring(mediaIndex))
    end
    local volume = data:getDeviceVolume()
    local ok, reason = pcall(function()
        emitter:setVolume(state.mediaSound, volume)
        -- RadioTalk uses the native DeviceVolume FMOD parameter when it is
        -- owned by DeviceData. Character emitters do not have that updater, so
        -- mirror the parameter explicitly when the event exposes it.
        pcall(function()
            emitter:setParameterValueByName(state.mediaSound, "DeviceVolume", volume)
        end)
    end)
    if not ok then error(reason) end
end

local function upkeepPower(item, data, state, minute)
    -- Native Radio resumes its own battery tick when taken into a hand. Advance
    -- its minute stamp too, or it would charge the mounted interval a second time.
    -- setInitialPower is the public stamp setter; restore its power-only side
    -- effect synchronously (both setters are local and emit no events/packets).
    local savedPower = data:getPower()
    local stamped, stampError = pcall(data.setInitialPower, data)
    data:setPower(savedPower)
    if not stamped then error(stampError) end
    local elapsed = minute - state.minute
    if elapsed < 0 then state.minute = minute end
    if elapsed > 0 then
        state.minute = minute
        state.listen = state.listen + elapsed
        if state.listen >= 10 then state.listen = 0 end
        if state.listen == 0 or state.listen == 5 then data:TriggerPlayerListening(true) end
        -- DeviceData.update has no public battery-only entry. Retain its minute
        -- arithmetic/cadence without calling update/updateSimple (both emit sound).
        local power = data:getPower()
        if data:getIsBatteryPowered() and power > 0 then
            local threshold = power - power % 0.01
            data:setPower(power - data:getUseDelta() * elapsed)
            if state.listen == 0 or data:getPower() <= 0 or data:getPower() < threshold then
                data:transmitBatteryChange()
            end
        end
    end
    if data:getIsBatteryPowered() and (not data:getHasBattery() or data:getPower() <= 0) then
        data:setIsTurnedOn(false)
        return
    end
end

local function upkeepMedia(player, item, data, state)
    local receiving = not data:isNoTransmit() and not data:isPlayingMedia()
    if not isClient() and receiving and not state.registered then
        getZomboidRadio():RegisterDevice(item)
        state.registered = true
    elseif not receiving then unregister(state, item) end
    advanceMountedMediaMirror(player, item, data, state)
end

-- A failure in one branch must not permanently disable unrelated upkeep.
-- One initial attempt plus four retries, at 1/2/4/8 seconds. A successful
-- retry clears its budget; toggling off/re-equipping resets the device state.
local function runUpkeepPhase(item, state, name, now, callback)
    local retry=state[name]
    if retry and (retry.exhausted or now<retry.nextAt) then return end
    local ok,reason=pcall(callback)
    if ok then state[name]=nil;return end
    retry=retry or {failures=0}
    retry.failures=retry.failures+1
    retry.nextAt=now+1000*2^(retry.failures-1)
    retry.exhausted=retry.failures>=5
    state[name]=retry
    M.logOnce("mounted-"..name..":"..tostring(item:getID())..":"..retry.failures,
        "mounted radio "..name.." failed; "..(retry.exhausted and "retry limit reached" or "retry scheduled")..": "..tostring(reason))
end

function M.tickMountedRadioPlayback(player)
    if not player or isServer() then return end
    local playerNum = player:getPlayerNum()
    if not player:isLocalPlayer() then return end
    if player:isDead() then
        M.clearMountedRadioPlayback(playerNum)
        return
    end
    local hotbar = getPlayerHotbar(playerNum)
    local states = players[playerNum]
    if not states then states = {} players[playerNum] = states end
    for _, state in pairs(states) do state.seen = false end
    -- Only the small native Hotbar table, never a recursive inventory/frame scan.
    for _, item in pairs(hotbar and hotbar.attachedItems or {}) do
        if item and instanceof(item, "Radio") and item:getContainer() == player:getInventory()
            and item:getAttachedSlot() ~= -1 and not player:isEquipped(item)
            and player:getPrimaryHandItem() ~= item and player:getSecondaryHandItem() ~= item then
            local data = item:getDeviceData()
            if data and data:getIsTurnedOn() then
                local minute = getGameTime():getMinutesStamp()
                local state = states[item]
                if not state or state.data ~= data then
                    if state then
                        unregister(state, item)
                        stopMountedMediaAudio(state)
                    end
                    state = {
                        data=data,
                        minute=minute,
                        listen=0,
                        itemId=item:getID(),
                        mediaPollPlaying=nil,
                    }
                    states[item] = state
                    M.logOnce("mounted-radio:" .. tostring(item:getID()),
                        "mounted radio updater active channel=" .. tostring(data:getChannel())
                        .. " slot=" .. tostring(item:getAttachedSlot())
                        .. " attached=" .. tostring(player:isAttachedItem(item))
                        .. " playing=" .. tostring(data:isPlayingMedia())
                        .. " headphones=" .. tostring(data:getHeadphoneType()))
                    -- Native battery packet refreshes MP channel roaming too.
                    if isClient() then data:transmitBatteryChange() end
                    data:TriggerPlayerListening(true)
                end
                if not state.seen then
                    state.seen = true
                    local now=getTimestampMs()
                    runUpkeepPhase(item,state,"power",now,function()
                        upkeepPower(item,data,state,minute)
                    end)
                    if data:getIsTurnedOn() then
                        runUpkeepPhase(item,state,"media",now,function()
                            upkeepMedia(player,item,data,state)
                        end)
                        runUpkeepPhase(item,state,"audio",now,function()
                            upkeepMediaAudio(player,data,state)
                        end)
                    else
                        stopMountedMediaAudio(state)
                    end
                end
            end
        end
    end
    for item, state in pairs(states) do
        if not state.seen then
            unregister(state, item)
            stopMountedMediaAudio(state)
            states[item] = nil
        end
    end
end

-- Run after the native world/item update. Radio.update() has already performed
-- its normal cleanup for non-equipped radios by this point, so mounted playback
-- no longer races a stale hand-radio cache or an item update later in the frame.
local function tickAllMountedRadioPlayback()
    if isServer() then return end
    local count = 4
    if type(getNumActivePlayers) == "function" then
        local ok, value = pcall(getNumActivePlayers)
        if ok and type(value) == "number" then count = math.max(count, value) end
    end
    for index = 0, count - 1 do
        local ok, player = pcall(getSpecificPlayer, index)
        if ok and player and player:isLocalPlayer() then
            M.tickMountedRadioPlayback(player)
        end
    end
end
Events.OnTick.Add(tickAllMountedRadioPlayback)
