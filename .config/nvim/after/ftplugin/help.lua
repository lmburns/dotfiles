local W = Rc.api.win
local bmap0 = Rc.api.bmap0
local o = vim.opt_local

local wk = require("which-key")

o.colorcolumn = "+1"
o.signcolumn = "yes"
o.textwidth = 85

-- if expand('%') =~# '^'.$VIMRUNTIME || &readonly
--   " autocmd BufWinEnter <buffer> wincmd L | vertical resize 80
--   finish
-- endif

wk.register({gO = "Open TOC"}, {mode = "n", buffer = 0})

bmap0("n", "<CR>", "<C-]>", {desc = "Go to definition"})
bmap0("n", "<BS>", "<C-^>", {desc = "Go to prev buffer"})
bmap0("n", "]f", "ta", { desc = "Go to next tag"})
bmap0("n", "[f", "<C-t>", { desc = "Go to prev tag"})
-- bmap0("n", "]x", [[search('\\<<C-R><C-W>\\>', 'w')]], {ccmd = true, desc = "Next word occurrence"})
-- bmap0("n", "[x", [[search('\<<C-R><C-W>\>', 'w')]], {ccmd = true, desc = "Prev word occurrence"})
bmap0("n", "]x", [[search('\C\<'.expand('<cword>').'\>', 'w')]], {ccmd = true, desc = "Next <cword> occurrence"})
bmap0("n", "[x", [[search('\C\<'.expand('<cword>').'\>', 'wb')]], {ccmd = true, desc = "Prev <cword> occurrence"})
bmap0("n", "]X", [[search('\<'.expand('<cWORD>').'\>', 'w')]], {ccmd = true, desc = "Next <cWORD> occurrence"})
bmap0("n", "[X", [[search('\<'.expand('<cWORD>').'\>', 'wb')]], {ccmd = true, desc = "Prev <cWORD> occurrence"})
bmap0("n", "]W", [[search('\<'.expand('<cexpr>').'\>', 'w')]], {ccmd = true, desc = "Next <cexpr> occurrence"})
bmap0("n", "[W", [[search('\<'.expand('<cexpr>').'\>', 'wb')]], {ccmd = true, desc = "Prev <cexpr> occurrence"})
bmap0("n", "]w", [[search('''\l\{2,}''', 'w')]], {ccmd = true, desc = "Next 'quoted word'"})
bmap0("n", "[w", [[search('''\l\{2,}''', 'wb')]], {ccmd = true, desc = "Prev 'quoted word'"})
-- bmap0("n", ")", [=[call search('^==============================', 'w')<Bar>norm ]]]=], {cmd = true, desc = "Next heading"})
-- bmap0("n", "(", [=[call search('^==============================', 'wb')<Bar>norm ]]]=], {cmd = true, desc = "Prev heading"})
bmap0("n", ")", [=[call search('^==============================', 'w')]=], {cmd = true, desc = "Next heading"})
bmap0("n", "(", [=[call search('^==============================', 'wb')]=], {cmd = true, desc = "Prev heading"})
bmap0("n", "]]", [[search('\*\S\{-}\*', 'w')]], {ccmd = true, desc = "Next *link*"})
bmap0("n", "[[", [[search('\*\S\{-}\*', 'wb')]], {ccmd = true, desc = "Prev *link*"})
bmap0("n", "}", [[search('<Bar>\S\{-}<Bar>', 'w')]], {ccmd = true, desc = "Next |link|"})
bmap0("n", "{", [[search('<Bar>\S\{-}<Bar>', 'wb')]], {ccmd = true, desc = "Prev |link|"})
bmap0("n", ">", "}", {nowait = true, desc = "Next blank line"})
bmap0("n", "<", "{", {nowait = true, desc = "Prev blank line"})

bmap0(
    "n",
    "gX",
    [[vimgrep /\v.*\*\S+\*$/j %<Bar>copen]],
    {cmd = true, desc = "Helptags to quickfix"}
)
bmap0(
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

bmap0("n", ";ft", format_helptags, {desc = "Format: helptags"})

-- bmap0("n", "]]", [[/\v\<Bar>[^<Bar>]+\<Bar><CR>]], {desc = "Next link (highlight)"})
-- bmap0("n", "[[", [[?\v\<Bar>[^<Bar>]+\<Bar><CR>]], {desc = "Prev link (highlight)"})
-- bmap0("n", "]x", "/<C-R><C-W><CR>:nohl<CR>", {desc = "Next word occurrence (hl)"})
-- bmap0("n", "[x", "?<C-R><C-W><CR>:nohl<CR>", {desc = "Prev word occurrence (hl)"})
