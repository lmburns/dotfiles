local M = {}

local utils = require("common.utils")
local funcs = require("functions")
local map = utils.map
local command = utils.command

local ex = nvim.ex
local fn = vim.fn
local api = vim.api

-- Legendary needs to be called again in this file for the keybindings to register
-- Not sure why these options only work from here
require("legendary").setup(
    ---@diagnostic disable-next-line: redundant-parameter
    {
        include_builtin = false,
        include_legendary_cmds = false
    }
)
local wk = require("which-key")

-- ============== General mappings ============== [[[
-- map("n", "<Space>", "<Nop>")
-- map("x", "<Space>", "<Nop>")

wk.register(
    {
        [";q"] = {[[:lua require('common.builtin').fix_quit()<CR>]], "Quit"},
        [";w"] = {[[:update<CR>]], "Update file"}
    }
)

-- Map '-' to blackhole register
map("n", "-", '"_', {desc = "Black hole register"})
map("x", "-", '"_', {desc = "Black hole register"})
map("n", "q:", "<Nop>")
map("n", "q/", "<Nop>")
map("n", "q?", "<Nop>")
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

-- Use qq to record and stop (only records q)
map(
    "n",
    "qq",
    function()
        return fn.reg_recording() == "" and "qq" or "q"
    end,
    {expr = true, desc = "Record macro"}
)
map("n", "q", "<Nop>", {silent = true})

-- Repeat last command
wk.register(
    {
        ["<F2>"] = {"@:", "Repeat last command"}
    }
)

map({"n", "x"}, "<Leader>2;", "@:", {desc = "Repeat last command"})
-- map("c", "<CR>", [[pumvisible() ? "\<C-y>" : "\<CR>"]], {noremap = true, expr = true})

map({"n", "x", "o"}, "H", "g^")
map({"n", "x", "o"}, "L", "g_")

-- Navigate merge conflict markers
-- map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})
-- map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})

wk.register(
    {
        ["S"] = {":%S//g<Left><Left>", "Global replace"}
        -- ["<Leader>sr"] = {[[:%s/\<<C-r><C-w>\>/]], "Replace word under cursor"}
    },
    {silent = false}
)

-- Jump back and forth jumplist
map("n", "<C-A-o>", [[<C-o>]], {desc = "Previous item jumplist"})
map("n", "<C-A-i>", [[<C-i>]], {desc = "Next item jumplist"})

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("v", "<Tab>", ">><Esc>gv")
map("v", "<S-Tab>", "<<<Esc>gv")
map("i", "<S-Tab>", "<C-d>")
-- Don't lose selection when shifting sidewards
map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "v", "m`v")
map("n", "V", "m`V")
map("n", "<C-v>", "m`<C-v>")

-- TIP: Use g- and g+
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
        ["yd"] = {":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>", "Copy directory"},
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
    --         -- ["oo"] = {[[<cmd>put =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    --         -- ["OO"] = {[[<cmd>put! =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
)

wk.register(
    {
        ["D"] = {[["_D]], "Delete to end of line (blackhole)"},
        ["E"] = {[[^"_D]], "Delete line (blackhole)"},
        ["Y"] = {[[y$]], "Yank to EOL (without newline)"},
        ["x"] = {[["_x]], "Cut letter (blackhole)"},
        ["vv"] = {[[^vg_]], "Select entire line (without newline)"}
        -- ["ghp"] = {[[m`o<Esc>p``]], "Paste line below (linewise)"},
        -- ["ghP"] = {[[m`O<Esc>p``]], "Paste line above (linewise)"},
    }
)

wk.register(
    {
        ["d"] = {[["_d]], "Delete (blackhole)"},
        ["y"] = {[[ygv<Esc>]], "Place the cursor at end of yank"}
        -- ["c"] = {[["_c]], "Change (blackhole)"},
        -- ["y"] = {[==[ygv<Esc>']]==], "Place the cursor back where started on yank"},
        -- ["//"] = {[[y/<C-R>"<CR>]], "Search for visual selection"}
    },
    {mode = "v"}
)

-- Paste over selected text
-- map("x", "p", "_c<Esc>p")

-- Paste before
-- map("x", "p", [[p<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])
-- Paste after
-- map("x", "P", [[P<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])

-- Move through folded lines
-- map("n", "j", "(v:count == 0 ? 'gj' : 'j')", { expr = true })
-- map("n", "k", "(v:count == 0 ? 'gk' : 'k')", { expr = true })

-- Jumps more than 5 modify jumplist
map("n", "j", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']], {expr = true})
map("n", "k", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']], {expr = true})

-- map("n", "gj", ":norm! }<CR>")
-- map("n", "gk", ":norm! {<CR>")

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

-- Buffer switching
-- map("n", "gt", ":bnext<CR>")
-- map("n", "gT", ":bprevious<CR>")

map("n", "cc", [[getline('.') =~ '^\s*$' ? '"_cc' : 'cc']], {expr = true})
map({"n", "x", "o"}, "0", [[v:lua.require'common.builtin'.jump0()]], {expr = true})

map({"n", "x"}, "[", [[v:lua.require'common.builtin'.prefix_timeout('[')]], {expr = true})
map({"n", "x"}, "]", [[v:lua.require'common.builtin'.prefix_timeout(']')]], {expr = true})

wk.register(
    {
        ["[q"] = {[[:execute(v:count1 . 'cprev')<CR>]], "Previous item in quickfix"},
        ["]q"] = {[[:execute(v:count1 . 'cnext')<CR>]], "Next item in quickfix"},
        ["[Q"] = {":cfirst<CR>", "First item in quickfix"},
        ["]Q"] = {":clast<CR>", "Last item in quickfix"},
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
map({"n", "x"}, "[z", "[z_")
map({"n", "x"}, "]z", "]z_")
map({"n", "x"}, "zj", "zj_", {desc = "Next fold"})
map({"n", "x"}, "zk", "zk_", {desc = "Previous fold"})
map({"n", "x"}, "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]], {expr = true})

map("n", "zf", [[<Cmd>lua require('plugs.fold').with_highlight('a')<CR>]], {silent = false})
map("n", "zF", [[<Cmd>lua require('plugs.fold').with_highlight('A')<CR>]])
map("n", "zo", [[<Cmd>lua require('plugs.fold').with_highlight('o')<CR>]])
map("n", "zO", [[<Cmd>lua require('plugs.fold').with_highlight('O')<CR>]])
map("n", "zv", [[<Cmd>lua require('plugs.fold').with_highlight('v')<CR>]])
-- Recursively open whatever top level fold
map("n", "zR", [[<Cmd>lua require('plugs.fold').with_highlight('CzO')<CR>]])
map("n", "z;", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>", {silent = true})

map("n", "z[", [[<Cmd>lua require('plugs.fold').nav_fold(false)<CR>]])
map("n", "z]", [[<Cmd>lua require('plugs.fold').nav_fold(true)<CR>]])

map("x", "iz", [[:<C-u>keepj norm [zv]zg_<CR>]], {desc = "Previous opening brace"})
map("o", "iz", [[:norm viz<CR>]])

-- Using <ff> to fold or unfold
map("n", "ff", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>", {silent = true})
map("n", "fl", "&foldlevel ? 'zM' :'zR'", {silent = true, expr = true})
-- Refocus folds
map("n", "<LocalLeader>z", [[zMzvzz]])
-- map("n", "<Space><CR>", "zi", { silent = true })

map("n", "zz", [[(winline() == (winheight (0) + 1)/ 2) ?  'zt' : (winline() == 1)? 'zb' : 'zz']], {expr = true})

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
                function()
                    if api.nvim_win_get_config(fn.win_getid()).relative ~= "" then
                        ex.wincmd("p")
                        return
                    end
                    for _, winnr in ipairs(fn.range(1, fn.winnr("$"))) do
                        local winid = fn.win_getid(winnr)
                        local conf = nvim.win.get_config(winid)
                        if conf.focusable and conf.relative ~= "" then
                            fn.win_gotoid(winid)
                            return
                        end
                    end
                end,
                "Focus floating window"
            }
        }
    }
)

-- perform dot commands over visual blocks
map("v", ".", ":normal .<CR>")

-- Change tabs
map("n", "<Leader>rt", "<cmd>setl et<CR>")
map("x", "<Leader>re", "<cmd>retab!<CR>")
-- Change directory to buffers dir
map("n", "<Leader>cd", ":lcd %:p:h<CR>")

wk.register(
    {
        -- Change vertical to horizontal
        ["<Leader>w-"] = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
        ["<Leader>w\\"] = {"<C-w>t<C-w>H", "Change horizontal to vertical"},
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
        ["<Leader>ft"] = {[[<Cmd>lua require('common.qfext').outline({fzf=true})<CR>]], "Quickfix outline (fzf)"},
        ["<Leader>ff"] = {[[<Cmd>lua require('common.qfext').outline()<CR>]], "Quickfix outline (coc)"},
        ["<Leader>fw"] = {[[<Cmd>lua require('common.qfext').outline_treesitter()<CR>]], "Quickfix outline (coc)"},
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
                c = {
                    ":e $XDG_CONFIG_HOME/nvim/coc-settings.json<CR>",
                    "Edit coc-settings"
                },
                v = {":e $VIMRC<CR>", "Edit neovim config"},
                z = {":e $ZDOTDIR/.zshrc<CR>", "Edit .zshrc"}
            },
            ["sv"] = {":luafile $VIMRC<CR>", "Source neovim config"}
        }
    }
)

-- Show file info
map("n", "<C-g>", "2<C-g>")
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
