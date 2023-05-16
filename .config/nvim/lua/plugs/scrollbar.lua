---@module 'plugs.scrollbar'
local M = {}

local D = require("dev")
local scrollbar = D.npcall(require, "scrollbar")
if not scrollbar then
    return
end

local style = require("style")
local icons = style.icons

function M.setup()
    local colors = require("kimbox.colors")

    local keep = {"markdown", "vimwiki"}
    local bl = BLACKLIST_FT:filter(function(f)
        if _t(keep):contains(f) then
            return false
        end
        return true
    end)

    scrollbar.setup({
        show = true,
        show_in_active_only = false,
        set_highlights = true,
        folds = 1000,                    -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
        maxlines = false,
        hide_if_all_visible = false,     -- Hides everything if all lines are visible
        throttle_ms = 100,
        handle = {
            text = " ",
            color = "#7E602C",
            cterm = nil,
            highlight = "CursorColumn",
            hide_if_all_visible = true,     -- Hides handle if all lines are visible
        },
        marks = {
            Cursor = {
                text = icons.ui.dot,
                priority = 0,
                color = colors.orange,
                cterm = nil,
                highlight = "Normal",
            },
            Search = {
                text = {"-", "󰫢"}, -- =
                priority = 0,
                color = colors.blue,
                cterm = nil,
                highlight = "Search",
            },
            Error = {
                text = {"-", "󰜁"}, -- = 
                priority = 1,
                color = colors.red,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextError",
                highlight = "CocError",
            },
            Warn = {
                text = {"-", "󰜁"}, -- = 
                priority = 2,
                color = colors.yellow,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextWarn",
                highlight = "CocWarn",
            },
            Info = {
                text = {"-", "󰜁"}, -- = 
                priority = 3,
                color = colors.green,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextInfo",
                highlight = "CocInfo",
            },
            Hint = {
                text = {"-", "󰜁"}, -- = 
                priority = 4,
                color = colors.blue,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextHint",
                highlight = "CocHint",
            },
            Misc = {
                text = {"-", "="},
                priority = 5,
                color = colors.magenta,
                cterm = nil,
                highlight = "Normal",
            },
            GitAdd = {
                text = "┆",
                priority = 7,
                color = nil,
                cterm = nil,
                highlight = "GitSignsAdd",
            },
            GitChange = {
                text = "┆",
                priority = 7,
                color = nil,
                cterm = nil,
                highlight = "GitSignsChange",
            },
            GitDelete = {
                text = "▁",
                priority = 7,
                color = nil,
                cterm = nil,
                highlight = "GitSignsDelete",
            },
        },
        excluded_buftypes = {"terminal"},
        excluded_filetypes = bl,
        autocmd = {
            render = {
                "BufWinEnter",
                "TabEnter",
                "TermEnter",
                "WinEnter",
                "CmdwinLeave",
                "TextChanged",
                "VimResized",
                "WinScrolled",
            },
            clear = {
                "BufWinLeave",
                "TabLeave",
                "TermLeave",
                "WinLeave",
            },
        },
        handlers = {
            cursor = true,
            diagnostic = true,
            gitsigns = true,
            handle = true,
            search = true,
        },
    })
end

local function init()
    M.setup()

    -- require("scrollbar.handlers").register("marks", function(bufnr)
    --     local jump = api.nvim_buf_get_mark(0, "'")
    --     local change = api.nvim_buf_get_mark(0, ".")
    --     local exit = api.nvim_buf_get_mark(0, '"')
    --     return {
    --         { line = jump[1], type = "Misc", text = icons.ui.bookmark, level = 3 },
    --         { line = change[1], type = "Misc", text = icons.ui.chevron.double.left, level = 3 },
    --         { line = exit[1], type = "Misc", text = '"', level = 3 }
    --     }
    -- end)
end

init()

return M
