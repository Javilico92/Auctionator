AUCTIONATOR_LOCALES = AUCTIONATOR_LOCALES or {}

-- The current 3.3.5 Spanish UI uses the same strings for esES and esMX.
-- This remains a separate locale table so it can diverge later without
-- changing any addon code.
AUCTIONATOR_LOCALES.esMX = function()
  if AUCTIONATOR_LOCALES.esES then
    return AUCTIONATOR_LOCALES.esES()
  end
  return {}
end
