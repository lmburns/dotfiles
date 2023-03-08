local map = require("common.utils").map

local opt = vim.opt_local
local fn = vim.fn

opt.colorcolumn = "+1"
opt.signcolumn = "yes"
opt.textwidth = 85

-- if expand('%') =~# '^'.$VIMRUNTIME || &readonly
--   " autocmd BufWinEnter <buffer> wincmd L | vertical resize 80
--   finish
-- else
--   setlocal spell spelllang=en_us
-- endif

map("n", "<CR>", "<C-]>", {buffer = true, desc = "Go to definition"})
map("n", "<BS>", "<C-^>", {buffer = true, desc = "Go to previous buffer"})
map("n", "[t", "<C-T>", {buffer = true, desc = "Go to previous tag"})

map(
    "n",
    "o",
    [[:<C-u>call search('''\l\{2,}''', 'w')<CR>]],
    {silent = true, buffer = true, desc = "Next quoted word"}
)
map(
    "n",
    "O",
    [[:<C-u>call search('''\l\{2,}''', 'wb')<CR>]],
    {silent = true, buffer = true, desc = "Prev quoted word"}
)

map(
    "n",
    "]x",
    [[:<C-u>call search('\<<C-R><C-W>\>', 'w')<CR>]],
    {silent = true, buffer = true, desc = "Next occurrence of word"}
)
map(
    "n",
    "[x",
    [[:<C-u>call search('\<<C-R><C-W>\>', 'w')<CR>]],
    {silent = true, buffer = true, desc = "Prev occurrence of word"}
)

map(
    "n",
    "]]",
    [[:<C-u>call search('<Bar>\S\{-}<Bar>', 'w')<CR>]],
    {silent = true, buffer = true, desc = "Next link", nowait = true}
)
map(
    "n",
    "[[",
    [[:<C-u>call search('<Bar>\S\{-}<Bar>', 'wb')<CR>]],
    {silent = true, buffer = true, desc = "Prev link", nowait = true}
)

map(
    "n",
    "}",
    [[<Cmd>norm! }<CR>]],
    {silent = true, buffer = true, desc = "Next blank line"}
)
map(
    "n",
    "{",
    [[<Cmd>norm! {<CR>]],
    {silent = true, buffer = true, desc = "Prev blank line"}
)

--   nnoremap <silent><buffer> s /\|\zs\S\+\ze\|<CR>
--   nnoremap <silent><buffer> S ?\|\zs\S\+\ze\|<CR>

-- map(
--     "n",
--     "]]",
--     [[/\v\<Bar>[^<Bar>]+\<Bar><CR>]],
--     {silent = true, buffer = true, desc = "Next link (highlight)"}
-- )
-- map(
--     "n",
--     "[[",
--     [[?\v\<Bar>[^<Bar>]+\<Bar><CR>]],
--     {silent = true, buffer = true, desc = "Prev link (highlight)"}
-- )

-- map(
--     "n",
--     "]x",
--     "/<C-R><C-W><CR>:nohl<CR>",
--     {silent = true, buffer = true, desc = "Next occurrence of word (highlight)"}
-- )
-- map(
--     "n",
--     "[x",
--     "?<C-R><C-W><CR>:nohl<CR>",
--     {silent = true, buffer = true, desc = "Prev occurrence of word (highlight)"}
-- )
