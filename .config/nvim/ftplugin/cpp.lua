local mpi = require("usr.api")
local bmap0 = mpi.bmap0

bmap0("n", "<Leader>r<CR>", "<cmd>sil! up<CR><cmd>FloatermNew --autoclose=0 g++ % -o %:r && ./%:r <CR>")
bmap0("n", "M", [[<cmd>lua vim.cmd(("%s %s"):format(vim.o.keywordprg, vim.fn.expand("<cword>")))<CR>]])
