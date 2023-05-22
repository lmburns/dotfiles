local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local mpi = require("usr.api")
local o = vim.opt_local

local map = function(...)
    mpi.bmap(0, ...)
end

o.iskeyword:remove({".", ":", "="})

local dargs = {wrap = true, float = true}
map("n", "[g", it(vim.diagnostic.goto_prev, dargs), {desc = "Prev diagnostic"})
map("n", "]g", it(vim.diagnostic.goto_next, dargs), {desc = "Next diagnostic"})
