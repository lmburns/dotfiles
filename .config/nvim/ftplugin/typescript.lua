local coc = require("plugs.coc")
local utils = require("common.utils")
local map = utils.map

map(
    "n",
    "<Leader>re",
    function()
        coc.run_command("tsserver.restart", {})
        coc.run_command("eslint.restart", {})
    end,
    {buffer = true, desc = "Restart TSServer"}
)
