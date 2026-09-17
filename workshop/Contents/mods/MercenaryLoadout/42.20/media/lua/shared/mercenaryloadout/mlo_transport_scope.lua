-- Transport v26: a client path is a lookup hint, never an ownership claim.
-- The server resolves each edge against actual ItemContainer membership.
require "mercenaryloadout/mlo_shared"
local M=MercenaryLoadout
local MAX_DEPTH=64
local MAX_EDGES=4096
local MAX_LOOKUPS=65536

local function integer(value)
    return type(value)=="number" and value==value and math.abs(value)<=9007199254740991
        and value%1==0
end
local function dense(values,limit)
    if type(values)~="table" then return false end
    local n=#values
    if n==0 or n>limit then return false end
    local count=0
    for key in pairs(values) do
        count=count+1
        if count>limit or not integer(key) or key<1 or key>n then return false end
    end
    return count==n
end

function M.transportPathForItem(player,item)
    if not player or not item then return nil,"missing-item" end
    local root=player:getInventory()
    local current,reverse,seen=item,{},{}
    while current do
        if seen[current] or #reverse>=MAX_DEPTH then return nil,"owned-container-cycle" end
        seen[current]=true
        local id=tonumber(current:getID())
        if not integer(id) then return nil,"owned-container-invalid-id" end
        reverse[#reverse+1]=id
        local container=current:getContainer()
        if not container then return nil,"container-not-owned" end
        if container==root then
            local path={}
            for i=#reverse,1,-1 do path[#path+1]=reverse[i] end
            return path
        end
        local parent=container:getContainingItem()
        if not parent or not parent:IsInventoryContainer() or parent:getInventory()~=container then
            return nil,"owned-container-backref-mismatch"
        end
        current=parent
    end
    return nil,"container-not-owned"
end

function M.resolveTransportPaths(player,ids,paths)
    if not player or not dense(ids,M.CONTAINER_TRANSPORT_LIMIT)
        or not dense(paths,M.CONTAINER_TRANSPORT_LIMIT) or #ids~=#paths then
        return nil,"invalid-selection"
    end
    local root=player:getInventory()
    if not root then return nil,"missing-root" end
    local out,selected,indexes={},{},{}
    local comparisons,edges=0,0
    local function findDirect(container,id)
        local index=indexes[container]
        if not index then
            index={}
            local values=container:getItems()
            if comparisons+values:size()>MAX_LOOKUPS then return nil,"lookup-limit" end
            comparisons=comparisons+values:size()
            -- Read IDs only. Never descend into unrequested containers or
            -- make an unrelated broken child a prerequisite of this transfer.
            for i=0,values:size()-1 do
                local candidate=values:get(i)
                if candidate then
                    local candidateId=tonumber(candidate:getID())
                    if integer(candidateId) then
                        if index[candidateId]~=nil then index[candidateId]=false
                        else index[candidateId]=candidate end
                    end
                end
            end
            indexes[container]=index
        end
        local item=index[id]
        if item==false then return nil,"owned-container-duplicate-id" end
        if not item or item:getContainer()~=container then return nil,"ownership-changed" end
        return item
    end
    for n,id in ipairs(ids) do
        local path=paths[n]
        if not integer(id) or selected[id] or not dense(path,MAX_DEPTH)
            or path[#path]~=id then return nil,"invalid-path" end
        selected[id]=true
        edges=edges+#path
        if edges>MAX_EDGES then return nil,"path-limit" end
        local container,item=root,nil
        local seen={}
        for depth,pathId in ipairs(path) do
            if not integer(pathId) or seen[container] then return nil,"invalid-path" end
            seen[container]=true
            local reason
            item,reason=findDirect(container,pathId)
            if not item then return nil,reason end
            if depth<#path then
                if not item:IsInventoryContainer() then return nil,"invalid-path" end
                container=item:getInventory()
                if not container or container:getContainingItem()~=item then
                    return nil,"owned-container-backref-mismatch"
                end
            end
        end
        if not M.VANILLA_CONTAINER_STATE[M.fullType(item)] then return nil,"not-supported-box" end
        out[#out+1]=item
    end
    return out
end
return M
