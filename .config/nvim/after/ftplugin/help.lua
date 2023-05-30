local mpi = require("usr.api")
local W = mpi.win
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
-- endif

wk.register({gO = "Open TOC"})

map("n", "<CR>", "<C-]>", {desc = "Go to definition"})
map("n", "<BS>", "<C-^>", {desc = "Go to prev buffer"})
map("n", "]f", "ta", { desc = "Go to next tag"})
map("n", "[f", "<C-t>", { desc = "Go to prev tag"})
-- map("n", "]x", [[search('\\<<C-R><C-W>\\>', 'w')]], {ccmd = true, desc = "Next word occurrence"})
-- map("n", "[x", [[search('\<<C-R><C-W>\>', 'w')]], {ccmd = true, desc = "Prev word occurrence"})
map("n", "]x", [[search(expand('<cword>'), 'w')]], {ccmd = true, desc = "Next cword occurrence"})
map("n", "[x", [[search(expand('<cword>'), 'wb')]], {ccmd = true, desc = "Prev cword occurrence"})
map("n", "]X", [[search(expand('<cWORD>'), 'w')]], {ccmd = true, desc = "Next cWORD occurrence"})
map("n", "[X", [[search(expand('<cWORD>'), 'wb')]], {ccmd = true, desc = "Prev cWORD occurrence"})
map("n", "]w", [[search('''\l\{2,}''', 'w')]], {ccmd = true, desc = "Next 'quoted word'"})
map("n", "[w", [[search('''\l\{2,}''', 'wb')]], {ccmd = true, desc = "Prev 'quoted word'"})
map("n", ")", [=[call search('^==============================', 'w')<Bar>norm ]]]=], {cmd = true, desc = "Next heading"})
map("n", "(", [=[call search('^==============================', 'wb')<Bar>norm ]]]=], {cmd = true, desc = "Prev heading"})
map("n", "]]", [[search('\*\S\{-}\*', 'w')]], {ccmd = true, desc = "Next *link*"})
map("n", "[[", [[search('\*\S\{-}\*', 'wb')]], {ccmd = true, desc = "Prev *link*"})
map("n", "}", [[search('<Bar>\S\{-}<Bar>', 'w')]], {ccmd = true, desc = "Next |link|"})
map("n", "{", [[search('<Bar>\S\{-}<Bar>', 'wb')]], {ccmd = true, desc = "Prev |link|"})
map("n", ">", "}", {nowait = true, desc = "Next blank line"})
map("n", "<", "{", {nowait = true, desc = "Prev blank line"})

map(
    "n",
    "gX",
    [[vimgrep /\v.*\*\S+\*$/j %<Bar>copen]],
    {cmd = true, desc = "Helptags to quickfix"}
)
map(
    "n",
    "gx",
    [[lvimgrep /\v.*\*\S+\*$/j %<Bar>lopen]],
    {cmd = true, desc = "Helptags to loclist"}
)

local function format_helptags()
    local view = W.win_save_positions()
    cmd([[%sub/\v(.{-})(\s{2,})(\*.*\*)/\=submatch(1) . repeat(" ", 48 - len(submatch(1))) . submatch(3)]])
    cmd.noh()
    view.restore()
end

map("n", ";ft", format_helptags, {desc = "Format: helptags"})

-- map("n", "]]", [[/\v\<Bar>[^<Bar>]+\<Bar><CR>]], {desc = "Next link (highlight)"})
-- map("n", "[[", [[?\v\<Bar>[^<Bar>]+\<Bar><CR>]], {desc = "Prev link (highlight)"})
-- map("n", "]x", "/<C-R><C-W><CR>:nohl<CR>", {desc = "Next word occurrence (hl)"})
-- map("n", "[x", "?<C-R><C-W><CR>:nohl<CR>", {desc = "Prev word occurrence (hl)"})
