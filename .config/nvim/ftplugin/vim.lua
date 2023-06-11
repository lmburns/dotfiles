local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local cmd = vim.cmd
local fn = vim.fn
local o = vim.opt_local

-- o.iskeyword:remove("#")

bmap0(
    "n",
    "M",
    function()
        cmd.help({fn.expand("<cword>"), mods = {emsg_silent = true}})
    end,
    {desc = "Open help with <cword>"}
)
