AuctionatorXMLCompat = AuctionatorXMLCompat or {}

local definitions = {}

local function ApplyMixin(frame, mixin)
  if not frame or type(mixin) ~= "table" then
    return
  end

  for key, value in pairs(mixin) do
    frame[key] = value
  end
end

local function ResolveValue(value)
  if type(value) ~= "table" or not value.xmlType then
    return value
  end

  if value.xmlType == "global" then
    return _G[value.value]
  elseif value.xmlType == "number" then
    return tonumber(value.value)
  elseif value.xmlType == "boolean" then
    return value.value == true
      or value.value == "true"
      or value.value == "1"
  elseif value.xmlType == "string" then
    return tostring(value.value or "")
  end

  return value.value
end

function AuctionatorXMLCompat.Global(name)
  return {
    xmlType = "global",
    value = name,
  }
end

function AuctionatorXMLCompat.Number(value)
  return {
    xmlType = "number",
    value = value,
  }
end

function AuctionatorXMLCompat.Boolean(value)
  return {
    xmlType = "boolean",
    value = value,
  }
end

function AuctionatorXMLCompat.String(value)
  return {
    xmlType = "string",
    value = value,
  }
end

function AuctionatorXMLCompat.Register(key, definition)
  definitions[key] = definition
end

local function ApplyValues(frame, values)
  if not frame or not values then
    return
  end

  for key, value in pairs(values) do
    frame[key] = ResolveValue(value)
  end
end

local function BindChild(parent, propertyName, globalSuffix)
  if not parent or not parent.GetName then
    return nil
  end

  local parentName = parent:GetName()
  if not parentName then
    return nil
  end

  local child = _G[parentName .. globalSuffix]

  if child then
    parent[propertyName] = child
  end

  return child
end

local function BindKnownComponentReferences(frame)
  if not frame or type(frame.GetName) ~= "function" then
    return
  end

  local frameName = frame:GetName()
  if not frameName then
    return
  end

  -- AuctionatorConfigurationCheckbox
  if frame.SetChecked and frame.GetChecked then
    frame.CheckBox =
      frame.CheckBox or _G[frameName .. "CheckBox"]

    if frame.CheckBox then
      local checkBoxName = frame.CheckBox:GetName()

      if checkBoxName then
        frame.CheckBox.Label =
          frame.CheckBox.Label
          or _G[checkBoxName .. "Label"]
      end
    end
  end

  -- AuctionatorConfigurationNumericInput
  if frame.SetNumber and frame.GetNumber then
    frame.InputBox =
      frame.InputBox or _G[frameName .. "InputBox"]

    if frame.InputBox then
      local inputName = frame.InputBox:GetName()

      if inputName then
        frame.InputBox.Label =
          frame.InputBox.Label
          or _G[inputName .. "Label"]
      end
    end
  end

  -- AuctionatorConfigurationMoneyInput
  if frame.SetAmount and frame.GetAmount then
    frame.MoneyInput =
      frame.MoneyInput or _G[frameName .. "MoneyInput"]

    frame.Label =
      frame.Label or _G[frameName .. "Label"]

    if frame.MoneyInput then
      local moneyName = frame.MoneyInput:GetName()

      if moneyName then
        frame.MoneyInput.GoldBox =
          frame.MoneyInput.GoldBox
          or _G[moneyName .. "Gold"]

        frame.MoneyInput.SilverBox =
          frame.MoneyInput.SilverBox
          or _G[moneyName .. "Silver"]
      end
    end
  end

  -- AuctionatorConfigurationRadioButtonGroup
  if frame.SetOnChange then
    frame.GroupHeading =
      frame.GroupHeading or _G[frameName .. "GroupHeading"]
  end

  -- Title area
  frame.Title = frame.Title or _G[frameName .. "Title"]
  frame.SubTitle = frame.SubTitle or _G[frameName .. "SubTitle"]

  -- Heading
  frame.Heading = frame.Heading or _G[frameName .. "Heading"]
end

local function InitializeChild(parent, propertyName, childDefinition)
  local suffix = childDefinition.suffix or propertyName
  local child = BindChild(parent, propertyName, suffix)

  if not child then
    return false
  end

  for _, mixin in ipairs(childDefinition.mixins or {}) do
    ApplyMixin(child, mixin)
  end

  ApplyValues(child, childDefinition.values)

  -- Reconstruye referencias que parentKey habría creado en Retail
  BindKnownComponentReferences(child)

  if childDefinition.children then
    for nestedName, nestedDefinition in pairs(childDefinition.children) do
      local initialized = InitializeChild(
        child,
        nestedName,
        nestedDefinition
      )

      if not initialized then
        return false
      end
    end
  end

  local method = childDefinition.onload

  if method
    and type(child[method]) == "function"
    and not child.__auctionatorXMLCompatOnLoadCalled
  then
    child.__auctionatorXMLCompatOnLoadCalled = true

    local success, errorMessage = pcall(
      child[method],
      child
    )

    if not success then
      child.__auctionatorXMLCompatOnLoadCalled = nil
      error(errorMessage)
    end
  end

  return true
end

function AuctionatorXMLCompat.Initialize(frame, definitionKey)
  local definition = definitions[definitionKey]
  if not frame or not definition then
    return false
  end

  for _, mixin in ipairs(definition.mixins or {}) do
    ApplyMixin(frame, mixin)
  end

  ApplyValues(frame, definition.values)

  local allChildrenReady = true

  for propertyName, childDefinition in pairs(definition.children or {}) do
    if not InitializeChild(frame, propertyName, childDefinition) then
      allChildrenReady = false
    end
  end

  if not allChildrenReady then
    return false
  end

  if definition.onload
      and type(frame[definition.onload]) == "function"
  then
    frame[definition.onload](frame)
  end

  frame.__auctionatorXMLCompatInitialized = true
  return true
end

function AuctionatorXMLCompat.InitializeDeferred(frame, definitionKey)
  if not frame or frame.__auctionatorXMLCompatPending then
    return
  end

  frame.__auctionatorXMLCompatPending = true

  frame:SetScript("OnUpdate", function(self)
    if AuctionatorXMLCompat.Initialize(self, definitionKey) then
      self:SetScript("OnUpdate", nil)
      self.__auctionatorXMLCompatPending = nil
    end
  end)
end

function AuctionatorXMLCompat.Call(frame, methodName, ...)
  if frame and type(frame[methodName]) == "function" then
    return frame[methodName](frame, ...)
  end
end