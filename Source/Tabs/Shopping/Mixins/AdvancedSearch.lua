Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.AdvancedSearch = Auctionator.Shopping.AdvancedSearch or {}

local AdvancedSearch = Auctionator.Shopping.AdvancedSearch
local DIVIDER = (Auctionator.Constants and Auctionator.Constants.AdvancedSearchDivider) or ";"

local function GetQualityText(qualityIndex, label)
  if qualityIndex == nil then
    return label
  end

  local r, g, b
  if GetItemQualityColor then
    r, g, b = GetItemQualityColor(qualityIndex)
  elseif ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[qualityIndex] then
    local color = ITEM_QUALITY_COLORS[qualityIndex]
    r, g, b = color.r, color.g, color.b
  end

  if not r or not g or not b then
    return label
  end

  return string.format(
    "|cff%02x%02x%02x%s|r",
    math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5),
    label
  )
end

local QUALITY_OPTIONS = {
  { text = "Any quality", token = nil, index = nil },
  { text = _G.ITEM_QUALITY0_DESC or "Poor", token = "Poor", index = 0 },
  { text = _G.ITEM_QUALITY1_DESC or "Common", token = "Common", index = 1 },
  { text = _G.ITEM_QUALITY2_DESC or "Uncommon", token = "Uncommon", index = 2 },
  { text = _G.ITEM_QUALITY3_DESC or "Rare", token = "Rare", index = 3 },
  { text = _G.ITEM_QUALITY4_DESC or "Epic", token = "Epic", index = 4 },
  { text = _G.ITEM_QUALITY5_DESC or "Legendary", token = "Legendary", index = 5 },
}

for _, option in ipairs(QUALITY_OPTIONS) do
  option.displayText = GetQualityText(option.index, option.text)
end

local function Trim(text)
  text = text or ""
  text = string.gsub(text, "^%s+", "")
  text = string.gsub(text, "%s+$", "")
  return text
end

local function SetDropdown(dropdown, text, value)
  dropdown.selectedValue = value
  UIDropDownMenu_SetSelectedValue(dropdown, value)
  UIDropDownMenu_SetText(dropdown, text)
end

local function AddDropdownButton(dropdown, text, value, callback)
  local info = UIDropDownMenu_CreateInfo()
  info.text = text
  info.value = value
  info.func = function(button)
    callback(button.value, button:GetText())
  end
  info.checked = (dropdown.selectedValue == value)
  UIDropDownMenu_AddButton(info)
end

local function CreateLabel(parent, text, x, y)
  local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  label:SetText(text)
  return label
end

local function CreateEditBox(parent, name, width, x, y, numeric)
  local box = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
  box:SetWidth(width)
  box:SetHeight(20)
  box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  box:SetAutoFocus(false)
  if numeric then
    box:SetNumeric(true)
    box:SetMaxLetters(3)
  end
  box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  return box
end

local function RefreshItemLevelVisibility(dialog)
  local classIndex = dialog.classDropdown.selectedValue or 0
  local show = (classIndex == WEAPON or classIndex == ARMOR)
  if show then
    dialog.itemLevelLabel:Show()
    dialog.minItemLevel:Show()
    dialog.maxItemLevel:Show()
    dialog.itemLevelDash:Show()
  else
    dialog.itemLevelLabel:Hide()
    dialog.minItemLevel:Hide()
    dialog.maxItemLevel:Hide()
    dialog.itemLevelDash:Hide()
    dialog.minItemLevel:SetText("")
    dialog.maxItemLevel:SetText("")
  end
end

local function InitializeQuality(dropdown)
  for _, option in ipairs(QUALITY_OPTIONS) do
    AddDropdownButton(dropdown, option.displayText, option.index == nil and -1 or option.index, function(value)
      local selected
      for _, candidate in ipairs(QUALITY_OPTIONS) do
        local candidateValue = candidate.index == nil and -1 or candidate.index
        if candidateValue == value then selected = candidate break end
      end
      dropdown.qualityToken = selected and selected.token or nil
      SetDropdown(dropdown, selected and selected.displayText or "Any quality", value)
    end)
  end
end

local function InitializeClasses(dropdown)
  local dialog = dropdown:GetParent()
  AddDropdownButton(dropdown, "Any category", 0, function(value)
    SetDropdown(dropdown, "Any category", value)
    dialog.subclassDropdown.selectedValue = 0
    SetDropdown(dialog.subclassDropdown, "Any subcategory", 0)
    UIDropDownMenu_Initialize(dialog.subclassDropdown, InitializeSubclasses)
    RefreshItemLevelVisibility(dialog)
  end)

  local classes = Atr_GetAuctionClasses and Atr_GetAuctionClasses() or {}
  for index, className in ipairs(classes) do
    AddDropdownButton(dropdown, className, index, function(value, text)
      SetDropdown(dropdown, text, value)
      dialog.subclassDropdown.selectedValue = 0
      SetDropdown(dialog.subclassDropdown, "Any subcategory", 0)
      UIDropDownMenu_Initialize(dialog.subclassDropdown, InitializeSubclasses)
      RefreshItemLevelVisibility(dialog)
    end)
  end
end

function InitializeSubclasses(dropdown)
  local dialog = dropdown:GetParent()
  AddDropdownButton(dropdown, "Any subcategory", 0, function(value)
    SetDropdown(dropdown, "Any subcategory", value)
  end)

  local classIndex = dialog.classDropdown.selectedValue or 0
  if classIndex <= 0 then return end

  local subclasses = Atr_GetAuctionSubclasses and Atr_GetAuctionSubclasses(classIndex) or {}
  for index, subclassName in ipairs(subclasses) do
    AddDropdownButton(dropdown, subclassName, index, function(value, text)
      SetDropdown(dropdown, text, value)
    end)
  end
end

local function Reset(dialog, preserveText)
  if not preserveText then dialog.searchText:SetText("") end
  dialog.qualityDropdown.qualityToken = nil
  SetDropdown(dialog.qualityDropdown, "Any quality", -1)
  SetDropdown(dialog.classDropdown, "Any category", 0)
  SetDropdown(dialog.subclassDropdown, "Any subcategory", 0)
  dialog.minLevel:SetText("")
  dialog.maxLevel:SetText("")
  dialog.minItemLevel:SetText("")
  dialog.maxItemLevel:SetText("")
  UIDropDownMenu_Initialize(dialog.subclassDropdown, InitializeSubclasses)
  RefreshItemLevelVisibility(dialog)
end

local function SelectQuality(dialog, qualityIndex)
  dialog.qualityDropdown.qualityToken = nil
  SetDropdown(dialog.qualityDropdown, "Any quality", -1)
  if qualityIndex == nil then return end
  for _, option in ipairs(QUALITY_OPTIONS) do
    if option.index == qualityIndex then
      dialog.qualityDropdown.qualityToken = option.token
      SetDropdown(dialog.qualityDropdown, option.displayText, option.index)
      return
    end
  end
end

local function Prefill(dialog, searchText)
  Reset(dialog, false)
  searchText = Trim(searchText)
  if searchText == "" then return end

  if Atr_IsCompoundSearch and Atr_IsCompoundSearch(searchText) then
    local text, classIndex, subclassIndex, minLevel, maxLevel, minItemLevel, maxItemLevel, qualityIndex = Atr_ParseCompoundSearch(searchText)
    dialog.searchText:SetText(text or "")
    SelectQuality(dialog, qualityIndex)

    local classes = Atr_GetAuctionClasses and Atr_GetAuctionClasses() or {}
    classIndex = tonumber(classIndex) or 0
    subclassIndex = tonumber(subclassIndex) or 0
    SetDropdown(dialog.classDropdown, classes[classIndex] or "Any category", classIndex)
    UIDropDownMenu_Initialize(dialog.subclassDropdown, InitializeSubclasses)

    local subclasses = classIndex > 0 and Atr_GetAuctionSubclasses(classIndex) or {}
    SetDropdown(dialog.subclassDropdown, subclasses[subclassIndex] or "Any subcategory", subclassIndex)
    dialog.minLevel:SetText(minLevel or "")
    dialog.maxLevel:SetText(maxLevel or "")
    dialog.minItemLevel:SetText(minItemLevel or "")
    dialog.maxItemLevel:SetText(maxItemLevel or "")
    RefreshItemLevelVisibility(dialog)
  else
    dialog.searchText:SetText(searchText)
  end
end

local function Execute(dialog)
  local qualityToken = dialog.qualityDropdown.qualityToken
  local classIndex = tonumber(dialog.classDropdown.selectedValue) or 0
  local subclassIndex = tonumber(dialog.subclassDropdown.selectedValue) or 0

  local success, searchText
  if Atr_ExecuteAdvancedSearch then
    success, searchText = Atr_ExecuteAdvancedSearch(
      qualityToken,
      classIndex,
      subclassIndex,
      dialog.minLevel:GetNumber(),
      dialog.maxLevel:GetNumber(),
      dialog.minItemLevel:GetNumber(),
      dialog.maxItemLevel:GetNumber(),
      Trim(dialog.searchText:GetText())
    )
  else
    success = false
  end

  if not success then
    dialog.searchText:SetFocus()
    return
  end

  local frame = Auctionator.Shopping.Frame
  if frame and frame.SearchBox then
    frame.SearchBox:SetText(searchText or "")
  end

  dialog:Hide()
end

function AdvancedSearch.OnLoad(dialog)
  if not dialog or dialog.initialized then return end
  dialog.initialized = true

  dialog:SetWidth(500)
  dialog:SetHeight(330)
  dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
  dialog:SetFrameStrata("FULLSCREEN_DIALOG")
  dialog:EnableMouse(true)
  dialog:SetClampedToScreen(true)
  dialog:Hide()

  local background = dialog:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints(dialog)
  background:SetTexture(0.05, 0.05, 0.05, 0.96)

  local border = CreateFrame("Frame", nil, dialog)
  border:SetAllPoints(dialog)
  border:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })

  local title = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOP", dialog, "TOP", 0, -18)
  title:SetText("Advanced Search")

  CreateLabel(dialog, "Search for", 35, -55)
  dialog.searchText = CreateEditBox(dialog, "AuctionatorShoppingAdvancedSearchText", 250, 35, -73, false)

  CreateLabel(dialog, "Quality", 325, -55)
  dialog.qualityDropdown = CreateFrame("Frame", "AuctionatorShoppingAdvancedQuality", dialog, "UIDropDownMenuTemplate")
  dialog.qualityDropdown:SetPoint("TOPLEFT", dialog, "TOPLEFT", 305, -68)
  UIDropDownMenu_SetWidth(dialog.qualityDropdown, 130)
  UIDropDownMenu_Initialize(dialog.qualityDropdown, InitializeQuality)

  CreateLabel(dialog, "Category", 35, -115)
  dialog.classDropdown = CreateFrame("Frame", "AuctionatorShoppingAdvancedClass", dialog, "UIDropDownMenuTemplate")
  dialog.classDropdown:SetPoint("TOPLEFT", dialog, "TOPLEFT", 15, -128)
  UIDropDownMenu_SetWidth(dialog.classDropdown, 180)
  UIDropDownMenu_Initialize(dialog.classDropdown, InitializeClasses)

  CreateLabel(dialog, "Subcategory", 270, -115)
  dialog.subclassDropdown = CreateFrame("Frame", "AuctionatorShoppingAdvancedSubclass", dialog, "UIDropDownMenuTemplate")
  dialog.subclassDropdown:SetPoint("TOPLEFT", dialog, "TOPLEFT", 250, -128)
  UIDropDownMenu_SetWidth(dialog.subclassDropdown, 180)
  UIDropDownMenu_Initialize(dialog.subclassDropdown, InitializeSubclasses)

  CreateLabel(dialog, "Required level", 35, -185)
  dialog.minLevel = CreateEditBox(dialog, "AuctionatorShoppingAdvancedMinLevel", 45, 40, -207, true)
  dialog.levelDash = dialog:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  dialog.levelDash:SetPoint("LEFT", dialog.minLevel, "RIGHT", 9, 0)
  dialog.levelDash:SetText("-")
  dialog.maxLevel = CreateEditBox(dialog, "AuctionatorShoppingAdvancedMaxLevel", 45, 115, -207, true)

  dialog.itemLevelLabel = CreateLabel(dialog, "Item level", 270, -185)
  dialog.minItemLevel = CreateEditBox(dialog, "AuctionatorShoppingAdvancedMinItemLevel", 45, 275, -207, true)
  dialog.itemLevelDash = dialog:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  dialog.itemLevelDash:SetPoint("LEFT", dialog.minItemLevel, "RIGHT", 9, 0)
  dialog.itemLevelDash:SetText("-")
  dialog.maxItemLevel = CreateEditBox(dialog, "AuctionatorShoppingAdvancedMaxItemLevel", 45, 350, -207, true)

  local reset = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
  reset:SetWidth(85); reset:SetHeight(22)
  reset:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 28, 25)
  reset:SetText("Reset")
  reset:SetScript("OnClick", function() Reset(dialog, false) dialog.searchText:SetFocus() end)

  local cancel = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
  cancel:SetWidth(90); cancel:SetHeight(22)
  cancel:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -25, 25)
  cancel:SetText("Cancel")
  cancel:SetScript("OnClick", function() dialog:Hide() end)

  local search = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
  search:SetWidth(90); search:SetHeight(22)
  search:SetPoint("RIGHT", cancel, "LEFT", -10, 0)
  search:SetText("Search")
  search:SetScript("OnClick", function() Execute(dialog) end)

  dialog.searchText:SetScript("OnEnterPressed", function() Execute(dialog) end)
  dialog:SetScript("OnHide", function() dialog.searchText:ClearFocus() end)

  Reset(dialog, false)
  AdvancedSearch.Dialog = dialog
end

function AdvancedSearch.Show(searchText)
  local dialog = _G.AuctionatorShoppingAdvancedSearchDialog or AdvancedSearch.Dialog
  if not dialog then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000<Auctionator>|r AdvancedSearch.xml was not loaded.")
    end
    return
  end

  if not dialog.initialized then
    AdvancedSearch.OnLoad(dialog)
  end

  Prefill(dialog, searchText)
  dialog:Show()
  dialog.searchText:SetFocus()
  dialog.searchText:HighlightText()
end
