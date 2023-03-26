local M = {}

local D = require("dev")
local noice = D.npcall(require, "noice")
if not noice then
    return
end

local utils = require("common.utils")
local map = utils.map
local style = require("style")

local views = require("noice.config.views").defaults

local fn = vim.fn
local cmd = vim.cmd

-- TODO: EasyAlign open command line

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

    -- ROUTE: NoiceRoute
    -- view   NoiceView                          : one of the views (built-in or custom)
    -- filter NoiceFilter                        : a filter for messages matching this route
    -- opts   NoiceRouteOptions|NoiceViewOptions : options for the view and the route
    -- ROUTE_OPTS: NoiceRouteOptions
    -- stop  boolean
    -- skip  boolean
    -- ROUTE_VIEW_OPTS: NoiceViewOptions
    -- *NoiceViewBaseOptions*
    -- buf_options table<string,any>
    -- backend     string
    -- fallback    string               : Fallback view in case the backend could not be loaded
    -- format      NoiceFormat|string
    -- align       NoiceAlign
    -- lang        string
    -- view        string
    -- *NoiceNuiOptions*
    -- *NoiceNotifyOptions*
    -- title   string
    -- level   string|number : Message log level
    -- merge   boolean       : Merge messages into one Notification or create separate notifications
    -- replace boolean       : Replace existing notification or create a new one
    -- render  notify.RenderFun|string
    -- timeout integer
    -- *NoiceAlign*
    -- "center"        | "left"        | "right"     | "message-center" | "message-left"
    -- "message-right" | "line-center" | "line-left" | "line-right"

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
    --   default = { "{level} ", "{title} ", "{message}" },    -- default format
    --   notify = { "{message}" },                             -- default format for vim.notify
    --   details = {                                           -- default format for the history
    --     "{level} ", "{date} ", "{event}",
    --     { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
    --     " ", "{title} ", "{cmdline} ", "{message}",
    --   },
    --   telescope = ...,         -- formatter used to display telescope results
    --   telescope_preview = ..., -- formatter used to preview telescope results
    --   lsp_progress = ...,      -- formatter used by lsp progress
    --   lsp_progress_done = ..., -- formatter used by lsp progress
    -- }
    --
    -- FILTERS: NoiceFilter
    -- any          NoiceFilter[]               check at least one filter matches
    -- blocking     boolean                     are we in blocking mode?
    -- cleared      boolean                     if msg is cleared, meaning it’s in the history
    -- cmdline      boolean|string              if msg generated by exec cmdline. (string=pattern)
    -- error        boolean                     all error-like kinds from ext_msgs
    -- event        NoiceEvent|NoiceEvent[]     See ui-messages
    -- find         string                      uses lua string.find to match the pattern
    -- has          boolean                     if the msg is exists, meaning it’s in the history
    -- kind         NoiceKind|NoiceKind[]       any of the kinds from ext_msgs. See :h ui-messages
    -- max_height   number                      max height of the msg
    -- max_length   number                      max length of the msg (total width of all lines)
    -- max_width    number                      max width of the msg
    -- min_height   number                      min height of the msg
    -- min_length   number                      min length of the msg (total width of all lines)
    -- min_width    number                      min width of the msg
    -- mode         string                      if api.nvim_get_mode() contains the given mode
    -- not          NoiceFilter                 whether the filter matches or not
    -- warning      boolean                     all warning-like kinds from ext_msgs
    -- cond         fun(m:NoiceMessage)
    -- message      NoiceMessage

    -- EVENT: NoiceEvent
    -- msg_show           msg_clear
    -- msg_showmode       msg_showcmd
    -- msg_ruler          msg_history_show     msg_history_clear
    --
    -- cmdline            cmdline_show         cmdline_hide
    -- cmdline_pos        cmdline_special_char
    -- cmdline_block_show cmdline_block_append cmdline_block_hide
    --
    -- notify
    --
    -- lsp

    -- KIND: NoiceKind
    --### MsgKind
    -- "" (empty)      Unknown
    -- echo            |:echo| message
    -- echomsg         |:echomsg| message
    --
    -- confirm         |confirm()| or |:confirm| dialog
    -- confirm_sub     |:substitute| confirm dialog |:s_c|
    -- return_prompt   |press-enter| prompt after a multiple messages
    --
    -- emsg            Error (|errors|, internal error, |:throw|, …)
    -- echoerr         |:echoerr| message
    -- lua_error       Error in |:lua| code
    -- rpc_error       Error response from |rpcrequest()|
    -- wmsg            Warning (search hit BOTTOM, |W10|, …)
    --
    -- quickfix        Quickfix navigation message
    -- search_count    Search count message (S flag of 'shortmess')
    --
    --### NotifyLevel
    -- "trace"|"debug"|"info"|"warn"|"error"|"off"
    --
    --### LspKind
    -- progress, hover, message, signature

    -- COMMAND: NoiceCommand
    -- filter_opts:
    -- history boolean
    -- sort    boolean
    -- reverse boolean
    -- count   number

    local function is_focused()
        return g.nvim_focused
    end

    -- ---@type NoiceViewBaseOptions|NoiceNuiOptions|NoiceNotifyOptions
    ---@type NoiceViewOptions
    local top_right =
        vim.tbl_deep_extend(
        "force",
        views.mini,
        {
            view = "mini",
            timeout = 6000,
            reverse = false,
            zindex = 60,
            relative = "editor",
            align = "message-left",
            position = {row = "8%", col = "100%"},
            size = {
                height = "auto",
                width = "auto"
            },
            win_options = {
                winhighlight = {
                    Normal = "NormalFloat", -- change to NormalFloat to make normal
                    FloatBorder = "NoicePopupmenuBorder", -- border highlight
                    PmenuMatch = "NoicePopupmenuMatch" -- part of the item that matches input
                },
                winblend = 10,
                wrap = true,
                linebreak = true,
                cursorline = false
            },
            border = {
                style = style.current.border,
                padding = {0, 1},
                text = {top = "Messages"}
            }
        }
    )

    ---@type NoiceRouteConfig[]
    local routes = {
        -- {
        --     view = "mini",
        --     filter = {
        --         {
        --             event = "msg_show",
        --             cond = function(m)
        --                 -- N(m.cmdline:get())
        --                 N(m)
        --                 return true
        --             end
        --         }
        --     }
        -- },
        --  ╭───────╮
        --  │ Skips │
        --  ╰───────╯
        {
            opts = {skip = true},
            filter = {
                any = {
                    {event = "msg_show", find = "%[w%]"}, -- Writing a file
                    {event = "msg_show", find = "^%?"}, -- Clicking 'N' after search
                    {event = "msg_show", kind = {"echo", ""}, find = "^/\\?"}, -- after asterisk '*'
                    {event = "msg_show", kind = {"echo", ""}, find = "^\\"}, -- after asterisk '#'
                    {event = "msg_show", kind = {"echo", ""}, find = "^[%w_]+/s[+]%d+"}, -- after asterisk 'g*'
                    {event = "msg_show", kind = {"echo", ""}, find = "^[%w_]+[?]s[+]%d+"}, -- after asterisk 'g#'
                    {event = "msg_show", find = "^/[^/]+$"}, -- search display
                    {event = "msg_show", find = "/[^/]+/[^ ]+ %d+L, %d+B"},
                    {event = "msg_show", find = "%d+ lines indented ?$"},
                    {event = "msg_show", find = "%d+ lines to indent... ?$"},
                    {event = "msg_show", find = "%d+ lines >ed %d+ time"},
                    {event = "msg_show", find = "%d+ lines <ed %d+ time"},
                    {event = "msg_show", find = "No active Snippet"},
                    {event = "msg_show", kind = "redraw"},
                    {event = "msg_show", kind = "search_count"},
                    {event = "msg_show", find = "Hop %d char"},
                    {event = "msg_show", kind = "emsg", find = "Pattern not found"}, -- search term is not found
                    -- Comes after easy align
                    {
                        event = "msg_show",
                        kind = "echo",
                        max_length = 1,
                        cond = function(m)
                            return m:content():rxfind([[^(\(|_|\))$]])
                        end
                    }
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
                    {event = "msg_show", find = "Last set from Lua"} -- result of verbose <cmd>
                }
            }
        },
        {
            view = "split",
            opts = {lang = "lua"},
            filter = {event = "notify", kind = "debug"}
        },
        --  ╭────────────╮
        --  │ Split Wrap │
        --  ╰────────────╯
        {
            view = "split",
            -- TODO: Wrap doesn't set to false
            opts = {
                win_options = {wrap = false},
                winhighlight = {
                    Normal = "NoiceSplit",
                    FloatBorder = "NoiceSplitBorder"
                }
            },
            filter = {
                any = {
                    -- Output of :map
                    {
                        event = "msg_show",
                        cond = function(m)
                            if m.cmdline and m.cmdline:get():rxfind([[^[invxts]?(nore)?map.*]]) then
                                return true
                            end
                            return false
                        end
                    },
                    -- Output of :filter
                    {
                        event = "msg_show",
                        cond = function(m)
                            if m.cmdline and m.cmdline:get():rxfind([[^filt(er)?.*]]) then
                                return true
                            end
                            return false
                        end
                    }
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
                    {event = "msg_show", kind = "wmsg"},
                    {event = "notify", kind = "error"}
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
                    {event = "msg_show", kind = "echo", find = "^%[VM%] *$"},
                    {event = "msg_show", kind = "quickfix"},
                    {event = "msg_show", kind = "info", find = "%[tree%-sitter%]"},
                    {event = "msg_show", kind = "info", find = "%[nvim%-treesitter%]"},
                    {event = "msg_show", kind = "return_prompt"},
                    {event = "msg_show", find = "Unception prevented inception!"},
                    {event = "msg_show", find = "%d+ changes?; before"},
                    {event = "msg_show", find = "%d+ changes?; after"},
                    {event = "msg_show", find = "%d+ more lines"},
                    {event = "msg_show", find = "%d+ fewer lines"},
                    {event = "msg_show", find = "%d+ more lines?; before"},
                    {event = "msg_show", find = "%d+ more lines?; after"},
                    {event = "msg_show", find = "%d+ fewer lines?; before"},
                    {event = "msg_show", find = "%d+ fewer lines?; after"},
                    {event = "msg_show", find = "%d+ lines? less; before"},
                    {event = "msg_show", find = "%d+ lines? less; after"},
                    {event = "msg_show", find = "%d+ changes; before #%d+  %d+ seconds ago"},
                    {event = "msg_show", find = "Already at newest change"},
                    {event = "msg_show", find = "search hit BOTTOM, continuing at TOP"},
                    {event = "msg_show", find = "%d+ lines yanked"},
                    {event = "msg_show", find = "Neoformat: .* formatted buffer"},
                    {event = "msg_show", find = "Neoformat: no change necessary with .*"},
                    {event = "notify", kind = "info", find = "%[mason%-lspconfig.*%]"},
                    {event = "notify", kind = "info", find = "packer.nvim"},
                    {event = "notify", kind = "info", find = "%[mason%-tool%-installer%]"},
                    {event = "notify", kind = "info", find = "was successfully installed"},
                    {event = "notify", kind = "info", find = "was successfully uninstalled"}
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
                    {event = "msg_show", find = "fetching"},
                    {event = "msg_show", find = "successfully fetched all PR state"},
                    {event = "msg_show", find = "Hunk %d+ of %d+"},
                    {event = "msg_showmode", find = "Recording @%w$"} -- shows macro recording
                    -- {event = "notify", find = ".%sRecording @%w$"} -- shows macro recording
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
        },
        --  ╭──────────────────────────╮
        --  │ Interactive Command Line │
        --  ╰──────────────────────────╯
        -- {
        --     view = "cmdline_popup",
        --     filter = {
        --         any = {
        --             {event = "msg_show", kind = {"echo", ""}}
        --         }
        --     }
        --     -- opts = {enter = true}
        -- },
        {
            view = "mini",
            filter = {
                -- cmdline = "^:EasyAlign"
                any = {
                    {event = "msg_show", kind = "echo", find = "^:EasyAlign"},
                    {event = "msg_show", kind = "echo", find = "^:LiveEasyAlign"}
                    -- {cmdline = ".*EasyAlign.*"}
                }
            }
            -- opts = {enter = true}
        },
        --  ╭──────╮
        --  │ Rest │
        --  ╰──────╯
        {
            view = "top_right",
            filter = {
                cond = is_focused,
                any = {
                    {event = "msg_show"},
                    {event = "msg_showmode"},
                    {event = "notify"}
                }
            }
        }
        --  ╭─────────────╮
        --  │ Not Focused │
        --  ╰─────────────╯
        -- {
        --     view = "notify_send",
        --     -- opts = {stop = false},
        --     filter = {
        --         cond = function()
        --             return not g.nvim_focused
        --         end
        --     }
        -- }
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
                -- opts = {buf_options = {filetype = "vim"}}, -- enable syntax highlighting in the cmdline
                opts = {},
                icons = {
                    ["/"] = {icon = " ", hl_group = "MoreMsg"},
                    ["?"] = {icon = " ", hl_group = "WarningMsg"},
                    [":"] = {icon = " ", hl_group = "Macro", firstc = false}
                },
                win_options = {
                    winhighlight = {
                        Normal = "Normal", -- change to NormalFloat to make normal
                        FloatBorder = "FloatBorder", -- border highlight
                        CursorLine = "" -- used for highlighting the selected item
                    },
                    winblend = 10,
                    cursorline = false,
                    conceallevel = 0
                },
                ---@type table<string, CmdlineFormat>
                format = {
                    -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
                    -- view: (default is cmdline view)
                    -- opts: any options passed to the view
                    -- icon_hl_group: optional hl_group for the icon
                    -- title: set to anything or empty string to hide
                    cmdline = {
                        pattern = "^:",
                        icon = "",
                        lang = "vim",
                        icon_hl_group = "Macro"
                    },
                    search_down = {
                        kind = "search",
                        pattern = "^/",
                        icon = " ",
                        lang = "regex",
                        view = "cmdline",
                        icon_hl_group = "MoreMsg"
                    },
                    search_up = {
                        kind = "search",
                        pattern = "^%?",
                        icon = " ",
                        lang = "regex",
                        view = "cmdline",
                        icon_hl_group = "WarningMsg"
                    },
                    lua = {
                        pattern = "^:%s*lua%s+",
                        icon = "",
                        lang = "lua",
                        view = "cmdline"
                    },
                    inspect = {
                        pattern = {"^:%s*lua%s*=%s*", "^:%s*=%s*"},
                        conceal = true,
                        icon = " ",
                        lang = "lua"
                    },
                    help = {
                        pattern = "^:%s*he?l?p?%s+",
                        icon = "",
                        view = "cmdline"
                    },
                    filter = {
                        pattern = "^:%s*!",
                        icon = "$",
                        lang = "zsh"
                    },
                    man = {
                        pattern = "^:%s*Man%s+",
                        icon = "龎",
                        lang = "bash"
                    },
                    input = {} -- Used by input()
                }
            },
            --  ╭──────────╮
            --  │ messages │
            --  ╰──────────╯
            messages = {
                enabled = true, -- enables the Noice messages UI
                view = "notify", -- default view for messages
                view_error = "notify", -- view for errors
                view_warn = "notify", -- view for warnings
                view_history = "split", -- view for :messages / split
                view_search = "virtualtext" -- view for search count messages. Set to `false` to disable
            },
            --  ╭───────────╮
            --  │ popupmenu │
            --  ╰───────────╯
            popupmenu = {
                enabled = false, -- enables the Noice popupmenu UI
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
                view = "cmdline_popup",
                filter = {event = "msg_show"}
            },
            --  ╭──────────────────────────────────────────────────────────╮
            --  │                         commands                         │
            --  ╰──────────────────────────────────────────────────────────╯
            -- You can add any custom commands below that will be available with `:Noice command`
            ---@type table<string, NoiceCommand>
            commands = {
                history = {
                    -- options for the message history that you get with `:Noice`
                    -- view = "popup",
                    view = "split",
                    opts = {enter = true, format = "details", title = "History"},
                    filter_opts = {reverse = true},
                    filter = {
                        any = {
                            {error = true},
                            {warning = true},
                            {event = "msg_show", kind = {""}},
                            {event = "lsp", kind = "message"},
                            {
                                event = {"msg_show", "notify"},
                                ["not"] = {kind = {"search_count", "echo"}}
                            }
                        }
                    }
                },
                notifs = {
                    view = "split",
                    opts = {enter = true, format = "details", title = "Notifications"},
                    filter_opts = {reverse = true},
                    filter = {
                        any = {
                            {event = "notify"},
                            {event = {"msg_show"}, ["not"] = {kind = {"search_count", "echo"}}}
                        }
                    }
                },
                -- history = true
                all = {
                    view = "split",
                    opts = {enter = true, format = "details", title = "All"},
                    filter_opts = {reverse = true},
                    filter = {
                        any = {
                            {event = "msg_show"},
                            {event = "msg_showcmd"},
                            {event = "notify"},
                        }
                    }
                },
                -- :Noice last
                last = {
                    view = "popup",
                    opts = {enter = true, format = "details"},
                    border = {style = style.current.border, text = {top = "Noice Last"}},
                    filter_opts = {count = 1},
                    filter = {
                        event = {"msg_show", "notify"},
                        ["not"] = {kind = {"search_count"}}
                    }
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
                    enabled = false,
                    view = nil, -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {} -- merged with defaults from documentation
                },
                signature = {
                    enabled = false,
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
                    enabled = false,
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
                        win_options = {
                            concealcursor = "n",
                            conceallevel = 3
                        }
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
                lsp_doc_border = false, -- add a border to hover docs and signature help
                cmdline_output_to_split = false -- send the output of a command you executed in the cmdline to a split
            },
            throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates?
            --  ╭──────────────────────────────────────────────────────────╮
            --  │                          views                           │
            --  ╰──────────────────────────────────────────────────────────╯
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
                    close = {keys = {"qq"}},
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceSplit",
                            FloatBorder = "NoiceSplitBorder"
                        },
                        wrap = true,
                        linebreak = true
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
                    border = {style = style.current.border, padding = {0, 1}}
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
                    merge = false,
                    timeout = 5000
                },
                --  ╭────────────────╮
                --  │ cmdline_output │
                --  ╰────────────────╯
                cmdline_output = {format = "details", view = "split"},
                --  ╭──────────╮
                --  │ messages │
                --  ╰──────────╯
                messages = {view = "split"},
                --  ╭────────╮
                --  │ vsplit │
                --  ╰────────╯
                vsplit = {view = "split", position = "right"},
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
                    border = {style = style.current.border, padding = {0, 2}},
                    position = {row = 1, col = 0},
                    win_options = {wrap = true, linebreak = true}
                },
                --  ╭──────╮
                --  │ mini │
                --  ╰──────╯
                mini = {
                    backend = "mini",
                    relative = "editor",
                    align = "message-right",
                    timeout = 3000,
                    reverse = false,
                    focusable = false,
                    position = {
                        row = -2,
                        col = "100%"
                    },
                    -- size = "auto",
                    size = {
                        max_height = math.ceil(0.8 * vim.o.lines),
                        max_width = math.ceil(0.8 * vim.o.columns),
                        width = "auto",
                        height = "auto"
                    },
                    border = {style = style.current.border},
                    zindex = 60,
                    win_options = {
                        winblend = 10,
                        wrap = true,
                        linebreak = true,
                        cursorline = false,
                        winhighlight = {
                            Normal = "NoiceMini",
                            IncSearch = "",
                            Search = ""
                        }
                    }
                },
                --  ╭───────╮
                --  │ popup │
                --  ╰───────╯
                popup = {
                    backend = "popup",
                    relative = "editor",
                    close = {events = {"BufLeave"}, keys = {"q"}},
                    enter = true,
                    border = {style = style.current.border},
                    position = "50%",
                    size = {width = "120", height = "20"},
                    win_options = {
                        winhighlight = {
                            Normal = "NoicePopup",
                            FloatBorder = "NoicePopupBorder"
                        }
                    },
                    opts = {replace = true, merge = true, title = "Messages"}
                },
                --  ╭─────────╮
                --  │ cmdline │
                --  ╰─────────╯
                cmdline = {
                    backend = "popup",
                    relative = "editor",
                    position = {row = "100%", col = 0},
                    size = {height = "auto", width = "100%"},
                    border = {style = "none"},
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceCmdline",
                            IncSearch = "",
                            Search = ""
                        }
                        -- conceallevel = 0
                    }
                },
                --  ╭───────────────╮
                --  │ cmdline_popup │
                --  ╰───────────────╯
                cmdline_popup = {
                    backend = "popup",
                    relative = "editor",
                    focusable = true,
                    enter = true,
                    zindex = 60,
                    close = {events = {"BufLeave"}, keys = {"q"}},
                    position = {
                        -- row = "50%",
                        -- col = "50%"
                        row = vim.o.lines - 3,
                        col = "50%"
                    },
                    size = {
                        -- min_width = 60,
                        -- width = "auto",
                        width = math.floor(vim.o.columns * 0.9),
                        height = "auto"
                    },
                    border = {style = style.current.border, padding = {0, 1}},
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceCmdlinePopup",
                            FloatBorder = "NoiceCmdlinePopupBorder",
                            IncSearch = "",
                            Search = ""
                        },
                        cursorline = false,
                        conceallevel = 0
                    },
                    opts = {replace = true, merge = true, title = "Output"}
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
                    position = {row = "50%", col = "50%"},
                    size = "auto",
                    border = {
                        style = style.current.border,
                        padding = {0, 1},
                        text = {top = " Confirm "}
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceConfirm",
                            FloatBorder = "NoiceConfirmBorder"
                        }
                    }
                }
            } --[[@see section on views]],
            ---@type NoiceRouteConfig[]
            routes = routes --[[@see section on routes]],
            ---@type table<string, NoiceFilter>
            status = {} --[[@see section on statusline components]],
            ---@type NoiceFormatOptions
            format = {} --[[@see section on formatting]]
        }
    )
end

local function init()
    M.setup()
    views.mini.timeout = 5000

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
