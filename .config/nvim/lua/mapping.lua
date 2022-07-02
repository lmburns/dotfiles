local M = {}

local utils = require("common.utils")
-- local funcs = require("functions")
-- local command = utils.command
local map = utils.map

-- local ex = nvim.ex
-- local api = vim.api
local fn = vim.fn

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
map("n", "<Backspace>", "<C-^>", {desc = "Alternate file"})

-- ╓                                                          ╖
-- ║                          Macro                           ║
-- ╙                                                          ╜
-- Use qq to record, q to stop, Q to play a macro
map("n", "Q", "@q")
-- map("v", "Q", ":normal @q")
map(
    "x",
    "@",
    ":<C-u>lua require('functions').execute_macro_over_visual_range()<CR>",
    {silent = false, desc = "Execute amcro visually"}
)

map("v", ".", ":normal .<CR>", {desc = "Perform dot commands over visual blocks"})

-- Use qq to record and stop (only records q)
map(
    "n",
    "qq",
    function()
        return fn.reg_recording() == "" and "qq" or "q"
    end,
    {expr = true, desc = "Record macro"}
)
map("n", "q:", "<Nop>")
map("n", "q/", "<Nop>")
map("n", "q?", "<Nop>")
map("n", "q", "<Nop>", {silent = true})

-- Repeat last command
map({"n", "x"}, "<F2>", "@:", {desc = "Repeat last command"})
-- map("c", "<CR>", [[pumvisible() ? "\<C-y>" : "\<CR>"]], {noremap = true, expr = true})

map({"n", "x", "o"}, "H", "g^")
map({"n", "x", "o"}, "L", "g_")
map("i", "<M-'>", "<End>", {desc = "Move to end of line"})
map("i", '<M-S-">', "<Home>", {desc = "Move to of line"})

-- Navigate merge conflict markers
-- map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})
-- map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})

-- Jump back and forth jumplist
map("n", "<C-A-o>", [[<C-o>]], {desc = "Previous item jumplist"})
map("n", "<C-A-i>", [[<C-i>]], {desc = "Next item jumplist"})

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("v", "<Tab>", ">><Esc>gv")
map("v", "<S-Tab>", "<<<Esc>gv")
-- map("i", "<S-Tab>", "<C-d>")
-- Don't lose selection when shifting sidewards
map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "v", "m`v")
map("n", "V", "m`V")
map("n", "<C-v>", "m`<C-v>")

-- Use g- and g+
wk.register(
    {
        ["U"] = {"<C-r>", "Redo action"},
        [";u"] = {":execute('earlier ' . v:count1 . 'f')<CR>", "Return to earlier state"},
        [";U"] = {":execute('later' . v:count1 . 'f')<CR>", "Return to later state"},
        ["gI"] = {":norm! gi<CR>", "Goto last insert spot"}
        -- ["g;"] = {":norm! g;<CR>", "Goto previous change"},
        -- ["g,"] = {":norm! g,<CR>", "Goto next change"}
    }
)

-- Yank mappings
wk.register(
    {
        ["yd"] = {dev.ithunk(require("common.yank").yank_reg, vim.v.register, fn.expand("%:p:h")), "Copy directory"},
        ["yn"] = {":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:t'))<CR>", "Copy file name"},
        ["yp"] = {":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p'))<CR>", "Copy full path"}
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
        ["E"] = {[[^"_D]], "Delete line (blackhole)"}, -- similar to 'S'/'cc'
        ["Y"] = {[[y$]], "Yank to EOL (without newline)"},
        ["x"] = {[["_x]], "Cut letter (blackhole)"},
        ["vv"] = {[[^vg_]], "Select entire line (without newline)"},
        ["cn"] = {[[*``cgn]], "Change text, start search forward"},
        ["cN"] = {[[*``cgN]], "Change text, start search backward"},
        ["g."] = {[[/\V<C-r>"<CR>cgn<C-a><Esc>]], "Make last change as initiation for cgn"}
        -- ["ghp"] = {[[m`o<Esc>p``]], "Paste line below (linewise)"},
        -- ["ghP"] = {[[m`O<Esc>p``]], "Paste line above (linewise)"},
    }
)

-- map("n", "c*", ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn")
map("x", "C", '"cy:let @/=@c<CR>cgn', {desc = "Change text (dot repeatable)"})
map("n", "cc", [[getline('.') =~ '^\s*$' ? '"_cc' : 'cc']], {expr = true})

wk.register(
    {
        ["<Leader>S"] = {":%S//g<Left><Left>", "Global replace"},
        ["dm"] = {[[:%s/<C-r>//g<CR>]], "Delete all search matches"},
        ["dM"] = {":%g/<C-r>//d<CR>", "Delete all lines with search matches"},
        -- ["<Leader>sr"] = {[[:%s/\<<C-r><C-w>\>/]], "Replace word under cursor"}
    },
    {silent = false}
)

wk.register(
    {
        ["d"] = {[["_d]], "Delete (blackhole)"},
        ["y"] = {[[ygv<Esc>]], "Place the cursor at end of yank"}
        -- ["c"] = {[["_c]], "Change (blackhole)"},
        -- ["//"] = {[[y/<C-R>"<CR>]], "Search for visual selection"}
    },
    {mode = "v"}
)

-- map("x", "p", "_c<Esc>p", {desc = "Paste over selected text"})
-- map("x", "p", [[p<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]], {desc = "Paste before})
-- map("x", "P", [[P<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]], {desc = "Paste after"})

-- map("n", "j", "(v:count == 0 ? 'gj' : 'j')", { expr = true })
-- map("n", "k", "(v:count == 0 ? 'gk' : 'k')", { expr = true })
-- map({ "n", "x", "o" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
-- map({ "n", "x", "o" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Jumps more than 5 modify jumplist
map("n", "j", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']], {expr = true})
map("n", "k", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']], {expr = true})

map("n", "gj", ":norm! }<CR>", {desc = "Move to next blank line"})
map("n", "gk", ":norm! {<CR>", {desc = "Move to previous blank line"})

-- Move selected text up down
-- map("v", "J", ":m '>+1<CR>gv=gv")
-- map("v", "K", ":m '<-2<CR>gv=gv")
-- map("i", "<C-J>", "<C-o><Cmd>m +1<CR>")
-- map("i", "<C-K>", "<C-o><Cmd>m -2<CR>")
-- map("n", "<C-,>", "<Cmd>m +1<CR>")
-- map("n", "<C-.>", "<Cmd>m -2<CR>")

-- Remap mark jumping
map({"n", "x", "o"}, "'", "`")
map({"n", "x", "o"}, "`", "'")

map({"n", "x", "o"}, "0", [[v:lua.require'common.builtin'.jump0()]], {expr = true})
map({"n", "x"}, "[", [[v:lua.require'common.builtin'.prefix_timeout('[')]], {expr = true})
map({"n", "x"}, "]", [[v:lua.require'common.builtin'.prefix_timeout(']')]], {expr = true})

wk.register(
    {
        ["[q"] = {[[<Cmd>execute(v:count1 . 'cprev')<CR>]], "Previous item in quickfix"},
        ["]q"] = {[[<Cmd>execute(v:count1 . 'cnext')<CR>]], "Next item in quickfix"},
        ["[Q"] = {"<Cmd>cfirst<CR>", "First item in quickfix"},
        ["]Q"] = {"<Cmd>clast<CR>", "Last item in quickfix"},
        ["[S"] = {"<Cmd>lfirst<CR>", "First location list"},
        ["]S"] = {"<Cmd>llast<CR>", "Last location list"},
        ["[t"] = {"<Cmd>tabp<CR>", "Previous tab"},
        ["]t"] = {"<Cmd>tabn<CR>", "Next tab"}
    }
)

-- Location list
-- map("n", "[s", [[<Cmd>execute(v:count1 . 'lprev')<CR>]])
-- map("n", "]s", [[<Cmd>execute(v:count1 . 'lnext')<CR>]])

-- Folding
map({"n", "x"}, "[z", "[z_", {desc = "Top of open fold"})
map({"n", "x"}, "]z", "]z_", {desc = "Bottom of open fold"})
-- map({"n", "x"}, "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]], {expr = true})
map({"n", "x"}, "zl", "zj_", {desc = "Top next fold"})
map({"n", "x"}, "zh", "zk_", {desc = "Bottom previous fold"})

-- map("n", "zf", "za")
-- map("n", "zF", "zA")
-- map("n", "zR", "zCzO")

-- map("n", "za", [[<Cmd>lua require('plugs.fold').with_highlight('a')<CR>]], {silent = false})
-- map("n", "zA", [[<Cmd>lua require('plugs.fold').with_highlight('A')<CR>]])
-- map("n", "zo", [[<Cmd>lua require('plugs.fold').with_highlight('o')<CR>]])
-- map("n", "zO", [[<Cmd>lua require('plugs.fold').with_highlight('O')<CR>]])
-- map("n", "zv", [[<Cmd>lua require('plugs.fold').with_highlight('v')<CR>]])

-- Recursively open whatever top level fold
-- map("n", "zR", [[<Cmd>lua require('plugs.fold').with_highlight('CzO')<CR>]])
map("n", "z;", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>", {silent = true})
map("n", "z'", "&foldlevel ? 'zM' :'zR'", {silent = true, expr = true, desc = "Open/close all folds in file"})
-- map("n", "z,", ":lua require('plugs.fold').open_fold()<CR>", {desc = "Open/close all folds under cursor"})

-- map(
--     "n",
--     "zp",
--     [[:lua if vim.o.foldlevel > 0 then require'ufo'.closeAllFolds() else require'ufo'.openAllFolds() end<CR>]],
--     {silent = true}
-- )

-- map("n", "ff", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>", {silent = true})
-- map("n", "fl", "&foldlevel ? 'zM' :'zR'", {silent = true, expr = true})

-- map("n", "z[", [[<Cmd>lua require('plugs.fold').nav_fold(false)<CR>]])
map("n", "z[", [[<Cmd>lua require('ufo').goPreviousStartFold()<CR>]])
map("n", "z]", [[<Cmd>lua require('plugs.fold').nav_fold(true)<CR>]])

map("n", "z,", [[<Cmd>lua require('ufo').goPreviousClosedFold()<CR>]])
map("n", "z.", [[<Cmd>lua require('ufo').goNextClosedFold()<CR>]])

map("x", "iz", [[:<C-u>keepj norm [zjv]zkL<CR>]], {desc = "Inside folding block"})
map("o", "iz", [[:norm viz<CR>]], {desc = "Inside folding block"})
map("x", "az", [[:<C-u>keepj norm [zv]zL<CR>]], {desc = "Around folding block"})
map("o", "az", [[:norm vaz<CR>]], {desc = "Around folding block"})

-- Refocus folds
map("n", "<LocalLeader>z", [[zMzvzz]])

map(
    "n",
    "zz",
    ([[(winline() == (winheight (0) + 1)/ 2) ?  %s : %s]]):format([['zt' : (winline() == 1) ? 'zb']], [['zz']]),
    {expr = true, desc = "Center or top current line"}
)

-- Window/Buffer
-- Grepping for keybindings is more difficult with this
wk.register(
    {
        ["<C-w>"] = {
            name = "+buffer",
            s = {
                [[<Cmd>lua require('common.builtin').split_lastbuf()<CR>]],
                "Split last buffer (horizontally)"
            },
            v = {
                [[<Cmd>lua require('common.builtin').split_lastbuf(true)<CR>]],
                "Split last buffer (vertically)"
            },
            H = {
                "<C-w>t<C-w>K",
                "Change vertical to horizontal"
            },
            V = {
                "<C-w>t<C-w>H",
                "Change horizontal to vertical"
            },
            [";"] = {
                [[<Cmd>lua require('common.win').go2recent()<CR>]],
                "Focus last buffer"
            },
            ["X"] = {
                utils.close_all_floating_wins,
                "Close all floating windows"
            },
            ["<C-w>"] = {
                utils.focus_floating_win,
                "Focus floating window"
            },
            ["<C-t>"] = {
                "<Cmd>tab sp<CR>",
                "Split tab"
            },
            ["O"] = {
                "<Cmd>tabo<CR>",
                "Close all other tabs except this one"
            }
        }
    }
)

map("n", "<Leader>rt", "<cmd>setl et<CR>", {desc = "Set extendedtab"})
map("x", "<Leader>re", "<cmd>retab!<CR>", {desc = "Retab selection"})
map("n", "<Leader>cd", "<cmd>lcd %:p:h<CR><cmd>pwd<CR>", {desc = "lcd to filename directory"})

wk.register(
    {
        ["qc"] = {[[:lua require('common.qf').close()<CR>]], "Close quickfix"},
        ["qd"] = {[[:lua require('common.utils').close_diff()<CR>]], "Close diff"},
        ["qC"] = {[[:lua require("common.qfext").conflicts2qf()<CR>]], "Conflicts to quickfix"},
        ["qs"] = {[[:lua require("common.builtin").spellcheck()<CR>]], "Spelling mistakes to quickfix"},
        ["qz"] = {[[:lua require("common.builtin").changes2qf()<CR>]], "Changes to quickfix"},
        ["qD"] = {
            [[<Cmd>tabdo lua require('common.utils').close_diff()<CR><Cmd>noa tabe<Bar> noa bw<CR>]],
            "Close diff"
        },
        ["qt"] = {[[<Cmd>tabc<CR>]], "Close tab"},
        ["<A-u>"] = {[[:lua require('common.builtin').switch_lastbuf()<CR>]], "Switch to last buffer"},
        ["<Leader>fk"] = {[[<Cmd>lua require('common.qfext').outline({fzf=true})<CR>]], "Quickfix outline (fzf)"},
        ["<Leader>ff"] = {[[<Cmd>lua require('common.qfext').outline()<CR>]], "Quickfix outline (coc)"},
        ["<Leader>fw"] = {
            [[<Cmd>lua require('common.qfext').outline_treesitter()<CR>]],
            "Quickfix outline (treesitter)"
        },
        ["<Leader>fa"] = {[[<Cmd>lua require('common.qfext').outline_aerial()<CR>]], "Quickfix outline (aerial)"}
    }
)

-- Keep focused in center of screen when searching
-- map("n", "n", "(v:searchforward ? 'nzzzv' : 'Nzzzv')", { expr = true })
-- map("n", "N", "(v:searchforward ? 'Nzzzv' : 'nzzzv')", { expr = true })

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
                z = {":e $ZDOTDIR/.zshrc<CR>", "Edit .zshrc"}
            },
            ["sv"] = {":luafile $NVIMRC<CR>", "Source neovim config"}
        }
    }
)

map("n", "<C-g>", "2<C-g>", {desc = "Show buffer info"})
-- ]]] === Other ===

-- ============== Function Mappings ============= [[[
-- Allow the use of extended function keys
local fkey = 1
for i = 13, 24, 1 do
    map({"n", "x"}, ("<F%d>"):format(i), ("<S-F%d>"):format(fkey), {silent = true})
    fkey = fkey + 1
end

fkey = 1
for i = 25, 36, 1 do
    map({"n", "x"}, ("<F%d>"):format(i), ("<C-F%d>"):format(fkey), {silent = true})
    fkey = fkey + 1
end
-- ]]] === Function Mappings ===

return M
