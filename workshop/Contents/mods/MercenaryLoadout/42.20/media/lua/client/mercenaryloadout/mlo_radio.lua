require "RadioCom/ISRadioAction"
local M = MercenaryLoadout
local players = {}

-- B42.20 GameServer resolves inventory radio packets in hand 1/2 only.
-- Keep DeviceData as playback authority; bridge just the missing owned-item
-- request address. Server replies still use the native 8/9 state packets.
local mediaTails = setmetatable({}, { __mode = "k" })
local mediaPositions = setmetatable({}, { __mode = "k" })
local mediaUpdated = setmetatable({}, { __mode = "k" })
local mediaFrame = 0
function M.onNativeMediaRequest(data, playing)
    mediaTails[data] = nil
    mediaPositions[data] = playing and {index = data:getMediaIndex(), nextLine = 0} or nil
end
local function mountedOwner(player, item)
    return player and item and instanceof(item, "Radio")
        and item:getContainer() == player:getInventory()
        and item:getPlayer() == player and item:getAttachedSlot() ~= -1
        and player:getPrimaryHandItem() ~= item and player:getSecondaryHandItem() ~= item
end

function M.requestMountedMedia(player, data, playing)
    if not isClient() or isServer() or not player or not data then return false end
    local item = data:getParent()
    if not mountedOwner(player, item) or item:getDeviceData() ~= data then return false end
    M.onNativeMediaRequest(data, playing)
    sendClientCommand(player, M.MODULE, "mountedMedia", {
        itemId = item:getID(), mediaIndex = data:getMediaIndex(), playing = playing == true,
    })
    return true
end

-- Preserve wrapper chaining with extensions regardless of their load order.
-- The original timed action still owns its effects and session notifications.
local vanillaToggleMedia = ISRadioAction.performTogglePlayMedia
function ISRadioAction:performTogglePlayMedia(...)
    local data = self.deviceData
    local wasPlaying = data and data:isPlayingMedia()
    if data then M.onNativeMediaRequest(data, not wasPlaying) end
    local result = vanillaToggleMedia(self, ...)
    if data and data:hasMedia() then
        M.requestMountedMedia(self.character, data, not wasPlaying)
    end
    return result
end

-- No Lua end event exists in B42.20. Observe the final native line and bridge
-- its trailing hold only, never the playlist, text delivery or replay deadline.
-- DeviceData's exact B42.20 rule is clamp(Java UTF-16 length / 10 * 60,90,300),
-- decremented by 1.25 * multiplier per audible native update. Lua # is UTF-8
-- bytes, so count UTF-16 units explicitly for translated/non-ASCII lines.
local function nativeTextUnits(text)
    local units = 0
    for index = 1, #text do
        local byte = string.byte(text, index)
        if byte < 128 or byte >= 192 then units = units + (byte >= 240 and 2 or 1) end
    end
    return units
end

local function observeNativeMediaTail(item, player, guid, line)
    if not isClient() or not player or not player:isLocalPlayer() then return end
    local data = item:getDeviceData()
    if not data or not data:isPlayingMedia() or data:getMediaType() ~= 0 then return end
    local media = data:getMediaData()
    if not media then return end
    local count = media:getLineCount()
    mediaTails[data] = nil
    local observed = mediaPositions[data]
    local position = observed and observed.index == data:getMediaIndex()
        and observed.nextLine or nil
    local expected = position and media:getLine(position) or nil
    if not expected or expected:getTextGuid() ~= guid then
        -- On reload/late observation, resume only at an unambiguous native
        -- event. Stock lyrics repeat GUIDs in choruses, so GUID==last alone
        -- would incorrectly stop at an earlier occurrence of the same line.
        position = nil
        for index = 0, count - 1 do
            if media:getLine(index):getTextGuid() == guid then
                if position then mediaPositions[data] = nil; return end
                position = index
            end
        end
    end
    if position == nil then mediaPositions[data] = nil; return end
    mediaPositions[data] = {index = data:getMediaIndex(), nextLine = position + 1}
    if position ~= count - 1 then return end
    mediaTails[data] = {
        item = item, player = player, mediaIndex = data:getMediaIndex(),
        remaining = math.max(90, math.min(300, nativeTextUnits(line) * 6)),
        frame = mediaFrame,
    }
end

local function advanceNativeMediaTails()
    for data, tail in pairs(mediaTails) do
        local item, player = tail.item, tail.player
        if player:isDead() or item:getDeviceData() ~= data
            or item:getContainer() ~= player:getInventory()
            or data:getMediaIndex() ~= tail.mediaIndex or not data:isPlayingMedia() then
            mediaTails[data] = nil
        elseif tail.frame < mediaFrame
            and (player:getEquipedRadio() == item or mediaUpdated[data] == mediaFrame)
            and data:getIsTurnedOn()
            and data:getDeviceVolume() > 0 and data:getHeadphoneType() >= 0 then
            tail.remaining = tail.remaining - 1.25 * getGameTime():getMultiplier()
            if tail.remaining <= 0 then
                mediaTails[data] = nil
                if mountedOwner(player, item) then
                    M.requestMountedMedia(player, data, false)
                end
            end
        end
    end
end

local function unregister(state, item)
    if state.registered then
        getZomboidRadio():UnRegisterDevice(item)
        state.registered = nil
    end
end

-- Use the same native world emitter pool as DeviceData. Explicit ownership
-- keeps Radio.update() and the pool from reclaiming this mounted-only emitter.
-- Keep a failed cleanup reachable and retry before allocating another voice.
local function stopMountedMediaAudio(state)
    local emitter=state.mediaEmitter
    if not emitter then return true end
    local now=getTimestampMs()
    if state.audioCleanupAt and now<state.audioCleanupAt then return false end
    local ok,reason=pcall(function()
        emitter:stopAll()
        getWorld():returnOwnershipOfEmitter(emitter)
    end)
    if not ok then
        state.audioCleanupAt=now+1000
        M.logOnce("mounted-audio-cleanup:"..tostring(state.itemId),
            "mounted radio audio cleanup failed; retry scheduled: "..tostring(reason))
        return false
    end
    state.mediaEmitter,state.mediaSound,state.audioCleanupAt=nil,nil,nil
    return true
end

function M.clearMountedRadioPlayback(playerNum)
    local states=players[playerNum]
    for item,state in pairs(states or {}) do
        unregister(state,item)
        if stopMountedMediaAudio(state) then states[item]=nil end
    end
    if not states or not next(states) then players[playerNum]=nil end
end

-- MP broadcast delivery already owns reception, chat history and mood effects.
-- Its native head-chat branch requires isEquipped, unlike CD's Radio overload.
-- Add just that missing visual line; never fire OnDeviceText again.
function M.onMountedBroadcastText(guid, codes, x, y, z, line, source)
    if not isClient() or isServer() or not source or not instanceof(source, "Radio") then return end
    local player = source:getPlayer()
    -- Native Radio.AddDeviceText fires this event only for non-nil codes.
    -- Event delivery proves that path ran, not that the HUD rendered the line.
    if player and player:isLocalPlayer() then
        observeNativeMediaTail(source, player, guid, line)
    end
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

-- Radio.update() skips DeviceData for an unequipped Hotbar item. Advance only
-- the public native media updater here: it owns the existing line position,
-- content, stopping tail and MP headphone gate. Do not start another subtitle
-- clock or infer an extension deadline; playback extensions own their sessions.
-- In particular, isPlayingMedia may remain true during the SP stopping tail,
-- even though the private playingMedia pointer has already been cleared.
local function advanceMountedMedia(data)
    data:updateMediaPlaying()
    mediaUpdated[data] = mediaFrame
end

local function upkeepMediaAudio(player, data, state)
    if state.audioCleanupAt and not stopMountedMediaAudio(state) then return end
    if not data:getIsTurnedOn() or not data:isPlayingMedia() or data:getDeviceVolume() <= 0 then
        stopMountedMediaAudio(state)
        return
    end
    local emitter=state.mediaEmitter
    if not emitter then
        local world=getWorld()
        emitter=world:getFreeEmitter(player:getX(),player:getY(),math.floor(player:getZ()))
        if not emitter then error("mounted world emitter unavailable") end
        world:takeOwnershipOfEmitter(emitter)
        state.mediaEmitter=emitter
    end
    emitter:setPos(player:getX(),player:getY(),math.floor(player:getZ()))
    if not state.mediaSound or not emitter:isPlaying(state.mediaSound) then
        -- Three arguments select the IsoObject overload unambiguously in Lua;
        -- the two-argument nil also matches the native IsoGridSquare overload.
        state.mediaSound=emitter:playSoundImpl("RadioTalk",false,nil)
        if not state.mediaSound or state.mediaSound==0 then
            state.mediaSound=nil
            error("RadioTalk returned no sound handle")
        end
        M.logOnce("mounted-media-audio:"..tostring(state.itemId or "?"),
            "mounted media native world emitter RadioTalk active index="..tostring(data:getMediaIndex()))
    end
    -- DeviceData.setSoundVolume chooses the event parameter OR direct gain.
    -- Applying both attenuates parameter-driven radio events twice.
    local volume=data:getDeviceVolume()
    if emitter:isUsingParameter(state.mediaSound,"DeviceVolume") then
        emitter:setParameterValueByName(state.mediaSound,"DeviceVolume",volume)
    else
        emitter:setVolume(state.mediaSound,volume)
    end
    emitter:tick()
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
    local receiving = data:getIsTurnedOn() and not data:isNoTransmit() and not data:isPlayingMedia()
    if not isClient() and receiving and not state.registered then
        getZomboidRadio():RegisterDevice(item)
        state.registered = true
    elseif not receiving then unregister(state, item) end
    advanceMountedMedia(data)
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
            and player:getPrimaryHandItem() ~= item and player:getSecondaryHandItem() ~= item
            and player:getEquipedRadio() ~= item then
            local data = item:getDeviceData()
            if data and (data:getIsTurnedOn() or data:isPlayingMedia()) then
                local minute = getGameTime():getMinutesStamp()
                local state = states[item]
                if state and state.data ~= data then
                    unregister(state,item)
                    if stopMountedMediaAudio(state) then
                        states[item]=nil
                        state=nil
                    else
                        state.seen=true
                    end
                end
                if not state then
                    state = {
                        data=data,
                        minute=minute,
                        listen=0,
                        itemId=item:getID(),
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
                    if data:getIsTurnedOn() then
                        runUpkeepPhase(item,state,"power",now,function()
                            upkeepPower(item,data,state,minute)
                        end)
                    end
                    -- SP must drain its native stopping tail even after power
                    -- is removed. MP retains the native off/mute/headphone gate.
                    runUpkeepPhase(item,state,"media",now,function()
                        upkeepMedia(player,item,data,state)
                    end)
                    runUpkeepPhase(item,state,"audio",now,function()
                        upkeepMediaAudio(player,data,state)
                    end)
                end
            end
        end
    end
    for item, state in pairs(states) do
        if not state.seen then
            unregister(state, item)
            if stopMountedMediaAudio(state) then states[item] = nil end
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
    advanceNativeMediaTails()
    mediaFrame = mediaFrame + 1
end
Events.OnTick.Add(tickAllMountedRadioPlayback)
