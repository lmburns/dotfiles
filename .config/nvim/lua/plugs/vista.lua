local utils = require("common.utils")
local map = utils.map

g.vista_sidebar_position = "topleft vertical"
g["vista#renderer#enable_icon"] = 1

map("n", [[<A-\>]], ":Vista finder coc<CR>")
map("n", [[<A-]>]], ":Vista finder ctags<CR>")

g.vista_fzf_preview = { "down:50%" }
g.vista_fzf_opt = { "--no-border" }
g.vista_default_executive = "coc"
