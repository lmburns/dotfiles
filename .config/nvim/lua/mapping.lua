local utils = require("common.utils")
local map = utils.map

-- ============== General Mappings ============== [[[
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
map("n", "<C-s>", ":update<CR>")
-- Save & quit
-- map("n", "<C-x>", ":x<CR>")

-- Save with root
map("c", "w!!", "execute ':silent w !sudo tee % > /dev/null' <bar> edit!")
map("c", "W!!", "w !sudo tee % >/dev/null<CR>")

-- Navigate merge conflict markers
map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], { silent = true })
map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], { silent = true })

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
