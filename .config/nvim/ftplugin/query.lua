local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local o = vim.opt_local

o.iskeyword:remove({".", ":", "="})

local dargs = {wrap = true, float = true}
bmap0("n", "[g", it(vim.diagnostic.goto_prev, dargs), {desc = "Prev diagnostic"})
bmap0("n", "]g", it(vim.diagnostic.goto_next, dargs), {desc = "Next diagnostic"})
