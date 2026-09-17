-- Identity-preserving native sibling transport. This is a preflight adapter,
-- not an atomic replacement for Build 42's native transaction implementation.
require "mercenaryloadout/mlo_shared"
local M = MercenaryLoadout
local T = M.PocketTransport or {}
M.PocketTransport = T
T.MAX_VISITED = 4096

local function inner(item)
    return item and item:IsInventoryContainer() and item:getInventory() or nil
end
local function linkedParent(item)
    if not M.isParent(item) then return false end
    local md = item:getModData()
    for key in pairs(M.FIXED_POUCH) do
        if md["MLO_module_" .. key] ~= nil then return true end
    end
    return false
end
local function linkedChild(item)
    return M.isFixedPouchItem(item) and not M.isDetachedPouch(item)
end
local function walk(container, visit, seen, count)
    if seen[container] then return nil, "container-cycle" end
    seen[container] = true
    local values = container:getItems()
    for i = 0, values:size() - 1 do
        local item = values:get(i)
        count.n = count.n + 1
        if count.n > T.MAX_VISITED then return nil, "source-too-large" end
        if not item or item:getContainer() ~= container then return nil, "stale-source" end
        local ok, err = visit(item, container)
        if not ok then return nil, err end
        local child = inner(item)
        if child then
            ok, err = walk(child, visit, seen, count)
            if not ok then return nil, err end
        end
    end
    seen[container] = nil
    return true
end

-- No mutation or inventory creation is allowed in this planner. Parent IDs are
-- authoritative; absent replicated child indexes are tolerated, conflicts not.
function T.plan(items, source, destination, character)
    if not source or type(items) ~= "table" then return nil, "invalid-source" end
    local plan = {items={}, members={}, source=source,
        destination=destination, character=character, grouped=false, weight=0}
    local selected, carried = {}, {}
    local function mark(item)
        if carried[item] then return true end
        carried[item] = true
        if linkedParent(item) or linkedChild(item) then plan.grouped = true end
        return true
    end
    for _, item in ipairs(items) do
        if not selected[item] then
            selected[item] = true
            plan.items[#plan.items+1] = item
            mark(item)
        end
    end
    -- Relevance discovery cannot enforce MLO's validation budget: an ordinary
    -- bag with many unrelated items must still reach the unchanged native path.
    -- Visit only selected subtrees, iteratively, without scanning world state.
    local pending, inspected, index = {}, {}, 1
    for _, item in ipairs(plan.items) do
        local child = inner(item)
        if child then pending[#pending+1] = child end
    end
    while index <= #pending do
        local container = pending[index]
        index = index + 1
        if not inspected[container] then
            inspected[container] = true
            local values = container:getItems()
            for i=0, values:size()-1 do
                local item = values:get(i)
                if item then
                    mark(item)
                    local child = inner(item)
                    if child then pending[#pending+1] = child end
                end
            end
        end
    end
    if not plan.grouped then return plan end
    for _, item in ipairs(plan.items) do
        if item:getContainer() ~= source then return nil, "stale-source" end
    end
    local byId, owners, all = {}, {}, {}
    local ok, err = walk(source, function(item, container)
        local id = tonumber(item:getID())
        if not id or byId[id] then return nil, "duplicate-or-invalid-id" end
        byId[id], owners[item] = item, container
        all[#all+1] = item
        return true
    end, {}, {n=0})
    if not ok then return nil, err end
    local authority = {}
    for _, parent in ipairs(all) do
        if M.isParent(parent) then
            for key in pairs(M.FIXED_POUCH) do
                local id = tonumber(parent:getModData()["MLO_module_" .. key])
                if id then
                    if authority[id] ~= nil then authority[id] = false
                    else authority[id] = parent end
                end
            end
        end
    end
    local claimed, parentOf, processed = {}, {}, {}
    -- Inspect only transported parents. An enclosing bag's subtree is carried
    -- natively; its internal pockets are not separate top-level batch entries.
    local progressed = true
    while progressed do
      progressed = false
      for _, parent in ipairs(all) do
        if carried[parent] and linkedParent(parent) and not processed[parent] then
            processed[parent], progressed = true, true
            for key, definition in pairs(M.FIXED_POUCH) do
                local rawId = parent:getModData()["MLO_module_" .. key]
                if rawId ~= nil then
                    local id = tonumber(rawId)
                    local child = id and byId[id]
                    if not child then return nil, "missing-pocket:" .. tostring(rawId) end
                    if child == parent or not inner(child) or child:getFullType() ~= definition.fullType then
                        return nil, "wrong-pocket-type:" .. tostring(rawId)
                    end
                    local md = child:getModData()
                    if (md.MLO_parentId ~= nil and tonumber(md.MLO_parentId) ~= tonumber(parent:getID()))
                        or (md.MLO_moduleKey ~= nil and md.MLO_moduleKey ~= key)
                        or M.isDetachedPouch(child) or claimed[child] or authority[id] ~= parent then
                        return nil, "conflicting-pocket:" .. tostring(rawId)
                    end
                    if owners[child] ~= owners[parent] then return nil, "split-owner:" .. tostring(rawId) end
                    claimed[child], parentOf[child], carried[child] = true, parent, true
                    local nestedOk, nestedErr = walk(inner(child), mark, {}, {n=0})
                    if not nestedOk then return nil, nestedErr end
                    if owners[parent] == source and not selected[child] then
                        selected[child] = true
                        plan.items[#plan.items+1] = child
                    end
                end
            end
        end
      end
    end
    for item in pairs(carried) do
        if linkedChild(item) and not parentOf[item] then return nil, "unowned-pocket:" .. tostring(item:getID()) end
        plan.members[#plan.members+1] = item
    end
    for _, item in ipairs(plan.items) do
        if destination and destination:isInside(item) then return nil, "container-cycle" end
        plan.weight = plan.weight + item:getUnequippedWeight()
    end
    return plan
end

function T.preflight(plan, square)
    if not plan or not plan.grouped then return true end
    local dst, player = plan.destination, plan.character
    if not dst then return true end -- Trade offers are checked by native UI.
    for _, item in ipairs(plan.items) do
        if item:getContainer() ~= plan.source then return nil, "stale-source" end
        if not plan.source:isRemoveItemAllowed(item) or not dst:isItemAllowed(item) then
            return nil, "item-not-allowed"
        end
    end
    if dst:getType() == "floor" then
        square = square or player:getCurrentSquare()
        if not square then return nil, "missing-floor" end
        -- Native MP batching chooses the current square per member. Requiring
        -- the whole group to fit here prevents members spilling across squares.
        local weight = square:getTotalWeightOfItemsOnFloor()
        for _, item in ipairs(plan.items) do
            local obj = item:getWorldItem()
            if obj and obj:getSquare() == square then weight = weight - item:getUnequippedWeight() end
        end
        if weight + plan.weight > dst:getEffectiveCapacity(player) then return nil, "group-floor-full" end
        plan.square = square
    elseif not dst:hasRoomFor(player, plan.weight) then
        return nil, "group-container-full"
    end
    return true
end

function T.reject(character, reason)
    T.lastError = tostring(reason)
    if M.logOnce then M.logOnce("pocket-transport:" .. T.lastError, "Pocket transfer rejected/interrupted; no compensating item created: " .. T.lastError) end
    if T.onFailure then T.onFailure(character, T.lastError) end
end

local function preparePlacedBoxes(character, items)
    local boxes, reason = M.collectOwnedTransportBoxes(character, items)
    if not boxes then return nil, reason end
    if #boxes == 0 then return true end
    local tx = M.newTransaction(character)
    for _, box in ipairs(boxes) do
        local ok, _, err = M.ensureOwnedContainerTransport(character, box.item, tx)
        if not ok then
            M.rollbackTransaction(tx)
            return nil, err
        end
    end
    -- Pointer normalization only: no item movement or publication is queued.
    return true
end

function T.installShared()
    if T.sharedInstalled then return end
    require "TimedActions/ISTransferAction"
    require "TimedActions/ISDropWorldItemAction"
    require "TimedActions/ISDropVehicleItemAction"
    local transfer = ISTransferAction.transferItem
    ISTransferAction.transferItem = function(self, character, item, src, dst, square)
        if isServer() or isClient() then
            -- MP native player-to-floor processes one entry at a time. Do not
            -- expand here: the client already submitted the native group list.
            return transfer(self, character, item, src, dst, square)
        end
        local plan, err = T.plan({item}, src, dst, character)
        if not plan then T.reject(character, err); return item end
        if not plan.grouped then return transfer(self, character, item, src, dst, square) end
        local ok
        ok, err = T.preflight(plan, square)
        if not ok then T.reject(character, err); return item end
        local result
        for _, member in ipairs(plan.items) do
            local ran,moved = pcall(transfer,self,character,member,src,dst,plan.square or square)
            if not ran then
                T.reject(character,"native-group-interrupted")
                error(moved,0)
            end
            local arrived=member:getContainer()==dst
            if dst:getType()=="floor" then
                local world=member:getWorldItem()
                arrived=world~=nil and world:getSquare()==(plan.square or square)
            end
            if moved==false or not arrived then
                -- Never advance the remaining hidden companions after a native
                -- rejection. Do not clone items or pretend published moves rolled back.
                T.reject(character,"native-group-interrupted")
                return result or item
            end
            if member == item then result = moved end
        end
        return result
    end
    local complete = ISDropWorldItemAction.complete
    ISDropWorldItemAction.complete = function(self)
        local source = self.character:getInventory()
        local plan, err = T.plan({self.item}, source, nil, self.character)
        if not plan then T.reject(self.character, err); return false end
        if not plan.grouped then
            local ok, reason = preparePlacedBoxes(self.character, {self.item})
            if not ok then T.reject(self.character, reason); return false end
            return complete(self)
        end
        local weight = 0
        for _, item in ipairs(plan.items) do weight = weight + item:getUnequippedWeight() end
        if not self.sq or self.sq:getTotalWeightOfItemsOnFloor() + weight > 50 then
            T.reject(self.character, "group-floor-full"); return false
        end
        local ok, reason = preparePlacedBoxes(self.character, plan.items)
        if not ok then T.reject(self.character, reason); return false end
        -- The placement cursor queued Unequip only for the visible parent.
        -- Added hidden companions may still occupy their native worn slots.
        -- Clear those exact references; native completion removes hands/root.
        for _, member in ipairs(plan.items) do
            if linkedChild(member) then
                self.character:removeAttachedItem(member)
                self.character:removeWornItem(member, false)
            end
        end
        local parentItem, result = self.item
        for _, member in ipairs(plan.items) do
            self.item = member
            local ran, value = pcall(complete, self)
            if not ran then
                self.item = parentItem
                -- Native placement has already mutated state; do not replay or
                -- invent a compensating item on an unproven rollback path.
                T.reject(self.character,"native-group-interrupted")
                error(value)
            end
            if value==false then
                self.item=parentItem
                T.reject(self.character,"native-group-interrupted")
                return false
            end
            if member == parentItem then result = value end
        end
        self.item = parentItem
        return result
    end
    local vehicleComplete = ISDropVehicleItemAction.complete
    ISDropVehicleItemAction.complete = function(self)
        local ok, reason = preparePlacedBoxes(self.character, {self.item})
        if not ok then T.reject(self.character, reason); return false end
        return vehicleComplete(self)
    end
    T.sharedInstalled = true
end
return T
