local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local coc = require("plugs.coc")
local mpi = require("usr.api")
local o = vim.opt_local

o.cms = "// %s"

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 node % <CR>")

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
