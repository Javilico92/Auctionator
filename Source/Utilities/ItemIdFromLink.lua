function Auctionator.Utilities.ItemIdFromLink(link) -- 335 ATM this is mixing Quest, Items and Spells in Hyperlink, do a better handle for items
    -- local _, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
    -- local _, itemId = strsplit(":", itemString)
    if type(link) ~= "string" then
        return nil
    end

    local itemId = link:match("item:(%d+)")
    if itemId then
        return tonumber(itemId)
    end

    return nil
end