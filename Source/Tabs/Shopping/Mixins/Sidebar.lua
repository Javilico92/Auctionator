Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.Sidebar = Auctionator.Shopping.Sidebar or {}
AuctionatorShopping = AuctionatorShopping or {}

local Sidebar = Auctionator.Shopping.Sidebar
local VISIBLE_ROWS = 11
local ROW_HEIGHT = 22

Sidebar.Frame = Sidebar.Frame or nil
Sidebar.Mode = Sidebar.Mode or "lists"
Sidebar.Entries = Sidebar.Entries or {}
Sidebar.SelectedList = Sidebar.SelectedList or nil

local QUALITY_TOKENS = {
  poor = 0,
  common = 1,
  uncommon = 2,
  rare = 3,
  epic = 4,
  legendary = 5,
}

local function Trim(text)
  text = text or ""
  text = string.gsub(text, "^%s+", "")
  text = string.gsub(text, "%s+$", "")
  return text
end

local function GetExpandedLists()
  AUCTIONATOR_SAVEDVARS = AUCTIONATOR_SAVEDVARS or {}
  AUCTIONATOR_SAVEDVARS.ShoppingExpandedLists = AUCTIONATOR_SAVEDVARS.ShoppingExpandedLists or {}
  return AUCTIONATOR_SAVEDVARS.ShoppingExpandedLists
end

local function IsExpanded(list)
  return list and list.name and GetExpandedLists()[list.name] == true
end

local function SetExpanded(list, expanded)
  if list and list.name then
    GetExpandedLists()[list.name] = expanded and true or nil
  end
end

local function ColorTextForQuality(text, qualityIndex)
  if qualityIndex == nil then return text end

  local r, g, b
  if GetItemQualityColor then
    r, g, b = GetItemQualityColor(qualityIndex)
  elseif ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[qualityIndex] then
    local color = ITEM_QUALITY_COLORS[qualityIndex]
    r, g, b = color.r, color.g, color.b
  end

  if not r or not g or not b then return text end

  return string.format("|cff%02x%02x%02x%s|r",
    math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5), text)
end

local function SplitSemicolonPreserveEmpty(text)
  local values = {}
  local start = 1
  text = text or ""
  while true do
    local position = string.find(text, ";", start, true)
    if not position then
      table.insert(values, string.sub(text, start))
      break
    end
    table.insert(values, string.sub(text, start, position - 1))
    start = position + 1
  end
  return values
end

local function GetSearchDisplayData(searchText)
  local fields = SplitSemicolonPreserveEmpty(searchText)

  -- Auctionator Retail extended-search format. Display only the search term,
  -- while retaining the complete serialized value for search/export.
  if #fields >= 14 then
    local name = Trim(fields[1])
    local qualityField = Trim(fields[11])
    local qualityIndex = tonumber(qualityField)
    if qualityIndex == nil then
      qualityIndex = QUALITY_TOKENS[string.lower(qualityField)]
    end
    if name == "" then name = searchText or "" end
    return ColorTextForQuality(name, qualityIndex), qualityIndex
  end

  -- Native Wrath compact format: Quality;Category;...;Search term
  local first, remainder = string.match(searchText or "", "^([^;]+);(.+)$")
  if not first or not remainder then return searchText or "", nil end

  local qualityIndex = QUALITY_TOKENS[string.lower(Trim(first))]
  if qualityIndex == nil then return searchText or "", nil end

  remainder = Trim(remainder)
  if remainder == "" then return searchText or "", qualityIndex end
  return ColorTextForQuality(remainder, qualityIndex), qualityIndex
end

local function GetRecentsList()
  if not AUCTIONATOR_SHOPPING_LISTS then return nil end

  for index = 1, #AUCTIONATOR_SHOPPING_LISTS do
    local list = AUCTIONATOR_SHOPPING_LISTS[index]
    if list and list.isRecents then return list end
  end

  return AUCTIONATOR_SHOPPING_LISTS[1]
end

local function BuildShoppingListEntries()
  local entries = {}
  if not AUCTIONATOR_SHOPPING_LISTS then return entries end

  for index = 1, #AUCTIONATOR_SHOPPING_LISTS do
    local list = AUCTIONATOR_SHOPPING_LISTS[index]
    if list and not list.isRecents and list.name and list.name ~= "" then
      table.insert(entries, {
        type = "list",
        text = list.name,
        searchText = "{ " .. list.name .. " }",
        list = list,
        listIndex = index,
      })

      if IsExpanded(list) and list.items then
        for itemIndex = 1, #list.items do
          local itemName = list.items[itemIndex]
          if itemName and itemName ~= "" then
            table.insert(entries, {
              type = "item",
              text = (GetSearchDisplayData(itemName)),
              tooltipText = itemName,
              searchText = itemName,
              list = list,
              listIndex = index,
              itemIndex = itemIndex,
            })
          end
        end
      end
    end
  end

  return entries
end

local function BuildRecentEntries()
  local entries = {}
  local recents = GetRecentsList()
  if not recents or not recents.items then return entries end

  for index = 1, #recents.items do
    local value = recents.items[index]
    if value and value ~= "" then
      local displayText, qualityIndex = GetSearchDisplayData(value)
      table.insert(entries, {
        type = "recent",
        text = displayText,
        tooltipText = value,
        searchText = value,
        recentIndex = index,
        qualityIndex = qualityIndex,
        isRecent = true,
      })
    end
  end

  return entries
end

local function CreateIconButton(parent, suffix, texturePath, size)
  local button = CreateFrame("Button", parent:GetName() .. suffix, parent)
  button:SetWidth(size or 18)
  button:SetHeight(size or 18)
  button:EnableMouse(true)

  local texture = button:CreateTexture(nil, "ARTWORK")
  texture:SetTexture(texturePath)
  texture:SetAllPoints(button)
  button.Icon = texture
  return button
end

local function CreateDeleteButton(parent, suffix)
  local button = CreateFrame("Button", parent:GetName() .. suffix, parent)
  button:SetWidth(18)
  button:SetHeight(18)
  button:EnableMouse(true)

  local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  text:SetPoint("CENTER", button, "CENTER", 0, 1)
  text:SetText("x")
  text:SetTextColor(1, 0.2, 0.2)
  button.Label = text

  local highlight = button:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
  highlight:SetBlendMode("ADD")
  highlight:SetAllPoints(button)
  return button
end

local function CreateAddButton(parent, suffix)
  local button = CreateFrame("Button", parent:GetName() .. suffix, parent)
  button:SetWidth(18)
  button:SetHeight(18)
  button:EnableMouse(true)

  local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  text:SetPoint("CENTER", button, "CENTER", 0, 1)
  text:SetText("+")
  text:SetTextColor(0.2, 1, 0.2)
  button.Label = text

  local highlight = button:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
  highlight:SetBlendMode("ADD")
  highlight:SetAllPoints(button)
  return button
end

local function SetupActionButton(button, clickHandler, tooltip)
  button:SetScript("OnClick", function(self)
    clickHandler(self:GetParent())
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltip, 1, 1, 1)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  button:HookScript("OnEnter", function(self)
    if self.Icon then
        self.Icon:SetVertexColor(0.55, 0.55, 0.55)
    end
  end)

  button:HookScript("OnLeave", function(self)
    if self.Icon then
        self.Icon:SetVertexColor(1, 1, 1)
    end
  end)
end

function Sidebar.OnLoad(frame)
  Sidebar.Frame = frame
  local name = frame:GetName()

  frame.ShoppingListsTab = _G[name .. "ShoppingListsTab"]
  frame.RecentSearchesTab = _G[name .. "RecentSearchesTab"]
  frame.Content = _G[name .. "Content"]
  frame.EmptyText = _G[name .. "ContentEmptyText"]
  frame.ScrollFrame = _G[name .. "ScrollFrame"]
  frame.NewListButton = _G[name .. "NewListButton"]
  frame.ImportButton = _G[name .. "ImportButton"]
  frame.ExportButton = _G[name .. "ExportButton"]

  if frame.ExportButton then frame.ExportButton:Disable() end
  frame.Rows = {}

  local baseLevel = frame:GetFrameLevel()
  if AuctionFrame then
    frame:SetFrameStrata(AuctionFrame:GetFrameStrata())
    frame:SetFrameLevel(AuctionFrame:GetFrameLevel() + 20)
    baseLevel = frame:GetFrameLevel()
  end
  if frame.ScrollFrame then frame.ScrollFrame:SetFrameLevel(baseLevel + 1) end

  for index = 1, VISIBLE_ROWS do
    local row = _G[name .. "Row" .. index]
    if row then
      row.Text = _G[row:GetName() .. "Text"]
      row.LegacySearchIcon = _G[row:GetName() .. "SearchIcon"]
      row.LegacyDeleteButton = _G[row:GetName() .. "DeleteButton"]
      if row.LegacySearchIcon then row.LegacySearchIcon:Hide() end
      if row.LegacyDeleteButton then row.LegacyDeleteButton:Hide() end

      row.SearchButton = CreateIconButton(row, "ActionSearch", "Interface\\AddOns\\Auctionator\\Images\\Magnify_Icon", 12)
      row.EditButton = CreateIconButton(row, "ActionEdit", "Interface\\AddOns\\Auctionator\\Images\\Pen_Icon", 12)
      row.RemoveButton = CreateIconButton(row, "ActionRemove", "Interface\\AddOns\\Auctionator\\Images\\Trash_Icon", 12)
      row.AddButton = CreateIconButton(row, "ActionAdd", "Interface\\AddOns\\Auctionator\\Images\\Plus_Icon", 12)

      row.RemoveButton:SetPoint("RIGHT", row, "RIGHT", -4, 0)
      row.EditButton:SetPoint("RIGHT", row.RemoveButton, "LEFT", -4, 0)
      row.SearchButton:SetPoint("RIGHT", row.EditButton, "LEFT", -4, 0)
      row.AddButton:SetPoint("RIGHT", row, "RIGHT", -2, 0)

      SetupActionButton(row.SearchButton, Sidebar.SearchEntry, "Buscar")
      SetupActionButton(row.EditButton, Sidebar.RenameList, "Renombrar lista")
      SetupActionButton(row.RemoveButton, Sidebar.DeleteEntry, "Eliminar")
      SetupActionButton(row.AddButton, Sidebar.AddRecentToSelectedList, "Añadir a la lista seleccionada")

      row:SetFrameLevel(baseLevel + 2)
      row.SearchButton:SetFrameLevel(baseLevel + 3)
      row.EditButton:SetFrameLevel(baseLevel + 3)
      row.RemoveButton:SetFrameLevel(baseLevel + 3)
      row.AddButton:SetFrameLevel(baseLevel + 3)
      frame.Rows[index] = row
    end
  end
end

function Sidebar.OnShow() Sidebar.Refresh() end

function Sidebar.SetMode(mode)
  if mode ~= "lists" and mode ~= "recents" then return end
  Sidebar.Mode = mode

  local frame = Sidebar.Frame
  if frame and frame.ScrollFrame then
    FauxScrollFrame_SetOffset(frame.ScrollFrame, 0)
    frame.ScrollFrame:SetVerticalScroll(0)
  end

  Sidebar.Refresh()
end

local function SelectList(list)
  Sidebar.SelectedList = list
  AuctionatorShopping.SelectedList = list and list.name or nil
  if Auctionator.Shopping.Dialogs then
    Auctionator.Shopping.Dialogs.SetSelectedList(list)
  end
end

function Sidebar.Refresh()
  local frame = Sidebar.Frame
  if not frame then return end

  Sidebar.Entries = Sidebar.Mode == "recents" and BuildRecentEntries() or BuildShoppingListEntries()

  if frame.ShoppingListsTab and frame.RecentSearchesTab then
    if Sidebar.Mode == "lists" then
      frame.ShoppingListsTab:Disable()
      frame.RecentSearchesTab:Enable()
    else
      frame.ShoppingListsTab:Enable()
      frame.RecentSearchesTab:Disable()
    end
  end

  local total = #Sidebar.Entries
  local offset = 0
  if frame.ScrollFrame then
    offset = FauxScrollFrame_GetOffset(frame.ScrollFrame)
    FauxScrollFrame_Update(frame.ScrollFrame, total, VISIBLE_ROWS, ROW_HEIGHT)
  end

  for line = 1, VISIBLE_ROWS do
    local row = frame.Rows[line]
    local entry = Sidebar.Entries[offset + line]

    if row then
      if entry then
        row.Entry = entry
        row:SetID(offset + line)

        local isList = entry.type == "list"
        local isItem = entry.type == "item"
        local isRecent = entry.type == "recent"
        local prefix = ""
        if isList then prefix = IsExpanded(entry.list) and "- " or "+ " end

        if row.Text then
          row.Text:SetText(prefix .. (entry.text or ""))
          row.Text:ClearAllPoints()
          row.Text:SetPoint("LEFT", row, "LEFT", isItem and 20 or 5, 0)
          local rightPadding = isRecent and -24 or (isItem and -40 or -58)
          row.Text:SetPoint("RIGHT", row, "RIGHT", rightPadding, 0)
          if entry.list == Sidebar.SelectedList and isList then
            row.Text:SetTextColor(1, 0.82, 0)
          else
            row.Text:SetTextColor(1, 1, 1)
          end
        end

        row.SearchButton:Show()
        row.RemoveButton:Show()
        row.AddButton:Hide()
        if isList then
          row.EditButton:Show()
        else
          row.EditButton:Hide()
        end

        if isRecent then
          row.SearchButton:Hide()
          row.RemoveButton:Hide()
          row.AddButton:Show()
        end

        row:Show()
      else
        row.Entry = nil
        row.SearchButton:Hide()
        row.EditButton:Hide()
        row.RemoveButton:Hide()
        row.AddButton:Hide()
        row:Hide()
      end
    end
  end

  if frame.EmptyText then
    if total == 0 then
      frame.EmptyText:SetText(Sidebar.Mode == "recents" and "No recent searches" or "No shopping lists")
      frame.EmptyText:Show()
    else
      frame.EmptyText:Hide()
    end
  end
end

local function ExecuteSearch(searchText)
  local shoppingFrame = Auctionator.Shopping.Frame
  if not shoppingFrame or not shoppingFrame.SearchBox then return end

  shoppingFrame.SearchBox:SetText(searchText or "")
  Auctionator.Shopping.Search(shoppingFrame)
  Sidebar.Refresh()
end

function Sidebar.RowOnClick(row)
  if not row or not row.Entry then return end
  local entry = row.Entry

  if entry.type == "recent" then
    ExecuteSearch(entry.searchText or entry.text)
    return
  end

  if entry.type == "list" then
    SelectList(entry.list)
    SetExpanded(entry.list, not IsExpanded(entry.list))
    Sidebar.Refresh()
  end
end

function Sidebar.SearchEntry(row)
  if row and row.Entry then ExecuteSearch(row.Entry.searchText or row.Entry.text) end
end

function Sidebar.AddRecentToSelectedList(row)
  if not row or not row.Entry or row.Entry.type ~= "recent" then return end

  local selectedName = AuctionatorShopping.SelectedList
  if not selectedName or selectedName == "" then
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff4040Auctionator:|r Debes seleccionar primero una Shopping List.")
    end
    return
  end

  local selectedList
  if AUCTIONATOR_SHOPPING_LISTS then
    for index = 1, #AUCTIONATOR_SHOPPING_LISTS do
      local list = AUCTIONATOR_SHOPPING_LISTS[index]
      if list and not list.isRecents and list.name == selectedName then
        selectedList = list
        break
      end
    end
  end

  if not selectedList then
    AuctionatorShopping.SelectedList = nil
    Sidebar.SelectedList = nil
    if DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff4040Auctionator:|r La Shopping List seleccionada ya no existe. Selecciona otra lista.")
    end
    Sidebar.Refresh()
    return
  end

  local itemName = Trim(row.Entry.searchText or row.Entry.tooltipText or row.Entry.text)
  if itemName == "" then return end

  selectedList.items = selectedList.items or {}
  local normalized = string.lower(itemName)
  for index = 1, #selectedList.items do
    if string.lower(Trim(selectedList.items[index])) == normalized then
      if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd200Auctionator:|r '" .. itemName .. "' ya está en la lista '" .. selectedName .. "'.")
      end
      return
    end
  end

  table.insert(selectedList.items, itemName)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cff40ff40Auctionator:|r Añadido '" .. itemName .. "' a la lista '" .. selectedName .. "'.")
  end
  Sidebar.Refresh()
end

function Sidebar.RowOnEnter(row)
  if not row or not row.Entry then return end
  local entry = row.Entry

  GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
  GameTooltip:SetText(entry.tooltipText or entry.text or "", 1, 1, 1)
  if entry.type == "list" and entry.list and entry.list.items then
    local count = #entry.list.items
    GameTooltip:AddLine(count .. (count == 1 and " objeto" or " objetos"), 0.75, 0.75, 0.75)
    GameTooltip:AddLine("Clic para desplegar o contraer", 0.5, 0.8, 1)
  end
  GameTooltip:Show()
end

function Sidebar.RowOnLeave() GameTooltip:Hide() end

function Sidebar.DeleteRecent(row)
  if not row or not row.Entry or not row.Entry.isRecent then return end
  local recents = GetRecentsList()
  if not recents or not recents.items then return end

  local target = row.Entry.searchText
  for index = #recents.items, 1, -1 do
    if recents.items[index] == target then
      table.remove(recents.items, index)
      break
    end
  end
  Sidebar.Refresh()
end

local pendingDeleteEntry
StaticPopupDialogs["AUCTIONATOR_DELETE_SHOPPING_ENTRY"] = {
  text = "¿Eliminar %s?",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
    local entry = pendingDeleteEntry
    pendingDeleteEntry = nil
    if not entry then return end

    if entry.type == "item" and entry.list and entry.list.items then
      table.remove(entry.list.items, entry.itemIndex)
    elseif entry.type == "list" and AUCTIONATOR_SHOPPING_LISTS then
      for index = #AUCTIONATOR_SHOPPING_LISTS, 1, -1 do
        if AUCTIONATOR_SHOPPING_LISTS[index] == entry.list then
          table.remove(AUCTIONATOR_SHOPPING_LISTS, index)
          break
        end
      end
      GetExpandedLists()[entry.list.name] = nil
      if Sidebar.SelectedList == entry.list then
        SelectList(nil)
      end
    end
    Sidebar.Refresh()
  end,
  OnCancel = function() pendingDeleteEntry = nil end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
}

function Sidebar.DeleteEntry(row)
  if not row or not row.Entry then return end
  pendingDeleteEntry = row.Entry
  local label = row.Entry.type == "list"
    and ("la lista '" .. (row.Entry.list.name or "") .. "'")
    or ("el objeto '" .. (row.Entry.text or "") .. "'")
  StaticPopup_Show("AUCTIONATOR_DELETE_SHOPPING_ENTRY", label)
end

local pendingRenameEntry
StaticPopupDialogs["AUCTIONATOR_RENAME_SHOPPING_LIST"] = {
  text = "Nuevo nombre para la lista:",
  button1 = ACCEPT,
  button2 = CANCEL,
  hasEditBox = 1,
  maxLetters = 64,
  OnShow = function(self)
    self.editBox:SetText(pendingRenameEntry and pendingRenameEntry.list.name or "")
    self.editBox:HighlightText()
    self.editBox:SetFocus()
  end,
  OnAccept = function(self)
    local entry = pendingRenameEntry
    pendingRenameEntry = nil
    if not entry or not entry.list then return end

    local newName = Trim(self.editBox:GetText())
    if newName == "" or newName == entry.list.name then return end

    local oldName = entry.list.name
    local wasExpanded = GetExpandedLists()[oldName]
    if Atr_RenameSList and entry.listIndex then
      Atr_RenameSList(entry.listIndex, newName)
    else
      entry.list.name = newName
    end
    GetExpandedLists()[oldName] = nil
    if wasExpanded then GetExpandedLists()[newName] = true end
    if Sidebar.SelectedList == entry.list then
      AuctionatorShopping.SelectedList = newName
    end
    Sidebar.Refresh()
  end,
  EditBoxOnEnterPressed = function(self)
    local parent = self:GetParent()
    if parent and parent.button1 then parent.button1:Click() end
  end,
  EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
  OnCancel = function() pendingRenameEntry = nil end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
}

function Sidebar.RenameList(row)
  if not row or not row.Entry or row.Entry.type ~= "list" then return end
  pendingRenameEntry = row.Entry
  StaticPopup_Show("AUCTIONATOR_RENAME_SHOPPING_LIST")
end

local function GetDialogs()
  return Auctionator and Auctionator.Shopping and Auctionator.Shopping.Dialogs
end

function Sidebar.ShowNewListDialog()
  local dialogs = GetDialogs()
  if dialogs and dialogs.ShowNewList then dialogs.ShowNewList()
  elseif DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("Auctionator: no se pudo cargar el gestor de listas.") end
end

function Sidebar.ShowImportDialog()
  local dialogs = GetDialogs()
  if dialogs and dialogs.ShowImport then dialogs.ShowImport()
  elseif DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("Auctionator: no se pudo cargar el diálogo de importación.") end
end

function Sidebar.ShowExportDialog()
  local dialogs = GetDialogs()
  if dialogs and dialogs.ShowExport then dialogs.ShowExport()
  elseif DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("Auctionator: no se pudo cargar el diálogo de exportación.") end
end
