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