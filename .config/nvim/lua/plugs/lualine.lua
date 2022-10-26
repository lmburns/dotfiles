---@diagnostic disable:need-check-nil

local M = {}

local D = require("dev")
local lualine = D.npcall(require, "lualine")
if not lualine then
    return
end

local colors = require("kimbox.colors")
local style = require("style")
local icons = style.icons

-- local overseer = require("overseer")

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
-- local autocmd = utils.autocmd

local fs = vim.fs
local fn = vim.fn
local F = vim.F
local api = vim.api
local cmd = vim.cmd
local g = vim.g
-- local uv = vim.loop

local stl = require("common.utils.stl")
local conds = stl.conditions
local plugs = stl.plugins
local only_pad_right = stl.other.only_pad_right

-- map("", "J", function()
--     api.nvim_echo({{vim.inspect(api.nvim_get_mode()), "WarningMsg"}}, true, {})
-- end
-- )

---@param trunc_width number trunctates component when screen width is less then trunc_width
---@param trunc_len number truncates component to trunc_len number of chars
---@param hide_width number hides component when window width is smaller then hide_width
---@param no_ellipsis boolean whether to disable adding '' at end after truncation
---return function that can format the component accordingly
---@diagnostic disable-next-line:unused-function, unused-local
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
    return function(str)
        local win_width = fn.winwidth(0)
        if hide_width and win_width < hide_width then
            return ""
        elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
            return str:sub(1, trunc_len) .. (F.tern(no_ellipsis, "", ""))
        end
        return str
    end
end

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 1
-- ╘══════════════════════════════════════════════════════════╛
local sections_1 = {
    lualine_a = {
        {
            "mode",
            fmt = function(str)
                -- if api.nvim_get_mode().mode == "no" then
                --     return "OP"
                -- end
                return ("%s %s"):format((str == "V-LINE" and "VL") or (str == "V-BLOCK" and "VB") or str:sub(1, 1), "")
            end,
            padding = only_pad_right
        }
    },
    lualine_b = {
        -- Separators aren't shown here
        {
            "filetype",
            icon_only = false
        },
        {
            "filesize",
            cond = function()
                return conds.hide_in_width() and conds.buffer_not_empty()
            end,
            color = {fg = colors.green}
        },
        {
            plugs.file_encoding.fn,
            cond = plugs.file_encoding.toggle
        },
        {
            plugs.spell.fn,
            cond = plugs.spell.toggle,
            color = "SpellCap",
            padding = only_pad_right,
            type = "stl"
        },
        {
            "filename",
            path = 0,
            symbols = {
                modified = icons.misc.modified,
                readonly = icons.misc.readonly,
                unnamed = icons.misc.unnamed,
                shorting_target = 40
            },
            ---@diagnostic disable:unused-local
            color = function(section)
                -- return { fg = vim.bo.modified and colors.purple or colors.fg }
                return {
                    gui = F.tern(vim.bo.modified, "bold", "none"),
                    fg = F.tern(vim.b.fugitive_fname, colors.orange, "none")
                }
            end,
            fmt = function(str)
                local bufname = api.nvim_buf_get_name(0)
                local fugitive_name = vim.b.fugitive_fname
                if not fugitive_name then
                    if bufname:match("^fugitive:") and fn.exists("*FugitiveReal") == 1 then
                        fugitive_name = fs.basename(fn.FugitiveReal(bufname)) .. " "
                        vim.b.fugitive_fname = fugitive_name
                    end
                end

                return F.tern(fugitive_name, fugitive_name, str)
            end
        },
        {
            "%w",
            cond = function()
                return vim.wo.previewwindow
            end
        }
    },
    lualine_c = {plugs.coc_status.fn},
    lualine_x = {},
    lualine_y = {
        {
            plugs.gps.fn,
            cond = function()
                return conds.is_available_gps() and conds.hide_in_width() -- and conds.coc_status_width()
            end
        },
        -- {
        --     "aerial",
        --     sep = "",
        --     depth = nil,
        --     dense = true,
        --     dense_sep = "  ",
        --     colored = true,
        --     color = {fg = colors.morning_blue}
        -- },
        {
            "diagnostics",
            sources = {"nvim_diagnostic", "coc"},
            symbols = {
                error = icons.lsp.sb.error,
                warn = icons.lsp.sb.warn,
                info = icons.lsp.sb.info,
                hint = icons.lsp.sb.hint
            }
        },
        -- FIX: When gps isn't show there's a white seperator shown
        {
            "diff",
            colored = true,
            diff_color = {
                added = "GitSignsAdd", -- "DiffAdd",
                modified = "GitSignsChange", --  "DiffChange",
                removed = "GitSignsDelete" -- "DiffDelete"
            },
            symbols = {added = icons.git.add, modified = icons.git.mod, removed = icons.git.remove},
            source = plugs.diff.fn
            -- separator = {left = ""}
        },
        {plugs.luapad.fn, cond = plugs.luapad.toggle},
        {plugs.debugger.fn, cond = plugs.debugger.toggle}
    },
    lualine_z = {
        {
            plugs.gitbuf.fn,
            color = {fg = colors.light_red, gui = "bold"}
        },
        {
            plugs.recording.fn,
            color = {fg = colors.orange, gui = "bold"}
        },
        {
            -- "branch",
            -- "FugitiveHead",
            "b:gitsigns_head",
            icon = icons.git.branch,
            cond = function()
                -- local ok, ret = pcall(plugs.search_result.fn)
                -- if not ok then
                return conds.check_git_workspace()
                -- end
                -- return conds.check_git_workspace() and ret == ""
            end,
            color = F.tern(g.colors_name == "kimbox", {fg = colors.dyellow, gui = "bold"}, {gui = "bold"})
        },
        {
            plugs.quickfix_count.fn,
            separator = {left = plugs.sep()}
        },
        plugs.loclist_count.fn,
        {
            "%3l %3v",
            fmt = function(s)
                return ("%s %s"):format(icons.misc.line, s)
            end
        },
        F.tern(
            g.colors_name == "kimbox",
            {
                "%p%%/%-3L",
                color = {fg = colors.light_red, gui = "bold"}
            },
            {
                "%p%%/%-3L"
            }
        )
        -- {
        --     "overseer",
        --     label = "", -- Prefix for task counts
        --     colored = true, -- Color the task icons and counts
        --     symbols = {
        --         [overseer.STATUS.FAILURE] = "F:",
        --         [overseer.STATUS.CANCELED] = "C:",
        --         [overseer.STATUS.SUCCESS] = "S:",
        --         [overseer.STATUS.RUNNING] = "R:"
        --     },
        --     unique = true, -- Unique-ify non-running task count by name
        --     name = nil, -- List of task names to search for
        --     name_not = false, -- When true, invert the name search
        --     status = nil, -- List of task statuses to display
        --     status_not = false -- When true, invert the status search
        -- }
        -- "%l:%c",
        -- "%p%%/%L",
        -- plugs.search_result.fn
    }
}

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 2
-- ╘══════════════════════════════════════════════════════════╛
local sections_2 = {
    lualine_a = {"mode"},
    lualine_b = {
        {"filetype", icon_only = true},
        "fileformat",
        {"filesize", cond = conds.hide_in_width},
        {plugs.file_encoding.fn, cond = plugs.file_encoding.toggle},
        {
            "filename",
            file_status = 1,
            path = 1,
            symbols = {modified = icons.misc.modified, readonly = icons.misc.readonly, unnamed = icons.misc.unnamed}
        }
    },
    lualine_c = {},
    lualine_x = {
        {
            -- { 'aerial', sep = '', dense = true, dense_sep = '  ' },
            plugs.gps.fn,
            cond = function()
                return conds.is_available_gps() and conds.hide_in_width() -- and conds.coc_status_width()
            end,
            color = {fg = colors.red}
        },
        {
            "branch",
            icon = icons.git.branch,
            cond = conds.check_git_workspace
        }
    },
    lualine_y = {
        plugs.progress.fn,
        {plugs.gutentags_progress.fn, cond = plugs.gutentags_progress.toggle}
    },
    lualine_z = {"location"}
}

-- ╒══════════════════════════════════════════════════════════╕
--                           Mapping
-- ╘══════════════════════════════════════════════════════════╛
-- It has to do with the added padding
function M.toggle_mode()
    local ll_req = require("lualine_require")
    local modules = ll_req.lazy_require({config_module = "lualine.config"})
    local current_config = modules.config_module.get_config()
    local lutils = require("lualine.utils.utils")

    if D.tbl_equivalent(current_config.sections, sections_1) then
        -- if vim.inspect(current_config.sections) == vim.inspect(sections_1) then
        current_config.sections = lutils.deepcopy(sections_2)
    else
        current_config.sections = lutils.deepcopy(sections_1)
    end
    require("lualine").setup(current_config)
end

-- ╒══════════════════════════════════════════════════════════╕
--                           Autocmds
-- ╘══════════════════════════════════════════════════════════╛
function M.autocmds()
    -- Clear the builtin Lualine ModeChanged
    vim.defer_fn(
        function()
            cmd("au! lualine_stl_refresh  CursorMoved") -- Messes up certain languages (like Rust)
            cmd("au! lualine_stl_refresh  ModeChanged")
            cmd("au! lualine_stl_refresh  BufEnter")
        end,
        20
    )

    augroup(
        "lmb__Lualine",
        {
            event = "User",
            pattern = {
                "NeogitPushComplete",
                "NeogitCommitComplete",
                "NeogitStatusRefresh"
            },
            desc = "Update branch and diff statusline components",
            command = function()
                require("lualine.components.diff.git_diff").update_diff_args()
                require("lualine.components.diff.git_diff").update_git_diff()
            end
        },
        {
            event = {"RecordingEnter", "RecordingLeave", "BufWritePost", "BufModifiedSet"},
            pattern = "*",
            desc = "Update statusline on macro enter/exit, and buffer modification",
            command = function()
                lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
            end
        },
        -- This has been fixed, but it redraws too often
        {
            event = "ModeChanged",
            pattern = "*",
            desc = "Update statusline to show operator pending mode",
            command = function()
                -- Lazy redraw just now started causing me problems
                if _t({"no", "nov", "noV"}):contains(vim.v.event.new_mode) then
                    lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
                end
            end
        },
        {
            event = "BufEnter",
            pattern = "*",
            desc = "Update Lualine statusline refresh to match against Wilder",
            command = function()
                local bufname = api.nvim_buf_get_name(0)
                if not bufname:match("%[Wilder Float %d%]") then
                    lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
                end
            end
        }
    )
end

-- ╒══════════════════════════════════════════════════════════╕
--                             Init
-- ╘══════════════════════════════════════════════════════════╛
local function init()
    M.autocmds()
    map("n", "!", ":lua require('plugs.lualine').toggle_mode()<CR>", {silent = true})

    local my_extension = {
        sections = {
            lualine_a = {
                {
                    "mode",
                    fmt = function(str)
                        return ("%s %s"):format(str, "")
                    end,
                    padding = only_pad_right
                }
            },
            lualine_b = {"filetype"},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {
                "%l:%c",
                "%p%%/%L"
            }
        },
        filetypes = {
            "packer",
            "vista",
            "coctree",
            "NeogitStatus",
            "undotree",
            "TelescopePrompt",
            "tsplayground",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "man",
            "neoterm",
            "floaterm"
        } -- aerial
    }

    lualine.setup(
        {
            options = {
                icons_enabled = true,
                theme = "auto",
                globalstatus = true,
                always_divide_middle = true,
                section_separators = {left = "", right = ""},
                component_separators = {left = "", right = ""},
                refresh = {
                    statusline = 1000,
                    tabline = 0,
                    winbar = 0
                },
                disabled_filetypes = {
                    statusline = {
                        "NvimTree",
                        "quickmenu",
                        "wilder"
                    },
                    winbar = {}
                }
            },
            sections = sections_1,
            -- Inactive sections don't change with FocusLost
            inactive_sections = {
                lualine_a = {},
                lualine_b = {
                    {"filetype", icon_only = false},
                    {
                        "filesize",
                        cond = function()
                            return conds.hide_in_width() and conds.buffer_not_empty()
                        end,
                        color = {fg = colors.green}
                    },
                    {plugs.file_encoding.fn, cond = plugs.file_encoding.toggle},
                    {
                        "filename",
                        path = 0,
                        symbols = {
                            modified = icons.misc.modified,
                            readonly = icons.misc.readonly,
                            unnamed = icons.misc.unnamed
                        },
                        ---@diagnostic disable:unused-local
                        color = function(section)
                            -- return { fg = vim.bo.modified and colors.purple or colors.fg }
                            return {gui = F.tern(vim.bo.modified, "bold", "none")}
                        end
                    }
                },
                lualine_c = {},
                lualine_x = {"location"},
                lualine_y = {},
                lualine_z = {}
            },
            winbar = {},
            inactive_winbar = {},
            tabline = {},
            -- tabline = {
            --   lualine_a = { "tabs" },
            --   lualine_b = { { "buffers" } },
            --   lualine_c = {},
            --   lualine_x = {},
            --   lualine_y = {},
            --   lualine_z = {
            --     {
            --       'require("nvim-gps").get_location()',
            --       cond = conds.is_available_gps,
            --     },
            --   },
            -- },
            extensions = {
                -- "quickfix",
                stl.extensions.qf,
                stl.extensions.toggleterm,
                stl.extensions.trouble,
                my_extension,
                "symbols-outline",
                "aerial",
                "fzf",
                "fugitive",
                "nvim-dap-ui"
            }
        }
    )
end

init()

return M
