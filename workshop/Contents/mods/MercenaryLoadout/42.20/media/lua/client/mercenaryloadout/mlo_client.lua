require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISTimedActionQueue"
require "TimedActions/ISAttachItemHotbar"
require "TimedActions/ISDetachItemHotbar"
require "TimedActions/ISDropWorldItemAction"
require "TimedActions/ISDropVehicleItemAction"
require "TimedActions/ISInventoryTransferAction"
require "TimedActions/ISReloadWeaponAction"
require "Hotbar/ISHotbarAttachDefinition"
require "Hotbar/ISHotbar"
require "ISUI/ISInventoryPage"
require "ISUI/ISInventoryPane"
require "ISUI/ISInventoryPaneContextMenu"
require "ISUI/ISDPadWheels"
require "TimedActions/ISWearClothing"
require "TimedActions/ISUnequipAction"
require "TimedActions/ISEquipWeaponAction"
require "RadioCom/ISRadioWindow"
require "mercenaryloadout/mlo_shared"
require "mercenaryloadout/mlo_actions"
require "mercenaryloadout/mlo_radio"

local M = MercenaryLoadout

-- Preserve the stock pane's grouping, transfer and context-menu ownership.
-- Immediately before vanilla groups the current visible container, repair
-- only direct MLO parents whose replicated name identity is already present.
-- This keeps the owner-confirmed backpack name behavior without transfer
-- hooks, nested inventory scans or extra packets.
local vanillaInventoryPaneRefreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    local inventory = self.inventory
    local items = inventory and inventory:getItems() or nil
    if items then
        for index = 0, items:size() - 1 do
            local item = items:get(index)
            local md = item and item:getModData() or nil
            if md and md.MLO_nameKey and M.isParent(item) then
                M.refreshDynamicName(item)
            end
        end
    end
    return vanillaInventoryPaneRefreshContainer(self)
end

-- Hidden fixed pockets cannot enter Build 42's clothing network because an
-- InventoryContainer has no ItemVisual. The stock reload action only checks
-- equipped/worn tags, so mirror its single 1.15 ammo-strap bonus when the
-- equipped ALICE rig owns the matching fixed pocket. Vanilla remains the
-- owner of reload classification, base speed, moodles, skills and animation;
-- this wrapper adds nothing when a normal worn/equipped strap already earned
-- the same bonus.
local function safeCharacterCall(callback, fallback)
    local ok, value = pcall(callback)
    if ok then return value end
    return fallback
end

local function activeAmmoPocket(character, fullType)
    for _, item in ipairs(M.activeFixedModuleContainers(character)) do
        if M.fullType(item) == fullType then return true end
    end
    return false
end

local function vanillaAmmoStrapBonusApplied(character, shell)
    local equippedShell = safeCharacterCall(function()
        return character:hasEquippedTag(ItemTag.RELOAD_FAST_SHELLS)
    end, false)
    local equippedBullets = safeCharacterCall(function()
        return character:hasEquippedTag(ItemTag.RELOAD_FAST_BULLETS)
    end, false)
    local strap = safeCharacterCall(function()
        return character:getWornItem(ItemBodyLocation.AMMO_STRAP)
    end, nil)
    local strapClothing = strap and safeCharacterCall(function() return strap:getClothingItem() end, nil) or nil
    if not (equippedShell or equippedBullets or strapClothing) then return false end
    local wornTag = shell and ItemTag.RELOAD_FAST_SHELLS or ItemTag.RELOAD_FAST_BULLETS
    local hasMatchingTag = shell and equippedShell or equippedBullets
    hasMatchingTag = hasMatchingTag or safeCharacterCall(function()
        return character:hasWornTag(wornTag)
    end, false)
    local expectedName = shell and "AmmoStrap_Shells" or "AmmoStrap_Bullets"
    local strapName = strap and safeCharacterCall(function() return strap:getClothingItemName() end, nil) or nil
    return hasMatchingTag or strapName == expectedName
end

local vanillaReloadWeaponSetReloadSpeed = ISReloadWeaponAction.setReloadSpeed
function ISReloadWeaponAction.setReloadSpeed(character, rack)
    vanillaReloadWeaponSetReloadSpeed(character, rack)
    if not character then return end
    local gun = safeCharacterCall(function() return character:getPrimaryHandItem() end, nil)
    if not gun or safeCharacterCall(function() return gun:getMagazineType() end, nil) then return end
    local shell = safeCharacterCall(function()
        return gun:getAmmoType() == AmmoType.SHOTGUN_SHELLS
    end, false)
    local pocketType = shell and "MercenaryLoadout.MLO_ShellPouch"
        or "MercenaryLoadout.MLO_BulletPouch"
    if not activeAmmoPocket(character, pocketType)
        or vanillaAmmoStrapBonusApplied(character, shell) then return end
    local speed = safeCharacterCall(function() return character:getVariableFloat("ReloadSpeed", 1.0) end, 1.0)
    character:setVariable("ReloadSpeed", speed * 1.15)
end

-- The stock transfer action remains the only owner of item movement and the
-- multiplayer transaction.  Build 42's immediate renderDirty pass can race
-- the final container state for an attached InventoryContainer, leaving an
-- unmovable stale row.  Observe successful stock completion and rebuild the
-- stock pages on the next player update; never transfer, clone, add or remove
-- an item here.
local pendingMountedContainerTransferRefresh = {}
local pendingInventoryMutation = {}
-- Temporary build16 evidence only: at most 96 item samples per Lua session.
-- Never mutate inventory, request packets or retain a trace beyond one update.
local pendingContainerTransferTrace = {}
local containerTransferTraceLines = 0
local function traceContainerTransfer(action, phase, items)
    if containerTransferTraceLines >= 96 then return false end
    local ok, traced = pcall(function()
        local source, target = action.srcContainer, action.destContainer
        local function owner(container)
            return container and container:getContainingItem() or nil
        end
        local sourceOwner, targetOwner = owner(source), owner(target)
        local function isBox(item)
            return item and M.VANILLA_CONTAINER_STATE[M.fullType(item)] ~= nil
        end
        if not isBox(sourceOwner) and not isBox(targetOwner) then return false end
        local player = action.character
        local root = player:getInventory()
        local data = getPlayerData(player:getPlayerNum())
        local function location(container)
            if container == source then return "source" end
            if container == target then return "target" end
            if container == root then return "player-root" end
            return "other"
        end
        local function state(container, item)
            if not container then return "nil" end
            local idCount, exactCount = 0, 0
            local list = container:getItems()
            for i = 0, list:size() - 1 do
                local entry = list:get(i)
                if entry:getID() == item:getID() then idCount = idCount + 1 end
                if entry == item then exactCount = exactCount + 1 end
            end
            return idCount .. "/" .. exactCount .. "/" .. tostring(container:isDrawDirty())
        end
        local function paneState(page, item)
            local pane = page and page.inventoryPane
            if not pane then return "none" end
            local count, seen = 0, {}
            for _, group in ipairs(pane.itemslist or {}) do
                for _, entry in ipairs(group.items or {}) do
                    if not seen[entry] and entry:getID() == item:getID() then count = count + 1 end
                    seen[entry] = true
                end
            end
            return location(pane.inventory) .. "/" .. count .. "/"
                .. tostring(pane.refreshContainerCount)
        end
        local box = isBox(targetOwner) and targetOwner or sourceOwner
        local currentBox
        local rootItems = root:getItems()
        for i = 0, rootItems:size() - 1 do
            local entry = rootItems:get(i)
            if entry:getID() == box:getID() then currentBox = entry break end
        end
        local boxInventory = box:getInventory()
        local parentRead, innerParent = pcall(function() return boxInventory:getParent() end)
        for i = 1, math.min(#items, 4) do
            if containerTransferTraceLines >= 96 then break end
            local item = items[i]
            containerTransferTraceLines = containerTransferTraceLines + 1
            print("[MLO transfer trace] phase=" .. phase .. " item=" .. item:getID() .. "/" .. M.fullType(item)
                .. " actual=" .. location(item:getContainer())
                .. " source(id/exact/dirty)=" .. state(source, item)
                .. " target(id/exact/dirty)=" .. state(target, item)
                .. " root(id/exact/dirty)=" .. state(root, item)
                .. " box=" .. box:getID() .. " rootBoxSame=" .. tostring(currentBox == box)
                .. " boxInner=" .. location(boxInventory)
                .. " currentInnerSame=" .. tostring(currentBox and currentBox:getInventory() == boxInventory)
                .. " innerParentIsPlayer=" .. (parentRead and tostring(innerParent == player) or "unknown")
                .. " currentInner(id/exact/dirty)=" .. state(currentBox and currentBox:getInventory(), item)
                .. " playerPane(bound/cached/refresh)=" .. paneState(data and data.playerInventory, item)
                .. " lootPane(bound/cached/refresh)=" .. paneState(data and data.lootInventory, item))
        end
        return #items > 0
    end)
    if not ok then
        containerTransferTraceLines = 96
        M.logOnce("container-transfer-trace", "temporary container trace unavailable; native transfer unchanged")
    end
    return ok and traced == true
end
local rootExitRelation
local requestRootExitUnmount

local function isMloContainerInventory(inventory)
    if not inventory then return false end
    local ok, item = pcall(function() return inventory:getContainingItem() end)
    if not ok or not item then return false end
    local md=item:getModData()
    local moduleKey=md and tostring(md.MLO_moduleKey or "") or ""
    local mountSlot=md and tostring(md.MLO_mountSlotId or "") or ""
    return M.isFixedPouchItem(item)
        or moduleKey=="packMedBox" or moduleKey=="packToolbox"
        or mountSlot=="MLO_Pack_MedBox" or mountSlot=="MLO_Pack_Toolbox"
end

local function isMloRelevantItem(item)
    if not item then return false end
    local md=item:getModData()
    return M.isParent(item) or M.isFixedPouchItem(item)
        or (md and (md.MLO_parentId~=nil or md.MLO_mountParentId~=nil
            or md.MLO_moduleKey~=nil or md.MLO_mountSlotId~=nil))
end

local function currentTransferItems(action)
    local items={}
    local queued=action.queueList and action.queueList[1] or nil
    if queued and queued.items then
        for _,item in ipairs(queued.items) do items[#items+1]=item end
    elseif action.item then
        items[1]=action.item
    end
    return items
end

local function hasTableEntries(entries)
    if not entries then return false end
    for _ in pairs(entries) do return true end
    return false
end

local function captureTransferRootExitRelations(action)
    local player=action.character
    local relations={}
    local function capture(item)
        local relation=rootExitRelation and rootExitRelation(player,item) or nil
        if relation then relations[relation.itemId]=relation end
    end
    if action.queueList then
        for _,queued in ipairs(action.queueList) do
            if queued and queued.items then
                for _,item in ipairs(queued.items) do capture(item) end
            end
        end
    elseif action.item then
        capture(action.item)
    end
    action.MLO_rootExitRelations=hasTableEntries(relations) and relations or nil
end

-- Native attachment packets and ClientCommand share reliable ordered channel
-- 0; inventory transactions use channel 1. Await a server acknowledgement of
-- the exact box ownership repair before allowing the native transfer to start.
local mountedTransferSequence=0
local pendingMountedTransferPrepare={}
local function clearMountedTransferPrepare(action)
    local state=action.MLO_transportPrepare
    if state then pendingMountedTransferPrepare[state.token]=nil end
    action.MLO_transportPrepare=nil
end
local vanillaInventoryTransferForceCancel=ISInventoryTransferAction.forceCancel
function ISInventoryTransferAction:forceCancel(...)
    clearMountedTransferPrepare(self)
    if vanillaInventoryTransferForceCancel then return vanillaInventoryTransferForceCancel(self,...) end
end
local function mountedTransferBoxes(action)
    local boxes,seen={},{}
    local player=action.character
    for _,container in ipairs({action.srcContainer,action.destContainer}) do
        local item=container and container:getContainingItem()
        if item and M.VANILLA_CONTAINER_STATE[M.fullType(item)]
            and item:getContainer()==player:getInventory() then
            local parent,slot=M.findPersistentMountParent(player,item)
            if parent and (slot==M.MODULE_SLOT.packMedBox or slot==M.MODULE_SLOT.packToolbox)
                and item:getInventory()==container and not seen[item] then
                boxes[#boxes+1]={item=item,inventory=container,parent=parent,slot=slot}
                seen[item]=true
            end
        end
    end
    return boxes
end
local function sameMountedTransferBoxes(a,b)
    if #a~=#b then return false end
    for i,box in ipairs(a) do
        local other=b[i]
        if box.item~=other.item or box.inventory~=other.inventory
            or box.parent~=other.parent or box.slot~=other.slot then return false end
    end
    return true
end
local vanillaInventoryTransferWaitToStart=ISInventoryTransferAction.waitToStart
function ISInventoryTransferAction:waitToStart(...)
    if vanillaInventoryTransferWaitToStart and vanillaInventoryTransferWaitToStart(self,...) then return true end
    if not isClient() then return false end
    local state=self.MLO_transportPrepare
    local boxes=mountedTransferBoxes(self)
    if #boxes==0 and not state then return false end
    if not state then
        mountedTransferSequence=mountedTransferSequence+1
        state={token=mountedTransferSequence,boxes=boxes,startedAt=getTimestampMs()}
        self.MLO_transportPrepare=state
        pendingMountedTransferPrepare[state.token]=self
        local ids={}
        for _,box in ipairs(boxes) do ids[#ids+1]=box.item:getID() end
        sendClientCommand(self.character,M.MODULE,"prepareMountedTransfer",{token=state.token,boxIds=ids})
        return true
    end
    if state.rejected or not sameMountedTransferBoxes(state.boxes,boxes)
        or getTimestampMs()-state.startedAt>10000 then
        clearMountedTransferPrepare(self)
        M.logOnce("mounted-transfer-prepare","mounted container transfer cancelled before native transaction: ownership changed or server preparation unavailable")
        self:forceStop()
        return true
    end
    if not state.ready then return true end
    for _,box in ipairs(boxes) do
        local ok=M.ensureMountedContainerTransport(self.character,box.item)
        if not ok then clearMountedTransferPrepare(self);self:forceStop();return true end
    end
    clearMountedTransferPrepare(self)
    return false
end

local vanillaInventoryTransferStart = ISInventoryTransferAction.start
local vanillaInventoryTransferPerform = ISInventoryTransferAction.perform
local vanillaInventoryTransferStop = ISInventoryTransferAction.stop
function ISInventoryTransferAction:start(...)
    self.MLO_rootExitRelations=nil
    traceContainerTransfer(self, "before-start", currentTransferItems(self))
    local result=vanillaInventoryTransferStart(self,...)
    -- In multiplayer the stock action may complete the actual move while
    -- perform() is waiting for the transaction acknowledgement. Capture the
    -- durable relation only after stock start has accepted the action, while
    -- the item is still a direct child of the player inventory.
    if self.started then captureTransferRootExitRelations(self) end
    return result
end

function ISInventoryTransferAction:perform()
    local player = self.character
    local touchesMountedContainer = isMloContainerInventory(self.srcContainer)
        or isMloContainerInventory(self.destContainer)
    local candidates=currentTransferItems(self)
    local relevant=false
    for _,item in ipairs(candidates) do
        relevant=relevant or isMloRelevantItem(item)
    end
    local result = vanillaInventoryTransferPerform(self)
    local traced = traceContainerTransfer(self, "after-perform", candidates)
    if player then
        local playerNum=player:getPlayerNum()
        if traced then
            pendingContainerTransferTrace[playerNum] = {
                action={character=player,srcContainer=self.srcContainer,destContainer=self.destContainer},
                items=candidates,
            }
        end
        if relevant then pendingInventoryMutation[playerNum]=true end
        if touchesMountedContainer then
            pendingMountedContainerTransferRefresh[playerNum] = true
        end
        local root=player:getInventory()
        local relations=self.MLO_rootExitRelations
        for _,candidate in ipairs(candidates) do
            local itemId=tonumber(candidate and candidate:getID() or nil)
            local relation=itemId and relations and relations[itemId] or nil
            if relation then
                relations[itemId]=nil
                local item=M.findById(player,itemId)
                if not item or item:getContainer()~=root then requestRootExitUnmount(player,relation) end
            end
        end
        if relations and not hasTableEntries(relations) then self.MLO_rootExitRelations=nil end
    end
    return result
end

function ISInventoryTransferAction:stop(...)
    clearMountedTransferPrepare(self)
    self.MLO_rootExitRelations=nil
    return vanillaInventoryTransferStop(self,...)
end

M.registerAttachedLocations()
M.registerBodyLocations()

local function hotbarDefinition(slotType)
    for _, definition in pairs(ISHotbarAttachDefinition or {}) do
        if definition.type == slotType then return definition end
    end
    return nil
end

local function registerHotbarDefinitions()
    for slotId, templateType in pairs(M.HOTBAR_TEMPLATE) do
        if not hotbarDefinition(slotId) then
            local template = hotbarDefinition(templateType)
            if template and template.attachments then
                local attachments = {}
                local allowed = M.SLOT_ALLOWED_ATTACHMENT_TYPES[slotId]
                if allowed then
                    for attachmentType, attachedLocation in pairs(allowed) do
                        attachments[attachmentType] = attachedLocation
                    end
                else
                    for attachmentType in pairs(template.attachments) do
                        attachments[attachmentType] = slotId
                    end
                end
                table.insert(ISHotbarAttachDefinition, {
                    type = slotId,
                    name = M.text(M.SLOT_LABEL_KEY[slotId]),
                    animset = template.animset,
                    attachments = attachments,
                })
            else
                M.logOnce("hotbar-definition:" .. slotId,
                    "missing vanilla hotbar template " .. tostring(templateType))
            end
        end
    end
end

registerHotbarDefinitions()

local function mloSlotIdFromDefinition(slotDef)
    local slotId=slotDef and slotDef.type or nil
    if slotId and M.HOTBAR_TEMPLATE[slotId] then return slotId end
    return nil
end

local HIDDEN_CONTAINER_HOTBAR_SLOT={
    MLO_Pack_MedBox=true,
    MLO_Pack_Toolbox=true,
}

local function isHiddenContainerHotbarSlot(slot)
    local slotId=mloSlotIdFromDefinition(slot and slot.def or nil)
    return slotId and HIDDEN_CONTAINER_HOTBAR_SLOT[slotId]==true
end

-- Container hooks must remain real vanilla Hotbar slots: the stock inventory
-- Attach menu, timed actions, AttachedItem state and saved ordering all depend
-- on availableSlot.  Present one contiguous view to rendering and translate
-- every visible input back to the real slot instead of deleting those hooks.
local function visibleHotbarProjection(hotbar)
    local slots,items,realByVisible,visibleByReal={},{},{},{}
    for realIndex,slot in ipairs(hotbar.availableSlot or {}) do
        if not isHiddenContainerHotbarSlot(slot) then
            local visibleIndex=#slots+1
            slots[visibleIndex]=slot
            items[visibleIndex]=hotbar.attachedItems and hotbar.attachedItems[realIndex] or nil
            realByVisible[visibleIndex]=realIndex
            visibleByReal[realIndex]=visibleIndex
        end
    end
    return slots,items,realByVisible,visibleByReal
end

local function withVisibleHotbarProjection(hotbar,callback,...)
    local slots,items=visibleHotbarProjection(hotbar)
    local realSlots,realItems=hotbar.availableSlot,hotbar.attachedItems
    hotbar.availableSlot,hotbar.attachedItems=slots,items
    hotbar.MLO_visibleProjection=true
    local ok,result=pcall(callback,hotbar,...)
    hotbar.MLO_visibleProjection=nil
    hotbar.availableSlot,hotbar.attachedItems=realSlots,realItems
    if not ok then error(result) end
    return result
end

local vanillaHotbarRender=ISHotbar.render
function ISHotbar:render()
    return withVisibleHotbarProjection(self,vanillaHotbarRender)
end

local vanillaHotbarSetSizeAndPosition=ISHotbar.setSizeAndPosition
function ISHotbar:setSizeAndPosition()
    return withVisibleHotbarProjection(self,vanillaHotbarSetSizeAndPosition)
end

local vanillaHotbarGetSlotIndexAt=ISHotbar.getSlotIndexAt
function ISHotbar:getSlotIndexAt(x,y)
    if self.MLO_visibleProjection then
        return vanillaHotbarGetSlotIndexAt(self,x,y)
    end
    local _,_,realByVisible=visibleHotbarProjection(self)
    local visibleIndex=withVisibleHotbarProjection(self,vanillaHotbarGetSlotIndexAt,x,y)
    return realByVisible[visibleIndex] or -1
end

local vanillaHotbarGetSlotForKey=ISHotbar.getSlotForKey
function ISHotbar:getSlotForKey(key)
    local visibleIndex=vanillaHotbarGetSlotForKey(self,key)
    if visibleIndex==-1 then return -1 end
    local _,_,realByVisible=visibleHotbarProjection(self)
    return realByVisible[visibleIndex] or -1
end

local vanillaHotbarGetKeyForIndex=ISHotbar.getKeyForIndex
function ISHotbar:getKeyForIndex(realIndex)
    local _,_,_,visibleByReal=visibleHotbarProjection(self)
    local visibleIndex=visibleByReal[realIndex]
    if not visibleIndex then return 0 end
    return vanillaHotbarGetKeyForIndex(self,visibleIndex)
end

-- Keep vanilla Hotbar as the owner of every attach/detach action.  The only
-- extra behavior is the exact MLO-slot rejection that vanilla AttachmentType
-- families cannot express (for example BigWeapon contains far more than the
-- one allowed TireIron).
local vanillaHotbarCanBeAttached=ISHotbar.canBeAttached
function ISHotbar:canBeAttached(slot,item)
    local slotId=mloSlotIdFromDefinition(slot and slot.def or nil)
    if slotId and not M.isCompatible(slotId,item) then return false end
    return vanillaHotbarCanBeAttached(self,slot,item)
end

local projectionDirty={}
local projectionRetry={}
local clothingProjectionSignatures={}
local projectionReadiness={}
local pendingStateSettles={}
local pendingUpgradeAttachmentHints={}
M.PROJECTION_READY_GRACE_TICKS=120
M.READINESS_RETRY_BASE_TICKS=120
M.READINESS_MAX_ATTEMPTS=3
M.STATE_SYNC_SETTLE_TICKS=60
M.STATE_SYNC_MAX_ATTEMPTS=5
M.PROJECTION_RETRY_BASE_TICKS=30
M.PROJECTION_RETRY_MAX_ATTEMPTS=5

local function markProjectionDirty(player)
    if player then
        local playerNum=player:getPlayerNum()
        projectionDirty[playerNum]=true
        projectionRetry[playerNum]=nil
    end
end

-- Read only the small native worn list on a clothing event. Ordinary clothing
-- changes do not invalidate every linked container in the player's inventory.
local function clothingProjectionSignature(player)
    local ok,signature=pcall(function()
        local worn=player:getWornItems()
        local entries={}
        for index=0,worn:size()-1 do
            local parent=worn:getItemByIndex(index)
            if parent and M.isParent(parent) then
                local fields={tostring(parent:getID())}
                for _,slotId in ipairs(M.SLOT_ORDER) do
                    fields[#fields+1]=slotId..":"..tostring(M.slotEnabled(parent,slotId))
                        ..":"..tostring(M.getPersistentMountId(parent,slotId))
                end
                local md=parent:getModData()
                for key in pairs(M.FIXED_POUCH) do
                    fields[#fields+1]=key..":"..tostring(md["MLO_module_"..key])
                end
                table.sort(fields)
                entries[#entries+1]=table.concat(fields,"|")
            end
        end
        table.sort(entries)
        return table.concat(entries,";")
    end)
    return ok and signature or nil
end

local function deferFailedProjection(player)
    local playerNum=player:getPlayerNum()
    local retry=projectionRetry[playerNum] or {attempts=0}
    retry.attempts=retry.attempts+1
    projectionRetry[playerNum]=retry
    if retry.attempts>=M.PROJECTION_RETRY_MAX_ATTEMPTS then
        projectionDirty[playerNum]=nil
        retry.waitingForChange=true
        M.logOnce("projection-retry:"..tostring(playerNum),
            "mount projection retry limit reached; waiting for related state change")
        return
    end
    retry.ticks=M.PROJECTION_RETRY_BASE_TICKS*(2^(retry.attempts-1))
    projectionDirty[playerNum]=true
end

-- Multiplayer creates the player, root inventory, Hotbar definitions, and the
-- online PlayerID in separate packets.  Do not rebuild an MLO projection until
-- all four have settled for a short per-player grace period.  In particular,
-- OnCreatePlayer and lightweight state notifications must never send an attachment packet directly.
local function queuePersistentMountProjection(player)
    if not player then return end
    local playerNum=player:getPlayerNum()
    markProjectionDirty(player)
    local state=projectionReadiness[playerNum] or {requested=false}
    state.readyTicks=state.readyTicks or 0
    -- Exhaustion is not a license to retry on every UI/inventory notification.
    -- Only a genuinely different worn-parent/upgrade signature starts a new
    -- bounded request round; player creation resets the whole state separately.
    if state.exhausted and not state.versionMismatch then
        local signature=clothingProjectionSignature(player)
        if signature~=nil and signature~=state.exhaustedSignature then
            state.requested=false
            state.requestAttempts=0
            state.waitTicks=nil
            state.exhausted=nil
            state.exhaustedSignature=nil
        end
    end
    projectionReadiness[playerNum]=state
end

local function upgradeAttachmentHintsForParent(player,parent)
    if not player or not parent then return nil end
    local playerNum=player:getPlayerNum()
    local parentId=tonumber(parent:getID())
    local byParent=parentId and pendingUpgradeAttachmentHints[playerNum] or nil
    local stored=byParent and byParent[parentId] or nil
    if not stored then return nil end
    local enabled={}
    for slotId,upgradeKey in pairs(stored) do
        if M.isInstalled(parent,upgradeKey) then
            stored[slotId]=nil
        else
            enabled[slotId]=true
        end
    end
    if not hasTableEntries(stored) then
        byParent[parentId]=nil
        if not hasTableEntries(byParent) then pendingUpgradeAttachmentHints[playerNum]=nil end
    end
    return hasTableEntries(enabled) and enabled or nil
end

local function addUpgradeAttachmentHint(player,parent,upgradeKey)
    if not player or not parent or not upgradeKey then return nil end
    local playerNum=player:getPlayerNum()
    local parentId=tonumber(parent:getID())
    if not parentId then return nil end
    local hints=pendingUpgradeAttachmentHints[playerNum] or {}
    local parentHints=hints[parentId] or {}
    for slotId,key in pairs(M.SLOT_UPGRADE_KEY or {}) do
        if key==upgradeKey and M.slotBelongsToGroup(slotId,M.groupOf(parent)) then
            parentHints[slotId]=upgradeKey
        end
    end
    if not hasTableEntries(parentHints) then return nil end
    hints[parentId]=parentHints
    pendingUpgradeAttachmentHints[playerNum]=hints
    return upgradeAttachmentHintsForParent(player,parent)
end

local function attachmentHintsByParent(player,snapshot)
    local out={}
    for _,parent in ipairs(snapshot and snapshot.parents or {}) do
        local hints=upgradeAttachmentHintsForParent(player,parent)
        local parentId=tonumber(parent:getID())
        if parentId and hints then out[parentId]=hints end
    end
    return hasTableEntries(out) and out or nil
end

local function queueStateSettle(player,parentId,upgradeKey)
    if not player or not parentId then return end
    local playerNum=player:getPlayerNum()
    local pending=pendingStateSettles[playerNum] or {}
    local id=tonumber(parentId) or parentId
    local state=pending[id] or {ticks=M.STATE_SYNC_SETTLE_TICKS,attempts=0,upgradeKeys={}}
    if upgradeKey then state.upgradeKeys[upgradeKey]=true end
    pending[id]=state
    pendingStateSettles[playerNum]=pending
end

local function settleStateChangedProjection(player)
    if not player then return end
    local playerNum=player:getPlayerNum()
    local pending=pendingStateSettles[playerNum]
    if not pending then return end
    local due={}
    for parentId,state in pairs(pending) do
        state.ticks=state.ticks-1
        if state.ticks<=0 then
            due[#due+1]={parentId=parentId,state=state}
            pending[parentId]=nil
        end
    end
    if not hasTableEntries(pending) then pendingStateSettles[playerNum]=nil end
    if #due==0 then return end

    -- Bounded, exact-upgrade verification; duplicate completion signals share
    -- one record instead of restarting its budget.
    -- Native SyncItemFields replaces ModData, not AttachmentsProvided. Recheck
    -- both item definitions and UI publication once, without global listeners
    -- or recurring inventory projection.
    local snapshot=M.inventorySnapshot(player)
    local repaired=false
    for _,entry in ipairs(due) do
        local parentId,state=entry.parentId,entry.state
        local parent=M.findById(player,parentId,snapshot)
        local settled=parent~=nil
        if parent then
            for upgradeKey in pairs(state.upgradeKeys) do
                addUpgradeAttachmentHint(player,parent,upgradeKey)
                if not M.isInstalled(parent,upgradeKey) then settled=false end
            end
            local hints=upgradeAttachmentHintsForParent(player,parent)
            local readable=M.ensureAttachmentsProvided(parent,hints)
            settled=settled and readable
            repaired=true
        end
        if not settled then
            state.attempts=state.attempts+1
            if state.attempts<M.STATE_SYNC_MAX_ATTEMPTS then
                state.ticks=M.STATE_SYNC_SETTLE_TICKS*state.attempts
                pending[parentId]=state
            else
                M.logOnce("upgrade-settle:"..tostring(parentId),
                    "upgrade UI settlement exhausted; authoritative target/fields unavailable")
            end
        end
    end
    if hasTableEntries(pending) then pendingStateSettles[playerNum]=pending end
    if repaired then queuePersistentMountProjection(player) end
end

-- Both native Done/perform and the existing server notification confirm the
-- same upgrade. Neither is a ModData delivery barrier. This adapter changes
-- presentation only; server upgrade/mount validation remains authoritative.
function M.clientUpgradeCompleted(player,itemId,upgradeKey)
    if not player or not tonumber(itemId) then return end
    local parent=M.findById(player,itemId)
    if parent then
        local hints=addUpgradeAttachmentHint(player,parent,upgradeKey)
        M.refreshDynamicName(parent)
        M.ensureAttachmentsProvided(parent,hints)
        queuePersistentMountProjection(player)
    end
    queueStateSettle(player,itemId,upgradeKey)
end

local function projectionRestoreReady(player)
    if not player or type(getPlayerHotbar)~="function" then return false end
    local playerNum=player:getPlayerNum()
    local state=projectionReadiness[playerNum] or {requested=false,readyTicks=0}
    projectionReadiness[playerNum]=state
    local onlineId=select(2,pcall(function() return player:getOnlineID() end))
    local inventory=select(2,pcall(function() return player:getInventory() end))
    local hotbar=getPlayerHotbar(playerNum)
    local multiplayer=type(isClient)=="function" and isClient()==true
    local onlineReady=not multiplayer or (type(onlineId)=="number" and onlineId>=0)
    if multiplayer and not state.serverReady then
        if state.versionMismatch or state.exhausted then
            projectionDirty[playerNum]=nil
            return false
        end
        local localReady=onlineReady and inventory~=nil and hotbar~=nil
            and hotbar.chr==player and hotbar.availableSlot~=nil
        if localReady and type(sendClientCommand)=="function" then
            if (state.waitTicks or 0)>0 then
                state.waitTicks=state.waitTicks-1
            elseif (state.requestAttempts or 0)>=M.READINESS_MAX_ATTEMPTS then
                state.exhausted=true
                state.exhaustedSignature=clothingProjectionSignature(player)
                projectionDirty[playerNum]=nil
                M.logOnce("readiness-exhausted:"..tostring(playerNum),
                    "server readiness confirmation missing after bounded requests; waiting for related state change")
            else
                state.requestAttempts=(state.requestAttempts or 0)+1
                state.requested=true
                state.waitTicks=M.READINESS_RETRY_BASE_TICKS*(2^(state.requestAttempts-1))
                -- A locally successful call is NOT an ACK. Even thrown sends
                -- consume the bounded attempt so failures cannot spam each frame.
                local sent=pcall(function()
                    sendClientCommand(player,M.MODULE,"clientReady",{version=M.VERSION,build=M.BUILD})
                end)
                if not sent then
                    M.logOnce("readiness-send:"..tostring(playerNum),"server readiness request failed locally")
                end
            end
        end
    end
    local serverReady=not multiplayer or state.serverReady==true
    local ready=onlineReady and serverReady and inventory~=nil
        and hotbar~=nil and hotbar.chr==player and hotbar.availableSlot~=nil
    if not ready then
        state.readyTicks=0
        return false
    end
    if state.readyTicks<M.PROJECTION_READY_GRACE_TICKS then
        state.readyTicks=state.readyTicks+1
        return false
    end
    return true
end

local function requestPersistentMount(player,parent,item,slotId)
    if not player or not parent or not item then return false end
    if isClient() then
        sendClientCommand(player,M.MODULE,"mountItem",{
            parentId=parent:getID(),itemId=item:getID(),slotId=slotId,
        })
        return true
    end
    local ok=M.mountItem(player,parent,slotId,item)
    if not ok then
        markProjectionDirty(player)
        return false
    end
    markProjectionDirty(player)
    return true
end

local requestPersistentUnmountById
local function requestPersistentUnmount(player,parent,item,slotId)
    if not player or not parent or not item then return false end
    if isClient() then
        -- Vanilla has already detached the local AttachedItem at this point.
        -- Keep the exact durable relation pending until server confirmation so
        -- projection cannot reattach it during the multiplayer response gap.
        return requestPersistentUnmountById(player,parent,slotId,item:getID())
    end
    local ok=M.unmountItem(player,parent,slotId,item)
    if not ok then return false end
    markProjectionDirty(player)
    return true
end

-- Vanilla detach/drop/place removes AttachedItem before the authoritative
-- multiplayer unlink is confirmed. Do not replace those actions: keep the
-- durable relation pending, keyed by the exact child id, so projection cannot
-- reattach it and a delayed command cannot clear a newer mount.
local pendingRootExitUnmount={}
M.ROOT_EXIT_RETRY_BASE_TICKS=30
M.ROOT_EXIT_RETRY_MAX_TICKS=240
local function rootExitUnmountKey(player,parent,slotId,itemId)
    local playerNum=player and player:getPlayerNum() or -1
    return table.concat({playerNum,parent and parent:getID() or "",slotId or "",itemId or ""},":")
end

local function clearPendingRootExitUnmount(player,parentId,slotId,itemId)
    if not player then return end
    local key=rootExitUnmountKey(player,{getID=function() return parentId end},slotId,itemId)
    pendingRootExitUnmount[key]=nil
end

local function isPendingRootExitItem(player,item,slotId,snapshot)
    if not player or not item then return false end
    local prefix=tostring(player:getPlayerNum())..":"
    local itemId=tonumber(item:getID())
    for key,pending in pairs(pendingRootExitUnmount) do
        if string.sub(key,1,#prefix)==prefix and pending.itemId==itemId
            and pending.slotId==slotId then
            local parent=M.mountedSlotForItem(player,item,snapshot)
            if parent and tonumber(parent:getID())==pending.parentId then return true end
        end
    end
    return false
end

local function clearAllPendingRootExitUnmount(player)
    local prefix=tostring(player and player:getPlayerNum() or -1)..":"
    for key in pairs(pendingRootExitUnmount) do
        if string.sub(key,1,#prefix)==prefix then
            pendingRootExitUnmount[key]=nil
        end
    end
end

local function rootExitRetryDelay(attempts)
    local exponent=math.max(0,math.min((tonumber(attempts) or 1)-1,3))
    return math.min(M.ROOT_EXIT_RETRY_BASE_TICKS*(2^exponent),M.ROOT_EXIT_RETRY_MAX_TICKS)
end

local function dispatchPendingRootExitUnmount(player,pending)
    if not player or not pending or not isClient() then return false end
    sendClientCommand(player,M.MODULE,"unmountItemById",{
        parentId=pending.parentId,itemId=pending.itemId,slotId=pending.slotId,
    })
    pending.attempts=(tonumber(pending.attempts) or 0)+1
    pending.retryTicks=rootExitRetryDelay(pending.attempts)
    return true
end

local function tickPendingRootExitUnmount(player,pending)
    if not pending or not isClient() then return false end
    pending.retryTicks=(tonumber(pending.retryTicks) or M.ROOT_EXIT_RETRY_BASE_TICKS)-1
    if pending.retryTicks>0 then return false end
    return dispatchPendingRootExitUnmount(player,pending)
end

local function tickPendingRootExitUnmounts(player)
    if not player or not isClient() then return end
    local prefix=tostring(player:getPlayerNum())..":"
    for key,pending in pairs(pendingRootExitUnmount) do
        if string.sub(key,1,#prefix)==prefix then tickPendingRootExitUnmount(player,pending) end
    end
end

requestPersistentUnmountById=function(player,parent,slotId,itemId)
    if not player or not parent or not slotId or not itemId then return false end
    local key=rootExitUnmountKey(player,parent,slotId,itemId)
    if pendingRootExitUnmount[key] then return true end
    local pending={parentId=tonumber(parent:getID()),slotId=tostring(slotId),itemId=tonumber(itemId),attempts=0,retryTicks=0}
    pendingRootExitUnmount[key]=pending
    if isClient() then
        dispatchPendingRootExitUnmount(player,pending)
        markProjectionDirty(player)
        return true
    end
    local ok=M.unmountItemById(player,parent,slotId,itemId)
    if not ok then
        pendingRootExitUnmount[key]=nil
        return false
    end
    clearPendingRootExitUnmount(player,parent:getID(),slotId,itemId)
    markProjectionDirty(player)
    return true
end

-- AttachmentsProvided belongs to the current item instance while MLO_up_*
-- remains the durable authority. Restore only a genuinely stale worn-parent
-- projection immediately before vanilla consumes it. The stock wornItems
-- cache must remain intact on the common no-change path because clothing
-- updates are intentionally frequent in Build 42.
local vanillaHotbarRefresh=ISHotbar.refresh
local function restoreChangedWornMloAttachments(hotbar)
    local player=hotbar and hotbar.chr or nil
    if not player then return false end
    local playerNum=player:getPlayerNum()
    local readiness=projectionReadiness[playerNum]
    if type(isClient)=="function" and isClient()==true
        and (not readiness or readiness.serverReady~=true) then return false end
    local readOk,worn=pcall(function() return player:getWornItems() end)
    if not readOk or not worn then return false end
    local changed=false
    for index=0,worn:size()-1 do
        local parent=worn:getItemByIndex(index)
        if parent and M.isParent(parent) then
            local callOk,provided,parentChanged=pcall(function()
                local hints=upgradeAttachmentHintsForParent(player,parent)
                return M.ensureAttachmentsProvided(parent,hints)
            end)
            if not callOk or provided==false then
                M.logOnce("hotbar-refresh-attachments:"..tostring(parent:getID()),
                    "worn attachment definition refresh failed")
            elseif parentChanged==true then
                changed=true
            end
        end
    end
    return changed
end

function ISHotbar:refresh()
    if restoreChangedWornMloAttachments(self) then
        -- The worn identity may be unchanged while its transient attachment
        -- list was recreated. Bypass only that one stale cache entry; vanilla
        -- still owns slot ordering, removals, reattachment and persistence.
        self.wornItems=nil
    end
    return vanillaHotbarRefresh(self)
end

local vanillaHotbarAttachItem=ISHotbar.attachItem
local vanillaHotbarRemoveItem=ISHotbar.removeItem
local pendingVanillaMount={}
local function mountIntentKey(item)
    if not item then return nil end
    local ok,id=pcall(function() return item:getID() end)
    if not ok or id==nil then return nil end
    return tostring(id)
end

local function validatedMloVanillaAttach(self,item,attachedLocation,slotIndex,slotDef,doAnim)
    local requestedSlot=mloSlotIdFromDefinition(slotDef)
    local liveIndex=type(self.getThisSlotIndex)=="function" and self:getThisSlotIndex(requestedSlot) or nil
    local liveSlot=liveIndex and self.availableSlot and self.availableSlot[liveIndex] or nil
    local liveDef=liveSlot and liveSlot.def or nil
    local slotId=mloSlotIdFromDefinition(liveDef)
    if not requestedSlot and not slotId then return nil end
    if not requestedSlot or requestedSlot~=slotId or not item or liveIndex~=slotIndex then return false end
    if not M.isCompatible(slotId,item) then return false end
    local attachmentType=item:getAttachmentType()
    local baseExpected=liveDef.attachments and liveDef.attachments[attachmentType] or nil
    local expected=type(M.resolveAttachedLocation)=="function"
        and M.resolveAttachedLocation(slotId,item,baseExpected) or baseExpected
    local allowed=M.SLOT_ALLOWED_ATTACHMENT_TYPES[slotId]
    local locationGroup=AttachedLocations and AttachedLocations.getGroup("Human") or nil
    local location=expected and locationGroup and select(2,pcall(function()
        return locationGroup:getLocation(expected)
    end)) or nil
    local attachmentName=location and select(2,pcall(function() return location:getAttachmentName() end)) or nil
    if not baseExpected or not M.ATTACHED[baseExpected]
        or not attachmentName
        or (allowed and allowed[attachmentType]~=baseExpected)
        or (doAnim~=false and attachedLocation~=baseExpected and attachedLocation~=expected) then
        return false
    end
    return {slotId=slotId,attachedLocation=expected,slotIndex=liveIndex,slotDef=liveDef}
end

function ISHotbar:attachItem(item,attachedLocation,slotIndex,slotDef,doAnim)
    local checked=validatedMloVanillaAttach(self,item,attachedLocation,slotIndex,slotDef,doAnim)
    if checked==false then return false end
    local slotId=checked and checked.slotId or nil
    -- Vanilla refresh may reattach surviving items while publishing a new
    -- hook. Suppress only the exact item awaiting authoritative unlink; an
    -- unrelated pending unlink must not freeze all new slots.
    if slotId and isPendingRootExitItem(self.chr,item,slotId) then return false end
    if slotId and doAnim then
        local snapshot=M.inventorySnapshot(self.chr)
        local parent=M.parentForSlot(self.chr,slotId,true,snapshot,
            attachmentHintsByParent(self.chr,snapshot))
        local linkedParent,linkedSlot=M.mountedSlotForItem(self.chr,item,snapshot)
        if not parent then return false end
        if linkedParent and (linkedParent~=parent or linkedSlot~=slotId) then return false end
        if not linkedParent then
            local key=mountIntentKey(item)
            if not key then return false end
            pendingVanillaMount[key]={
                parentId=parent:getID(),slotId=slotId,
                playerNum=self.chr and self.chr:getPlayerNum() or -1,
            }
        end
    end
    local result=vanillaHotbarAttachItem(self,item,
        checked and checked.attachedLocation or attachedLocation,
        checked and checked.slotIndex or slotIndex,checked and checked.slotDef or slotDef,doAnim)
    if result==false then
        local key=mountIntentKey(item)
        if key then pendingVanillaMount[key]=nil end
    end
    return result
end

-- Some B42 non-animated remove paths leave only attachedToModel cleared.  The
-- guard is deliberately limited to MLO slots and animated removal is untouched.
-- If Java still owns the attachment mapping, repair just enough model state to
-- let vanilla removeAttachedItem perform its normal character cleanup.
local function mloAttachedLocationAvailable(slotId)
    if not slotId or not AttachedLocations or type(AttachedLocations.getGroup)~="function" then return false end
    local groupOk,group=pcall(AttachedLocations.getGroup,"Human")
    if not groupOk or not group or type(group.getLocation)~="function" then return false end
    local locationOk,location=pcall(function() return group:getLocation(slotId) end)
    return locationOk and location~=nil
end

local function clearHalfRemovedMloFields(hotbar,item,doAnim)
    if doAnim~=false or not item then return false end
    local slotId=item:getAttachedSlotType()
    if not slotId or not M.HOTBAR_TEMPLATE[slotId] or item:getAttachedToModel()~=nil then return false end
    local chr=hotbar and hotbar.chr or nil
    local mapped=nil
    local attachedLocation=type(M.resolveAttachedLocation)=="function"
        and M.resolveAttachedLocation(slotId,item,slotId) or slotId
    if chr then
        local mappedOk,mappedItem=pcall(function() return chr:getAttachedItem(attachedLocation) end)
        if mappedOk then mapped=mappedItem end
    end
    if mapped==item and mloAttachedLocationAvailable(attachedLocation) then
        local restored=pcall(function() item:setAttachedToModel(attachedLocation) end)
        if restored then return false end
    end
    pcall(function()
        item:setAttachedSlot(-1)
        item:setAttachedSlotType(nil)
    end)
    for index,attached in pairs(hotbar.attachedItems or {}) do
        if attached==item then hotbar.attachedItems[index]=nil end
    end
    hotbar.needsRefresh=true
    if hotbar.reloadIcons then pcall(function() hotbar:reloadIcons() end) end
    return true
end

function ISHotbar:removeItem(item,doAnim)
    -- Do this before vanilla. Its non-animated path assumes attachedToModel is
    -- non-null and may emit GameCharacterAttachedItem before reaching its own
    -- cleanup. The guard is MLO-only and never affects an animated interaction.
    if clearHalfRemovedMloFields(self,item,doAnim) then return true end
    local result=vanillaHotbarRemoveItem(self,item,doAnim)
    return result
end

local function removeMloProjectionItem(hotbar,item)
    if clearHalfRemovedMloFields(hotbar,item,false) then return true end
    local result=vanillaHotbarRemoveItem(hotbar,item,false)
    return result
end

-- The stock actions remain the sole owner of interactive Hotbar mutation and
-- inventory transfer.  MLO records/clears its durable relation only after the
-- corresponding vanilla action has completed successfully.
-- Native inventory transfer may leave one client update where the old Java
-- object has gone and its same-ID replacement has not arrived.  Only actions
-- which explicitly opted into a root-inventory rebind may wait through it.
local MLO_ROOT_REBIND_WAIT_MS=2000

local function rootItemById(root,itemId,expectedFullType,requireUnique)
    local item=itemId~=nil and root and root:getItemById(itemId) or nil
    if not item then return nil,"missing" end
    if expectedFullType and M.fullType(item)~=expectedFullType then return nil,"fulltype" end
    if requireUnique then
        local count=0
        local items=root:getItems()
        for index=0,items:size()-1 do
            local candidate=items:get(index)
            if candidate and tonumber(candidate:getID())==tonumber(itemId) then count=count+1 end
        end
        if count~=1 then return nil,"ambiguous" end
    end
    return item
end
local vanillaAttachActionIsValid=ISAttachItemHotbar.isValid
local vanillaAttachActionWaitToStart=ISAttachItemHotbar.waitToStart
local vanillaAttachActionPerform=ISAttachItemHotbar.perform
local vanillaAttachActionStop=ISAttachItemHotbar.stop
local vanillaAttachActionForceCancel=ISAttachItemHotbar.forceCancel

local function pendingMountForAttachAction(action)
    if type(isClient)~="function" or not isClient() or not action then return nil,nil end
    local key=mountIntentKey(action.item)
    local intent=key and pendingVanillaMount[key] or nil
    local character=action.character
    local slotId=action.slotDef and action.slotDef.type or nil
    if not intent or not character or not M.HOTBAR_TEMPLATE[slotId]
        or intent.slotId~=slotId or intent.playerNum~=character:getPlayerNum() then
        return nil,key
    end
    return intent,key
end

local function pendingMountMayWaitForRebind(action)
    local intent,key=pendingMountForAttachAction(action)
    if not intent or not action.action or action.action:isStarted() then return nil,key end
    return intent,key
end

local function clearAttachRebindWait(action)
    action.MLO_attachRebindWaitStartedAt=nil
    action.MLO_attachRebindWaitExpired=nil
end

local function expireAttachRebindWait(action,itemId,slotId)
    if action.MLO_attachRebindWaitExpired then return end
    action.MLO_attachRebindWaitExpired=true
    M.logOnce("attach-rebind-timeout:"..tostring(action.character:getPlayerNum())..":"
            ..tostring(itemId)..":"..tostring(slotId),
        "Hotbar attach replacement wait timed out; slot="..tostring(slotId)
            .." item="..tostring(itemId))
end

function ISAttachItemHotbar:isValid()
    local intent=pendingMountMayWaitForRebind(self)
    if not intent then return vanillaAttachActionIsValid(self) end
    local root=self.character:getInventory()
    local itemId=self.item and self.item:getID() or nil
    if itemId~=nil and root:getItemById(itemId) then
        return vanillaAttachActionIsValid(self)
    end
    if self.MLO_attachRebindWaitExpired then return false end
    local startedAt=self.MLO_attachRebindWaitStartedAt
    if startedAt and getTimestampMs()-startedAt>=MLO_ROOT_REBIND_WAIT_MS then
        expireAttachRebindWait(self,itemId,intent.slotId)
        return false
    end
    return true
end

function ISAttachItemHotbar:waitToStart()
    local intent=pendingMountMayWaitForRebind(self)
    if not intent then return vanillaAttachActionWaitToStart(self) end
    local root=self.character:getInventory()
    local itemId=self.item and self.item:getID() or nil
    local current=rootItemById(root,itemId)
    if current then
        self.item=current
        clearAttachRebindWait(self)
        return vanillaAttachActionWaitToStart(self)
    end
    local now=getTimestampMs()
    if not self.MLO_attachRebindWaitStartedAt then
        self.MLO_attachRebindWaitStartedAt=now
    elseif now-self.MLO_attachRebindWaitStartedAt>=MLO_ROOT_REBIND_WAIT_MS then
        expireAttachRebindWait(self,itemId,intent.slotId)
    end
    return true
end

function ISAttachItemHotbar:perform()
    local key=mountIntentKey(self.item)
    local intent=key and pendingVanillaMount[key] or nil
    local result=vanillaAttachActionPerform(self)
    clearAttachRebindWait(self)
    if intent then
        pendingVanillaMount[key]=nil
        local parent=M.findById(self.character,intent.parentId)
        if parent and self.item:getAttachedSlotType()==intent.slotId
            and self.item:getContainer()==self.character:getInventory() then
            requestPersistentMount(self.character,parent,self.item,intent.slotId)
        end
    end
    return result
end

function ISAttachItemHotbar:stop()
    local key=mountIntentKey(self.item)
    if key then pendingVanillaMount[key]=nil end
    clearAttachRebindWait(self)
    return vanillaAttachActionStop(self)
end

function ISAttachItemHotbar:forceCancel()
    local key=mountIntentKey(self.item)
    if key then pendingVanillaMount[key]=nil end
    clearAttachRebindWait(self)
    return vanillaAttachActionForceCancel(self)
end

local vanillaDetachActionPerform=ISDetachItemHotbar.perform
function ISDetachItemHotbar:perform()
    local parent,slotId=M.mountedSlotForItem(self.character,self.item)
    local result=vanillaDetachActionPerform(self)
    if parent and slotId and self.item:getAttachedSlotType()==nil then
        requestPersistentUnmount(self.character,parent,self.item,slotId)
    end
    return result
end

-- A right-click upgrade of an item inside a bag uses vanilla transfer first.
-- The follow-on MLO action is allowed to rebind only before it starts, so a
-- normal same-ID client replacement can continue while a wrong/ambiguous
-- replacement, cancellation, or prolonged missing item fails closed.
if MLOUpgradeAction then
local vanillaUpgradeActionIsValid=MLOUpgradeAction.isValid
local vanillaUpgradeActionWaitToStart=MLOUpgradeAction.waitToStart
local vanillaUpgradeActionStop=MLOUpgradeAction.stop
local vanillaUpgradeActionForceCancel=MLOUpgradeAction.forceCancel

local function clearUpgradeRootRebind(action)
    action.MLO_upgradeRootRebind=nil
end

local function upgradeRootRebindMayWait(action)
    local state=action.MLO_upgradeRootRebind
    if not state or not action.action or action.action:isStarted() then return nil end
    return state
end

function MLOUpgradeAction:isValid()
    if not self.character or self.character:isDead() or not self.target then return false end
    local state=upgradeRootRebindMayWait(self)
    if not state then return vanillaUpgradeActionIsValid(self) end
    local item,reason=rootItemById(self.character:getInventory(),state.itemId,state.fullType,true)
    if state.expired then return false end
    if item then return true end
    if reason~="missing" then return false end
    local startedAt=state.waitStartedAt
    if startedAt and getTimestampMs()-startedAt>=MLO_ROOT_REBIND_WAIT_MS then
        state.expired=true
        return false
    end
    return true
end

function MLOUpgradeAction:waitToStart()
    local state=upgradeRootRebindMayWait(self)
    if not state then return vanillaUpgradeActionWaitToStart(self) end
    local item,reason=rootItemById(self.character:getInventory(),state.itemId,state.fullType,true)
    if item then
        self.target=item
        local def=M.UPGRADES[self.upgradeKey]
        local ok=M.checkUpgrade(self.character,item,self.upgradeKey)
        if not ok or not def then
            state.expired=true
            return true
        end
        self.maxTime=M.upgradeDurationTicks(self.character,def.time)
        clearUpgradeRootRebind(self)
        return vanillaUpgradeActionWaitToStart(self)
    end
    if reason~="missing" then
        state.expired=true
        return true
    end
    local now=getTimestampMs()
    if not state.waitStartedAt then
        state.waitStartedAt=now
    elseif now-state.waitStartedAt>=MLO_ROOT_REBIND_WAIT_MS then
        state.expired=true
    end
    return true
end

function MLOUpgradeAction:stop()
    clearUpgradeRootRebind(self)
    return vanillaUpgradeActionStop(self)
end

function MLOUpgradeAction:forceCancel()
    clearUpgradeRootRebind(self)
    return vanillaUpgradeActionForceCancel(self)
end
end

-- Both mouse/key activation and the D-pad adapter enter this same native action
-- path. Returning a Radio uses AttachItemHotbar, not UnequipAction (which turns
-- activated devices off). Only manual radio controls own power/media state.
local function activatePortableRadio(hotbar, item, slotIndex, slot)
    if not item or not instanceof(item, "Radio") or not slot or not slot.def then return false end
    if item:getAttachedSlot() ~= slotIndex then return true end
    local player = hotbar.chr
    if player:getPrimaryHandItem() == item or player:getSecondaryHandItem() == item then
        local location = item:getAttachedToModel()
        if not location or location == "null" then return true end
        -- Close before removing from hands, so native window.update cannot
        -- interpret the return-to-mount action as permission to switch off.
        local window = ISRadioWindow.instances[player:getPlayerNum()]
        if window and window.device == item then window:close() end
        ISTimedActionQueue.add(ISAttachItemHotbar:new(player, item, location, slotIndex, slot.def))
    else
        -- Native completion publishes equipment; native OnEquipSecondary opens
        -- the actual device window, after the item has reached the hand.
        ISInventoryPaneContextMenu.transferIfNeeded(player, item)
        ISTimedActionQueue.add(ISEquipWeaponAction:new(player, item, 20, false, false))
    end
    return true
end

-- Clothing stays assigned to its Hotbar slot while vanilla Wear/Unequip owns
-- the actual clothing state. ISHotbar:update() already hides the attached
-- model while the item is worn and restores it when it is taken off.
local vanillaHotbarActivateSlot=ISHotbar.activateSlot
function ISHotbar:activateSlot(slotIndex)
    local item=self.attachedItems and self.attachedItems[slotIndex] or nil
    local slot=self.availableSlot and self.availableSlot[slotIndex] or nil
    local slotId=slot and mloSlotIdFromDefinition(slot.def) or nil
    if activatePortableRadio(self, item, slotIndex, slot) then return end
    if item and slotId=="MLO_Pack_WeldingMask" and M.isCompatible(slotId,item) then
        if self.chr:isEquipped(item) then
            ISTimedActionQueue.add(ISUnequipAction:new(self.chr,item,50))
        else
            ISTimedActionQueue.add(ISWearClothing:new(self.chr,item,50))
        end
        return
    end
    return vanillaHotbarActivateSlot(self,slotIndex)
end

-- Build 42.20.4's D-pad-left wheel has native weapon and light slices but no
-- Radio slice. Add attached radios and route the selection through the exact
-- Hotbar activation used by mouse and keyboard input.
local function activateAttachedRadioFromDPad(playerIndex,itemId,slotType)
    local player=getSpecificPlayer(playerIndex)
    local hotbar=getPlayerHotbar(playerIndex)
    if not player or not hotbar then return end
    for slotIndex,slot in ipairs(hotbar.availableSlot or {}) do
        local currentType=slot.slotType or (slot.def and slot.def.type)
        local item=hotbar.attachedItems and hotbar.attachedItems[slotIndex] or nil
        if currentType==slotType and item and instanceof(item,"Radio")
            and tonumber(item:getID())==tonumber(itemId)
            and item:getAttachedSlot()==slotIndex
            and (player:isEquipped(item) or player:isAttachedItem(item)) then
            -- Native radial removal is deferred by UIManager. Its callback still
            -- sees isReallyVisible=true in this frame; exclude only this closing
            -- wheel while retaining the stock pause/death/attack/action guards.
            local menu = getPlayerRadialMenu(playerIndex)
            local visible = menu:isVisible()
            menu:setVisible(false)
            local ok, allowed = pcall(hotbar.isAllowedToActivateSlot, hotbar)
            menu:setVisible(visible)
            if ok and allowed then hotbar:activateSlot(slotIndex) end
            return
        end
    end
end

-- Vanilla selects one strongest light. Preserve that slice and append the
-- other mounted lights, sharing its exact toggle/sync/sound callback.
local function addMissingMountedLightSlices(player, hotbar, menu)
    local shown = {}
    for _, slice in ipairs(menu.slices or {}) do
        local command = slice.command
        if command and command[1] == ISDPadWheels.onToggleLight and command[2] == player then
            shown[command[3]] = true
        end
    end
    for slotIndex, item in pairs(hotbar.attachedItems or {}) do
        if item and not shown[item] and item.canEmitLight and item:canEmitLight()
            and not instanceof(item, "HandWeapon")
            and item:getContainer() == player:getInventory()
            and item:getAttachedSlot() == slotIndex
            and (player:isEquipped(item) or player:isAttachedItem(item)) then
            menu:addSlice(item:getDisplayName(), item:getTex(), ISDPadWheels.onToggleLight, player, item)
            shown[item] = true
        end
    end
end

local vanillaDPadDisplayLeft=ISDPadWheels.onDisplayLeft
ISDPadWheels.onDisplayLeft=function(joypadData)
    local result=vanillaDPadDisplayLeft(joypadData)
    local speedControls=UIManager.getSpeedControls()
    if speedControls and speedControls:getCurrentGameSpeed()==0 then return result end

    local playerIndex=joypadData.player
    local player=getSpecificPlayer(playerIndex)
    local hotbar=getPlayerHotbar(playerIndex)
    local menu=getPlayerRadialMenu(playerIndex)
    if not player or not hotbar or not menu then return result end
    addMissingMountedLightSlices(player, hotbar, menu)
    for slotIndex,slot in ipairs(hotbar.availableSlot or {}) do
        local item=hotbar.attachedItems and hotbar.attachedItems[slotIndex] or nil
        if item and instanceof(item,"Radio") and item:getAttachedSlot()==slotIndex
            and (player:isEquipped(item) or player:isAttachedItem(item)) then
            local slotType=slot.slotType or (slot.def and slot.def.type)
            menu:addSlice(item:getDisplayName(),item:getTex(),activateAttachedRadioFromDPad,
                playerIndex,tonumber(item:getID()),slotType)
        end
    end
    menu:setX(getPlayerScreenLeft(playerIndex)+getPlayerScreenWidth(playerIndex)/2-menu:getWidth()/2)
    menu:setY(getPlayerScreenTop(playerIndex)+getPlayerScreenHeight(playerIndex)/2-menu:getHeight()/2)
    return result
end


local function activeModuleContainers(player,snapshot)
    local out = {}
    local seen = {}
    local items=snapshot and snapshot.items or M.allRecursiveItems(player)
    for _, item in ipairs(items) do
        if M.activeModuleContainer(player, item, snapshot) then
            -- ContainerID serializes an ItemContainer whose parent is the
            -- player as PlayerInventory. Repair only the already-validated
            -- mounted medical/toolbox container before vanilla exposes that
            -- exact container in the sidebar; transfer remains stock-owned.
            local transported,_,reason=M.ensureMountedContainerTransport(player,item,nil,snapshot)
            if transported then
                local id = tonumber(item:getID())
                if not seen[id] then
                    out[#out + 1] = item
                    seen[id] = true
                end
            else
                M.logOnce("container-transport:"..tostring(item:getID()),
                    "mounted container transport rejected: "..tostring(reason))
            end
        end
    end
    local fixedItems,owners=M.activeFixedModuleContainers(player,snapshot)
    for _, item in ipairs(fixedItems) do
        local id = tonumber(item:getID())
        if not seen[id] then
            out[#out + 1] = item
            seen[id] = true
        end
    end
    return out,owners
end

local function addContainerButtonIfMissing(page,item,player,snapshot,parent)
    if not page or not item then return end
    local container = item:getInventory()
    M.refreshDynamicName(item)
    -- Sidebar presentation only. The validated parent link owns this texture;
    -- child ModData may be absent during replication. Never change item icons.
    local texture=item:getTex()
    local keyClip=M.FIXED_POUCH.beltKeyClip
    if parent and (not keyClip or M.fullType(item)~=keyClip.fullType) then
        texture=parent:getTex() or texture
    end
    for _,button in ipairs(page.backpacks or {}) do
        if button.inventory==container then
            if texture then button:setImage(texture) end
            page.MLO_containerButtons[container]=true
            return button
        end
    end
    local button=page:addContainerButton(container, texture, item:getName(), item:getName())
    page.MLO_containerButtons[container]=true
    return button
end

-- Native clickable sources define access (including Floor and vehicle/seat
-- containers). The same discovery is used for display and a fresh menu lookup;
-- a selected/custom child button must never grant access to its former owner.
local function discoverSidebarContainers(page,player)
    local snapshot={byId={},items={},parents={},mountByItemId={}}
    local parents,detached={},{}
    local seenParents,seenItems,seenContainers={},{},{}
    local pending={}
    local root=player:getInventory()
    local function observe(item)
        if not item or seenItems[item] then return end
        seenItems[item]=true
        local id=tonumber(item:getID())
        if id then
            local prior=snapshot.byId[id]
            if prior and prior~=item then snapshot.byId[id]=false
            elseif prior==nil then snapshot.byId[id]=item end
        end
        if M.isParent(item) and not seenParents[item]
            and (not page.onCharacter or M.parentEquipped(player,item)
                or item:getContainer()~=root) then
            seenParents[item]=true
            parents[#parents+1]=item
        end
        if M.isDetachedPouch(item) then detached[#detached+1]=item end
    end
    local sources=page.MLO_nativeContainerSources or page.backpacks or {}
    for _,source in ipairs(sources) do
        local button=source.button or source
        local container=source.container or button.inventory
        local present=false
        for _,current in ipairs(page.backpacks or {}) do
            if current==button then present=true break end
        end
        local ownerUnchanged=not source.owner or (source.owner:getContainer()==source.outer
            and source.owner:getInventory()==container)
        if present and ownerUnchanged and button.onclick and button.inventory==container then
            pending[#pending+1]=container
            local owner=container:getContainingItem()
            if owner and owner:getInventory()==container then observe(owner) end
        end
    end
    local index=1
    while index<=#pending do
        local container=pending[index]
        index=index+1
        if container and not seenContainers[container] then
            seenContainers[container]=true
            local items=container:getItems()
            for i=0,items:size()-1 do
                local item=items:get(i)
                if item and item:getContainer()==container then
                    observe(item)
                    if item:IsInventoryContainer() then
                        local inner=item:getInventory()
                        if inner and inner:getContainingItem()==item then pending[#pending+1]=inner end
                    end
                end
            end
        end
    end
    -- An ordinary loot refresh must not scan the player's whole inventory.
    -- Resolve hidden children there only after discovering a reachable parent.
    if page.onCharacter or #parents>0 then
        local inventorySnapshot=M.inventorySnapshot(player)
        -- The general snapshot is last-write-wins. Sidebar access must reject
        -- two different objects with one ID, including replicas in player
        -- inventory when the visible parent is on the loot page.
        local uniqueById={}
        for _,item in ipairs(inventorySnapshot.items) do
            local id=tonumber(item:getID())
            if id then
                local prior=uniqueById[id]
                if prior~=nil and prior~=item then uniqueById[id]=false
                elseif prior==nil then uniqueById[id]=item end
            end
        end
        inventorySnapshot.byId=uniqueById
        for id,item in pairs(snapshot.byId) do
            local prior=inventorySnapshot.byId[id]
            if item==false or (prior and prior~=item) then inventorySnapshot.byId[id]=false
            elseif prior==nil then inventorySnapshot.byId[id]=item end
        end
        snapshot=inventorySnapshot
    end
    -- Reject ambiguous ownership once for both sidebar and context menu.
    local owners,linked,ambiguous={},{},{}
    for _,parent in ipairs(parents) do
        for moduleKey in pairs(M.FIXED_POUCH) do
            local item=M.fixedModuleContainerForParent(player,parent,moduleKey,snapshot)
            if item then
                if owners[item] then ambiguous[item]=true
                else linked[#linked+1]=item;owners[item]=parent end
            end
        end
    end
    local fixed={}
    for _,item in ipairs(linked) do
        if ambiguous[item] then owners[item]=nil else fixed[#fixed+1]=item end
    end
    return {snapshot=snapshot,parents=parents,detached=detached,fixed=fixed,owners=owners}
end

local function addDetachedPouchButtons(page,player,discovery)
    discovery=discovery or discoverSidebarContainers(page,player)
    for _,item in ipairs(discovery.detached) do addContainerButtonIfMissing(page,item,player) end
end

-- Both sidebars use the same grouping rule. Only move existing pocket
-- buttons: discovery/ownership remains with the respective page adapter.
local function groupFixedPouchButtons(page,player,snapshot)
    local parents={}
    local nativeOrder={}
    for _,button in ipairs(page.backpacks or {}) do
        nativeOrder[#nativeOrder+1]=button
        local container=button.inventory
        local parent=container and container:getContainingItem() or nil
        if parent and M.isParent(parent) then
            parents[#parents+1]={item=parent,button=button}
        end
    end
    local changed=false
    for _,parent in ipairs(parents) do
        local insertAt
        for index,button in ipairs(page.backpacks) do
            if button==parent.button then insertAt=index+1 break end
        end
        for _,item in ipairs(M.fixedModuleContainersForParent(player,parent.item,snapshot)) do
            local container=item:getInventory()
            for index,button in ipairs(page.backpacks) do
                if button.inventory==container and insertAt then
                    if index~=insertAt then
                        table.remove(page.backpacks,index)
                        if index<insertAt then insertAt=insertAt-1 end
                        table.insert(page.backpacks,insertAt,button)
                        changed=true
                    end
                    insertAt=insertAt+1
                    break
                end
            end
        end
    end
    if changed then
        page.MLO_nativeContainerButtonOrder=nativeOrder
        page:onInventoryContainerSizeChanged()
    end
end

-- Stock mouse-up selects twice, with refreshBackpacks between callbacks.
-- Undo only our visual reorder in the recycled pool so stock discovery does
-- not rebind the clicked button to another container during that refresh.
local function restoreNativeContainerButtonPool(page)
    local order=page.MLO_nativeContainerButtonOrder
    page.MLO_nativeContainerButtonOrder=nil
    local pool=page.buttonPool
    if not order or not pool or #pool<#order then return end
    local remaining={}
    for _,button in ipairs(order) do remaining[button]=true end
    for index=1,#order do
        local button=pool[index]
        if not remaining[button] then return end
        remaining[button]=nil
    end
    for index,button in ipairs(order) do pool[index]=button end
end

local function onRefreshInventoryWindowContainers(page, phase)
    if not page then return end
    if phase == "begin" then
        restoreNativeContainerButtonPool(page)
        page.MLO_containerButtons = {}
        page.MLO_nativeContainerSources = nil
        return
    end
    if phase ~= "buttonsAdded" then return end
    local player = getSpecificPlayer(page.player)
    if not player then return end
    page.MLO_containerButtons = page.MLO_containerButtons or {}
    if not page.MLO_nativeContainerSources then
        page.MLO_nativeContainerSources={}
        for _,button in ipairs(page.backpacks or {}) do
            local container=button.inventory
            local owner=container and container:getContainingItem() or nil
            page.MLO_nativeContainerSources[#page.MLO_nativeContainerSources+1]={button=button,container=container,
                owner=owner,outer=owner and owner:getContainer() or nil}
        end
    end
    local discovery=discoverSidebarContainers(page,player)
    local snapshot=discovery.snapshot
    addDetachedPouchButtons(page,player,discovery)
    if page.onCharacter then
        local items,owners=activeModuleContainers(player,snapshot)
        for _,item in ipairs(items) do
            -- Fixed pouches share the scoped, unambiguous owner map below.
            if not M.isFixedPouchItem(item) then addContainerButtonIfMissing(page,item,player,snapshot) end
        end
    end
    for _,item in ipairs(discovery.fixed) do
        addContainerButtonIfMissing(page,item,player,snapshot,discovery.owners[item])
    end
    groupFixedPouchButtons(page,player,snapshot)
end
Events.OnRefreshInventoryWindowContainers.Add(onRefreshInventoryWindowContainers)

local function refreshInventoryContainers(player)
    local playerData = player and getPlayerData(player:getPlayerNum()) or nil
    if not playerData then return end
    if playerData.playerInventory then playerData.playerInventory:refreshBackpacks() end
    if playerData.lootInventory then playerData.lootInventory:refreshBackpacks() end
end

function M.clientComponentsChanged(player)
    markProjectionDirty(player)
    refreshInventoryContainers(player)
end

local function requestComponentReconciliation(player)
    if not player then return end
    if isClient() then
        sendClientCommand(player,M.MODULE,"reconcileComponents",{})
    elseif type(M.reconcileComponents)=="function" then
        M.reconcileComponents(player)
    end
end

local function flushMountedContainerTransferRefresh(player)
    if not player then return end
    local playerNum = player:getPlayerNum()
    local refresh = pendingMountedContainerTransferRefresh[playerNum]
    if refresh then
        pendingMountedContainerTransferRefresh[playerNum] = nil
        refreshInventoryContainers(player)
    end
    local trace = pendingContainerTransferTrace[playerNum]
    pendingContainerTransferTrace[playerNum] = nil
    if trace then
        traceContainerTransfer(trace.action, refresh and "after-refresh" or "next-update-no-refresh", trace.items)
    end
end

local containerSignatures = {}
local function activeContainerSignature(player,snapshot)
    local ids = {}
    for _, item in ipairs(activeModuleContainers(player,snapshot)) do
        ids[#ids + 1] = tostring(item:getID())
    end
    local parents=snapshot and snapshot.parents or M.allRecursiveItems(player)
    for _, parent in ipairs(parents) do
        if M.isParent(parent) and M.parentEquipped(player, parent) then
            local parentMd = parent:getModData()
            for moduleKey in pairs(M.FIXED_POUCH) do
                local moduleId = tonumber(parentMd["MLO_module_" .. moduleKey])
                if moduleId then
                    local ready = M.findById(player,moduleId,snapshot) ~= nil and "ready" or "pending"
                    ids[#ids + 1] = "fixed:" .. moduleKey .. ":" .. tostring(moduleId) .. ":" .. ready
                end
            end
        end
    end
    table.sort(ids)
    return table.concat(ids, ":")
end

local function refreshInventoryContainersIfChanged(player, force, snapshot)
    if not player then return end
    local playerNum = player:getPlayerNum()
    snapshot=snapshot or M.inventorySnapshot(player)
    local signature = activeContainerSignature(player,snapshot)
    if not force and containerSignatures[playerNum] == signature then return end
    containerSignatures[playerNum] = signature
    refreshInventoryContainers(player)
end

-- Upgrades only change which slots the worn item provides. Vanilla owns the
-- menu, timed action, attached-item fields, animation, and network packets.
local function refreshVanillaHotbar(player)
    if not player or type(getPlayerHotbar) ~= "function" then return end
    local hotbar = getPlayerHotbar(player:getPlayerNum())
    if not hotbar then return end
    hotbar.wornItems = nil
    hotbar.needsRefresh = true
    hotbar:refresh()
end

local function resetProjectionForCreate(player)
    if not player then return end
    local playerNum=player:getPlayerNum()
    projectionDirty[playerNum]=true
    projectionRetry[playerNum]=nil
    clothingProjectionSignatures[playerNum]=clothingProjectionSignature(player)
    pendingUpgradeAttachmentHints[playerNum]=nil
    local multiplayer=type(isClient)=="function" and isClient()==true
    projectionReadiness[playerNum]={requested=false,readyTicks=0,serverReady=not multiplayer}
    clearAllPendingRootExitUnmount(player)
    for key,intent in pairs(pendingVanillaMount) do
        if intent.playerNum==playerNum then pendingVanillaMount[key]=nil end
    end
end

local function hasPersistentMountProjection(player,snapshot)
    for _,parent in ipairs(snapshot.parents) do
        if M.isParent(parent) then
            for _,slotId in ipairs(M.SLOT_ORDER) do
                if M.getPersistentMountId(parent,slotId) then return true end
            end
        end
    end
    return false
end

-- An unlocked hook must exist in the vanilla Hotbar before the first item can
-- be attached.  A durable mount cannot be used as the refresh trigger because
-- that relation is created only after vanilla finishes the attach action.
local function mloHotbarLayoutNeedsRefresh(player,hotbar,snapshot,hintsByParent)
    if not player or not hotbar or not hotbar.availableSlot then return false end
    local expected={}
    for _,parent in ipairs(snapshot.parents) do
        if M.isParent(parent) and M.parentEquipped(player,parent) then
            local group=M.groupOf(parent)
            local parentHints=hintsByParent and hintsByParent[tonumber(parent:getID())] or nil
            for _,slotId in ipairs(M.SLOT_ORDER) do
                if M.HOTBAR_TEMPLATE[slotId] and M.slotBelongsToGroup(slotId,group)
                    and (M.slotEnabled(parent,slotId) or (parentHints and parentHints[slotId])) then
                    expected[slotId]=true
                end
            end
        end
    end
    local actual={}
    for _,slot in pairs(hotbar.availableSlot) do
        local slotId=mloSlotIdFromDefinition(slot and slot.def or nil)
        if slotId then actual[slotId]=true end
    end
    for slotId in pairs(expected) do
        if not actual[slotId] then return true end
    end
    for slotId in pairs(actual) do
        if not expected[slotId] then return true end
    end
    return false
end

local function syncPersistentMountProjection(player,force)
    if not player or type(getPlayerHotbar)~="function" or not projectionRestoreReady(player) then return false end
    local playerNum=player:getPlayerNum()
    if not force and not projectionDirty[playerNum] then return true end
    local snapshot=M.inventorySnapshot(player)
    projectionDirty[playerNum]=nil

    -- A real dirty event owns the whole repair pass. Reuse one inventory view
    -- for module presentation, detachable visuals, container discovery and the
    -- Hotbar projection instead of recursively walking the same tree again.
    local hintsByParent=attachmentHintsByParent(player,snapshot)
    M.syncInstalledModules(player,true,snapshot)
    M.syncAttachedItems(player,snapshot,nil,hintsByParent)

    -- Never reproject a relation whose child has already left the character's
    -- root inventory.  This covers vanilla paths outside ISDetachItemHotbar;
    -- the expected item id prevents an old request from clearing a remount.
    local root=player:getInventory()
    for _,parent in ipairs(snapshot.parents) do
        if M.isParent(parent) then
            for _,slotId in ipairs(M.SLOT_ORDER) do
                local mounted=M.getPersistentMountId(parent,slotId)
                if mounted then
                    local item=M.findById(player,mounted,snapshot)
                    local pendingKey=rootExitUnmountKey(player,parent,slotId,mounted)
                    local pending=pendingRootExitUnmount[pendingKey]
                    if pending then
                        -- A fast pickup must not reproject before the server
                        -- confirms the exact-id parent unlink.  Missing or
                        -- unresolved acknowledgements retry in the lightweight
                        -- per-player timer, outside this inventory projection.
                    elseif not item or item:getContainer()~=root then
                        requestPersistentUnmountById(player,parent,slotId,mounted)
                    end
                end
            end
        end
    end

    -- Publish unlocked hooks after the full online/inventory/Hotbar readiness
    -- grace, even before a durable relation exists.  The first attach option
    -- cannot exist until vanilla has rebuilt this layout.  Refresh only when
    -- the exact MLO layout changed, preserving the dev.12 startup guard.
    for _,parent in ipairs(snapshot.parents) do
        if M.isParent(parent) then
            M.ensureAttachmentsProvided(parent,hintsByParent and hintsByParent[tonumber(parent:getID())] or nil)
        end
    end
    local hotbar=getPlayerHotbar(playerNum)
    if not hotbar then return false end
    if mloHotbarLayoutNeedsRefresh(player,hotbar,snapshot,hintsByParent) then
        refreshVanillaHotbar(player)
        hotbar=getPlayerHotbar(playerNum)
        if not hotbar then return false end
    end

    -- First deproject stale MLO fields.  Removing clothing, transferring an
    -- attachment, or an authoritative unmount must not leave a ghost model.
    local attached={}
    for _,item in pairs(hotbar.attachedItems or {}) do attached[#attached+1]=item end
    for _,item in ipairs(attached) do
        local liveSlot=item:getAttachedSlotType()
        if liveSlot and M.HOTBAR_TEMPLATE[liveSlot] then
            local parent,linkedSlot=M.mountedSlotForItem(player,item,snapshot)
            local shouldRemain=parent and linkedSlot==liveSlot and M.parentEquipped(player,parent)
                and item:getContainer()==player:getInventory()
                and not isPendingRootExitItem(player,item,liveSlot,snapshot)
            if not shouldRemain then
                removeMloProjectionItem(hotbar,item)
            end
        end
    end

    -- An empty durable relation now means there is nothing to project, not
    -- that the last stale visual can survive an authoritative unlink.
    if not hasPersistentMountProjection(player,snapshot) then
        refreshInventoryContainersIfChanged(player,false,snapshot)
        return true
    end

    -- Then project each confirmed relation with the original Hotbar method.
    -- doAnim=false is vanilla's own refresh/re-wear path and creates no custom
    -- container/equipment state.
    local projected=true
    for _,parent in ipairs(snapshot.parents) do
        if M.isParent(parent) and M.parentEquipped(player,parent) then
            for _,slotId in ipairs(M.SLOT_ORDER) do
                local mounted=M.getPersistentMountId(parent,slotId)
                local item=mounted and M.findById(player,mounted,snapshot) or nil
                local awaitingUnlink=mounted and pendingRootExitUnmount[
                    rootExitUnmountKey(player,parent,slotId,mounted)]~=nil
                if awaitingUnlink then
                    -- ACK/related state changes own the next attempt. No hot
                    -- retry is needed for this already-known pending relation.
                elseif mounted and (not item or item:getContainer()~=player:getInventory() or not M.isCompatible(slotId,item)) then
                    projected=false
                elseif item then
                    local slotIndex=hotbar:getThisSlotIndex(slotId)
                    local slot=slotIndex and hotbar.availableSlot[slotIndex] or nil
                    local slotDef=slot and slot.def or nil
                    local attachedLocation=slotDef and slotDef.attachments[item:getAttachmentType()] or nil
                    if not slotDef or not attachedLocation then
                        projected=false
                    elseif item:getAttachedSlotType()~=slotId
                        or hotbar.attachedItems[slotIndex]~=item then
                        local occupied=hotbar.attachedItems[slotIndex]
                        if occupied and occupied~=item then
                            removeMloProjectionItem(hotbar,occupied)
                        end
                        if item:getAttachedSlot()~=-1 then
                            removeMloProjectionItem(hotbar,item)
                        end
                        local attached=hotbar:attachItem(item,attachedLocation,slotIndex,slotDef,false)
                        if attached==false then
                            projected=false
                        end
                    end
                end
            end
        end
    end
    if not projected then
        deferFailedProjection(player)
        return false
    end
    projectionRetry[playerNum]=nil
    ISInventoryPage.renderDirty=true
    refreshInventoryContainersIfChanged(player,false,snapshot)
    return true
end

local function unwrap(entry)
    if not entry then return nil end
    if instanceof(entry,"InventoryItem") then return entry end
    if entry.items and entry.items[1] then return entry.items[1] end
    return nil
end

rootExitRelation=function(player,item)
    if not player or not item or not item.getContainer or item:getContainer()~=player:getInventory() then return nil end
    local parent,slotId=M.mountedSlotForItem(player,item)
    local itemId=tonumber(item:getID())
    if parent and slotId and itemId and M.getPersistentMountId(parent,slotId)==itemId then
        return {parent=parent,slotId=slotId,itemId=itemId}
    end
    return nil
end

requestRootExitUnmount=function(player,relation)
    if relation then requestPersistentUnmountById(player,relation.parent,relation.slotId,relation.itemId) end
end

local function addTooltip(option,text)
    option.toolTip = ISWorldObjectContextMenu.addToolTip()
    option.toolTip.description = tostring(text or "")
end

local function requirementLine(available, text)
    return (available and "<RGB:1,1,1> " or "<RGB:1,0,0> ") .. tostring(text)
end

local SOURCE_SET_DISPLAY_TYPE = {
    FANNY = "Base.Bag_FannyPackFront",
    SATCHEL = "Base.Bag_Satchel",
    BULLET_STRAP = "Base.AmmoStrap_Bullets",
    SHELL_STRAP = "Base.AmmoStrap_Shells",
    FIRST_AID = "Base.FirstAidKit",
    TOOLBOX = "Base.Toolbox",
}

local function sourceRequirementName(player, def, source)
    if source then return M.displayName(source) end
    if def.sourceTag then
        if def.sourceTag == "KEY_RING" then return getItemNameFromFullType("Base.KeyRing") end
        return M.text("IGUI_MLO_SourceTag_" .. tostring(def.sourceTag))
    end
    if def.sourceSet then
        local fullType = SOURCE_SET_DISPLAY_TYPE[def.sourceSet]
        if fullType then return getItemNameFromFullType(fullType) end
    end
    if def.sourceTypes then
        local types = {}
        for fullType in pairs(def.sourceTypes) do types[#types + 1] = fullType end
        table.sort(types)
        if types[1] then return getItemNameFromFullType(types[1]) end
    end
    return nil
end

local function describeRequirementState(player, def)
    local lines = {}
    local requiredTailoring = tonumber(def.tailoring) or 0
    if requiredTailoring > 0 then
        local current = tonumber(player:getPerkLevel(Perks.Tailoring)) or 0
        lines[#lines + 1] = requirementLine(current >= requiredTailoring,
            getText("IGUI_perks_Tailoring") .. " " .. current .. "/" .. requiredTailoring)
    end

    local materialTypes = {}
    for fullType in pairs(def.materials or {}) do materialTypes[#materialTypes + 1] = fullType end
    table.sort(materialTypes)
    for _, fullType in ipairs(materialTypes) do
        local required = tonumber(def.materials[fullType]) or 0
        local current = math.min(M.countUnits(player, fullType), required)
        lines[#lines + 1] = requirementLine(current >= required,
            getItemNameFromFullType(fullType) .. " " .. current .. "/" .. required)
    end

    local excludedSources = {}
    for _, requirement in ipairs(M.sourceRequirements(def)) do
        local source = M.getSourceForRequirement(player, requirement, excludedSources)
        local found = source ~= nil
        if source then excludedSources[source] = true end
        lines[#lines + 1] = requirementLine(found,
            tostring(sourceRequirementName(player, requirement, source) or "") .. " " .. (found and "1/1" or "0/1"))
    end

    for _, fullType in ipairs(def.tools or {}) do
        local found = M.findFirst(player, {[fullType] = true}, function(item)
            return not item:isBroken()
        end) ~= nil
        lines[#lines + 1] = requirementLine(found,
            getItemNameFromFullType(fullType) .. " " .. (found and "1/1" or "0/1"))
    end
    return table.concat(lines, " <LINE> ")
end

local function addUpgradeMenu(player,context,parent)
    local group = M.groupOf(parent)
    local order = M.UPGRADE_ORDER[group]
    if not order then return end

    local sub = ISContextMenu:getNew(context)
    local anything=false
    for _,key in ipairs(order) do
        if not M.isInstalled(parent,key) and M.upgradeParentEligible(parent,key) then
            local def=M.UPGRADES[key]
            local label=M.text(def.labelKey)
            local opt=sub:addOption(label,parent,function(target)
                local ok=M.checkUpgrade(player,target,key)
                if not ok then return end
                local duration=M.upgradeDurationTicks(player,def.time)
                local action=MLOUpgradeAction:new(player,target,key,label,duration)
                if target:getContainer()~=player:getInventory() then
                    action.MLO_upgradeRootRebind={
                        itemId=tonumber(target:getID()),fullType=M.fullType(target),
                        waitStartedAt=nil,expired=false,
                    }
                    ISInventoryPaneContextMenu.transferIfNeeded(player,target)
                end
                ISTimedActionQueue.add(action)
            end)
            local ok,reason=M.checkUpgrade(player,parent,key)
            if not ok then
                opt.notAvailable=true
            end
            addTooltip(opt,describeRequirementState(player,def))
            anything=true
        end
    end

    if anything then
        local rootOpt=context:addOption(getText("ContextMenu_Add_Weapon_Upgrade"),parent,nil)
        context:addSubMenu(rootOpt,sub)
    end
end

local function removeMenuOptionAt(menu,index)
    local option=menu.options[index]
    if menu.optionPool and option then table.insert(menu.optionPool,option) end
    table.remove(menu.options,index)
    for i,value in ipairs(menu.options) do value.id=i end
    menu.numOptions=#menu.options+1
    menu:calcHeight()
    menu:setWidth(menu:calcWidth())
end

-- If a hidden fixed-pouch item ever reaches the ordinary item-menu event,
-- fail closed instead of exposing ownership-changing callbacks. The sidebar
-- button path below passes the verified parent to vanilla and does not enter
-- this fallback.
local function clearInstalledModuleMenu(menu)
    while menu and menu.options and #menu.options>0 do
        removeMenuOptionAt(menu,#menu.options)
    end
end

-- A fixed pouch owns its storage space, while its equipped parent owns every
-- item-level command. Resolve that parent from the durable parent-side item ID
-- and let the stock inventory menu build the commands. The selected inventory
-- page remains the pouch, so stock pane commands such as Transfer All continue
-- to operate on the pouch contents.
local function fixedPouchMenuParent(player,item,container,page)
    if not player or not item or not container or not M.isFixedPouchItem(item) then return nil end
    if item:getInventory()~=container then return nil end
    if not page then return nil end
    local discovery=discoverSidebarContainers(page,player)
    if M.findById(player,item:getID(),discovery.snapshot)~=item then return nil end
    return discovery.owners[item]
end

local function closeFixedPouchMenu(playerIndex)
    local context=ISContextMenu.get(playerIndex,getMouseX(),getMouseY())
    clearInstalledModuleMenu(context)
    if context and context.setVisible then context:setVisible(false) end
end

local vanillaBackpackRightMouseDown=ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage.onBackpackRightMouseDown(button,x,y)
    local container=button and button.inventory or nil
    local item=container and container:getContainingItem() or nil
    if not M.isFixedPouchItem(item) then
        return vanillaBackpackRightMouseDown(button,x,y)
    end

    local page=button.parent and button.parent.parent or nil
    local player=page and getSpecificPlayer(page.player) or nil
    local parent=fixedPouchMenuParent(player,item,container,page)
    if not page or not parent or not page.inventoryPane or not page.selectContainer then
        closeFixedPouchMenu(page and page.player or 0)
        return
    end

    if page.inventoryPane.inventory~=container then
        if player and player:getJoypadBind()~=-1 then
            for index,candidate in ipairs(page.backpacks or {}) do
                if candidate==button then
                    page.backpackChoice=index
                    break
                end
            end
        end
        page:selectContainer(button)
    end
    if page.inventoryPane.inventory~=container then
        closeFixedPouchMenu(page.player)
        return
    end

    local context=ISInventoryPaneContextMenu.createMenu(
        page.player,page.onCharacter,{parent},getMouseX(),getMouseY())
    if context and context.numOptions>1 and JoypadState.players[page.player+1] then
        context.origin=page
        context.mouseOver=1
        setJoypadFocus(page.player,context)
    end
end

local function pruneIncompatibleMloHotbarOptions(menu,item)
    for index=#menu.options,1,-1 do
        local option=menu.options[index]
        local child=option.subOption and menu:getSubMenu(option.subOption) or nil
        if child then pruneIncompatibleMloHotbarOptions(child,item) end
        local slotDef=option.onSelect==ISHotbar.attachItem and option.param4 or nil
        local slotId=slotDef and slotDef.type or nil
        local candidate=item or (slotDef and option.param1 or nil)
        if slotId and M.HOTBAR_TEMPLATE[slotId] and candidate
            and not M.isCompatible(slotId,candidate) then
            removeMenuOptionAt(menu,index)
        elseif child and #child.options==0 then
            removeMenuOptionAt(menu,index)
        end
    end
end

-- ISInventoryPaneContextMenu builds the vanilla Attach submenu before it emits
-- OnFillInventoryObjectContextMenu.  Preflight the one missing per-instance
-- AttachmentType at the vanilla entry point, then leave its transfer and
-- ISAttachItemHotbar transaction completely untouched.
local vanillaHotbarDoMenuFromInventory=ISHotbar.doMenuFromInventory
function ISHotbar.doMenuFromInventory(playerNum,item,context)
    local player=getSpecificPlayer(playerNum)
    if player and item and M.detachableAttachmentType(item) then
        local ok=pcall(function() return M.ensureDetachableItemState(item,player) end)
        if not ok then M.logOnce("attach-preflight:"..tostring(item:getID()), "MLO attachment preflight failed") end
    end
    return vanillaHotbarDoMenuFromInventory(playerNum,item,context)
end

-- World placement and vehicle drop are native server-authoritative timed
-- actions. Capture only the durable MLO relation at start, then unlink it from
-- the client after the original action reaches perform(). Cancellation never
-- reaches perform(), so queued or failed drops cannot clear the relation.
local function observeRootExitAction(actionClass)
    local vanillaStart=actionClass.start
    local vanillaPerform=actionClass.perform
    local vanillaStop=actionClass.stop
    function actionClass:start(...)
        self.MLO_rootExitRelation=rootExitRelation(self.character,self.item)
        return vanillaStart(self,...)
    end
    function actionClass:perform(...)
        local relation=self.MLO_rootExitRelation
        local result=vanillaPerform(self,...)
        self.MLO_rootExitRelation=nil
        if relation then requestRootExitUnmount(self.character,relation) end
        return result
    end
    if vanillaStop then
        function actionClass:stop(...)
            self.MLO_rootExitRelation=nil
            return vanillaStop(self,...)
        end
    end
end
observeRootExitAction(ISDropWorldItemAction)
observeRootExitAction(ISDropVehicleItemAction)

local vanillaHotbarDoMenu=ISHotbar.doMenu
function ISHotbar:doMenu(slotIndex)
    local result=vanillaHotbarDoMenu(self,slotIndex)
    local slot=self.availableSlot and self.availableSlot[slotIndex] or nil
    if slot and mloSlotIdFromDefinition(slot.def) then
        local context=getPlayerContextMenu(self.playerNum)
        if context and context.options then
            pruneIncompatibleMloHotbarOptions(context,nil)
            if #context.options==0 then
                local option=context:addOption(getText("ContextMenu_NoWeaponsAvailable"))
                option.notAvailable=true
            end
        end
    end
    return result
end

local function pruneMloRadialSlices(hotbar,slotIndex)
    local slot=hotbar and hotbar.availableSlot and hotbar.availableSlot[slotIndex] or nil
    local slotId=slot and mloSlotIdFromDefinition(slot.def) or nil
    if not slotId then return end
    local radialMenu=getPlayerRadialMenu(hotbar.playerNum)
    if not radialMenu or not radialMenu.slices then return end

    local kept={}
    local changed=false
    for _,slice in ipairs(radialMenu.slices) do
        local command=slice.command
        local candidate=command and command[2]==hotbar and command[4]==slotIndex and command[3] or nil
        if candidate and not M.isCompatible(slotId,candidate) then
            changed=true
        else
            kept[#kept+1]=slice
        end
    end
    if not changed then return end

    radialMenu:clear()
    for _,slice in ipairs(kept) do
        radialMenu:addSlice(slice.text,slice.texture,unpack(slice.command))
    end
end

local vanillaHotbarOnKeyKeepPressed=ISHotbar.onKeyKeepPressed
ISHotbar.onKeyKeepPressed=function(key)
    local result=vanillaHotbarOnKeyKeepPressed(key)
    local hotbar=getPlayerHotbar(0)
    if hotbar then
        local slotIndex=hotbar:getSlotForKey(key)
        if slotIndex and slotIndex~=-1 then pruneMloRadialSlices(hotbar,slotIndex) end
    end
    return result
end

local function pruneMountedHotbarRemove(menu)
    for index=#(menu.options or {}),1,-1 do
        local option=menu.options[index]
        local child=option.subOption and menu:getSubMenu(option.subOption) or nil
        if child then pruneMountedHotbarRemove(child) end
        if option.onSelect==ISHotbar.removeItem or option.onSelect==vanillaHotbarRemoveItem
            or (child and #child.options==0) then
            removeMenuOptionAt(menu,index)
        end
    end
end

local function addPersistentUnmountMenu(player,context,item,parent,slotId)
    pruneMountedHotbarRemove(context)
    local label=M.text("IGUI_MLO_Context_RemoveFromParent",{M.displayName(parent)})
    context:addOption(label,item,function(selected,linkedParent,linkedSlot)
        local hotbar=type(getPlayerHotbar)=="function" and getPlayerHotbar(player:getPlayerNum()) or nil
        local attachedLocation=type(M.resolveAttachedLocation)=="function"
            and M.resolveAttachedLocation(linkedSlot,selected,linkedSlot) or linkedSlot
        if hotbar and M.parentEquipped(player,linkedParent)
            and player:getAttachedItem(attachedLocation)==selected then
            -- The wrapped ISDetachItemHotbar.perform clears the durable link
            -- only after vanilla has completed the interactive detach.
            hotbar:removeItem(selected,true)
            return
        end
        requestPersistentUnmount(player,linkedParent,selected,linkedSlot)
    end,parent,slotId)
end

-- Add validated mounted destinations to the stock menu. The native callback
-- retains transfer queues, permission/capacity checks and multiplayer ownership.
local function addMountedContainerMoveTargets(player,context,items)
    local containers=activeModuleContainers(player,M.inventorySnapshot(player))
    if #containers==0 then return end
    local moveItems=ISInventoryPane.getActualItems(items)
    if #moveItems==0 then return end
    local playerIndex=player:getPlayerNum()
    local option=context:getOptionFromName(getText("ContextMenu_Move_To"))
    local subMenu=option and option.subOption and context:getSubMenu(option.subOption) or nil
    local shown={}
    for _,entry in ipairs(subMenu and subMenu.options or {}) do
        if entry.onSelect==ISInventoryPaneContextMenu.onMoveItemsTo then
            shown[entry.param1]=true
        end
    end
    for _,item in ipairs(containers) do
        local inventory=item:getInventory()
        if not shown[inventory] and ISInventoryPaneContextMenu.canMoveTo(moveItems,item,playerIndex) then
            if not subMenu then
                option=option or context:addOption(getText("ContextMenu_Move_To"))
                subMenu=context:getNew(context)
                context:addSubMenu(option,subMenu)
            end
            local entry=subMenu:addOption(item:getName(),moveItems,
                ISInventoryPaneContextMenu.onMoveItemsTo,inventory,playerIndex)
            entry.notAvailable=not ISInventoryPaneContextMenu.hasRoomForAny(player,item,moveItems)
            shown[inventory]=true
        end
    end
end

local function onFillInventoryObjectContextMenu(playerIndex,context,items)
    local player=getSpecificPlayer(playerIndex)
    if not player then return end
    -- Mixed selections containing a fixed pouch must also fail closed; no
    -- vanilla batch action may move the inseparable child as a side effect.
    for _,entry in ipairs(items) do
        local selected=unwrap(entry)
        if selected and M.isFixedPouchItem(selected) then
            clearInstalledModuleMenu(context)
            return
        end
    end
    addMountedContainerMoveTargets(player,context,items)
    local seen={}
    local upgradeAdded=false
    for _,entry in ipairs(items) do
        local item=unwrap(entry)
        if item and not seen[item] then
            seen[item]=true
            if M.isParent(item) then
                if not upgradeAdded then
                    addUpgradeMenu(player,context,item)
                    upgradeAdded=true
                end
            else
                pruneIncompatibleMloHotbarOptions(context,item)
            end
            local mountedParent,mountedSlot=M.mountedSlotForItem(player,item)
            if mountedParent and mountedSlot then
                addPersistentUnmountMenu(player,context,item,mountedParent,mountedSlot)
            end
        end
    end
end
Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)

local pouchReductionEffectByPlayer = {}
local function onPlayerUpdate(player)
    M.tickMountedRadioPlayback(player)
    local playerNum=player and player:getPlayerNum() or nil
    if playerNum ~= nil then
        local effect = M.pouchReductionEffect()
        if pouchReductionEffectByPlayer[playerNum] ~= effect then
            pouchReductionEffectByPlayer[playerNum] = effect
            projectionDirty[playerNum] = true
        end
        if M.pouchVisualBecameReady(player) then projectionDirty[playerNum] = true end
    end
    tickPendingRootExitUnmounts(player)
    settleStateChangedProjection(player)
    if playerNum~=nil and pendingInventoryMutation[playerNum] then
        pendingInventoryMutation[playerNum]=nil
        -- Reuse an existing relevant mutation boundary, never a stable-frame scan.
        requestComponentReconciliation(player)
        markProjectionDirty(player)
    end
    flushMountedContainerTransferRefresh(player)
    if playerNum~=nil and projectionDirty[playerNum] then
        local retry=projectionRetry[playerNum]
        if retry and (retry.ticks or 0)>0 then
            retry.ticks=retry.ticks-1
        else
            syncPersistentMountProjection(player,false)
        end
    end
end
Events.OnPlayerUpdate.Add(onPlayerUpdate)

local function onCreatePlayer(index,player)
    M.clearMountedRadioPlayback(index)
    pendingMountedContainerTransferRefresh[index]=nil
    pendingInventoryMutation[index]=nil
    pendingContainerTransferTrace[index]=nil
    pendingStateSettles[index]=nil
    pouchReductionEffectByPlayer[index]=nil
    M.clearPouchPlayerState(player)
    M.registerAttachedLocations()
    -- PlayerID is not registered yet. Reset only local projection state here;
    -- saved-item fields are repaired after serverReady and the readiness grace.
    resetProjectionForCreate(player)
    if not isClient() and type(M.reconcileComponents)=="function" then M.reconcileComponents(player) end
    refreshInventoryContainers(player)
end
Events.OnCreatePlayer.Add(onCreatePlayer)

if Events.EveryOneMinute then
    Events.EveryOneMinute.Add(function()
        if isClient() then return end
        local changed = M.takeComponentOptionsChange()
        for index = 0, getNumActivePlayers()-1 do
            local player = getSpecificPlayer(index)
            if player then
                if changed then M.reconcileComponents(player)
                else M.flushComponentPublications(player, false) end
            end
        end
    end)
end

if Events.OnClothingUpdated then
    Events.OnClothingUpdated.Add(function(player)
        if not player then return end
        local playerNum=player:getPlayerNum()
        local signature=clothingProjectionSignature(player)
        if signature~=nil and signature~=clothingProjectionSignatures[playerNum] then
            clothingProjectionSignatures[playerNum]=signature
            queuePersistentMountProjection(player)
        end
    end)
end

local function onServerCommand(module,command,args)
    if module~=M.MODULE or not args then return end
    if command=="mountedTransferPrepared" then
        local action=pendingMountedTransferPrepare[tonumber(args.token)]
        if action and action.character:getOnlineID()==tonumber(args.playerId) then
            local state=action.MLO_transportPrepare
            state.ready=args.ok==true
            state.rejected=args.ok~=true
        end
        return
    end
    local player=getPlayer()
    if not player then return end

    if command=="serverReady" then
        local playerNum=player:getPlayerNum()
        local state=projectionReadiness[playerNum] or {requested=false,readyTicks=0}
        local serverVersion=tostring(args.version or "")
        local serverBuild=tostring(args.build or 0)
        if serverVersion~=M.VERSION or serverBuild~=tostring(M.BUILD or 0) then
            state.serverReady=false
            state.versionMismatch=true
            projectionDirty[playerNum]=nil
            M.logOnce("server-version:"..serverVersion..":"..serverBuild,
                "server/client version mismatch; projection disabled (server="
                    ..serverVersion.." build "..serverBuild..", client="..tostring(M.VERSION)
                    .." build "..tostring(M.BUILD or 0)..")")
        else
            state.requested=true
            state.serverReady=true
            state.versionMismatch=nil
            state.waitTicks=nil
            state.exhausted=nil
            state.exhaustedSignature=nil
            state.readyTicks=0
            projectionDirty[playerNum]=true
        end
        projectionReadiness[playerNum]=state
        return
    end

    if command=="failed" then
        markProjectionDirty(player)
        return
    end

    if command=="componentsChanged" then
        M.clientComponentsChanged(player)
        return
    end

    if command=="rootExitUnmountAck" then
        if args.resolved==true then
            clearPendingRootExitUnmount(player,args.parentId,tostring(args.slotId or ""),tonumber(args.itemId))
            markProjectionDirty(player)
        end
        return
    end

    if command=="stateChanged" then
        M.clientUpgradeCompleted(player,args.itemId,args.upgradeKey)
        return
    end

end
Events.OnServerCommand.Add(onServerCommand)

print("[MercenaryLoadout] client loaded "..M.VERSION.." build "..tostring(M.BUILD or 0))
