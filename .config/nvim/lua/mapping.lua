local M = {}

local D = require("dev")
local _ = D.ithunk
local utils = require("common.utils")
local map = utils.map
local funcs = require("functions")

-- local ex = nvim.ex
-- local api = vim.api
-- local fn = vim.fn
-- local F = vim.F

-- Legendary needs to be called again in this file for the keybindings to register
-- Not sure why these options only work from here
require("legendary").setup({include_builtin = false, include_legendary_cmds = false})
local wk = require("which-key")

-- ============== General mappings ============== [[[
-- map("n", "<Space>", "<Nop>")
-- map("x", "<Space>", "<Nop>")

wk.register(
    {
        [";q"] = {[[:q<CR>]], "Quit"},
        [";w"] = {[[:update<CR>]], "Update file"}
    }
)

-- Map '-' to blackhole register
map("n", "-", '"_', {desc = "Black hole register"})
map("x", "-", '"_', {desc = "Black hole register"})
map("n", "<BS>", "<C-^>", {desc = "Alternate file"})

-- ╓                                                          ╖
-- ║                          Macro                           ║
-- ╙                                                          ╜
-- Use qq to record, q to stop, Q to play a macro
map("n", "Q", "@q", {desc = "Play 'q' macro"})

-- Repeat last command
map({"n", "x"}, "<F2>", "@:", {desc = "Repeat last command"})

map(
    "x",
    "@",
    ":<C-u>lua require('functions').execute_macro_over_visual_range()<CR>",
    {silent = false, desc = "Execute macro visually"}
)

map("x", ".", ":norm .<CR>", {desc = "Perform dot commands over visual blocks"})

-- Use qq to record and stop (only records q)
map("n", "qq", D.ithunk(funcs.record_macro, "q"), {expr = true, desc = "Record macro"})
map("n", "qj", D.ithunk(funcs.record_macro, "j"), {expr = true, desc = "Record macro"})
map("n", "qk", D.ithunk(funcs.record_macro, "k"), {expr = true, desc = "Record macro"})
map("n", "q:", "<Nop>")
map("n", "q/", "<Nop>")
map("n", "q?", "<Nop>")
map("n", "q", "<Nop>", {silent = true})

-- map("v", "J", ":m '>+1<CR>gv=gv")
-- map("v", "K", ":m '<-2<CR>gv=gv")
-- map("n", "<C-,>", "<Cmd>m +1<CR>")
-- map("n", "<C-.>", "<Cmd>m -2<CR>")

map("i", '<M-S-">', "<Home>", {desc = "Goto begin of lne"})
map("i", "<M-'>", "<End>", {desc = "Goto end of line"})
map("i", "<M-b>", "<C-Left>", {desc = "Go word back"})
map("i", "<M-f>", "<C-Right>", {desc = "Go word forward"})
map("i", "<C-S-h>", "<C-Left>", {desc = "Go word back"})
map("i", "<C-S-l>", "<C-Right>", {desc = "Go word forward"})
map("i", "<C-S-m>", "<Left>", {desc = "Go one char left"})
map("i", "<C-S-n>", "<Right>", {desc = "Go one char right"})
map("i", "<C-S-k>", "<C-o>gk", {desc = "Go one line up"})
map("i", "<C-S-j>", "<C-o>gj", {desc = "Go one line down"})
map("i", "<Down>", "<C-o>gj", {desc = "Goto next screen-line"})
map("i", "<Up>", "<C-o>gk", {desc = "Goto prev screen-line"})

map("i", "<M-/>", "<C-a>", {desc = "Insert last inserted text"})
map("i", "<C-S-p>", "<C-o>p", {desc = "Paste"})
map("i", "<C-M-p>", "<C-o>ghp", {desc = "Paste formatted", noremap = false})
map("i", "<C-M-,>", "<C-o>ghp", {desc = "Paste formatted", noremap = false})
map("i", "<M-p>", "<C-o>g2p", {desc = "Paste commented", noremap = false})
map("i", "<C-M-.>", "<C-o>g2p", {desc = "Paste commented", noremap = false})

-- map("i", "<C-M-n>", "<C-n>", {desc = "Complete word (search forward)"})
-- map("i", "<C-M-p>", "<C-p>", {desc = "Complete word (search backward)"})
-- map("i", "<C-j>", "<C-o><Cmd>m +1<CR>")
-- map("i", "<C-k>", "<C-o><Cmd>m -2<CR>")
-- map("i", "<C-o>", "<C-o>", {desc = "Run command, resume insert mode"})
map("i", "<C-n>", "<C-o>:", {desc = "Command mode"})

-- Start new undo sequence
-- map("i", "<C-r>", "<C-g>u<C-r>", {desc = "Show registers"})
map("i", "<C-S-u>", "<C-g>u", {desc = "Start new undo sequence"})
map("i", "<C-/>", "<C-g>u", {desc = "Start new undo sequence"})
map("i", "<C-o>u", "<C-g>u<C-o>u", {desc = "Undo typed text"})
map("i", "<C-o>U", "<C-g>u<C-o><C-r>", {desc = "Redo"})
map("i", "<M-u>", "<C-g>u<C-o>u", {desc = "Undo typed text"})
map("i", "<M-S-u>", "<C-g>u<C-o><C-r>", {desc = "Redo"})
-- map("i", "<C-o>U", "<C-g>u<C-o><Cmd>redo<CR>", {desc = "Redo"})
-- map("i", "<C-Left>", [[<C-o>u]], {desc = "Undo"})
-- map("i", "<C-Right>", [[<C-o><Cmd>norm! ".p<CR>]], {desc = "Redo"})

map("i", ".", ".<C-g>u")
map("i", ",", ",<C-g>u")
map("i", "!", "!<C-g>u")
map("i", "?", "?<C-g>u")
map("i", "<CR>", "<CR><C-g>u")
map("i", "<M-BS>", "<C-g>u<C-w>", {desc = "Delete previous word"})
-- map("i", "<C-w>", "<C-g>u<C-w>", {desc = "Delete previous word"})
-- map("i", "<C-h>", "<C-g>u<C-h>", {desc = "Delete character to left"})
map("i", "<C-u>", "<C-g>u<C-u>", {desc = "Delete all typed in insert (before cursor)"})
map("i", "<C-l>", "<C-g>u<Del>", {desc = "Delete character to right"})
map("i", "<M-d>", "<C-g>u<C-o>de", {desc = "Delete to end of word"})
map("i", "<M-[>", "<C-g>u<C-o>dg^", {desc = "Left kill line"})
map("i", "<M-]>", "<C-g>u<C-o>dg$", {desc = "Right kill line"})
map("i", "<M-x>", "<C-g>u<C-o>cc", {desc = "Kill whole line"})
-- map("i", "<C-M-u>", "<C-g>u<C-o>ciL", {desc = "Kill whole line (except indent)", noremap = false})
-- map("i", "<M-,>", "<C-w>", {desc = "Delete previous word", noremap = false})

map("i", "<M-o>", "<C-g>u<C-o>o", {desc = "Equivalent: 'norm! o'"})
map("i", "<M-CR>", "<C-g>u<C-o>o", {desc = "Equivalent: 'norm! o'"})
map("i", "<M-i>", "<C-g>u<C-o>O", {desc = "Move current line down"})
map("i", "<M-S-o>", "<C-g>u<C-o>O", {desc = "Move current line down"})
map("i", "<C-M-i>", "<C-g>u<C-o>zk", {desc = "Insert line above", noremap = false})
map("i", "<C-M-o>", "<C-g>u<C-o>zj", {desc = "Insert line below", noremap = false})

wk.register(
    {
        ["<C-t>"] = "Insert one shift level at beginning of line",
        ["<C-d>"] = "Delete one shift level at beginning of line",
        ["<C-o>"] = "Run command, resume insert mode",
        ["<C-e>"] = "Insert char from line below",
        ["<C-y>"] = "Insert char from line above",
        ["<C-b>"] = "Move one char left",
        ["<C-f>"] = "Move one char right"
    },
    {mode = "i"}
)

-- imap <C-F> <C-R>=expand("%")<CR>
-- cnoremap <M-e>  <C-R>=expand("%:p:h") . "/" <CR>
-- cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
-- cnoremap <expr> * getcmdline() =~ '.*\*\*$' ? '/*' : '*' what

map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")
map("c", "<C-,>", "<Home>")
map("c", "<C-.>", "<End>")
map("c", "<C-S-k>", "<Home>")
map("c", "<C-S-j>", "<End>")
map("c", "<C-h>", "<BS>")
map("c", "<C-l>", "<Del>")
map("c", "<C-d>", "<Del>")
map("c", "<M-[>", "<Up>")
map("c", "<M-]>", "<Down>")
map("c", "<C-o>", [[<C-\>egetcmdline()[:getcmdpos() - 2]<CR>]], {desc = "Delete to end of line"})
map("c", "<M-b>", "<C-Left>", {desc = "Move one word left"})
map("c", "<M-f>", "<C-Right>", {desc = "Move one word right"})
map("c", "<C-S-h>", "<C-Left>", {desc = "Move one word left"})
map("c", "<C-S-l>", "<C-Right>", {desc = "Move one word right"})

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("x", "<Tab>", ">><Esc>gv", {silent = true})
map("x", "<S-Tab>", "<<<Esc>gv", {silent = true})
-- map("i", "<S-Tab>", "<C-d>") hello sir okj

-- Don't lose selection when shifting sidewards
-- map("x", "<", "<gv")
-- map("x", ">", ">gv")

map(
    "n",
    "<Leader>c;",
    D.ithunk(funcs.toggle_formatopts_r),
    {desc = "Toggle continuation of comment"}
)

map("n", "<Leader>a;", "<Cmd>:h pattern-overview<CR>", {desc = "Help: vim patterns"})
map("n", "<Leader>am", "<Cmd>:h index<CR>", {desc = "Help: mapping overview"})

map("n", "c*", ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn")
map("x", "C", '"cy:let @/=@c<CR>cgn', {desc = "Change text (dot repeatable)"})
map("n", "cc", [[getline('.') =~ '^\s*$' ? '"_cc' : 'cc']], {expr = true, noremap = true})

wk.register(
    {
        ["<Leader>sg"] = {":%s//g<Left><Left>", "Global replace"},
        ["dM"] = {[[:%s/<C-r>//g<CR>]], "Delete all search matches"},
        ["cm"] = {[[:%s/<C-r>///g<Left><Left>]], "Change all matches"}
        -- ["dM"] = {":%g/<C-r>//d<CR>", "Delete all lines with search matches"},
        -- ["z/"] = {[[/\%><C-r>=line("w0")-1<CR>l\%<<C-r>=line("w$")+1<CR>l]], "Search in visible screen"},
    },
    {silent = false}
)

map(
    "n",
    "z/",
    function()
        local scrolloff = vim.wo.scrolloff
        vim.wo.scrolloff = 0
        -- utils.normal("n", "VHoLo0<Esc>/\\%V")
        utils.normal("n", "m`HVL<Esc>/\\%V")

        vim.defer_fn(
            function()
                utils.normal("n", "``zz")
                vim.wo.scrolloff = scrolloff
            end,
            10
        )
    end,
    {desc = "Search in visible screen"}
)

map("n", "<Leader>rt", "<Cmd>setl et<CR>", {desc = "Set expandtab"})
map("n", "<Leader>re", "<Cmd>setl et<CR><Cmd>retab<CR>", {desc = "Retab whole file"})
map("x", "<Leader>re", "<Cmd>retab<CR>", {desc = "Retab selection"})
map("n", "<Leader>cd", "<Cmd>lcd %:p:h<CR><Cmd>pwd<CR>", {desc = "'lcd' to filename directory"})

-- Use g- and g+
wk.register(
    {
        -- ["U"] = {"<C-r>", "Redo action"},
        ["U"] = {"<Plug>(RepeatRedo)", "Redo action"},
        ["<C-S-u>"] = {"<Plug>(RepeatUndoLine)", "Undo entire line"},
        [";U"] = {"<Cmd>execute('later ' . v:count1 . 'f')<CR>", "Return to later state"},
        [";u"] = {"<Cmd>execute('earlier ' . v:count1 . 'f')<CR>", "Return to earlier state"},
        ["gI"] = {D.ithunk(utils.normal, "n", "`^"), "Goto last insert spot"},
        ["gA"] = {D.ithunk(utils.normal, "n", "ga"), "Get ASCII value"},
        ["<C-g>"] = {"2<C-g>", "Show buffer info"},
    }
)

-- Yank mappings
wk.register(
    {
        ["yd"] = {
            ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>",
            "Copy directory"
        },
        ["yn"] = {
            ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:t'))<CR>",
            "Copy file name"
        },
        ["yp"] = {
            ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p'))<CR>",
            "Copy full path"
        }
    }
)

wk.register(
    {
        ["y"] = {[[v:lua.require'common.yank'.wrap()]], "Yank motion"},
        ["yw"] = {[[v:lua.require'common.yank'.wrap('iw')]], "Yank word (iw)"},
        ["yW"] = {[[v:lua.require'common.yank'.wrap('iW')]], "Yank word (iW)"},
        ["gV"] = {[['`[' . strpart(getregtype(), 0, 1) . '`]']], "Reselect pasted text"}
    },
    {expr = true}
)

wk.register(
    {
        ["D"] = {[["_D]], "Delete to end of line (blackhole)"},
        ["S"] = {[[^"_D]], "Delete line (blackhole)"}, -- similar to norm! S/cc
        ["Y"] = {[[y$]], "Yank to EOL (without newline)"},
        ["x"] = {[["_x]], "Cut letter (blackhole)"},
        ["vv"] = {[[^vg_]], "Select entire line (without newline)"},
        ["<A-a>"] = {[[VggoG]], "Select entire file"},
        ["cn"] = {[[*``cgn]], "Change text, start search forward"},
        ["cN"] = {[[*``cgN]], "Change text, start search backward"},
        ["g."] = {[[/\V<C-r>"<CR>cgn<C-a><Esc>]], "Make last change as initiation for cgn"},
        ["&"] = "Repeat last substitution"
        -- ["J"] = {"mzJ`z", "Join lines, keep curpos"}
    }
)

wk.register(
    {
        ["d"] = {[["_d]], "Delete (blackhole)"},
        ["y"] = {[[ygv<Esc>]], "Place the cursor at end of yank"},
        ["<C-g>"] = {[[g<C-g>]], "Show word count"},
        ["<C-CR>"] = {[[g<C-g>]], "Show word count"},
        ["/"] = {"<Esc>/\\%V", "Search visual selection"},
        ["&"] = {":&&<CR>", "Repeat last substitution"}
        -- ["c"] = {[["_c]], "Change (blackhole)"},
        -- ["//"] = {[[y/<C-R>"<CR>]], "Search for visual selection"}
    },
    {mode = "x"}
)

-- map("n", "j", [[(v:count > 1 ? 'm`' . v:count : '') . 'j']], {noremap = true, expr = true})
-- map("n", "k", [[(v:count > 1 ? 'm`' . v:count : '') . 'k']], {noremap = true, expr = true})

-- map({"n", "x", "o"}, "H", "g0", {desc = "Start of screen-line"})
-- map({"n", "x", "o"}, "L", "g_", {desc = "End of line"})
map({"n", "x", "o"}, "H", "g^", {desc = "Start of line"})
map(
    "n",
    "L",
    [[<Cmd>norm! g$<CR><Cmd>exe (getline('.')[col('.') - 1] == ' ' ? 'norm! ge' : '')<CR>]],
    {desc = "End of line"}
)
map(
    "x",
    "L",
    [[<Cmd>norm! g$<CR><Cmd>exe (getline('.')[col('.') - 2] == ' ' ? 'norm! ge' : '')<CR>]],
    {desc = "End of line"}
)
map("o", "L", "g$", {desc = "End of screen-line"})
-- fn.nr2char(fn.strgetchar(fn.getline('.'):sub(fn.col('.')), 0))

map("n", "j", [[v:count ? (v:count > 1 ? "m`" . v:count : '') . 'j' : 'gj']], {expr = true})
map("n", "k", [[v:count ? (v:count > 1 ? "m`" . v:count : '') . 'k' : 'gk']], {expr = true})
map("x", "j", "<Cmd>norm! gj<CR>", {desc = "Next screen-line", silent = true})
map("x", "k", "<Cmd>norm! gk<CR>", {desc = "Prev screen-line", silent = true})
map({"n", "x"}, "gj", "<Cmd>norm! j<CR>", {desc = "Next line", silent = true})
map({"n", "x"}, "gk", "<Cmd>norm! k<CR>", {desc = "Prev line", silent = true})

map("n", "<Down>", "<Cmd>norm! }<CR>", {desc = "Next blank line", silent = true})
map("n", "<Up>", "<Cmd>norm! {<CR>", {desc = "Prev blank line", silent = true})

map(
    {"n", "x", "o"},
    "0",
    [[v:lua.require'common.builtin'.jump0()]],
    {expr = true, desc = "Toggle first (non-blank) char"}
)

wk.register(
    {
        ["gm"] = "Half screenwidth to right (screen-line)",
        ["gM"] = "Halfway screen-line (count = % of line)",
        ["g^"] = "First non-blank char of screen-line",
        ["g_"] = "Last non-blank char",
        ["g0"] = "First char of screen-line",
        ["g<Home>"] = "First char of screen-line",
        ["g$"] = "Last char of screen-line",
        ["g<End>"] = "Last char of screen-line",
        ["|"] = "Screen column (count)",
        -- Quickfix
        ["[q"] = {[[<Cmd>execute(v:count1 . 'cprev')<CR>]], "Previous item in quickfix"},
        ["]q"] = {[[<Cmd>execute(v:count1 . 'cnext')<CR>]], "Next item in quickfix"},
        ["[Q"] = {"<Cmd>cfirst<CR>", "First item in quickfix"},
        ["]Q"] = {"<Cmd>clast<CR>", "Last item in quickfix"},
        ["]e"] = {"<Cmd>cnewer<CR>", "Next quickfix list"},
        ["[e"] = {"<Cmd>colder<CR>", "Prev quickfix list"},
        -- Loclist
        ["qw"] = {"<Cmd>lopen<CR>", "Open loclist"},
        ["[w"] = {[[<Cmd>execute(v:count1 . 'lprev')<CR>]], "Previous item in loclist"},
        ["]w"] = {[[<Cmd>execute(v:count1 . 'lnext')<CR>]], "Next item in loclist"},
        ["[W"] = {"<Cmd>lfirst<CR>", "First item in loclist"},
        ["]W"] = {"<Cmd>llast<CR>", "Last item in loclist"},
        ["]E"] = {"<Cmd>lnewer<CR>", "Next loclist"},
        ["[E"] = {"<Cmd>lolder<CR>", "Prev loclist"},
        -- Tab
        ["[t"] = {"<Cmd>tabp<CR>", "Previous tab"},
        ["]t"] = {"<Cmd>tabn<CR>", "Next tab"}
    }
)

map("x", "iz", [[:<C-u>keepj norm [zjv]zkL<CR>]], {desc = "Inside folding block"})
map("o", "iz", [[:norm viz<CR>]], {desc = "Inside folding block"})
map("x", "az", [[:<C-u>keepj norm [zv]zL<CR>]], {desc = "Around folding block"})
map("o", "az", [[:norm vaz<CR>]], {desc = "Around folding block"})

-- Refocus folds
map("n", "<LocalLeader>z", [[zMzvzz]], {noremap = false})

map(
    "n",
    "zz",
    ([[(winline() == (winheight(0) + 1)/ 2) ?  %s : %s]]):format(
        [['zt' : (winline() == 1) ? 'zb']],
        [['zz']]
    ),
    {expr = true, desc = "Center or top current line"}
)

-- Keep focused in center of screen when searching
-- map("n", "n", "(v:searchforward ? 'nzzzv' : 'Nzzzv')", { expr = true })
-- map("n", "N", "(v:searchforward ? 'Nzzzv' : 'nzzzv')", { expr = true })

-- Window/Buffer
-- Grepping for keybindings is more difficult with this
wk.register(
    {
        ["<C-w>"] = {
            name = "+buffer",
            ["<C-s>"] = {
                [[<Cmd>lua require('common.builtin').split_lastbuf()<CR>]],
                "Split last buffer (horizontally)"
            },
            -- ["<C-v>"] = {
            --     [[<Cmd>lua require('common.builtin').split_lastbuf(true)<CR>]],
            --     "Split last buffer (vertically)"
            -- },
            ["<C-,>"] = {
                [[<Cmd>lua require('common.builtin').split_lastbuf()<CR>]],
                "Split last buffer (horizontally)"
            },
            ["<C-.>"] = {
                [[<Cmd>lua require('common.builtin').split_lastbuf(true)<CR>]],
                "Split last buffer (vertically)"
            },
            -- H = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
            -- V = {"<C-w>t<C-w>H", "Change horizontal to vertical"},
            ["<lt>"] = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
            [">"] = {"<C-w>t<C-w>H", "Change horizontal to vertical"},
            [";"] = {[[<Cmd>lua require('common.win').go2recent()<CR>]], "Focus last buffer"},
            X = {utils.close_all_floating_wins, "Close all floating windows"},
            ["<C-w>"] = {utils.focus_floating_win, "Focus floating window"},
            ["<C-t>"] = {"<Cmd>tab sp<CR>", "Open current window in tab"},
            O = {"<Cmd>tabo<CR>", "Close all tabs except current"},
            ["0"] = {"<C-w>=", "Equally high and wide"},
        }
    }
)

wk.register(
    {
        ["qc"] = {[[:lua require('common.qf').close()<CR>]], "Close quickfix"},
        ["qd"] = {[[:lua require('common.utils').close_diff()<CR>]], "Close diff"},
        ["qC"] = {[[:lua require("common.qfext").conflicts2qf()<CR>]], "Conflicts to quickfix"},
        ["qs"] = {
            [[:lua require("common.builtin").spellcheck()<CR>]],
            "Spelling mistakes to quickfix"
        },
        ["qz"] = {[[:lua require("common.builtin").changes2qf()<CR>]], "Changes to quickfix"},
        ["qD"] = {
            [[<Cmd>tabdo lua require('common.utils').close_diff()<CR><Cmd>noa tabe<Bar> noa bw<CR>]],
            "Close diff"
        },
        ["qt"] = {[[<Cmd>tabc<CR>]], "Close tab"},
        ["<A-u>"] = {
            [[:lua require('common.builtin').switch_lastbuf()<CR>]],
            "Switch to last buffer"
        },
        ["<Leader>fk"] = {
            [[<Cmd>lua require('common.qfext').outline({fzf=true})<CR>]],
            "Quickfix outline (fzf)"
        },
        ["<Leader>ff"] = {
            [[<Cmd>lua require('common.qfext').outline()<CR>]],
            "Quickfix outline (coc)"
        },
        ["<Leader>fw"] = {
            [[<Cmd>lua require('common.qfext').outline_treesitter()<CR>]],
            "Quickfix outline (treesitter)"
        },
        ["<Leader>fa"] = {
            [[<Cmd>lua require('common.qfext').outline_aerial()<CR>]],
            "Quickfix outline (aerial)"
        }
    }
)

-- ]]] === General mappings ===

-- ================== Spelling ================== [[[
wk.register(
    {
        ["<Leader>"] = {
            s = {
                name = "spelling",
                s = {":setlocal spell!<CR>", "Toggle spellchecking"},
                n = {"]s", "Next spelling mistake"},
                p = {"[s", "Previous spelling mistake"},
                a = {"zg", "Add word to spell list"},
                ["?"] = {"z=", "Offer spell corrections"},
                u = {"zuw", "Undo add to spell list"},
                l = {"<c-g>u<Esc>[s1z=`]a<c-g>u", "Correct next spelling mistake"}
            }
        }
    }
)
-- ]]] === Spelling ===

-- ==================== Other =================== [[[

map("n", "<Leader>jj", "Jumps", {cmd = true})

wk.register(
    {
        ["<Leader>"] = {
            e = {
                name = "+edit",
                -- c = {":e $XDG_CONFIG_HOME/nvim/coc-settings.json<CR>", "Edit coc-settings"},
                c = {"<cmd>CocConfig<CR>", "Edit coc-settings"},
                v = {":e $NVIMRC<CR>", "Edit neovim config"},
                z = {":e $ZDOTDIR/.zshrc<CR>", "Edit .zshrc"},
                p = {":e $NVIMD/lua/plugins.lua<CR>", "Edit plugins"}
            },
            ["sv"] = {":luafile $NVIMRC<CR>", "Source neovim config"}
        },
        ["<C-S-N>"] = {require("notify").dismiss, "Dismiss notification"}
    }
)
-- ]]] === Other ===

-- ============== Function Mappings ============= [[[
-- Allow the use of extended function keys
local fkey = 1
for i = 13, 24, 1 do
    map({"n", "x"}, ("<F%d>"):format(i), ("<S-F%d>"):format(fkey), {silent = true, desc = "ignore"})
    fkey = fkey + 1
end

fkey = 1
for i = 25, 36, 1 do
    map({"n", "x"}, ("<F%d>"):format(i), ("<C-F%d>"):format(fkey), {silent = true, desc = "ignore"})
    fkey = fkey + 1
end
-- ]]] === Function Mappings ===

-- Navigate merge conflict markers
-- map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})
-- map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})

-- Jump back and forth jumplist
-- map("n", "<C-A-o>", [[<C-o>]], {desc = "Previous item jumplist"})
-- map("n", "<C-A-i>", [[<C-i>]], {desc = "Next item jumplist"})
-- This works if Alacritty is configured correctly and Tmux is recompiled
-- map("n", "<C-o>", [[<C-o>]], {desc = "Previous item jumplist"})
-- map("n", "<C-i>", [[<C-i>]], {desc = "Next item jumplist"})

return M
