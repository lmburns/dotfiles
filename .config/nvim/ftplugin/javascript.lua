local coc = require("plugs.coc")
local map = require("common.utils").map
local D = require("dev")

map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 node % <CR>")

map(
    "n",
    "<Leader>re",
    function()
        coc.run_command("tsserver.restart")
        coc.run_command("eslint.restart")
    end,
    {buffer = true, desc = "Restart TSServer"}
)

map(
    "n",
    ";fa",
    D.ithunk(coc.run_command, "eslint.executeAutofix"),
    {buffer = true, desc = "ESLint autofix"}
)

map(
    "n",
    ";fd",
    D.ithunk(coc.run_command, "tsserver.executeAutofix"),
    {buffer = true, desc = "TSServer autofix"}
)
