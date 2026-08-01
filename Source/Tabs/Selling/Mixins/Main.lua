-- Selling tab UI for the Wrath 3.3.5 Auctionator port.
-- Loaded through Source/Tabs/Selling, matching the modular Source structure.
-- The classic selling backend remains intact; only its controls are reparented.

Auctionator = Auctionator or {}
Auctionator.Tabs = Auctionator.Tabs or {}
Auctionator.Tabs.Selling = Auctionator.Tabs.Selling or {}

local Selling = Auctionator.Tabs.Selling

-- Temporary compatibility alias for any external code created while this panel
-- still lived in the root-level Selling.lua file.
Auctionator.ModernSell = Selling

local function Reanchor(frame, point, relativeTo, relativePoint, x, y)
  if not frame or not relativeTo then return end
  frame:ClearAllPoints()
  frame:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
end

local function MakePanel(name, parent, r, g, b, a)
  local frame = CreateFrame("Frame", name, parent)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  frame:SetBackdropColor(r or 0.035, g or 0.035, b or 0.035, a or 0.96)
  frame:SetBackdropBorderColor(0.32, 0.32, 0.32, 1)
  return frame
end

local function MakeLabel(parent, text, template)
  local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  label:SetText(text or "")
  label:SetJustifyH("LEFT")
  return label
end

local function HideFrame(frame)
  if frame then frame:Hide() end
end

local function RestoreLegacyPanel()
  if not Atr_Main_Panel then return end
  Atr_Main_Panel:SetAlpha(1)
  Atr_Main_Panel:EnableMouse(true)

  -- The active-auctions (More...) view still uses the original panel and its
  -- regions. Restore them whenever the modern Selling tab is left.
  local regions = { Atr_Main_Panel:GetRegions() }
  for _, region in ipairs(regions) do
    if region and region.Show then
      region:Show()
    end
  end

  -- Restore the shared history/active-auctions list to its original legacy
  -- position. The More... tab expects these exact controls and row children.
  if Atr_Hlist then
    Atr_Hlist:SetParent(Atr_Main_Panel)
    Atr_Hlist:ClearAllPoints()
    Atr_Hlist:SetPoint("TOPLEFT", Atr_Main_Panel, "TOPLEFT", -193, -75)
    Atr_Hlist:SetSize(170, 335)
  end
  if Atr_Hlist_ScrollFrame then
    Atr_Hlist_ScrollFrame:SetParent(Atr_Main_Panel)
    Atr_Hlist_ScrollFrame:ClearAllPoints()
    Atr_Hlist_ScrollFrame:SetPoint("TOPLEFT", Atr_Main_Panel, "TOPLEFT", -193, -75)
    Atr_Hlist_ScrollFrame:SetSize(170, 335)
  end
end

local function GetBagItemInfo(bag, slot)
  local texture, count, locked, quality = GetContainerItemInfo(bag, slot)
  local link = GetContainerItemLink(bag, slot)
  if not link then return nil end

  local name, _, rarity, itemLevel, _, itemType, itemSubType, maxStack,
        equipLoc, vendorPrice = GetItemInfo(link)

  return {
    bag = bag,
    slot = slot,
    texture = texture,
    count = count or 1,
    locked = locked,
    quality = quality or rarity or 1,
    link = link,
    name = name or link,
    itemLevel = itemLevel,
    itemType = itemType,
    itemSubType = itemSubType,
    maxStack = maxStack,
    equipLoc = equipLoc,
    vendorPrice = vendorPrice,
  }
end

local function InventoryButtonOnEnter(self)
  if not self.ItemData then return end
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetHyperlink(self.ItemData.link)
  GameTooltip:Show()
end

local function InventoryButtonOnLeave()
  GameTooltip:Hide()
end

local function InventoryButtonOnClick(self, button)
  local item = self.ItemData
  if not item or item.locked then return end

  Selling:SetSearchLoading(true, item.name)

  PickupContainerItem(item.bag, item.slot)
  if GetCursorInfo() == "item" then
    Atr_OnDropItem(self, button or "LeftButton")
  end
end


local function DisconnectLegacySellPanel()
  if not Atr_Main_Panel then return end

  -- Every visible control used by the modern interface is reparented to one
  -- of its three panels. The old frame can therefore remain only as a hidden
  -- technical owner for legacy backend code.
  Atr_Main_Panel:EnableMouse(false)
  Atr_Main_Panel:SetAlpha(0)
  Atr_Main_Panel:Hide()

  -- Explicitly hide its own artwork as an additional safeguard against old
  -- textures being shown again by legacy update code. Child controls that are
  -- used by the modern interface have already been reparented and are not
  -- affected by this loop.
  local regions = { Atr_Main_Panel:GetRegions() }
  for _, region in ipairs(regions) do
    if region and region.Hide then
      region:Hide()
    end
  end
end

local function HideLegacyChrome()
  local frames = {
    AuctionatorTitle,
    Atr_ActiveItems_Text,
    AuctionatorMessageFrame,
    AuctionatorMessage2Frame,
    Atr_Search_Box,
    Atr_Search_Button,
    Atr_Adv_Search_Button,
    Atr_Exact_Search_Button,
    Atr_DropDownSL,
    Atr_CheckActiveButton,
    Auctionator1Button,
    Atr_FullScanButton,
    Atr_RecommendItem_Tex,
    Atr_Recommend_Text,
    Atr_Recommend_Basis_Text,
    Atr_RecommendPerStack_Text,
    Atr_RecommendPerItem_Text,
    Atr_RecommendPerStack_Price,
    Atr_RecommendPerItem_Price,
    Atr_AddToSListButton,
    Atr_RemFromSListButton,
    Atr_SrchSListButton,
    Atr_MngSListsButton,
    Atr_NewSListButton,
  }
  for _, frame in ipairs(frames) do HideFrame(frame) end
end


local function CompactAuctionResultRow(row)
  if not row then return end

  local priceColumn, currentAuctionsColumn, packPriceColumn = row:GetChildren()

  if priceColumn then
    priceColumn:ClearAllPoints()
    priceColumn:SetPoint("LEFT", row, "LEFT", 4, 0)
    priceColumn:SetSize(112, 16)
  end

  if currentAuctionsColumn then
    currentAuctionsColumn:ClearAllPoints()
    currentAuctionsColumn:SetPoint("LEFT", row, "LEFT", 120, 0)
    currentAuctionsColumn:SetSize(158, 16)

    local entryText = _G[row:GetName() .. "_EntryText"]
    if entryText then
      entryText:ClearAllPoints()
      entryText:SetPoint("LEFT", currentAuctionsColumn, "LEFT", 2, 0)
      entryText:SetPoint("RIGHT", currentAuctionsColumn, "RIGHT", -2, 0)
      entryText:SetJustifyH("LEFT")
    end
  end

  if packPriceColumn then
    packPriceColumn:ClearAllPoints()
    packPriceColumn:SetPoint("LEFT", row, "LEFT", 284, 0)
    packPriceColumn:SetSize(105, 16)

    local stackPrice = _G[row:GetName() .. "_StackPrice"]
    if stackPrice then
      stackPrice:ClearAllPoints()
      stackPrice:SetPoint("RIGHT", packPriceColumn, "RIGHT", -2, 0)
      stackPrice:SetJustifyH("RIGHT")
    end
  end
end

local function CompactAuctionHeadings()
  if not Atr_HeadingsBar then return end

  if Atr_Col1_Heading then
    Atr_Col1_Heading:ClearAllPoints()
    Atr_Col1_Heading:SetPoint("LEFT", Atr_HeadingsBar, "LEFT", 8, 1)
    Atr_Col1_Heading:SetWidth(108)
    Atr_Col1_Heading:SetJustifyH("CENTER")
  end

  if Atr_Col3_Heading then
    Atr_Col3_Heading:ClearAllPoints()
    Atr_Col3_Heading:SetPoint("LEFT", Atr_HeadingsBar, "LEFT", 122, 1)
    Atr_Col3_Heading:SetWidth(154)
    Atr_Col3_Heading:SetJustifyH("CENTER")
  end

  if Atr_Col4_Heading then
    Atr_Col4_Heading:ClearAllPoints()
    Atr_Col4_Heading:SetPoint("LEFT", Atr_HeadingsBar, "LEFT", 286, 1)
    Atr_Col4_Heading:SetWidth(102)
    Atr_Col4_Heading:SetJustifyH("CENTER")
  end

  if Atr_Col1_Heading_Button then
    Atr_Col1_Heading_Button:ClearAllPoints()
    Atr_Col1_Heading_Button:SetPoint("TOPLEFT", Atr_HeadingsBar, "TOPLEFT", 8, -21)
    Atr_Col1_Heading_Button:SetSize(108, 20)
  end

  if Atr_Col3_Heading_Button then
    Atr_Col3_Heading_Button:ClearAllPoints()
    Atr_Col3_Heading_Button:SetPoint("TOPLEFT", Atr_HeadingsBar, "TOPLEFT", 122, -21)
    Atr_Col3_Heading_Button:SetSize(154, 20)
  end
end


function Selling:SetSearchLoading(isLoading, searchText)
  local overlay = self.SearchOverlay
  if not overlay then return end

  if isLoading then
    overlay.SearchText:SetText(searchText or "")
    if searchText and searchText ~= "" then
      overlay.SearchText:Show()
    else
      overlay.SearchText:Hide()
    end

    overlay.Status:SetText(ZT and ZT("Searching") or "Buscando")
    overlay.DotStep = 0
    overlay.Elapsed = 0
    overlay.Dots:SetText(".")
    overlay:Show()
  else
    overlay:Hide()
  end
end

function Selling:UpdateSearchLoading(elapsed)
  local overlay = self.SearchOverlay
  if not overlay or not overlay:IsShown() then return end

  overlay.Elapsed = (overlay.Elapsed or 0) + (elapsed or 0)
  if overlay.Elapsed < 0.12 then return end
  overlay.Elapsed = 0

  local pane = Atr_GetCurrentPane and Atr_GetCurrentPane()
  local search = pane and pane.activeSearch
  local states = Auctionator
    and Auctionator.Constants
    and Auctionator.Constants.SearchStates

  if search and states then
    local state = search.processing_state

    if state == states.NULL then
      overlay:Hide()
      return
    elseif state == states.PRE_QUERY then
      overlay.Status:SetText(
        ZT and ZT("Waiting to send query") or "Preparando consulta"
      )
    elseif state == states.IN_QUERY or state == states.POST_QUERY then
      local page = tonumber(search.current_page) or 1
      overlay.Status:SetText(
        string.format(
          ZT and ZT("Searching page %d") or "Buscando página %d",
          math.max(1, page)
        )
      )
    elseif state == states.ANALYZING then
      overlay.Status:SetText(
        ZT and ZT("Analyzing results") or "Analizando resultados"
      )
    else
      overlay.Status:SetText(ZT and ZT("Searching") or "Buscando")
    end
  end

  overlay.DotStep = ((overlay.DotStep or 0) + 1) % 12
  local dotCount = math.floor(overlay.DotStep / 3) + 1
  overlay.Dots:SetText(string.rep(".", dotCount))
end


local SELLING_EMPTY_SLOT_TEXTURE =
  "Interface\\Buttons\\UI-Slot-Background"

function Selling:ShowEmptyItemSlot()
  if not Atr_SellControls_Tex then return end

  local itemName = GetAuctionSellItemInfo and GetAuctionSellItemInfo()
  if itemName then
    local normalTexture = Atr_SellControls_Tex:GetNormalTexture()

    if normalTexture then
      normalTexture:SetTexCoord(0, 1, 0, 1)
      normalTexture:SetVertexColor(1, 1, 1, 1)
      normalTexture:SetAlpha(1)
    end

    Atr_SellControls_Tex:Show()
    return
  end

  Atr_SellControls_Tex:SetNormalTexture(SELLING_EMPTY_SLOT_TEXTURE)

  local normalTexture = Atr_SellControls_Tex:GetNormalTexture()
  if normalTexture then
    normalTexture:SetTexCoord(0, 0.640625, 0, 0.640625)
    normalTexture:SetVertexColor(1, 1, 1, 1)
    normalTexture:SetAlpha(1)
  end

  Atr_SellControls_Tex:Show()

  if Atr_SetTextureButtonCount then
    Atr_SetTextureButtonCount("Atr_SellControls_Tex", 0)
  elseif Atr_SellControls_TexCount then
    Atr_SellControls_TexCount:Hide()
  end

  if Atr_SellControls_TexName then
    Atr_SellControls_TexName:SetText("")
  end
end

function Selling:ClearSelectedAuctionItem()
  -- Return any item still held by the Blizzard auction sell slot to its bag.
  -- ClearAuctionSellItem is not available on every 3.3.5 client, so retain a
  -- guarded classic fallback.
  if GetAuctionSellItemInfo and GetAuctionSellItemInfo() then
    if ClearAuctionSellItem then
      ClearAuctionSellItem()
    elseif ClickAuctionSellItemButton then
      ClickAuctionSellItemButton()
      if ClearCursor then
        ClearCursor()
      end
    end
  end

  if gSellPane and gSellPane.ClearSearch then
    gSellPane:ClearSearch()
  end

  if gCurrentPane and gSellPane and gCurrentPane == gSellPane then
    gCurrentPane.totalItems = 0
    gCurrentPane.fullStackSize = 0
  elseif gSellPane then
    gSellPane.totalItems = 0
    gSellPane.fullStackSize = 0
  end

  if Atr_SellControls_TexName then
    Atr_SellControls_TexName:SetText("")
  end

  if Atr_Batch_NumAuctions then
    Atr_Batch_NumAuctions:SetText(0)
  end

  if Atr_SetStackSize then
    Atr_SetStackSize(0)
  end

  self:SetSearchLoading(false)
  self:ShowEmptyItemSlot()
end

function Selling:Create()
  if self.Frame or not AuctionFrame or not Atr_Main_Panel then return end

  local root = CreateFrame("Frame", "Atr_ModernSellFrame", AuctionFrame)
  root:SetFrameStrata("HIGH")
  root:SetFrameLevel((Atr_Main_Panel:GetFrameLevel() or 1) + 10)
  Reanchor(root, "TOPLEFT", Atr_Main_Panel, "TOPLEFT", -198, -62)
  root:SetSize(805, 352)

  -- Opaque base for the complete modern selling workspace. This prevents the
  -- legacy Auctionator panel/background from showing through the small gaps
  -- between the header, inventory and results panels.
  root:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
  })
  root:SetBackdropColor(0.018, 0.018, 0.018, 1)

  self.Frame = root

  local header = MakePanel("Atr_ModernSellHeader", root, 0.025, 0.025, 0.025, 0.98)
  Reanchor(header, "TOPLEFT", root, "TOPLEFT", 0, 0)
  header:SetSize(805, 92)
  self.Header = header

  local inventory = MakePanel("Atr_ModernSellInventory", root, 0.03, 0.03, 0.03, 0.98)
  Reanchor(inventory, "TOPLEFT", header, "BOTTOMLEFT", 0, -4)
  inventory:SetSize(282, 256)
  self.Inventory = inventory

  -- Independent bag inventory. The old Atr_Hlist is shared by Shopping and
  -- More..., so reparenting it caused active auctions to leak into Selling.
  local inventoryScroll = CreateFrame("ScrollFrame", "Atr_ModernSellInventoryScroll", inventory)
  Reanchor(inventoryScroll, "TOPLEFT", inventory, "TOPLEFT", 7, -7)
  inventoryScroll:SetSize(248, 242)
  inventoryScroll:EnableMouseWheel(true)
  self.InventoryScroll = inventoryScroll

  local inventoryChild = CreateFrame("Frame", "Atr_ModernSellInventoryChild", inventoryScroll)
  inventoryChild:SetSize(248, 242)
  inventoryScroll:SetScrollChild(inventoryChild)
  self.InventoryChild = inventoryChild
  self.InventoryButtons = {}

  local inventorySlider = CreateFrame("Slider", "Atr_ModernSellInventorySlider", inventoryScroll, "UIPanelScrollBarTemplate")
  inventorySlider:SetPoint("TOPLEFT", inventoryScroll, "TOPRIGHT", 2, -15)
  inventorySlider:SetPoint("BOTTOMLEFT", inventoryScroll, "BOTTOMRIGHT", 2, 15)
  inventorySlider:SetMinMaxValues(0, 0)
  inventorySlider:SetValueStep(18)

  -- UIPanelScrollBarTemplate includes an inherited OnValueChanged handler
  -- that tries to scroll the slider's parent. Replace it before SetValue().
  inventorySlider:SetScript("OnValueChanged", function(_, value)
    if inventoryScroll and inventoryScroll.SetVerticalScroll then
      inventoryScroll:SetVerticalScroll(value or 0)
    end
  end)

  inventorySlider:SetValue(0)
  inventorySlider:Hide()
  self.InventorySlider = inventorySlider

  inventoryScroll:SetScript("OnMouseWheel", function(_, delta)
    local minValue, maxValue = inventorySlider:GetMinMaxValues()
    local value = inventorySlider:GetValue() - delta * 42
    if value < minValue then value = minValue end
    if value > maxValue then value = maxValue end
    inventorySlider:SetValue(value)
  end)

  local results = MakePanel("Atr_ModernSellResults", root, 0.03, 0.03, 0.03, 0.98)
  Reanchor(results, "TOPLEFT", inventory, "TOPRIGHT", 6, 0)
  results:SetSize(517, 256)
  self.Results = results

  -- Search status panel. It is independent from the result table and does not
  -- alter any of the existing layout, rows, scrollbars or auction controls.
  local searchOverlay = CreateFrame(
    "Frame",
    "Atr_ModernSellSearchOverlay",
    results
  )
  searchOverlay:SetFrameLevel(results:GetFrameLevel() + 30)
  searchOverlay:SetPoint("TOPLEFT", results, "TOPLEFT", 7, -34)
  searchOverlay:SetPoint("BOTTOMRIGHT", results, "BOTTOMRIGHT", -7, 33)
  searchOverlay:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  searchOverlay:SetBackdropColor(0.025, 0.025, 0.025, 0.985)
  searchOverlay:SetBackdropBorderColor(0.38, 0.38, 0.38, 1)
  searchOverlay:EnableMouse(true)

  local loadingTitle = searchOverlay:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
  )
  loadingTitle:SetPoint("CENTER", searchOverlay, "CENTER", 0, 24)
  loadingTitle:SetText(
    ZT and ZT("Searching the Auction House")
      or "Buscando en la casa de subastas"
  )

  local loadingSearchText = searchOverlay:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlight"
  )
  loadingSearchText:SetPoint("TOP", loadingTitle, "BOTTOM", 0, -8)
  loadingSearchText:SetWidth(400)
  loadingSearchText:SetJustifyH("CENTER")
  searchOverlay.SearchText = loadingSearchText

  local loadingStatus = searchOverlay:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  loadingStatus:SetPoint("TOP", loadingSearchText, "BOTTOM", -8, -10)
  loadingStatus:SetText(ZT and ZT("Searching") or "Buscando")
  searchOverlay.Status = loadingStatus

  local loadingDots = searchOverlay:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontHighlightSmall"
  )
  loadingDots:SetPoint("LEFT", loadingStatus, "RIGHT", 2, 0)
  loadingDots:SetWidth(28)
  loadingDots:SetJustifyH("LEFT")
  loadingDots:SetText(".")
  searchOverlay.Dots = loadingDots

  searchOverlay:SetScript("OnUpdate", function(_, elapsed)
    Selling:UpdateSearchLoading(elapsed)
  end)
  searchOverlay:Hide()
  self.SearchOverlay = searchOverlay

  -- Compact header: section captions and divider lines are intentionally
  -- omitted to leave the maximum vertical space for inventory and results.

  root:Hide()
end

function Selling:Apply()
  if not Atr_Main_Panel then return end
  if not self.Frame then self:Create() end
  if not self.Frame then return end

  HideLegacyChrome()
  self.Frame:Show()

  -- Fully detach the legacy visual panel. It remains available as a hidden
  -- technical frame, while the modern frame is the sole visible workspace.
  DisconnectLegacySellPanel()

  -- Header: existing sell controls become children of the new horizontal header.
  if Atr_SellControls then
    Atr_SellControls:SetParent(self.Header)
    Reanchor(Atr_SellControls, "TOPLEFT", self.Header, "TOPLEFT", 0, 0)
    Atr_SellControls:SetSize(805, 92)
    Atr_SellControls:SetBackdrop(nil)
    Atr_SellControls:Show()
  end

  -- Compact horizontal auction creation area.
  Reanchor(Atr_SellControls_Tex, "TOPLEFT", self.Header, "TOPLEFT", 15, -18)
  if Atr_SellControls_Tex then Atr_SellControls_Tex:SetSize(54, 54) end
  self:ShowEmptyItemSlot()

  if Atr_SellControls_TexName then
    Reanchor(Atr_SellControls_TexName, "TOPLEFT", Atr_SellControls_Tex, "TOPRIGHT", 9, -1)
    Atr_SellControls_TexName:SetSize(118, 52)
    Atr_SellControls_TexName:SetJustifyH("LEFT")
    Atr_SellControls_TexName:SetJustifyV("TOP")
  end

  -- Price fields: stack price on the first line, per-item price below.
  Reanchor(Atr_StackPriceText, "TOPLEFT", self.Header, "TOPLEFT", 205, -13)
  Reanchor(Atr_StackPrice, "TOPLEFT", self.Header, "TOPLEFT", 205, -29)
  Reanchor(Atr_ItemPriceText, "TOPLEFT", self.Header, "TOPLEFT", 205, -53)
  Reanchor(Atr_ItemPrice, "TOPLEFT", self.Header, "TOPLEFT", 205, -68)

  -- Quantity controls occupy the centre of the compact header.
  Reanchor(Atr_ItemsOwned_Text, "TOPLEFT", self.Header, "TOPLEFT", 397, -13)
  Reanchor(Atr_Batch_NumAuctions, "TOPLEFT", self.Header, "TOPLEFT", 397, -35)
  Reanchor(Atr_Batch_Stacksize_Text, "TOPLEFT", self.Header, "TOPLEFT", 441, -35)
  if Atr_Batch_Stacksize_Text then
    Atr_Batch_Stacksize_Text:SetSize(68, 22)
    Atr_Batch_Stacksize_Text:SetText(ZT and ZT("stacks of") or "stacks of")
  end
  Reanchor(Atr_Batch_Stacksize, "TOPLEFT", self.Header, "TOPLEFT", 510, -35)
  Reanchor(Atr_Batch_MaxAuctions_Text, "TOPLEFT", self.Header, "TOPLEFT", 394, -58)
  Reanchor(Atr_Batch_MaxStacksize_Text, "TOPLEFT", self.Header, "TOPLEFT", 506, -58)

  -- Keep starting-price controls available on the last compact line.
  Reanchor(Atr_StartingPriceDiscountText, "TOPLEFT", self.Header, "TOPLEFT", 397, -74)
  Reanchor(Atr_StartingPriceText, "TOPLEFT", self.Header, "TOPLEFT", 397, -74)
  Reanchor(Atr_StartingPrice, "TOPLEFT", self.Header, "TOPLEFT", 487, -68)

  -- Duration, deposit and a narrower publish button.
  Reanchor(Atr_Duration_Text, "TOPLEFT", self.Header, "TOPLEFT", 590, -13)
  Reanchor(Atr_Duration, "TOPLEFT", self.Header, "TOPLEFT", 602, -28)
  if UIDropDownMenu_SetWidth and Atr_Duration then UIDropDownMenu_SetWidth(Atr_Duration, 95) end

  Reanchor(Atr_Deposit_Text, "TOPLEFT", self.Header, "TOPLEFT", 590, -57)
  if Atr_Deposit_Text then Atr_Deposit_Text:SetWidth(190) end

  Reanchor(Atr_CreateAuctionButton, "BOTTOMRIGHT", self.Header, "BOTTOMRIGHT", -13, 7)
  if Atr_CreateAuctionButton then Atr_CreateAuctionButton:SetSize(160, 24) end

  -- Lower-left inventory is now a dedicated bag grid. Atr_Hlist remains under
  -- Atr_Main_Panel because the More... tab uses it for active auctions.
  if Atr_Hlist and Atr_Hlist:GetParent() ~= Atr_Main_Panel then
    Atr_Hlist:SetParent(Atr_Main_Panel)
  end
  if Atr_Hlist_ScrollFrame and Atr_Hlist_ScrollFrame:GetParent() ~= Atr_Main_Panel then
    Atr_Hlist_ScrollFrame:SetParent(Atr_Main_Panel)
  end
  HideFrame(Atr_Hlist)
  HideFrame(Atr_Hlist_ScrollFrame)
  self:RefreshInventory()

  -- Lower-right competition/results area.
  -- The legacy result template was designed for a much wider panel, so both
  -- the outer frames and the three internal row columns are compacted here.
  if Atr_HeadingsBar then
    Atr_HeadingsBar:SetParent(self.Results)
    Reanchor(Atr_HeadingsBar, "TOPLEFT", self.Results, "TOPLEFT", 3, -1)
    Atr_HeadingsBar:SetSize(474, 50)
    if Atr_HeadingsBarMiddle then Atr_HeadingsBarMiddle:SetWidth(474) end
    CompactAuctionHeadings()
  end

  if Atr_ListTabs then
    Atr_ListTabs:SetParent(self.Results)
    Reanchor(Atr_ListTabs, "TOPRIGHT", self.Results, "TOPRIGHT", -34, 18)
  end

  if AuctionatorScrollFrame then
    AuctionatorScrollFrame:SetParent(self.Results)
    Reanchor(AuctionatorScrollFrame, "TOPLEFT", self.Results, "TOPLEFT", 2, -36)
    AuctionatorScrollFrame:SetSize(470, 192)
  end

  for i = 1, 15 do
    local row = _G["AuctionatorEntry" .. i]
    if row then
      row:SetParent(self.Results)
      row:SetWidth(460)
      CompactAuctionResultRow(row)

      if i == 1 and AuctionatorScrollFrame then
        Reanchor(row, "TOPLEFT", AuctionatorScrollFrame, "TOPLEFT", 4, 0)
      end
    end
  end

  Reanchor(Atr_Buy1_Button, "BOTTOMRIGHT", self.Results, "BOTTOMRIGHT", -205, 7)
  Reanchor(Atr_CancelSelectionButton, "BOTTOMRIGHT", self.Results, "BOTTOMRIGHT", -108, 7)
  Reanchor(AuctionatorCloseButton, "BOTTOMRIGHT", self.Results, "BOTTOMRIGHT", -8, 7)

  -- The legacy drag highlight now exactly matches the modern header.
  if Atr_Hilite1 then
    Atr_Hilite1:SetParent(self.Header)
    Reanchor(Atr_Hilite1, "TOPLEFT", self.Header, "TOPLEFT", 0, 0)
    Atr_Hilite1:SetSize(805, 92)
  end
  if Atr_Hilite1_btn then
    Atr_Hilite1_btn:SetParent(self.Header)
    Reanchor(Atr_Hilite1_btn, "TOPLEFT", self.Header, "TOPLEFT", 0, 0)
    Atr_Hilite1_btn:SetSize(805, 92)
  end
end

function Selling:AcquireInventoryButton(index)
  local button = self.InventoryButtons[index]
  if button then return button end

  button = CreateFrame("Button", "Atr_ModernSellInventoryItem" .. index, self.InventoryChild)
  button:SetSize(36, 36)
  button:RegisterForClicks("LeftButtonUp")

  local background = button:CreateTexture(nil, "BACKGROUND")
  background:SetTexture("Interface\\Buttons\\UI-Quickslot2")
  background:SetAllPoints(button)
  button.Background = background

  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
  icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  button.Icon = icon

  local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
  count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
  count:SetJustifyH("RIGHT")
  button.Count = count

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  border:SetBlendMode("ADD")
  border:SetPoint("CENTER", button, "CENTER", 0, 0)
  border:SetSize(62, 62)
  border:Hide()
  button.QualityBorder = border

  button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  button:SetScript("OnEnter", InventoryButtonOnEnter)
  button:SetScript("OnLeave", InventoryButtonOnLeave)
  button:SetScript("OnClick", InventoryButtonOnClick)

  self.InventoryButtons[index] = button
  return button
end

function Selling:RefreshInventory()
  if not self.InventoryChild then return end

  local items = {}
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(bag) do
      local item = GetBagItemInfo(bag, slot)
      if item then
        table.insert(items, item)
      end
    end
  end

  -- Keep bag order/slot order. It mirrors the player's actual bags and avoids
  -- surprising alphabetical reshuffles while items are moved or posted.
  local columns = 6
  local cell = 40
  local topPadding = 2

  for index, item in ipairs(items) do
    local button = self:AcquireInventoryButton(index)
    local col = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", self.InventoryChild, "TOPLEFT", col * cell + 2, -(row * cell + topPadding))
    button.ItemData = item
    button.Icon:SetTexture(item.texture)
    button.Count:SetText((item.count or 1) > 1 and item.count or "")
    button:SetAlpha(item.locked and 0.45 or 1)

    if item.quality and item.quality > 1 then
      local r, g, b = GetItemQualityColor(item.quality)
      button.QualityBorder:SetVertexColor(r or 1, g or 1, b or 1)
      button.QualityBorder:Show()
    else
      button.QualityBorder:Hide()
    end
    button:Show()
  end

  for index = #items + 1, #self.InventoryButtons do
    self.InventoryButtons[index]:Hide()
    self.InventoryButtons[index].ItemData = nil
  end

  local rows = math.max(1, math.ceil(#items / columns))
  local contentHeight = math.max(self.InventoryScroll:GetHeight(), rows * cell + 4)
  self.InventoryChild:SetHeight(contentHeight)

  local maxScroll = math.max(0, contentHeight - self.InventoryScroll:GetHeight())
  self.InventorySlider:SetMinMaxValues(0, maxScroll)
  if maxScroll > 0 then
    self.InventorySlider:Show()
  else
    self.InventorySlider:SetValue(0)
    self.InventorySlider:Hide()
  end
end

function Selling:Show()
  self:Apply()

  -- All visible selling controls have been moved to the modern frame. Keeping
  -- the legacy panel hidden prevents its old backdrop and XML layout from
  -- appearing when the Sell tab is selected.
  DisconnectLegacySellPanel()

  if self.Frame then
    self.Frame:Show()
  end
  self:RefreshInventory()
end

function Selling:Hide()
  if self.Frame then
    self.Frame:Hide()
  end
  RestoreLegacyPanel()
end

function Selling:IsSelected()
  return Atr_IsModeCreateAuction and Atr_IsModeCreateAuction()
end

function Selling:Refresh()
  if self:IsSelected() then
    self:Show()
  else
    self:Hide()
  end
end

function Selling:Initialize()
  if self.Initialized then
    return
  end

  self.Initialized = true
  self:Create()

  local eventFrame = CreateFrame("Frame")
  eventFrame:RegisterEvent("BAG_UPDATE")
  eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
  eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
  eventFrame:SetScript("OnEvent", function(_, event)
    if event == "AUCTION_HOUSE_CLOSED" then
      Selling:ClearSelectedAuctionItem()
      return
    end

    if event == "AUCTION_HOUSE_SHOW" then
      Selling:ShowEmptyItemSlot()
    end

    if Selling.Frame and Selling.Frame:IsShown() then
      Selling:RefreshInventory()
      Selling:ShowEmptyItemSlot()
    end
  end)
  self.EventFrame = eventFrame

  -- These functions are defined by Auctionator.lua, which is loaded after the
  -- Source manifests. Initialize is therefore called explicitly once the
  -- legacy file has finished defining its API.
  if hooksecurefunc then
    if Atr_UpdateUI then
      hooksecurefunc("Atr_UpdateUI", function()
        Selling:Refresh()
      end)
    end

    if Atr_UpdateUI_SellPane then
      hooksecurefunc("Atr_UpdateUI_SellPane", function()
        Selling:Refresh()
      end)
    end

    if Atr_OnSearchComplete then
      hooksecurefunc("Atr_OnSearchComplete", function()
        Selling:SetSearchLoading(false)
        Selling:Refresh()
      end)
    end

    if Atr_OnNewAuctionUpdate then
      hooksecurefunc("Atr_OnNewAuctionUpdate", function()
        if not (Selling.Frame and Selling.Frame:IsShown()) then
          return
        end

        local pane = Atr_GetCurrentPane and Atr_GetCurrentPane()
        local search = pane and pane.activeSearch
        local states = Auctionator
          and Auctionator.Constants
          and Auctionator.Constants.SearchStates

        if search and states and search.processing_state ~= states.NULL then
          local itemName = select(1, Atr_GetSellItemInfo())
          Selling:SetSearchLoading(true, itemName)
        end
      end)
    end
  end
end
