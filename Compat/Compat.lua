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