local mpi = require("common.api")
local map = mpi.map

map(
    "n",
    "M",
    function()
        vim.cmd(("sil! h %s"):format(vim.fn.expand("<cword>")))
    end,
    {buffer = true}
)
