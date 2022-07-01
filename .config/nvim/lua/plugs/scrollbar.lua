local M = {}

local D = require("dev")
local scrollbar = D.npcall(require, "scrollbar")
if not scrollbar then
    return
end

function M.setup()
    local colors = require("kimbox.colors")

    scrollbar.setup(
        {
            show = true,
            set_highlights = true,
            folds = 1000, -- handle folds, set to number to disable folds if no. of lines in buffer exceeds this
            maxlines = false,
            handle = {
                text = " ",
                color = "#7E602C",
                cterm = nil,
                highlight = "CursorColumn",
                hide_if_all_visible = true -- Hides handle if all lines are visible
            },
            marks = {
                Search = {
                    text = {"-", "="},
                    priority = 0,
                    color = colors.blue,
                    cterm = nil,
                    highlight = "Search"
                },
                Error = {
                    text = {"-", "="},
                    priority = 1,
                    color = colors.red,
                    cterm = nil,
                    highlight = "DiagnosticVirtualTextError"
                },
                Warn = {
                    text = {"-", "="},
                    priority = 2,
                    color = colors.yellow,
                    cterm = nil,
                    highlight = "DiagnosticVirtualTextWarn"
                },
                Info = {
                    text = {"-", "="},
                    priority = 3,
                    color = colors.green,
                    cterm = nil,
                    highlight = "DiagnosticVirtualTextInfo"
                },
                Hint = {
                    text = {"-", "="},
                    priority = 4,
                    color = nil,
                    cterm = nil,
                    highlight = "DiagnosticVirtualTextHint"
                },
                Misc = {
                    text = {"-", "="},
                    priority = 5,
                    color = colors.magenta,
                    cterm = nil,
                    highlight = "Normal"
                }
            },
            excluded_buftypes = {"terminal"},
            excluded_filetypes = BLACKLIST_FT,
            autocmd = {
                render = {
                    -- "BufEnter",
                    "BufWinEnter",
                    "TabEnter",
                    "TermEnter",
                    "WinEnter",
                    "CmdwinLeave",
                    "TextChanged",
                    "VimResized",
                    "WinScrolled"
                }
            },
            handlers = {
                diagnostic = false, -- FIX: once coc is supported
                search = false
            }
        }
    )
end

local function init()
    M.setup()

    -- api.nvim_create_autocmd(
    --     "VimEnter", {
    --       callback = function() require("scrollbar").show() end,
    --       pattern = "*",
    --       group = create_augroup("Scrollbar"),
    --     }
    -- )
end

init()

return M
