-- Compatibility for an original ground parent whose fixed pouches remained
-- in a nearby corpse. Work only on existing, mutually linked objects.
require "mercenaryloadout/mlo_pocket_transport"
local M=MercenaryLoadout
if M.SplitPocketPickup then return M.SplitPocketPickup end
local T=M.PocketTransport
local R={}
M.SplitPocketPickup=R
local lastRequest=setmetatable({}, {__mode="k"})
local function integer(n)
    return type(n)=="number" and n==n and math.abs(n)<2147483648 and n%1==0
end
local function accessible(player,square)
    local current=player:getCurrentSquare()
    if not current or not square or current:getZ()~=square:getZ()
        or math.abs(current:getX()-square:getX())>1
        or math.abs(current:getY()-square:getY())>1 then return false end
    if current~=square and (current:isBlockedTo(square) or current:isWindowTo(square)) then return false end
    return SafeHouse.isSafehouseAllowLoot(square,player)
end
-- Historical splits can follow a reanimated owner before it becomes a corpse.
-- This is a bounded repair of exact linked objects, not ordinary corpse looting.
-- Walk loaded, loot-permitted adjacent squares; never cross walls/windows or
-- load remote chunks. The player must still be beside the original ground bag.
R.MAX_REPAIR_STEPS=8
local function repairSquares(player,anchor)
    local found={[anchor]=true}
    local queue={{square=anchor,steps=0}}
    local head=1
    while head<=#queue do
        local entry=queue[head];head=head+1
        if entry.steps<R.MAX_REPAIR_STEPS then
            local from=entry.square
            for dy=-1,1 do for dx=-1,1 do
                if dx~=0 or dy~=0 then
                    local to=getCell():getGridSquare(from:getX()+dx,from:getY()+dy,anchor:getZ())
                    if to and not found[to] and SafeHouse.isSafehouseAllowLoot(to,player)
                        and not from:isBlockedTo(to) and not from:isWindowTo(to) then
                        found[to]=true
                        queue[#queue+1]={square=to,steps=entry.steps+1}
                    end
                end
            end end
        end
    end
    return found,queue
end
local function direct(container,item)
    return item:getContainer()==container and container:getItemWithID(item:getID())==item
end
function R.plan(player,args)
    if not player or player:isDead() or type(args)~="table"
        or not integer(args.parentId) or not integer(args.x)
        or not integer(args.y) or not integer(args.z) then return nil,"invalid-request" end
    local square=getCell():getGridSquare(args.x,args.y,args.z)
    if not accessible(player,square) then return nil,"out-of-reach" end
    local index,roots,owners,bodies={}, {}, {}, {}
    local count=0
    local function add(item,owner)
        count=count+1
        if count>T.MAX_VISITED then return false end
        local id=tonumber(item:getID())
        if not integer(id) then return false end
        if index[id]~=nil then index[id]=false else index[id]=item end
        roots[#roots+1]=item;owners[item]=owner
        return true
    end
    -- Same-square ground items and corpses in a bounded walkable repair area.
    -- Living players/zombies and remote/unloaded squares are never sources.
    local world=square:getWorldObjects()
    for i=0,world:size()-1 do
        local object=world:get(i)
        local item=object:getItem()
        if item and item:getWorldItem()==object and object:getSquare()==square then
            if not add(item,{world=object}) then return nil,"lookup-limit" end
        end
    end
    local _,area=repairSquares(player,square)
    for _,entry in ipairs(area) do
        local nearby=entry.square
        do
            local corpses=nearby:getDeadBodys()
            for i=0,corpses:size()-1 do
                local body=corpses:get(i)
                if body:getSquare()==nearby and body:getStaticMovingObjectIndex()>=0 then
                    local container=body:getContainer()
                    if container then
                        bodies[#bodies+1]=body
                        local values=container:getItems()
                        for n=0,values:size()-1 do
                            local item=values:get(n)
                            if not direct(container,item) then return nil,"stale-source" end
                            if not add(item,{container=container,body=body}) then return nil,"lookup-limit" end
                        end
                    end
                end
            end
        end
    end
    local parent=index[args.parentId]
    if not parent or not M.isParent(parent) or not owners[parent].world then return nil,"missing-parent" end
    local plan={parent=parent,world=owners[parent].world,square=square,player=player,entries={},links={}}
    local wanted,group={}, {parent}
    for key,definition in pairs(M.FIXED_POUCH) do
        local raw=parent:getModData()["MLO_module_"..key]
        if raw~=nil then
            local id=tonumber(raw)
            if not integer(id) or wanted[id] then return nil,"conflicting-pocket" end
            wanted[id]=key;plan.links[key]=id
            local item=index[id]
            if item==nil then return nil,"missing-pocket:"..id end
            if item==false then return nil,"duplicate-pocket:"..id end
            if item==parent or not item:IsInventoryContainer()
                or item:getFullType()~=definition.fullType or M.isDetachedPouch(item) then
                return nil,"invalid-pocket:"..id
            end
            local md=item:getModData()
            if tonumber(md.MLO_parentId)~=args.parentId or md.MLO_moduleKey~=key then return nil,"conflicting-pocket" end
            local owner=owners[item]
            group[#group+1]=item
            if owner.container then
                if not owner.container:isRemoveItemAllowed(item) then return nil,"item-not-allowed" end
                plan.entries[#plan.entries+1]={item=item,source=owner.container,body=owner.body,key=key}
            end
        end
    end
    if #group==1 then return nil,"no-fixed-pockets" end
    for _,other in ipairs(roots) do
        if other~=parent and M.isParent(other) then
            for key in pairs(M.FIXED_POUCH) do
                if wanted[tonumber(other:getModData()["MLO_module_"..key])] then return nil,"conflicting-parent" end
            end
        end
    end
    -- Validate the carried subtrees, including a belt inside a backpack pouch.
    local seen,visited={},0
    local function contents(item)
        if not item:IsInventoryContainer() then return true end
        local container=item:getInventory()
        if seen[container] then return false end
        seen[container]=true
        local items,values={},container:getItems()
        for i=0,values:size()-1 do
            local child=values:get(i)
            visited=visited+1
            if visited>T.MAX_VISITED or not direct(container,child) then return false end
            local id=tonumber(child:getID())
            if not integer(id) or index[id]~=nil then return false end
            index[id]=child;items[#items+1]=child
            if not contents(child) then return false end
        end
        local nested=T.plan(items,container,nil,player)
        return nested~=nil
    end
    for _,item in ipairs(group) do if not contents(item) then return nil,"invalid-nested-group" end end
    local weight=square:getTotalWeightOfItemsOnFloor()
    for _,entry in ipairs(plan.entries) do
        local w=entry.item:getUnequippedWeight()
        if type(w)~="number" or w~=w or w<0 then return nil,"invalid-weight" end
        weight=weight+w
    end
    if weight>50 then return nil,"group-floor-full" end
    return plan
end
local function captureList(list)
    local out={}
    for i=0,list:size()-1 do
        local entry=list:get(i)
        out[#out+1]={location=entry:getLocation(),item=entry:getItem()}
    end
    return out
end
local function restoreList(list,values)
    list:clear()
    for _,entry in ipairs(values) do list:setItem(entry.location,entry.item) end
end
function R.apply(plan)
    if isClient() then return false,"server-only" end
    if plan.used then return false,"stale-plan" end
    plan.used=true
    local parent,world,square=plan.parent,plan.world,plan.square
    if plan.player:isDead() or not accessible(plan.player,square)
        or parent:getWorldItem()~=world or world:getSquare()~=square then return false,"stale-parent" end
    for key,id in pairs(plan.links) do
        if tonumber(parent:getModData()["MLO_module_"..key])~=id then return false,"stale-links" end
    end
    local reachable=repairSquares(plan.player,square)
    local snapshots={}
    for _,entry in ipairs(plan.entries) do
        if not direct(entry.source,entry.item) or entry.body:getContainer()~=entry.source
            or entry.body:getStaticMovingObjectIndex()<0
            or not reachable[entry.body:getSquare()] then return false,"stale-source" end
        if not snapshots[entry.body] then
            snapshots[entry.body]={worn=captureList(entry.body:getWornItems()),
                attached=captureList(entry.body:getAttachedItems()),
                primary=entry.body:getPrimaryHandItem(),secondary=entry.body:getSecondaryHandItem()}
        end
    end
    local touched={}
    local ran,reason=pcall(function()
        for _,entry in ipairs(plan.entries) do
            touched[#touched+1]=entry
            entry.source:Remove(entry.item)
            if entry.item:getContainer()~=nil or entry.source:getItemWithID(entry.item:getID()) then error("remove-failed") end
            -- Suppress publication until every original object has moved.
            square:AddWorldInventoryItem(entry.item,0.5,0.5,square:getApparentZ(0.5,0.5)-square:getZ(),false)
            local object=entry.item:getWorldItem()
            if not object or object:getSquare()~=square then error("world-add-failed") end
            entry.world=object
        end
    end)
    if not ran then
        local restored=true
        for n=#touched,1,-1 do
            local entry=touched[n]
            local ok=pcall(function()
                local object=entry.item:getWorldItem()
                if object then
                    object:removeFromWorld();object:removeFromSquare();entry.item:setWorldItem(nil)
                end
                if not direct(entry.source,entry.item) then entry.source:AddItem(entry.item) end
                assert(direct(entry.source,entry.item))
            end)
            restored=restored and ok
        end
        for body,snapshot in pairs(snapshots) do
            local ok=pcall(function()
                restoreList(body:getWornItems(),snapshot.worn)
                restoreList(body:getAttachedItems(),snapshot.attached)
                body:setPrimaryHandItem(snapshot.primary);body:setSecondaryHandItem(snapshot.secondary)
            end)
            restored=restored and ok
        end
        return false,restored and "move-aborted" or "rollback-failed"
    end
    -- Native remove/add packets carry the existing IDs and full contents.
    -- After publication starts, never roll back or replay unknown sends.
    local published=true
    for _,entry in ipairs(plan.entries) do
        local ok=pcall(sendRemoveItemFromContainer,entry.source,entry.item)
        published=published and ok
        ok=pcall(function() entry.world:transmitCompleteItemToClients() end)
        published=published and ok
    end
    if not published then return false,"publication-incomplete" end
    return true
end
function R.request(player,args)
    if type(args)~="table" or not integer(args.token) then return end
    local now=getTimestampMs()
    if lastRequest[player] and now-lastRequest[player]<1000 then return end
    lastRequest[player]=now
    local ran,plan,reason=pcall(R.plan,player,args)
    local ok=false
    if ran and plan then
        ran,ok,reason=pcall(R.apply,plan)
        if not ran then ok=false;reason="apply-error" end
    elseif not ran then plan=nil;reason="lookup-error" end
    if M.RootCauseDiagnostic then M.RootCauseDiagnostic.emit("split-pickup.result",player,
        {parentId=args.parentId,ok=ok,reason=reason,moved=plan and #plan.entries or 0}) end
    M.sendPlayerCommand(player,"splitPocketPickupReady",{token=tonumber(args.token),
        parentId=tonumber(args.parentId),ok=ok,reason=reason})
end
return R
