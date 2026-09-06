require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISUnequipAction"
require "TimedActions/ISClothingExtraAction"
require "mercenaryloadout/mlo_shared"

local M=MercenaryLoadout

MLOUpgradeAction=ISBaseTimedAction:derive("MLOUpgradeAction")

function MLOUpgradeAction:isValid()
    if not self.character or self.character:isDead() or not self.target then return false end
    return self.character:getInventory():containsRecursive(self.target)
end

function MLOUpgradeAction:start()
    self.target:setJobType(self.label)
    self.target:setJobDelta(0.0)
    if not isServer() then
        self:setActionAnim("SewingCloth")
        self.sound=self.character:playSound("Sewing")
    end
end

function MLOUpgradeAction:update()
    self.target:setJobDelta(self:getJobDelta())
end

local function stopUpgradeSound(action)
    if action.sound and action.character:getEmitter():isPlaying(action.sound) then
        action.character:stopOrTriggerSound(action.sound)
    end
end

function MLOUpgradeAction:stop()
    stopUpgradeSound(self)
    self.target:setJobDelta(0.0)
    self.target:setJobType("")
    ISBaseTimedAction.stop(self)
end

function MLOUpgradeAction:perform()
    stopUpgradeSound(self)
    if not isServer() then self.character:resetModel() end
    self.target:setJobDelta(0.0)
    self.target:setJobType("")
    -- In MP this perform follows native server-complete/Done, not merely the
    -- local progress bar. Reuse the client-only presentation convergence hook;
    -- never apply the upgrade or write persistent fields here.
    if type(isClient)=="function" and isClient()==true
        and type(M.clientUpgradeCompleted)=="function" then
        local ok=pcall(function()
            M.clientUpgradeCompleted(self.character,self.target:getID(),self.upgradeKey)
        end)
        if not ok then
            M.logOnce("upgrade-ui-complete","upgrade UI callback failed; native action completion preserved")
        end
    end
    ISBaseTimedAction.perform(self)
end

-- Build 42.20 reconstructs shared timed actions on the server and invokes
-- complete() there. Keep the upgrade transaction inside that native
-- authoritative boundary instead of maintaining a second command/token
-- protocol beside NetTimedAction.
function MLOUpgradeAction:complete()
    local applied,reason=M.applyUpgrade(self.character,self.target,self.upgradeKey)
    if isServer() then
        if applied then
            local def=M.UPGRADES[self.upgradeKey]
            local payload={itemId=self.target:getID(),version=M.VERSION,upgradeKey=self.upgradeKey}
            if def then
                M.writeMessagePayload(payload,
                    M.message("IGUI_MLO_Status_UpgradeComplete",M.textArgument(def.labelKey)))
            end
            sendServerCommand(self.character,M.MODULE,"stateChanged",payload)
        else
            sendServerCommand(self.character,M.MODULE,"failed",M.writeMessagePayload({},reason))
        end
    end
    return applied==true
end

function MLOUpgradeAction:adjustMaxTime(maxTime)
    return maxTime
end

-- Build 42 NetTimedAction serializes action values by the formal parameter
-- names of new(). Keep this name identical to the stored action field.
function MLOUpgradeAction:new(character,target,upgradeKey,label,maxTime)
    local o=ISBaseTimedAction.new(self,character)
    o.character=character
    o.target=target
    o.upgradeKey=upgradeKey
    o.label=label
    o.maxTime=maxTime or 600
    o.stopOnWalk=true
    o.stopOnRun=true
    o.forceProgressBar=true
    return o
end

-- Preserve Build 42's complete unequip transaction verbatim. Once vanilla
-- confirms that an MLO parent is no longer equipped, the authoritative side
-- clears only MLO's durable child links in one transaction; the original item
-- instances stay in the character inventory and vanilla owns every visual/UI
-- refresh through OnClothingUpdated.
local vanillaUnequipComplete=ISUnequipAction.complete
function ISUnequipAction:complete(...)
    local result=vanillaUnequipComplete(self,...)
    local player=self.character
    local item=self.item
    local authoritative=type(isClient)~="function" or isClient()~=true
    if result~=false and authoritative and player and item and M.isParent(item)
        and not M.parentEquipped(player,item) then
        local cleared,count=M.unmountParent(player,item)
        if not cleared then
            M.logOnce("unequip-unmount:"..tostring(item:getID()),
                "failed to clear mounted items after vanilla unequip")
        elseif count>0 and type(isServer)=="function" and isServer()==true then
            sendServerCommand(player,M.MODULE,"stateChanged",{
                itemId=item:getID(),version=M.VERSION,
            })
        end
    end
    return result
end

-- Extend only the authoritative native side-change boundary. The original
-- action still owns cloning clothing properties, removal, addition and wear.
local vanillaClothingExtraComplete = ISClothingExtraAction.complete
function ISClothingExtraAction:complete(...)
    local source, target = M.armorSideSwapEquipment(self.item, self.extra)
    if not source or (type(isClient)=="function" and isClient()==true) then
        return vanillaClothingExtraComplete(self, ...)
    end
    local oldItem, player = self.item, self.character
    local function report(reason)
        M.logOnce("armor-side-swap:" .. tostring(oldItem:getID()) .. ":" .. tostring(reason),
            "armor side swap: " .. tostring(reason))
    end
    local plan, reason = M.validateArmorSideSwap(player, oldItem, source, target)
    if not plan then report(reason) return false end

    -- Preflight before native removes the old clothing. No contents are copied.
    local created, replacement = pcall(self.createItem, self, oldItem, self.extra)
    if not created or not replacement then report("native-precreate-failed") return false end
    local tx = M.newTransaction(player)
    local prepared, accepted, prepareReason = pcall(M.prepareArmorSideSwap,
        tx, player, oldItem, replacement, plan)
    if not prepared or not accepted then
        if not M.rollbackTransaction(tx) then report("prepare-rollback-failed") end
        report(prepareReason or "replacement-prepare-failed")
        return false
    end

    local ownFactory = rawget(self, "createItem")
    self.createItem = function(_, item, extra)
        if item ~= oldItem or extra ~= self.extra then error("unexpected native armor factory input") end
        return replacement
    end
    local completed, result = pcall(vanillaClothingExtraComplete, self, ...)
    self.createItem = ownFactory

    local inventory = player:getInventory()
    local adopted = replacement:getContainer() == inventory
        and inventory:getItems():contains(replacement)
    if adopted and inventory:getItems():contains(oldItem) then
        -- A silent native Remove rejection is not a successful replacement.
        -- Revert only the newly created object; never remove the old survivor.
        pcall(function() inventory:Remove(replacement) end)
        if inventory:getItems():contains(replacement) then
            self.mloFailedSideSwap = {oldItem=oldItem,replacement=replacement}
            report("duplicate-parent-cleanup-failed")
            return false
        end
        adopted = false
    end
    if not adopted then
        -- Never publish a child link to an unadopted replacement. In the native
        -- Remove/Add gap, recover the SAME old item, not a copy/new identity.
        local rolledBack = M.rollbackTransaction(tx)
        if not rolledBack then report("relation-rollback-failed") end
        -- A silent native Add rejection can still have emitted Add/wear/event.
        -- Remove only the exact unadopted object from that partial projection.
        local cleared = pcall(function()
            if player:getWornItem(replacement:getBodyLocation()) == replacement then
                player:removeWornItem(replacement, false)
                sendClothing(player, replacement:getBodyLocation(), nil)
            end
            sendRemoveItemFromContainer(inventory, replacement)
        end)
        if not cleared then report("unadopted-replacement-cleanup-sync-failed") end
        if oldItem:getContainer() == nil and replacement:getContainer() == nil then
            pcall(function() inventory:AddItem(oldItem) end)
        end
        local restored = oldItem:getContainer() == inventory
            and inventory:getItems():contains(oldItem)
        if restored then
            local sent = pcall(function() sendAddItemToContainer(inventory, oldItem) end)
            report(sent and "old-parent-restored-to-inventory" or "old-parent-restored-sync-failed")
        else
            -- Keep exact recovery references on this failed action. Do not
            -- misreport success or discard them by finalizing its transaction.
            self.mloFailedSideSwap = {oldItem=oldItem,replacement=replacement}
            report("old-parent-restore-failed")
        end
        report("native-replacement-not-adopted")
    else
        -- Once vanilla adopted the replacement, the new relationship is the
        -- authoritative state. Publication failure is NOT a second failed swap.
        if not M.finishArmorSideSwap(tx) then report("committed-child-sync-failed") end
    end

    if not completed then
        report(adopted and "native-partial-new-parent-in-inventory" or "native-complete-failed")
        error(result, 0)
    end
    if result == false or not adopted then return false end
    if player:getWornItem(replacement:getBodyLocation()) ~= replacement then
        report("native-partial-new-parent-not-worn")
        return false
    end
    if plan.staleParentId then report("legacy-stale-parent-recovered") end
    return result
end

print("[MercenaryLoadout] shared actions loaded "..M.VERSION.." build "..tostring(M.BUILD or 0))
