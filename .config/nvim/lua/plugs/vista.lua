local M = {}

local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd

function M.setup()
    g.vista_fzf_preview = {"down:50%"}
    g.vista_fzf_opt = {"--no-border"}
    g.vista_default_executive = "coc"
    g.vista_sidebar_position = "topleft vertical"
    g["vista#renderer#enable_icon"] = 1
end

-- Why does this only work on some projects with coc?
-- If `coc` fails, then `ctags` works

local function init()
    M.setup()

    map("n", [[<A-\>]], ":Vista finder fzf:coc<CR>")
    map("n", [[<A-]>]], ":Vista finder ctags<CR>")
end

init()

return M
