local utils = require("usr.shared.utils")
local mpi = require("usr.api")
local bmap0 = mpi.bmap0
-- local command = mpi.command

-- local cmd = vim.cmd
local o = vim.opt_local

--  === Options ============================================================ [[[
vim.b.coc_additional_keywords = {"-"}

o.keywordprg = ":RunHelp"
o.comments = {":#"}
o.commentstring = "# %s"
o.formatoptions:append({t = false, c = true, r = true, o = true, q = true, l = true})
-- o.iskeyword = {"@", "48-57", "_", "192-255", "#", "-"}
-- o.iskeyword = {"@", "48-57", "_", "192-255"}

o.autoindent = true
o.smartindent = true
o.cindent = true
-- o.copyindent = true -- copy structure of existing lines indent when autoindenting a new line
o.preserveindent = true -- preserve most indent structure as possible when reindenting line
o.breakindent = true    -- each wrapped line will continue same indent level
o.breakindentopt = {
    "sbr",              -- display 'showbreak' value before applying indent
    "list:2",           -- add additional indent for lines matching 'formatlistpat'
    "min:20",           --- min width kept after breaking line
    "shift:2",          -- all lines after break are shifted N
}
o.linebreak = true      -- lines wrap at words rather than random characters

-- which chars cause break with 'linebreak'
-- vim.o.breakat = "  !@*-+;:,./?"
o.breakat = {
    -- ["\t"] = true,
    [utils.termcodes["<Tab>"]] = true,
    [" "] = true,
    ["!"] = true,
    ["*"] = true,
    ["+"] = true,
    [","] = true,
    ["-"] = true,
    ["."] = true,
    ["/"] = true,
    [":"] = true,
    [";"] = true,
    ["?"] = true,
    ["@"] = true,
}

-- Builtin
-- "s,e0,n0,f0,{0,}0,^0,L-1,:s,=s,l0,b0,gs,hs,N0,E0,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,k0,m0,j0,J0,)20,*70,#0,P0"
o.cinoptions = {
    ">1s", -- any: amount added for "normal" indent
    "L0",  -- placement of jump labels
    "=1s", -- ? case: statement after case label: N chars from indent of label
    "l1",  -- N!=0 case: align w/ case label instead of statement after it on same line
    "b1",  -- N!=0 case: align final "break" w/ case label so it looks like block (0=break cinkeys)
    "g1s", -- ? C++ scope decls: N chars from indent of block they're in
    "h1s", -- ? C++: after scope decl: N chars from indent of label
    "N0",  -- ? C++: inside namespace: N chars extra
    "E0",  -- ? C++: inside linkage specifications: N chars extra
    "p1s", -- ? K&R: function decl: N chars from margin
    "t0",  -- K&R: return type of function decl: N chars from margin
    "i1s", -- ? C++: base class decl/constructor init if they start on newline
    "+0",  -- line continuation: N chars extra inside function; 2*N outside func if line end = '\'
    "c1s", -- comment lines: N chars from comment opener if no other text to align with
    "(1s", -- inside unclosed paren: N chars from line ('sw' for every unclosed paren)
    "u1s", -- same as (N but one level deeper
    "U1",  -- N!=0 : do not ignore nested parens that are on line by themselves
    -- "wN", "WN" --
    "k1s", -- unclosed paren in 'if' 'for' 'while' override '(N'
    "m1",  -- N!=0 line up line starting w/ closing paren w/ 1st char of line w/ opening
    "j1",  -- java: anon classes
    "J1",  -- javascript: object classes
    ")40", -- search for parens N lines away
    "*70", -- search for unclosed comments N lines away
    "#0",  -- N!=0 recognized '#' comments otherwise preproc (toggle this for files)
    "P1",  -- N!=0 format C pragmas
}

-- keys in insert mode that cause reindenting of current line 'cinkeys-format'
-- "0#" "0)"
-- o.cinkeys = {"0{", "0}", "0]", ":", "!^F", "o", "O", "e"}
o.cinkeys:remove({"0)", "0#", "0}"})
-- ]]]

bmap0("n", "J", "gW", {noremap = false, desc = "Join lines & remove backslash"})

bmap0("n", "[a", "[(", {desc = "Prev parenthesis"})
bmap0("n", "]a", "])", {desc = "Next parenthesis"})
bmap0("n", "[b", "[{", {desc = "Prev curly brace"})
bmap0("n", "]b", "]}", {desc = "Next curly brace"})

bmap0("n", "(", "[(", {desc = "Prev parenthesis"})
bmap0("n", ")", "])", {desc = "Next parenthesis"})
bmap0("n", "[[", "[{", {desc = "Prev curly brace"})
bmap0("n", "]]", "]}", {desc = "Next curly brace"})

bmap0("n", "{", "[m", {desc = "Prev start of method"})
bmap0("n", "}", "]m", {desc = "Next start of method"})
bmap0("n", "[f", "[m", {desc = "Prev start of method"})
bmap0("n", "]f", "]m", {desc = "Next start of method"})
bmap0("n", "[F", "[M", {desc = "Prev end of method"})
bmap0("n", "]F", "]M", {desc = "Next end of method"})

bmap0("n", "[d", "[<C-i>", {desc = "Prev line with keyword"})
bmap0("n", "]d", "]<C-i>", {desc = "Next line with keyword"})
bmap0("n", "[r", "[i", {desc = "Disp prev line w/ keyword"})
bmap0("n", "]r", "]i", {desc = "Disp next line w/ keyword"})
bmap0("n", "[x", "tp", {cmd = true, desc = "Tag: previous"})
bmap0("n", "]x", "tn", {cmd = true, desc = "Tag: next"})

bmap0("n", "gD", ":tag <C-r><C-w><CR>", {desc = "Tag: fill stack"})

-- bmap0("n", "", "[*", {desc = "Prev start of '/*' comment"})
-- bmap0("n", "", "]*", {desc = "Next end of '/*' comment"})
-- bmap0("n", "", "[#", {desc = "Prev unmatched #if/#else"})
-- bmap0("n", "", "]#", {desc = "Next unmatched #else/#endif"})

vim.b.match_words =
    [=[\<if\>\ze\s.\{-}\%())\|]]\)\s\={:\<elif\>\ze\s.\{-}\%())\|]]\)\s\={:\<else\>\ze\s\={]=] ..
    [[,\<if\>:\<\%(then\|else\|elif\)\>:\<fi\>]] ..
    [[,\<if\>:\<fi\>]] ..
    [[,\<function\>:\<return\>]] ..
    [[,\<case\>:^\s*([^)]*):\<esac\>]] ..
    [[,\<\%(select\|while\|until\|repeat\|for\%(each\)\=\)\>:\<\%(continue\|break\)\>:\<done\>]]

-- vim.b.match_skip = [[s:comment\|string\|heredoc\|subst]]
vim.b.match_skip = [[s:comment\|string\|heredoc\|subst\(delim\)\@!]]
-- # synIDattr(synID(s:effline('.'),s:effcol('.'),1),'name')=~?'comment\|string\|heredoc\|subst'
vim.b.match_ignorecase = 0

vim.b.undo_ftplugin = "unlet! b:match_ignorecase b:match_words b:match_skip"
