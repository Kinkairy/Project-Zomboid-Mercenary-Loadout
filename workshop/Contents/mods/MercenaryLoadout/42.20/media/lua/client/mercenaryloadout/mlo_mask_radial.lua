-- Adds one state-labelled mask slice to the existing D-pad-left utility wheel.
-- No custom wear state, model, item copy, inventory transfer, or server command.
require "mercenaryloadout/mlo_shared"
local M=MercenaryLoadout
local SLOT="MLO_Pack_WeldingMask"

local function resolve(player,hotbar,expectedId)
    if not player or not hotbar or hotbar.chr~=player or player:isDead() then return nil end
    for index,slot in ipairs(hotbar.availableSlot or {}) do
        if slot.def and slot.def.type==SLOT then
            local item=hotbar.attachedItems and hotbar.attachedItems[index]
            if item and (not expectedId or tonumber(item:getID())==expectedId)
                and item:getContainer()==player:getInventory()
                and item:getAttachedSlot()==index and M.isCompatible(SLOT,item) then
                local parent,linkedSlot=M.findPersistentMountParent(player,item)
                if parent and linkedSlot==SLOT and M.parentEquipped(player,parent)
                    and M.slotEnabled(parent,SLOT) then return item,index end
            end
        end
    end
    return nil
end

function M.activateMaskRadial(playerIndex,itemId,wasWorn)
    local player=getSpecificPlayer(playerIndex)
    local hotbar=getPlayerHotbar(playerIndex)
    local item,index=resolve(player,hotbar,tonumber(itemId))
    -- Never toggle a different replacement or reverse an intervening action.
    if not item or player:isEquippedClothing(item)~=wasWorn then return end
    local menu=getPlayerRadialMenu(playerIndex)
    if not menu then return end
    -- UIManager defers radial removal. Exclude only this closing wheel from
    -- the stock guard, retaining pause/death/attack/action checks.
    local visible=menu:isVisible()
    menu:setVisible(false)
    local ok,allowed=pcall(hotbar.isAllowedToActivateSlot,hotbar)
    menu:setVisible(visible)
    if ok and allowed then hotbar:activateSlot(index) end
end

function M.addMaskRadialSlice(player,hotbar,menu)
    local item=resolve(player,hotbar)
    if not item or not menu then return end
    local id=tonumber(item:getID())
    for _,slice in ipairs(menu.slices or {}) do
        local command=slice.command
        if command and command[1]==M.activateMaskRadial and command[3]==id then return end
    end
    local worn=player:isEquippedClothing(item)
    local key=worn and "IGUI_MLO_Radial_RemoveMask" or "IGUI_MLO_Radial_WearMask"
    menu:addSlice(M.text(key,{M.displayName(item)}),item:getTex(),
        M.activateMaskRadial,player:getPlayerNum(),id,worn)
end
return M
