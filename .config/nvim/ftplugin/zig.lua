local mpi = require("common.api")

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "<Leader>r<CR>", "<cmd>sil! up<CR><cmd>FloatermNew --autoclose=0 zig run ./%<CR>")
