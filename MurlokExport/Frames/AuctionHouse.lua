local addonName, core = ...

-- Searches the Auction House for an item by name, the way its own search bar does, across every
-- category. Returns false when the Auction House is not open.
function core:SearchAuctionHouse(name)
	if not (name and AuctionHouseFrame and AuctionHouseFrame:IsVisible()) then
		return false
	end
	AuctionHouseFrame:GetCategoriesList():SetSelectedCategory(nil)
	AuctionHouseFrame.SearchBar:SetSearchText(name)
	AuctionHouseFrame.SearchBar:StartSearch()
	return true
end

-- A panel docked to the right of the Auction House with what the current spec should buy.
-- Closed with its close button it leaves a small toggle on the Auction House's edge instead,
-- and the choice is kept in MurlokExportConfig.HideAuctionHousePanel.
MurlokExportAuctionHouseMixin = {}
function MurlokExportAuctionHouseMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)
	ButtonFrameTemplate_HideButtonBar(self)
	ButtonFrameTemplate_HideAttic(self)
	self.List.itemsOnly = true
	self.List.showCounts = true
	self.CloseButton:SetScript("OnClick", function()
		MurlokExportConfig.HideAuctionHousePanel = true
		self:Update()
	end)
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	-- Attach waits for our own ADDON_LOADED: the toggle is created after this frame, and when
	-- another addon has already loaded the Auction House UI, ContinueOnAddOnLoaded would call
	-- back right here, before the toggle exists.
	self:RegisterEvent("ADDON_LOADED")
end

function MurlokExportAuctionHouseMixin:Attach()
	local toggle = MurlokExportAuctionHouseToggle
	self:SetParent(AuctionHouseFrame)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", 2, 0)
	self:SetPoint("BOTTOMLEFT", AuctionHouseFrame, "BOTTOMRIGHT", 2, 0)
	toggle:SetParent(AuctionHouseFrame)
	toggle:ClearAllPoints()
	toggle:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", -2, -230)
	AuctionHouseFrame:HookScript("OnShow", function() self:Update() end)
	self:Update()
end

-- Shown when Gorloc Consumables has data for the current spec, unless the player closed it.
function MurlokExportAuctionHouseMixin:Update()
	local _, specId = core:GetPlayerClassSpecHero()
	local available = specId ~= nil and self.List:SetSpec(specId)
	if available then
		local _, specName, _, _, _, _, className = GetSpecializationInfoByID(specId)
		self:SetTitle(format("%s: %s %s", MURLOKEXPORT_CATEGORY_CONSUMABLES, specName, className))
	end
	self:SetShown(available and not MurlokExportConfig.HideAuctionHousePanel)
	MurlokExportAuctionHouseToggle:SetShown(available and MurlokExportConfig.HideAuctionHousePanel)
end

function MurlokExportAuctionHouseMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == addonName then
		self:UnregisterEvent("ADDON_LOADED")
		-- the Auction House UI loads on demand, the first time one is opened
		EventUtil.ContinueOnAddOnLoaded("Blizzard_AuctionHouseUI", function()
			self:Attach()
		end)
	-- after a purchase, or anything else that changes what is in the bags
	elseif event == "BAG_UPDATE_DELAYED" and self:IsVisible() then
		self.List.ScrollBox:ForEachFrame(function(frame)
			if frame.UpdateCount then
				frame:UpdateCount()
			end
		end)
	end
end

-- A side tab like the quest log's (LargeSideTabButtonTemplate), which brings its own hover,
-- click sound and tooltip. It is only shown while the panel is closed, so never selected.
MurlokExportAuctionHouseToggleMixin = {}
function MurlokExportAuctionHouseToggleMixin:OnLoad()
	self.Icon:SetTexture(core:Artwork("MurlokExport_Tab"))
	self.Icon:SetSize(30, 30)
	self.SelectedTexture:Hide()
	self.tooltipText = MURLOKEXPORT_CATEGORY_CONSUMABLES
	self:SetCustomOnMouseUpHandler(function(_, button, upInside)
		if button == "LeftButton" and upInside then
			MurlokExportConfig.HideAuctionHousePanel = false
			MurlokExportAuctionHouse:Update()
		end
	end)
end
