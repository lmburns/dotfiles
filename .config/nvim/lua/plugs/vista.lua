---@module 'plugs.vista'
local M = {}

local map = Rc.api.map

local g = vim.g
local fn = vim.fn

function M.setup()
    -- g.vista_fzf_opt = {"--no-border"}
    g.vista_fzf_preview = {"down:50%"}
    g.vista_keep_fzf_colors = 0
    g.vista_floating_border = Rc.style.border_t
    g.vista_echo_cursor = 1
    g.vista_echo_cursor_strategy = "floating_win"
    g.vista_sidebar_position = "vertical botright"
    g.vista_fold_toggle_icons = {"", ""}
    g.vista_icon_indent = {"Ͱ ", "┃ "}
    g.vista_update_on_text_changed = 0
    g.vista_ignore_kinds = {}
    g.vista_disable_statusline = 1
    -- g.vista_log_file = ""

    g["vista#renderer#enable_icon"] = 1
    g["vista#renderer#enable_kind"] = 1
    g["vista#renderer#icons"] = Rc.icons.type

    g.vista_ctags_cmd = {}
    -- g.vista_ctags_project_opts = ""

    if nvim.executable("ripper-tags") then
        -- g.vista_ruby_executive = "ripper-tags"
        g.vista_ctags_cmd.ruby = "ripper-tags --ignore-unsupported-options --recursive"
    end
    if nvim.executable("hasktags") then
        -- g.vista_haskell_executive = "hasktags"
        g.vista_ctags_cmd.haskell = "hasktags -o - -c"
    end

    g.vista_default_executive = "coc"
    g.vista_vimwiki_executive = "markdown"

    g.vista_executive_for = {
        pandoc = "markdown",
        vimwiki = "markdown",
        markdown = "toc",
    }
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
    map("n", [[<M-\>]], "<Cmd>Vista finder fzf:coc<CR>", {desc = "Vista: coc buf"})
    map("n", [[<M-]>]], "<Cmd>Vista finder ctags<CR>", {desc = "Vista: ctags buf"})
    map("n", [[<M-S-}>]], M.vista_project, {desc = "Vista: ctags project"})
    map("n", [[<Leader>jp]], M.vista_project, {desc = "Vista: ctags project"})
    -- map("n", [[<C-A-S-}>]], M.vista_project, {desc = "Vista: ctags project"})
end

init()

return M
