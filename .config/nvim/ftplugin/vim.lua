local mpi = require("common.api")
local cmd = vim.cmd
local fn = vim.fn

local function map(...)
    mpi.bmap(0, ...)
end

map(
    "n",
    "M",
    function()
        cmd.help({fn.expand("<cword>"), mods = {emsg_silent = true}})
    end,
    {desc = "Open help with <cword>"}
)
