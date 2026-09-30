-- Resume an explicitly requested pickup only after native world replication
-- contains the complete group. A reply alone is not replication confirmation.
require "mercenaryloadout/mlo_pocket_transport"
local M=MercenaryLoadout
local T=M.PocketTransport
if T.splitPickupClientInstalled then return T end
T.splitPickupClientInstalled=true
local pending=setmetatable({}, {__mode="k"})
local sequence=0
function T.prepareSplitPickup(player,items,source,destination,reason)
    if not isClient() or type(reason)~="string" or not reason:match("^missing%-pocket:")
        or #items~=1 or source:getType()~="floor" or destination~=player:getInventory() then return false end
    local item=items[1]
    local object=item:getWorldItem()
    local square=object and object:getSquare()
    if not square or not M.isParent(item) then return false end
    if pending[player] then return pending[player].item==item end
    sequence=sequence+1
    local request={item=item,source=source,destination=destination,token=sequence,
        x=square:getX(),y=square:getY(),z=square:getZ(),deadline=getTimestampMs()+10000}
    pending[player]=request
    local sent=pcall(sendClientCommand,player,M.MODULE,"prepareSplitPocketPickup",{
        token=sequence,parentId=item:getID(),x=request.x,y=request.y,z=request.z})
    if not sent then pending[player]=nil;return false end
    return true
end
local function fail(player,request,reason)
    pending[player]=nil
    T.reject(player,reason or "split-pickup-failed")
end
local function tick()
    for player,request in pairs(pending) do
        if player:isDead() or player:getInventory()~=request.destination then
            pending[player]=nil
        elseif getTimestampMs()>request.deadline then
            fail(player,request,"split-pickup-timeout")
        elseif request.ready then
            local item=request.item
            local world=item:getWorldItem()
            local square=world and world:getSquare()
            local current=player:getCurrentSquare()
            if item:getContainer()==request.destination then
                pending[player]=nil
            elseif not square or square:getX()~=request.x or square:getY()~=request.y or square:getZ()~=request.z
                or not current or current:getZ()~=square:getZ()
                or math.abs(current:getX()-square:getX())>1 or math.abs(current:getY()-square:getY())>1 then
                fail(player,request,"split-pickup-moved")
            else
                -- Refresh the native floor view after world-add packets arrive.
                local source=ISInventoryPage.GetFloorContainer(player:getPlayerNum())
                local plan=T.plan({item},source,request.destination,player)
                if plan then
                    local ok,reason=T.preflight(plan)
                    if not ok then fail(player,request,reason)
                    else
                        pending[player]=nil
                        ISTimedActionQueue.add(ISInventoryTransferAction:new(player,item,source,request.destination))
                    end
                end
            end
        end
    end
end
Events.OnTick.Add(tick)
Events.OnServerCommand.Add(function(module,command,args)
    if module~=M.MODULE or command~="splitPocketPickupReady" or type(args)~="table" then return end
    for player,request in pairs(pending) do
        if tonumber(args.token)==request.token and tonumber(args.parentId)==tonumber(request.item:getID()) then
            if args.ok==true then request.ready=true
            else fail(player,request,args.reason) end
            return
        end
    end
end)
return T
