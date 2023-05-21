local mpi = require("common.api")

local function map(...)
    mpi.bmap(0, ...)
end

map(
    "n",
    "<Leader>r<CR>",
    "<cmd>sil! up<CR><cmd>FloatermNew --autoclose=0 gcc -std=gnu2x % -o %< && ./%< <CR>"
)
map(
    "n",
    "M",
    [[<cmd>lua vim.cmd(("%s %s"):format(vim.o.keywordprg, vim.fn.expand("<cword>")))<CR>]]
)
