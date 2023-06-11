---@module 'plugs.scrollbar'
local M = {}

local scrollbar = Rc.F.npcall(require, "scrollbar")
if not scrollbar then
    return
end

local I = Rc.icons

function M.setup()
    local colors = require("kimbox.colors")

    local keep = {"markdown", "vimwiki"}
    local bl = Rc.blacklist.ft:filter(function(f)
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
                text = I.shape.dot,
                priority = 0,
                color = colors.orange,
                cterm = nil,
                highlight = "Normal",
            },
            Search = {
                text = {"-", I.shape.star_sm}, -- =
                priority = 0,
                color = colors.blue,
                cterm = nil,
                highlight = "Search",
            },
            Error = {
                text = {"-", I.shape.pentagon}, -- = 
                priority = 1,
                color = colors.red,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextError",
                highlight = "CocError",
            },
            Warn = {
                text = {"-", I.shape.pentagon}, -- = 
                priority = 2,
                color = colors.yellow,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextWarn",
                highlight = "CocWarn",
            },
            Info = {
                text = {"-", I.shape.pentagon}, -- = 
                priority = 3,
                color = colors.green,
                cterm = nil,
                -- highlight = "DiagnosticVirtualTextInfo",
                highlight = "CocInfo",
            },
            Hint = {
                text = {"-", I.shape.pentagon}, -- = 
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
    --         { line = jump[1], type = "Misc", text = I.ui.bookmark, level = 3 },
    --         { line = change[1], type = "Misc", text = I.chevron.double.left, level = 3 },
    --         { line = exit[1], type = "Misc", text = '"', level = 3 }
    --     }
    -- end)
end

init()

return M
