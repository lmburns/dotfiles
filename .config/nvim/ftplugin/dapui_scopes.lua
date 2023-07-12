local fn, cmd = vim.fn, vim.cmd

local mpi = require("usr.api")
local bmap0 = mpi.bmap0

bmap0("n", "J", [[/▸\\|▾<CR>:nohlsearch<CR>]])
bmap0("n", "K", [[K ?▸\\|▾<CR>:nohlsearch<CR>]])

-- nnoremap <buffer><silent> J /▸\\|▾<CR>:nohlsearch<CR>
-- nnoremap <buffer><silent> K ?▸\\|▾<CR>:nohlsearch<CR>
