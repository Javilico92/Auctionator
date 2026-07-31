Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}

local Shopping = Auctionator.Shopping

Shopping.ProgressiveDebugEnabled = false

function Shopping.ProgressiveDebug(message)
  if not Shopping.ProgressiveDebugEnabled then
    return
  end

  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100[Auctionator Debug]|r " .. tostring(message))
  end
end

function Shopping.Initialize(parent)
  if Shopping.Frame then
    return Shopping.Frame
  end

  parent = parent or AuctionFrame

  local frame = CreateFrame(
    "Frame",
    "AuctionatorShoppingFrame",
    parent,
    "AuctionatorShoppingFrameTemplate"
  )

  frame:ClearAllPoints()

  if Atr_Main_Panel then
    frame:SetAllPoints(Atr_Main_Panel)
  else
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
  end

  frame:Hide()
  Shopping.Frame = frame

  return frame
end

function Shopping.OnLoad(frame)
  Shopping.Frame = frame

  local frameName = frame:GetName()

  frame.SearchBox = _G[frameName .. "SearchBox"]
  frame.SearchButton = _G[frameName .. "SearchButton"]
  frame.ClearButton = _G[frameName .. "ClearButton"]
  frame.AdvancedSearchButton = _G[frameName .. "AdvancedSearchButton"]
  frame.ResultsListing = _G[frameName .. "ResultsListing"]
  frame.Sidebar = _G[frameName .. "Sidebar"]
  frame.EmptyText = _G[frameName .. "EmptyText"]
end

function Shopping.Show()
  local frame = Shopping.Frame or Shopping.Initialize(AuctionFrame)

  if frame then
    frame:Show()
  end
end

function Shopping.Hide()
  if Shopping.Frame then
    Shopping.Frame:Hide()
  end
end

function Shopping.OnShow(frame)
  if Atr_Main_Panel then
    Atr_Main_Panel:Hide()
  end

  if Shopping.ResultsListing then
    Shopping.ResultsListing.BindLegacyGlobals()
    -- Start from a clean summary layout whenever the Auction House/Shopping
    -- tab is opened. Atr_RedisplayAuctions will show a valid item header again
    -- only when the current view really is an item's auction detail.
    Shopping.ResultsListing.HideSelectedItemHeader()
  end

  if Atr_GetCurrentPane then
    Shopping.LegacyPane = Atr_GetCurrentPane()
  end

  if frame.SearchBox then
    frame.SearchBox:SetFocus()
  end

  if Atr_RedisplayAuctions then
    Atr_RedisplayAuctions()
  end
end

function Shopping.OnHide(frame)
  Shopping.SetLoading(false)

  if frame.SearchBox then
    frame.SearchBox:ClearFocus()
  end

  if Shopping.ResultsListing then
    Shopping.ResultsListing.RestoreLegacyGlobals()
  end
end

function Shopping.Search(frame)
  if not frame or not frame.SearchBox then
    return
  end

  local searchText = frame.SearchBox:GetText() or ""
  searchText = string.gsub(searchText, "^%s+", "")
  searchText = string.gsub(searchText, "%s+$", "")

  if searchText == "" then
    return
  end

  if not Shopping.ResultsListing or
     not Shopping.ResultsListing.BindLegacyGlobals() then
    return
  end

  local legacyPane = Atr_GetCurrentPane and Atr_GetCurrentPane() or Shopping.LegacyPane
  Shopping.LegacyPane = legacyPane

  if Atr_Search_Box then
    Atr_Search_Box:SetText(searchText)
  end

  if frame.EmptyText then
    frame.EmptyText:Hide()
  end

  Shopping.ResultsListing.HideLoadMore()
  Shopping.ResultsListing.SetLoading(true, searchText)

  if frame.SearchButton then
    frame.SearchButton:Disable()
  end

  Atr_Search_Onclick()

  -- gCurrentPane and gShopPane are local to Auctionator.lua, so other modules
  -- cannot read them directly. Keep the actual pane/search returned by the
  -- public accessor for progressive continuation.
  legacyPane = Atr_GetCurrentPane and Atr_GetCurrentPane() or legacyPane
  Shopping.LegacyPane = legacyPane
  Shopping.ProgressiveSearch = legacyPane and legacyPane.activeSearch or nil

  if Shopping.Sidebar then
    Shopping.Sidebar.Refresh()
  end

  frame.SearchBox:ClearFocus()
end

function Shopping.SetLoadingPage(currentPage, totalPages, totalAuctions)
  if Shopping.ResultsListing and Shopping.ResultsListing.SetLoadingPage then
    Shopping.ResultsListing.SetLoadingPage(currentPage, totalPages, totalAuctions)
  end
end

function Shopping.FinishLoading(totalAuctions)
  local frame = Shopping.Frame

  if Shopping.ResultsListing and Shopping.ResultsListing.FinishLoading then
    Shopping.ResultsListing.FinishLoading(totalAuctions)
  end

  if frame and frame.SearchButton then
    frame.SearchButton:Enable()
  end
end

function Shopping.SetLoading(isLoading, searchText)
  local frame = Shopping.Frame

  if Shopping.ResultsListing then
    Shopping.ResultsListing.SetLoading(isLoading, searchText)
  end

  if frame and frame.SearchButton then
    if isLoading then
      frame.SearchButton:Disable()
    else
      frame.SearchButton:Enable()
    end
  end
end

function Shopping.ClearSearch(frame)
  frame = frame or Shopping.Frame

  if not frame then
    return
  end

  if frame.SearchBox then
    frame.SearchBox:SetText("")
    frame.SearchBox:ClearFocus()
  end

  if Atr_Search_Box then
    Atr_Search_Box:SetText("")
  end

  if Shopping.ResultsListing then
    Shopping.ResultsListing.BindLegacyGlobals()
  end

  local legacyPane = Atr_GetCurrentPane and Atr_GetCurrentPane() or Shopping.LegacyPane
  Shopping.LegacyPane = legacyPane
  Shopping.ProgressiveSearch = nil

  if legacyPane and legacyPane.ClearSearch then
    legacyPane:ClearSearch()
  end

  -- Clear must leave the item-detail view completely, not only empty its
  -- auction rows. Restore the normal search-results state explicitly because
  -- the legacy empty search does not schedule a UI refresh by itself.
  if Shopping.ResultsListing then
    Shopping.ResultsListing.HideSelectedItemHeader()
    Shopping.ResultsListing.BeginDisplay("search-summary", 0)

    local resultsFrame = Shopping.ResultsListing.Frame
    if resultsFrame then
      if resultsFrame.BackButton then
        resultsFrame.BackButton:Hide()
      end
      if resultsFrame.SaveThisListButton then
        resultsFrame.SaveThisListButton:Hide()
      end
      if resultsFrame.Col1Heading then
        resultsFrame.Col1Heading:Hide()
      end
      if resultsFrame.Col3Heading then
        resultsFrame.Col3Heading:Hide()
      end
      if resultsFrame.Col4Heading then
        resultsFrame.Col4Heading:Show()
        resultsFrame.Col4Heading:SetText("")
      end
      if resultsFrame.Col1HeadingButton then
        resultsFrame.Col1HeadingButton:Show()
      end
      if resultsFrame.Col3HeadingButton then
        resultsFrame.Col3HeadingButton:Show()
      end
      if resultsFrame.Rows then
        for _, row in ipairs(resultsFrame.Rows) do
          row:Hide()
        end
      end
      if resultsFrame.ScrollFrame then
        FauxScrollFrame_SetOffset(resultsFrame.ScrollFrame, 0)
        resultsFrame.ScrollFrame:SetVerticalScroll(0)
      end
    end
  end

  Shopping.SetLoading(false)

  if frame.EmptyText then
    frame.EmptyText:Show()
  end
end


-- Opens the Wrath-safe custom advanced-search composer.
function Shopping.ShowAdvancedSearch(frame)
  frame = frame or Shopping.Frame
  if not frame then return end

  local searchText = ""
  if frame.SearchBox then
    searchText = frame.SearchBox:GetText() or ""
    frame.SearchBox:ClearFocus()
  end

  if Shopping.AdvancedSearch and Shopping.AdvancedSearch.Show then
    Shopping.AdvancedSearch.Show(searchText)
  end
end


function Shopping.PartialSearchFinished(loadedPages, totalPages, totalAuctions)
  local frame = Shopping.Frame
  local legacyPane = Atr_GetCurrentPane and Atr_GetCurrentPane() or Shopping.LegacyPane
  Shopping.LegacyPane = legacyPane
  Shopping.ProgressiveSearch = legacyPane and legacyPane.activeSearch or Shopping.ProgressiveSearch

  if Shopping.ResultsListing then
    Shopping.ResultsListing.SetLoading(false)
    Shopping.ResultsListing.ShowLoadMore(loadedPages, totalPages, totalAuctions)
  end

  if frame and frame.SearchButton then
    frame.SearchButton:Enable()
  end
end

function Shopping.LoadMoreResults()
  local pane = (Atr_GetCurrentPane and Atr_GetCurrentPane()) or Shopping.LegacyPane
  local search = (pane and pane.activeSearch) or Shopping.ProgressiveSearch

  if not search or not search.auctionatorPausedForMore then
    if Shopping.ResultsListing then
      Shopping.ResultsListing.HideLoadMore()
    end
    return
  end

  Shopping.LegacyPane = pane or Shopping.LegacyPane
  Shopping.ProgressiveSearch = search

  local searchText = search.origSearchText or search.searchText or ""
  Shopping.SetLoading(true, searchText)

  search.auctionatorPausedForMore = false
  search.auctionatorLoadingRemainingPages = true
  search.processing_state = Auctionator.Constants.SearchStates.PRE_QUERY

  -- Continue immediately when the query throttle allows it. Otherwise Atr_Idle
  -- will see PRE_QUERY and retry through Auctionator's original state machine.
  search:Continue()
end
