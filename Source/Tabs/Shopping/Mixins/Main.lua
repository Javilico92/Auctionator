Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}

local Shopping = Auctionator.Shopping

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
  frame.ResultsListing = _G[frameName .. "ResultsListing"]
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
  end

  gCurrentPane = gShopPane

  if frame.SearchBox then
    frame.SearchBox:SetFocus()
  end

  if Atr_RedisplayAuctions then
    Atr_RedisplayAuctions()
  end
end

function Shopping.OnHide(frame)
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

  gCurrentPane = gShopPane

  if Atr_Search_Box then
    Atr_Search_Box:SetText(searchText)
  end

  if frame.EmptyText then
    frame.EmptyText:Hide()
  end

  Atr_Search_Onclick()
  frame.SearchBox:ClearFocus()
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

  gCurrentPane = gShopPane

  if gShopPane and gShopPane.ClearSearch then
    gShopPane:ClearSearch()
  end

  if frame.EmptyText then
    frame.EmptyText:Show()
  end
end
