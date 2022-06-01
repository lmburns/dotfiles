local map = require("common.utils").map

map("n", "<Leader>r<CR>", "<cmd>sil! up<CR><cmd>FloatermNew --autoclose=0 zig run ./%<CR>")
