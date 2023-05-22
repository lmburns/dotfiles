local mpi = require("usr.api")

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "<Leader>r<CR>", "<cmd>sil! up<CR><cmd>FloatermNew --autoclose=0 g++ % -o %:r && ./%:r <CR>")
map("n", "M", [[<cmd>lua vim.cmd(("%s %s"):format(vim.o.keywordprg, vim.fn.expand("<cword>")))<CR>]])
