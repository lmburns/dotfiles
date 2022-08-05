local coc = require("plugs.coc")
local utils = require("common.utils")
local map = utils.map

map("n", "<Leader>r<CR>", "<cmd>w<CR><cmd>FloatermNew --autoclose=0 npx ts-node %<CR>")
-- map("n", "<Leader>r<CR>", "<cmd>w<CR><cmd>FloatermNew --autoclose=0 tsc --target es2020 % && node %:r.js<CR>")
-- map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 npx ts-node %<CR>")

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
