Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.Dialogs = Auctionator.Shopping.Dialogs or {}

local Dialogs = Auctionator.Shopping.Dialogs
local MAX_ITEMS = ATR_MAXNUM_ITEMS_ON_SHOPPING_LIST or 50
local EXPORT_VISIBLE_ROWS = 12
local EXPORT_ROW_HEIGHT = 22

Dialogs.SelectedList = Dialogs.SelectedList or nil
Dialogs.ExportItems = Dialogs.ExportItems or {}
Dialogs.ExportChecks = Dialogs.ExportChecks or {}

local function Trim(text)
  if strtrim then
    return strtrim(text or "")
  end
  return (text or ""):match("^%s*(.-)%s*$")
end

local function FindList(name)
  if Atr_SList and Atr_SList.FindByName then
    return Atr_SList.FindByName(name, { skipTempList = true })
  end

  if not AUCTIONATOR_SHOPPING_LISTS then
    return nil
  end

  local wanted = string.lower(name or "")
  for _, list in ipairs(AUCTIONATOR_SHOPPING_LISTS) do
    if list and string.lower(list.name or "") == wanted then
      return list
    end
  end
end

local function RefreshSidebar()
  if Auctionator.Shopping.Sidebar and Auctionator.Shopping.Sidebar.Refresh then
    Auctionator.Shopping.Sidebar.Refresh()
  end
end

local function ShowMessage(message)
  if UIErrorsFrame then
    UIErrorsFrame:AddMessage(message, 1, 0.25, 0.25, 1)
  else
    DEFAULT_CHAT_FRAME:AddMessage("Auctionator: " .. message)
  end
end

local function PrepareDialog(frame)
  if not frame then
    return nil
  end

  -- These dialogs are created while Source\Manifest.xml is loaded, before
  -- Auctionator.xml creates AuctionFrame. Therefore their XML parent must be
  -- UIParent. Re-parent and re-anchor them when they are actually opened.
  if AuctionFrame then
    if frame:GetParent() ~= AuctionFrame then
      frame:SetParent(AuctionFrame)
    end
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", AuctionFrame, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(AuctionFrame:GetFrameLevel() + 80)
  else
    frame:SetParent(UIParent)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)
  end

  return frame
end

local function SetDialogLevel(frame)
  PrepareDialog(frame)
end

function Dialogs.SetSelectedList(list)
  Dialogs.SelectedList = list

  local sidebar = Auctionator.Shopping.Sidebar and Auctionator.Shopping.Sidebar.Frame
  if sidebar and sidebar.ExportButton then
    if list and list.items then
      sidebar.ExportButton:Enable()
    else
      sidebar.ExportButton:Disable()
    end
  end
end

function Dialogs.NewListOnLoad(frame)
  Dialogs.NewListFrame = frame
  SetDialogLevel(frame)
  frame.NameBox = _G[frame:GetName() .. "NameBox"]
end

function Dialogs.ShowNewList()
  local frame = PrepareDialog(Dialogs.NewListFrame or _G.AuctionatorShoppingNewListDialog)
  if not frame then
    ShowMessage("No se pudo abrir el diálogo de nueva lista.")
    return
  end
  Dialogs.NewListFrame = frame
  frame.NameBox = frame.NameBox or _G[frame:GetName() .. "NameBox"]

  frame.NameBox:SetText("")
  frame:Show()
  frame.NameBox:SetFocus()
end

function Dialogs.CreateNewList()
  local frame = Dialogs.NewListFrame
  local name = frame and Trim(frame.NameBox:GetText()) or ""

  if name == "" then
    ShowMessage("Escribe un nombre para la lista.")
    return
  end

  if FindList(name) then
    ShowMessage("Ya existe una lista con ese nombre.")
    return
  end

  local list
  if Atr_SList and Atr_SList.create then
    list = Atr_SList.create(name)
  else
    AUCTIONATOR_SHOPPING_LISTS = AUCTIONATOR_SHOPPING_LISTS or {}
    list = { name = name, items = {} }
    table.insert(AUCTIONATOR_SHOPPING_LISTS, list)
  end

  Dialogs.SetSelectedList(list)
  frame:Hide()
  RefreshSidebar()
end

local LARGE_EDIT_LINE_HEIGHT = 14
local LARGE_EDIT_PADDING = 16
local LARGE_EDIT_WHEEL_STEP = 36

local function UpdateLargeEditBoxHeight(editBox)
  if not editBox then
    return
  end

  local scrollFrame = editBox:GetParent()
  if not scrollFrame then
    return
  end

  local visibleHeight = scrollFrame:GetHeight() or 1
  local lineCount = 1
  if editBox.GetNumLines then
    lineCount = editBox:GetNumLines() or 1
  else
    local value = editBox:GetText() or ""
    for _ in string.gmatch(value, "\n") do
      lineCount = lineCount + 1
    end
  end
  local requiredHeight = math.max(visibleHeight, (lineCount * LARGE_EDIT_LINE_HEIGHT) + LARGE_EDIT_PADDING)

  if math.abs((editBox:GetHeight() or 0) - requiredHeight) > 0.5 then
    editBox:SetHeight(requiredHeight)
  end

  local maxScroll = math.max(0, requiredHeight - visibleHeight)
  local currentScroll = scrollFrame:GetVerticalScroll() or 0
  if currentScroll > maxScroll then
    scrollFrame:SetVerticalScroll(maxScroll)
  end

  local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
  if scrollBar then
    scrollBar:SetMinMaxValues(0, maxScroll)
    scrollBar:SetValue(math.min(currentScroll, maxScroll))
    if maxScroll > 0 then
      scrollBar:Show()
    else
      scrollBar:Hide()
    end
  end
end

function Dialogs.LargeEditBoxOnTextChanged(editBox)
  UpdateLargeEditBoxHeight(editBox)
end

function Dialogs.LargeEditBoxOnMouseWheel(scrollFrame, delta)
  if not scrollFrame then
    return
  end

  local editBox = scrollFrame:GetScrollChild()
  UpdateLargeEditBoxHeight(editBox)

  local visibleHeight = scrollFrame:GetHeight() or 1
  local contentHeight = editBox and editBox:GetHeight() or visibleHeight
  local maxScroll = math.max(0, contentHeight - visibleHeight)
  local current = scrollFrame:GetVerticalScroll() or 0
  local nextValue = current - ((delta or 0) * LARGE_EDIT_WHEEL_STEP)
  nextValue = math.max(0, math.min(maxScroll, nextValue))

  scrollFrame:SetVerticalScroll(nextValue)

  local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
  if scrollBar then
    scrollBar:SetValue(nextValue)
  end
end

function Dialogs.LargeEditBoxOnCursorChanged(editBox, x, y, width, height)
  local scrollFrame = editBox and editBox:GetParent()
  if not scrollFrame or not editBox:HasFocus() then
    return
  end

  UpdateLargeEditBoxHeight(editBox)

  local current = scrollFrame:GetVerticalScroll() or 0
  local visibleHeight = scrollFrame:GetHeight() or 1
  local cursorTop = -(y or 0)
  local cursorBottom = cursorTop + (height or LARGE_EDIT_LINE_HEIGHT)
  local nextValue = current

  if cursorTop < current then
    nextValue = cursorTop
  elseif cursorBottom > current + visibleHeight then
    nextValue = cursorBottom - visibleHeight
  end

  local maxScroll = math.max(0, (editBox:GetHeight() or visibleHeight) - visibleHeight)
  nextValue = math.max(0, math.min(maxScroll, nextValue))

  if nextValue ~= current then
    scrollFrame:SetVerticalScroll(nextValue)
    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    if scrollBar then
      scrollBar:SetValue(nextValue)
    end
  end
end

function Dialogs.ResetLargeEditBox(editBox, text)
  if not editBox then
    return
  end

  local scrollFrame = editBox:GetParent()
  editBox:SetText(text or "")
  UpdateLargeEditBoxHeight(editBox)

  if scrollFrame then
    scrollFrame:SetVerticalScroll(0)
    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    if scrollBar then
      scrollBar:SetValue(0)
    end
  end
end

function Dialogs.ImportOnLoad(frame)
  Dialogs.ImportFrame = frame
  SetDialogLevel(frame)
  local name = frame:GetName()
  frame.TextBox = _G[name .. "TextScrollTextBox"]
end

function Dialogs.ShowImport()
  local frame = PrepareDialog(Dialogs.ImportFrame or _G.AuctionatorShoppingImportDialog)
  if not frame then
    ShowMessage("No se pudo abrir el diálogo de importación.")
    return
  end
  Dialogs.ImportFrame = frame
  local frameName = frame:GetName()
  frame.TextBox = frame.TextBox or _G[frameName .. "TextScrollTextBox"]

  Dialogs.ResetLargeEditBox(frame.TextBox, "")
  frame:Show()
  frame.TextBox:SetFocus()
end

local function SplitCaretLine(line)
  local values = {}
  for value in string.gmatch((line or "") .. "^", "(.-)%^") do
    value = Trim(value)
    if value ~= "" then
      table.insert(values, value)
    end
  end
  return values
end

local function CreateImportedList(name, items)
  if name == "" then
    return false, "Hay una línea sin nombre de lista."
  end
  if FindList(name) then
    return false, "Ya existe la lista '" .. name .. "'."
  end
  if #items == 0 then
    return false, "La lista '" .. name .. "' no contiene objetos."
  end
  if #items > MAX_ITEMS then
    return false, "La lista '" .. name .. "' supera el máximo de " .. MAX_ITEMS .. " objetos."
  end

  local list = Atr_SList.create(name)
  for _, itemName in ipairs(items) do
    list:AddItem(itemName)
  end
  return true, list
end

local function ImportCaretLists(text)
  local pending = {}
  text = (text or ""):gsub("\r", "")

  for line in string.gmatch(text .. "\n", "([^\n]*)\n") do
    line = Trim(line)
    if line ~= "" then
      local values = SplitCaretLine(line)
      local name = table.remove(values, 1) or ""
      table.insert(pending, { name = name, items = values })
    end
  end

  if #pending == 0 then
    return false, "Pega primero una lista de objetos."
  end

  -- Validate everything before creating anything, so an invalid second line
  -- does not leave a half-imported batch.
  local seen = {}
  for _, entry in ipairs(pending) do
    local key = string.lower(entry.name or "")
    if entry.name == "" then
      return false, "Hay una línea sin nombre de lista."
    elseif seen[key] then
      return false, "El nombre de lista '" .. entry.name .. "' está repetido en el texto."
    elseif FindList(entry.name) then
      return false, "Ya existe la lista '" .. entry.name .. "'."
    elseif #entry.items == 0 then
      return false, "La lista '" .. entry.name .. "' no contiene objetos."
    elseif #entry.items > MAX_ITEMS then
      return false, "La lista '" .. entry.name .. "' supera el máximo de " .. MAX_ITEMS .. " objetos."
    end
    seen[key] = true
  end

  local lastList
  for _, entry in ipairs(pending) do
    local ok, result = CreateImportedList(entry.name, entry.items)
    if not ok then
      return false, result
    end
    lastList = result
  end

  return true, lastList, #pending
end

local function ImportLegacyText(text)
  local currentList
  local created = 0
  local lastList

  text = (text or ""):gsub("\r", "")
  for line in string.gmatch(text .. "\n", "([^\n]*)\n") do
    line = Trim(line)
    if string.sub(line, 1, 3) == "***" then
      local name = Trim((line:gsub("^%*+", "")))
      if name ~= "" then
        if FindList(name) then
          return false, "Ya existe la lista '" .. name .. "'."
        end
        currentList = Atr_SList.create(name)
        lastList = currentList
        created = created + 1
      end
    elseif line ~= "" and currentList then
      if #currentList.items >= MAX_ITEMS then
        return false, "Una lista puede tener como máximo " .. MAX_ITEMS .. " objetos."
      end
      currentList:AddItem(line)
    end
  end

  if created == 0 then
    return false, "No se ha encontrado ninguna lista válida."
  end
  return true, lastList, created
end

function Dialogs.ImportList()
  local frame = Dialogs.ImportFrame
  if not frame or not frame.TextBox then
    return
  end

  local text = Trim(frame.TextBox:GetText())
  if text == "" then
    ShowMessage("Pega primero una lista de objetos.")
    return
  end

  local ok, lastList, count
  if string.find(text, "***", 1, true) then
    ok, lastList, count = ImportLegacyText(text)
  else
    ok, lastList, count = ImportCaretLists(text)
  end

  if not ok then
    ShowMessage(lastList)
    return
  end

  Dialogs.SetSelectedList(lastList)
  frame:Hide()
  RefreshSidebar()
  ShowMessage((count == 1 and "Lista importada correctamente." or (count .. " listas importadas correctamente.")))
end

local function ConfigureExportCheckTexture(texture, row)
  if not texture then
    return
  end

  texture:ClearAllPoints()
  texture:SetPoint("LEFT", row, "LEFT", 0, 0)
  texture:SetWidth(20)
  texture:SetHeight(20)
end

local function EnsureExportRows(frame)
  if not frame then
    return false
  end

  local name = frame:GetName()
  frame.ListName = frame.ListName or _G[name .. "ListName"]
  frame.ScrollFrame = frame.ScrollFrame or _G[name .. "ScrollFrame"]
  frame.Rows = frame.Rows or {}

  for index = 1, EXPORT_VISIBLE_ROWS do
    local row = frame.Rows[index] or _G[name .. "Row" .. index]

    if not row then
      row = CreateFrame("CheckButton", name .. "Row" .. index, frame, "UICheckButtonTemplate")
      row:SetWidth(350)
      row:SetHeight(EXPORT_ROW_HEIGHT)
      row:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -67 - ((index - 1) * EXPORT_ROW_HEIGHT))
      row:SetHitRectInsets(0, -320, 0, 0)

      ConfigureExportCheckTexture(row:GetNormalTexture(), row)
      ConfigureExportCheckTexture(row:GetCheckedTexture(), row)
      ConfigureExportCheckTexture(row:GetHighlightTexture(), row)
      ConfigureExportCheckTexture(row:GetDisabledCheckedTexture(), row)
      ConfigureExportCheckTexture(row:GetPushedTexture(), row)

      local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      label:SetPoint("LEFT", row, "LEFT", 24, 0)
      label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
      label:SetJustifyH("LEFT")
      row.Label = label

      row:SetScript("OnClick", function(self)
        local item = Dialogs.ExportItems[self.ItemIndex]
        if item then
          item.selected = self:GetChecked() and true or false
        end
      end)
    else
      -- Frames can survive /reload while the Lua table is rebuilt. Restore all
      -- references and texture sizes instead of assuming OnLoad created them.
      ConfigureExportCheckTexture(row:GetNormalTexture(), row)
      ConfigureExportCheckTexture(row:GetCheckedTexture(), row)
      ConfigureExportCheckTexture(row:GetHighlightTexture(), row)
      ConfigureExportCheckTexture(row:GetDisabledCheckedTexture(), row)
      ConfigureExportCheckTexture(row:GetPushedTexture(), row)

      if not row.Label then
        local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        label:SetPoint("LEFT", row, "LEFT", 24, 0)
        label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        row.Label = label
      end
    end

    frame.Rows[index] = row
  end

  return frame.ListName ~= nil and frame.ScrollFrame ~= nil
end

function Dialogs.ExportOnLoad(frame)
  Dialogs.ExportFrame = frame
  SetDialogLevel(frame)
  EnsureExportRows(frame)
end

function Dialogs.ShowExport()
  local list = Dialogs.SelectedList
  local frame = PrepareDialog(Dialogs.ExportFrame or _G.AuctionatorShoppingExportDialog)
  Dialogs.ExportFrame = frame

  if frame then
    EnsureExportRows(frame)
  end

  if not frame or not list or not list.items then
    ShowMessage("Selecciona primero una Shopping List.")
    return
  end

  Dialogs.ExportItems = {}
  for index, itemName in ipairs(list.items) do
    table.insert(Dialogs.ExportItems, {
      name = itemName,
      selected = true,
      originalIndex = index,
    })
  end

  frame.ListName:SetText(list.name or "")
  FauxScrollFrame_SetOffset(frame.ScrollFrame, 0)
  frame.ScrollFrame:SetVerticalScroll(0)
  frame:Show()
  Dialogs.RefreshExportRows()
end

function Dialogs.RefreshExportRows()
  local frame = Dialogs.ExportFrame
  if not frame or not EnsureExportRows(frame) then return end

  local offset = FauxScrollFrame_GetOffset(frame.ScrollFrame)
  FauxScrollFrame_Update(frame.ScrollFrame, #Dialogs.ExportItems, EXPORT_VISIBLE_ROWS, EXPORT_ROW_HEIGHT)

  for line = 1, EXPORT_VISIBLE_ROWS do
    local row = frame.Rows[line]
    local itemIndex = offset + line
    local item = Dialogs.ExportItems[itemIndex]

    if item then
      row.ItemIndex = itemIndex
      row.Label:SetText(item.name)
      row:SetChecked(item.selected)
      row:Show()
    else
      row.ItemIndex = nil
      row:Hide()
    end
  end
end

function Dialogs.SetAllExportSelected(selected)
  for _, item in ipairs(Dialogs.ExportItems) do
    item.selected = selected and true or false
  end
  Dialogs.RefreshExportRows()
end

function Dialogs.BuildExportText()
  local values = {}
  local listName = Dialogs.SelectedList and Trim(Dialogs.SelectedList.name) or ""
  if listName ~= "" then
    table.insert(values, listName)
  end
  for _, item in ipairs(Dialogs.ExportItems) do
    if item.selected then
      table.insert(values, item.name)
    end
  end
  return table.concat(values, "^")
end

function Dialogs.ExportSelected()
  local text = Dialogs.BuildExportText()
  if text == "" then
    ShowMessage("Selecciona al menos un objeto.")
    return
  end

  local frame = PrepareDialog(Dialogs.ExportResultFrame or _G.AuctionatorShoppingExportResultDialog)
  if not frame then
    ShowMessage("No se pudo abrir el resultado de exportación.")
    return
  end
  Dialogs.ExportResultFrame = frame
  frame.TextBox = frame.TextBox or _G[frame:GetName() .. "TextScrollTextBox"]

  Dialogs.ExportFrame:Hide()
  Dialogs.ResetLargeEditBox(frame.TextBox, text)
  frame:Show()
  frame.TextBox:SetFocus()
  frame.TextBox:HighlightText()
end

function Dialogs.ExportResultOnLoad(frame)
  Dialogs.ExportResultFrame = frame
  SetDialogLevel(frame)
  frame.TextBox = _G[frame:GetName() .. "TextScrollTextBox"]
end

function Dialogs.Close(frame)
  if frame then
    frame:Hide()
  end
end
