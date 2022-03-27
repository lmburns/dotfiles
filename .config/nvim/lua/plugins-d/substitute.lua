local map = require("common.utils").map

require("substitute").setup()

-- Lua
map("n", "s", ":lua require('substitute').operator()<CR>")
map("n", "ss", ":lua require('substitute').line()<CR>")
map("n", "se", ":lua require('substitute').eol()<CR>")
map("x", "s", ":lua require('substitute').visual()<CR>")

map("n", "sx", ":lua require('substitute.exchange').operator()<CR>")
map("n", "sxx", ":lua require('substitute.exchange').line()<CR>")
map("x", "X", ":lua require('substitute.exchange').visual()<CR>")
map("n", "sxc", ":lua require('substitute.exchange').cancel()<CR>")
