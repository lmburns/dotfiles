local mpi = require("usr.api")
local o = vim.opt_local

local map = function(...)
    mpi.bmap(0, ...)
end

map("x", ">", ">><Esc>gv", {silent = true})
map("x", "<", "<<<Esc>gv", {silent = true})

o.concealcursor = "c"
o.conceallevel = 0
