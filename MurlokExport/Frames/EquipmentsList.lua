
local _, core = ...

SlotConfig = {
	["head"] = "HEADSLOT",
	["neck"] = "NECKSLOT",
	["shoulders"] = "SHOULDERSLOT",
	["back"] = "BACKSLOT",
	["chest"] = "CHESTSLOT",
	["waist"] = "WAISTSLOT",
	["legs"] = "LEGSSLOT",
	["feet"] = "FEETSLOT",
	["wrist"] = "WRISTSLOT",
	["hands"] = "HANDSSLOT",
	["ring-1"] = "FINGER0SLOT",
	["ring-2"] = "FINGER1SLOT",
	["trinket-1"] = "TRINKET0SLOT",
	["trinket-2"] = "TRINKET1SLOT",
	["main-hand"] = "MAINHANDSLOT",
	["off-hand"] = "SECONDARYHANDSLOT"
}

EquipmentsListFrameMixin = {}
function EquipmentsListFrameMixin:OnLoad()
	local equipmentsView = CreateScrollBoxListLinearView()
	equipmentsView:SetElementInitializer("EquipmentsListTemplate", function(frame, elementData) self:InitEquipmentFrame(frame, elementData) end)
	equipmentsView:SetPadding(0, 280, 60, 60, 0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.EquipmentsScrollBox, self.EquipmentsScrollBar, equipmentsView)

	-- everything that makes up the equipment view, hidden while the consumables view is shown
	self.equipmentWidgets = {}
	for _, child in ipairs({self:GetChildren()}) do
		if child ~= self.EquipmentsInset and child ~= self.equipmentsBorder and child ~= self.ConsumablesToggle and child ~= self.ConsumablesFrame then
			tinsert(self.equipmentWidgets, child)
		end
	end
	self.ConsumablesToggle:SetFrameLevel(self.equipmentsBorder:GetFrameLevel() + 1)
	self.ConsumablesToggle:SetScript("OnClick", function() self:ToggleConsumables() end)
	self:SetConsumablesShown(false)
end

-- Consumables are per spec and PvE only: they can be shown in the Mythic+ list, for a spec
-- Gorloc Consumables has data for. The compact view shows them on their own tab, the
-- maximized view behind the toggle. Called without specId it keeps the last one.
function EquipmentsListFrameMixin:UpdateConsumables(specId)
	if specId then
		self.consumablesSpecId = specId
	end
	local available = self.ConsumablesFrame:SetSpec(self.consumablesSpecId) and UIMurlokExport.ClassListFrame:GetDisplayMode() == "m+"
	self.ConsumablesToggle:SetShown(available and not MurlokExportConfig.CompactView)
	UIMurlokExport:SetConsumablesTabShown(available)
	self:SetConsumablesShown(available and self:IsConsumablesWanted())
end

function EquipmentsListFrameMixin:IsConsumablesWanted()
	if MurlokExportConfig.CompactView then
		return UIMurlokExport.selectedTab == 5
	end
	return MurlokExportConfig.ShowConsumables
end

function EquipmentsListFrameMixin:ToggleConsumables()
	MurlokExportConfig.ShowConsumables = not MurlokExportConfig.ShowConsumables
	self:SetConsumablesShown(MurlokExportConfig.ShowConsumables)
end

function EquipmentsListFrameMixin:SetConsumablesShown(shown)
	for _, widget in ipairs(self.equipmentWidgets) do
		widget:SetShown(not shown)
	end
	self.ConsumablesFrame:SetShown(shown)
	self.equipmentsBorder.HeaderText:SetText(shown and MURLOKEXPORT_CATEGORY_CONSUMABLES or MURLOKEXPORT_CATEGORY_EQUIPMENT)
	self.ConsumablesToggle:SetText(shown and MURLOKEXPORT_CATEGORY_EQUIPMENT or MURLOKEXPORT_CATEGORY_CONSUMABLES)
end

function EquipmentsListFrameMixin:InitEquipmentFrame(frame, elementData)
	frame.equipmentSlot:SetText(_G[strupper(elementData.equipmentSlot)])

	local index = 1
	local enchants = {}
	for k, v in core:IPairs(elementData.equipment.enchantments, function (k1, k2) return k1[2].count > k2[2].count end) do
		enchants[index] = k
		index = index + 1
	end

	index  = 1
	for k, v in core:IPairs(elementData.equipment.items, function (k1, k2) return k1[2].count > k2[2].count end) do
		local bonus = ""
		if v.bonus then
			bonus = #v.bonus .. ":" .. table.concat(v.bonus, ":")
		end
		local enchant = ""
		if enchants[index] then
			enchant = enchants[index]
		end
		local link = "|Hitem:" .. k .. ":" .. enchant .. "::::::::" .. elementData.specId .. ":::" .. bonus .. "|h"
		frame["itemButton" .. index]:SetItem(link)
		frame["itemButton" .. index].Count:SetText(core:GetRankColor(v.rank)  ..  v.count  ..  "|r")
		frame["itemButton" .. index].Count:Show()
		frame["itemButton" .. index]:Show()
		index = index + 1
	end
	for i=index,5 do
		frame["itemButton" .. i]:SetItem(nil)
		frame["itemButton" .. i].icon:Show()
		frame["itemButton" .. i].icon:SetAtlas("bags-item-slot64")
	end

	index = 1
	for k, v in core:IPairs(elementData.equipment.enchantments, function (k1, k2) return k1[2].count > k2[2].count end) do
		local link = nil
		if v.source and v.source.type == "item" then
			link = "|Hitem:" .. (v.source.id) .. "::::::::::::|h"
			frame["enchantButton" .. index]:SetItem(link)
			frame["enchantButton" .. index].Count:SetText(core:GetRankColor(v.rank)  ..  v.count  ..  "|r")
			frame["enchantButton" .. index].Count:Show()
		elseif v.source and v.source.type == "spell" then
			link = C_Spell.GetSpellLink(v.source.id)
			frame["enchantButton" .. index]:SetItemSource(nil)
			frame["enchantButton" .. index].item = link
			local rank = 1
			if v.rank == 0 then 
				rank = 5 
			elseif v.rank >= 1 and v.rank < 5 then 
				rank = 4 
			end
			frame["enchantButton" .. index]:SetItemButtonQuality(rank, link)
			frame["enchantButton" .. index]:SetItemButtonTexture(C_Spell.GetSpellTexture(v.source.id))
			frame["enchantButton" .. index].Count:SetText(core:GetRankColor(v.rank)  ..  v.count  ..  "|r")
			frame["enchantButton" .. index].Count:Show()
		else
			frame["enchantButton" .. index]:SetItem(nil)
			frame["enchantButton" .. index].icon:Show()
			frame["enchantButton" .. index].icon:SetAtlas("bags-item-slot64")
		end
		index = index + 1
	end
	for i=index,5 do
		frame["enchantButton" .. i]:SetItem(nil)
		frame["enchantButton" .. i].icon:Show()
		frame["enchantButton" .. i].icon:SetAtlas("bags-item-slot64")
	end

	index = 1
	for k, v in core:IPairs(elementData.equipment.gems, function (k1, k2) return k1[2].count > k2[2].count end) do
		local link = ("|Hitem:" .. k .. "|h")
		frame["gemButton" .. index]:SetItem(link)
		frame["gemButton" .. index].Count:SetText(core:GetRankColor(v.rank)  ..  v.count  ..  "|r")
		frame["gemButton" .. index].Count:Show()
		index = index + 1
	end
	for i=index,5 do
		frame["gemButton" .. i]:SetItem(nil)
		frame["gemButton" .. i].icon:Show()
		frame["gemButton" .. i].icon:SetAtlas("bags-item-slot64")
	end
end

function EquipmentsListFrameMixin:OnClick(stats, specId)
    local equipmentsDataProvider = CreateDataProvider()
    local index = 1
    for slot, equip in core:IPairs(stats.equips, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2].order < k2[2].order end) do
    	equipmentsDataProvider:Insert({
    		index = index,
    		equipmentSlot = SlotConfig[slot],
    		slotId = GetInventorySlotInfo(SlotConfig[slot]),
    		specId = specId,
    		equipment = equip
    	})
    	index = index + 1
    end
    self.EquipmentsScrollBox:SetDataProvider(equipmentsDataProvider, ScrollBoxConstants.RetainScrollPosition)
    self:UpdateConsumables(specId)
    -- self:Hide()
    -- self:Show()
end

EnchantingItemButtonMixin = CreateFromMixins(EnchantingItemButtonAnimMixin)
function EnchantingItemButtonMixin:OnLoad()
    EnchantingItemButtonAnimMixin.OnLoad(self)
	self:RegisterForClicks("LeftButtonUp")

    local start = "character"
    if strsub(self:GetParentKey(), 1, string.len(start)) == start then
        local id, _ = GetInventorySlotInfo(strsub(self:GetParentKey(), 10))
        self:SetID(id)
    end
end

function EnchantingItemButtonMixin:OnShow()
    EnchantingItemButtonAnimMixin.OnShow(self)
    if self:GetID() > 0 then
        local _, textureName = GetInventorySlotInfo(strsub(self:GetParentKey(), 10))
        self.icon:SetTexture(textureName)
        self.emptyTexture = textureName

        local link = GetInventoryItemLink("player", self:GetID())
        if link then
            self:SetItem(link)
        else
            self:SetItem(nil)
		    self.icon:SetTexture(self.emptyTexture)
            self.icon:SetShown(self.emptyTexture ~= nil)
        end
    end
end

function EnchantingItemButtonMixin:CheckUpdateTooltip(tooltipOwner)
	if self == tooltipOwner then
		if self:HasItem() then
			self:UpdateTooltip()
		else
			GameTooltip:Hide()
		end
	end
end

function EnchantingItemButtonMixin:OnEnter()
	self:OnUpdate()
end

function EnchantingItemButtonMixin:OnLeave()
	GameTooltip_Hide()
end

function EnchantingItemButtonMixin:OnUpdate()
	if self:GetItem() then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		self:CalculateItemTooltipAnchors()
		GameTooltip:SetHyperlink(self:GetItem())
	end
end

function EnchantingItemButtonMixin:OnClick(button)
	if button == "LeftButton" and self:GetID() then
		UIMurlokExport.EquipmentsListFrame.EquipmentsScrollBox:ScrollToElementDataByPredicate(function(e) return e.slotId == self:GetID() end, ScrollBoxConstants.AlignBegin, 0, true)
	end
	if self:GetItem() then
		local _, link = C_Item.GetItemInfo(self:GetItem())
		HandleModifiedItemClick(link)
	end
end

function EnchantingItemButtonMixin:CalculateItemTooltipAnchors()
	local x = self:GetRight()
	local anchorFromLeft = x < GetScreenWidth() / 2
	if ( anchorFromLeft ) then
		GameTooltip:SetAnchorType("ANCHOR_RIGHT", 0, 0)
		GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT")
	else
		GameTooltip:SetAnchorType("ANCHOR_LEFT", 0, 0)
		GameTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT")
	end
end