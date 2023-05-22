local mpi = require("usr.api")

local function map(...)
    mpi.bmap(0, ...)
end

map("n", "J", [[/▸\\|▾<CR>:nohlsearch<CR>]])
map("n", "K", [[K ?▸\\|▾<CR>:nohlsearch<CR>]])

-- nnoremap <buffer><silent> J /▸\\|▾<CR>:nohlsearch<CR>
-- nnoremap <buffer><silent> K ?▸\\|▾<CR>:nohlsearch<CR>
