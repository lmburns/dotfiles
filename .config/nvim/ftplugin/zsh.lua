local mpi = require("usr.api")
local command = mpi.command
local cmd = vim.cmd

command(
    "RunHelp",
    [[silent exe ':term zsh -c "autoload -Uz run-help; run-help <args>"']],
    {buffer = true, nargs = 1}
)

cmd.compiler("zsh")
