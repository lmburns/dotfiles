local coc = require("plugs.coc")
local map = require("common.utils").map

map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 node % <CR>")

map(
    "n",
    "<Leader>re",
    function()
        coc.run_command("tsserver.restart", {})
        coc.run_command("eslint.restart", {})
    end,
    {buffer = true, desc = "Restart TSServer"}
)

map(
    "n",
    ";fa",
    function()
        coc.run_command("eslint.executeAutofix")
    end,
    {buffer = true, desc = "ESLint autofix"}
)
