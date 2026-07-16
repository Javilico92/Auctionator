local Global = AuctionatorXMLCompat.Global

AuctionatorXMLCompat.Register(
  "AuctionatorConfigBasicOptionsFrame",
  {
    mixins = {
      AuctionatorPanelConfigMixin,
      AuctionatorConfigBasicOptionsFrameMixin,
    },

    onload = "OnLoad",

    children = {
      TitleArea = {
        suffix = "TitleArea",
        mixins = {
          AuctionatorConfigTitleFrameMixin,
        },
        values = {
          titleText =
            Global("AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY"),

          subTitleText =
            Global("AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_TEXT"),
        },
        onload = "OnLoad",
      },

      ShoppingListHeading = {
        suffix = "ShoppingListHeading",
        mixins = {
          AuctionatorConfigHeadingMixin,
        },
        values = {
          headingText =
            Global("AUCTIONATOR_L_CONFIG_SHOPPING_LIST"),
        },
        onload = "OnLoad",
      },

      AutoListSearch = {
        suffix = "AutoListSearch",
        mixins = {
          AuctionatorConfigTooltipMixin,
          AuctionatorConfigCheckboxMixin,
        },
        values = {
          labelText =
            Global("AUCTIONATOR_L_CONFIG_AUTO_LIST_SEARCH"),

          tooltipTitleText =
            Global(
              "AUCTIONATOR_L_CONFIG_AUTO_LIST_SEARCH_TOOLTIP_HEADER"
            ),

          tooltipText =
            Global(
              "AUCTIONATOR_L_CONFIG_AUTO_LIST_SEARCH_TOOLTIP_TEXT"
            ),
        },
        onload = "OnLoad",
      },

      AuctionChatLog = {
        suffix = "AuctionChatLog",
        mixins = {
          AuctionatorConfigTooltipMixin,
          AuctionatorConfigCheckboxMixin,
        },
        values = {
          labelText =
            Global("AUCTIONATOR_L_CONFIG_CHAT_LOG"),

          tooltipTitleText =
            Global(
              "AUCTIONATOR_L_CONFIG_CHAT_LOG_TOOLTIP_HEADER"
            ),

          tooltipText =
            Global(
              "AUCTIONATOR_L_CONFIG_CHAT_LOG_TOOLTIP_TEXT"
            ),
        },
        onload = "OnLoad",
      },

      ScanningHeading = {
        suffix = "ScanningHeading",
        mixins = {
          AuctionatorConfigHeadingMixin,
        },
        values = {
          headingText =
            Global("AUCTIONATOR_L_CONFIG_SCANNING"),
        },
        onload = "OnLoad",
      },

      Autoscan = {
        suffix = "Autoscan",
        mixins = {
          AuctionatorConfigTooltipMixin,
          AuctionatorConfigCheckboxMixin,
        },
        values = {
          labelText =
            Global("AUCTIONATOR_L_CONFIG_AUTOSCAN"),

          tooltipTitleText =
            Global(
              "AUCTIONATOR_L_CONFIG_AUTOSCAN_TOOLTIP_HEADER"
            ),

          tooltipText =
            Global(
              "AUCTIONATOR_L_CONFIG_AUTOSCAN_TOOLTIP_TEXT"
            ),
        },
        onload = "OnLoad",
      },

      AlternateScan = {
        suffix = "AlternateScan",
        mixins = {
          AuctionatorConfigTooltipMixin,
          AuctionatorConfigCheckboxMixin,
        },
        values = {
          labelText =
            Global("AUCTIONATOR_L_CONFIG_ALTERNATE_SCAN"),

          tooltipTitleText =
            Global(
              "AUCTIONATOR_L_CONFIG_ALTERNATE_SCAN_HEADER"
            ),

          tooltipText =
            Global(
              "AUCTIONATOR_L_CONFIG_ALTERNATE_SCAN_TEXT"
            ),
        },
        onload = "OnLoad",
      },

      CancellingHeading = {
        suffix = "CancellingHeading",
        mixins = {
          AuctionatorConfigHeadingMixin,
        },
        values = {
          headingText =
            Global("AUCTIONATOR_L_CANCELLING_TAB"),
        },
        onload = "OnLoad",
      },

      UndercutScanPetsGear = {
        suffix = "UndercutScanPetsGear",
        mixins = {
          AuctionatorConfigTooltipMixin,
          AuctionatorConfigCheckboxMixin,
        },
        values = {
          labelText =
            Global("AUCTIONATOR_L_CONFIG_UNDERCUT_SCAN_NOT_LIFO"),

          tooltipTitleText =
            Global(
              "AUCTIONATOR_L_CONFIG_UNDERCUT_SCAN_NOT_LIFO_TOOLTIP_HEADER"
            ),

          tooltipText =
            Global(
              "AUCTIONATOR_L_CONFIG_UNDERCUT_SCAN_NOT_LIFO_TOOLTIP_TEXT"
            ),
        },
        onload = "OnLoad",
      },
    },
  }
)