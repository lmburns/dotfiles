local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local coc = require("plugs.coc")
local mpi = require("usr.api")

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "<Leader>r<CR>", "<cmd>w<CR><cmd>FloatermNew --autoclose=0 npx ts-node %<CR>")
-- map("n", "<Leader>r<CR>", "<cmd>w<CR><cmd>FloatermNew --autoclose=0 tsc --target es2020 % && node %:r.js<CR>")
-- map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 npx ts-node %<CR>")

map(
    "n",
    "<Leader>jR",
    function()
        coc.run_command("tsserver.restart")
        coc.run_command("eslint.restart")
    end,
    {desc = "Restart TSServer"}
)

map("n", ";fa", it(coc.run_command, "eslint.executeAutofix"), {desc = "ESLint autofix"})
map("n", ";fd", it(coc.run_command, "tsserver.executeAutofix"), {desc = "TSServer autofix"})
