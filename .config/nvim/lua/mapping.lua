local M = {}

local utils = require("common.utils")
local map = utils.map
local fmap = utils.fmap

M.mappings = {}

-- This is for returning them and sending them to a delayed function
local function map2(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    table.insert(M.mappings, { mode, lhs, rhs, opts })
  end
end

-- ============== General mappings ============== [[[
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")

map("n", "q:", "<Nop>")
map("n", "q/", "<Nop>")
map("n", "q?", "<Nop>")
map("n", ";w", ":update<CR>")

map("n", "Q:", ":q", { noremap = false })
map("n", ";q", [[<Cmd>lua require('common.builtin').fix_quit()<CR>]])
map("n", "qa", "<Cmd>qa<CR>")

-- Replace command history with quit
-- map q: :MinimapToggle<CR> :q<CR>
-- map q: :q<CR>

cmd([[command! -bang -nargs=* Q q]])

-- Use qq to record, q to stop, Q to play a macro
map("n", "Q", "@q")
map("v", "Q", ":normal @q")

-- Use qq to record and stop (only records q)
fmap {
  "n",
  "qq",
  function()
    return vim.fn.reg_recording() == "" and "qq" or "q"
  end,
  { noremap = true, expr = true },
}
map("n", "q", "<Nop>", { silent = true })

-- Repeat last command
map("n", "<F2>", "@:")
map("n", "<Leader>2;", "@:")
map("x", "<Leader>2;", "@:")
map(
    "c", "<CR>", [[pumvisible() ? "\<C-y>" : "\<CR>"]],
    { noremap = true, expr = true }
)

-- Easier navigation in normal / visual / operator pending mode
map("n", "gkk", "{")
map("n", "gjj", "}")
map("n", "H", "g^")
map("x", "H", "g^")
map("n", "L", "g_")
map("x", "L", "g_")

-- Navigate merge conflict markers
map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], { silent = true })
map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], { silent = true })

-- Replace all
map("n", "S", ":%s//g<Left><Left>")
-- Replace under cursor
map("n", "<Leader>sr", [[:%s/\<<C-r><C-w>\>/]])
-- Replace quotes on the line
map("n", "<Leader>Q", [[:s/'/"/g<CR>:nohlsearch<CR>]])
-- Title case entire line
-- map("n", "<Leader>sc", [[s/\v<(\w)(\S*)/\u\1\L\2/g<CR>:nohlsearch<CR>]])

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("v", "<Tab>", ">><Esc>gv")
map("v", "<S-Tab>", "<<<Esc>gv")
map("i", "<S-Tab>", "<C-d>")

-- Don't lose selection when shifting sidewards
map("x", "<", "<gv")
map("x", ">", ">gv")

-- NOTE: Use g- and g+
-- Use `u` to undo, use `U` to redo
map("n", "U", "<C-r>")
map("n", ";u", [[:execute('earlier ' . v:count1 . 'f')<CR>]], { silent = false })
map("n", ";U", [[:execute('later ' . v:count1 . 'f')<CR>]], { silent = false })

-- Yank mappings
map("n", "y", [[v:lua.require'common.yank'.wrap()]], { expr = true })
map("n", "yw", [[v:lua.require'common.yank'.wrap('iw')]], { expr = true })
map("n", "yW", [[v:lua.require'common.yank'.wrap('iW')]], { expr = true })
-- Copy directory
map(
    "n", "yd",
    [[:lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>]]
)
-- Copy name
map(
    "n", "yn",
    [[:lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:t'))<CR>]]
)
-- Copy path
map(
    "n", "yp",
    [[:lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p'))<CR>]]
)

-- Make deleting line not go to clipbard
map("n", "d", "\"_d")
map("v", "d", "\"_d")
map("n", "D", "\"_D")
-- Delete line without copying
map("n", "E", "^\"_D")
-- Yank line without newline character
map("n", "Y", "y$")
-- Make cut not go to clipboard
map("n", "x", "\"_x")
-- Reselect the text that has just been pasted
map("n", "gp", [['`[' . strpart(getregtype(), 0, 1) . '`]']], { expr = true })
-- Select characters of line (no new line)
map("n", "vv", "^vg_")
-- Make visual yanks place the cursor back where started
map("v", "y", "ygv<Esc>")
-- Insert a space after current character
-- map("n", "<Leader>sa", 'a<Space><Esc>h')

-- Paste over selected text
-- map("x", "p", "_c<Esc>p")

-- Paste before
map("x", "p", [[p<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])
-- Paste after
map("x", "P", [[P<Cmd>let @+ = @0<CR><Cmd>let @" = @0<CR>]])

-- Adds a space  to left of cursor
map("n", "zl", "i <Esc>l", { silent = true })

-- Inserts a line above or below (these are the same)
map("n", "zj", "printf('m`%so<ESC>``', v:count1)", { expr = true })
map("n", "zk", "printf('m`%sO<ESC>``', v:count1)", { expr = true })
map("n", "oo", "o<Esc>k", { silent = true })
map("n", "OO", "O<Esc>j", { silent = true })

-- Move through folded lines
-- map("n", "j", "(v:count == 0 ? 'gj' : 'j')", { expr = true })
-- map("n", "k", "(v:count == 0 ? 'gk' : 'k')", { expr = true })

-- Jumps more than 5 modify jumplist
map(
    "n", "j", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']],
    { expr = true }
)
map(
    "n", "k", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']],
    { expr = true }
)

-- Move selected text up down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("i", "<C-J>", "<C-o><Cmd>m +1<CR>")
map("i", "<C-K>", "<C-o><Cmd>m -2<CR>")
-- map("n", "<C-,>", "<Cmd>m +1<CR>")
-- map("n", "<C-.>", "<Cmd>m -2<CR>")

-- Move between windows
map("n", "<C-j>", "<C-W>j")
map("n", "<C-k>", "<C-W>k")
map("n", "<C-h>", "<C-W>h")
map("n", "<C-l>", "<C-W>l")

-- Using <ff> to fold or unfold
map(
    "n", "ff", "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>",
    { silent = true }
)
map("n", "fl", "&foldlevel ? 'zM' :'zR'", { silent = true, expr = true })
-- map("n", "<Space><CR>", "zi", { silent = true })

-- Remap mark jumping
map({ "n", "x", "o" }, "'", "`")
map({ "n", "x", "o" }, "`", "'")

-- Buffer switching
map("n", "gt", ":bnext<CR>")
map("n", "gT", ":bprevious<CR>")

map("n", "cc", [[getline('.') =~ '^\s*$' ? '"_cc' : 'cc']], { expr = true })
map(
    { "n", "x", "o" }, "0", [[v:lua.require'common.builtin'.jump0()]],
    { expr = true }
)

map(
    { "n", "x" }, "[", [[v:lua.require'common.builtin'.prefix_timeout('[')]],
    { expr = true }
)
map(
    { "n", "x" }, "]", [[v:lua.require'common.builtin'.prefix_timeout(']')]],
    { expr = true }
)
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
map("n", "[s", [[<Cmd>execute(v:count1 . 'lprev')<CR>]])
map("n", "]s", [[<Cmd>execute(v:count1 . 'lnext')<CR>]])
-- First/last location list
map("n", "[S", "<Cmd>lfirst<CR>")
map("n", "]S", "<Cmd>llast<CR>")

-- Folding
map(
    "n", "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]],
    { noremap = true, expr = true }
)
map(
    "x", "z", [[v:lua.require'common.builtin'.prefix_timeout('z')]],
    { noremap = true, expr = true }
)

map(
    "n", "zf", [[<Cmd>lua require('common.fold').with_highlight('a')<CR>]],
    { silent = false }
)
map("n", "zF", [[<Cmd>lua require('common.fold').with_highlight('A')<CR>]])
map("n", "zo", [[<Cmd>lua require('common.fold').with_highlight('o')<CR>]])
map("n", "zO", [[<Cmd>lua require('common.fold').with_highlight('O')<CR>]])
map("n", "zv", [[<Cmd>lua require('common.fold').with_highlight('v')<CR>]])

map("n", "z[", [[<Cmd>lua require('common.fold').nav_fold(false)<CR>]])
map("n", "z]", [[<Cmd>lua require('common.fold').nav_fold(true)<CR>]])

-- New buffer
map("n", "<Leader>bn", ":enew<CR>")
-- Close buffer
map("n", "<Leader>bq", ":bp <Bar> bd! #<CR>")
-- Close all buffers
map("n", "<Leader>bQ", ":bufdo bd! #<CR>")

-- Split last buffer
map("n", "<C-w>s", [[:lua require('common.builtin').split_lastbuf()<CR>]])
map("n", "<C-w>v", [[:lua require('common.builtin').split_lastbuf(true)<CR>]])

map("n", "<C-w>;", [[<Cmd>lua require('common.win').go2recent()<CR>]])

-- Resize windows
-- map("n", "+", ":vertical resize +5<CR>")
-- map("n", "-", ":vertical resize -5<CR>")
-- map("n", "s+", ":resize +5<CR>")
-- map("n", "s-", ":resize -5<CR>")
map("n", "<C-Up>", [[:lua require('common.utils').resize(false, -1)<CR>]])
map("n", "<C-Down>", [[:lua require('common.utils').resize(false, 1)<CR>]])
map("n", "<C-Right>", [[:lua require('common.utils').resize(true, 1)<CR>]])
map("n", "<C-Left>", [[:lua require('common.utils').resize(true, -1)<CR>]])

-- Change vertical to horizontal
map("n", "<Leader>w-", "<C-w>t<C-w>K")
-- Change horizontal to vertical
map("n", [[<Leader>w\]], "<C-w>t<C-w>H")

-- perform dot commands over visual blocks
map("v", ".", ":normal .<CR>")
-- Toggle hlsearch
map("n", "<Esc><Esc>", "<Esc>:nohlsearch<CR>")

-- Change tabs
map("n", "<Leader>nt", ":setlocal noexpandtab<CR>")
map("x", "<Leader>re", ":retab!<CR>")
-- Close quickfix
map("n", "<Leader>cc", ":cclose<CR>")
-- Close diff
map("n", "qd", [[:lua require('common.kutils').close_diff()<CR>]])
-- Close quickfix
map("n", "qc", [[:lua require('common.qf').close()<CR>]])
-- Switch to last buffer
map("n", "<A-u>", [[:lua require('common.builtin').switch_lastbuf()<CR>]])
-- qf Extension
map("n", "<Leader>ft", [[<Cmd>lua require('common.qfext').outline()<CR>]])

-- Keep focused in center of screen when searching
-- map("n", "n", "(v:searchforward ? 'nzzzv' : 'Nzzzv')", { expr = true })
-- map("n", "N", "(v:searchforward ? 'Nzzzv' : 'nzzzv')", { expr = true })

-- Insert a place holder
map("i", ",p", "<++>")

-- Jump to the next '<++>' and edit it
map("n", "<Leader>fe", "<Esc>/<++><CR>:nohlsearch<CR>c4l", { silent = true })
map("n", "<Leader>fi", "<Esc>/<++><CR>:nohlsearch<CR>", { silent = true })
map("i", ";fi", "<Esc>/<++><CR>:nohlsearch<CR>\"_c4l", { silent = true })

-- ]]] === General mappings ===

-- ================== Spelling ================== [[[
map("n", "<Leader>ss", ":setlocal spell!<CR>")
map("n", "<Leader>sn", "]s")
map("n", "<Leader>sp", "[s")
map("n", "<Leader>sa", "zg")
map("n", "<Leader>s?", "z=")
map("n", "<Leader>su", "zuw")
map("n", "<Leader>su1", "zug")
-- Correct last spelling mistake
map("n", "<Leader>sl", "<c-g>u<Esc>[s1z=`]a<c-g>u")
-- ]]] === Spelling ===

-- ==================== Other =================== [[[
-- map("n", "F2", ":set nowrap!<CR>", { silent = true })
-- map("n", "F3", ":set relativenumber!<CR>", { silent = true })
map("n", "<Leader>ec", ":e $XDG_CONFIG_HOME/nvim/coc-settings.json<CR>")
map("n", "<Leader>ev", ":e $VIMRC<CR>")
map("n", "<Leader>sv", ":so $VIMRC<CR>")
map("n", "<Leader>ez", ":e $ZDOTDIR/.zshrc<CR>")

map("n", "<Leader>jj", "<Cmd>Jumps<CR>")

-- Show file info
map("n", "<C-g>", "2<C-g>")
-- ]]] === Other ===

-- ============== Function Mappings ============= [[[
-- Focus floating window with <C-w><C-w>
fmap {
  "n",
  "<C-w><C-w>",
  function()
    if api.nvim_win_get_config(fn.win_getid()).relative ~= "" then
      cmd [[ wincmd p ]]
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
  { noremap = true, silent = false },
}

-- Allow the use of extended function keys
local fkey = 1
for i = 13, 24, 1 do
  map(
      { "n", "x" }, ("<F%d>"):format(i), ("<S-F%d>"):format(fkey),
      { silent = true }
  )
  fkey = fkey + 1
end

fkey = 1
for i = 25, 36, 1 do
  map(
      { "n", "x" }, ("<F%d>"):format(i), ("<C-F%d>"):format(fkey),
      { silent = true }
  )
  fkey = fkey + 1
end
-- ]]] === Function Mappings ===

return M
