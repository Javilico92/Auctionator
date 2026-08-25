AUCTIONATOR_LOCALES = AUCTIONATOR_LOCALES or {}

AUCTIONATOR_LOCALES.enUS = function()
  local L = {}

  -- Main tabs and option categories
  L["AUCTIONATOR_TAB"] = "Auctionator"
  L["CONFIG_SHOPPING_CATEGORY"] = "Shopping"
  L["CONFIG_SELLING_CATEGORY"] = "Selling"
  L["CONFIG_SCANNING"] = "Full Scan Settings"
  L["CANCELLING_TAB"] = "Cancelling"

  -- Shared UI
  L["SEARCH"] = "Search"
  L["SEARCH_COLON"] = "Search:"
  L["TOTAL_VALUE"] = "Total value:"
  L["RESULTS_NAME_COLUMN"] = "Item name"
  L["QUANTITY"] = "Auction quantity"
  L["UNIT_PRICE"] = "Price per item"
  L["TIME_LEFT"] = "Time left"
  L["IS_UNDERCUT"] = "Undercut"
  L["ITEMS_AHEAD"] = "Items ahead"
  L["UNDERCUT_YES"] = "Yes"
  L["UNDERCUT_NO"] = "No"
  L["STOP"] = "Stop"
  L["UNKNOWN"] = "Unknown"

  -- Cancelling tab (3.3.5 modern UI)
  L["CANCELLING_CHECK_PRICES"] = "Check prices"
  L["CANCELLING_CHECKING_X_OF_X"] = "Checking %d of %d..."
  L["CANCELLING_COMPLETE"] = "Price check complete"
  L["CANCELLING_STOPPED"] = "Price check stopped"
  L["CANCELLING_NO_AUCTIONS"] = "You have no active auctions."
  L["CANCELLING_NO_RESULTS"] = "No auctions match the search."
  L["CANCELLING_PACK"] = "pack"
  L["CANCELLING_PACKS"] = "packs"
  L["CANCELLING_OF"] = "of"
  L["CANCELLING_SUMMARY"] = "%d rows · %d active auctions"

  -- Auctionator information tab
  L["OPEN_ADDON_OPTIONS"] = "Open addon options"
  L["FULL_SCAN"] = "Full scan"
  L["OPEN_ADDON_OPTIONS_TOOLTIP"] = "Opens Interface > AddOns > Auctionator."
  L["FULL_SCAN_TOOLTIP_WOTLK"] = "Click: fast scan.\nShift + click: full page-by-page scan."
  L["FULL_SCAN_PAGE_BY_PAGE"] = "Page-by-page scan"
  L["FULL_SCAN_FAST_UNAVAILABLE"] = "Fast scan unavailable"
  L["FULL_SCAN_FAST_FAILED_STATUS"] = "The server did not return the fast scan."
  L["FULL_SCAN_FAST_FAILED_MESSAGE"] = "This realm advertises fast-scan support, but it did not return usable auction data. Auctionator has disabled fast scanning for this session.\n\nDo you want to start a page-by-page scan instead? This can take several minutes on a large Auction House."
  L["AUTHOR_HEADER"] = "Author"
  L["VERSION_HEADER"] = "Version"
  L["AVAILABLE_LANGUAGES"] = "Available languages"
  L["TRANSLATORS_HEADER"] = "Translators"

  -- Shopping progressive search
  L["LOAD_MORE_RESULTS"] = "Load more results"
  L["LOADING"] = "Loading..."
  L["SHOPPING_SEARCH_TITLE"] = "Searching the Auction House..."
  L["SHOPPING_SEARCH_SUBTITLE"] = "This may take a few seconds."
  L["SHOPPING_SEARCHING_FOR"] = "Searching: |cffffd200%s|r"
  L["SHOPPING_PREPARING_SEARCH"] = "Preparing search..."
  L["SHOPPING_PAGE_X_OF_X"] = "Page %d of %d"
  L["SHOPPING_ONE_AUCTION_FOUND"] = "1 auction found"
  L["SHOPPING_AUCTIONS_FOUND"] = "%d auctions found"
  L["SHOPPING_SEARCH_COMPLETE"] = "Search complete"
  L["SHOPPING_RESULTS_AVAILABLE"] = "The results are now available."
  L["SHOPPING_ONE_RESULT_FOUND"] = "1 result found"
  L["SHOPPING_RESULTS_FOUND"] = "%d results found"

  -- Selling search overlay
  L["SEARCHING"] = "Searching"
  L["WAITING_TO_SEND_QUERY"] = "Preparing query"
  L["SEARCHING_PAGE_X"] = "Searching page %d"
  L["ANALYZING_RESULTS"] = "Analyzing results"
  L["SEARCHING_AUCTION_HOUSE"] = "Searching the Auction House"

  -- Time-left fallbacks (normally supplied by Blizzard globals)
  L["TIME_LEFT_VERY_SHORT"] = "Very short"
  L["TIME_LEFT_SHORT"] = "Short"
  L["TIME_LEFT_LONG"] = "Long"
  L["TIME_LEFT_VERY_LONG"] = "Very long"

  return L
end
