---@module 'plugs.vista'
local M = {}

local bmap = Rc.api.bmap
local map = Rc.api.map

local api = vim.api
local g = vim.g
local fn = vim.fn

function M.setup()
    -- g.vista_fzf_opt = {"--no-border"}
    g.vista_fzf_preview = {"down:50%"}
    g.vista_keep_fzf_colors = 0
    g.vista_floating_border = Rc.style.border_t
    g.vista_echo_cursor = 1
    g.vista_echo_cursor_strategy = "echo"
    -- g.vista_echo_cursor_strategy = "floating_win"
    g.vista_sidebar_position = "vertical botright"
    g.vista_fold_toggle_icons = {"", ""}
    g.vista_icon_indent = {"Ͱ ", "┃ "}
    g.vista_update_on_text_changed = 0
    -- g.vista_find_absolute_nearest_method_or_function = 1
    g.vista_ignore_kinds = {"variables", "variable"}
    g.vista_disable_statusline = 1
    g.vista_log_file = ""

    g["vista#renderer#enable_icon"] = 1
    g["vista#renderer#enable_kind"] = 1
    g["vista#renderer#icons"] = Rc.icons.type

    -- g.vista_ctags_cmd = {}
    -- g.vista_ctags_project_opts = ""

    g.vista_default_executive = "coc"
    g.vista_vimwiki_executive = "markdown"

    g.vista_executive_for = {
        pandoc = "markdown",
        vimwiki = "markdown",
        markdown = "toc",
        zsh = "ctags",
        sh = "ctags",
        tmux = "ctags",
    }

    if nvim.executable("ripper-tags") then
        g.vista_executive_for.ruby = "ripper-tags"
        -- g.vista_ruby_executive = "ripper-tags"
        -- g.vista_ctags_cmd.ruby = "ripper-tags --ignore-unsupported-options --recursive"
    end
    if nvim.executable("hasktags") then
        g.vista_executive_for.haskell = "hasktags"
        -- g.vista_haskell_executive = "hasktags"
        -- g.vista_ctags_cmd.haskell = "hasktags -o - -c"
    end
end

function M.vista_project()
    fn["vista#finder#fzf#ProjectRun"]("ctags")
end

function M.vista_functions()
    g.vista_ignore_kinds = {"variable"}
    fn["vista#finder#fzf#Run"]("ctags")
    vim.defer_fn(function() g.vista_ignore_kinds = {} end, 500)
end

-- FIX: don't know if sidebar works with what you pick
function M.vista_functions_sidebar()
    g.vista_ignore_kinds = {"variable"}
    fn["vista#sidebar#Toggle"]()
    vim.defer_fn(function() g.vista_ignore_kinds = {} end, 500)
end

local function setup_autocmds()
    nvim.autocmd.lmb__Vista = {
        event = "FileType",
        pattern = {"vista", "vista_kind"},
        command = function(a)
            bmap(a.buf, "n", "/", function()
                api.nvim_buf_call(fn.bufnr("#"), function()
                    fn["vista#finder#fzf#Run"]("ctags")
                end)
                Rc.api.win.win_focus_floating()
            end, {desc = "Vista: ctags fzf"})

            bmap(a.buf, "n", "?", function()
                api.nvim_buf_call(fn.bufnr("#"), function()
                    fn["vista#finder#fzf#Run"]("coc")
                end)
                Rc.api.win.win_focus_floating()
            end, {desc = "Vista: coc fzf"})

            bmap(a.buf, "n", "P", function()
                api.nvim_buf_call(fn.bufnr("#"), function()
                    fn["vista#finder#fzf#ProjectRun"]("ctags")
                end)
                Rc.api.win.win_focus_floating()
            end, {desc = "Vista: ctags fzf project"})
        end,
    }

    -- augroup("lmb__VistaNearest", {
    --     event = "VimEnter",
    --     pattern = "*",
    --     command = [[call vista#RunForNearestMethodOrFunction()]],
    -- })
end

local function init()
    M.setup()
    setup_autocmds()

    map("n", [[<C-M-S-">]], "Vista!!", {cmd = true, desc = "Toggle Vista window"})
    map("n", [[<M-\>]], "<Cmd>Vista finder fzf:coc<CR>", {desc = "Vista: coc buf"})
    map("n", [[<M-]>]], "<Cmd>Vista finder ctags<CR>", {desc = "Vista: ctags buf"})
    map("n", [[<M-S-}>]], M.vista_project, {desc = "Vista: fzf ctags project"})
    map("n", [[<Leader>jp]], M.vista_project, {desc = "Vista: fzf ctags project"})
    map("n", [[<Leader>ju]], M.vista_functions, {desc = "Vista: fzf ctags funcs"})
    map("n", [[<Leader>jU]], M.vista_functions_sidebar, {desc = "Vista: sidebar ctags funcs"})
    -- map("n", [[<C-A-S-}>]], M.vista_project, {desc = "Vista: ctags project"})
end

init()

return M
