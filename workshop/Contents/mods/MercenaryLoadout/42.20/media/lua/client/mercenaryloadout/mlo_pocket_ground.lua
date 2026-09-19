-- Fixed pouches remain real native world items for saves and grouped pickup.
-- Present only their owner on the ground; never hide detached or orphan items.
require "mercenaryloadout/mlo_pocket_transport"
local M=MercenaryLoadout
local T=M.PocketTransport
local hidden=setmetatable({}, {__mode="k"})
local knownSquare=setmetatable({}, {__mode="k"})

local function restore(object)
    local state=hidden[object]
    if not state then return end
    if object:getSprite()==state.empty then
        object:setSprite(state.sprite)
        object:updateSprite()
    end
    object:setNoPicking(state.noPicking)
    hidden[object]=nil
end

local function present(object,concealed)
    if not concealed then restore(object);return end
    local state=hidden[object]
    if not state then
        state={sprite=object:getSprite(),noPicking=object:isNoPicking(),empty=IsoSprite.new()}
        hidden[object]=state
    end
    -- A native sprite refresh may have populated our previous empty sprite.
    if not state.empty:hasNoTextures() then state.empty=IsoSprite.new() end
    if object:getSprite()~=state.empty then object:setSprite(state.empty) end
    object:setNoPicking(true)
end

local function refresh(square)
    local objects=square:getWorldObjects()
    local byId={}
    for index=0,objects:size()-1 do
        local object=objects:get(index)
        local item=object:getItem()
        if item and item:getWorldItem()==object and object:getSquare()==square then
            local id=tonumber(item:getID())
            if id then
                if byId[id]~=nil then byId[id]=false else byId[id]=item end
            end
            if M.isParent(item) or M.isFixedPouchItem(item) then knownSquare[object]=square end
        end
    end
    for index=0,objects:size()-1 do
        local object=objects:get(index)
        local item=object:getItem()
        local concealed=false
        if item and M.isFixedPouchItem(item) and not M.isDetachedPouch(item)
            and item:getWorldItem()==object and object:getSquare()==square
            and byId[tonumber(item:getID())]==item then
            local md=item:getModData()
            local parent=byId[tonumber(md.MLO_parentId)]
            local key=md.MLO_moduleKey
            local definition=key and M.FIXED_POUCH[key]
            -- Same-square, two-way identity is required. Packet ordering may
            -- reveal a pouch briefly; an unproven relation must stay recoverable.
            concealed=parent and M.isParent(parent) and definition
                and definition.fullType==item:getFullType()
                and tonumber(parent:getModData()["MLO_module_"..key])==tonumber(item:getID())
            -- Owned pouch types are InventoryContainers with no world model.
            -- Native rendering/picking both skip an empty fallback sprite.
            -- Leave another Mod's added 3D model alone rather than fake success.
            local model=item:getWorldStaticItem()
            concealed=concealed and (model==nil or model=="")
        end
        present(object,concealed==true)
    end
end

function T.refreshGroundSquare(square)
    if isServer() or not square then return end
    local ok,reason=pcall(refresh,square)
    if not ok then
        M.logOnce("fixed-pouch-ground", "fixed pouch ground presentation failed: "..tostring(reason))
    end
end

local function onWorldObjectChanged(object)
    if isServer() or not object or not instanceof(object,"IsoWorldInventoryObject") then return end
    local previous=knownSquare[object]
    local square=object:getSquare()
    if previous then T.refreshGroundSquare(previous) end
    if square and square~=previous then T.refreshGroundSquare(square) end
    local item=object:getItem()
    if not item or item:getWorldItem()~=object then
        if item then restore(object) else hidden[object]=nil end
        knownSquare[object]=nil
    end
end

Events.LoadGridsquare.Add(T.refreshGroundSquare)
Events.OnObjectAdded.Add(onWorldObjectChanged)
-- Native map add/remove packets include the affected object, including removal
-- after its square reference was cleared. No frame timer or global floor scan.
Events.OnContainerUpdate.Add(onWorldObjectChanged)
return T
