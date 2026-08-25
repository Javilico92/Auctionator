Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.ResultsListing = Auctionator.Shopping.ResultsListing or {}

local ResultsListing = Auctionator.Shopping.ResultsListing

local L = setmetatable({}, {
  __index = function(_, key)
    if Auctionator and Auctionator.Localize then
      return Auctionator.Localize(key)
    end
    return key
  end,
})
local NIL_VALUE = {}

ResultsListing.Frame = ResultsListing.Frame or nil
ResultsListing.LegacyGlobals = ResultsListing.LegacyGlobals or {}
ResultsListing.BoundGlobalNames = ResultsListing.BoundGlobalNames or {}
ResultsListing.GlobalsBound = ResultsListing.GlobalsBound or false

local function GetObject(name)
  if not name then
    return nil
  end

  return _G[name]
end

local function SaveGlobal(name)
  if ResultsListing.LegacyGlobals[name] ~= nil then
    return
  end

  local value = _G[name]

  if value == nil then
    ResultsListing.LegacyGlobals[name] = NIL_VALUE
  else
    ResultsListing.LegacyGlobals[name] = value
  end

  table.insert(ResultsListing.BoundGlobalNames, name)
end

local function BindGlobal(name, object)
  SaveGlobal(name)
  _G[name] = object
end

local function BindIfPresent(name, object)
  if object then
    BindGlobal(name, object)
  end
end

local function GetValidSelectedAuction()
  if not Atr_IsSelectedTab_Current or not Atr_IsSelectedTab_Current() then
    return nil
  end

  local currentPane = Atr_GetCurrentPane and Atr_GetCurrentPane()
  if not currentPane or not currentPane.activeScan then
    return nil
  end

  local sortedData = currentPane.activeScan.sortedData
  local selectedIndex = tonumber(currentPane.currIndex)

  if not sortedData or not selectedIndex or selectedIndex < 1 or selectedIndex > #sortedData then
    return nil
  end

  local data = sortedData[selectedIndex]
  if not data or data.yours or data.altname or (tonumber(data.buyoutPrice) or 0) <= 0 then
    return nil
  end

  return data
end

function ResultsListing.UpdateBuyButtonState()
  local frame = ResultsListing.Frame
  local button = frame and frame.BuyButton

  if not button then
    return
  end

  button:Disable()

  if GetValidSelectedAuction() then
    button:Enable()
  end
end

local function ResolveListingObjects(frame)
  local frameName = frame:GetName()
  local headingsName = frameName .. "HeadingsBar"

  frame.HeadingsBar = GetObject(headingsName)
  frame.ScrollFrame = GetObject(frameName .. "ScrollFrame")
  frame.Highlight = GetObject(frameName .. "Highlight")
  frame.HighlightButton = GetObject(frameName .. "HighlightButton")
  frame.BuyButton = GetObject(frameName .. "BuyButton")
  frame.LoadMoreButton = GetObject(frameName .. "LoadMoreButton")
  frame.LoadMoreHighlight = GetObject(frameName .. "LoadMoreButtonHighlight")
  frame.LoadingOverlay = GetObject(frameName .. "LoadingOverlay")

  if frame.LoadingOverlay then
    local loadingName = frame.LoadingOverlay:GetName()
    local contentName = loadingName .. "Content"
    local content = GetObject(contentName)

    -- Some Phase 3 layouts place the controls directly inside LoadingOverlay,
    -- while others use a Content child frame. Support both structures so UI
    -- coordinate changes cannot break the page counter or progress bar.
    local controlsPrefix = content and contentName or loadingName

    frame.LoadingOverlay.Content = content
    frame.LoadingOverlay.Title = GetObject(controlsPrefix .. "Title")
    frame.LoadingOverlay.Subtitle = GetObject(controlsPrefix .. "Subtitle")
    frame.LoadingOverlay.SearchText = GetObject(controlsPrefix .. "SearchText")
    frame.LoadingOverlay.PageText = GetObject(controlsPrefix .. "PageText")
    frame.LoadingOverlay.TotalText = GetObject(controlsPrefix .. "TotalText")
    frame.LoadingOverlay.ProgressBar = GetObject(controlsPrefix .. "ProgressBar")
    frame.LoadingOverlay.ProgressFill = GetObject(controlsPrefix .. "ProgressBarFill")
    frame.LoadingOverlay.Dots = {}

    for index = 1, 8 do
      frame.LoadingOverlay.Dots[index] = GetObject(controlsPrefix .. "Dot" .. index)
    end
  end

  frame.Col1Heading = GetObject(headingsName .. "Col1Heading")
  frame.Col3Heading = GetObject(headingsName .. "Col3Heading")
  frame.Col4Heading = GetObject(headingsName .. "Col4Heading")
  frame.BackButton = GetObject(headingsName .. "BackButton")
  frame.SelectedItemButton = GetObject(headingsName .. "SelectedItemButton")
  if frame.SelectedItemButton then
    frame.SelectedItemButton.Icon = GetObject(headingsName .. "SelectedItemButtonIcon")
    frame.SelectedItemButton.NameText = GetObject(headingsName .. "SelectedItemButtonName")
  end
  frame.SaveThisListButton = GetObject(headingsName .. "SaveThisListButton")
  frame.Col1HeadingButton = GetObject(headingsName .. "Col1HeadingButton")
  frame.Col3HeadingButton = GetObject(headingsName .. "Col3HeadingButton")

  if frame.Col1HeadingButton then
    frame.Col1HeadingButtonArrow = GetObject(frame.Col1HeadingButton:GetName() .. "Arrow")
  end

  if frame.Col3HeadingButton then
    frame.Col3HeadingButtonArrow = GetObject(frame.Col3HeadingButton:GetName() .. "Arrow")
  end
end

function ResultsListing.OnLoad(frame)
  ResultsListing.Frame = frame
  frame.Rows = frame.Rows or {}

  frame:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  frame:SetBackdropBorderColor(0.32, 0.32, 0.32, 1)

  ResolveListingObjects(frame)

  -- This container only paints the table. It must never consume clicks meant
  -- for rows or sorting buttons.
  frame:EnableMouse(false)

  -- Do not depend on child OnLoad ordering in the 3.3.5 XML engine.
  local baseLevel = frame:GetFrameLevel()

  if frame.Highlight then
    frame.Highlight:SetFrameLevel(baseLevel + 1)
  end

  -- The legacy drag-and-drop button covers the whole results area. On some
  -- 3.3.5 clients it steals clicks even when rows have a higher frame level.
  -- Keep it hidden and mouse-disabled unless an item is actually on the cursor.
  if frame.HighlightButton then
    frame.HighlightButton:SetFrameLevel(baseLevel + 1)
    frame.HighlightButton:EnableMouse(false)
    frame.HighlightButton:Hide()
  end

  frame:SetScript("OnUpdate", function(self)
    local capture = self.HighlightButton
    if not capture then
      return
    end

    local cursorType = GetCursorInfo()
    local shouldCapture = cursorType == "item"

    if shouldCapture then
      capture:SetFrameLevel(baseLevel + 40)
      capture:EnableMouse(true)
      capture:Show()
    else
      capture:EnableMouse(false)
      capture:Hide()
      capture:SetFrameLevel(baseLevel + 1)

      if self.Highlight then
        self.Highlight:Hide()
      end
    end
  end)

  if frame.ScrollFrame then
    frame.ScrollFrame:SetFrameLevel(baseLevel + 4)
  end

  if frame.HeadingsBar then
    frame.HeadingsBar:SetFrameLevel(baseLevel + 8)
    frame.HeadingsBar:EnableMouse(false)

    local middle = GetObject(frame.HeadingsBar:GetName() .. "Middle")
    if middle then
      middle:SetTexture("Interface\\Buttons\\WHITE8X8")
      middle:SetVertexColor(0.14, 0.14, 0.14, 0.98)
    end

    for _, heading in ipairs({ frame.Col1Heading, frame.Col3Heading, frame.Col4Heading }) do
      if heading then
        heading:SetTextColor(1, 0.82, 0)
      end
    end
  end

  for _, button in ipairs({
    frame.Col1HeadingButton,
    frame.Col3HeadingButton,
    frame.BackButton,
    frame.SelectedItemButton,
    frame.SaveThisListButton,
  }) do
    if button then
      button:SetFrameLevel(baseLevel + 12)
      button:EnableMouse(true)
      button:RegisterForClicks("LeftButtonUp")
    end
  end

  for index = 1, 15 do
    local row = GetObject(frame:GetName() .. "Entry" .. index)

    if row then
      frame.Rows[index] = row
      row:SetFrameLevel(baseLevel + 14)
      row:EnableMouse(true)
      row:RegisterForClicks("LeftButtonUp")

      local rowName = row:GetName()
      row.EntryText = row.EntryText or GetObject(rowName .. "_EntryText")
      row.ItemIcon = row.ItemIcon or GetObject(rowName .. "_ItemIcon")
      row.PerItemText = row.PerItemText or GetObject(rowName .. "_PerItem_Text")
      row.PerItemPrice = row.PerItemPrice or GetObject(rowName .. "_PerItem_Price")
      row.StackPrice = row.StackPrice or GetObject(rowName .. "_StackPrice")
    end
  end

  if frame.BuyButton then
    frame.BuyButton:SetFrameLevel(baseLevel + 16)
    frame.BuyButton:EnableMouse(true)
    frame.BuyButton:Disable()
  end

  if frame.LoadMoreButton then
    frame.LoadMoreButton:SetFrameLevel(baseLevel + 16)
    frame.LoadMoreButton:EnableMouse(true)
  end

  if frame.LoadingOverlay then
    frame.LoadingOverlay:SetFrameLevel(baseLevel + 20)
  end

  -- The selected-item header is a detail-only element. Explicitly reset it
  -- here because dynamically-created frames can retain layout state while the
  -- Auction House is closed and reopened.
  if frame.SelectedItemButton then
    frame.SelectedItemButton:Hide()
    frame.SelectedItemButton.ItemLink = nil
    frame.SelectedItemButton.ItemName = nil
    frame.SelectedItemButton.ItemQuality = nil
  end
end

function ResultsListing.BindLegacyGlobals()
  if ResultsListing.GlobalsBound then
    return true
  end

  local frame = ResultsListing.Frame

  if not frame then
    return false
  end

  BindIfPresent("AuctionatorScrollFrame", frame.ScrollFrame)

  BindIfPresent("Atr_HeadingsBar", frame.HeadingsBar)
  BindIfPresent("Atr_Col1_Heading", frame.Col1Heading)
  BindIfPresent("Atr_Col3_Heading", frame.Col3Heading)
  BindIfPresent("Atr_Col4_Heading", frame.Col4Heading)
  BindIfPresent("Atr_Back_Button", frame.BackButton)
  BindIfPresent("Atr_SaveThisList_Button", frame.SaveThisListButton)
  BindIfPresent("Atr_Col1_Heading_Button", frame.Col1HeadingButton)
  BindIfPresent("Atr_Col3_Heading_Button", frame.Col3HeadingButton)
  BindIfPresent("Atr_Col1_Heading_ButtonArrow", frame.Col1HeadingButtonArrow)
  BindIfPresent("Atr_Col3_Heading_ButtonArrow", frame.Col3HeadingButtonArrow)

  BindIfPresent("Atr_Hilite1", frame.Highlight)
  BindIfPresent("Atr_Hilite1_btn", frame.HighlightButton)
  BindIfPresent("Atr_Buy1_Button", frame.BuyButton)

  for index = 1, 15 do
    local row = frame.Rows[index]

    if row then
      local legacyName = "AuctionatorEntry" .. index

      BindGlobal(legacyName, row)
      BindIfPresent(legacyName .. "_EntryText", row.EntryText)
      BindIfPresent(legacyName .. "_PerItem_Text", row.PerItemText)
      BindIfPresent(legacyName .. "_PerItem_Price", row.PerItemPrice)
      BindIfPresent(legacyName .. "_StackPrice", row.StackPrice)
    end
  end

  ResultsListing.GlobalsBound = true
  return true
end

function ResultsListing.RestoreLegacyGlobals()
  if not ResultsListing.GlobalsBound then
    return
  end

  for _, name in ipairs(ResultsListing.BoundGlobalNames) do
    local value = ResultsListing.LegacyGlobals[name]

    if value == NIL_VALUE then
      _G[name] = nil
    else
      _G[name] = value
    end
  end

  ResultsListing.LegacyGlobals = {}
  ResultsListing.BoundGlobalNames = {}
  ResultsListing.GlobalsBound = false
end

function ResultsListing.HighlightButtonOnLoad(button)
  button:RegisterEvent("NEW_AUCTION_UPDATE")
  button:RegisterForDrag("LeftButton")
end

function ResultsListing.HighlightButtonOnEvent(button, event)
  if event == "NEW_AUCTION_UPDATE" then
    local frame = button:GetParent()

    if frame and frame.Highlight then
      frame.Highlight:Hide()
    end
  end
end

function ResultsListing.HighlightButtonOnEnter(button)
  local cursorType = GetCursorInfo()
  local frame = button:GetParent()

  if cursorType == "item" and frame and frame.Highlight then
    frame.Highlight:Show()
  end
end

function ResultsListing.HighlightButtonOnLeave(button)
  local frame = button:GetParent()

  if frame and frame.Highlight then
    frame.Highlight:Hide()
  end
end
-- Modern row access API. The legacy global bridge remains temporarily for
-- callbacks that still live in Auctionator 8.2.0, but rendering code can now
-- access rows without constructing global frame names.
function ResultsListing.GetRow(index)
  local row

  -- Use the new Shopping rows only while the bridge is active. Sell and More
  -- still use the original rows from Sell.xml during this migration phase.
  if ResultsListing.GlobalsBound and ResultsListing.Frame and ResultsListing.Frame.Rows then
    row = ResultsListing.Frame.Rows[index]
  end

  if not row then
    row = _G["AuctionatorEntry" .. index]
  end

  if row then
    local rowName = row:GetName()
    row.EntryText = row.EntryText or GetObject(rowName .. "_EntryText")
    row.PerItemText = row.PerItemText or GetObject(rowName .. "_PerItem_Text")
    row.PerItemPrice = row.PerItemPrice or GetObject(rowName .. "_PerItem_Price")
    row.StackPrice = row.StackPrice or GetObject(rowName .. "_StackPrice")
  end

  return row
end

function ResultsListing.GetRowParts(index)
  local row = ResultsListing.GetRow(index)

  if not row then
    return nil
  end

  return row,
    row.PerItemPrice,
    row.PerItemText,
    row.EntryText,
    row.StackPrice
end

function ResultsListing.BeginDisplay(viewType, totalCount)
  local provider = Auctionator.Shopping.ResultsDataProvider

  if provider then
    provider:Clear(viewType)
    provider:SetTotalCount(totalCount)
  end
end

function ResultsListing.SetDisplayResult(index, result)
  local provider = Auctionator.Shopping.ResultsDataProvider

  if provider then
    provider:SetResult(index, result)
  end
end



-- Selected item header ----------------------------------------------------
-- Keep the normal search-summary layout untouched. The extra vertical room
-- is applied only while displaying the auctions belonging to one item.
local DETAIL_TABLE_OFFSET = 40
local DETAIL_COLUMNS_OFFSET = 68
local DETAIL_HEADER_OFFSET = -24

local function SetDetailLayout(enabled)
  local frame = ResultsListing.Frame
  if not frame or not frame.ScrollFrame or not frame.HeadingsBar then
    return
  end

  local headingsName = frame.HeadingsBar:GetName()
  local middle = GetObject(headingsName .. "Middle")
  local tableYOffset = enabled and -DETAIL_TABLE_OFFSET or 0
  local columnsYOffset = enabled and -DETAIL_COLUMNS_OFFSET or 0

  -- Move the detail table as one unit. Re-anchor the first row explicitly as
  -- well; on the 3.3.5 XML engine this avoids the rows retaining their old
  -- screen coordinates after ClearAllPoints/SetPoint on the FauxScrollFrame.
  frame.ScrollFrame:ClearAllPoints()
  frame.ScrollFrame:SetPoint("TOPLEFT", frame.HeadingsBar, "BOTTOMLEFT", -6, tableYOffset)

  if frame.Rows and frame.Rows[1] then
    frame.Rows[1]:ClearAllPoints()
    frame.Rows[1]:SetPoint("TOPLEFT", frame.ScrollFrame, "TOPLEFT", 8, 0)

    for index = 2, 15 do
      if frame.Rows[index] and frame.Rows[index - 1] then
        frame.Rows[index]:ClearAllPoints()
        frame.Rows[index]:SetPoint("TOPLEFT", frame.Rows[index - 1], "BOTTOMLEFT", 0, 0)
      end
    end
  end

  if middle then
    middle:ClearAllPoints()
    middle:SetPoint("TOPLEFT", frame.HeadingsBar, "TOPLEFT", 0, columnsYOffset)
  end

  if frame.Col1Heading then
    frame.Col1Heading:ClearAllPoints()
    frame.Col1Heading:SetPoint("LEFT", middle or frame.HeadingsBar, "LEFT", 40, 1)
  end
  if frame.Col3Heading then
    frame.Col3Heading:ClearAllPoints()
    frame.Col3Heading:SetPoint("LEFT", middle or frame.HeadingsBar, "LEFT", 205, 1)
  end
  if frame.Col4Heading then
    frame.Col4Heading:ClearAllPoints()
    frame.Col4Heading:SetPoint("LEFT", middle or frame.HeadingsBar, "LEFT", 500, 1)
  end
  if frame.Col1HeadingButton then
    frame.Col1HeadingButton:ClearAllPoints()
    frame.Col1HeadingButton:SetPoint("TOPLEFT", frame.HeadingsBar, "TOPLEFT", 46, -21 + columnsYOffset)
  end
  if frame.Col3HeadingButton then
    frame.Col3HeadingButton:ClearAllPoints()
    frame.Col3HeadingButton:SetPoint("TOPLEFT", frame.HeadingsBar, "TOPLEFT", 220, -21 + columnsYOffset)
  end

  -- Lower the navigation/object row only in detail view. Previously the table
  -- moved but these controls remained at the very top, making the rows appear
  -- to overlap the selected-item information.
  if frame.BackButton then
    frame.BackButton:ClearAllPoints()
    if enabled then
      frame.BackButton:SetPoint("TOPLEFT", frame.HeadingsBar, "TOPLEFT", 8, DETAIL_HEADER_OFFSET)
    else
      frame.BackButton:SetPoint("TOPLEFT", frame.HeadingsBar, "TOPLEFT", 8, 5)
    end
  end

  if frame.SelectedItemButton and frame.BackButton then
    frame.SelectedItemButton:ClearAllPoints()
    frame.SelectedItemButton:SetPoint("TOPLEFT", frame.BackButton, "TOPRIGHT", 10, enabled and -2 or 3)
  end
end

function ResultsListing.ShowSelectedItemHeader(itemLink, itemName, itemQuality)
  local frame = ResultsListing.Frame
  local button = frame and frame.SelectedItemButton
  if not button then
    return
  end

  -- Never show an empty header. This is especially important when opening the
  -- Auction House: the legacy pane may briefly point at its nil scan.
  if (not itemLink or itemLink == "") and (not itemName or itemName == "") then
    ResultsListing.HideSelectedItemHeader()
    return
  end

  local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemLink or itemName)
  button.ItemLink = link or itemLink
  button.ItemName = name or itemName or ""
  button.ItemQuality = tonumber(quality or itemQuality)

  if button.ItemName == "" then
    ResultsListing.HideSelectedItemHeader()
    return
  end

  if not texture and GetItemIcon then
    texture = GetItemIcon(button.ItemLink or button.ItemName)
  end

  if button.Icon then
    if texture then
      button.Icon:SetTexture(texture)
      button.Icon:Show()
    else
      -- Do not display the red question-mark placeholder while the item cache
      -- is warming up. The name remains usable and the icon appears next time
      -- GetItemInfo has the data.
      button.Icon:SetTexture(nil)
      button.Icon:Hide()
    end
  end

  if button.NameText then
    button.NameText:SetText(button.ItemName)
    local q = button.ItemQuality
    if q then
      local r, g, b = GetItemQualityColor(q)
      button.NameText:SetTextColor(r or 1, g or 1, b or 1)
    else
      button.NameText:SetTextColor(1, 1, 1)
    end
  end

  button:Show()
  SetDetailLayout(true)
end

function ResultsListing.HideSelectedItemHeader()
  local frame = ResultsListing.Frame
  if frame and frame.SelectedItemButton then
    frame.SelectedItemButton:Hide()
    frame.SelectedItemButton.ItemLink = nil
    frame.SelectedItemButton.ItemName = nil
    frame.SelectedItemButton.ItemQuality = nil
    if frame.SelectedItemButton.Icon then
      frame.SelectedItemButton.Icon:SetTexture(nil)
    end
  end
  SetDetailLayout(false)
end

function ResultsListing.SelectedItemOnClick(button)
  local itemName = button and button.ItemName
  if not itemName or itemName == "" then
    return
  end

  -- Change to Blizzard's Browse/Consultar tab first. The tab handler can clear
  -- BrowseName while rebuilding the panel, which made the old implementation
  -- work only intermittently on repeated clicks.
  if AuctionFrameTab1 and AuctionFrameTab_OnClick then
    AuctionFrameTab_OnClick(AuctionFrameTab1)
  elseif AuctionFrame and AuctionFrameTab1 then
    PanelTemplates_SetTab(AuctionFrame, 1)
    if AuctionFrameBrowse then
      AuctionFrameBrowse:Show()
    end
  end

  if BrowseName then
    BrowseName:SetText(itemName)
    BrowseName:SetCursorPosition(0)
  end

  -- Actually submit the Browse search every time, rather than only filling the
  -- edit box. Prefer the Blizzard function and fall back to clicking its button.
  if AuctionFrameBrowse_Search then
    AuctionFrameBrowse_Search()
  elseif BrowseSearchButton and BrowseSearchButton.Click then
    BrowseSearchButton:Click()
  end
end

function ResultsListing.SelectedItemOnEnter(button)
  if button and button.NameText then
    button.NameText:SetTextColor(0.75, 0.75, 0.75)
  end
  if button and button.ItemLink then
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(button.ItemLink)
    GameTooltip:Show()
  end
end

function ResultsListing.SelectedItemOnLeave(button)
  GameTooltip:Hide()
  if not button or not button.NameText then
    return
  end

  local quality = button.ItemQuality
  if not quality and button.ItemLink then
    local _, _, cachedQuality = GetItemInfo(button.ItemLink)
    quality = cachedQuality
  end

  if quality then
    local r, g, b = GetItemQualityColor(quality)
    button.NameText:SetTextColor(r or 1, g or 1, b or 1)
  else
    button.NameText:SetTextColor(1, 1, 1)
  end
end

-- Progressive page loading ------------------------------------------------
function ResultsListing.HideLoadMore()
  local frame = ResultsListing.Frame
  if frame and frame.LoadMoreButton then
    frame.LoadMoreButton:Hide()
  end
end

local function SetLoadMoreText(button, text)
  if not button then
    return
  end

  local label = button.Text
  if not label and button:GetName() then
    label = GetObject(button:GetName() .. "Text")
    button.Text = label
  end

  if label then
    label:SetText(text or "")
  end
end

function ResultsListing.ShowLoadMore(loadedPages, totalPages, totalAuctions)
  local frame = ResultsListing.Frame
  local button = frame and frame.LoadMoreButton
  if not button then
    return
  end

  button.LoadedPages = tonumber(loadedPages) or 1
  button.TotalPages = tonumber(totalPages) or 1
  button.TotalAuctions = tonumber(totalAuctions) or 0
  button:Enable()
  SetLoadMoreText(button, L.LOAD_MORE_RESULTS)
  button:Show()
end

function ResultsListing.LoadMoreOnEnter(button)
  local highlight = button and button.Highlight
  if not highlight and button and button:GetName() then
    highlight = GetObject(button:GetName() .. "Highlight")
    button.Highlight = highlight
  end
  if highlight then
    highlight:Show()
  end
end

function ResultsListing.LoadMoreOnLeave(button)
  local highlight = button and button.Highlight
  if highlight then
    highlight:Hide()
  end
end

function ResultsListing.LoadMoreOnClick(button)
  if Auctionator.Shopping and Auctionator.Shopping.ProgressiveDebug then
    Auctionator.Shopping.ProgressiveDebug("LoadMore button CLICK; button=" .. tostring(button) .. " enabled=" .. tostring(button and button:IsEnabled()))
  end

  if not button or not button:IsEnabled() then
    if Auctionator.Shopping and Auctionator.Shopping.ProgressiveDebug then
      Auctionator.Shopping.ProgressiveDebug("ABORT in OnClick: missing or disabled button")
    end
    return
  end

  button:Disable()
  SetLoadMoreText(button, L.LOADING)
  ResultsListing.LoadMoreOnLeave(button)

  if Auctionator.Shopping and Auctionator.Shopping.LoadMoreResults then
    Auctionator.Shopping.ProgressiveDebug("Calling Shopping.LoadMoreResults")
    Auctionator.Shopping.LoadMoreResults()
  else
    if Auctionator.Shopping and Auctionator.Shopping.ProgressiveDebug then
      Auctionator.Shopping.ProgressiveDebug("ERROR: Shopping.LoadMoreResults is nil")
    end
  end
end

-- Loading spinner ---------------------------------------------------------
-- Eight text dots are faded in sequence. This avoids relying on Retail-only
-- textures and works on the 3.3.5 client.
function ResultsListing.LoadingOnUpdate(overlay, elapsed)
  if overlay.FinishDelay then
    overlay.FinishDelay = overlay.FinishDelay - elapsed

    if overlay.FinishDelay <= 0 then
      overlay.FinishDelay = nil
      overlay:Hide()

      ResultsListing.UpdateBuyButtonState()
    end

    return
  end

  overlay.Elapsed = (overlay.Elapsed or 0) + elapsed

  if overlay.Elapsed < 0.085 then
    return
  end

  overlay.Elapsed = 0
  overlay.ActiveDot = ((overlay.ActiveDot or 0) % 8) + 1

  for index, dot in ipairs(overlay.Dots or {}) do
    if dot then
      local distance = (overlay.ActiveDot - index) % 8
      local alpha

      if distance == 0 then
        alpha = 1
      elseif distance == 1 then
        alpha = 0.75
      elseif distance == 2 then
        alpha = 0.5
      elseif distance == 3 then
        alpha = 0.3
      else
        alpha = 0.15
      end

      dot:SetAlpha(alpha)
    end
  end
end

local function SetProgress(overlay, currentPage, totalPages)
  if not overlay or not overlay.ProgressFill then
    return
  end

  currentPage = tonumber(currentPage) or 0
  totalPages = math.max(tonumber(totalPages) or 1, 1)

  local progress = math.max(0, math.min(currentPage / totalPages, 1))
  local width = math.max(1, math.floor(248 * progress))
  overlay.ProgressFill:SetWidth(width)
end

function ResultsListing.SetLoading(isLoading, searchText)
  local frame = ResultsListing.Frame
  local overlay = frame and frame.LoadingOverlay

  if not overlay then
    return
  end

  if isLoading then
    ResultsListing.HideLoadMore()
    overlay.Elapsed = 0
    overlay.ActiveDot = 0
    overlay.FinishDelay = nil

    if overlay.Title then
      overlay.Title:SetText(L.SHOPPING_SEARCH_TITLE)
    end

    if overlay.Subtitle then
      overlay.Subtitle:SetText(L.SHOPPING_SEARCH_SUBTITLE)
    end

    if overlay.SearchText then
      if searchText and searchText ~= "" then
        overlay.SearchText:SetText(string.format(L.SHOPPING_SEARCHING_FOR, searchText))
      else
        overlay.SearchText:SetText("")
      end
    end

    if overlay.PageText then
      overlay.PageText:SetText(L.SHOPPING_PREPARING_SEARCH)
    end

    if overlay.TotalText then
      overlay.TotalText:SetText("")
    end

    SetProgress(overlay, 0, 1)
    overlay:Show()

    if frame.BuyButton then
      frame.BuyButton:Disable()
    end
  else
    overlay.FinishDelay = nil
    overlay:Hide()

    ResultsListing.UpdateBuyButtonState()
  end
end

function ResultsListing.SetLoadingPage(currentPage, totalPages, totalAuctions)
  local frame = ResultsListing.Frame
  local overlay = frame and frame.LoadingOverlay

  if not overlay or not overlay:IsShown() then
    return
  end

  currentPage = math.max(tonumber(currentPage) or 1, 1)
  totalPages = math.max(tonumber(totalPages) or 1, 1)
  totalAuctions = math.max(tonumber(totalAuctions) or 0, 0)

  if overlay.PageText then
    overlay.PageText:SetFormattedText(L.SHOPPING_PAGE_X_OF_X, currentPage, totalPages)
  end

  if overlay.TotalText then
    if totalAuctions == 1 then
      overlay.TotalText:SetText(L.SHOPPING_ONE_AUCTION_FOUND)
    else
      overlay.TotalText:SetFormattedText(L.SHOPPING_AUCTIONS_FOUND, totalAuctions)
    end
  end

  SetProgress(overlay, currentPage, totalPages)
end

function ResultsListing.FinishLoading(totalAuctions)
  local frame = ResultsListing.Frame
  local overlay = frame and frame.LoadingOverlay

  if not overlay or not overlay:IsShown() then
    ResultsListing.UpdateBuyButtonState()
    return
  end

  totalAuctions = math.max(tonumber(totalAuctions) or 0, 0)
  overlay.FinishDelay = 0.45

  if overlay.Title then
    overlay.Title:SetText(L.SHOPPING_SEARCH_COMPLETE)
  end

  if overlay.Subtitle then
    overlay.Subtitle:SetText(L.SHOPPING_RESULTS_AVAILABLE)
  end

  if overlay.PageText then
    overlay.PageText:SetText("")
  end

  if overlay.TotalText then
    if totalAuctions == 1 then
      overlay.TotalText:SetText(L.SHOPPING_ONE_RESULT_FOUND)
    else
      overlay.TotalText:SetFormattedText(L.SHOPPING_RESULTS_FOUND, totalAuctions)
    end
  end

  SetProgress(overlay, 1, 1)

  for _, dot in ipairs(overlay.Dots or {}) do
    if dot then
      dot:SetAlpha(1)
    end
  end
end

