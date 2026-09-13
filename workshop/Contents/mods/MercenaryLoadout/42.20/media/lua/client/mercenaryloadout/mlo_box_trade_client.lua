require "ISUI/ISTradingUI"
local M=MercenaryLoadout
local P=M.BoxTransportPrepare

-- Gate native offer/seal packets, not finalizeDeal (which only closes the UI
-- after the native finalization packet). Each participant prepares their own
-- boxes. No custom trade, item copies or additional background event loop.
local function snapshot(list)
    local out={}
    for _,entry in ipairs(list.items) do out[#out+1]=entry.item end
    return out
end
local function sameOffer(list,items)
    if #list.items~=#items then return false end
    for i,entry in ipairs(list.items) do if entry.item~=items[i] then return false end end
    return true
end
local function cancel(ui)
    local request=ui.MLO_boxPrepare
    if request then
        P.cancel(request)
        if request.kind=="seal" then ui.sealOffer.selected[1]=false end
    end
    ui.MLO_boxPrepare=nil
end
local function fail(ui)
    cancel(ui)
    ui:setHistoryMessage(getText("IGUI_MLO_Error_TransferContent"),false,false,false)
end
local function validWindow(ui,request)
    return ui.player==request.player and ui.otherPlayer==request.otherPlayer
        and ui.player:getOnlineID()==request.playerId
        and ui.otherPlayer:getOnlineID()==request.otherId
        and ISTradingUI.windows[ui.player:getIndex()+1]==ui
        and ui:isVisible() and not ui.blockingMessage and not ui.blockingMessage2
        and not ui:isOfferSealed()
        and sameOffer(ui.yourOfferDatas,request.own)
        and sameOffer(ui.hisOfferDatas,request.other)
end
local function eligible(ui,items)
    local seen={}
    for _,item in ipairs(items) do
        if seen[item] or item:getContainer()~=ui.player:getInventory()
            or luautils.haveToBeTransfered(ui.player,item)
            or ui.player:isEquipped(item) or ui.player:isEquippedClothing(item)
            or item:isFavorite() then return false end
        seen[item]=true
    end
    return true
end
local function begin(ui,kind,items,option)
    local request={kind=kind,items=items,option=option,player=ui.player,
        otherPlayer=ui.otherPlayer,playerId=ui.player:getOnlineID(),
        otherId=ui.otherPlayer:getOnlineID(),own=snapshot(ui.yourOfferDatas),
        other=snapshot(ui.hisOfferDatas)}
    ui.MLO_boxPrepare=request
    return request
end

local nativeAdd=ISTradingUI.addItemToYourOffer
function ISTradingUI:addItemToYourOffer(item)
    -- Preserve native per-item rejection during a mixed bulk selection. An
    -- ineligible later click must not discard earlier valid pending boxes.
    if not eligible(self,{item}) then return nativeAdd(self,item) end
    local request=self.MLO_boxPrepare
    if request then
        if request.kind~="add" then cancel(self) else
            for _,pending in ipairs(request.items) do if pending==item then return end end
            request.items[#request.items+1]=item
            -- A new user selection changes the preparation scope. Retire the
            -- old token; update() starts one request for the complete selection.
            P.cancel(request)
            return
        end
    end
    local boxes=M.collectOwnedTransportBoxes(self.player,{item})
    if not boxes then fail(self);return end
    if #boxes==0 then return nativeAdd(self,item) end
    if self:isOfferSealed() then return end
    begin(self,"add",{item})
end

local nativeSeal=ISTradingUI.onSealOffer
function ISTradingUI:onSealOffer(option,enabled)
    if not enabled then cancel(self);return nativeSeal(self,option,false) end
    -- The checkbox is already true when the callback runs. Keep it unsealed
    -- until both peers agree on box transport ownership.
    self.sealOffer.selected[1]=false
    if self.MLO_boxPrepare then return end
    local items=snapshot(self.yourOfferDatas)
    local boxes=M.collectOwnedTransportBoxes(self.player,items)
    if not boxes then fail(self);return end
    if #boxes==0 then self.sealOffer.selected[1]=true;return nativeSeal(self,option,true) end
    begin(self,"seal",items,option)
end

local nativeUpdate=ISTradingUI.update
function ISTradingUI:update(...)
    local result=nativeUpdate(self,...)
    local request=self.MLO_boxPrepare
    if not request then return result end
    if not validWindow(self,request) or not eligible(self,request.items) then
        fail(self);return result
    end
    local boxes=M.collectOwnedTransportBoxes(self.player,request.items)
    local ready=P.poll(request,self.player,boxes)
    if ready==false then fail(self);return result end
    if ready~=true then return result end
    -- Consume before calling vanilla, so reentrant UI changes cannot replay it.
    self.MLO_boxPrepare=nil
    if request.kind=="add" then
        for _,item in ipairs(request.items) do nativeAdd(self,item) end
    else
        self.sealOffer.selected[1]=true
        nativeSeal(self,request.option,true)
    end
    return result
end

local nativeButtons=ISTradingUI.updateButtons
function ISTradingUI:updateButtons(...)
    local result=nativeButtons(self,...)
    if self.MLO_boxPrepare then
        self.sealOffer.enable=false
        self.acceptDeal.enable=false
    end
    return result
end
local nativeClick=ISTradingUI.onClick
function ISTradingUI:onClick(button,...)
    if self.MLO_boxPrepare and button.internal=="ACCEPTDEAL" then return end
    return nativeClick(self,button,...)
end
local nativeClose=ISTradingUI.close
function ISTradingUI:close(...)
    cancel(self)
    return nativeClose(self,...)
end
local nativeRemove=ISTradingUI.removeItem
function ISTradingUI:removeItem(...)
    cancel(self)
    return nativeRemove(self,...)
end
