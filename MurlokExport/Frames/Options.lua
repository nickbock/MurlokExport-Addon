local _, core = ...

local category

OptionsPanelTemplateMixin = {}
function OptionsPanelTemplateMixin:Open()
    Settings.OpenToCategory(category:GetID())
end

function OptionsPanelTemplateMixin:Register()
    category = Settings.RegisterCanvasLayoutCategory(self, MURLOKEXPORT_TITLE)
    Settings.RegisterAddOnCategory(category)
end

-- Our own label next to each check box: the template's Text has no font in current
-- clients, so its labels showed empty.
local function SetLabel(checkBox, text)
    checkBox.Label:SetText(text)
    if checkBox.Text then
        checkBox.Text:SetText("")
    end
end

function OptionsPanelTemplateMixin:OnLoad()
    self.Title:SetText(MURLOKEXPORT_TITLE)
    self.SubText:SetText(MURLOKEXPORT_OPTIONS_SUBTEXT)
    SetLabel(self.CompactViewCheckButton, MURLOKEXPORT_OPTIONS_COMPACT_VIEW)
    SetLabel(self.ShowOnlyCurrentClassCheckButton, MURLOKEXPORT_OPTIONS_SHOW_ONLY_CURRENT_CLASS)
    SetLabel(self.HideMinimapButtonCheckButton, MURLOKEXPORT_OPTIONS_HIDE_MINIMAP_BUTTON)
end

-- The check box handlers run on the check box itself (self). The panel is created
-- before the saved settings are read, so the first OnShow may find no settings yet.
function OptionsPanelTemplateMixin:CompactViewCheckButtonOnShow()
    self:SetChecked(MurlokExportConfig ~= nil and MurlokExportConfig.CompactView)
end

function OptionsPanelTemplateMixin:CompactViewCheckButtonOnClick()
    MurlokExportConfig.CompactView = self:GetChecked()
end

function OptionsPanelTemplateMixin:ShowOnlyCurrentClassCheckButtonOnShow()
    self:SetChecked(MurlokExportConfig ~= nil and MurlokExportConfig.ShowOnlyCurrentClass)
end

function OptionsPanelTemplateMixin:ShowOnlyCurrentClassCheckButtonOnClick()
    MurlokExportConfig.ShowOnlyCurrentClass = self:GetChecked()
end

function OptionsPanelTemplateMixin:HideMinimapButtonCheckButtonOnShow()
    self:SetChecked(MurlokExportConfig ~= nil and MurlokExportConfig.hide)
end

function OptionsPanelTemplateMixin:HideMinimapButtonCheckButtonOnClick()
    MurlokExportConfig.hide = self:GetChecked()
    core.dbIcon:Refresh(MURLOKEXPORT_TITLE, MurlokExportConfig)
end
