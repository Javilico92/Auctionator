function Auctionator.Events.OnAuctionHouseShow()
    Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow()")
    
    Auctionator.AH.Initialize()

    Auctionator.State.AuctionatorFrame = _G.AuctionatorAHFrame

    if Auctionator.State.AuctionatorFrame == nil then
        Auctionator.State.AuctionatorFrame = CreateFrame(
            "Frame",
            "AuctionatorAHFrame",
            AuctionHouseFrame or AuctionFrame,
            "AuctionatorAHFrameTemplate"
        )

        FrameUtil.RegisterFrameForEvents(Auctionator.State.AuctionatorFrame, {
            "AUCTION_HOUSE_SHOW",
            "AUCTION_HOUSE_CLOSED",
        })

        Auctionator.State.AuctionatorFrame:Show()

        local onEvent = Auctionator.State.AuctionatorFrame:GetScript("OnEvent")
        if onEvent then
            onEvent(Auctionator.State.AuctionatorFrame, "AUCTION_HOUSE_SHOW")
        end
    else
        Auctionator.State.AuctionatorFrame:Show()
    end

    print("Width:", Auctionator.State.AuctionatorFrame:GetWidth())
print("Height:", Auctionator.State.AuctionatorFrame:GetHeight())
print("Points:", Auctionator.State.AuctionatorFrame:GetNumPoints())
print("Children:", Auctionator.State.AuctionatorFrame:GetNumChildren())
print("Regions:", Auctionator.State.AuctionatorFrame:GetNumRegions())
end