local M = {}

local D = require("dev")
local wk = D.npcall(require, "which-key")
if not wk then
    return
end

local style = require("style")
local utils = require("common.utils")
local map = utils.map

function M.setup()
    local presets = require("which-key.plugins.presets")
    presets.operators["!"] = nil
    -- presets.operators["<lt>"] = nil
    -- presets.operators["<gt>"] = nil
    -- presets.operators["gc"] = "Commenter (line)"
    -- presets.operators["gb"] = "Commenter (block)"
    presets.operators["d"] = "Delete (blackhole)"
    presets.operators["gq"] = "Formatter"
    presets.operators["ga"] = "EasyAlign"
    presets.operators["ys"] = "Surround"
    presets.operators["y"] = "Yank"
    presets.operators["sx"] = "Exchange"
    presets.operators["s"] = "Substitue"

    ---@class WKRegisterOpts
    ---@field mode string Default "n"
    ---@field prefix string: Use "<Leader>f" example. Prepended to every mapping
    ---@field buffer number Buffer local mappings
    ---@field silent boolean Use `silent` when creating keymaps
    ---@field noremap boolean Use `noremap` when creating keymaps
    ---@field nowait boolean Use `nowait` when creating keymaps

    -- ---@param mappings table<string, string|string[]>
    -- ---@param opts? WKRegisterOpts
    -- local function register(mappings, opts)
    --     wk.register(mappings, opts)
    -- end
    --
    -- wk.register = register

    -- This still allows to check variables, etc.
    -- local show = wk.show
    -- wk.show = function(keys, opts)
    --     ---@diagnostic disable-next-line: undefined-field
    --     if vim.bo.ft == "TelescopePrompt" or vim.bo.ft == "toggleterm" or vim.b.visual_multi then
    --         return
    --     end
    --     show(keys, opts)
    -- end

    wk.setup {
        plugins = {
            marks = true, -- shows a list of your marks on ' and `
            registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            spelling = {
                enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                suggestions = 20 -- how many suggestions should be shown in the list?
            },
            presets = {
                operators = true, -- adds help for operators like d, y, ... and registers them for motion
                motions = true, -- adds help for motions
                text_objects = true, -- help for text objects triggered after entering an operator
                windows = true, -- default bindings on <c-w>
                nav = true, -- misc bindings to work with windows
                z = true, -- bindings for folds, spelling and others prefixed with z
                g = true -- bindings for prefixed with g
            }
        },
        -- NOTE: Only gq/s works here
        operators = {
            gc = "Comments",
            s = "Substitute",
            y = "Yank"
            -- sx = "Exchange",
        },
        key_labels = {
            -- override the label used to display some keys. It doesn't effect WK in any other way.
            -- ["<space>"] = "SPC",
            -- ["<Space>"] = "SPC",
            -- ["<tab>"] = "TAB",
            -- ["<cr>"] = "RET",
            -- ["<CR>"] = "RET",
            -- ["<Cr>"] = "RET",
            -- ["<Tab>"] = "TAB",
            -- ["<Cmd>"] = ":",
            -- ["<CMD>"] = ":",
            ["<c-w>"] = "<C-w>",
            ["<leader>"] = "<Leader>",
            ["<localleader>"] = "<LocalLeader>",
            ["<C-Bslash>"] = [[<C-\>]],
            ["<M-Bslash>"] = [[<M-\>]],
            ["<A-Bslash>"] = [[<M-\>]],
            ["<Backspace>"] = "<BS>",
            ["<BACKSPACE>"] = "<BS>",
            ["<2-LeftMouse>"] = "<2-LMouse>",
            ["<PageUp>"] = "<PgUp>",
            ["<PageDown>"] = "<PgDown>",
        },
        motions = {
            count = true
        },
        icons = {
            breadcrumb = "»", -- symbol used in the command line area that shows active key combo
            separator = "", -- 輪淪‣ symbol used between a key and it's label
            group = "󰫢" -- 󰫢 symbol prepended to a group
        },
        popup_mappings = {
            scroll_down = "<C-d>", -- binding to scroll down inside the popup
            scroll_up = "<C-u>" -- binding to scroll up inside the popup
        },
        window = {
            border = style.current.border, -- none, single, double, shadow
            position = "bottom", -- bottom, top
            margin = {1, 0, 1, 0}, -- extra window margin [top, right, bottom, left]
            padding = {2, 2, 2, 2}, -- extra window padding [top, right, bottom, left]
            winblend = 10
        },
        layout = {
            height = {min = 4, max = 25}, -- min and max height of the columns
            width = {min = 20, max = 50}, -- min and max width of the columns
            spacing = 3, -- spacing between columns
            align = "left" -- align columns left, center or right
        },
        ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
        -- hide mapping boilerplate
        -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
        -- hidden = {"lua", "^ ", "<silent>", "<cmd> ", "<Cmd> ", "<cmd>", "<Cmd>", "<CR>"},
        hidden = {"lua", "^ ", "<silent>", "<cmd> ", "<Cmd> ", "<cmd>", "<Cmd>", ": ", "<CR>"},
        show_help = true, -- show help message on the command line when the popup is visible
        show_keys = true, -- show the currently pressed key and its label as a message in the command line
        triggers = "auto",
        triggers_nowait = {
            -- marks
            "`",
            "'",
            "g`",
            "g'",
            -- registers
            '"',
            "<c-r>",
            -- spelling
            "z="
        }, -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
        triggers_blacklist = {
            i = {"j", "k"},
            v = {"j", "k"},
            c = {},
            n = {} -- "s"
            -- o = {"d", '"_d'}
        },
        -- disable the WhichKey popup for certain buf types and file types.
        -- Disabled by deafult for Telescope
        disable = {
            buftypes = {"terminal"},
            filetypes = {"TelescopePrompt", "Telescope", "toggleterm", "floaterm"}
        }
    }
end

---
---@param mode string
local function wk_help(mode)
    -- wk.show_command("", utils.mode())
    wk.show_command("", mode)
end

local function init()
    M.setup()

    -- map("n", "d", [[:lua require("which-key").show('"_d', {mode = "n", auto = true})<CR>]])
    map("n", "d", '"_d', {desc = "Delete blackhole"})
    map("i", "<C-A-;>", "<Esc><Cmd>WhichKey '' i<CR>", {desc = "WhichKey insert mode"})
    map("x", "<Leader>wh", "<Esc><Cmd>WhichKey '' x<CR>", {desc = "WhichKey select mode"})
    map("x", "<CR>", "<Esc><Cmd>WhichKey '' x<CR>", {desc = "WhichKey select mode"})
    map("v", "<CR>", "<Esc><Cmd>WhichKey '' v<CR>", {desc = "WhichKey visual mode"})
    map("o", "?", "<Cmd>WhichKey '' o<CR>", {desc = "WhichKey operator"})

    -- The reason why some of these are here is because they don't always trigger (some never do)
    wk.register(
        {
            ["<Leader>wh"] = {"<Cmd>WhichKey '' n<CR>", "WhichKey normal mode"},
            ["<Leader><Leader><CR>"] = {[[<Cmd>WhichKey \ \ <CR>]], "WhichKey Leader Leader"},
            ["<Leader><CR>"] = {[[<Cmd>WhichKey \ <CR>]], "WhichKey Leader"},
            ["<LocalLeader><CR>"] = {"<Cmd>WhichKey <LocalLeader><CR>", "WhichKey LocalLeader"},
            [";<CR>"] = {"<Cmd>WhichKey ;<CR>", "WhichKey colon"},
            ["g<CR>"] = {"<Cmd>WhichKey g<CR>", "WhichKey g"},
            ["[<CR>"] = {"<Cmd>WhichKey [<CR>", "WhichKey ["},
            ["]<CR>"] = {"<Cmd>WhichKey ]<CR>", "WhichKey ]"},
            ["<C-x><CR>"] = {"<Cmd>WhichKey ]<CR>", "WhichKey <C-x>"},
            ["c<CR>"] = {[[<Cmd>WhichKey c<CR>]], "WhichKey c"},
            ["<C-w><CR>"] = {[[<Cmd>WhichKey <C-w><CR>]], "WhichKey <C-w>"},
            ["q<CR>"] = {[[<Cmd>WhichKey q<CR>]], "WhichKey q"},
            ["z<CR>"] = {[[<Cmd>WhichKey z<CR>]], "WhichKey z"},
            ["s<CR>"] = {[[<Cmd>WhichKey s<CR>]], "WhichKey s"},
            ["cr<CR>"] = {[[<Cmd>WhichKey cr<CR>]], "WhichKey cr"},
            ["gc<CR>"] = {[[<Cmd>WhichKey gc<CR>]], "WhichKey gc"},
            ["ga<CR>"] = {[[<Cmd>WhichKey ga<CR>]], "WhichKey ga"},
            ["'<CR>"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
            ["'<Space>"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
            ["'?"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"}
        }
    )

    -- Addition to builtin which-key
    wk.register(
        {
            ["gq"] = "Format operator (formatexpr, formatprg)",
            ["="] = "Format operator (equalprg, indentexpr)",
            ["zQ"] = "Equivalent to ':q!'",
            ["zG"] = "Add word to internal spell-list",
            ["zW"] = "Mark word as bad internal wordlist",
            ["zuw"] = "Remove from spellfile",
            ["zuW"] = "Remove from internal wordlist",
            ["zug"] = "Remove from spellfile",
            ["zuG"] = "Remove from internal wordlist",
            --
            ["[i"] = "1st line with keyword",
            ["]i"] = "1st line w/ keyword after curline",
            ["[I"] = "All lines with keyword",
            ["]I"] = "All lines w/ keyword after curline",
            ["[<C-i>"] = "Goto 1st line with keyword",
            ["]<C-i>"] = "Goto 1st line w/ keyword after curline",
            -- ["[d"] = "1st line with macro",
            -- ["]d"] = "1st line w/ macro after curline",
            ["[D"] = "All lines with macro",
            ["]D"] = "All lines w/ macro after curline",
            -- ["[<C-d>"] = "Goto 1st line with macro",
            -- ["]<C-d>"] = "Goto 1st line w/ macro after curline",
            ["[<C-s>"] = {[[<Cmd>lua utils.normal('n', '[<C-d>')<CR>]], "Goto 1st line with macro"},
            ["]<C-s>"] = {
                [[<Cmd>lua utils.normal('n', ']<C-d>')<CR>]],
                "Goto 1st line w/ macro after curline"
            }
        }
    )

    wk.register(
        {
            ["="] = "Format operator (equalprg, indentexpr)"
        },
        {mode = "v"}
    )

    wk.register(
        {
            ["<C-w>"] = {
                name = "+window",
                r = "Rotate window down/right",
                ["<C-r>"] = "Rotate window down/right",
                R = "Rotate window up/left",
                K = "Move current window to top",
                J = "Move current window to bottom",
                H = "Move current window to left",
                L = "Move current window to right",
                ["<C-x>"] = "Swap current with next",
                --
                -- ["z<Num>"] = "Set window height",
                --
                n = "Create new blank (horiz) window",
                ["<C-n>"] = {
                    "<Cmd>lua utils.normal('m', '<C-w>n<C-w>V')<CR>",
                    "Create new blank (vert) window"
                },
                ["^"] = "Split window, edit alt file",
                ["<C-^>"] = "Split window, edit alt file",
                --
                c = "Close current window",
                o = "Close all windows except current",
                z = "Close preview window",
                --
                ["<Down>"] = "Goto window below",
                -- ["<C-j>"] = "Goto window below",
                j = "Goto window below",
                ["<Up>"] = "Goto window above",
                -- ["<C-k>"] = "Goto window above",
                k = "Goto window above",
                ["<Left>"] = "Goto window to left",
                -- ["<C-h>"] = "Goto window to left",
                h = "Goto window to left",
                ["<Right>"] = "Goto window to right",
                -- ["<C-l>"] = "Goto window to right",
                l = "Goto window to right",
                w = "Goto below/right window",
                W = "Goto above/left window",
                t = "Goto top-left window",
                -- ["<C-t>"] = "Goto top-left window",
                b = "Goto bottom-right window",
                ["<C-b>"] = "Goto bottom-right window",
                p = "Goto previous window",
                -- [","] = {"<C-w>p", "Goto previous window"},
                -- ["<C-p>"] = "Goto previous window",
                P = "Goto preview window",
                --
                f = "Split window, edit file under cursor",
                ["<C-f>"] = "Split: edit file under cursor",
                ["<C-F>"] = "Split: edit file under cursor, jump line",
                ["gf"] = "Tab: edit file under cursor",
                ["gF"] = "Tab: edit file under cursor, jump line",
                ["gt"] = "Goto next tab",
                ["gT"] = "Goto prev tab",
                --
                i = "Split: first line with keyword",
                ["<C-i>"] = "Split: first line with keyword",
                ["}"] = "Preview: ':ptag' under cursor",
                ["g}"] = "Preview: ':ptjump' under cursor",
                ["<lt>"] = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
                [">"] = {"<C-w>t<C-w>H", "Change horizontal to vertical"}
            }
        }
    )

    wk.register(
        {
            ["<C-w>"] = {
                name = "+window",
                ["]"] = "Split window, goto tag",
                ["<C-]>"] = "Split window, goto tag",
                ["g]"] = "Split window, ':tselect'",
                ["g<C-]>"] = "Split window, ':tjump'"
            }
        },
        {mode = {"n", "x"}}
    )

    -- <F-3> to show which-key help in any relevant mode
    local _modes = {"n", "i", "t", "v", "x", "s", "o"}
    for m = 1, #_modes do
        wk.register(
            {["<F3>"] = {wk_help, "Show which-key help menu", noremap = true}},
            {mode = _modes[m]}
        )
    end
end

init()

return M
