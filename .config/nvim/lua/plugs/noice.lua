local M = {}

local D = require("dev")
local noice = D.npcall(require, "noice")
if not noice then
    return
end

local utils = require("common.utils")
local map = utils.map
local mini = require("noice.config.views").defaults.mini

local fn = vim.fn
local cmd = vim.cmd
---Setup `noice.nvim`
function M.setup()
    --  ╭──────────────────────────────────────────────────────────╮
    --  │                          Views                           │
    --  ╰──────────────────────────────────────────────────────────╯
    -- BACKENDS: popup, split, notify, virtualtext, mini, notify_send
    --
    -- VIEWS:
    -- notify         : nvim-notify with level=nil, replace=false, merge=false
    -- split          : horizontal split
    -- vsplit         : vertical split
    -- popup          : simple popup
    -- mini           : minimal view, by default bottom right, right-aligned
    -- cmdline        : bottom line, similar to the classic cmdline
    -- cmdline_popup  : fancy cmdline popup, with different styles according to the cmdline mode
    -- cmdline_output : split used by config.presets.cmdline_output_to_split
    -- messages       : split use for :messages
    -- confirm        : popup used for confirm events
    -- hover          : popup used for lsp signature help and hover
    -- popupmenu      : special view with the options used to render the popupmenu when backend is nui

    -- NOTIFY:
    -- title   : title to be used for the notification. Uses Message.title if available
    -- replace : true = msgs routing to the same replace existing messages instead of new each time
    -- merge   : Merge messages into one Notification or create separate notifications
    -- level   : notification level. Uses Message.level if available

    -- ROUTE:
    -- view   : one of the views (built-in or custom)
    -- filter : a filter for messages matching this route
    -- opts   : options for the view and the route

    -- FORMAT:
    -- level    : message level with optional `icon` and `hl_group` per level
    -- text     : any text with optional `hl_group`
    -- title    : message title with optional `hl_group`
    -- event    : message event with optional `hl_group`
    -- kind     : message kind with optional `hl_group`
    -- date     : formatted date with optional date format string
    -- message  : message content itself with optional `hl_group` to override message highlights
    -- confirm  : only useful for `confirm` messages. Will format the choices as buttons
    -- cmdline  : will render the cmdline in the message that generated the message
    -- progress : progress bar used by lsp progress
    -- spinner  : spinners used by lsp progress
    -- data     : render any custom data from `Message.opts`. Useful with `vim.notify`
    --
    -- FORMAT_DEFINITIONS:
    -- {
    --   -- default format
    --   default = { "{level} ", "{title} ", "{message}" },
    --   -- default format for vim.notify views
    --   notify = { "{message}" },
    --   -- default format for the history
    --   details = {
    --     "{level} ",
    --     "{date} ",
    --     "{event}",
    --     { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
    --     " ",
    --     "{title} ",
    --     "{cmdline} ",
    --     "{message}",
    --   },
    --   telescope = ..., -- formatter used to display telescope results
    --   telescope_preview = ..., -- formatter used to preview telescope results
    --   lsp_progress = ..., -- formatter used by lsp progress
    --   lsp_progress_done = ..., -- formatter used by lsp progress
    -- }
    --
    -- EXAMPLE:
    -- -- skip search_count messages instead of showing them as virtual text
    -- require("noice").setup({
    --   routes = {
    --     {
    --       filter = { event = "msg_show", kind = "search_count" },
    --       opts = { skip = true },
    --     },
    --   },
    -- })
    --
    -- -- always route any messages with more than 20 lines to the split view
    -- require("noice").setup({
    --   routes = {
    --     {
    --       view = "split",
    --       filter = { event = "msg_show", min_height = 20 },
    --     },
    --   },
    -- })

    -- KIND:
    -- "" (empty)          Unknown (consider a feature-request: |bugs|)
    --     "confirm"       |confirm()| or |:confirm| dialog
    --     "confirm_sub"   |:substitute| confirm dialog |:s_c|
    --     "emsg"          Error (|errors|, internal error, |:throw|, …)
    --     "echo"          |:echo| message
    --     "echomsg"       |:echomsg| message
    --     "echoerr"       |:echoerr| message
    --     "lua_error"     Error in |:lua| code
    --     "rpc_error"     Error response from |rpcrequest()|
    --     "return_prompt" |press-enter| prompt after a multiple messages
    --     "quickfix"      Quickfix navigation message
    --     "search_count"  Search count message ("S" flag of 'shortmess')
    --     "wmsg"          Warning ("search hit BOTTOM", |W10|, …)

    -- MSG_EVENT:
    -- msg_show
    -- msg_clear
    -- msg_showmode
    -- msg_showcmd
    -- msg_ruler
    -- msg_history_show
    -- msg_history_clear

    -- MSG_KIND:
    -- == ECHO ==
    -- "",      -- (empty) Unknown (consider a feature-request: |bugs|)
    -- echo,    --  |:echo| message
    -- echomsg, -- |:echomsg| message
    -- == INPUT RELATED ==
    -- confirm,       -- |confirm()| or |:confirm| dialog
    -- confirm_sub,   -- |:substitute| confirm dialog |:s_c|
    -- return_prompt, -- |press-enter| prompt after a multiple messages
    -- == ERROR/WARNINGS ==
    -- emsg,      --  Error (|errors|, internal error, |:throw|, …)
    -- echoerr,   -- |:echoerr| message
    -- lua_error, -- Error in |:lua| code
    -- rpc_error, -- Error response from |rpcrequest()|
    -- wmsg       --  Warning ("search hit BOTTOM", |W10|, …)
    -- == HINTS ==
    -- quickfix      -- Quickfix navigation message
    -- search_count  -- Search count message ("S" flag of 'shortmess')

    local top_right =
        vim.tbl_deep_extend(
        "force",
        mini,
        {
            view = "mini",
            timeout = 6000,
            zindex = 60,
            relative = "editor",
            position = {
                row = "8%",
                col = "100%"
            },
            size = {
                height = "auto",
                width = "auto"
                -- max_height = 20
                -- min_width = 10,
            },
            win_options = {
                winhighlight = {
                    Normal = "NormalFloat", -- change to NormalFloat to make normal
                    FloatBorder = "NoicePopupmenuBorder", -- border highlight
                    CursorLine = "", -- used for highlighting the selected item
                    PmenuMatch = "NoicePopupmenuMatch" -- part of the item that matches input
                },
                winblend = 10,
                wrap = true,
                linebreak = true
            },
            border = {
                style = "rounded",
                padding = {0, 1},
                text = {
                    top = "Messages"
                }
            }
        }
    )

    local routes = {
        --  ╭───────╮
        --  │ Skips │
        --  ╰───────╯
        {
            opts = {skip = true},
            filter = {
                any = {
                    {event = "msg_show", find = "%[w%]"}, -- Writing a file
                    {event = "msg_show", find = "%d+ lines indented ?$"},
                    {event = "msg_show", find = "%d+ lines to indent... ?$"},
                    {event = "msg_show", find = "No active Snippet"},
                    {event = "msg_show", kind = "redraw"},
                    {event = "msg_show", kind = "search_count"},
                    {event = "msg_show", find = "^/[^/]+$"}, -- search display
                    {event = "msg_show", find = "/[^/]+/[^ ]+ %d+L, %d+B"},
                    {event = "msg_show", kind = "emsg", find = "Pattern not found"} -- search term is not found
                }
            }
        },
        --  ╭───────╮
        --  │ Split │
        --  ╰───────╯
        {
            view = "split",
            filter = {
                any = {
                    {min_width = 500},
                    -- always route any messages with more than 20 lines to the split view
                    {event = "msg_show", min_height = 20},
                    {event = "msg_show", find = "Last set from .+ line %d+"},
                    {event = "msg_show", find = "No mapping found"},
                    {event = "msg_show", find = "Last set from Lua"}, -- result of verbose <cmd>
                    {event = "msg_show", find = "^/.+/"} -- filepath
                }
            }
        },
        --  ╭────────╮
        --  │ Notify │
        --  ╰────────╯
        {
            view = "notify",
            filter = {
                any = {
                    {event = "msg_show", kind = "emsg"},
                    {event = "msg_show", kind = "echoerr"},
                    {event = "msg_show", kind = "lua_error"},
                    {event = "msg_show", kind = "rpc_error"},
                    {event = "msg_show", kind = "wmsg"}
                }
            }
        },
        --  ╭──────╮
        --  │ Mini │
        --  ╰──────╯
        {
            view = "mini",
            filter = {
                any = {
                    {event = "msg_show", kind = "quickfix"},
                    {event = "msg_show", kind = "info", find = "%[tree%-sitter%]"},
                    {event = "msg_show", kind = "info", find = "%[nvim%-treesitter%]"},
                    {event = "notify", kind = "info", find = "%[mason%-lspconfig.*%]"},
                    {event = "msg_show", kind = "return_prompt"},
                    {event = "notify", kind = "info", find = "packer.nvim"},
                    {event = "notify", kind = "info", find = "%[mason%-tool%-installer%]"},
                    {event = "notify", kind = "info", find = "was successfully installed"},
                    {event = "notify", kind = "info", find = "was successfully uninstalled"},
                    {event = "msg_show", find = "Unception prevented inception!"},
                    {event = "msg_show", kind = "echo", find = "^%[VM%] *$"},
                    {event = "msg_show", kind = "echo", max_length = 1}
                }
            }
        },
        --  ╭───────────────────────────────────╮
        --  │ Hijack notifications to top right │
        --  ╰───────────────────────────────────╯
        {
            view = "top_right",
            filter = {
                any = {
                    {event = "msg_show", find = "%d+ fewer lines"},
                    {event = "msg_show", find = "%d+ more lines"},
                    {event = "msg_show", find = "%d+ changes?; before"},
                    {event = "msg_show", find = "%d+ changes?; after"},
                    {event = "msg_show", find = "%d+ more lines?; before"},
                    {event = "msg_show", find = "%d+ more lines?; after"},
                    {event = "msg_show", find = "%d+ lines? less; before"},
                    {event = "msg_show", find = "%d+ changes; before #%d+  %d+ seconds ago"},
                    {event = "msg_show", find = "Already at newest change"},
                    {event = "msg_show", find = "%d+ lines >ed %d+ time"},
                    {event = "msg_show", find = "%d+ lines <ed %d+ time"},
                    {event = "msg_show", find = "search hit BOTTOM, continuing at TOP"},
                    {event = "msg_show", find = "%d+ lines yanked"},
                    {event = "msg_show", find = "fetching"},
                    {event = "msg_show", find = "successfully fetched all PR state"},
                    {event = "msg_show", find = "Hunk %d+ of %d+"},
                    {event = "msg_showmode", find = "Recording @%w$"} -- shows macro recording
                    -- "%[master .+%] check[\r%s]+%d+ files? changed, %d+ insertions?",
                }
            }
        },
        --  ╭─────────╮
        --  │ Confirm │
        --  ╰─────────╯
        {
            view = "confirm",
            filter = {
                find = "OK to remove"
            }
        }
    }

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                          Setup                           │
    --  ╰──────────────────────────────────────────────────────────╯
    noice.setup(
        {
            --  ╭─────────╮
            --  │ cmdline │
            --  ╰─────────╯
            cmdline = {
                enabled = true, -- enables the Noice cmdline UI
                view = "cmdline", -- view for rendering the cmdline. `cmdline` = Classic
                opts = {buf_options = {filetype = "vim"}}, -- enable syntax highlighting in the cmdline
                icons = {
                    ["/"] = {icon = " ", hl_group = "DiagnosticWarn"},
                    ["?"] = {icon = " ", hl_group = "DiagnosticWarn"},
                    [":"] = {icon = " ", hl_group = "DiagnosticInfo", firstc = false}
                },
                win_options = {
                    winhighlight = {
                        Normal = "Normal", -- change to NormalFloat to make normal
                        FloatBorder = "FloatBorder", -- border highlight
                        CursorLine = "" -- used for highlighting the selected item
                    },
                    winblend = 10
                },
                ---@type table<string, CmdlineFormat>
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = {pattern = "^:", icon = "", lang = "vim"},
                    search_down = {
                        kind = "Search",
                        pattern = "^/",
                        icon = " ",
                        lang = "regex",
                        view = "cmdline"
                    },
                    search_up = {
                        kind = "Search",
                        pattern = "^%?",
                        icon = " ",
                        lang = "regex",
                        view = "cmdline"
                    },
                    filter = {pattern = "^:%s*!", icon = "$", lang = "bash"},
                    lua = {pattern = "^:%s*lua%s+", icon = "", lang = "lua", view = "cmdline"},
                    help = {pattern = "^:%s*he?l?p?%s+", icon = "", view = "cmdline"},
                    inspect = {
                        conceal = true,
                        icon = " ",
                        lang = "lua",
                        pattern = "^:%s*lua =%s*"
                    },
                    input = {} -- Used by input()
                }
            },
            --  ╭──────────╮
            --  │ messages │
            --  ╰──────────╯
            messages = {
                -- NOTE: If you enable messages, then the cmdline is enabled automatically.
                enabled = true, -- enables the Noice messages UI
                view = "notify", -- default view for messages
                view_error = "notify", -- view for errors
                view_warn = "notify", -- view for warnings
                view_history = "split", -- view for :messages
                view_search = "virtualtext" -- view for search count messages. Set to `false` to disable
            },
            --  ╭───────────╮
            --  │ popupmenu │
            --  ╰───────────╯
            popupmenu = {
                enabled = true, -- enables the Noice popupmenu UI
                ---@type 'nui'|'cmp'
                backend = "nui", -- backend to use to show regular cmdline completions
                ---@type NoicePopupmenuItemKind|false
                -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
                kind_icons = {} -- set to `false` to disable icons
            },
            --  ╭──────────╮
            --  │ redirect │
            --  ╰──────────╯
            -- default options for require('noice').redirect
            -- see the section on Command Redirection
            ---@type NoiceRouteConfig
            redirect = {
                view = "popup",
                filter = {event = "msg_show"}
            },
            --  ╭──────────╮
            --  │ commands │
            --  ╰──────────╯
            -- You can add any custom commands below that will be available with `:Noice command`
            ---@type table<string, NoiceCommand>
            commands = {
                history = {
                    -- options for the message history that you get with `:Noice`
                    view = "split",
                    opts = {enter = true, format = "details"},
                    filter = {
                        any = {
                            {event = "notify"},
                            {error = true},
                            {warning = true},
                            {event = "msg_show", kind = {""}},
                            {event = "lsp", kind = "message"},
                            {
                                event = {"msg_show", "notify"},
                                ["not"] = {
                                    kind = {"search_count", "echo"}
                                }
                            }
                        }
                    }
                },
                -- :Noice last
                last = {
                    view = "popup",
                    opts = {enter = true, format = "details"},
                    filter = {
                        -- any = {
                        --     {event = "notify"},
                        --     {error = true},
                        --     {warning = true},
                        --     {event = "msg_show", kind = {""}},
                        --     {event = "lsp", kind = "message"}
                        -- }
                        event = {"msg_show", "notify"},
                        ["not"] = {
                            kind = {"search_count", "echo"}
                        }
                    },
                    filter_opts = {count = 1}
                },
                -- :Noice errors
                errors = {
                    -- options for the message history that you get with `:Noice`
                    view = "popup",
                    opts = {enter = true, format = "details"},
                    filter = {error = true},
                    filter_opts = {reverse = true}
                }
            },
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always "notify" and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = true,
                view = "notify"
            },
            lsp = {
                progress = {
                    enabled = true,
                    -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                    -- See the section on formatting for more details on how to customize.
                    --- @type NoiceFormat|string
                    format = "lsp_progress",
                    --- @type NoiceFormat|string
                    format_done = "lsp_progress_done",
                    throttle = 1000 / 30, -- frequency to update lsp progress message
                    view = "mini"
                },
                override = {
                    -- override the default lsp markdown formatter with Noice
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                    -- override the lsp markdown formatter with Noice
                    ["vim.lsp.util.stylize_markdown"] = false,
                    -- override cmp documentation with Noice (needs the other options to work)
                    ["cmp.entry.get_documentation"] = false
                },
                hover = {
                    enabled = true,
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {} -- merged with defaults from documentation
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50 -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {} -- merged with defaults from documentation
                },
                message = {
                    -- Messages shown by lsp servers
                    enabled = true,
                    view = "notify",
                    opts = {}
                },
                -- defaults for hover and signature help
                documentation = {
                    view = "hover",
                    ---@type NoiceViewOptions
                    opts = {
                        lang = "markdown",
                        replace = true,
                        render = "plain",
                        format = {"{message}"},
                        win_options = {concealcursor = "n", conceallevel = 3}
                    }
                }
            },
            markdown = {
                hover = {
                    ["|(%S-)|"] = cmd.help, -- vim help links
                    ["%[.-%]%((%S-)%)"] = require("noice.util").open -- markdown links
                },
                highlights = {
                    ["|%S-|"] = "@text.reference",
                    ["@%S+"] = "@parameter",
                    ["^%s*(Parameters:)"] = "@text.title",
                    ["^%s*(Return:)"] = "@text.title",
                    ["^%s*(See also:)"] = "@text.title",
                    ["{%S-}"] = "@parameter"
                }
            },
            health = {
                checker = true -- Disable if you don't want health checks to run
            },
            smart_move = {
                -- noice tries to move out of the way of existing floating windows.
                enabled = true, -- you can disable this behaviour here
                -- add any filetypes here, that shouldn't trigger smart move.
                excluded_filetypes = BLACKLIST_FT
            },
            ---@type NoicePresets
            presets = {
                -- you can enable a preset by setting it to true, or a table that will override the preset config
                -- you can also add custom presets that you can enable/disable with enabled=true
                bottom_search = false, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = false, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false -- add a border to hover docs and signature help
            },
            throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates?
            ---@type NoiceConfigViews
            views = {
                --  ╭───────────╮
                --  │ top_right │
                --  ╰───────────╯
                top_right = top_right,
                --  ╭───────╮
                --  │ split │
                --  ╰───────╯
                split = {
                    backend = "split",
                    enter = true,
                    relative = "editor",
                    position = "bottom",
                    size = "20%",
                    close = {
                        keys = {"q"}
                    },
                    win_options = {
                        winhighlight = {Normal = "NoiceSplit", FloatBorder = "NoiceSplitBorder"},
                        wrap = true
                    }
                },
                --  ╭───────────╮
                --  │ popupmenu │
                --  ╰───────────╯
                popupmenu = {
                    relative = "editor",
                    zindex = 65,
                    position = "auto", -- when auto, then it will be positioned to the cmdline or cursor
                    size = {
                        width = "auto",
                        height = "auto",
                        max_height = 20
                        -- min_width = 10,
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NoicePopupmenu", -- change to NormalFloat to make normal
                            FloatBorder = "NoicePopupmenuBorder", -- border highlight
                            CursorLine = "NoicePopupmenuSelected", -- used for highlighting the selected item
                            PmenuMatch = "NoicePopupmenuMatch" -- part of the item that matches input
                        }
                    },
                    border = {
                        style = "rounded",
                        padding = {0, 1}
                    }
                },
                --  ╭─────────────╮
                --  │ virtualtext │
                --  ╰─────────────╯
                virtualtext = {
                    backend = "virtualtext",
                    format = {"{message}"},
                    hl_group = "NoiceVirtualText"
                },
                --  ╭────────╮
                --  │ notify │
                --  ╰────────╯
                notify = {
                    backend = "notify",
                    fallback = "mini",
                    format = "notify",
                    replace = false,
                    merge = false
                },
                --  ╭────────────────╮
                --  │ cmdline_output │
                --  ╰────────────────╯
                cmdline_output = {
                    format = "details",
                    view = "split"
                },
                --  ╭──────────╮
                --  │ messages │
                --  ╰──────────╯
                messages = {
                    view = "split",
                    enter = true
                },
                --  ╭────────╮
                --  │ vsplit │
                --  ╰────────╯
                vsplit = {
                    view = "split",
                    position = "right"
                },
                --  ╭───────╮
                --  │ popup │
                --  ╰───────╯
                popup = {
                    backend = "popup",
                    relative = "editor",
                    close = {
                        events = {"BufLeave"},
                        keys = {"q"}
                    },
                    enter = true,
                    border = {
                        style = "rounded"
                    },
                    position = "50%",
                    size = {
                        width = "120",
                        height = "20"
                    },
                    win_options = {
                        winhighlight = {Normal = "NoicePopup", FloatBorder = "NoicePopupBorder"}
                    }
                },
                --  ╭───────╮
                --  │ hover │
                --  ╰───────╯
                hover = {
                    view = "popup",
                    relative = "cursor",
                    zindex = 45,
                    enter = false,
                    anchor = "auto",
                    size = {
                        width = "auto",
                        height = "auto",
                        max_height = 20,
                        max_width = 120
                    },
                    border = {
                        style = "none",
                        padding = {0, 2}
                    },
                    position = {row = 1, col = 0},
                    win_options = {
                        wrap = true,
                        linebreak = true
                    }
                },
                --  ╭─────────╮
                --  │ cmdline │
                --  ╰─────────╯
                cmdline = {
                    backend = "popup",
                    relative = "editor",
                    position = {
                        row = "100%",
                        col = 0
                    },
                    size = {
                        height = "auto",
                        width = "100%"
                    },
                    border = {
                        style = "none"
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceCmdline",
                            IncSearch = "",
                            Search = ""
                        }
                    }
                },
                --  ╭──────╮
                --  │ mini │
                --  ╰──────╯
                mini = {
                    backend = "mini",
                    relative = "editor",
                    align = "message-right",
                    timeout = 2000,
                    reverse = true,
                    focusable = false,
                    position = {
                        row = -1,
                        col = "100%"
                        -- col = 0,
                    },
                    size = "auto",
                    border = {
                        style = "none"
                    },
                    zindex = 60,
                    win_options = {
                        winblend = 30,
                        winhighlight = {
                            Normal = "NoiceMini",
                            IncSearch = "",
                            Search = ""
                        }
                    }
                },
                --  ╭───────────────╮
                --  │ cmdline_popup │
                --  ╰───────────────╯
                cmdline_popup = {
                    backend = "popup",
                    relative = "editor",
                    focusable = false,
                    enter = false,
                    zindex = 60,
                    position = {
                        row = "50%",
                        col = "50%"
                    },
                    size = {
                        min_width = 60,
                        width = "auto",
                        height = "auto"
                    },
                    border = {
                        style = "rounded",
                        padding = {0, 1}
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceCmdlinePopup",
                            FloatBorder = "NoiceCmdlinePopupBorder",
                            IncSearch = "",
                            Search = ""
                        },
                        cursorline = false
                    }
                },
                --  ╭─────────╮
                --  │ confirm │
                --  ╰─────────╯
                confirm = {
                    backend = "popup",
                    relative = "editor",
                    focusable = false,
                    align = "center",
                    enter = false,
                    zindex = 60,
                    format = {"{confirm}"},
                    position = {
                        row = "50%",
                        col = "50%"
                    },
                    size = "auto",
                    border = {
                        style = "rounded",
                        padding = {0, 1},
                        text = {
                            top = " Confirm "
                        }
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceConfirm",
                            FloatBorder = "NoiceConfirmBorder"
                        }
                    }
                }
            }, ---@see section on views
            ---@type NoiceRouteConfig[]
            routes = routes, --- @see section on routes
            ---@type table<string, NoiceFilter>
            status = {}, --- @see section on statusline components
            ---@type NoiceFormatOptions
            format = {} --- @see section on formatting
        }
    )
end

local function init()
    M.setup()
    mini.timeout = 5000

    map(
        "c",
        "<S-Enter>",
        function()
            noice.redirect(fn.getcmdline())
        end,
        {desc = "Redirect cmdline (noice)"}
    )

    require("telescope").load_extension("noice")
end

init()

return M
