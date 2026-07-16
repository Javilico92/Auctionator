AuctionatorConfigMoneyInputMixin = {}

function AuctionatorConfigMoneyInputMixin:OnLoad() -- 335 not MoneyInputFrameTemplate so we need to calculate it
  if self.Label and self.labelText then
    self.Label:SetText(self.labelText)
  end

  if self.MoneyInput.GoldBox then
    self.MoneyInput.GoldBox:SetScript("OnEnter", function()
      self:OnEnter()
    end)

    self.MoneyInput.GoldBox:SetScript("OnLeave", function()
      self:OnLeave()
    end)
  end

  if self.MoneyInput.SilverBox then
    self.MoneyInput.SilverBox:SetScript("OnEnter", function()
      self:OnEnter()
    end)

    self.MoneyInput.SilverBox:SetScript("OnLeave", function()
      self:OnLeave()
    end)
  end
end

function AuctionatorConfigMoneyInputMixin:SetAmount(value)
  value = tonumber(value) or 0

  local gold = math.floor(value / 10000)
  local silver = math.floor((value % 10000) / 100)

  if self.MoneyInput and self.MoneyInput.GoldBox then
    self.MoneyInput.GoldBox:SetNumber(gold)
  end

  if self.MoneyInput and self.MoneyInput.SilverBox then
    self.MoneyInput.SilverBox:SetNumber(silver)
  end
end

function AuctionatorConfigMoneyInputMixin:GetAmount()
  if not self.MoneyInput then
    return 0
  end

  local gold = 0
  local silver = 0

  if self.MoneyInput.GoldBox then
    gold = tonumber(self.MoneyInput.GoldBox:GetNumber()) or 0
  end

  if self.MoneyInput.SilverBox then
    silver = tonumber(self.MoneyInput.SilverBox:GetNumber()) or 0
  end

  return gold * 10000 + silver * 100
end