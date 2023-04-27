local mpi = require("common.api")
local opt = vim.opt_local

opt.colorcolumn = "+1"
opt.signcolumn = "yes"
opt.textwidth = 85

local bmap = function(...)
    return mpi.bmap(0, ...)
end

-- if expand('%') =~# '^'.$VIMRUNTIME || &readonly
--   " autocmd BufWinEnter <buffer> wincmd L | vertical resize 80
--   finish
-- else
--   setlocal spell spelllang=en_us
-- endif

-- nnoremap <silent><buffer> s /\|\zs\S\+\ze\|<CR>
-- nnoremap <silent><buffer> S ?\|\zs\S\+\ze\|<CR>

bmap("n", "<CR>", "<C-]>", {desc = "Go to definition"})
bmap("n", "<BS>", "<C-^>", {desc = "Go to prev buffer"})

bmap("n", "]f", "<Cmd>norm! ta<CR>", {desc = "Go to next tag"})
bmap("n", "[f", "<C-T>", {desc = "Go to prev tag"})

bmap(
    "n",
    "]x",
    [[:<C-u>call search('\<<C-R><C-W>\>', 'w')<CR>]],
    {silent = true, desc = "Next occurrence of word"}
)
bmap(
    "n",
    "[x",
    [[:<C-u>call search('\<<C-R><C-W>\>', 'w')<CR>]],
    {silent = true, desc = "Prev occurrence of word"}
)

bmap(
    "n",
    "o",
    [[:<C-u>call search('''\l\{2,}''', 'w')<CR>]],
    {silent = true, desc = "Next quoted word"}
)
bmap(
    "n",
    "O",
    [[:<C-u>call search('''\l\{2,}''', 'wb')<CR>]],
    {silent = true, desc = "Prev quoted word"}
)

bmap(
    "n",
    "]]",
    [[:<C-u>call search('<Bar>\S\{-}<Bar>', 'w')<CR>]],
    {silent = true, desc = "Next link", nowait = true}
)
bmap(
    "n",
    "[[",
    [[:<C-u>call search('<Bar>\S\{-}<Bar>', 'wb')<CR>]],
    {silent = true, desc = "Prev link", nowait = true}
)

bmap(
    "n",
    "}",
    [[:<C-u>call search('<Bar>\S\{-}<Bar>', 'w')<CR>]],
    {silent = true, desc = "Next link", nowait = true}
)
bmap(
    "n",
    "{",
    [[:<C-u>call search('<Bar>\S\{-}<Bar>', 'wb')<CR>]],
    {silent = true, desc = "Prev link", nowait = true}
)

bmap(
    "n",
    ">",
    [[<Cmd>norm! }<CR>]],
    {silent = true, desc = "Next blank line", nowait = true}
)
bmap(
    "n",
    "<",
    [[<Cmd>norm! {<CR>]],
    {silent = true, desc = "Prev blank line", nowait = true}
)

-- bmap(
--     "n",
--     "]]",
--     [[/\v\<Bar>[^<Bar>]+\<Bar><CR>]],
--     {silent = true, desc = "Next link (highlight)"}
-- )
-- bmap(
--     "n",
--     "[[",
--     [[?\v\<Bar>[^<Bar>]+\<Bar><CR>]],
--     {silent = true, desc = "Prev link (highlight)"}
-- )

-- bmap(
--     "n",
--     "]x",
--     "/<C-R><C-W><CR>:nohl<CR>",
--     {silent = true, desc = "Next occurrence of word (highlight)"}
-- )
-- bmap(
--     "n",
--     "[x",
--     "?<C-R><C-W><CR>:nohl<CR>",
--     {silent = true, desc = "Prev occurrence of word (highlight)"}
-- )
