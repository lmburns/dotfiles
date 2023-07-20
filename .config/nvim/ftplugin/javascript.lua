local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local coc = require("plugs.coc")
local mpi = require("usr.api")
local bmap0 = mpi.bmap0
-- local o = vim.opt_local

bmap0("n", "<Leader>r<CR>", "<Cmd>FloatermNew --autoclose=0 node %<CR>", {desc = "Run: node"})

bmap0(
    "n",
    "<Leader>jR",
    function()
        coc.run_command("tsserver.restart")
        coc.run_command("eslint.restart")
    end,
    {desc = "Restart TSServer"}
)

bmap0("n", ";fa", it(coc.run_command, "eslint.executeAutofix"), {desc = "ESLint autofix"})
bmap0("n", ";fd", it(coc.run_command, "tsserver.executeAutofix"), {desc = "TSServer autofix"})
