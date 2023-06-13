local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local o = vim.opt_local

bmap0("x", ">", ">><Esc>gv", {silent = true})
bmap0("x", "<", "<<<Esc>gv", {silent = true})

o.concealcursor = "c"
-- o.conceallevel = 0
