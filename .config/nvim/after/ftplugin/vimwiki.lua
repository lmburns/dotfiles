local mpi = require("usr.api")
local bmap = mpi.bmap
local o = vim.opt_local

bmap("x", ">", ">><Esc>gv", {silent = true})
bmap("x", "<", "<<<Esc>gv", {silent = true})

o.concealcursor = "cv"
