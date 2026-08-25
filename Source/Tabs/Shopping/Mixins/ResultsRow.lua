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
  row.ItemIcon = GetObject(rowName .. "_ItemIcon")
  row.PerItemText = GetObject(rowName .. "_PerItem_Text")
  row.PerItemPrice = GetObject(rowName .. "_PerItem_Price")
  row.StackPrice = GetObject(rowName .. "_StackPrice")
  row.Stripe = GetObject(rowName .. "Stripe")

  row.ResultIndex = tonumber(string.match(rowName or "", "Entry(%d+)$"))

  if row.Stripe then
    if row.ResultIndex and row.ResultIndex % 2 == 0 then
      row.Stripe:SetVertexColor(0.12, 0.12, 0.12, 0.45)
    else
      row.Stripe:SetVertexColor(0.02, 0.02, 0.02, 0.18)
    end
  end

  parent.Rows = parent.Rows or {}

  if row.ResultIndex then
    parent.Rows[row.ResultIndex] = row
  else
    table.insert(parent.Rows, row)
  end
end

function ResultsRow.SetItem(row, itemLink, quality)
  if not row then
    return
  end

  row.itemLink = itemLink

  local icon = row.ItemIcon
  if icon then
    local texture = itemLink and GetItemIcon(itemLink)
    if not texture and itemLink then
      local itemID = tonumber(string.match(itemLink, "item:(%d+)"))
      if itemID then
        texture = GetItemIcon(itemID)
      end
    end

    if texture then
      icon:SetTexture(texture)
      icon:Show()
    else
      icon:Hide()
    end
  end

  if row.EntryText and quality ~= nil and GetItemQualityColor then
    local r, g, b = GetItemQualityColor(quality)
    if r then
      row.EntryText:SetTextColor(r, g, b)
    end
  end
end

function ResultsRow.ClearItem(row)
  if not row then
    return
  end

  row.itemLink = nil
  if row.ItemIcon then
    row.ItemIcon:Hide()
  end
end
