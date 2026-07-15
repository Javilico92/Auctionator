AuctionatorCompat = AuctionatorCompat or {}

AuctionatorCompat.C_TradeSkillUI = AuctionatorCompat.C_TradeSkillUI or {}

AuctionatorCompat.C_TradeSkillUI.GetRecipeInfo = function(index)
    local name, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(index)

    if not name then
        return nil
    end

    return {
        name = name,
        recipeID = index,
        relativeDifficulty = skillType,
        numAvailable = numAvailable,
        isExpanded = isExpanded,
        alternateVerb = altVerb,
        numSkillUps = numSkillUps,
        icon = GetTradeSkillIcon(index),
    }
end

AuctionatorCompat.C_TradeSkillUI.GetRecipeReagentInfo = function(recipeIndex, reagentIndex)
    return GetTradeSkillReagentInfo(recipeIndex, reagentIndex)
end

AuctionatorCompat.C_TradeSkillUI.GetRecipeItemLink = function(recipeIndex)
    return GetTradeSkillItemLink(recipeIndex)
end

AuctionatorCompat.C_TradeSkillUI.GetRecipeNumReagents = function(recipeIndex)
    return GetTradeSkillNumReagents(recipeIndex)
end

AuctionatorCompat.C_TradeSkillUI.GetSelectedRecipeID = function()
    return GetTradeSkillSelectionIndex()
end

AuctionatorCompat.TradeSkillFrame = AuctionatorCompat.TradeSkillFrame or {}
AuctionatorCompat.TradeSkillFrame.RecipeList = AuctionatorCompat.TradeSkillFrame.RecipeList or {}

AuctionatorCompat.TradeSkillFrame.RecipeList.GetSelectedRecipeID = function()
    return GetTradeSkillSelectionIndex()
end

AuctionatorCompat.LE_ITEM_CLASS_WEAPON = 1 -- LE_ITEM_CLASS_WEAPON = 2 after 7.0.X
AuctionatorCompat.LE_ITEM_CLASS_ARMOR = 2 -- LE_ITEM_CLASS_ARMOR = 4 after 7.0.X
AuctionatorCompat.LE_ITEM_CLASS_BATTLEPET = 0 -- Not used in 3.3.5

if not SOUNDKIT then
    SOUNDKIT = {
        IG_MAINMENU_OPTION_CHECKBOX_ON  = "igMainMenuOptionCheckBoxOn",
        IG_MAINMENU_OPTION_CHECKBOX_OFF = "igMainMenuOptionCheckBoxOff",

        IG_QUEST_LIST_OPEN  = "igQuestListOpen",
        IG_QUEST_LIST_CLOSE = "igQuestListClose",

        AUCTION_WINDOW_OPEN  = "AuctionWindowOpen",
        AUCTION_WINDOW_CLOSE = "AuctionWindowClose",

        IG_CHARACTER_INFO_TAB = "igCharacterInfoTab",

        GS_TITLE_OPTION_OK = "gsTitleOptionOK",
    }
end

-- C_ChatInfo 
C_ChatInfo = C_ChatInfo or {}

if not C_ChatInfo.SendAddonMessage then
    function C_ChatInfo.SendAddonMessage(prefix, message, channel, target)
        if not prefix or not message or not channel then
            return false
        end

        SendAddonMessage(prefix, message, channel, target)
        return true
    end
end

if not C_ChatInfo.RegisterAddonMessagePrefix then
    function C_ChatInfo.RegisterAddonMessagePrefix(prefix)
        if RegisterAddonMessagePrefix then
            return RegisterAddonMessagePrefix(prefix)
        end

        return prefix ~= nil and prefix ~= ""
    end
end

-- C_AuctionHouse

C_AuctionHouse = C_AuctionHouse or {}

if not C_AuctionHouse.GetAuctionItemSubClasses then
    function C_AuctionHouse.GetAuctionItemSubClasses(classID)
        if not GetAuctionItemSubClasses then
            return {}
        end

        local results = { GetAuctionItemSubClasses(classID) }
        local subclasses = {}

        for index, name in ipairs(results) do
            subclasses[index] = {
                classID = classID,
                subClassID = index - 1,
                name = name,
            }
        end

        return subclasses
    end
end

ItemLocation = {}
ItemLocation.__index = ItemLocation

function ItemLocation:CreateFromBagAndSlot(bag, slot)
    return setmetatable({
        bag = bag,
        slot = slot,
    }, ItemLocation)
end

function ItemLocation:IsValid()
    if self.bag == nil or self.slot == nil then
        return false
    end

    return GetContainerItemLink(self.bag, self.slot) ~= nil
end

C_Item = C_Item or {}

if not C_Item.GetItemID then
    function C_Item.GetItemID(item)
        if not item then
            return nil
        end

        if type(item) == "number" then
            return item
        end

        if type(item) == "string" then
            return tonumber(item:match("item:(%d+)")) or tonumber(item)
        end

        if type(item) == "table" and item.bag ~= nil and item.slot ~= nil then
            local itemLink = GetContainerItemLink(item.bag, item.slot)
            return itemLink and tonumber(Auctionator.Utilities.ItemIdFromLink(itemLink)) or nil
        end

        return nil
    end
end

if not C_Item.GetStackCount then
    function C_Item.GetStackCount(itemLocation)
        if not itemLocation then
            return nil
        end

        local bag = itemLocation.bag
        local slot = itemLocation.slot

        if bag == nil or slot == nil then
            return nil
        end

        local _, itemCount = GetContainerItemInfo(bag, slot)

        return tonumber(itemCount) or 1
    end
end

if not C_Item.GetItemLink then
    function C_Item.GetItemLink(itemLocation)
        if not itemLocation then
            return nil
        end

        if type(itemLocation) == "number"
            or type(itemLocation) == "string"
        then
            local _, itemLink = GetItemInfo(itemLocation)
            return itemLink
        end

        if type(itemLocation) ~= "table" then
            return nil
        end

        if itemLocation.bag ~= nil and itemLocation.slot ~= nil then
            return GetContainerItemLink(
                itemLocation.bag,
                itemLocation.slot
            )
        end

        if itemLocation.itemID then
            local _, itemLink = GetItemInfo(itemLocation.itemID)
            return itemLink
        end

        return nil
    end
end

if not LootSlotHasItem then
    function LootSlotHasItem(slot)
        if not slot then
            return false
        end

        local texture, itemName = GetLootSlotInfo(slot)

        return texture ~= nil and itemName ~= nil
    end
end

if not GetMerchantItemID then
    function GetMerchantItemID(index)
        if not index then
            return nil
        end

        local itemLink = GetMerchantItemLink(index)

        if not itemLink then
            return nil
        end

        return Auctionator.Utilities.ItemIdFromLink(itemLink)
    end
end

C_MerchantFrame = C_MerchantFrame or {}

if not C_MerchantFrame.GetBuybackItemID then
    function C_MerchantFrame.GetBuybackItemID(slotIndex)
        if not slotIndex then
            return nil
        end

        local itemLink = GetBuybackItemLink(slotIndex)
        if not itemLink then
            return nil
        end

        return Auctionator.Utilities.ItemIdFromLink(itemLink)
    end
end

if not C_MerchantFrame.GetBuybackItemLink then
    function C_MerchantFrame.GetBuybackItemLink(index)
        if not index then
            return nil
        end

        return GetBuybackItemLink(index)
    end
end

if not CreateFrame("Frame").IsForbidden then
    local frameMT = getmetatable(CreateFrame("Frame")).__index

    function frameMT:IsForbidden()
        return false
    end
end

local function ColorComponentToHex(value)
    value = tonumber(value) or 1

    if value < 0 then
        value = 0
    elseif value > 1 then
        value = 1
    end

    return string.format("%02x", math.floor(value * 255 + 0.5))
end

local function EnsureFontColor(globalName, r, g, b)
    local color = _G[globalName]

    if not color then
        color = {
            r = r,
            g = g,
            b = b,
        }

        _G[globalName] = color
    end

    if not color.WrapTextInColorCode then
        function color:WrapTextInColorCode(text)
            local colorCode =
                ColorComponentToHex(self.r) ..
                ColorComponentToHex(self.g) ..
                ColorComponentToHex(self.b)

            return "|cff" .. colorCode .. tostring(text or "") .. "|r"
        end
    end

    return color
end

EnsureFontColor("WHITE_FONT_COLOR", 1, 1, 1)
EnsureFontColor("GREEN_FONT_COLOR", 0, 1, 0)
EnsureFontColor("RED_FONT_COLOR", 1, 0.1, 0.1)
EnsureFontColor("YELLOW_FONT_COLOR", 1, 1, 0)
EnsureFontColor("GRAY_FONT_COLOR", 0.5, 0.5, 0.5)
EnsureFontColor("NORMAL_FONT_COLOR", 1, 0.82, 0)
EnsureFontColor("HIGHLIGHT_FONT_COLOR", 1, 1, 1)
EnsureFontColor("LIGHTBLUE_FONT_COLOR", 0.42, 0.65, 1.0)
EnsureFontColor("ORANGE_FONT_COLOR", 1.0, 0.5, 0.0)
EnsureFontColor("DISABLED_FONT_COLOR", 0.5, 0.5, 0.5)
EnsureFontColor("DIM_RED_FONT_COLOR", 0.8, 0.2, 0.2)
EnsureFontColor("BATTLENET_FONT_COLOR", 0.0, 0.75, 1.0)

C_AuctionHouse = C_AuctionHouse or {}

-- https://wowpedia.fandom.com/wiki/API_C_AuctionHouse.ReplicateItems
if not C_AuctionHouse.ReplicateItems then
    function C_AuctionHouse.ReplicateItems()
        if not QueryAuctionItems or not CanSendAuctionQuery then
            return false
        end

        local canQuery, canQueryAll = CanSendAuctionQuery()

        print(
            "CanSendAuctionQuery:",
            tostring(canQuery),
            tostring(canQueryAll)
        )

        if not canQuery or not canQueryAll then
            return false
        end

        AuctionatorCompat.ReplicatePending = true

        QueryAuctionItems(
            "",     -- name
            nil,    -- minLevel
            nil,    -- maxLevel
            0,      -- inventoryTypeIndex
            0,      -- classIndex
            0,      -- subclassIndex
            0,      -- page
            false,  -- usable
            0,      -- quality
            true    -- getAll
        )

        print("GetAll query sent")
        return true
    end
end

if not C_AuctionHouse.GetNumReplicateItems then
    function C_AuctionHouse.GetNumReplicateItems()
        local shown, total = GetNumAuctionItems("list")

        print(
            "Replicate results:",
            tostring(shown),
            "/",
            tostring(total)
        )

        return tonumber(shown) or 0
    end
end

--https://wowpedia.fandom.com/wiki/API_C_AuctionHouse.GetReplicateItemInfo
if not C_AuctionHouse.GetReplicateItemInfo then
    function C_AuctionHouse.GetReplicateItemInfo(index)
        if index == nil then
            return nil
        end

        -- Retail is based at 0 index, but 3.3.5 at 1
        local legacyIndex = index + 1

        local name,
              texture,
              count,
              quality,
              canUse,
              level,
              levelColHeader,
              minBid,
              minIncrement,
              buyoutPrice,
              bidAmount,
              highBidder,
              bidderFullName,
              owner,
              ownerFullName,
              saleStatus,
              itemId =
            GetAuctionItemInfo("list", legacyIndex)

        if not name then
            return nil
        end

        if not itemId then
            local itemLink = GetAuctionItemLink("list", legacyIndex)

            if itemLink then
                itemId = tonumber(itemLink:match("item:(%d+)"))
            end
        end

        -- Keep the structure
        return name,
               texture,
               count,
               quality,
               canUse,
               level,
               levelColHeader,
               minBid,
               minIncrement,
               buyoutPrice,
               bidAmount,
               highBidder,
               bidderFullName,
               owner,
               ownerFullName,
               saleStatus,
               itemId
    end
end

AuctionatorCompat = AuctionatorCompat or {}

AuctionatorCompat.ReplicatePending = false

AuctionatorCompat.EventMap = {
    REPLICATE_ITEM_LIST_UPDATE = "AUCTION_ITEM_LIST_UPDATE",

    -- Futuras adaptaciones:
    -- OWNED_AUCTIONS_UPDATED = "AUCTION_OWNED_LIST_UPDATE",
    -- AUCTION_CREATED = "NEW_AUCTION_UPDATE",
}

function AuctionatorCompat.GetEventName(eventName)
    return AuctionatorCompat.EventMap[eventName] or eventName
end

function AuctionatorCompat.NormalizeEvent(eventName)
    if eventName == "AUCTION_ITEM_LIST_UPDATE" then
        if AuctionatorCompat.ReplicatePending then
            AuctionatorCompat.ReplicatePending = false
            return "REPLICATE_ITEM_LIST_UPDATE"
        end

        return eventName
    end

    for modernEvent, legacyEvent in pairs(AuctionatorCompat.EventMap) do
        if eventName == legacyEvent then
            return modernEvent
        end
    end

    return eventName
end

if not Mixin then
    function Mixin(object, ...)
        if type(object) ~= "table" then
            return object
        end

        for i = 1, select("#", ...) do
            local mixin = select(i, ...)

            if type(mixin) == "table" then
                for key, value in pairs(mixin) do
                    object[key] = value
                end
            end
        end

        return object
    end
end

if not CreateAndInitFromMixin then
    function CreateAndInitFromMixin(mixin, ...)
        local object = CreateFromMixins(mixin)

        if type(object.Init) == "function" then
            object:Init(...)
        end

        return object
    end
end

if not CreateFromMixins then
    function CreateFromMixins(...)
        local object = {}

        for i = 1, select("#", ...) do
            local mixin = select(i, ...)

            if type(mixin) == "table" then
                for key, value in pairs(mixin) do
                    object[key] = value
                end
            end
        end

        return object
    end
end

function AuctionatorCompat.SetupAuctionFrame()
    if not AuctionFrame then
        return false
    end

    AuctionHouseFrame = AuctionHouseFrame or AuctionFrame

    AuctionHouseFrameTab1 = AuctionHouseFrameTab1 or AuctionFrameTab1
    AuctionHouseFrameTab2 = AuctionHouseFrameTab2 or AuctionFrameTab2
    AuctionHouseFrameTab3 = AuctionHouseFrameTab3 or AuctionFrameTab3

    AuctionHouseFrameBrowseFrame =
        AuctionHouseFrameBrowseFrame or AuctionFrameBrowse

    AuctionHouseFrameBidFrame =
        AuctionHouseFrameBidFrame or AuctionFrameBid

    AuctionHouseFrameAuctionsFrame =
        AuctionHouseFrameAuctionsFrame or AuctionFrameAuctions

        print("AuctionatorCompat.SetupAuctionFrame")

    return true
end

function AuctionatorCompat.CreateAuctionTab(frameName)
    local parent = AuctionHouseFrame or AuctionFrame

    if not parent then
        return nil
    end

    local template

    if AuctionHouseFrameTabTemplate then
        template = "AuctionHouseFrameTabTemplate"
    else
        template = "AuctionTabTemplate"
    end

    return CreateFrame(
        "Button",
        frameName,
        parent,
        template
    )
end

AuctionHouseFrameTab_OnClick =
    AuctionHouseFrameTab_OnClick or AuctionFrameTab_OnClick

FrameUtil = FrameUtil or {}

if not FrameUtil.RegisterFrameForEvents then
    function FrameUtil.RegisterFrameForEvents(frame, events)
        if not frame or type(events) ~= "table" then
            return
        end

        for _, eventName in ipairs(events) do
            frame:RegisterEvent(eventName)
        end
    end
end

if not FrameUtil.UnregisterFrameForEvents then
    function FrameUtil.UnregisterFrameForEvents(frame, events)
        if not frame or type(events) ~= "table" then
            return
        end

        for _, eventName in ipairs(events) do
            frame:UnregisterEvent(eventName)
        end
    end
end