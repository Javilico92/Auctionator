function Auctionator.Events.OnAuctionHouseShow()
    Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow()")

    local frame = _G.AuctionatorAHFrame

    if not frame then
        frame = CreateFrame(
            "Frame",
            "AuctionatorAHFrame",
            AuctionHouseFrame or AuctionFrame,
            "AuctionatorAHFrameTemplate"
        )

        FrameUtil.RegisterFrameForEvents(frame, {
            "AUCTION_HOUSE_SHOW",
            "AUCTION_HOUSE_CLOSED",
        })

        frame:Show()

        local onEvent = frame:GetScript("OnEvent")
        if onEvent then
            onEvent(frame, "AUCTION_HOUSE_SHOW")
        end
    else
        frame:Show()
    end

    print("Width:", frame:GetWidth())
print("Height:", frame:GetHeight())
print("Points:", frame:GetNumPoints())
print("Children:", frame:GetNumChildren())
print("Regions:", frame:GetNumRegions())
end