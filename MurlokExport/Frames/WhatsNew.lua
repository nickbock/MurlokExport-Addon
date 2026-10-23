local addonName, core = ...

local GORLOC_CONSUMABLES_URL = "https://www.curseforge.com/wow/addons/gorloc-consumables"

-- Release notes, shown once after an update, keyed by the TOC's ## Version. A version
-- without an entry shows nothing, so a fix release goes out without a popup.
-- text: the global string with the notes. image (optional): a file in Artwork/, its size as
-- shown, and texCoord to crop it, since a texture's size must be a power of two. The file name
-- has no dots: the path goes without its extension, and the game would take ".0" for one.
local ReleaseNotes = {
	["1.7.0"] = {
		text = "MURLOKEXPORT_WHATSNEW_1_7_0",
		image = {file = "WhatsNew_1_7_0", width = 300, height = 194, texCoord = {0, 395 / 512, 0, 1}}
	}
}

-- On the first time MurlokExport opens in a version, that version's notes.
function core:ShowWhatsNew()
	local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
	if MurlokExportConfig.WhatsNewSeen == version then
		return
	end
	MurlokExportConfig.WhatsNewSeen = version
	if ReleaseNotes[version] then
		MurlokExportWhatsNew:ShowNotes(version, ReleaseNotes[version])
	end
end

MurlokExportWhatsNewMixin = {}
function MurlokExportWhatsNewMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName())
	self:RegisterForDrag("LeftButton")
	self:SetTitle(MURLOKEXPORT_TITLE)
	self.PortraitContainer.portrait:SetTexture(core:Artwork(MURLOKEXPORT_TITLE))
	self.Okay:SetScript("OnClick", function() self:Hide() end)

	local gorloc = self.Gorloc
	gorloc.Text:SetText(MURLOKEXPORT_WHATSNEW_GORLOC)
	gorloc.Hint:SetText(MURLOKEXPORT_WHATSNEW_COPY_HINT)
	gorloc.Copy:SetText(MURLOKEXPORT_WHATSNEW_COPY)
	-- the game cannot write to the clipboard: select the link for the player to copy
	gorloc.Copy:SetScript("OnClick", function()
		gorloc.Link:SetFocus()
		gorloc.Link:HighlightText()
		gorloc.Hint:Show()
	end)
	gorloc.Link:SetText(GORLOC_CONSUMABLES_URL)
	gorloc.Link:SetCursorPosition(0)
	-- read-only: typing puts the link back
	gorloc.Link:HookScript("OnTextChanged", function(editBox, userInput)
		if userInput then
			editBox:SetText(GORLOC_CONSUMABLES_URL)
			editBox:HighlightText()
		end
	end)
end

-- The image goes below the notes, the Gorloc Consumables link below that, and the link only
-- while Gorloc Consumables is not installed.
function MurlokExportWhatsNewMixin:ShowNotes(version, release)
	self.Heading:SetText(format(MURLOKEXPORT_WHATSNEW_TITLE, version))
	self.Notes:SetText(_G[release.text])
	local height = 70 + self.Heading:GetStringHeight() + 10 + self.Notes:GetStringHeight() + 60

	local image, imageHeight = release.image, 0
	self.Image:SetShown(image ~= nil)
	if image then
		self.Image:SetTexture(core:Artwork(image.file))
		-- a texture without anchors in XML fills its parent: clear that before placing it
		self.Image:ClearAllPoints()
		self.Image:SetPoint("TOP", self.Notes, "BOTTOM", 0, -12)
		self.Image:SetSize(image.width, image.height)
		self.Image:SetTexCoord(unpack(image.texCoord or {0, 1, 0, 1}))
		imageHeight = 12 + image.height
		height = height + imageHeight
	end

	local showGorloc = core:GetConsumablesAPI() == nil
	self.Gorloc:SetShown(showGorloc)
	self.Gorloc.Hint:Hide()
	self.Gorloc:SetPoint("TOPLEFT", self.Notes, "BOTTOMLEFT", 0, -14 - imageHeight)
	if showGorloc then
		self.Gorloc:SetHeight(self.Gorloc.Text:GetStringHeight() + 8 + 22 + 22)
		height = height + 14 + self.Gorloc:GetHeight()
	end
	self:SetHeight(height)
	self:Show()
end
