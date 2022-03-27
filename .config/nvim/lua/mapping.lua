local utils = require("common.utils")
local map = utils.map

-- ============== General Mappings ============== [[[
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")

map("n", "q:", "<Nop>")
map("n", "q/", "<Nop>")
map("n", "q?", "<Nop>")
map("n", ";w", ":update<CR>")

map("n", ";q", ":q<CR>")
map("n", "q;", ":q<CR>")
map("n", "Q:", ":q", { noremap = false })

-- Replace command history with quit
-- map q: :MinimapToggle<CR> :q<CR>
-- map q: :q<CR>

cmd([[ command! -bang -nargs=* Q q ]])

-- Use qq to record, q to stop, Q to play a macro
map("n", "Q", "@q")
map("v", "Q", ":normal @q")

-- Easier navigation in normal / visual / operator pending mode
map("n", "gkk", "{")
map("n", "gjj", "}")
map("n", "H", "g^")
map("x", "H", "g^")
map("n", "L", "g_")
map("x", "L", "g_")

-- Save write
-- map("n", "<C-s>", ":update<CR>")
-- Save & quit
-- map("n", "<C-x>", ":x<CR>")

-- Save with root
map("c", "w!!", "execute ':silent w !sudo tee % > /dev/null' <bar> edit!")
map("c", "W!!", "w !sudo tee % >/dev/null<CR>")

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
map("n", "<Leader>sc", [[s/\v<(\w)(\S*)/\u\1\L\2/g<CR>:nohlsearch<CR>]])

-- Use tab and shift tab to indent and de-indent code
map("n", "<Tab>", ">>")
map("n", "<S-Tab>", "<<")
map("v", "<Tab>", ">><Esc>gv")
map("v", "<S-Tab>", "<<<Esc>gv")
map("i", "<S-Tab>", "<C-d>")

-- Don't lose selection when shifting sidewards
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Use `u` to undo, use `U` to redo, mind = blown
map("n", "U", "<C-r>")

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
map("n", "gp", [[ '`[' . strpart(getregtype(), 0, 1) . '`]' ]], { expr = true })
-- Select characters of line (no new line)
map("n", "vv", "^vg_")
-- Make visual yanks place the cursor back where started
map("v", "y", "ygv<Esc>")
-- Insert a space after current character
-- map("n", "<Leader>sa", 'a<Space><Esc>h')

-- Paste over selected text
map("x", "p", "_c<Esc>p")

-- Adds a space  to left of cursor
map("n", "zl", "i <Esc>l", { silent = true })

-- Inserts a line above or below
map("n", "zj", "printf('m`%so<ESC>``', v:count1)", { expr = true })
map("n", "zk", "printf('m`%sO<ESC>``', v:count1)", { expr = true })
map("n", "oo", "o<Esc>k", { silent = true })
map("n", "OO", "O<Esc>j", { silent = true })

-- Move through folded lines
map("n", "j", "(v:count == 0 ? 'gj' : 'j')", { expr = true })
map("n", "k", "(v:count == 0 ? 'gk' : 'k')", { expr = true })
-- map("n", "j", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj']], {expr=true})
-- map("n", "k", [[v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk']], {expr=true})

-- Move selected text up down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
-- map("i", "<C-J>", "<Esc>:m .+1<CR>==a")
-- map("i", "<C-K>", "<Esc>:m .-2<CR>==a")

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
map("", "'", "`")
map("", "`", "'")

-- Buffer switching
map("n", "gt", ":bnext<CR>")
map("n", "gT", ":bprevious<CR>")
map("n", "<C-S-Right>", ":bnext<CR>")
map("n", "<C-S-Left>", ":bprevious<CR>")

-- New buffer
map("n", "<Leader>bn", ":enew<CR>")
-- Close buffer
map("n", "<Leader>bq", ":bp <Bar> bd! #<CR>")
-- Close all buffers
map("n", "<Leader>bQ", ":bufdo bd! #<CR>")
-- List buffers
map("n", "<Leader>bl", ":Telescope buffers<CR>", { silent = true })

-- Resize windows
-- map("n", "+", ":vertical resize +5<CR>")
-- map("n", "-", ":vertical resize -5<CR>")
-- map("n", "s+", ":resize +5<CR>")
-- map("n", "s-", ":resize -5<CR>")

map("", "<C-Up>", ":resize +1<CR>", { noremap = false })
map("", "<C-Up>", ":resize +1<CR>", { noremap = false })
map("", "<C-Right>", ":vertical resize +1<CR>", { noremap = false })
map("", "<C-Left>", ":vertical resize +1<CR>", { noremap = false })

-- Change vertical to horizontal
map("n", "<Leader>w-", "<C-w>t<C-w>K")
-- Change horizontal to vertical
map("n", [[<Leader>w\]], "<C-w>t<C-w>H")

-- perform dot commands over visual blocks
map("v", ".", ":normal .<CR>")

-- Change tabs
map("n", "<Leader>nt", ":setlocal noexpandtab<CR>")
map("x", "<Leader>re", ":retab!<CR>")
-- Close quickfix
map("n", "<Leader>cc", ":cclose<CR>")

-- Keep focused in center of screen when searching
-- map("n", "n", "(v:searchforward ? 'nzzzv' : 'Nzzzv')", { expr = true })
-- map("n", "N", "(v:searchforward ? 'Nzzzv' : 'nzzzv')", { expr = true })

-- Insert a place holder
map("i", ",p", "<++>")

-- Jump to the next '<++>' and edit it
map("n", "<Leader>fe", "<Esc>/<++><CR>:nohlsearch<CR>c4l", { silent = true })
map("n", "<Leader>fi", "<Esc>/<++><CR>:nohlsearch<CR>", { silent = true })
map("i", ";f", "<Esc>/<++><CR>:nohlsearch<CR>\"_c4l", { silent = true })

-- ]]] === General Mappings ===

-- ================== Spelling ================== [[[
map("n", "<Leader>ss", ":setlocal spell!<CR>")
map("n", "<Leader>sn", "]s")
map("n", "<Leader>sp", "[s")
map("n", "<Leader>sa", "zg")
map("n", "<Leader>s?", "z=")
map("n", "<Leader>su", "zuw")
map("n", "<Leader>su1", "zug")
-- ]]] === Spelling ===

-- ==================== Other =================== [[[
map("n", "F2", ":set nowrap!<CR>", { silent = true })
map("n", "F3", ":set relativenumber!<CR>", { silent = true })
-- ]]] === Other ===
