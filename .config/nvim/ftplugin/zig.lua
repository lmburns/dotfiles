local mpi = require("usr.api")
local bmap0 = mpi.bmap0

bmap0("n", "<Leader>r<CR>", "<cmd>sil! up<CR><cmd>FloatermNew --autoclose=0 zig run ./%<CR>")
