---@module 'plugs.lualine'
local M = {}

local F = Rc.F
local lualine = F.npcall(require, "lualine")
if not lualine then
    return
end

local C = Rc.shared.C

local colors = require("kimbox.colors")
local I = Rc.icons
local llicons = Rc.style.plugins.lualine

local map = Rc.api.map
local augroup = Rc.api.augroup

local fs = vim.fs
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local g = vim.g
-- local uv = vim.uv

-- local overseer = require("overseer")

local stl = require("usr.stl")
local conds = stl.conditions
local plugs = stl.plugins
local builtin = stl.builtin
local only_pad_right = stl.other.only_pad_right

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 1
-- ╘══════════════════════════════════════════════════════════╛
local sections_1 = {
    lualine_a = {builtin.mode.fn()},
    lualine_b = {
        -- Separators aren't shown here
        builtin.filetype.fn(),
        builtin.filesize.fn({color = {fg = colors.green}}),
        {
            plugs.vm.fn,
            cond = plugs.vm.toggle,
            color = {fg = colors.teaberry, gui = "bold"},
        },
        {
            plugs.file_encoding.fn,
            cond = plugs.file_encoding.toggle,
        },
        {
            plugs.spell.fn,
            cond = plugs.spell.toggle,
            color = "SpellCap",
            padding = only_pad_right,
            type = "stl",
        },
        builtin.filename.fn({
            color = function(_section)
                return {
                    gui = F.if_expr(vim.bo.modified, "bold", "none"),
                    fg = F.if_expr(
                        vim.b.fugitive_fname,
                        colors.orange,
                        F.if_expr(vim.bo.readonly, colors.beaver, "none")
                    ),
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

                return F.unwrap_or(fugitive_name, str)
            end,
        }),
        {
            "%w",
            cond = function()
                return vim.wo.previewwindow
            end,
        },
    },
    lualine_c = {{plugs.coc_status.fn}},
    lualine_x = {},
    lualine_y = {
        {
            plugs.gps.fn,
            color = {fg = colors.sea_green, gui = "bold"},
            cond = function()
                return conds.is_available_gps() and conds.hide_in_width()
                -- and conds.coc_status_width()
            end,
        },
        -- {plugs.treesitter.fn},
        -- {plugs.vim_matchup.fn},
        -- {
        --     plugs.noice.command.fn,
        --     cond = plugs.noice.command.toggle,
        --     color = {fg = colors.orange, gui = "bold"},
        -- },
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
                error = I.lsp.sb.error,
                warn = I.lsp.sb.warn,
                info = I.lsp.sb.info,
                hint = I.lsp.sb.hint,
            },
        },
        -- FIX: When gps isn't shown there's a white seperator visible
        builtin.diff.fn(),
        {plugs.luapad.fn, cond = plugs.luapad.toggle},
        {plugs.debugger.fn, cond = plugs.debugger.toggle},
    },
    lualine_z = {
        {
            plugs.gitbuf.fn,
            color = {fg = colors.fuzzy_wuzzy, gui = "bold"},
        },
        {
            plugs.recording.fn,
            color = {fg = colors.orange, gui = "bold"},
        },
        plugs.branch.fn(),
        {
            plugs.quickfix_count.fn,
            separator = {left = plugs.sep()},
            color = {fg = colors.oni_violet, gui = "bold"},
        },
        {
            plugs.loclist_count.fn,
            separator = {left = plugs.sep()},
            color = {fg = colors.oni_violet, gui = "bold"},
        },
        plugs.location.fn(),
        {
            plugs.foldlevel.fn,
            color = {fg = colors.yellow, gui = "bold"},
        },
        builtin.selectioncount.fn(),
        F.if_expr(
            g.colors_name == "kimbox",
            {"%p%%/%-3L", color = {fg = colors.fuzzy_wuzzy, gui = "bold"}},
            {"%p%%/%-3L"}
        ),
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
    },
}

-- ╒══════════════════════════════════════════════════════════╕
--                          Section 2
-- ╘══════════════════════════════════════════════════════════╛
local sections_2 = {
    lualine_a = {builtin.mode.fn({}, true)},
    lualine_b = {
        builtin.filetype.fn(),
        builtin.filesize.fn({cond = conds.hide_in_width}),
        {plugs.file_encoding.fn, cond = plugs.file_encoding.toggle},
        builtin.filename.fn({path = 1}),
    },
    lualine_c = {},
    lualine_x = {
        {
            -- { 'aerial', sep = '', dense = true, dense_sep = '  ' },
            plugs.gps.fn,
            cond = function()
                return conds.is_available_gps() and conds.hide_in_width()
            end,
            color = {fg = colors.red},
        },
        plugs.branch.fn(),
    },
    lualine_y = {
        plugs.progress.fn,
        {
            plugs.gutentags_progress.fn,
            cond = plugs.gutentags_progress.toggle,
        },
    },
    lualine_z = {plugs.location.fn({}, false)},
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

    if C.tbl_equivalent(current_config.sections, sections_1) then
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
            -- cmd("au! lualine_stl_refresh  CursorMoved") -- Messes up certain languages (like Rust)
            cmd("au! lualine_stl_refresh  ModeChanged")
            cmd("au! lualine_stl_refresh  BufEnter")
        end,
        20
    )

    augroup(
        "lmb__Lualine",
        {
            event = "User",
            pattern = {"NeogitPushComplete", "NeogitCommitComplete", "NeogitStatusRefresh"},
            desc = "Update branch and diff statusline components",
            command = function()
                require("lualine.components.diff.git_diff").update_diff_args()
                require("lualine.components.diff.git_diff").update_git_diff()
            end,
        },
        {
            event = {"RecordingEnter", "RecordingLeave", "BufWritePost", "BufModifiedSet"},
            pattern = "*",
            desc = "Update statusline on macro enter/exit, and buffer modification",
            command = function()
                lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
            end,
        },
        -- This has been fixed, but it redraws too often
        {
            event = "ModeChanged",
            pattern = "*",
            desc = "Update statusline to show operator pending mode",
            command = function()
                if _t({"no", "nov", "noV"}):contains(vim.v.event.new_mode) then
                    lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
                end
            end,
        },
        {
            event = "BufEnter",
            pattern = "*",
            desc = "Update Lualine statusline refresh to match against Wilder",
            command = function()
                local bufname = fn.bufname()
                if not bufname:match("%[Wilder Float %d%]") then
                    lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
                end
            end,
        },
        {
            event = "User",
            pattern = "CocStatusChange",
            desc = "Update Lualine statusline when Coc status changes",
            command = function()
                lualine.refresh({kind = "window", place = {"statusline"}, trigger = "timer"})
            end,
        }
    )
end

-- ╒══════════════════════════════════════════════════════════╕
--                             Init
-- ╘══════════════════════════════════════════════════════════╛
local function init()
    M.autocmds()
    map("n", "!", M.toggle_mode, {silent = true, desc = "Change Lualine"})

    local my_extension = {
        sections = {
            lualine_a = {builtin.mode.fn({}, true)},
            lualine_b = {builtin.filetype.fn()},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {
                plugs.location.fn(),
                builtin.selectioncount.fn(),
                F.if_expr(
                    g.colors_name == "kimbox",
                    {"%p%%/%-3L", color = {fg = colors.fuzzy_wuzzy, gui = "bold"}},
                    {"%p%%/%-3L"}
                ),
            },
        },
        filetypes = {
            "aerial",
            -- "DiffviewFileStatus",
            -- "DiffviewFileHistoryPanel",
            -- "NeogitStatus",
            "TelescopePrompt",
            "coctree",
            "dapui_breakpoints",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "floaterm",
            "neoterm",
            "packer",
            "tsplayground",
            "undotree",
            "vista",
        },
    }

    lualine.setup({
        options = {
            icons_enabled = true,
            theme = "auto",
            globalstatus = true,
            always_divide_middle = true,
            section_separators = {left = llicons.sep.tri_right, right = llicons.sep.tri_left},
            component_separators = {left = llicons.sep.slant, right = llicons.sep.slant},
            -- If current filetype is in this list it'll
            -- always be drawn as inactive statusline
            -- and the last window will be drawn as active statusline.
            -- for example if you don't want statusline of
            -- your file tree / sidebar window to have active
            -- statusline you can add their filetypes here.
            ignore_focus = {"netrw"},
            refresh = {
                statusline = 1000,
                tabline = 0,
                winbar = 0,
            },
            disabled_filetypes = {
                statusline = {
                    "NvimTree",
                    "quickmenu",
                    "wilder",
                },
                winbar = {},
            },
        },
        sections = sections_1,
        -- Inactive sections don't change with FocusLost
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            -- lualine_b = {
            --     builtin.filetype.fn(),
            --     builtin.filesize.fn({color = {fg = colors.green}}),
            --     {
            --         plugs.file_encoding.fn,
            --         cond = plugs.file_encoding.toggle,
            --     },
            --     builtin.filename.fn({
            --         path = 1,
            --         color = function(_section)
            --             return {gui = F.if_expr(vim.bo.modified, "bold", "none")}
            --         end,
            --     }),
            -- },
            lualine_c = {},
            lualine_x = {plugs.location.fn()},
            lualine_y = {},
            lualine_z = {},
        },
        winbar = {},
        inactive_winbar = {},
        tabline = {},
        extensions = {
            -- "fugitive",
            -- "aerial",
            stl.extensions.trouble,
            stl.extensions.neogit,
            stl.extensions.diffview,
            stl.extensions.qf,
            stl.extensions.toggleterm,
            stl.extensions.man,
            my_extension,
            "symbols-outline",
            "fzf",
            "nvim-dap-ui",
        },
    })
end

init()

return M
