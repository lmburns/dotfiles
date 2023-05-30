---@module 'plugs.git'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local log = require("usr.lib.log")

local mpi = require("usr.api")
local map = mpi.map
local augroup = mpi.augroup

local fs = vim.fs
local api = vim.api

-- ╭──────────────────────────────────────────────────────────╮
-- │                          GHLine                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.ghline()
    map("n", "<Leader>go", "<Plug>(gh-repo)", {desc = "Open git repo"})
    map("n", "<Leader>gL", "<Plug>(gh-line)", {desc = "Open git line"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Git Conflict                       │
-- ╰──────────────────────────────────────────────────────────╯
function M.git_conflict()
    local conflict = F.npcall(require, "git-conflict")
    if not conflict then
        return
    end

    conflict.setup({
        default_mappings = false,
        disable_diagnostics = false,     -- will disable diagnostics while conflicted
        highlights = {
            incoming = "DiffText",
            current = "DiffAdd",
            ancestor = "DiffChange",
        },
    })

    augroup(
        "lmb__GitConflict",
        {
            event = "User",
            pattern = "GitConflictDetected",
            command = function(a)
                local bufnr = a.buf
                local bufname = api.nvim_buf_get_name(bufnr)

                local function bmap(...)
                    mpi.bmap(bufnr, ...)
                end

                -- Why does this need to be deferred? There is an error otherwise
                vim.defer_fn(function()
                    log.warn(
                        ("Conflict detected in %s"):format(fs.basename(bufname)),
                        {title = "GitConflict"}
                    )
                end, 100)

                bmap("n", "co", "<Plug>(git-conflict-ours)", {desc = "Conflict: ours"})
                bmap("n", "cb", "<Plug>(git-conflict-base)", {desc = "Conflict: base"})
                bmap("n", "cB", "<Plug>(git-conflict-both)", {desc = "Conflict: both"})
                bmap("n", "ct", "<Plug>(git-conflict-theirs)", {desc = "Conflict: theirs"})
                bmap("n", "c0", "<Plug>(git-conflict-none)", {desc = "Conflict: none"})
                bmap("n", "cq", "GitConflictListQf", {cmd = true, desc = "Conflict: qf"})
                bmap("n", "cq", "GitConflictRefresh", {cmd = true, desc = "Conflict: refresh"})
                bmap("n", "[n", "<Plug>(git-conflict-next-conflict)", {desc = "Next conflict"})
                bmap("n", "]n", "<Plug>(git-conflict-prev-conflict)", {desc = "Prev conflict"}
                )
            end,
        }
    )

    -- map("n", "]n", [[/\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true, desc = "Next conflict"})
    -- map("n", "[n", [[?\(<<<<<<<\|=======\|>>>>>>>\)<cr>]], {silent = true, desc = "Prev conflict"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Projects                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.project()
    -- Detection Methods
    -- =src                => Specify root
    -- plain name          => Has a certain directory or file (may be glob
    -- ^fixtures           => Has certain directory as ancestory
    -- >Latex              => Has a certain directory as direct ancestor
    -- !=extras !^fixtures => Exclude pattern
    local project = F.npcall(require, "project_nvim")
    if not project then
        return
    end

    project.setup({
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        manual_mode = false,
        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
        -- order matters: if one is not detected, the other is used as fallback. You
        -- can also delete or rearangne the detection methods.
        detection_methods = {"lsp", "pattern"},
        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        patterns = {".git", ".hg", ".svn", "Makefile", "package.json", "=src"},
        -- Table of lsp clients to ignore by name
        ignore_lsp = {},
        -- Don't calculate root dir on specific directories
        exclude_dirs = {"~/.local/share/cargo/*"},
        -- Show hidden files in telescope
        show_hidden = false,
        -- When set to false, you will get a message when project.nvim changes your
        -- directory.
        silent_chdir = true,
        -- What scope to change the directory, valid options are
        -- * global (default)   * tab   * win
        scope_chdir = "global",
        -- Path where project.nvim will store the project history for use in
        -- telescope
        datapath = lb.dirs.data,
    })

    require("telescope").load_extension("projects")
    map("n", "<LocalLeader>p", "Telescope projects", {cmd = true})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         LazyGit                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.lazygit()
--     -- require("lazygit.utils").project_root_dir()
--
--     g.lazygit_floating_window_winblend = 0                        -- transparency of floating window
--     g.lazygit_floating_window_corner_chars = {"╭", "╮", "╰", "╯"} -- customize lazygit popup window corner
--     -- g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
--     -- g.lazygit_floating_window_use_plenary = 1 -- use plenary.nvim to manage floating window if available
--     -- g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed
--
--     require("telescope").load_extension("lazygit")
--     map("n", "<Leader>lg", ":LazyGit<CR>", {silent = true})
-- end

return M
