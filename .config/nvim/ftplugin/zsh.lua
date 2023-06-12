local mpi = require("usr.api")
local command = mpi.command
local cmd = vim.cmd

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
