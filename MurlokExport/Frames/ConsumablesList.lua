local _, core = ...

-- Global string per group and slot of GorlocConsumables.GetLayout(). A group or slot missing
-- here is one Gorloc Consumables added after this was written, and is left out.
local GroupNames = {
	["consumables"] = "MURLOKEXPORT_CATEGORY_CONSUMABLES",
	["enchants"] = "MURLOKEXPORT_CONSUMABLES_ENCHANTS",
	["gems"] = "MURLOKEXPORT_CONSUMABLES_GEMS"
}

local SlotNames = {
	["flask"] = "MURLOKEXPORT_CONSUMABLES_FLASK",
	["combat_potion"] = "MURLOKEXPORT_CONSUMABLES_COMBAT_POTION",
	["health_potion"] = "MURLOKEXPORT_CONSUMABLES_HEALTH_POTION",
	["weapon_buff"] = "MURLOKEXPORT_CONSUMABLES_WEAPON_BUFF",
	["food"] = "MURLOKEXPORT_CONSUMABLES_FOOD",
	["augment_rune"] = "MURLOKEXPORT_CONSUMABLES_AUGMENT_RUNE",
	["weapon"] = "MURLOKEXPORT_CONSUMABLES_WEAPON",
	["head"] = "HEADSLOT",
	["shoulder"] = "SHOULDERSLOT",
	["chest"] = "CHESTSLOT",
	["legs"] = "LEGSSLOT",
	["feet"] = "FEETSLOT",
	["finger"] = "FINGER0SLOT",
	["diamond"] = "MURLOKEXPORT_CONSUMABLES_DIAMOND",
	["gems"] = "MURLOKEXPORT_CONSUMABLES_GEMS"
}

-- A list of one spec's recommendations, shown in the Equipment panel and at the Auction House.
-- The Auction House sets itemsOnly (spells cannot be bought) and showCounts (how many you have).
ConsumablesListFrameMixin = {}
function ConsumablesListFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView()
	view:SetElementFactory(function(factory, elementData)
		if elementData.header then
			factory("ConsumablesListHeaderTemplate", function(frame, data) frame.Text:SetText(data.header) end)
		elseif elementData.note then
			factory("ConsumablesListNoteRowTemplate", function(frame, data) frame:Init(data) end)
		else
			factory("ConsumablesListRowTemplate", function(frame, data) frame:Init(data) end)
		end
	end)
	view:SetPadding(0, 8, 0, 0, 0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)
end

-- Returns whether Gorloc Consumables has data for specId.
-- GetSpec builds a new copy on every call, so it only runs when the spec changes.
function ConsumablesListFrameMixin:SetSpec(specId)
	if specId ~= self.specId then
		self.specId = specId
		local api = core:GetConsumablesAPI()
		self.spec = api and specId and api.GetSpec(specId)
		self:Refresh(api)
	end
	return self.spec ~= nil
end

-- One header per group, then a row per recommendation: every best entry labelled with its
-- slot, followed by the slot's options, indented, dimmed and labelled as an alternative.
-- An entry the guide comments on carries that note, its links turned into names by FormatNote.
function ConsumablesListFrameMixin:Refresh(api)
	local dataProvider = CreateDataProvider()
	if self.spec then
		for _, layout in ipairs(api.GetLayout()) do
			local slots = GroupNames[layout.group] and self.spec[layout.group]
			if slots then
				-- the header goes in with the group's first row, so a group with no rows has none
				local header = {header = _G[GroupNames[layout.group]]}
				local function insert(ref, slot, option)
					if self.itemsOnly and ref.type ~= "item" then
						return
					end
					if header then
						dataProvider:Insert(header)
						header = nil
					end
					dataProvider:Insert({ref = ref, slot = slot, note = self:FormatNote(api, ref), option = option, showCount = self.showCounts})
				end
				for _, slot in ipairs(layout.slots) do
					local entry = SlotNames[slot] and slots[slot]
					if entry then
						for _, ref in ipairs(entry.best) do
							insert(ref, _G[SlotNames[slot]], false)
						end
						for _, ref in ipairs(entry.options or {}) do
							insert(ref, MURLOKEXPORT_CONSUMABLES_ALTERNATIVE, true)
						end
					end
				end
			end
		end
		self.Updated:SetText(format(MURLOKEXPORT_CONSUMABLES_UPDATED, self.spec.modified and strsub(self.spec.modified, 1, 10) or ""))
	end
	self.ScrollBox:SetDataProvider(dataProvider)
end

-- Notes are newer than API_VERSION 1, so an older Gorloc Consumables has neither them nor FormatNote.
function ConsumablesListFrameMixin:FormatNote(api, ref)
	if ref.note and api.FormatNote then
		return api.FormatNote(ref.note)
	end
end

ConsumablesListRowMixin = {}
function ConsumablesListRowMixin:Init(elementData)
	if self.cancelItemLoad then
		self.cancelItemLoad()
		self.cancelItemLoad = nil
	end
	self.ref = elementData.ref
	self.Slot:SetText(elementData.slot)
	self:SetAlpha(elementData.option and 0.5 or 1)
	self.Icon:SetPoint("LEFT", elementData.option and 24 or 8, 0)
	-- with a note, name and slot move up to make room for it below the name
	local offset = elementData.note and 7 or 0
	self.Slot:SetPoint("RIGHT", -8, offset)
	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 8, offset)
	self.Note:SetText(elementData.note)
	self.Note:SetShown(elementData.note ~= nil)
	self.showCount = elementData.showCount
	self:UpdateCount()

	if self.ref.type == "spell" then
		self.Icon:SetTexture(C_Spell.GetSpellTexture(self.ref.id))
		self.Name:SetText(C_Spell.GetSpellName(self.ref.id))
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
	else
		-- names and quality need the item in the client cache, which it may not be yet
		local item = Item:CreateFromItemID(self.ref.id)
		self.Icon:SetTexture(item:GetItemIcon())
		self.Name:SetText("")
		self.cancelItemLoad = item:ContinueWithCancelOnItemLoad(function()
			self.cancelItemLoad = nil
			self.Name:SetText(item:GetItemName())
			local color = ITEM_QUALITY_COLORS[item:GetItemQuality()]
			self.Name:SetTextColor((color and color.color or HIGHLIGHT_FONT_COLOR):GetRGB())
		end)
	end
end

-- How many the player has, bags and banks: shown on the icon, and not at all when none.
function ConsumablesListRowMixin:UpdateCount()
	local count = self.showCount and self.ref.type == "item" and C_Item.GetItemCount(self.ref.id, true, false, true, true) or 0
	self.Count:SetText(count)
	self.Count:SetShown(count > 0)
end

function ConsumablesListRowMixin:GetLink()
	if self.ref.type == "spell" then
		return C_Spell.GetSpellLink(self.ref.id)
	end
	local _, link = C_Item.GetItemInfo(self.ref.id)
	return link
end

function ConsumablesListRowMixin:OnEnter()
	GameTooltip:SetOwner(self, self:GetRight() < GetScreenWidth() / 2 and "ANCHOR_RIGHT" or "ANCHOR_LEFT")
	if self.ref.type == "spell" then
		GameTooltip:SetSpellByID(self.ref.id)
	else
		GameTooltip:SetItemByID(self.ref.id)
	end
	GameTooltip:Show()
end

function ConsumablesListRowMixin:OnLeave()
	GameTooltip_Hide()
end

-- A plain click on an item searches the Auction House for it, when it is open.
function ConsumablesListRowMixin:OnClick()
	if IsModifiedClick() then
		local link = self:GetLink()
		if link then
			HandleModifiedItemClick(link)
		end
	elseif self.ref.type == "item" then
		core:SearchAuctionHouse(C_Item.GetItemNameByID(self.ref.id))
	end
end
