---@module 'plugs.vista'
local M = {}

local map = Rc.api.map

local g = vim.g
local fn = vim.fn

function M.setup()
    -- g.vista_fzf_opt = {"--no-border"}
    g.vista_fzf_preview = {"down:50%"}
    g.vista_keep_fzf_colors = 0
    g.vista_default_executive = "coc"
    g.vista_sidebar_position = "vertical botright"
    g.vista_echo_cursor_strategy = "floating_win"
    g.vista_ignore_kinds = {}
    g["vista#renderer#enable_icon"] = 1
    g["vista#renderer#enable_kind"] = 1
    g.vista_disable_statusline = 1

    g.vista_floating_border = "rounded"

    g.vista_executive_for = {
        vimwiki = "markdown",
        pandoc = "markdown",
        markdown = "toc",
    }

    g["vista#renderer#icons"] = Rc.icons.type
end

function M.vista_project()
   fn["vista#finder#fzf#ProjectRun"]("ctags")
end

local function init()
    M.setup()

    -- augroup("lmb__VistaNearest", {
    --     event = "VimEnter",
    --     pattern = "*",
    --     command = [[call vista#RunForNearestMethodOrFunction()]],
    -- })

    map("n", [[<C-M-S-">]], "Vista!!", {cmd = true, desc = "Toggle Vista window"})
    map("n", [[<M-\>]], ":Vista finder fzf:coc<CR>", {desc = "Vista: coc buf"})
    map("n", [[<M-]>]], ":Vista finder ctags<CR>", {desc = "Vista: ctags buf"})
    map("n", [[<M-S-}>]], M.vista_project, {desc = "Vista: ctags project"})
    map("n", [[<Leader>jp]], M.vista_project, {desc = "Vista: ctags project"})
    -- map("n", [[<C-A-S-}>]], M.vista_project, {desc = "Vista: ctags project"})
end

init()

return M
