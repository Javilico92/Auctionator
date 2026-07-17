Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.ResultsDataProvider = Auctionator.Shopping.ResultsDataProvider or {}

local Provider = Auctionator.Shopping.ResultsDataProvider

Provider.Results = Provider.Results or {}
Provider.TotalCount = Provider.TotalCount or 0
Provider.ViewType = Provider.ViewType or nil

function Provider:Clear(viewType)
  wipe(self.Results)
  self.TotalCount = 0
  self.ViewType = viewType
end

function Provider:SetTotalCount(totalCount)
  self.TotalCount = totalCount or 0
end

function Provider:SetResult(index, result)
  if not index then
    return
  end

  self.Results[index] = result
end

function Provider:GetResult(index)
  return self.Results[index]
end

function Provider:GetCount()
  return self.TotalCount
end

function Provider:GetViewType()
  return self.ViewType
end
