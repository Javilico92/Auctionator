local Global = AuctionatorXMLCompat.Global
local Boolean = AuctionatorXMLCompat.Boolean
local Number = AuctionatorXMLCompat.Number
local String = AuctionatorXMLCompat.String

-- Basic Options.xml

AuctionatorXMLCompat.RegisterSuffix("BasicOptionsFrameTitleArea", {
  titleText = Global("AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY"),
  subTitleText = Global("AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_DESCRIPTION"),
})

AuctionatorXMLCompat.RegisterSuffix("BasicOptionsFrameAutoscan", {
  labelText = Global("AUCTIONATOR_L_CONFIG_AUTOSCAN"),
  tooltipTitleText = Global("AUCTIONATOR_L_CONFIG_AUTOSCAN"),
  tooltipText = Global("AUCTIONATOR_L_CONFIG_AUTOSCAN_TOOLTIP"),
})

AuctionatorXMLCompat.RegisterSuffix("BasicOptionsFrameAlternateScan", {
  labelText = Global("AUCTIONATOR_L_CONFIG_ALTERNATE_SCAN"),
  tooltipTitleText = Global("AUCTIONATOR_L_CONFIG_ALTERNATE_SCAN"),
  tooltipText = Global("AUCTIONATOR_L_CONFIG_ALTERNATE_SCAN_TOOLTIP"),
})

AuctionatorXMLCompat.RegisterSuffix("BasicOptionsFrameAuctionChatLog", {
  labelText = Global("AUCTIONATOR_L_CONFIG_AUCTION_CHAT_LOG"),
})

AuctionatorXMLCompat.RegisterSuffix("BasicOptionsFrameAutoListSearch", {
  labelText = Global("AUCTIONATOR_L_CONFIG_AUTO_LIST_SEARCH"),
})

AuctionatorXMLCompat.RegisterSuffix("BasicOptionsFrameUndercutScanPetsGear", {
  labelText = Global("AUCTIONATOR_L_CONFIG_UNDERCUT_SCAN_PETS_GEAR"),
})

-- LIFO.xml

AuctionatorXMLCompat.RegisterSuffix("LIFOFrameTitleArea", {
  titleText = Global("AUCTIONATOR_L_CONFIG_SELLING_CATEGORY"),
  subTitleText = Global("AUCTIONATOR_L_CONFIG_SELLING_DESCRIPTION"),
})

AuctionatorXMLCompat.RegisterSuffix("LIFOFrameCommodityUndercutPercentage", {
  labelText = Global("AUCTIONATOR_L_CONFIG_UNDERCUT_PERCENTAGE"),
})

AuctionatorXMLCompat.RegisterSuffix("LIFOFrameCommodityUndercutValue", {
  labelText = Global("AUCTIONATOR_L_CONFIG_UNDERCUT_VALUE"),
})

AuctionatorXMLCompat.RegisterSuffix("LIFOFrameCommodityDurationGroup", {
  labelText = Global("AUCTIONATOR_L_CONFIG_DURATION"),
})

--

AuctionatorXMLCompat.RegisterSuffix(
  "CommoditySalesPreferencePercentage",
  {
    labelText = Global("AUCTIONATOR_L_CONFIG_PERCENTAGE"),
    value = String("percentage"),
  }
)

AuctionatorXMLCompat.RegisterSuffix(
  "CommoditySalesPreferenceValue",
  {
    labelText = Global("AUCTIONATOR_L_CONFIG_VALUE"),
    value = String("value"),
  }
)

AuctionatorXMLCompat.RegisterSuffix("SomeNumericControl", {
  value = Number(5),
})

AuctionatorXMLCompat.RegisterSuffix("SomeCheckbox", {
  value = Boolean(true),
})