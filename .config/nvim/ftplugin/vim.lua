local mpi = require("usr.api")
local cmd = vim.cmd
local fn = vim.fn
local o = vim.opt_local

o.iskeyword:remove("#")

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
