local M = {}

local D = require("dev")
local lualine = D.npcall(require, "lualine")
if not lualine then
    return
end

local colors = require("kimbox.colors")
local style = require("style")
local icons = style.icons

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup

local stl = require("common.utils.stl")
local conds = stl.conditions
local plugs = stl.plugins
local only_pad_right = stl.other.only_pad_right

-- map("", "J", function()
--     api.nvim_echo({{vim.inspect(api.nvim_get_mode()), "WarningMsg"}}, true, {})
-- end
-- )

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 1
-- ╘══════════════════════════════════════════════════════════╛
local sections_1 = {
    lualine_a = {
        {
            -- FIX: Doesn't show operator mode?
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
            padding = only_pad_right
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
            color = function(section)
                -- return { fg = vim.bo.modified and colors.purple or colors.fg }
                return {gui = vim.bo.modified and "bold" or "none"}
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
                return conds.is_available_gps() and conds.hide_in_width() and conds.coc_status_width()
            end,
            color = {fg = colors.morning_blue}
        },
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
        -- FIX: When gps isn't show there's a white seprator shown
        {
            "diff",
            colored = true,
            diff_color = {
                added = "GitSignsAdd", -- "DiffAdd",
                modified = "GitSignsChange", --  "DiffChange",
                removed = "GitSignsDelete" -- "DiffDelete"
            },
            symbols = {added = icons.git.add, modified = icons.git.mod, removed = icons.git.remove}
            -- separator = {left = ""}
        },
        {plugs.luapad.fn, cond = plugs.luapad.toggle},
        {plugs.debugger.fn, cond = plugs.debugger.toggle}
    },
    lualine_z = {
        {
            "branch",
            icon = icons.git.branch,
            cond = function()
                local ok, ret = pcall(plugs.search_result.fn)
                if not ok then
                    return conds.check_git_workspace()
                end
                return conds.check_git_workspace() and ret == ""
            end
        },
        {plugs.quickfix_count.fn, separator = {left = plugs.sep()}},
        plugs.loclist_count.fn,
        "%l:%c",
        -- "%p%%" .. (("/%s"):format(require("common.builtin").tokei() or "")) .. "/%L",
        "%p%%/%L",
        plugs.search_result.fn
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
            -- "aerial"
            'require("nvim-gps").get_location()',
            cond = conds.is_available_gps,
            color = {fg = colors.red}
        },
        {
            "branch",
            icon = icons.git.branch,
            cond = conds.check_git_workspace
        }
        -- "b:gitsigns_head"
        -- "Fugitivehead"
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
-- FIX: This stopped working once items were moved out of this file
-- It has to do with the added padding
function M.toggle_mode()
    local ll_req = require("lualine_require")
    local modules = ll_req.lazy_require({config_module = "lualine.config"})
    local current_config = modules.config_module.get_config()
    local lutils = require("lualine.utils.utils")

    if D.tbl_equivalent(current_config.sections, sections_1) then
        current_config.sections = lutils.deepcopy(sections_2)
    else
        current_config.sections = lutils.deepcopy(sections_1)
    end
    require("lualine").setup(current_config)
end

map("n", "!", ":lua require('plugs.lualine').toggle_mode()<CR>", {silent = true})

-- ╒══════════════════════════════════════════════════════════╕
--                           Autocmds
-- ╘══════════════════════════════════════════════════════════╛
function M.autocmds()
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
            event = "ModeChanged",
            pattern = "*",
            desc = "Update statusline to show operator pending mode",
            command = function()
                -- Lazy redraw just now started causing me problems
                if _t({"no", "nov", "noV"}):contains(vim.v.event.new_mode) and not vim.opt.lazyredraw:get() then
                    ex.redraws()
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
            "NvimTree",
            "coc-explorer",
            "coctree",
            "NeogitStatus",
            "undotree",
            "TelescopePrompt",
            "tsplayground",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches"
        } -- aerial
    }

    lualine.setup(
        {
            options = {
                icons_enabled = true,
                theme = "auto",
                globalstatus = true, -- enable global statusline (single SL for all windows)
                always_divide_middle = true,
                section_separators = {left = "", right = ""},
                component_separators = {left = "", right = ""},
                disabled_filetypes = {
                    -- "help",
                    -- "undotree",
                    "NvimTree",
                    "coc-explorer",
                    "quickmenu",
                    "neoterm",
                    "floaterm"
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
                        color = function(section)
                            -- return { fg = vim.bo.modified and colors.purple or colors.fg }
                            return {gui = vim.bo.modified and "bold" or "none"}
                        end
                    }
                },
                lualine_c = {},
                lualine_x = {"location"},
                lualine_y = {},
                lualine_z = {}
            },
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
                "symbols-outline",
                my_extension,
                "aerial",
                "fzf",
                "fugitive"
            }
        }
    )
end

init()

return M
