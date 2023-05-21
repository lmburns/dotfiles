---@module 'plugs.noice'
local M = {}

local D = require("dev")
local noice = D.npcall(require, "noice")
if not noice then
    return
end

local utils = require("common.utils")
local prequire = utils.mod.prequire
local xprequire = utils.mod.xprequire
local log = require("common.log")
local mpi = require("common.api")
local map = mpi.map
local style = require("style")
local icons = style.icons

local def_views = require("noice.config.views").defaults
local wk = require("which-key")

local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

---@type Noice.Config.Control
local control
local skips

-- TODO: EasyAlign open command line

---@return boolean
local function is_focused()
    return g.nvim_focused
end

---@param find string
---@param vimr? boolean
---@return fun(m: NoiceMessage): boolean
local function cmdline(find, vimr)
    ---@param m NoiceMessage
    ---@return boolean
    return function(m)
        if m.cmdline then
            if (vimr and m.cmdline:get():vmatch(find)) or m.cmdline:get():rxfind(find) then
                return true
            end
        end
        return false
    end
end

---@param find string
---@param vimr? boolean
---@return fun(m: NoiceMessage): boolean
local function content(find, vimr)
    ---@param m NoiceMessage
    ---@return boolean
    return function(m)
        if m.content then
            local content = m:content()
            if (vimr and content:vmatch(find)) or content:rxfind(find) then
                return true
            end
        end
        return false
    end
end

---@param find? string
---@return fun(m: NoiceMessage): boolean
---@diagnostic disable-next-line: unused-local, unused-function
local function deb(find)
    ---@param m NoiceMessage
    ---@return boolean
    return function(m)
        if m.event ~= "msg_showcmd" then
            local info = {
                event = m.event,
                content = m:content(),
                kind = m.kind or "NONE",
                opts = m.opts,
                cmdline = m.cmdline
                    and {
                        text = m.cmdline:get(),
                        offset = m.cmdline.offset,
                        state = m.cmdline.state,
                    }
                    or {},
                level = m.level or "NONE",
                id = m.id,
                tick = m.tick,
                ctime = m.ctime,
                mtime = m.mtime,
                -- bufs = m:bufs(),
                -- wins = m:wins(),
                -- buf = m:buf(),
                -- win = m:win(),
            }

            p(info)
        end
        return false
    end
end

---Setup `noice.nvim`
function M.setup()
    local views = M.setup_views()
    local routes = M.setup_routes()
    local cmds = M.setup_commands()

    noice.setup(
    ---@class NoiceConfig
        {
            --  ╭─────────╮
            --  │ cmdline │
            --  ╰─────────╯
            cmdline = {
                enabled = control.cmdline, -- enables the Noice cmdline UI
                view = "cmdline",          -- view for rendering the cmdline. `cmdline` = Classic
                opts = {
                    win_options = {
                        winhighlight = {
                            Normal = "Normal",           -- change to NormalFloat to make normal
                            FloatBorder = "FloatBorder", -- border highlight
                            FloatTitle = "Title",
                            CursorLine = "",             -- used for highlighting the selected item
                        },
                        winblend = 10,
                        cursorline = false,
                        conceallevel = 0,
                    },
                },
                ---@type table<string, CmdlineFormat>
                format = M.setup_cmdline_formats(),
            },
            --  ╭──────────╮
            --  │ messages │
            --  ╰──────────╯
            messages = {
                enabled = control.messages,
                view = "notify",             -- default view for messages
                view_error = "notify",       -- view for errors
                view_warn = "notify",        -- view for warnings
                view_history = "split",      -- view for :messages / split
                view_search = "virtualtext", -- view for search count msgs (`false`=disable)
            },
            --  ╭───────────╮
            --  │ popupmenu │
            --  ╰───────────╯
            popupmenu = {
                enabled = control.popupmenu,
                ---@type 'nui'|'cmp'
                backend = "nui", -- backend to use to show regular cmdline completions
                ---@type NoicePopupmenuItemKind|false
                -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
                kind_icons = {}, -- set to `false` to disable icons
            },
            --  ╭────────╮
            --  │ notify │
            --  ╰────────╯
            notify = {
                -- Noice can be used as `vim.notify` so you can route any notification like other messages
                -- Notification messages have their level and other properties set.
                -- event is always "notify" and kind can be any log level as a string
                -- The default routes will forward notifications to nvim-notify
                -- Benefit of using Noice for this is the routing and consistent history view
                enabled = control.notify,
                view = "notify",
            },
            --  ╭─────╮
            --  │ lsp │
            --  ╰─────╯
            lsp = {
                progress = {
                    enabled = control.lsp,
                    -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                    -- See the section on formatting for more details on how to customize.
                    ---@type NoiceFormat|string
                    format = "lsp_progress",
                    ---@type NoiceFormat|string
                    format_done = "lsp_progress_done",
                    throttle = 1000 / 30, -- frequency to update lsp progress message
                    view = "mini",
                },
                override = {
                    -- override the default lsp markdown formatter with Noice
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
                    -- override the lsp markdown formatter with Noice
                    ["vim.lsp.util.stylize_markdown"] = false,
                    -- override cmp documentation with Noice (needs the other options to work)
                    ["cmp.entry.get_documentation"] = false,
                },
                hover = {
                    enabled = control.lsp,
                    silent = false, -- set to true to not show a message if hover is not available
                    view = nil,     -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {},      -- merged with defaults from documentation
                },
                signature = {
                    enabled = control.lsp,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- auto show signature help when typing a trigger character from the LSP
                        luasnip = true, -- will open signature help when jumping to Luasnip insert nodes
                        throttle = 50,  -- debounce lsp signature help request by 50ms
                    },
                    view = nil,         -- when nil, use defaults from documentation
                    ---@type NoiceViewOptions
                    opts = {},          -- merged with defaults from documentation
                },
                message = {
                    -- Messages shown by lsp servers
                    enabled = control.lsp,
                    view = "notify",
                    opts = {},
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
                            conceallevel = 3,
                        },
                    },
                },
            },
            --  ╭──────────╮
            --  │ markdown │
            --  ╰──────────╯
            markdown = {
                hover = {
                    ["|(%S-)|"] = cmd.help,                           -- vim help links
                    ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
                },
                highlights = {
                    ["|%S-|"] = "@text.reference",
                    ["@%S+"] = "@parameter",
                    ["^%s*(Parameters:)"] = "@text.title",
                    ["^%s*(Return:)"] = "@text.title",
                    ["^%s*(See also:)"] = "@text.title",
                    ["{%S-}"] = "@parameter",
                },
            },
            --  ╭──────────────────────────────────────────────────────────╮
            --  │                         commands                         │
            --  ╰──────────────────────────────────────────────────────────╯
            -- You can add any custom commands below that will be available with `:Noice command`
            ---@type table<string, NoiceCommand>
            commands = {
                -- Show all in a split with full detail. (all split)
                all = cmds.all_sp_f,
                -- Plainly show all in a split. (all split plain)
                allSp = cmds.all_sp,
                -- Plainly show all in a popup. (all popup plain)
                allp = cmds.all_p,
                -- Plainly show all reversed in a popup. (all popup plain reverse)
                allpRev = cmds.all_p_r,
                ---Show all items that weren't skipped in a split with full detail
                shown = cmds.shown_sp_f,
                ---Plainly show all items that weren't skipped in a split
                shownp = cmds.shown_sp,
                -- Similar to `:messages`; shown in a split; full detail
                history = cmds.history,
                -- Show notifications only in a split; full detail
                notifs = cmds.notifs,
                -- Show last event caught by Noice in a popup; full detail
                last = cmds.last,
                -- Show warnings and errors in a popup; full detail
                errors = cmds.errors,
                -- Show warnings and errors in a split; full detail
                errorsSp = cmds.errorsSp,
                -- Show warnings in a split; full detail
                warnings = cmds.warnings,
                -- Show many types of events in a split; full detail
                trace = cmds.trace,
                -- Show many types of events in a split; plainly
                tracep = cmds.trace_p,
            },
            --  ╭────────────╮
            --  │ smart move │
            --  ╰────────────╯
            smart_move = {
                -- noice tries to move out of the way of existing floating windows
                enabled = control.smart_move, -- you can disable this behaviour here
                -- add any filetypes here, that shouldn't trigger smart move.
                excluded_filetypes = BLACKLIST_FT,
            },
            --  ╭──────────╮
            --  │ redirect │
            --  ╰──────────╯
            -- default options for require('noice').redirect
            -- see the section on Command Redirection
            ---@type NoiceRouteConfig
            redirect = {
                opts = {enter = true, title = "Cmdline Output", size = "35%"},
                -- view = "cmdline_popup",
                -- view = "cmdline_notif",
                -- view = "cmdline_output",
                -- view = "notify",
                view = "split",
                filter = {event = "msg_show"},
            },
            ---@type NoicePresets
            presets = {
                -- you can enable a preset by setting it to true, or a table that will override the preset config
                -- you can also add custom presets that you can enable/disable with enabled=true
                bottom_search = control.presets.bottom_search,
                command_palette = control.presets.command_palette,
                long_message_to_split = control.presets.long_message_to_split,
                inc_rename = control.presets.inc_rename,
                lsp_doc_border = control.presets.lsp_doc_border,
                cmdline_output_to_split = control.presets.cmdline_output_to_split,
            },
            health = {checker = control.health}, -- disable to not run checkhealth
            throttle = 1000 / 30,                -- how frequently does Noice need to check for ui updates?
            --  ╭──────────────────────────────────────────────────────────╮
            --  │                          views                           │
            --  ╰──────────────────────────────────────────────────────────╯
            ---@type NoiceConfigViews
            views = views, ---@see section on views
            ---@type NoiceRouteConfig[]
            routes = routes, ---@see section on routes
            ---@type NoiceFormatOptions
            format = {}, ---@see section on formatting
            ---@type table<string, NoiceFilter>
            status = {}, ---@see section on statusline components
        }
    )
end

---@return NoiceConfigViews
function M.setup_views()
    -- ---@type NoiceViewBaseOptions|NoiceNuiOptions|NoiceNotifyOptions
    ---@type NoiceViewOptions
    local top_right = vim.tbl_deep_extend("force", def_views.mini, {
        view = "mini",
        timeout = 6000,
        reverse = false,
        zindex = 60,
        relative = "editor",
        align = "message-left",
        position = {row = "8%", col = "100%"},
        size = {height = "auto", width = "auto"},
        border = {
            style = style.current.border_t,
            padding = {0, 1},
            text = {top = " Messages "},
        },
        win_options = {
            winhighlight = {
                Normal = "NormalFloat",               -- change to NormalFloat to make normal
                FloatBorder = "NoicePopupmenuBorder", -- border highlight
                FloatTitle = "Title",
                PmenuMatch = "NoicePopupmenuMatch",   -- part of the item that matches input
            },
            winblend = 10,
            wrap = true,
            linebreak = true,
            cursorline = false,
        },
    })

    ---@type NoiceViewOptions
    local cmdline_notif = vim.tbl_deep_extend("force", def_views.mini, {
        view = "mini",
        timeout = 3000,
        reverse = false,
        focusable = true,
        zindex = 60,
        relative = "editor",
        close = {events = {"BufLeave"}, keys = {"q"}},
        title = "Output",
        align = "message-left",
        size = {
            width = math.floor(vim.o.columns * 0.9),
            height = "auto",
        },
        position = {row = -2, col = "50%"},
        border = {
            style = style.current.border_t,
            padding = {0, 1},
        },
        win_options = {
            winhighlight = {
                Normal = "NormalFloat",               -- change to NormalFloat to make normal
                FloatBorder = "NoicePopupmenuBorder", -- border highlight
                FloatTitle = "Title",
                PmenuMatch = "NoicePopupmenuMatch",   -- part of the item that matches input
            },
            winblend = 10,
            wrap = false,
            cursorline = false,
            conceallevel = 0,
        },
    })

    ---@type NoiceViewOptions
    local split = {
        backend = "split",
        enter = true,
        relative = "editor",
        close = {keys = {"qq"}},
        size = "20%",
        position = "bottom",
        win_options = {
            winhighlight = {
                Normal = "NoiceSplit",
                FloatBorder = "NoiceSplitBorder",
                FloatTitle = "Title",
            },
            wrap = false,
            linebreak = true,
        },
    }

    ---@type NoiceViewOptions
    local popupmenu = {
        relative = "editor",
        zindex = 65,
        size = {
            width = "auto",
            height = "auto",
            max_height = 20,
            -- min_width = 10,
        },
        position = "auto", -- when auto, then it will be positioned to the cmdline or cursor
        border = {
            style = style.current.border_t,
            padding = {0, 1},
        },
        win_options = {
            winhighlight = {
                Normal = "NoicePopupmenu",             -- change to NormalFloat to make normal
                FloatBorder = "NoicePopupmenuBorder",  -- border highlight
                FloatTitle = "Title",
                CursorLine = "NoicePopupmenuSelected", -- used for highlighting the selected item
                PmenuMatch = "NoicePopupmenuMatch",    -- part of the item that matches input
            },
        },
    }

    ---@type NoiceViewOptions
    local virtualtext = {
        backend = "virtualtext",
        format = {"{message}"},
        hl_group = "NoiceVirtualText",
    }

    ---@type NoiceViewOptions
    local notify = {
        backend = "notify",
        fallback = "mini",
        format = "notify",
        replace = false,
        merge = false,
        timeout = 5000,
    }

    ---@type NoiceViewOptions
    local messages = {view = "split"}
    ---@type NoiceViewOptions
    local vsplit = {view = "split", position = "right"}
    ---@type NoiceViewOptions
    local hover = {
        view = "popup",
        relative = "cursor",
        zindex = 45,
        enter = false,
        anchor = "auto",
        size = {
            width = "auto",
            height = "auto",
            max_height = 20,
            max_width = 120,
        },
        position = {row = 1, col = 0},
        border = {
            style = style.current.border_t,
            padding = {0, 2},
        },
        win_options = {
            wrap = true,
            linebreak = true,
        },
    }

    ---@type NoiceViewOptions
    local mini = {
        backend = "mini",
        relative = "editor",
        align = "message-left",
        timeout = 3000,
        zindex = 60,
        reverse = false,
        focusable = false,
        position = {row = -2, col = "100%"},
        -- size = "auto",
        -- max_height = math.ceil(0.8 * vim.o.lines),
        -- max_width = math.ceil(0.8 * vim.o.columns),
        size = {width = "auto", height = "auto"},
        border = {
            style = style.current.border_t,
        },
        win_options = {
            winblend = 10,
            wrap = true,
            linebreak = true,
            cursorline = false,
            winhighlight = {
                Normal = "NoiceMini",
                IncSearch = "",
                Search = "",
                FloatTitle = "Title",
            },
        },
    }
    ---@type NoiceViewOptions
    local popup = {
        backend = "popup",
        relative = "editor",
        close = {events = {"BufLeave"}, keys = {"q"}},
        enter = true,
        title = "Messages",
        size = {width = "120", height = "20"},
        position = "50%",
        border = {
            style = style.current.border_t,
        },
        win_options = {
            winhighlight = {
                Normal = "NoicePopup",
                FloatBorder = "NoicePopupBorder",
                FloatTitle = "Title",
            },
        },
    }
    ---@type NoiceViewOptions
    local confirm = {
        backend = "popup",
        relative = "editor",
        focusable = false,
        enter = false,
        zindex = 60,
        format = {"{confirm}"},
        align = "center",
        size = "auto",
        position = {row = "50%", col = "50%"},
        border = {
            style = style.current.border_t,
            padding = {0, 1},
            text = {top = " Confirm "},
        },
        win_options = {
            winhighlight = {
                Normal = "NoiceConfirm",
                FloatBorder = "NoiceConfirmBorder",
                FloatTitle = "Title",
                Visual = "Search",
            },
        },
    }
    ---@type NoiceViewOptions
    local cmdline = {
        backend = "popup",
        relative = "editor",
        size = {height = "auto", width = "100%"},
        position = {row = "100%", col = 0},
        win_options = {
            winhighlight = {
                Normal = "NoiceCmdline",
                IncSearch = "",
                Search = "",
            },
            -- conceallevel = 0
        },
        border = {style = "none"},
    }
    ---@type NoiceViewOptions
    local cmdline_popup = {
        backend = "popup",
        relative = "editor",
        focusable = true,
        enter = true,
        zindex = 60,
        close = {events = {"BufLeave"}, keys = {"q"}},
        title = "Output",
        size = {
            -- min_width = 60,
            -- width = "auto",
            width = math.floor(vim.o.columns * 0.9),
            height = "auto",
        },
        position = {row = -2, col = "50%"},
        border = {
            style = style.current.border_t,
            padding = {0, 1},
            text = {top = " Output "},
        },
        win_options = {
            winhighlight = {
                -- Normal = "NoiceCmdlinePopup",
                Normal = "NormalFloat", -- change to NormalFloat to make normal
                FloatBorder = "NoiceCmdlinePopupBorder",
                FloatTitle = "Title",
                IncSearch = "",
                Search = "",
            },
            cursorline = false,
            conceallevel = 0,
        },
    }
    ---@type NoiceViewOptions
    local cmdline_output = {view = "split", format = "details"}

    return {
        top_right = top_right,
        split = split,
        popupmenu = popupmenu,
        notify = notify,
        virtualtext = virtualtext,
        messages = messages,
        vsplit = vsplit,
        hover = hover,
        mini = mini,
        popup = popup,
        confirm = confirm,
        cmdline = cmdline,
        cmdline_popup = cmdline_popup,
        cmdline_output = cmdline_output,
        cmdline_notif = cmdline_notif,
    }
end

---@return NoiceRouteConfig[]
function M.setup_routes()
    ---@type NoiceRoute[]
    ---@diagnostic disable-next-line: unused-local
    local deb = {
        view = "notify",
        filter = {
            any = {
                {cond = deb()},
                -- {event = "notify", cond = deb()},
                -- {event = "msg_show", cond = deb()},
            },
        },
    }

    ---@type NoiceRoute[]
    local skips_l = {
        opts = {skip = true},
        filter = {any = {unpack(skips)}},
    }

    ---@type NoiceRoute[]
    local split_wrap = {
        view = "split",
        -- TODO: Wrap doesn't set to false
        opts = {win_options = {wrap = false, cursorline = true}},
        filter = {
            any = {
                -- Output of :filter
                {event = "msg_show", cond = cmdline([[^filt(er)?.*]])},
            },
        },
    }

    ---@type NoiceRoute[]
    local cmdline_notif = {
        view = "cmdline_notif",
        opts = {
            border = {text = {top = " cmdline "}},
            enter = false,
            focusable = true,
            timeout = 5000,
            win_options = {
                wrap = false,
                conceallevel = 0,
            },
        },
        filter = {
            cond = is_focused,
            any = {
                -- Output of :echo
                {event = "msg_show", cond = cmdline([[\v^ec%[hon] .*]], true)},
                {event = "msg_show", cond = cmdline([[^lua (?:p|=|pp|pln|print(?:f)?)\(?.*]])},
                -- Output of :map
                {event = "msg_show", cond = cmdline([[^[invxts]?(nore)?map.*]])},
                {event = "msg_show", find = "No mapping found"},
                -- Output of ls
                {event = "msg_show", cond = cmdline([[^ls!?.*]])},
                -- Output of hi
                {event = "msg_show", cond = cmdline([[\v^hi%[ghlight] .*]], true)},
                -- Output of !cmd
                {event = "msg_show", cond = cmdline([[^!.*]])},
            },
        },
    }

    ---@type NoiceRoute[]
    local split = {
        view = "split",
        filter = {
            any = {
                {min_width = 500},
                -- always route any messages with more than 20 lines to the split view
                {event = "msg_show", min_height = 20},
                {event = "msg_show", find = "Last set from .+ line %d+"},
                {event = "msg_show", find = "Last set from Lua"}, -- result of 'verbose set opt?'
                {event = "msg_show", cond = cmdline([[^\d{0,2}verb(ose)? .*]])},
            },
        },
    }

    ---@type NoiceRoute[]
    local split_debug = {
        view = "split",
        opts = {lang = "lua"},
        filter = {event = "notify", kind = "debug"},
    }

    ---@type NoiceRoute[]
    local notify = {
        view = "notify",
        filter = {
            cond = is_focused,
            any = {
                {event = "msg_show", kind = "emsg"},
                {event = "msg_show", kind = "echoerr"},
                {event = "msg_show", kind = "lua_error"},
                {event = "msg_show", kind = "rpc_error"},
                {event = "msg_show", kind = "wmsg"},
                {event = "notify", kind = "error"},
            },
        },
    }

    ---@type NoiceRoute[]
    local mini = {
        view = "mini",
        filter = {
            cond = is_focused,
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
                {event = "notify", kind = "info", find = "was successfully uninstalled"},
            },
        },
    }

    ---@type NoiceRoute[]
    local top_right = {
        view = "top_right",
        filter = {
            cond = is_focused,
            any = {
                {event = "msg_show", find = "fetching"},
                {event = "msg_show", find = "successfully fetched all PR state"},
                {event = "msg_show", find = "Hunk %d+ of %d+"},
                {event = "notify", find = ".Recording @%w"},
                {event = "notify", find = ".*Recorded @%w"},
                -- "%[master .+%] check[\r%s]+%d+ files? changed, %d+ insertions?",
            },
        },
    }

    ---@type NoiceRoute[]
    local confirm = {
        view = "confirm",
        filter = {
            any = {
                {find = "OK to remove", ["not"] = {kind = {"debug"}}},
                {find = "Save changes to", ["not"] = {kind = {"debug"}}},
                {event = "msg_show", kind = "confirm"},
                {event = "msg_show", kind = "confirm_sub"},
                -- {find = "Confirm git push", ["not"] = {kind = {"debug"}}},
                -- {event = "msg_show", kind = {"echo", "echomsg", ""}, before = true},
                -- {event = "msg_show", kind = {"echo", "echomsg"}, instant = true},
            },
        },
    }

    ---@type NoiceRoute[]
    local interactive_cli = {
        view = "mini",
        -- view = "confirm",
        filter = {
            cond = is_focused,
            any = {
                {event = "msg_show", kind = "echo", find = "^:EasyAlign"},
                {event = "msg_show", kind = "echo", find = "^:LiveEasyAlign"},
                {event = "msg_show", kind = "echo", find = "%(Unknown delimiter key: %w%)"},
            },
        },
    }

    ---@type NoiceRoute[]
    local rest = {
        view = "top_right",
        filter = {
            cond = is_focused,
            any = {
                {event = "msg_show"},
                {event = "msg_showmode"},
                -- {event = "notify"}
            },
        },
    }

    ---@type NoiceRoute[]
    ---@diagnostic disable-next-line: unused-local
    local not_focused = {
        view = "notify_send",
        opts = {stop = false},
        filter = {
            cond = function() return not is_focused() end,
            any = {
                {event = "msg_show"},
                {event = "msg_showmode"},
                {event = "notify"},
            },
        },
    }

    return {
        -- deb = deb,
        [1] = skips_l,
        [2] = split_wrap,
        [3] = cmdline_notif,
        [4] = split,
        [5] = split_debug,
        [6] = notify,
        [7] = mini,
        [8] = top_right,
        [9] = confirm,
        [10] = interactive_cli,
        [11] = rest,
        -- not_focused = not_focused,
    }
end

---Setup formatting options
---@return table<string, CmdlineFormat>
function M.setup_cmdline_formats()
    -- NoiceFormat

    -- conceal       : (default=true) This will hide the text in the cmdline that matches the pattern.
    -- view          : (default is cmdline view)
    -- opts          : any options passed to the view
    -- icon_hl_group : optional hl_group for the icon
    -- title         : set to anything or empty string to hide

    ---@type CmdlineFormat
    local cmdline = {
        pattern = "^:",
        icon = "",
        lang = "vim",
        icon_hl_group = "Macro",
    }
    ---@type CmdlineFormat
    local search_down = {
        kind = "search",
        pattern = "^/",
        icon = " ",
        lang = "regex",
        view = "cmdline",
        icon_hl_group = "MoreMsg",
    }
    ---@type CmdlineFormat
    local search_up = {
        kind = "search",
        pattern = "^%?",
        icon = " ",
        lang = "regex",
        view = "cmdline",
        icon_hl_group = "@constant",
    }
    ---@type CmdlineFormat
    local inspect = {
        pattern = {"^:%s*lua%s*=%s*", "^:%s*=%s*"},
        icon = "",
        lang = "lua",
        icon_hl_group = "@bold",
    }
    ---@type CmdlineFormat
    local lua = {
        pattern = "^:%s*lua%s+",
        icon = "",
        lang = "lua",
        view = "cmdline",
    }
    ---@type CmdlineFormat
    local help = {
        pattern = "^:%s*he?l?p?%s+",
        icon = icons.misc.question_bold,
        view = "cmdline",
        icon_hl_group = "Title",
    }
    ---@type CmdlineFormat
    local filter = {
        pattern = "^:%s*!",
        icon = "$",
        lang = "zsh",
        icon_hl_group = "PreProc",
    }
    ---@type CmdlineFormat
    local man = {
        pattern = "^:%s*Man%s+",
        icon = "龎",
        lang = "bash",
        icon_hl_group = "Statement",
    }
    ---@type CmdlineFormat
    local calculator = {
        pattern = "^:=",
        icon = icons.ui.calculator,
        lang = "vimnormal",
        icon_hl_group = "@constructor",
    }
    ---@type CmdlineFormat
    local input = {
        icon = icons.ui.chevron.right,
    }

    return {
        cmdline = cmdline,
        search_down = search_down,
        search_up = search_up,
        inspect = inspect,
        lua = lua,
        help = help,
        filter = filter,
        man = man,
        calculator = calculator,
        input = input,
    }
end

---Setup formatting options
---@return NoiceFormatOptions
function M.setup_formats()
    -- NoiceFormat
    return {}
end

---Setup statusline components
---@return table<string, NoiceFilter>
function M.setup_status()
    return {}
end

---Setup Noice commands
---@return table<string, NoiceCommand>
function M.setup_commands()
    ---Plainly show all in a split. (all split plain)
    ---@type NoiceCommand
    local all_sp = {
        view = "split",
        opts = {enter = true, title = "All"},
        border = {style = style.current.border_t, text = {top = " All "}},
        filter_opts = {history = true},
        filter = {
            any = {
                {error = true},
                {warning = true},
                {event = {"msg_show"}, ["not"] = {kind = {"search_count"}}},
                {event = {"notify", "cmdline", "lsp"}},
            },
        },
    }
    ---Show all in a split with full detail. (all split)
    ---@type NoiceCommand
    local all_sp_f = vim.deepcopy(all_sp)
    all_sp_f.opts.format = "details"

    ---Plainly show all in a popup. (all popup plain)
    ---@type NoiceCommand
    local all_p = vim.deepcopy(all_sp)
    all_p.view = "popup"

    ---Plainly show all reversed in a popup. (all popup plain reverse)
    ---@type NoiceCommand
    local all_p_r = vim.deepcopy(all_p)
    all_p_r.filter_opts.reverse = true

    ---Plainly show all items that weren't skipped in a split
    ---@type NoiceCommand
    local shown_sp = {
        view = "split",
        opts = {enter = true, title = "All"},
        border = {style = style.current.border_t, text = {top = " All "}},
        filter_opts = {history = true},
        filter = {
            ["not"] = {any = skips},
            any = {
                {error = true},
                {warning = true},
                {event = {"msg_show"}, ["not"] = {kind = {"search_count"}}},
                {event = {"notify", "cmdline", "lsp"}},
            },
        },
    }

    ---Show all items that weren't skipped in a split with full detail
    ---@type NoiceCommand
    local shown_sp_f = vim.deepcopy(shown_sp)
    shown_sp_f.opts.format = "details"

    ---Similar to `:messages`; shown in a split; full detail
    ---@type NoiceCommand
    local history = {
        -- view = "popup",
        view = "split",
        opts = {enter = true, format = "details", title = "History"},
        filter_opts = {reverse = true, history = true},
        filter = {
            any = {
                {error = true},
                {warning = true},
                {event = "lsp", kind = "message"},
                {event = "msg_show", ["not"] = {kind = {"search_count", "echo"}}},
                {event = "notify"},
            },
        },
    }

    ---Show notifications only in a split; full detail
    ---@type NoiceCommand
    local notifs = {
        view = "split",
        opts = {enter = true, format = "details", title = "Notifications"},
        filter_opts = {reverse = true},
        filter = {
            any = {
                {event = "notify"},
                {error = true},
                {warning = true},
            },
        },
    }

    ---Show last event caught by Noice in a popup; full detail
    ---@type NoiceCommand
    local last = {
        view = "popup",
        opts = {enter = true, format = "details", title = "Last"},
        border = {style = style.current.border_t, text = {top = " Last "}},
        filter_opts = {count = 1, history = true},
        filter = {
            any = {
                {error = true},
                {warning = true},
                {event = {"msg_show"}, ["not"] = {kind = {"search_count"}}},
                {event = {"notify", "cmdline", "lsp"}},
            },
        },
    }

    ---Show many types of events in a split; plainly
    ---@type NoiceCommand
    local trace_p = {
        view = "split",
        opts = {enter = true, title = "Trace"},
        border = {style = style.current.border_t, text = {top = " Trace "}},
        filter = {
            ["not"] = {any = skips},
        },
    }
    ---Show many types of events in a split; full detail
    ---@type NoiceCommand
    local trace = {
        view = "split",
        opts = {enter = true, format = "details", title = "Trace"},
        border = {style = style.current.border_t, text = {top = " Trace "}},
        filter = {
            ["not"] = {any = skips},
            -- any = {
            --     {error = true},
            --     {warning = true},
            --     {event = {"msg_show", "msg_showmode", "msg_ruler"}},
            --     {event = {"msg_clear", "msg_history_show", "msg_history_clear"}},
            --     {event = {"cmdline"}},
            --     {event = {"notify", "lsp"}},
            -- },
        },
    }

    ---Show warnings and errors in a popup; full detail
    ---@type NoiceCommand
    local errors = {
        view = "popup",
        opts = {enter = true, format = "details"},
        filter_opts = {reverse = true},
        filter = {any = {{error = true}, {warning = true}}},
    }
    ---Show warnings and errors in a split; full detail
    ---@type NoiceCommand
    local errorsSp = {
        view = "split",
        opts = {enter = true, format = "details"},
        filter_opts = {reverse = true},
        filter = {any = {{error = true}, {warning = true}}},
    }
    ---Show warnings in a split; full detail
    ---@type NoiceCommand
    local warnings = {
        view = "split",
        opts = {enter = true, format = "details"},
        filter_opts = {reverse = true},
        filter = {warning = true},
    }

    return {
        all_sp = all_sp,
        all_sp_f = all_sp_f,
        all_p = all_p,
        all_p_r = all_p_r,
        shown_sp = shown_sp,
        shown_sp_f = shown_sp_f,
        history = history,
        notifs = notifs,
        last = last,
        errors = errors,
        errorsSp = errorsSp,
        warnings = warnings,
        trace = trace,
        trace_p = trace_p,
    }
end

---Toggle Noice on/off
function M.toggle()
    local c = require("noice.config")
    if c.is_running() then
        noice.disable()
        log.info("disabled", {title = "Noice"})
        vim.o.cmdheight = 2
    else
        noice.enable()
        log.info("enabled", {title = "Noice"})
    end
end

---Execute a function with noice disabled, includes checks
---@generic A, R
---@param func fun(...: A): R?
---@param ... A
---@return R?
function M.wrap_disable(func, ...)
    local noice_l
    prequire("noice"):thenCall(function(n)
        local c = require("noice.config")
        if c.is_running() then
            n.disable()
            noice_l = n
        end
    end)
    local ok, res = pcall(func, ...)
    if noice_l then
        noice_l.enable()
    end
    if not ok then
        log.err(res, {debug = true, title = "Noice"})
        return
    end
    return res
end

---Execute a function with noice disabled, don't check if enabled or for errors
---@generic A
---@param exec string|fun(...: A)
---@param ... A
function M.disable(exec, ...)
    pcall(xprequire("noice").disable)
    if type(exec) == "string" then
        pcall(cmd, exec)
    elseif type(exec) == "function" then
        pcall(exec, ...)
    end
    vim.schedule(function()
        pcall(xprequire("noice").enable)
    end)
end

local function init()
    def_views.mini.timeout = 5000
    ---@class Noice.Config.Control
    control = {
        lsp = true,
        smart_move = true,                   -- try to move out of the way of existing floating windows
        health = true,                       -- run a health check
        notify = true,                       -- use noice as replacement for vim.notify
        popupmenu = false,                   -- enables the Noice popupmenu UI
        messages = true,                     -- replace `:messages` with noice
        cmdline = true,                      -- enable the noice cli
        presets = {
            bottom_search = false,           -- use a classic bottom cmdline for search
            command_palette = false,         -- position the cmdline and popupmenu together
            long_message_to_split = false,   -- long messages will be sent to a split
            inc_rename = false,              -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false,          -- add a border to hover docs and signature help
            cmdline_output_to_split = false, -- send the output of a command you executed in the cmdline to a split
        },
    }

    skips = {
        -- "noice.lua" 1318L, 55370B [w]
        {event = "msg_show", find = "%[w%]$"},                                 -- Writing a file
        {event = "msg_show", find = '^".*"$'},                                 -- Writing a file
        {event = "msg_show", find = "/[^/]+/[^ ]+ %d+L, %d+B"},
        {event = "msg_show", find = "^%?"},                                    -- `N` after search
        {event = "msg_show", kind = {"echo", ""}, find = "^/\\?"},             -- `*`
        {event = "msg_show", kind = {"echo", ""}, find = "^\\"},               -- `#`
        {event = "msg_show", kind = {"echo", ""}, find = "^[%w_]+/s[+]%d+"},   -- `g*`
        {event = "msg_show", kind = {"echo", ""}, find = "^[%w_]+[?]s[+]%d+"}, -- `g#`
        {event = "msg_show", find = "^/[^/]+$"},                               -- search display
        {event = "msg_show", kind = "search_count"},
        {event = "msg_show", find = "%d+ lines indented ?$"},                  -- indenting
        {event = "msg_show", find = "%d+ lines to indent... ?$"},              -- indenting
        {event = "msg_show", find = "%d+ lines >ed %d+ time"},                 -- indenting
        {event = "msg_show", find = "%d+ lines <ed %d+ time"},                 -- indenting
        {event = "msg_show", find = "No active Snippet"},
        {event = "msg_show", find = "redraw"},
        {event = "msg_show", find = "Hop %d char"},
        -- An error is displayed on top of this message (sometimes)
        {event = "msg_show", kind = "echo", find = "Mark not set"},
        -- search term is not found
        {event = "msg_show", kind = "emsg", find = "Pattern not found"},
        -- shows macro recording (I have custom func)
        {event = "msg_showmode", find = "recording @%w$"},
        {event = "msg_show", kind = "echo", cond = content([[^Running: rg]])},
        {event = "msg_show", kind = "echo", find = "%d: nvim_exec2%(%): .*E486: Pattern not found"},
        {
            event = "notify",
            kind = "debug",
            find = "indent-blankline Invalid 'line': out of range",
        },
        -- Comes after easy align (would be nice to use the CLI interactively)
        -- '('
        -- '_'
        -- ')'
        {
            event = "msg_show",
            kind = "echo",
            max_length = 1,
            cond = function(m)
                ---@diagnostic disable-next-line: return-type-mismatch
                return m:content():rxfind([[^(\(|_|\))$]])
            end,
        },
    }

    M.setup()

    map(
        "c",
        "<S-Enter>",
        function()
            mpi.noautocmd(function()
                noice.redirect(fn.getcmdline())
                utils.normal("t", "<esc>")
            end)
        end,
        {desc = "Redirect to split (noice)"}
    )
    map(
        "c",
        "<C-S-Enter>",
        function()
            mpi.noautocmd(function()
                noice.redirect(fn.getcmdline(), "cmdline_output")
                utils.normal("t", "<esc>")
            end)
        end,
        {desc = "Redirect to float (noice)"}
    )

    wk.register({
        ["<C-S-N>"] = {"<Cmd>NoiceDismiss<CR>", "Noice: dismiss"},
        ["<Leader>nn"] = {M.toggle, "Noice: toggle"},
        ["<Leader>nl"] = {"<Cmd>NoiceLast<CR>", "Noice: last (P)"},
        ["<Leader>ne"] = {"<Cmd>NoiceErrors<CR>", "Noice: errors (F)"},
        ["<Leader>nw"] = {"<Cmd>NoiceWarnings<CR>", "Noice: warnings (F)"},
        ["<Leader>no"] = {"<Cmd>NoiceNotifs<CR>", "Noice: notifications (S)"},
        ["<Leader>na"] = {"<Cmd>NoiceAllp<CR>", "Noice: all (P)"},
        ["<Leader>nr"] = {"<Cmd>NoiceAllpRev<CR>", "Noice: all rev (P)"},
        ["<Leader>nS"] = {"<Cmd>NoiceAll<CR>", "Noice: all full (S)"},
        ["<Leader>ns"] = {"<Cmd>NoiceAllSp<CR>", "Noice: all (S)"},
        ["<Leader>nh"] = {"<Cmd>NoiceHistory<CR>", "Noice: history (S)"},
        ["<Leader>nv"] = {"<Cmd>NoiceShownp<CR>", "Noice: shown (S)"},
        ["<Leader>nV"] = {"<Cmd>NoiceShown<CR>", "Noice: shown full (S)"},
        ["<Leader>nm"] = {"<Cmd>messages<CR>", "Noice: messages (S)"},
        ["<Leader>nd"] = {"<Cmd>NoiceDebug<CR>", "Noice: debug"},
    })

    require("telescope").load_extension("noice")
end

init()

return M
