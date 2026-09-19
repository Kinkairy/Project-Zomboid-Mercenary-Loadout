require "mercenaryloadout/mlo_pocket_transport"
local T = MercenaryLoadout.PocketTransport

function T.installClient()
    if T.clientInstalled then return end
    require "TimedActions/ISInventoryTransferAction"
    require "ISUI/ISTradingUI"
    local nativeCreate = createItemTransaction
    local rejected = setmetatable({}, {__mode="k"})
    createItemTransaction = function(character, items, source, destination)
        if not T.needsPlan(items) then
            return nativeCreate(character, items, source, destination)
        end
        local plan, err = T.plan(items, source, destination, character)
        if plan then
            local ok
            ok, err = T.preflight(plan)
            if not ok then plan = nil end
        end
        if not plan then
            rejected[character] = {source=source, destination=destination}
            T.reject(character, err)
            return 0
        end
        -- One native transaction, containing original object references only.
        local id = nativeCreate(character, plan.grouped and plan.items or items, source, destination)
        if plan.grouped and id and id ~= 0 and T.onNativeTransaction then
            T.onNativeTransaction(character, id, plan)
        end
        return id
    end
    local function stopRejected(action)
        local failure = rejected[action.character]
        if action.transactionId == 0 and failure and failure.source == action.srcContainer
            and failure.destination == action.destContainer then
            rejected[action.character] = nil
            action:forceStop()
        end
    end
    local start, update = ISInventoryTransferAction.start, ISInventoryTransferAction.update
    ISInventoryTransferAction.start = function(self)
        local result = start(self)
        stopRejected(self)
        return result
    end
    ISInventoryTransferAction.update = function(self)
        local result = update(self)
        stopRejected(self)
        return result
    end

    local addOffer, removeOffer = ISTradingUI.addItemToYourOffer, ISTradingUI.removeItem
    local function offered(ui, item)
        for index, entry in ipairs(ui.yourOfferDatas.items) do
            if entry.item == item then return index end
        end
    end
    local function tradePlan(ui, item)
        local plan, err = T.plan({item}, ui.player:getInventory(), nil, ui.player)
        if not plan then T.reject(ui.player, err) end
        return plan
    end
    ISTradingUI.addItemToYourOffer = function(self, item)
        local plan = tradePlan(self, item)
        if not plan then return end
        if not plan.grouped then return addOffer(self, item) end
        local pending = {}
        for _, member in ipairs(plan.items) do
            if not offered(self, member) then pending[#pending+1] = member end
            if luautils.haveToBeTransfered(self.player, member)
                or self.player:isEquipped(member) or self.player:isEquippedClothing(member)
                or member:isFavorite() then
                T.reject(self.player, "trade-member-ineligible"); return
            end
        end
        if #self.yourOfferDatas.items + #pending > ISTradingUI.MaxItems then
            T.reject(self.player, "trade-group-limit"); return
        end
        -- Native offer packets carry IDs; native TradingManager transfers the
        -- actual server items, then saves both players on successful finalize.
        for _, member in ipairs(pending) do addOffer(self, member) end
        for _, member in ipairs(pending) do
            if not offered(self, member) then
                for _, rollback in ipairs(pending) do
                    local index = offered(self, rollback)
                    if index then removeOffer(self, {item=rollback,index=index}) end
                end
                T.reject(self.player, "trade-offer-incomplete"); return
            end
        end
    end
    ISTradingUI.removeItem = function(self, entry)
        local item = entry.item
        -- A companion is an implementation detail; removing its offered row
        -- withdraws the whole offered group instead of leaving a split offer.
        if MercenaryLoadout.isFixedPouchItem(item) then
            local owner
            for _, candidate in ipairs(self.yourOfferDatas.items) do
                if MercenaryLoadout.isParent(candidate.item) then
                    for key in pairs(MercenaryLoadout.FIXED_POUCH) do
                        if tonumber(candidate.item:getModData()["MLO_module_" .. key]) == tonumber(item:getID()) then
                            if owner and owner ~= candidate.item then
                                T.reject(self.player, "conflicting-offer-owner"); return
                            end
                            owner = candidate.item
                        end
                    end
                end
            end
            item = owner or item
        end
        local plan = tradePlan(self, item)
        if not plan then return end
        if not plan.grouped then return removeOffer(self, entry) end
        for _, member in ipairs(plan.items) do
            local index = offered(self, member)
            if index then removeOffer(self, {item=member,index=index}) end
        end
    end
    T.clientInstalled = true
end
return T
