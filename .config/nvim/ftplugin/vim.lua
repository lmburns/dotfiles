local map = require("common.utils").map

map(
    "n",
    "M",
    function()
        vim.cmd(("sil! h %s"):format(vim.fn.expand("<cword>")))
    end,
    {buffer = true}
)
