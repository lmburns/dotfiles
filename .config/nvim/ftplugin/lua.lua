local coc = require("plugs.coc")
local utils = require("common.utils")
local map = utils.map

map("n", "<Leader>tt", "<Plug>PlenaryTestFile")
vim.cmd([[let &l:include = '\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+']])

map(
    "n",
    "<Leader>re",
    function()
        coc.run_command("sumneko-lua.restart", {})
    end,
    {buffer = bufnr, desc = "Reload Luaorkspace"}
)
