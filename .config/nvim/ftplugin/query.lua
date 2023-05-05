local D = require("dev")
local mpi = require("common.api")

local bmap = function(...)
    mpi.bmap(0, ...)
end

local dargs = {wrap = true, float = true}
bmap("n", "[g", D.ithunk(vim.diagnostic.goto_prev, dargs), {desc = "Prev diagnostic"})
bmap("n", "]g", D.ithunk(vim.diagnostic.goto_next, dargs), {desc = "Next diagnostic"})
