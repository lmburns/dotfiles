local M = {}

local utils = require("common.utils")
local map = utils.map
local command = utils.command

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

-- M.mappings = {}
--
-- This is for returning them and sending them to a delayed function
-- local function map2(modes, lhs, rhs, opts)
--     opts = opts or {}
--     opts.noremap = opts.noremap == nil and true or opts.noremap
--     if type(modes) == "string" then
--         modes = {modes}
--     end
--     for _, mode in ipairs(modes) do
--         table.insert(M.mappings, {mode, lhs, rhs, opts})
--     end
-- end

-- ============== General mappings ============== [[[
-- map("i", "jk", "<ESC>")
-- map("i", "kj", "<ESC>")

wk.register(
    {
        [";q"] = {[[:lua require('common.builtin').fix_quit()<CR>]], "Quit"},
        [";w"] = {[[:update<CR>]], "Update file"}
    }
)

map("n", "q:", "<Nop>")
map("n", "q/", "<Nop>")
map("n", "q?", "<Nop>")

command("Q", "q", {bang = true, nargs = "*"})

-- Replace command history with quit
-- map q: :MinimapToggle<CR> :q<CR>
-- map q: :q<CR>

-- Use qq to record, q to stop, Q to play a macro
map("n", "Q", "@q")
map("v", "Q", ":normal @q")

-- Use qq to record and stop (only records q)
map(
    "n",
    "qq",
    function()
        return fn.reg_recording() == "" and "qq" or "q"
    end,
    {noremap = true, expr = true}
)
map("n", "q", "<Nop>", {silent = true})

-- Repeat last command
wk.register(
    {
        ["<F2>"] = {"@:", "Repeat last command"},
        ["<Leader>2;"] = {"@:", "Repeat last command"}
    }
)
map("x", "<Leader>2;", "@:")
map("c", "<CR>", [[pumvisible() ? "\<C-y>" : "\<CR>"]], {noremap = true, expr = true})

-- Easier navigation in normal / visual / operator pending mode
map("n", "gkk", "{")
map("n", "gjj", "}")
map("n", "H", "g^")
map("x", "H", "g^")
map("n", "L", "g_")
map("x", "L", "g_")

-- Navigate merge conflict markers
map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})
map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true})

wk.register(
    {
        ["S"] = {":%s//g<Left><Left>", "Replace all"},
        ["<Leader>sr"] = {[[:%s/\<<C-r><C-w>\>/]], "Replace word under cursor"}
    },
    {silent = false}
)

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("v", "<Tab>", ">><Esc>gv")
map("v", "<S-Tab>", "<<<Esc>gv")
map("i", "<S-Tab>", "<C-d>")

-- Don't lose selection when shifting sidewards
map("x", "<", "<gv")
map("x", ">", ">gv")

-- TIP: Use g- and g+
wk.register(
    {
        ["U"] = {"<C-r>", "Redo action"},
        [";u"] = {":execute('earlier ' . v:count1 . 'f')<CR>", "Return to earlier state"},
        [";U"] = {":execute('later' . v:count1 . 'f')<CR>", "Return to later state"}
    }
)

-- Yank mappings
wk.register(
    {
        ["yd"] = {
            ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>",
            "Copy directory name"
        },
        ["yn"] = {":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:t'))<CR>", "Copy file name"},
        ["yp"] = {":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p'))<CR>", "Copy full path"}
    }
)

wk.register(
    {
        ["y"] = {[[v:lua.require'common.yank'.wrap()]], "Yank motion"},
        ["yw"] = {[[v:lua.require'common.yank'.wrap('iw')]], "Yank word (iw)"},
        ["yW"] = {[[v:lua.require'common.yank'.wrap('iW')]], "Yank word (iW)"},
        ["gp"] = {[['`[' . strpart(getregtype(), 0, 1) . '`]']], "Reselect pasted text"}
    },
    {expr = true}
)

wk.register(
    {
        ["d"] = {[["_d]], "Delete motion (blackhole)"},
        ["D"] = {[["_D]], "Delete to end of line (blackhole)"},
        ["E"] = {[[^"_D]], "Delete line (blackhole)"},
        ["Y"] = {[[y$]], "Yank to EOL (without newline)"},
        ["x"] = {[["_x]], "Cut letter (blackhole)"},
        ["vv"] = {[[^vg_]], "Select entire line (without newline)"}
    }
)

wk.register(
    {
        ["d"] = {[["_d]], "Delete (blackhole)"},
        ["y"] = {[[ygv<Esc>]], "Place the cursor back where started on yank"},
        -- ["y"] = {[==[ygv<Esc>']]==], "Place the cursor back where started on yank"},
        ["//"] = {[[y/<C-R>"<CR>]], "Search for visual selection"}
    },
    {mode = "v"}
)

-- Paste over selected text
-- map("x", "p", "_c<Esc>p")

-- Paste before
map("x", "p", [[p<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])
-- Paste after
map("x", "P", [[P<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])

wk.register(
    {
        ["zl"] = {"i <Esc>l", "Insert space to left of cursor"},
        ["zj"] = {"printf('m`%so<ESC>``', v:count1)", "Insert line below cursor"},
        ["zk"] = {"printf('m`%sO<ESC>``', v:count1)", "Insert line above cursor"}
    },
    {expr = true}
)

wk.register(
    {
        ["oo"] = {"o<Esc>k", "Insert line below cursor"},
        ["OO"] = {"O<Esc>j", "Insert line above cursor"}
    }
)

-- Move through folded lines
-- map("n", "j", "(v:count == 0 ? 'gj' : 'j')", { expr = true })
-- map("n", "k", "(v:count == 0 ? 'gk' : 'k')", { expr = true })

-- Jumps more than 5 modify jumplist
map("n", "j", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']], {expr = true})
map("n", "k", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']], {expr = true})

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
-- Buffers; Bufferline takes care of this
-- map("n", "[b", [[:execute(v:count1 . 'bprev')<CR>]])
-- map("n", "]b", [[:execute(v:count1 . 'bnext')<CR>]])
-- Errors
map("n", "[q", [[:execute(v:count1 . 'cprev')<CR>]])
map("n", "]q", [[:execute(v:count1 . 'cnext')<CR>]])
-- First/last errors
map("n", "[Q", ":cfirst<CR>")
map("n", "]Q", ":clast<CR>")
-- Location list
-- map("n", "[s", [[<Cmd>execute(v:count1 . 'lprev')<CR>]])
-- map("n", "]s", [[<Cmd>execute(v:count1 . 'lnext')<CR>]])
-- First/last location list
map("n", "[S", "<Cmd>lfirst<CR>")
map("n", "]S", "<Cmd>llast<CR>")

-- Folding
map("n", "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]], {noremap = true, expr = true})
map("x", "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]], {noremap = true, expr = true})

map("n", "zf", [[<Cmd>lua require('common.fold').with_highlight('a')<CR>]], {silent = false})
map("n", "zF", [[<Cmd>lua require('common.fold').with_highlight('A')<CR>]])
map("n", "zo", [[<Cmd>lua require('common.fold').with_highlight('o')<CR>]])
map("n", "zO", [[<Cmd>lua require('common.fold').with_highlight('O')<CR>]])
map("n", "zv", [[<Cmd>lua require('common.fold').with_highlight('v')<CR>]])
-- Recursively open whatever top level fold
map("n", "zR", [[<Cmd>lua require('common.fold').with_highlight('CzO')<CR>]])

map("n", "z[", [[<Cmd>lua require('common.fold').nav_fold(false)<CR>]])
map("n", "z]", [[<Cmd>lua require('common.fold').nav_fold(true)<CR>]])

-- Using <ff> to fold or unfold
map("n", "ff", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>", {silent = true})
map("n", "fl", "&foldlevel ? 'zM' :'zR'", {silent = true, expr = true})
-- Refocus folds
map("n", "<LocalLeader>z", [[zMzvzz]])
-- map("n", "<Space><CR>", "zi", { silent = true })

-- Window/Buffer
-- Grepping for keybindings is more difficult with this
wk.register(
    {
        ["<C-w>"] = {
            name = "buffer",
            s = {
                [[<Cmd>lua require('common.builtin').split_lastbuf()<CR>]],
                "Split last buffer (horizontally)"
            },
            v = {
                [[<Cmd>lua require('common.builtin').split_lastbuf(true)<CR>]],
                "Split last buffer (vertically)"
            },
            [";"] = {
                [[<Cmd>lua require('common.win').go2recent()<CR>]],
                "Focus last buffer"
            },
            ["<C-w>"] = {
                function()
                    if api.nvim_win_get_config(fn.win_getid()).relative ~= "" then
                        cmd [[wincmd p]]
                        return
                    end
                    for _, winnr in ipairs(fn.range(1, fn.winnr("$"))) do
                        local winid = fn.win_getid(winnr)
                        local conf = api.nvim_win_get_config(winid)
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
map("n", "<Leader>nt", ":setlocal noexpandtab<CR>")
map("x", "<Leader>re", ":retab!<CR>")

wk.register(
    {
        -- Change vertical to horizontal
        ["<Leader>w-"] = {"<C-w>t<C-w>K", "Change vertical to horizontal"},
        ["<Leader>w\\"] = {"<C-w>t<C-w>H", "Change horizontal to vertical"},
        ["<Esc><Esc>"] = {"<Esc>:nohlsearch<CR>", "Disable hlsearch"},
        ["qc"] = {[[:lua require('common.qf').close()<CR>]], "Close quickfix"},
        ["<Leader>cc"] = {":cclose<CR>", "Close quickfix (cclose)"},
        ["qd"] = {[[:lua require('common.kutils').close_diff()<CR>]], "Close diff"},
        ["<A-u>"] = {[[:lua require('common.builtin').switch_lastbuf()<CR>]], "Switch to last buffer"},
        ["<Leader>ft"] = {[[<Cmd>lua require('common.qfext').outline()<CR>]], "Quickfix function outline"}
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

map("n", "<Leader>jj", "<Cmd>Jumps<CR>")

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
            ["sv"] = {":so $VIMRC<CR>", "Source neovim config"}
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
