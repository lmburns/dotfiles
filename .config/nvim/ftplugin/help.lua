local map = require("common.utils").map
local opt = vim.opt_local

opt.colorcolumn = "+1"
opt.signcolumn = "yes"
opt.textwidth = 85

map("n", "<C-M-i>", [[:<C-u>call search('<Bar>.\{-}<Bar>', 'w')<CR>]], {buffer = true})
map("n", "<C-M-o>", [[:<C-u>call search('<Bar>.\{-}<Bar>', 'wb')<CR>]], {buffer = true})

map("n", "<CR>", "<C-]>", {buffer = true})
-- Go to next occurrence of word
map("n", "<A-CR>", "/<C-R><C-W><CR>:nohl<CR>", {buffer = true})

-- Next link
map("n", "<A-]>", [[/\v\<Bar>[^<Bar>]+\<Bar><CR>]], {buffer = true})
map("n", "<A-[>", [[?\v\<Bar>[^<Bar>]+\<Bar><CR>]], {buffer = true})
