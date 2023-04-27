local mpi = require("common.api")
local map = mpi.map

map("x", ">", ">><Esc>gv", {silent = true})
map("x", "<", "<<<Esc>gv", {silent = true})

vim.opt_local.concealcursor = "cv"
