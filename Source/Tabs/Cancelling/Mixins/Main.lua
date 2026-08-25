-- Cancelling tab for the Wrath 3.3.5 Auctionator port.
-- This module owns the complete active-auctions interface and its price-check
-- queue. The legacy "More..." panel is no longer used by this tab.

Auctionator = Auctionator or {}
Auctionator.Tabs = Auctionator.Tabs or {}
Auctionator.Tabs.Cancelling = Auctionator.Tabs.Cancelling or {}

local Cancelling = Auctionator.Tabs.Cancelling

local PANEL_WIDTH = 805
local PANEL_HEIGHT = 352
local ROW_HEIGHT = 22
local VISIBLE_ROWS = 11
local TABLE_WIDTH = 783

-- Resolve strings at runtime because this module is loaded before the locale
-- manifest in the 3.3.5 TOC. This proxy uses the modern L["KEY"] table once
-- AuctionatorLocalize.lua has initialized it.
local L = setmetatable({}, {
  __index = function(_, key)
    if Auctionator and Auctionator.Localize then
      return Auctionator.Localize(key)
    end
    return key
  end,
})

local function GetTimeLeftText(index)
  local values = {
    [1] = _G.AUCTION_TIME_LEFT1 or L.TIME_LEFT_VERY_SHORT,
    [2] = _G.AUCTION_TIME_LEFT2 or L.TIME_LEFT_SHORT,
    [3] = _G.AUCTION_TIME_LEFT3 or L.TIME_LEFT_LONG,
    [4] = _G.AUCTION_TIME_LEFT4 or L.TIME_LEFT_VERY_LONG,
  }
  return values[index] or "—"
end

local function Hide(frame)
  if frame then frame:Hide() end
end

local function Normalize(text)
  text = tostring(text or "")
  if strlower then return strlower(text) end
  return string.lower(text)
end

local function Contains(text, query)
  if query == "" then return true end
  return string.find(Normalize(text), query, 1, true) ~= nil
end

local function CreateText(parent, template, justify)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
  text:SetJustifyH(justify or "LEFT")
  text:SetJustifyV("MIDDLE")
  return text
end

local function CreateColumnText(parent, x, width, justify)
  local text = CreateText(parent, "GameFontHighlightSmall", justify)
  text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, 0)
  text:SetWidth(width)
  text:SetHeight(ROW_HEIGHT)
  return text
end

local function FormatMoney(value)
  value = math.max(0, math.floor((tonumber(value) or 0) + 0.5))

  local gold = math.floor(value / 10000)
  local silver = math.floor((value % 10000) / 100)
  local copper = value % 100

  if gold > 0 then
    return string.format(
      "%d|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t %02d|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t %02d|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t",
      gold, silver, copper
    )
  elseif silver > 0 then
    return string.format(
      "%d|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t %02d|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t",
      silver, copper
    )
  end

  return string.format(
    "%d|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t",
    copper
  )
end

local function GetOwnerAuctionCount()
  if Atr_GetNumAuctionItems then
    return Atr_GetNumAuctionItems("owner") or 0
  end
  if GetNumAuctionItems then
    return GetNumAuctionItems("owner") or 0
  end
  return 0
end

local function GetIDString(itemLink, itemName)
  if itemLink and Auctionator.ItemLink and Auctionator.ItemLink.new then
    local ok, value = pcall(function()
      return Auctionator.ItemLink:new({ item_link = itemLink }):IdString()
    end)
    if ok and value then return value end
  end
  return itemLink or itemName or ""
end

function Cancelling:Initialize()
  if self.Frame or not AuctionFrame or not Atr_Main_Panel then
    return self.Frame
  end

  self.Data = {}
  self.FilteredData = {}
  self.Rows = {}
  self.TotalValue = 0
  self.TotalAuctions = 0
  self.CheckQueue = {}
  self.CheckIndex = 0
  self.Checking = false
  self.AutoCheckPending = false

  local frame = CreateFrame("Frame", "Atr_CancellingFrame", AuctionFrame)
  frame:SetFrameStrata("HIGH")
  frame:SetFrameLevel((Atr_Main_Panel:GetFrameLevel() or 1) + 10)
  frame:SetPoint("TOPLEFT", Atr_Main_Panel, "TOPLEFT", -198, -62)
  frame:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  frame:SetBackdropColor(0.018, 0.018, 0.018, 1)
  frame:SetBackdropBorderColor(0.32, 0.32, 0.32, 1)
  frame:EnableMouse(true)
  frame:Hide()
  self.Frame = frame

  local searchLabel = CreateText(frame, "GameFontNormalSmall", "LEFT")
  searchLabel:SetText(L.SEARCH_COLON)
  searchLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -11)
  searchLabel:SetSize(52, 20)

  local searchBox = CreateFrame("EditBox", "Atr_CancellingSearchBox", frame, "InputBoxTemplate")
  searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 2, 0)
  searchBox:SetSize(245, 20)
  searchBox:SetAutoFocus(false)
  searchBox:SetMaxLetters(80)
  searchBox:SetScript("OnTextChanged", function()
    Cancelling:ApplyFilter()
  end)
  searchBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  searchBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
  end)
  self.SearchBox = searchBox

  local totalLabel = CreateText(frame, "GameFontNormalSmall", "LEFT")
  totalLabel:SetText(L.TOTAL_VALUE)
  totalLabel:SetPoint("LEFT", searchBox, "RIGHT", 18, 0)
  totalLabel:SetSize(78, 20)

  local totalValue = CreateText(frame, "GameFontHighlightSmall", "LEFT")
  totalValue:SetPoint("LEFT", totalLabel, "RIGHT", 3, 0)
  totalValue:SetSize(205, 20)
  self.TotalValueText = totalValue

  local checkButton = CreateFrame("Button", "Atr_CancellingCheckPricesButton", frame, "UIPanelButtonTemplate")
  checkButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -8)
  checkButton:SetSize(135, 22)
  checkButton:SetText(L.CANCELLING_CHECK_PRICES)
  checkButton:SetScript("OnClick", function()
    Cancelling:TogglePriceCheck()
  end)
  self.CheckButton = checkButton

  local header = CreateFrame("Frame", nil, frame)
  header:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
  header:SetSize(TABLE_WIDTH, 22)
  local headerBackground = header:CreateTexture(nil, "BACKGROUND")
  headerBackground:SetAllPoints(header)
  headerBackground:SetTexture(0.14, 0.14, 0.14, 0.96)

  local columns = {
    { L.RESULTS_NAME_COLUMN, 28, 248, "LEFT" },
    { L.QUANTITY, 276, 120, "CENTER" },
    { L.UNIT_PRICE, 396, 135, "RIGHT" },
    { L.TIME_LEFT, 536, 100, "CENTER" },
    { L.IS_UNDERCUT, 636, 72, "CENTER" },
    { L.ITEMS_AHEAD, 708, 62, "CENTER" },
  }

  for i = 1, #columns do
    local column = columns[i]
    local heading = CreateText(header, "GameFontNormalSmall", column[4])
    heading:SetText(column[1])
    heading:SetPoint("TOPLEFT", header, "TOPLEFT", column[2], 0)
    heading:SetSize(column[3], 22)
  end

  local rowArea = CreateFrame("Frame", nil, frame)
  rowArea:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
  rowArea:SetSize(TABLE_WIDTH, ROW_HEIGHT * VISIBLE_ROWS)
  local rowBackground = rowArea:CreateTexture(nil, "BACKGROUND")
  rowBackground:SetAllPoints(rowArea)
  rowBackground:SetTexture(0.045, 0.045, 0.045, 0.97)
  self.RowArea = rowArea

  local scrollFrame = CreateFrame(
    "ScrollFrame",
    "Atr_CancellingScrollFrame",
    frame,
    "FauxScrollFrameTemplate"
  )
  scrollFrame:SetPoint("TOPLEFT", rowArea, "TOPLEFT", 0, 0)
  scrollFrame:SetPoint("BOTTOMRIGHT", rowArea, "BOTTOMRIGHT", 0, 0)
  scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function()
      Cancelling:UpdateRows()
    end)
  end)
  self.ScrollFrame = scrollFrame

  for i = 1, VISIBLE_ROWS do
    local row = CreateFrame("Button", "Atr_CancellingRow" .. i, rowArea)
    row:SetPoint("TOPLEFT", rowArea, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
    row:SetSize(TABLE_WIDTH - 20, ROW_HEIGHT)

    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetAllPoints(row)
    if i % 2 == 0 then
      stripe:SetTexture(0.12, 0.12, 0.12, 0.28)
    else
      stripe:SetTexture(0, 0, 0, 0.08)
    end

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(row)
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")

    row.Icon = row:CreateTexture(nil, "ARTWORK")
    row.Icon:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.Icon:SetSize(18, 18)
    row.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    row.Name = CreateColumnText(row, 28, 248, "LEFT")
    row.Quantity = CreateColumnText(row, 276, 120, "CENTER")
    row.UnitPrice = CreateColumnText(row, 396, 135, "RIGHT")
    row.TimeLeft = CreateColumnText(row, 536, 100, "CENTER")
    row.Undercut = CreateColumnText(row, 636, 72, "CENTER")
    row.Ahead = CreateColumnText(row, 708, 42, "CENTER")

    row:SetScript("OnEnter", function(self)
      local entry = self.Entry
      if not entry or not entry.link then return end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetHyperlink(entry.link)
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(
        string.format(
          "%d %s %s %d",
          entry.auctionCount,
          entry.auctionCount == 1 and L.CANCELLING_PACK or L.CANCELLING_PACKS,
          L.CANCELLING_OF,
          entry.stackSize
        ),
        0.85, 0.85, 0.85
      )
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
      if self.Entry and self.Entry.link and IsShiftKeyDown() and ChatEdit_InsertLink then
        ChatEdit_InsertLink(self.Entry.link)
      end
    end)

    self.Rows[i] = row
  end

  local emptyText = CreateText(frame, "GameFontNormal", "CENTER")
  emptyText:SetPoint("CENTER", rowArea, "CENTER", -8, 0)
  emptyText:SetSize(520, 40)
  emptyText:SetTextColor(0.72, 0.72, 0.72)
  self.EmptyText = emptyText

  local summary = CreateText(frame, "GameFontHighlightSmall", "LEFT")
  summary:SetPoint("TOPLEFT", rowArea, "BOTTOMLEFT", 2, -8)
  summary:SetSize(390, 18)
  summary:SetTextColor(0.68, 0.68, 0.68)
  self.SummaryText = summary

  local status = CreateText(frame, "GameFontHighlightSmall", "RIGHT")
  status:SetPoint("TOPRIGHT", rowArea, "BOTTOMRIGHT", -10, -8)
  status:SetSize(280, 18)
  status:SetTextColor(0.75, 0.75, 0.75)
  self.StatusText = status

  local closeButton = CreateFrame("Button", "Atr_CancellingCloseButton", frame, "UIPanelButtonTemplate")
  closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 10)
  closeButton:SetSize(90, 22)
  closeButton:SetText(_G.CLOSE or (spanish and "Cerrar" or "Close"))
  closeButton:SetScript("OnClick", function()
    if CloseAuctionHouse then CloseAuctionHouse() end
  end)
  self.CloseButton = closeButton

  local timer = CreateFrame("Frame")
  timer:Hide()
  timer:SetScript("OnUpdate", function(self, elapsed)
    self.Remaining = (self.Remaining or 0) - (elapsed or 0)
    if self.Remaining <= 0 then
      self:Hide()
      Cancelling:StartNextPriceCheck()
    end
  end)
  self.TimerFrame = timer

  return frame
end

function Cancelling:HideLegacyUI()
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
  for i = 1, #frames do Hide(frames[i]) end
end

function Cancelling:IsShown()
  return self.Frame and self.Frame:IsShown()
end

function Cancelling:Show()
  if not self.Frame then self:Initialize() end
  if not self.Frame then return end

  self:HideLegacyUI()
  self.Frame:Show()

  -- Opening the tab should immediately check all active auctions.  The owner
  -- list can occasionally arrive one event later, so keep the request pending
  -- until AUCTION_OWNED_LIST_UPDATE provides the data.
  self.AutoCheckPending = true
  self:Refresh()
  self:TryStartAutomaticPriceCheck()
end

function Cancelling:Hide()
  self.AutoCheckPending = false
  if self.Checking then
    self:StopPriceCheck(false)
  end
  if self.Frame then self.Frame:Hide() end
end

function Cancelling:BuildData()
  local grouped = {}
  local totalValue = 0
  local totalAuctions = 0
  local count = GetOwnerAuctionCount()

  for index = 1, count do
    -- Wrath 3.3.5 returns 13 values here.  Unlike newer clients there is no
    -- level-column-header value, so buyoutPrice is return value 9 (not 10).
    local name, texture, stackSize, quality, _, _, minimumBid, _, buyoutPrice, _, _, _, saleStatus =
      GetAuctionItemInfo("owner", index)

    stackSize = tonumber(stackSize) or 0
    minimumBid = tonumber(minimumBid) or 0
    buyoutPrice = tonumber(buyoutPrice) or 0

    if name and stackSize > 0 and (saleStatus == nil or saleStatus == 0) then
      local link = GetAuctionItemLink("owner", index)
      local idString = GetIDString(link, name)
      local timeLeft = GetAuctionItemTimeLeft and GetAuctionItemTimeLeft("owner", index) or 0
      local listingPrice = buyoutPrice > 0 and buyoutPrice or minimumBid
      local unitPrice = math.floor(listingPrice / stackSize)
      local key = table.concat({ idString, stackSize, listingPrice, timeLeft or 0 }, "|")
      local entry = grouped[key]

      if not entry then
        entry = {
          key = key,
          idString = idString,
          name = name,
          link = link,
          texture = texture,
          quality = quality,
          stackSize = stackSize,
          auctionCount = 0,
          listingPrice = listingPrice,
          unitPrice = unitPrice,
          timeLeft = timeLeft or 0,
        }
        grouped[key] = entry
      end

      entry.auctionCount = entry.auctionCount + 1
      totalAuctions = totalAuctions + 1
      totalValue = totalValue + listingPrice
    end
  end

  local data = {}
  for _, entry in pairs(grouped) do
    table.insert(data, entry)
  end

  table.sort(data, function(left, right)
    local leftName = Normalize(left.name)
    local rightName = Normalize(right.name)
    if leftName ~= rightName then return leftName < rightName end
    if left.unitPrice ~= right.unitPrice then return left.unitPrice < right.unitPrice end
    if left.stackSize ~= right.stackSize then return left.stackSize < right.stackSize end
    return left.timeLeft < right.timeLeft
  end)

  self.Data = data
  self.TotalValue = totalValue
  self.TotalAuctions = totalAuctions

  if self.TotalValueText then
    self.TotalValueText:SetText(FormatMoney(totalValue))
  end
end

function Cancelling:GetPriceStatus(entry)
  if not entry or not entry.idString or not Atr_FindScan then return nil, nil end

  local scan = Atr_FindScan(entry.idString)
  if not scan or not scan.whenScanned or scan.whenScanned == 0 or not scan.sortedData then
    return nil, nil
  end

  local cheaperItems = 0
  for index = 1, #scan.sortedData do
    local data = scan.sortedData[index]
    if data and not data.yours and data.itemPrice and data.itemPrice > 0 and data.itemPrice < entry.unitPrice then
      cheaperItems = cheaperItems + ((tonumber(data.count) or 1) * (tonumber(data.stackSize) or 1))
    end
  end

  return cheaperItems > 0, cheaperItems
end

function Cancelling:ApplyFilter()
  if not self.Frame then return end

  local query = self.SearchBox and Normalize(self.SearchBox:GetText()) or ""
  local filtered = {}

  for index = 1, #self.Data do
    local entry = self.Data[index]
    if Contains(entry.name, query) then
      table.insert(filtered, entry)
    end
  end

  self.FilteredData = filtered

  if self.ScrollFrame then
    FauxScrollFrame_SetOffset(self.ScrollFrame, 0)
    local scrollBar = _G[self.ScrollFrame:GetName() .. "ScrollBar"]
    if scrollBar then scrollBar:SetValue(0) end
  end

  self:UpdateRows()
end

function Cancelling:UpdateRows()
  if not self.Frame then return end

  local totalRows = #self.FilteredData
  local offset = 0

  if self.ScrollFrame then
    FauxScrollFrame_Update(self.ScrollFrame, totalRows, VISIBLE_ROWS, ROW_HEIGHT)
    offset = FauxScrollFrame_GetOffset(self.ScrollFrame)
  end

  for visibleIndex = 1, VISIBLE_ROWS do
    local row = self.Rows[visibleIndex]
    local entry = self.FilteredData[offset + visibleIndex]

    if entry then
      row.Entry = entry
      row.Icon:SetTexture(entry.texture)
      row.Icon:Show()
      row.Name:SetText(entry.name)

      local qualityColor = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[entry.quality or 1]
      if qualityColor then
        row.Name:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
      else
        row.Name:SetTextColor(1, 1, 1)
      end

      row.Quantity:SetText(string.format(
        "%d %s %s %d",
        entry.auctionCount,
        entry.auctionCount == 1 and L.CANCELLING_PACK or L.CANCELLING_PACKS,
        L.CANCELLING_OF,
        entry.stackSize
      ))
      row.UnitPrice:SetText(FormatMoney(entry.unitPrice))
      row.TimeLeft:SetText(GetTimeLeftText(entry.timeLeft))

      local undercut, cheaperItems = self:GetPriceStatus(entry)
      if undercut == nil then
        row.Undercut:SetText("—")
        row.Undercut:SetTextColor(0.65, 0.65, 0.65)
        row.Ahead:SetText("—")
        row.Ahead:SetTextColor(0.65, 0.65, 0.65)
      elseif undercut then
        row.Undercut:SetText(L.UNDERCUT_YES)
        row.Undercut:SetTextColor(1, 0.28, 0.28)
        row.Ahead:SetText(tostring(cheaperItems or 0))
        row.Ahead:SetTextColor(1, 0.72, 0.18)
      else
        row.Undercut:SetText(L.UNDERCUT_NO)
        row.Undercut:SetTextColor(0.25, 1, 0.25)
        row.Ahead:SetText("0")
        row.Ahead:SetTextColor(0.25, 1, 0.25)
      end

      row:Show()
    else
      row.Entry = nil
      row.Icon:SetTexture(nil)
      row.Icon:Hide()
      row:Hide()
    end
  end

  if self.EmptyText then
    if #self.Data == 0 then
      self.EmptyText:SetText(L.CANCELLING_NO_AUCTIONS)
      self.EmptyText:Show()
    elseif totalRows == 0 then
      self.EmptyText:SetText(L.CANCELLING_NO_RESULTS)
      self.EmptyText:Show()
    else
      self.EmptyText:Hide()
    end
  end

  if self.SummaryText then
    self.SummaryText:SetText(string.format(L.CANCELLING_SUMMARY, totalRows, self.TotalAuctions or 0))
  end
end

function Cancelling:Refresh()
  if not self.Frame then return end
  self:BuildData()
  self:ApplyFilter()
end

function Cancelling:SetChecking(checking, status)
  self.Checking = checking and true or false

  if self.CheckButton then
    self.CheckButton:SetText(self.Checking and L.STOP or L.CANCELLING_CHECK_PRICES)
  end

  if self.StatusText then
    self.StatusText:SetText(status or "")
  end
end

function Cancelling:BuildCheckQueue()
  local queue = {}
  local seen = {}

  for index = 1, #self.Data do
    local entry = self.Data[index]
    if entry.idString and entry.idString ~= "" and not seen[entry.idString] then
      seen[entry.idString] = true
      table.insert(queue, {
        idString = entry.idString,
        name = entry.name,
        link = entry.link,
      })
    end
  end

  self.CheckQueue = queue
  self.CheckIndex = 0
  self.CurrentCheckID = nil
end

function Cancelling:ScheduleNextPriceCheck(delay)
  if not self.Checking or not self.TimerFrame then return end
  self.TimerFrame.Remaining = delay or 0.12
  self.TimerFrame:Show()
end

function Cancelling:StartNextPriceCheck()
  if not self.Checking then return end

  self.CheckIndex = self.CheckIndex + 1
  local entry = self.CheckQueue[self.CheckIndex]
  if not entry then
    self:FinishPriceCheck()
    return
  end

  local pane = Atr_GetCurrentPane and Atr_GetCurrentPane()
  if not pane or not pane.DoSearch then
    self:StopPriceCheck(true)
    return
  end

  self.CurrentCheckID = entry.idString
  self:SetChecking(true, string.format(L.CANCELLING_CHECKING_X_OF_X, self.CheckIndex, #self.CheckQueue))

  local cacheHit = pane:DoSearch(entry.name, entry.idString, entry.link)
  if cacheHit then
    self:OnSearchComplete()
  end
end

function Cancelling:TryStartAutomaticPriceCheck()
  if not self.AutoCheckPending or not self:IsShown() or self.Checking then
    return
  end

  if (self.TotalAuctions or 0) == 0 then
    return
  end

  self.AutoCheckPending = false
  self:StartPriceCheck(true)
end

function Cancelling:StartPriceCheck(skipRefresh)
  if not skipRefresh then
    self:Refresh()
  end
  if self.TotalAuctions == 0 then return end

  if Atr_ClearScanCache then Atr_ClearScanCache() end

  self:BuildCheckQueue()
  if #self.CheckQueue == 0 then return end

  self:SetChecking(true, string.format(L.CANCELLING_CHECKING_X_OF_X, 1, #self.CheckQueue))
  self:ScheduleNextPriceCheck(0.05)
end

function Cancelling:StopPriceCheck(showStatus)
  if self.TimerFrame then self.TimerFrame:Hide() end

  local pane = Atr_GetCurrentPane and Atr_GetCurrentPane()
  if pane and pane.activeSearch and pane.activeSearch.Abort then
    pane.activeSearch:Abort()
  end

  self.CheckQueue = {}
  self.CheckIndex = 0
  self.CurrentCheckID = nil
  self:SetChecking(false, showStatus and L.CANCELLING_STOPPED or "")
  self:UpdateRows()
end

function Cancelling:FinishPriceCheck()
  if self.TimerFrame then self.TimerFrame:Hide() end
  self.CurrentCheckID = nil
  self:SetChecking(false, L.CANCELLING_COMPLETE)
  self:UpdateRows()
end

function Cancelling:TogglePriceCheck()
  if self.Checking then
    self:StopPriceCheck(true)
  else
    self:StartPriceCheck()
  end
end

function Cancelling:OnSearchComplete()
  if not self:IsShown() then return end

  self:HideLegacyUI()
  self:UpdateRows()

  if not self.Checking then return end

  local pane = Atr_GetCurrentPane and Atr_GetCurrentPane()
  local completedID = pane and pane.activeSearch and pane.activeSearch.IDstring
  if self.CurrentCheckID and completedID and completedID ~= self.CurrentCheckID then
    return
  end

  self:ScheduleNextPriceCheck(0.12)
end

function Cancelling:OnOwnedAuctionsUpdate()
  if self:IsShown() then
    self:Refresh()
    self:HideLegacyUI()
    self:TryStartAutomaticPriceCheck()
  end
end

function Cancelling:OnAuctionHouseClosed()
  self:StopPriceCheck(false)
  self:Hide()
end
