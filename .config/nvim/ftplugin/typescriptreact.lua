local mpi = require("common.api")
local map = mpi.map
local D = require("dev")
local coc = require("plugs.coc")

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
