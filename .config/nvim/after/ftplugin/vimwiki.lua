local utils = require("common.utils")
local map = utils.map

map("x", ">", ">><Esc>gv", {silent = true})
map("x", "<", "<<<Esc>gv", {silent = true})

vim.opt_local.concealcursor = "cv"
