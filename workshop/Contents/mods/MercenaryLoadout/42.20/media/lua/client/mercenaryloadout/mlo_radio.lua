local M = MercenaryLoadout
local players = {}

local function unregister(state, item)
    if state.registered then
        getZomboidRadio():UnRegisterDevice(item)
        state.registered = nil
    end
end

function M.clearMountedRadioPlayback(playerNum)
    for item, state in pairs(players[playerNum] or {}) do unregister(state, item) end
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

-- Reuse the actual device's private subtitle/mood path, with no new headphones,
-- emitter, world object, packet handler or replacement media progression.
local function updatePrivateMedia(data)
    local headphones = data:getHeadphoneType()
    local privateGate = isClient() and headphones < 0
    if privateGate then data:setHeadphoneType(0) end
    local ok, reason = pcall(data.updateMediaPlaying, data)
    if privateGate then data:setHeadphoneType(headphones) end
    if not ok then error(reason) end
end

local function upkeep(item, data, state, minute)
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
    local receiving = not data:isNoTransmit() and not data:isPlayingMedia()
    if not isClient() and receiving and not state.registered then
        getZomboidRadio():RegisterDevice(item)
        state.registered = true
    elseif not receiving then unregister(state, item) end
    if data:getDeviceVolume() > 0 and data:hasMedia() then updatePrivateMedia(data) end
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
            and player:isAttachedItem(item) and not player:isEquipped(item)
            and player:getEquipedRadio() ~= item then
            local data = item:getDeviceData()
            if data and data:getIsTurnedOn() then
                local minute = getGameTime():getMinutesStamp()
                local state = states[item]
                if not state or state.data ~= data then
                    if state then unregister(state, item) end
                    state = {data=data, minute=minute, listen=0}
                    states[item] = state
                    M.logOnce("mounted-radio:" .. tostring(item:getID()), "mounted radio updater active channel=" .. tostring(data:getChannel()))
                    -- Native battery packet refreshes MP channel roaming too.
                    if isClient() then data:transmitBatteryChange() end
                    data:TriggerPlayerListening(true)
                end
                if not state.seen then
                    state.seen = true
                    if not state.failed then
                        local ok, reason = pcall(upkeep, item, data, state, minute)
                        if not ok then
                            state.failed = true
                            M.logOnce("mounted-media:" .. tostring(item:getID()), "mounted subtitle update failed: " .. tostring(reason))
                        end
                    end
                end
            end
        end
    end
    for item, state in pairs(states) do
        if not state.seen then unregister(state, item) states[item] = nil end
    end
end
