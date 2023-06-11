local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local command = mpi.command

local o = vim.opt_local
local cmd = vim.cmd

o.keywordprg = ":RunHelp"
o.comments = {":#"}
o.commentstring = "# %s"
o.cinkeys:remove({"0}"})
o.formatoptions:append({t = false, c = true, r = true, o = true, q = true, l = true})
-- o.iskeyword = {"@", "48-57", "_", "192-255", "#", "-"}
-- o.iskeyword = {"@", "48-57", "_", "192-255"}

bmap0("n", "J", "gW", {noremap = false, desc = "Join lines & remove backslash"})

bmap0("n", "[a", "[(", {desc = "Prev parenthesis"})
bmap0("n", "]a", "])", {desc = "Next parenthesis"})
bmap0("n", "[b", "[{", {desc = "Prev curly brace"})
bmap0("n", "]b", "]}", {desc = "Next curly brace"})

bmap0("n", "(", "[(", {desc = "Prev parenthesis"})
bmap0("n", ")", "])", {desc = "Next parenthesis"})
bmap0("n", "[[", "[{", {desc = "Prev curly brace"})
bmap0("n", "]]", "]}", {desc = "Next curly brace"})

-- bmap0("n", "{", "[m", {desc = "Prev start of method"})
-- bmap0("n", "}", "]m", {desc = "Next start of method"})
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

command(
    "RunHelp",
    [[echo system('zsh -c "autoload -Uz run-help; run-help <args> 2>/dev/null"')]],
    {buffer = true, nargs = 1}
)

cmd.compiler("zsh")

vim.b.match_words =
    [[\<if\>:\<elif\>:\<else\>:\<fi\>]] ..
    [[,\<case\>:^\s*([^)]*):\<esac\>]] ..
    [[,\<\%(select\|while\|until\|repeat\|for\%(each\)\=\)\>:\<done\>]]
vim.b.match_skip = [[s:comment\|string\|heredoc\|subst]]
