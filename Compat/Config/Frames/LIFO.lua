  local Global = AuctionatorXMLCompat.Global
  local Number = AuctionatorXMLCompat.Number
  local String = AuctionatorXMLCompat.String

  AuctionatorXMLCompat.Register(
    "AuctionatorConfigLIFOFrame",
    {
      mixins = {
        AuctionatorConfigLIFOFrameMixin,
      },

      onload = "OnLoad",

      children = {
        TitleArea = {
          suffix = "TitleArea",

          mixins = {
            AuctionatorConfigTitleFrameMixin,
          },

          values = {
            titleText = Global(
              "AUCTIONATOR_L_CONFIG_SELLING_LIFO_HEADER"
            ),

            subTitleText = Global(
              "AUCTIONATOR_L_CONFIG_SELLING_LIFO_TEXT"
            ),
          },

          onload = "OnLoad",
        },

        CommodityDurationGroup = {
          suffix = "CommodityDurationGroup",

          mixins = {
            AuctionatorConfigRadioButtonGroupMixin,
          },

          values = {
            groupHeadingText = Global(
              "AUCTIONATOR_L_DEFAULT_AUCTION_DURATION"
            ),
          },

          children = {
            Duration12 = {
              suffix = "Duration12",

              mixins = {
                AuctionatorConfigTooltipMixin,
                AuctionatorConfigRadioButtonMixin,
              },

              values = {
                labelText = Global(
                  "AUCTIONATOR_L_AUCTION_DURATION_12"
                ),

                value = Number(12),
              },

              onload = "OnLoad",
            },

            Duration24 = {
              suffix = "Duration24",

              mixins = {
                AuctionatorConfigTooltipMixin,
                AuctionatorConfigRadioButtonMixin,
              },

              values = {
                labelText = Global(
                  "AUCTIONATOR_L_AUCTION_DURATION_24"
                ),

                value = Number(24),
              },

              onload = "OnLoad",
            },

            Duration48 = {
              suffix = "Duration48",

              mixins = {
                AuctionatorConfigTooltipMixin,
                AuctionatorConfigRadioButtonMixin,
              },

              values = {
                labelText = Global(
                  "AUCTIONATOR_L_AUCTION_DURATION_48"
                ),

                value = Number(48),
              },

              onload = "OnLoad",
            },
          },

          onload = "InitializeRadioButtonGroup",
        },

        CommoditySalesPreference = {
          suffix = "CommoditySalesPreference",

          mixins = {
            AuctionatorConfigRadioButtonGroupMixin,
          },

          values = {
            groupHeadingText = Global(
              "AUCTIONATOR_L_SALES_PREFERENCE"
            ),
          },

          children = {
            PreferencePercentage = {
              suffix = "PreferencePercentage",

              mixins = {
                AuctionatorConfigTooltipMixin,
                AuctionatorConfigRadioButtonMixin,
              },

              values = {
                labelText = Global(
                  "AUCTIONATOR_L_PERCENTAGE"
                ),

                value = String("percentage"),
              },

              onload = "OnLoad",
            },

            PreferenceStatic = {
              suffix = "PreferenceStatic",

              mixins = {
                AuctionatorConfigTooltipMixin,
                AuctionatorConfigRadioButtonMixin,
              },

              values = {
                labelText = Global(
                  "AUCTIONATOR_L_SET_VALUE"
                ),

                value = String("static"),
              },

              onload = "OnLoad",
            },
          },

          onload = "InitializeRadioButtonGroup",
        },

        CommodityUndercutPercentage = {
          suffix = "CommodityUndercutPercentage",

          mixins = {
            AuctionatorConfigTooltipMixin,
            AuctionatorConfigNumericInputMixin,
          },

          values = {
            labelText = Global(
              "AUCTIONATOR_L_PERCENTAGE_SUFFIX"
            ),

            tooltipTitleText = Global(
              "AUCTIONATOR_L_PERCENTAGE_TOOLTIP_HEADER"
            ),

            tooltipText = Global(
              "AUCTIONATOR_L_PERCENTAGE_TOOLTIP_TEXT"
            ),
          },

          onload = "OnLoad",
        },

        CommodityUndercutValue = {
          suffix = "CommodityUndercutValue",

          mixins = {
            AuctionatorConfigTooltipMixin,
            AuctionatorConfigMoneyInputMixin,
          },

          values = {
            labelText = Global(
              "AUCTIONATOR_L_SET_VALUE_SUFFIX"
            ),

            tooltipTitleText = Global(
              "AUCTIONATOR_L_UNDERCUT_TOOLTIP_HEADER"
            ),

            tooltipText = Global(
              "AUCTIONATOR_L_UNDERCUT_TOOLTIP_TEXT"
            ),
          },

          onload = "OnLoad",
        },
      },
    }
  )