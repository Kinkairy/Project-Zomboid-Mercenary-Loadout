require "mercenaryloadout/mlo_shared"
require "mercenaryloadout/mlo_actions"
local M=MercenaryLoadout

M.registerAttachedLocations()
M.registerBodyLocations()

local function playerKey(player)
    local ok,value=pcall(function() return player:getOnlineID() end)
    if ok and value~=nil then return tostring(value) end
    return tostring(player)
end

local function fail(player,message)
    sendServerCommand(player,M.MODULE,"failed",M.writeMessagePayload({},message or M.message("IGUI_MLO_Error_Generic")))
end

local function rootExitUnmountAck(player,parentId,slotId,itemId,message,resolved,currentItemId)
    local data={parentId=parentId,slotId=slotId,itemId=itemId,resolved=resolved==true,currentItemId=currentItemId}
    sendServerCommand(player,M.MODULE,"rootExitUnmountAck",M.writeMessagePayload(data,message))
end

local function stateChanged(player,parent,message)
    if not parent then fail(player,M.message("IGUI_MLO_Error_SyncState")) return false end
    local data=M.writeMessagePayload({itemId=parent:getID(),version=M.VERSION},message)
    sendServerCommand(player,M.MODULE,"stateChanged",data)
    return true
end

local migratedPlayers={}
local function migratePlayerOnce(player,cause)
    if not player then return false end
    if migratedPlayers[player] then return true end
    if not M.registerAttachedLocations() then return false end
    local usable,inventory=pcall(function() return player:getInventory() end)
    if not usable or not inventory then return false end

    local migrated,migratedParents=M.migrateLegacyContainerModules(player)
    if not migrated then return false end
    local orphans=M.reconcileOrphanModules(player)
    if not orphans then return false end
    -- One-time save repair runs before adopting dev.9's live Hotbar fields, so
    -- the exact vanilla container is healthy before any durable link is made.
    local containers=M.repairLegacyVanillaContainers(player)
    if not containers then return false end
    if not M.syncDetachableItems(player) then return false end
    local adopted,adoptedParents=M.adoptLegacyHotbarMounts(player)
    if not adopted then return false end
    local mounts,mountParents=M.reconcilePersistentMounts(player)
    if not mounts then return false end
    for _,parent in ipairs(M.allRecursiveItems(player)) do
        if M.isParent(parent) then
            local changed=migratedParents[parent]==true or adoptedParents[parent]==true
                or mountParents[parent]==true
            local md=parent:getModData()
            for _,slotId in ipairs(M.SLOT_ORDER) do
                local key="MLO_slot_"..slotId
                if md[key]~=nil then
                    md[key]=nil
                    changed=true
                    M.logOnce("reconcile-slot:"..playerKey(player)..":"..slotId,
                        "server reconciliation cleared legacy parallel slot state "
                            ..slotId.." after "..tostring(cause))
                end
            end
            M.ensureAttachmentsProvided(parent)
            if changed and not pcall(function() parent:syncItemFields() end) then return false end
        end
    end
    local modules=M.syncInstalledModules(player,false,nil,true)
    local attached=M.syncAttachedItems(player,nil,true)
    if not modules or not attached then return false end
    migratedPlayers[player]=true
    return true
end

local function migrateAndReady(player,cause)
    if not M.reconcileComponents(player) then return false end
    if not migratePlayerOnce(player,cause) then return false end
    sendServerCommand(player,M.MODULE,"serverReady",{version=M.VERSION,build=M.BUILD})
    return true
end

local function addServerEvent(name,handler)
    local event=Events and Events[name]
    if not event then return false end
    local ok=pcall(function() event.Add(handler) end)
    if not ok then M.logOnce("server-event:"..name,"server event registration failed: "..name) end
    return ok
end

local function onClientCommand(module,command,player,args)
    if module~=M.MODULE or not player or not args then return end

    if command=="clientReady" then
        migrateAndReady(player,"client-ready")
        return
    end

    if command=="reconcileComponents" then
        -- No ids, flags or destinations are accepted from the client.
        M.reconcileComponents(player)
        return
    end

    if command=="mountItem" then
        local parent=M.findById(player,args.parentId)
        local item=M.findById(player,args.itemId)
        local slotId=tostring(args.slotId or "")
        if not parent or not item then fail(player,M.message("IGUI_MLO_Error_AttachmentMissing")) return end
        local mounted,mountReason=M.mountItem(player,parent,slotId,item)
        if not mounted then fail(player,mountReason) return end
        stateChanged(player,parent,M.message("IGUI_MLO_Status_Attached"))
        return
    end

    if command=="unmountItem" then
        local parent=M.findById(player,args.parentId)
        local item=M.findById(player,args.itemId)
        local slotId=tostring(args.slotId or "")
        if not parent or not item then fail(player,M.message("IGUI_MLO_Error_AttachmentMissing")) return end
        local removed,removeReason=M.unmountItem(player,parent,slotId,item)
        if not removed then fail(player,removeReason) return end
        stateChanged(player,parent,M.message("IGUI_MLO_Status_Detached"))
        return
    end

    if command=="unmountItemById" then
        local parent=M.findById(player,args.parentId)
        local slotId=tostring(args.slotId or "")
        local expectedItemId=tonumber(args.itemId)
        if not parent or not expectedItemId or not M.isParent(parent)
            or not M.slotBelongsToGroup(slotId,M.groupOf(parent)) then
            rootExitUnmountAck(player,args.parentId,slotId,expectedItemId,M.message("IGUI_MLO_Error_AttachmentMissing"),false,nil)
            return
        end
        local removed,removeReason=M.unmountItemById(player,parent,slotId,expectedItemId)
        if not removed then
            local current=M.getPersistentMountId(parent,slotId)
            rootExitUnmountAck(player,parent:getID(),slotId,expectedItemId,removeReason,current~=expectedItemId,current)
            return
        end
        stateChanged(player,parent,M.message("IGUI_MLO_Status_Detached"))
        rootExitUnmountAck(player,parent:getID(),slotId,expectedItemId,nil,true,M.getPersistentMountId(parent,slotId))
        return
    end

end
Events.OnClientCommand.Add(onClientCommand)

local function clearPlayerState(player)
    migratedPlayers[player]=nil
    M.clearComponentPlayerState(player)
end

-- Native sandbox updates have no Lua change event. The stable path only
-- compares six booleans; inventories are visited once when a change is seen.
addServerEvent("EveryOneMinute",function()
    local changed = M.takeComponentOptionsChange()
    local players = getOnlinePlayers()
    for index = 0, players:size()-1 do
        local player = players:get(index)
        if changed then M.reconcileComponents(player)
        else M.flushComponentPublications(player, false) end
    end
end)

-- B42 event availability differs between dedicated and listen servers.
addServerEvent("OnCreatePlayer",function(_,player) migratePlayerOnce(player or _,"create") end)
addServerEvent("OnPlayerConnect",function(player) migrateAndReady(player,"connect") end)
addServerEvent("OnPlayerConnected",function(player) migrateAndReady(player,"connected") end)
addServerEvent("OnPlayerDisconnect",clearPlayerState)
addServerEvent("OnPlayerDisconnected",clearPlayerState)

print("[MercenaryLoadout] server loaded "..M.VERSION.." build "..tostring(M.BUILD or 0))
