{
  general = {
    default_ui = {
      prefix = " ",
      suffix = "",
    },
    focus_ui = {
      prefix = "▸",
      suffix = "",
      style = {
        fg = {
          Rgb = {
            170,
            150,
            130,
          },
        },
        bg = {
          Rgb = {
            50,
            50,
            50,
          },
        },
        add_modifiers = {
          "Bold",
        },
      },
    },
    selection_ui = {
      prefix = " ",
      suffix = "",
      style = {
        fg = {
          Rgb = {
            70,
            70,
            70,
          },
        },
        add_modifiers = {
          "Bold",
          "CrossedOut",
        },
      },
    },
    sort_and_filter_ui = {
      separator = {
        format = " » ",
      },
    },
    panel_ui = {
      default = {
        title = {
          style = {
            bg = {
              Rgb = {
                170,
                150,
                130,
              },
            },
            fg = {
              Rgb = {
                40,
                40,
                40,
              },
            },
            add_modifiers = {
              "Bold",
            },
          },
        },
        style = {
          fg = {
            Rgb = {
              170,
              150,
              130,
            },
          },
          bg = {
            Rgb = {
              33,
              33,
              33,
            },
          },
        },
        borders = {},
      },
      help_menu = {
        style = {
          bg = {
            Rgb = {
              26,
              26,
              26,
            },
          },
        },
      },
    },
  },
  layouts = {
    custom = {},
    builtin = {
      default = {
        Vertical = {
          config = {
            constraints = {
              {
                Length = 2,
              },
              {
                Min = 1,
              },
              {
                Length = 2,
              },
            },
          },
          splits = {
            {
              SortAndFilter = nil,
            },
            {
              Horizontal = {
                config = {
                  constraints = {
                    {
                      Percentage = 20,
                    },
                    {
                      Percentage = 60,
                    },
                    {
                      Percentage = 20,
                    },
                  },
                },
                splits = {
                  {
                    Selection = nil,
                  },
                  {
                    Table = nil,
                  },
                  {
                    HelpMenu = nil,
                  },
                },
              },
            },
            {
              InputAndLogs = nil,
            },
          },
        },
      },
      no_help = {
        Vertical = {
          config = {
            constraints = {
              {
                Length = 2,
              },
              {
                Min = 1,
              },
            },
          },
          splits = {
            {
              SortAndFilter = nil,
            },
            {
              Horizontal = {
                config = {
                  constraints = {
                    {
                      Percentage = 80,
                    },
                    {
                      Percentage = 20,
                    },
                  },
                },
                splits = {
                  {
                    Table = nil,
                  },
                  {
                    Selection = nil,
                  },
                },
              },
            },
            {
              InputAndLogs = nil,
            },
          },
        },
      },
      no_selection = {
        Vertical = {
          config = {
            constraints = {
              {
                Length = 2,
              },
              {
                Min = 1,
              },
              {
                Length = 2,
              },
            },
          },
          splits = {
            {
              SortAndFilter = nil,
            },
            {
              Horizontal = {
                config = {
                  constraints = {
                    {
                      Percentage = 80,
                    },
                    {
                      Percentage = 20,
                    },
                  },
                },
                splits = {
                  {
                    Table = nil,
                  },
                  {
                    HelpMenu = nil,
                  },
                },
              },
            },
            {
              InputAndLogs = nil,
            },
          },
        },
      },
      no_help_no_selection = {
        Vertical = {
          config = {
            constraints = {
              {
                Length = 2,
              },
              {
                Min = 1,
              },
              {
                Length = 2,
              },
            },
          },
          splits = {
            {
              SortAndFilter = nil,
            },
            {
              Table = nil,
            },
            {
              InputAndLogs = nil,
            },
          },
        },
      },
    },
  },
  node_types = {
    directory = {
      meta = {
        icon = "",
      },
    },
    file = {
      meta = {
        icon = "",
      },
    },
    symlink = {
      meta = {
        icon = "",
      },
    },
    extension = {
      lock = {
        meta = {
          icon = "🔒",
        },
      },
      md = {
        meta = {
          icon = "",
        },
      },
      toml = {
        meta = {
          icon = "",
        },
      },
      rs = {
        meta = {
          icon = "🦀",
        },
      },
      elm = {
        meta = {
          icon = "",
        },
      },
      java = {
        meta = {
          icon = "♨",
        },
      },
      kt = {
        meta = {
          icon = "🅺",
        },
      },
      lua = {
        meta = {
          icon = "🌙",
        },
      },
      nix = {
        meta = {
          icon = "❄️",
        },
      },
      js = {
        meta = {
          icon = "",
        },
      },
      py = {
        meta = {
          icon = "🐍",
        },
      },
      txt = {
        meta = {
          icon = "",
        },
      },
      csv = {
        meta = {
          icon = "",
        },
      },
      xlsx = {
        meta = {
          icon = "",
        },
      },
      odf = {
        meta = {
          icon = "",
        },
      },
      yml = {
        meta = {
          icon = "⚙",
        },
      },
      yaml = {
        meta = {
          icon = "⚙",
        },
      },
    },
    special = {
      ["docker-compose.yml"] = {
        meta = {
          icon = "🐳",
        },
      },
      [".git"] = {
        meta = {
          icon = "",
        },
      },
      node_modules = {
        meta = {
          icon = "",
        },
      },
    },
  },
}
