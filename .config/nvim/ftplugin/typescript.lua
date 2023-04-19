local coc = require("plugs.coc")
local D = require("dev")
local utils = require("common.utils")
local map = utils.map

map("n", "<Leader>r<CR>", "<cmd>w<CR><cmd>FloatermNew --autoclose=0 npx ts-node %<CR>")
-- map("n", "<Leader>r<CR>", "<cmd>w<CR><cmd>FloatermNew --autoclose=0 tsc --target es2020 % && node %:r.js<CR>")
-- map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 npx ts-node %<CR>")

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

map(
    "n",
    ";fo",
    D.ithunk(coc.run_command, "tsserver.organizeImports"),
    {buffer = true, desc = "TSServer organizeImports"}
)
