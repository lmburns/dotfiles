local M = {}

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup

local hl = require("common.color")

local g = vim.g

function M.setup()
    g.vista_fzf_preview = {"down:50%"}
    g.vista_fzf_opt = {"--no-border"}
    g.vista_default_executive = "coc"
    g.vista_sidebar_position = "vertical botright"
    g.vista_echo_cursor_strategy = "both"
    g["vista#renderer#enable_icon"] = 1

    g.vista_executive_for = {
        vimwiki = "markdown",
        pandoc = "markdown",
        markdown = "toc"
    }
end

-- Why does this only work on some projects with coc?
-- If `coc` fails, then `ctags` works

local function init()
    M.setup()

    hl.link("VistaFloat", "CocFloating")

    augroup(
        "lmb__VistaNearest",
        {
            event = "VimEnter",
            pattern = "*",
            command = [[call vista#RunForNearestMethodOrFunction()]]
        }
    )

    map("n", [[<C-A-S-">]], "Vista!!", {cmd = true, desc = "Toggle Vista window"})
    map("n", [[<A-\>]], ":Vista finder fzf:coc<CR>")
    map("n", [[<A-]>]], ":Vista finder ctags<CR>")
end

init()

return M
