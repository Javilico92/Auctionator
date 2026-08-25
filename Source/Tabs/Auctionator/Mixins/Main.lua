-- Auctionator tab for the Wrath 3.3.5 port.
-- Includes actions for opening Auctionator options and starting scans,
-- plus an information panel showing addon metadata and translation credits.

Auctionator = Auctionator or {}
Auctionator.Tabs = Auctionator.Tabs or {}
Auctionator.Tabs.Auctionator = Auctionator.Tabs.Auctionator or {}

local AuctionatorTab = Auctionator.Tabs.Auctionator

local PANEL_WIDTH = 805
local PANEL_HEIGHT = 386

-- Resolve strings at runtime because this module is loaded before the locale
-- manifest in the 3.3.5 TOC.
local L = setmetatable({}, {
  __index = function(_, key)
    if Auctionator and Auctionator.Localize then
      return Auctionator.Localize(key)
end
    return key
  end,
})

local LOCALE_LABELS = {
  deDE = "Deutsch",
  esES = "Español (España)",
  esMX = "Español (Latinoamérica)",
  frFR = "Français",
  itIT = "Italiano",
  koKR = "한국어",
  ptBR = "Português (Brasil)",
  ruRU = "Русский",
  zhCN = "简体中文",
  zhTW = "繁體中文",
  --roRo = "Romania"
  --trTR = "Türkiye",
}

-- Based on the credits shown in modern Auctionator and the translators
-- the user wants to thank in this 3.3.5 branch.
local TRANSLATION_CREDITS = {
  deDE = { "flow0284", "SunnySunflow" },
  esES = { "sugymaylis", "NuluT", "Franxavis" },
  esMX = { "sugymaylis", "NuluT", "ftg3" },
  frFR = { "Prissti", "Tulsow", "Korthen" },
  itIT = { "faniel80", "nimaus12" },
  koKR = { "Vee", "netaras" },
  ptBR = { "maylisdalan", "Magnuss_Im" },
  ruRU = { "ZamestoTV" },
  zhCN = { "sugymaylis", "LvWind", "枫聖御雷" },
  zhTW = { "RainbowUI", "BNS333" },
  --roRO = { "Radu Ursache" },
  --trTR = { "Serdar Çoban-Hellßringer" },
}

local function Hide(frame)
  if frame then frame:Hide() end
end

local function AddTooltip(button, title, body)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(title, 1, 0.82, 0)
    GameTooltip:AddLine(body, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

local function Trim(text)
  if type(text) ~= "string" then
    return ""
  end

  text = string.gsub(text, "^%s+", "")
  text = string.gsub(text, "%s+$", "")
  return text
end

local function JoinNames(names)
  if type(names) ~= "table" or #names == 0 then
    return "—"
  end

  return table.concat(names, ", ")
end

function AuctionatorTab:GetTitle()
  return L.AUCTIONATOR_TAB
end

function AuctionatorTab:GetAddonMetadata(key)
  if GetAddOnMetadata then
    return GetAddOnMetadata("Auctionator", key)
  end
  return nil
end

function AuctionatorTab:GetAddonAuthor()
  local author = self:GetAddonMetadata("Author")
  if author == nil or author == "" then
    return L.UNKNOWN
  end
  return author
end

function AuctionatorTab:GetAddonVersion()
  local version = self:GetAddonMetadata("Version")
  if version == nil or version == "" then
    return L.UNKNOWN
  end
  return version
end

function AuctionatorTab:GetSupportedLocales()
  local result = {}
  local seen = {}
  local rawLocales = self:GetAddonMetadata("X-Localizations") or ""

  for localeCode in string.gmatch(rawLocales, "([^,]+)") do
    localeCode = Trim(localeCode)

    if localeCode ~= "" and localeCode ~= "enUS" and not seen[localeCode] then
      seen[localeCode] = true
      table.insert(result, localeCode)
    end
  end

  return result
end

function AuctionatorTab:OpenOptions()
  if not InterfaceOptionsFrame_OpenToCategory then
    return
  end

  InterfaceOptionsFrame_OpenToCategory("Auctionator")

  local panel = _G["Atr_BasicOptionsFrame"] or _G["Atr_UIOptionsFrame"]
  if panel then
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)
  else
    InterfaceOptionsFrame_OpenToCategory("Auctionator")
  end
end

function AuctionatorTab:StartScan()
  local forcePageScan = IsShiftKeyDown and IsShiftKeyDown()

  if Atr_StartFullScanFromAuctionatorTab then
    Atr_StartFullScanFromAuctionatorTab(forcePageScan and true or false)
  elseif Atr_ShowFullScanFrame then
    Atr_ShowFullScanFrame()
  end
end

function AuctionatorTab:HideLegacyUI()
  local frames = {
    Atr_Main_Panel,
    Atr_Hlist,
    Atr_Hlist_ScrollFrame,
    Atr_ActiveItems_Text,
    Atr_CheckActiveButton,
    Atr_SellControls,
    Atr_HeadingsBar,
    Atr_ListTabs,
    Atr_Hilite1,
    Atr_Hilite1_btn,
    Atr_Buy1_Button,
    Atr_CancelSelectionButton,
    AuctionatorMessageFrame,
    AuctionatorMessage2Frame,
    Auctionator1Button,
    Atr_FullScanButton,
    AuctionatorCloseButton,
  }

  for i = 1, #frames do
    Hide(frames[i])
  end
end

function AuctionatorTab:CreateSectionHeader(parent, text, anchorPoint, relativeTo, relativePoint, x, y)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  fs:SetPoint(anchorPoint, relativeTo, relativePoint, x, y)
  fs:SetText(text)
  fs:SetTextColor(1, 0.82, 0)
  return fs
end

function AuctionatorTab:CreateInfoValue(parent, width, anchorPoint, relativeTo, relativePoint, x, y)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint(anchorPoint, relativeTo, relativePoint, x, y)
  fs:SetWidth(width)
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("TOP")
  fs:SetTextColor(1, 1, 1)
  return fs
end

function AuctionatorTab:CreateLanguageRows(parent)
  self.LanguageRows = {}

  local locales = self:GetSupportedLocales()
  local rowsPerColumn = 4
  local columnWidth = 250
  local rowHeight = 20
  local rowSpacing = 6
  local startX = 0
  local startY = -10

  for index = 1, #locales do
    local localeCode = locales[index]
    local zeroIndex = index - 1
    local columnIndex = math.floor(zeroIndex / rowsPerColumn)
    local rowIndex = zeroIndex % rowsPerColumn

    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(columnWidth - 8, rowHeight)
    row:EnableMouse(true)
    row.localeCode = localeCode
    row:SetPoint(
      "TOPLEFT",
      parent.TranslationHeader,
      "BOTTOMLEFT",
      startX + (columnIndex * columnWidth),
      startY - (rowIndex * (rowHeight + rowSpacing))
    )

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 14)
    icon:SetPoint("LEFT", row, "LEFT", 0, 0)
    icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\" .. localeCode .. ".tga")

    row:SetScript("OnEnter", function(self)
      local localeName = LOCALE_LABELS[self.localeCode] or self.localeCode
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(localeName, 1, 0.82, 0)
      GameTooltip:AddLine(self.localeCode, 0.75, 0.75, 0.75)
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    local names = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    names:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    names:SetWidth(columnWidth - 40)
    names:SetJustifyH("LEFT")
    names:SetTextColor(1, 1, 1)
    names:SetText(JoinNames(TRANSLATION_CREDITS[localeCode]))

    row.Icon = icon
    row.Names = names

    table.insert(self.LanguageRows, row)
  end
end

function AuctionatorTab:BuildInfoPanel(frame)
  local panel = CreateFrame("Frame", "Atr_AuctionatorInfoPanel", frame)
  panel:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -44)
  panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)

  panel:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  panel:SetBackdropColor(0, 0, 0, 1)
  panel:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)

  -- Fondo adicional completamente opaco. Algunos clientes 3.3.5 no aplican
  -- correctamente el alpha del backdrop cuando el frame está sobre AuctionFrame.
  local solidBackground = panel:CreateTexture(nil, "BACKGROUND")
  solidBackground:SetTexture("Interface\\Buttons\\WHITE8X8")
  solidBackground:SetVertexColor(0, 0, 0, 1)
  solidBackground:SetPoint("TOPLEFT", panel, "TOPLEFT", 3, -3)
  solidBackground:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -3, 3)
  panel.SolidBackground = solidBackground

  self.InfoPanel = panel

  panel.AuthorHeader = self:CreateSectionHeader(panel, L.AUTHOR_HEADER, "TOPLEFT", panel, "TOPLEFT", 16, -18)
  panel.AuthorValue = self:CreateInfoValue(panel, 470, "TOPLEFT", panel.AuthorHeader, "BOTTOMLEFT", 0, -6)
  panel.AuthorValue:SetText(self:GetAddonAuthor())

  panel.VersionHeader = self:CreateSectionHeader(panel, L.VERSION_HEADER, "TOPLEFT", panel, "TOPLEFT", 575, -18)
  panel.VersionValue = self:CreateInfoValue(panel, 110, "TOPLEFT", panel.VersionHeader, "BOTTOMLEFT", 0, -6)
  panel.VersionValue:SetText(self:GetAddonVersion())

  panel.TranslationHeader = self:CreateSectionHeader(panel, L.AVAILABLE_LANGUAGES, "TOPLEFT", panel.AuthorValue, "BOTTOMLEFT", 0, -26)

  self:CreateLanguageRows(panel)
end

function AuctionatorTab:Initialize()
  if self.Frame or not AuctionFrame or not Atr_Main_Panel then
    return self.Frame
  end

  local frame = CreateFrame("Frame", "Atr_AuctionatorFrame", AuctionFrame)
  frame:SetFrameStrata("HIGH")
  frame:SetFrameLevel((Atr_Main_Panel:GetFrameLevel() or 1) + 10)
  frame:SetPoint("TOPLEFT", Atr_Main_Panel, "TOPLEFT", -198, -28)
  frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
  frame:EnableMouse(true)
  frame:Hide()
  self.Frame = frame

  local scanButton = CreateFrame(
    "Button",
    "Atr_AuctionatorFullScanButton",
    frame,
    "UIPanelButtonTemplate"
  )
  scanButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
  scanButton:SetSize(178, 24)
  scanButton:SetText(L.FULL_SCAN)
  scanButton:RegisterForClicks("LeftButtonUp")
  scanButton:SetScript("OnClick", function()
    AuctionatorTab:StartScan()
  end)
  AddTooltip(scanButton, L.FULL_SCAN, L.FULL_SCAN_TOOLTIP_WOTLK)
  self.FullScanButton = scanButton

  local optionsButton = CreateFrame(
    "Button",
    "Atr_AuctionatorOpenOptionsButton",
    frame,
    "UIPanelButtonTemplate"
  )
  optionsButton:SetPoint("RIGHT", scanButton, "LEFT", -10, 0)
  optionsButton:SetSize(258, 24)
  optionsButton:SetText(L.OPEN_ADDON_OPTIONS)
  optionsButton:RegisterForClicks("LeftButtonUp")
  optionsButton:SetScript("OnClick", function()
    AuctionatorTab:OpenOptions()
  end)
  AddTooltip(optionsButton, L.OPEN_ADDON_OPTIONS, L.OPEN_ADDON_OPTIONS_TOOLTIP)
  self.OptionsButton = optionsButton

  self:BuildInfoPanel(frame)

  return frame
end

function AuctionatorTab:IsShown()
  return self.Frame and self.Frame:IsShown()
end

function AuctionatorTab:Show()
  if not self.Frame then
    self:Initialize()
  end
  if not self.Frame then
    return
  end

  self:HideLegacyUI()
  if AuctionatorTitle then
    AuctionatorTitle:SetText("Auctionator - " .. L.AUCTIONATOR_TAB)
    AuctionatorTitle:Show()
  end
  self.Frame:Show()
end

function AuctionatorTab:Hide()
  if self.Frame then
    self.Frame:Hide()
  end
end

function AuctionatorTab:OnAuctionHouseClosed()
  self:Hide()
end
