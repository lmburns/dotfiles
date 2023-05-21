local mpi = require("common.api")
local wk = require("which-key")
local o = vim.opt_local

o.colorcolumn = "+1"
o.signcolumn = "yes"
o.textwidth = 85

local map = function(...)
    return mpi.bmap(0, ...)
end

-- if expand('%') =~# '^'.$VIMRUNTIME || &readonly
--   " autocmd BufWinEnter <buffer> wincmd L | vertical resize 80
--   finish
-- else
--   setlocal spell spelllang=en_us
-- endif

wk.register({gO = "Open TOC"})

map("n", "<CR>", "<C-]>", {desc = "Go to definition"})
map("n", "<BS>", "<C-^>", {desc = "Go to prev buffer"})

map("n", "]f", "ta", {desc = "Go to next tag"})
map("n", "[f", "<C-T>", {desc = "Go to prev tag"})

map("n", "]x", [[search('\<<C-R><C-W>\>', 'w')]], {ccmd = true, desc = "Next word occurrence"})
map("n", "[x", [[search('\<<C-R><C-W>\>', 'w')]], {ccmd = true, desc = "Prev word occurrence"})

-- map("n", "o", [[search('''\l\{2,}''', 'w')]], {ccmd = true, desc = "Next quoted word"})
-- map("n", "O", [[search('''\l\{2,}''', 'wb')]], {ccmd = true, desc = "Prev quoted word"})

-- map("n", "]d", [[search('''\l\{2,}''', 'w')]], {ccmd = true, desc = "Next 'quoted word'"})
-- map("n", "[d", [[search('''\l\{2,}''', 'wb')]], {ccmd = true, desc = "Prev 'quoted word'"})
map("n", ")", [[search('''\l\{2,}''', 'w')]], {ccmd = true, desc = "Next 'quoted word'"})
map("n", "(", [[search('''\l\{2,}''', 'wb')]], {ccmd = true, desc = "Prev 'quoted word'"})

-- map("n", "]a", [[search('\*\S\{-}\*', 'w')]], {ccmd = true, desc = "Next *link*"})
-- map("n", "[a", [[search('\*\S\{-}\*', 'wb')]], {ccmd = true, desc = "Prev *link*"})
map("n", "]]", [[search('\*\S\{-}\*', 'w')]], {ccmd = true, desc = "Next *link*"})
map("n", "[[", [[search('\*\S\{-}\*', 'wb')]], {ccmd = true, desc = "Prev *link*"})

map("n", "}", [[search('<Bar>\S\{-}<Bar>', 'w')]], {ccmd = true, desc = "Next |link|"})
map("n", "{", [[search('<Bar>\S\{-}<Bar>', 'wb')]], {ccmd = true, desc = "Prev |link|"})

map("n", ">", "}", {nowait = true, desc = "Next blank line"})
map("n", "<", "{", {nowait = true, desc = "Prev blank line"})

-- map("n", "]]", [[/\v\<Bar>[^<Bar>]+\<Bar><CR>]], {desc = "Next link (highlight)"})
-- map("n", "[[", [[?\v\<Bar>[^<Bar>]+\<Bar><CR>]], {desc = "Prev link (highlight)"})
-- map("n", "]x", "/<C-R><C-W><CR>:nohl<CR>", {desc = "Next word occurrence (hl)"})
-- map("n", "[x", "?<C-R><C-W><CR>:nohl<CR>", {desc = "Prev word occurrence (hl)"})
