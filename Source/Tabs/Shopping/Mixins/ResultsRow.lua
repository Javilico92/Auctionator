Auctionator = Auctionator or {}
Auctionator.Shopping = Auctionator.Shopping or {}
Auctionator.Shopping.ResultsRow = Auctionator.Shopping.ResultsRow or {}

local ResultsRow = Auctionator.Shopping.ResultsRow

local function GetObject(name)
  if not name then
    return nil
  end

  return _G[name]
end

function ResultsRow.OnLoad(row)
  local rowName = row:GetName()
  local parent = row:GetParent()

  row.EntryText = GetObject(rowName .. "_EntryText")
  row.PerItemText = GetObject(rowName .. "_PerItem_Text")
  row.PerItemPrice = GetObject(rowName .. "_PerItem_Price")
  row.StackPrice = GetObject(rowName .. "_StackPrice")

  row.ResultIndex = tonumber(string.match(rowName or "", "Entry(%d+)$"))

  parent.Rows = parent.Rows or {}

  if row.ResultIndex then
    parent.Rows[row.ResultIndex] = row
  else
    table.insert(parent.Rows, row)
  end
end