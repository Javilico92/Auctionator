function Auctionator.Events.PlayerEnteringWorld()
  Auctionator.Debug.Message("Auctionator.Events.PlayerEnteringWorld")

end

auctionatorInited = false

-----------------------------------------
function Atr_OnPlayerEnteringWorld()
  Auctionator.Debug.Message( 'Atr_OnPlayerEnteringWorld' )
  Auctionator.Utilities.Message("Pre-release version. Limited functionality due to 8.3 AH updates.");

  zz ("auctionatorInited = ", auctionatorInited);

  if (auctionatorInited == false) then
    auctionatorInited = true;

    Atr_InitOptionsPanels()
    Atr_InitToolTips()

    if (RegisterAddonMessagePrefix) then
      RegisterAddonMessagePrefix ("ATR")
    end

  end
end