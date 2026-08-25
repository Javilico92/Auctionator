-- Shared auctionability checks used by the Selling inventory and item tooltips.
-- WoW 3.3.5 does not expose the bound state of a specific item instance through
-- GetItemInfo(), so the reliable source is the item's tooltip text.

Auctionator = Auctionator or {}
Auctionator.ItemAuctionability = Auctionator.ItemAuctionability or {}

local ItemAuctionability = Auctionator.ItemAuctionability

local SCAN_TOOLTIP_NAME = "AtrAuctionabilityScanTooltip"
local ScanTooltip
local NonAuctionableTooltipText = {}

local function AddNonAuctionableTooltipText(globalName)
  local text = _G[globalName]

  if type(text) == "string" and text ~= "" then
    NonAuctionableTooltipText[text] = true
  end
end

for _, globalName in ipairs({
  "ITEM_SOULBOUND",
  "ITEM_ACCOUNTBOUND",
  "ITEM_BNETACCOUNTBOUND",
  "ITEM_BIND_TO_ACCOUNT",
  "ITEM_BIND_TO_BNETACCOUNT",
  "ITEM_BIND_ON_PICKUP",
  "ITEM_BIND_QUEST",
  "ITEM_CONJURED",
  "ITEM_CANNOT_BE_AUCTIONED",
}) do
  AddNonAuctionableTooltipText(globalName)
end

local function TooltipContainsNonAuctionableText(tooltip)
  if not tooltip or not tooltip.NumLines or not tooltip.GetName then
    return false
  end

  local tooltipName = tooltip:GetName()
  if not tooltipName then
    return false
  end

  for lineIndex = 2, tooltip:NumLines() do
    local leftLine = _G[tooltipName .. "TextLeft" .. lineIndex]
    local rightLine = _G[tooltipName .. "TextRight" .. lineIndex]
    local leftText = leftLine and leftLine:GetText()
    local rightText = rightLine and rightLine:GetText()

    if NonAuctionableTooltipText[leftText] or
       NonAuctionableTooltipText[rightText] then
      return true
    end
  end

  return false
end

function ItemAuctionability.IsTooltipAuctionable(tooltip)
  return not TooltipContainsNonAuctionableText(tooltip)
end

function ItemAuctionability.IsBagItemAuctionable(bag, slot)
  if not ScanTooltip then
    ScanTooltip = CreateFrame(
      "GameTooltip",
      SCAN_TOOLTIP_NAME,
      UIParent,
      "GameTooltipTemplate"
    )
  end

  ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  ScanTooltip:ClearLines()

  local scanned = pcall(ScanTooltip.SetBagItem, ScanTooltip, bag, slot)
  if not scanned then
    ScanTooltip:Hide()
    -- Private servers can occasionally fail to populate an item tooltip. Do not
    -- hide the item merely because the scan itself failed.
    return true
  end

  ScanTooltip:Show()
  local auctionable = not TooltipContainsNonAuctionableText(ScanTooltip)
  ScanTooltip:Hide()

  return auctionable
end
