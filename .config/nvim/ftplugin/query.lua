local D = require("dev")
local it = D.ithunk
local mpi = require("common.api")
local o = vim.opt_local

local map = function(...)
    mpi.bmap(0, ...)
end

o.iskeyword:remove({".", ":", "="})

local dargs = {wrap = true, float = true}
map("n", "[g", it(vim.diagnostic.goto_prev, dargs), {desc = "Prev diagnostic"})
map("n", "]g", it(vim.diagnostic.goto_next, dargs), {desc = "Next diagnostic"})
