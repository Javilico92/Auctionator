AUCTIONATOR_LOCALES = AUCTIONATOR_LOCALES or {}

AUCTIONATOR_LOCALES.esES = function()
  local L = {}

  -- Main tabs and option categories
  L["AUCTIONATOR_TAB"] = "Auctionator"
  L["CONFIG_SHOPPING_CATEGORY"] = "Compras"
  L["CONFIG_SELLING_CATEGORY"] = "Ventas"
  L["CONFIG_SCANNING"] = "Configuración de escaneo completo"
  L["CANCELLING_TAB"] = "Cancelar"

  -- Shared UI
  L["SEARCH"] = "Buscar"
  L["SEARCH_COLON"] = "Buscar:"
  L["TOTAL_VALUE"] = "Valor total:"
  L["RESULTS_NAME_COLUMN"] = "Nombre del objeto"
  L["QUANTITY"] = "Cantidad subastada"
  L["UNIT_PRICE"] = "Precio por unidad"
  L["TIME_LEFT"] = "Tiempo restante"
  L["IS_UNDERCUT"] = "Descuento"
  L["ITEMS_AHEAD"] = "Objs. delante"
  L["UNDERCUT_YES"] = "Sí"
  L["UNDERCUT_NO"] = "No"
  L["STOP"] = "Detener"
  L["UNKNOWN"] = "Desconocido"

  -- Cancelling tab (3.3.5 modern UI)
  L["CANCELLING_CHECK_PRICES"] = "Comprobar precios"
  L["CANCELLING_CHECKING_X_OF_X"] = "Comprobando %d de %d..."
  L["CANCELLING_COMPLETE"] = "Comprobación terminada"
  L["CANCELLING_STOPPED"] = "Comprobación detenida"
  L["CANCELLING_NO_AUCTIONS"] = "No tienes subastas activas."
  L["CANCELLING_NO_RESULTS"] = "No hay subastas que coincidan con la búsqueda."
  L["CANCELLING_PACK"] = "pack"
  L["CANCELLING_PACKS"] = "packs"
  L["CANCELLING_OF"] = "de"
  L["CANCELLING_SUMMARY"] = "%d filas · %d subastas activas"

  -- Auctionator information tab
  L["OPEN_ADDON_OPTIONS"] = "Abrir las opciones del addon"
  L["FULL_SCAN"] = "Escaneo completo"
  L["OPEN_ADDON_OPTIONS_TOOLTIP"] = "Abre Interfaz > AddOns > Auctionator."
  L["FULL_SCAN_TOOLTIP_WOTLK"] = "Clic: escaneo rápido.\nMayús + clic: escaneo completo por páginas."
  L["FULL_SCAN_PAGE_BY_PAGE"] = "Escaneo por páginas"
  L["FULL_SCAN_FAST_UNAVAILABLE"] = "Escaneo rápido no disponible"
  L["FULL_SCAN_FAST_FAILED_STATUS"] = "El servidor no devolvió el escaneo rápido."
  L["FULL_SCAN_FAST_FAILED_MESSAGE"] = "Este reino anuncia que admite el escaneo rápido, pero no ha devuelto datos de subastas utilizables. Auctionator ha desactivado el escaneo rápido durante esta sesión.\n\n¿Quieres iniciar un escaneo página por página? En una casa de subastas grande puede tardar varios minutos."
  L["AUTHOR_HEADER"] = "Autor"
  L["VERSION_HEADER"] = "Versión"
  L["AVAILABLE_LANGUAGES"] = "Idiomas disponibles"
  L["TRANSLATORS_HEADER"] = "Traductores"

  -- Shopping progressive search
  L["LOAD_MORE_RESULTS"] = "Cargar más resultados"
  L["LOADING"] = "Cargando..."
  L["SHOPPING_SEARCH_TITLE"] = "Buscando en la casa de subastas..."
  L["SHOPPING_SEARCH_SUBTITLE"] = "Esto puede tardar unos segundos."
  L["SHOPPING_SEARCHING_FOR"] = "Buscando: |cffffd200%s|r"
  L["SHOPPING_PREPARING_SEARCH"] = "Preparando búsqueda..."
  L["SHOPPING_PAGE_X_OF_X"] = "Página %d de %d"
  L["SHOPPING_ONE_AUCTION_FOUND"] = "1 subasta encontrada"
  L["SHOPPING_AUCTIONS_FOUND"] = "%d subastas encontradas"
  L["SHOPPING_SEARCH_COMPLETE"] = "Búsqueda completada"
  L["SHOPPING_RESULTS_AVAILABLE"] = "Los resultados ya están disponibles."
  L["SHOPPING_ONE_RESULT_FOUND"] = "1 resultado encontrado"
  L["SHOPPING_RESULTS_FOUND"] = "%d resultados encontrados"

  -- Selling search overlay
  L["SEARCHING"] = "Buscando"
  L["WAITING_TO_SEND_QUERY"] = "Preparando consulta"
  L["SEARCHING_PAGE_X"] = "Buscando página %d"
  L["ANALYZING_RESULTS"] = "Analizando resultados"
  L["SEARCHING_AUCTION_HOUSE"] = "Buscando en la casa de subastas"

  -- Time-left fallbacks (normally supplied by Blizzard globals)
  L["TIME_LEFT_VERY_SHORT"] = "Muy corto"
  L["TIME_LEFT_SHORT"] = "Corto"
  L["TIME_LEFT_LONG"] = "Largo"
  L["TIME_LEFT_VERY_LONG"] = "Muy largo"

  return L
end
