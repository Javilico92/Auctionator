Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.ResultsListing = Auctionator.Shopping.ResultsListing or {}

local ResultsListing = Auctionator.Shopping.ResultsListing
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

local function ResolveListingObjects(frame)
  local frameName = frame:GetName()
  local headingsName = frameName .. "HeadingsBar"

  frame.HeadingsBar = GetObject(headingsName)
  frame.ScrollFrame = GetObject(frameName .. "ScrollFrame")
  frame.Highlight = GetObject(frameName .. "Highlight")
  frame.HighlightButton = GetObject(frameName .. "HighlightButton")
  frame.BuyButton = GetObject(frameName .. "BuyButton")

  frame.Col1Heading = GetObject(headingsName .. "Col1Heading")
  frame.Col3Heading = GetObject(headingsName .. "Col3Heading")
  frame.Col4Heading = GetObject(headingsName .. "Col4Heading")
  frame.BackButton = GetObject(headingsName .. "BackButton")
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

  ResolveListingObjects(frame)

  -- Do not depend on child OnLoad ordering in the 3.3.5 XML engine.
  local baseLevel = frame:GetFrameLevel()

  -- The drag-and-drop capture button covers the results area. Keep it below
  -- the actual result rows so it does not steal OnEnter/OnLeave from them.
  if frame.Highlight then
    frame.Highlight:SetFrameLevel(baseLevel + 1)
  end

  if frame.HighlightButton then
    frame.HighlightButton:SetFrameLevel(baseLevel + 1)
  end

  if frame.ScrollFrame then
    frame.ScrollFrame:SetFrameLevel(baseLevel + 2)
  end

  if frame.HeadingsBar then
    frame.HeadingsBar:SetFrameLevel(baseLevel + 3)
  end

  for index = 1, 15 do
    local row = GetObject(frame:GetName() .. "Entry" .. index)

    if row then
      frame.Rows[index] = row
      row:SetFrameLevel(baseLevel + 4)

      local rowName = row:GetName()
      row.EntryText = row.EntryText or GetObject(rowName .. "_EntryText")
      row.PerItemText = row.PerItemText or GetObject(rowName .. "_PerItem_Text")
      row.PerItemPrice = row.PerItemPrice or GetObject(rowName .. "_PerItem_Price")
      row.StackPrice = row.StackPrice or GetObject(rowName .. "_StackPrice")
    end
  end

  if frame.BuyButton then
    frame.BuyButton:SetFrameLevel(baseLevel + 5)
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
