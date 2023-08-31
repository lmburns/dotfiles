---@module 'plugs.which-key'
local M = {}

local F = Rc.F
local wk = F.npcall(require, "which-key")
if not wk then
    return
end

local utils = Rc.shared.utils
local map = Rc.api.map
local I = Rc.icons

local wkk

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

    wk.setup({
        plugins = {
            marks = true,         -- shows a list of your marks on ' and `
            registers = false,    -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            spelling = {
                enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                suggestions = 20, -- how many suggestions should be shown in the list?
            },
            presets = {
                operators = true,    -- adds help for operators like d, y, ... and registers them for motion
                motions = true,      -- adds help for motions
                text_objects = true, -- help for text objects triggered after entering an operator
                windows = false,     -- default bindings on <c-w>
                nav = true,          -- misc bindings to work with windows
                z = true,            -- bindings for folds, spelling and others prefixed with z
                g = true,            -- bindings for prefixed with g
            },
        },
        -- NOTE: Only gq/s works here
        operators = {
            gc = "Comments",
            s = "Substitute",
            y = "Yank",
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
            ["<space>"] = "<Space>",
            ["<cmd>"] = "<Cmd>",
            ["<cr>"] = "<CR>",
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
            count = true,
        },
        icons = {
            breadcrumb = I.chevron.double.right, -- symbol used in the command line area that shows active key combo
            separator = I.chevron.right,         -- symbol used between a key and it's label
            group = I.shape.star_sm,             -- symbol prepended to a group
        },
        popup_mappings = {
            scroll_down = "<C-d>", -- binding to scroll down inside the popup
            scroll_up = "<C-u>",   -- binding to scroll up inside the popup
        },
        window = {
            border = Rc.style.border, -- none, single, double, shadow
            position = "bottom",      -- bottom, top
            margin = {1, 0, 1, 0},    -- extra window margin [top, right, bottom, left]
            padding = {2, 2, 2, 2},   -- extra window padding [top, right, bottom, left]
            winblend = 10,
        },
        layout = {
            height = {min = 4, max = 25}, -- min and max height of the columns
            width = {min = 20, max = 50}, -- min and max width of the columns
            spacing = 3,                  -- spacing between columns
            align = "left",               -- align columns left, center or right
        },
        ignore_missing = false,           -- enable this to hide mappings for which you didn't specify a label
        -- hide mapping boilerplate
        hidden = {
            "^:call",
            "^:lua",
            "<cmd>call",
            "<cmd>lua",
            "<Cmd>call",
            "<Cmd>lua",
            "^ ",
            "^: ",
            -- ": ",
            "<silent>",
            "<MouseMove>",
            "<cmd> ",
            "<Cmd> ",
            "<cmd>",
            "<Cmd>",
            "<CR>",
        },
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
            "z=",
            "q",
            "gc",
        }, -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
        triggers_blacklist = {
            i = {"j", "k"},
            v = {"j", "k"},
            c = {},
            n = {}, -- "s"
            -- o = {"d", '"_d'}
        },
        -- disable the WhichKey popup for certain buf types and file types.
        -- Disabled by deafult for Telescope
        disable = {
            buftypes = {"terminal"},
            filetypes = {"TelescopePrompt", "Telescope", "toggleterm", "floaterm"},
        },
    })
end

local function wk_dump()
    wkk.dump()
end

---
---@param mode string
local function wk_help(mode)
    wk.show_command("", mode or utils.mode())
end

---Register keys dealing with the UnconditionalPaste plugin
function M.register_paste()
    wk.register({
        -- ["zy"] = "Yank text w/o trailing whitespace",
        -- ["zP"] = "Paste before cursor w/o trailing whitespace",
        ["zp"] = "Paste after cursor w/o trailing whitespace",
        ["]p"] = "Paste after and adjust indent",
        ["[p"] = "Paste before and adjust indent",
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ["gcp"] = "Paste: charwise after",
        ["gcP"] = "Paste: charwise before",
        ["glp"] = "Paste: linewise after",
        ["glP"] = "Paste: linewise before",
        ["gbp"] = "Paste: blockwise after",
        ["gbP"] = "Paste: blockwise before",
        ["g2p"] = "Paste: linewise + comment",
        ["g2P"] = "Paste: linewise + comment",
        ["g#p"] = "Paste: linewise + comment",
        ["g#P"] = "Paste: linewise + comment",
        ["ghp"] = "Paste: linewise + indent", -- like ]p
        ["ghP"] = "Paste: linewise + indent", -- like [p
        -- ["g]]p"] = "Paste: linewise + indent",
        -- ["g]]P"] = "Paste: linewise + indent",
        ["g>p"] = "Paste: linewise + shift",
        ["g>P"] = "Paste: linewise + shift",
        -- ["gsp"] = "Paste: linewise + space",
        -- ["gsP"] = "Paste: linewise + space",
        ["gqp"] = "Paste: charwise + query delim",
        ["gqP"] = "Paste: charwise + query delim",
        ["gQp"] = "Paste: repeat gqp",
        ["gQP"] = "Paste: repeat gqP",
        ["gqbp"] = "Paste: charwise + delim jagged",
        ["gqbP"] = "Paste: charwise + delim jagged",
        ["gQbp"] = "Paste: repeat gqbp",
        ["gQbP"] = "Paste: repeat gqbP",
        ["gq,p"] = "Paste: comma + single quote",
        ["gq,P"] = "Paste: comma + single quote",
        ["gq.p"] = "Paste: comma + double quote",
        ["gq.P"] = "Paste: comma + double quote",
        ["gup"] = "Paste: un-joined delim",
        ["guP"] = "Paste: un-joined delim",
        ["gUp"] = "Paste: repeat gup",
        ["gUP"] = "Paste: repeat guP",
        ["gqlp"] = "Paste: more indent",
        ["gqlP"] = "Paste: more indent",
        ["gqhp"] = "Paste: less indent",
        ["gqhP"] = "Paste: less indent",
        ["gBp"] = "Paste: blockwise + jagged",
        ["gBP"] = "Paste: blockwise + jagged",
    }, {mode = "n"})

    wk.register({
        ["<C-,><C-,>"] = {"<Plug>UnconditionalPasteChar", "Paste: charwise"},
        ["<C-,><C-q>"] = {"<Plug>UnconditionalPasteQueried", "Paste: queried delim"},
        ["<C-,><C-q><C-q>"] = {"<Plug>UnconditionalPasteRecallQueried", "Paste: recall queried delim"},
        ["<C-,>,"] = {"<Plug>UnconditionalPasteComma", "Paste: comma"},
    }, {mode = "i"})
end

---Addition to builtin which-key
function M.register_builtin()
    wk.register({
        ["gq"] = "Format operator (formatexpr, formatprg)",
        ["="] = "Format operator (equalprg, indentexpr)",
        -- ["ZZ"] = "Write file and close (equiv ':x')",
        -- ["ZQ"] = "Equivalent to ':q!'",
        --
        -- Spelling
        ["zG"] = "Add word to internal spell-list",
        ["zW"] = "Mark word as bad internal wordlist",
        ["zuw"] = "Remove from spellfile",
        ["zuW"] = "Remove from internal wordlist",
        ["zug"] = "Remove from spellfile",
        ["zuG"] = "Remove from internal wordlist",
        --
        -- Scrolling
        ["z+"] = "Redraw with line at top",
        ["z^"] = "Redraw with line at bottom",
        -- ["z<CR>"] = "Redraw line at top",
        ["z-"] = "Redraw line at bottom",
        -- ["z."] = "Redraw line at center",
        -- ["zL"] = "Scroll half-screen right (wrap=off)",
        ["z<Right>"] = "Scroll [count] chars right (wrap=off)",
        -- ["zh"] = "Scroll [count] chars left (wrap=off)",
        ["z<Left>"] = "Scroll [count] chars left (wrap=off)",
        -- ["zH"] = "Scroll half-screen right (wrap=off)",
        -- ["zl"] = "Scroll [count] chars right (wrap=off)",
        --
        -- Cursor movement
        ["gm"] = "Half screenwidth to right (screen-line)",
        ["gM"] = "Half screen-line to right (count=% of line)",
        ["g^"] = "First non-blank char of screen-line",
        ["g_"] = "Last non-blank char",
        ["g0"] = "First char of screen-line",
        ["g<Home>"] = "First char of screen-line",
        ["g$"] = "Last char of screen-line",
        ["g<End>"] = "Last char of screen-line",
        ["|"] = "Screen column (count)",
        --
        ["g8"] = "Get hex bytes of char",
        ["8g8"] = "Find illegal UTF-8 byte",
        ["g<"] = "Redisplay last pager message",
        --
        ["do"] = "diffget; remove diffs in curbuf",
        ["dp"] = "diffput; remove diffs in another",
    }, {mode = "n"})
end

---Register window group mappings
function M.register_window()
    wk.register({
        ["<C-w>"] = {
            name = "window",
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
                "Create new blank (vert) window",
            },
            ["^"] = "Split window, edit alt file",
            ["<C-^>"] = "Split window, edit alt file",
            --
            c = "Close current window",
            o = "Close all windows except current",
            z = "Close preview window",
            --
            ["<Down>"] = "Goto window below",
            ["<Up>"] = "Goto window above",
            ["<Left>"] = "Goto window to left",
            ["<Right>"] = "Goto window to right",
            j = "Goto window below",
            k = "Goto window above",
            h = "Goto window to left",
            l = "Goto window to right",
            -- ["<C-j>"] = "Goto window below",
            -- ["<C-k>"] = "Goto window above",
            -- ["<C-h>"] = "Goto window to left",
            -- ["<C-l>"] = "Goto window to right",
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
            --
            i = "Split: first line with keyword",
            ["<C-i>"] = "Split: first line with keyword",
            ["}"] = "Preview: ':ptag' under cursor",
            ["g}"] = "Preview: ':ptjump' under cursor",
            ["<lt>"] = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
            [">"] = {"<C-w>t<C-w>H", "Change horizontal to vertical"},
            -- WhichKey builtin
            s = "Split window",
            v = "Split window vertically",
            q = "Quit a window",
            ["<C-t>"] = {"<C-w>T", "Break out into a new tab"},
            x = "Swap current with next",
            ["-"] = "Decrease height",
            ["+"] = "Increase height",
            ["|"] = "Max out the width",
            ["_"] = "Max out the height",
            ["="] = "Equally high and wide",
            --
            ["<Tab>"] = "Tab: go to last used",
            ["g<Tab>"] = "Tab: go to last used",
            ["gf"] = "Tab: edit file under cursor",
            ["gF"] = "Tab: edit file under cursor, jump line",
            ["gt"] = "Goto next tab",
            ["gT"] = "Goto prev tab",
        },
    }, {mode = "n"})

    wk.register({
        ["<C-w>"] = {
            name = "window",
            ["]"] = "Split: window, goto tag",
            ["<C-]>"] = "Split window, goto tag",
            ["g]"] = "Split window, ':tselect'",
            ["g<C-]>"] = "Split window, ':tjump'",
        },
    }, {mode = {"n", "x"}})
end

---Register keybindings that move the cursor
function M.register_movement()
    wk.register({
        -- ["]`"] = "Next lower mark",
        -- ["[`"] = "Prev lower mark",
        ["]'"] = "Next lower mark; first col",
        ["['"] = "Prev lower mark; first col",
        ["]*"] = "Next '*/' comment",
        ["[*"] = "Prev '/*' comment",
        ["]#"] = "Next #else/#endif",
        ["[#"] = "Prev #if/#else",
        -- ["[m"] = "Prev start Java method ({)",
        -- ["[M"] = "Prev end Java method (})",
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- ["]i"], "Show next line with keyword",               -- isearch
        -- ["[i"], "Show first line with keyword",       -- isearch
        -- ["]I"] = [[Disp all lines w/ keyword after cursor]], -- ilist
        -- ["[I"] = [[Disp all lines w/ keyword]],       -- ilist
        -- ["]<C-i>"], "Jump [cnt] keyword, start cursor",      -- ijump
        -- ["[<C-i>"], "Jump [cnt] keyword, start file", -- ijump
        -- ["]d"] = "1st line w/ macro after curline",          -- dsearch
        -- ["[d"] = "1st line with macro",               -- dsearch
        ["]D"] = "Show all lines w/ macro > curline",     -- dlist
        ["[D"] = "Show all lines with macro",     -- dlist
        -- ["]<C-d>"] = "Goto 1st line w/ macro after curline", -- djump
        -- ["[<C-d>"] = "Goto 1st line with macro",      -- djump
        ["]<C-s>"] = {"]<C-d>", "Goto 1st line w/ macro after curline"},
        ["[<C-s>"] = {"[<C-d>", "Goto 1st line with macro"},
        -- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ["]<C-i>"] = {"]i", "Show next line with keyword"},
        ["[<C-i>"] = {"[i", "Show first line with keyword"},
        ["]i"] = {"]<C-i>", "Jump [cnt] keyword, start cursor"},
        ["[i"] = {"[<C-i>", "Jump [cnt] keyword, start file"},
        ["]I"] = [[Query tag after \<word\>]],
        ["[I"] = [[Query tag before \<word\>]],
        ["]<Tab>"] = [[Jump tag after \<word\>]],
        ["[<Tab>"] = [[Jump tag before \<word\>]],
        -- ["]N"] = [[Query tag w/ last search pat]],
        -- ["[N"] = [[Query tag w/ last search pat]],
        ["]<C-n>"] = [[Jump tag w/ last search pat]],
        ["[<C-n>"] = [[Jump tag w/ last search pat]],
        ["]/"] = [[Search next tag]],
        ["[/"] = [[Search prev tag]],
        ["]?"] = [[Search next tag]],
        ["[?"] = [[Search prev tag]],
        ["]N"] = [[Next tag (all)]],
        ["[N"] = [[Prev tag (all)]],
    }, {mode = "n"})

    wk.register({
        ["<C-t>"] = "Tag: pop",
        -- ["g]"] = "Tag: tselect",
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        -- ["g]I"] = "Query tag after word",
        -- ["g[I"] = "Query tag before word",
        ["g[<Tab>"] = [[Jump tag before word]],
        ["g]<Tab>"] = [[Jump tag after word]],
        ["<C-w>/"] = [[Search tag and split]],
        ["<C-w>?"] = [[Search tag and split]],
    }, {mode = "n"})

    -- gettagstack([{winnr}])
    -- settagstack({nr},
    -- tagfiles()
    -- taglist()

    -- " juggling with tags
    -- nnoremap ,j :tjump /
    -- nnoremap ,p :ptjump /

    -- " juggling with definitions
    -- nnoremap ,d :dlist /
    -- nnoremap [D [D:djump<Space><Space><Space><C-r><C-w><S-Left><Left>
    -- nnoremap ]D ]D:djump<Space><Space><Space><C-r><C-w><S-Left><Left>

    -- " juggling with matches
    -- nnoremap ,i :ilist /
    -- nnoremap [I [I:ijump<Space><Space><Space><C-r><C-w><S-Left><Left><Left>
    -- nnoremap ]I ]I:ijump<Space><Space><Space><C-r><C-w><S-Left><Left><Left>

    wk.register({
        ["[i"] = "First line with keyword",
        ["]i"] = "Next line with keyword",
        ["[I"] = [[Query tag before \<word\>]],
        ["]I"] = [[Query tag after \<word\>]],
        ["[<Tab>"] = [[Jump tag before \<word\>]],
        ["]<Tab>"] = [[Jump tag after \<word\>]],
    }, {mode = "v"})
end

---Specify keys to ignore in popups
function M.register_ignore()
    wk.register({
        ["<MouseMove>"] = "which_key_ignore",
        ["'"] = "which_key_ignore",
        ["`"] = "which_key_ignore",
    }, {mode = {"n", "x", "o", "s", "v", "i"}})
end

local function register_more()
    M.register_ignore()
    M.register_builtin()
    M.register_window()
    M.register_movement()
    M.register_paste()

    wk.register({
        ["="] = "Format operator (equalprg, indentexpr)",
        ["zy"] = "Yank, ignore trailing whitespace",
    }, {mode = "x"})
end

local function init()
    wkk = require("which-key.keys")

    M.setup()

    -- map("n", "d", [[:lua require("which-key").show('"_d', {mode = "n", auto = true})<CR>]])
    -- map("i", "<C-A-;>", "<Esc><Cmd>WhichKey '' i<CR>", {desc = "WhichKey insert mode"})
    map("x", "<Leader>wh", "<Esc><Cmd>WhichKey '' x<CR>", {desc = "WhichKey select mode"})
    map("x", "<CR>", "<Esc><Cmd>WhichKey '' x<CR>", {desc = "WhichKey select mode"})
    map("v", "<CR>", "<Esc><Cmd>WhichKey '' v<CR>", {desc = "WhichKey visual mode"})
    map("o", "?", "<Cmd>WhichKey '' o<CR>", {desc = "WhichKey operator"})

    -- The reason why some of these are here is because they don't always trigger (some never do)
    wk.register({
        ["<Leader>wh"] = {"<Cmd>WhichKey '' n<CR>", "WhichKey normal mode"},
        ["<Leader><Leader><CR>"] = {[[<Cmd>WhichKey \ \ <CR>]], "WhichKey Leader Leader"},
        ["<Leader><CR>"] = {[[<Cmd>WhichKey \ <CR>]], "WhichKey Leader"},
        ["<LocalLeader><CR>"] = {"<Cmd>WhichKey <LocalLeader><CR>", "WhichKey LocalLeader"},
        [";<CR>"] = {"<Cmd>WhichKey ;<CR>", "WhichKey ;"},
        [";<Space>"] = {"<Cmd>WhichKey ;<CR>", "WhichKey ;"},
        ["g<CR>"] = {"<Cmd>WhichKey g<CR>", "WhichKey g"},
        ["[<CR>"] = {"<Cmd>WhichKey [<CR>", "WhichKey ["},
        ["]<CR>"] = {"<Cmd>WhichKey ]<CR>", "WhichKey ]"},
        ["<C-x><CR>"] = {"<Cmd>WhichKey ]<CR>", "WhichKey <C-x>"},
        ["c<CR>"] = {[[<Cmd>WhichKey c<CR>]], "WhichKey c"},
        ["<C-w><CR>"] = {[[<Cmd>WhichKey <C-w><CR>]], "WhichKey <C-w>"},
        -- ["z<Space>"] = {[[<Cmd>WhichKey z<CR>]], "WhichKey z"},
        ["z<CR>"] = {[[<Cmd>WhichKey z<CR>]], "WhichKey z"},
        ["s<CR>"] = {[[<Cmd>WhichKey s<CR>]], "WhichKey s"},
        ["s<Space>"] = {[[<Cmd>WhichKey s<CR>]], "WhichKey s"},
        ["q<CR>"] = {[[<Cmd>WhichKey q<CR>]], "WhichKey q"},
        ["q<Space>"] = {[[<Cmd>WhichKey q<CR>]], "WhichKey q"},
        ["cr<CR>"] = {[[<Cmd>WhichKey cr<CR>]], "WhichKey cr"},
        ["gc<CR>"] = {[[<Cmd>WhichKey gc<CR>]], "WhichKey gc"},
        ["ga<CR>"] = {[[<Cmd>WhichKey ga<CR>]], "WhichKey ga"},
        ["'<CR>"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
        ["'<Space>"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
        ["`<CR>"] = {[[<Cmd>WhichKey `<CR>]], "WhichKey `"},
        ["`<Space>"] = {[[<Cmd>WhichKey `<CR>]], "WhichKey `"},
        -- ["'?"] = {[[<Cmd>WhichKey '<CR>]], "WhichKey '"},
    })

    vim.defer_fn(function()
        register_more()
    end, 500)

    -- <F3> to show which-key help in any relevant mode
    local _modes = {"n", "i", "t", "v", "x", "s", "o"}
    for m = 1, #_modes do
        wk.register(
            {["<F3>"] = {F.ithunk(wk_help, _modes[m]), "Show which-key help menu"}},
            {mode = _modes[m]}
        )
    end
end

init()

return M
