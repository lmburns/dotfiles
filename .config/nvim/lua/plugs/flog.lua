---@module 'plugs.flog'
local M = {}

local wk = require("which-key")

local g = vim.g
local cmd = vim.cmd

local has_forest

function M.curr_file()
    if has_forest then
        g.flog_build_log_command_fn = nil
    end
    cmd("Flog -raw-args=--follow -path=%")
    if has_forest then
        g.flog_build_log_command_fn = "flog#build_git_forest_log_command"
    end
end

-- Autocmds
-- FlogUpdate                On updating a |:Flog| window.
-- FlogSideWinSetup          On initializing any |flog-side-window|.
-- FlogTmpSideWinSetup       On initializing a temporary |flog-side-window|. Called after |User_FlogSideWinSetup|.
-- FlogNonTmpSideWinSetup    On initializing a non-temporary |flog-side-window|. Called after |User_FlogSideWinSetup|.

local function init()
    has_forest = nvim.executable("git-forest") == 1

    g.flog_default_opts = {max_count = 1000}
    g.flog_use_internal_lua = true
    -- g.flog_override_default_mappings = {"gg", "G", "<C-d>", "<C-u>", "<C-o>", "<C-i>"}

    if has_forest then
        g.flog_build_log_command_fn = "flog#build_git_forest_log_command"
    end

    wk.register({
        ["<Leader>gl"] = {"<Cmd>Flog<CR>", "Flog"},
        ["<Leader>gg"] = {"<Cmd>Flogsplit -path=%<CR>", "Flog: split current file"},
        ["<Leader>gi"] = {[[<Cmd>lua require('plugs.flog').curr_file()<CR>]], "Flog: current file"},
        --
        ["<Leader>yl"] = {"<Cmd>Flog<CR>", "Flog: tab all"},
        ["<Leader>yL"] = {"<Cmd>Flogsplit<CR>", "Flog: split all"},
        ["<Leader>yi"] = {[[<Cmd>lua require('plugs.flog').curr_file()<CR>]], "Flog: current file"},
        ["<Leader>yI"] = {"<Cmd>Flogsplit -path=%<CR>", "Flog: split current file"},
    })

    --   %%                    A literal "%" character.
    --   %h                    The hash of the commit under the cursor, if any.
    --   %H                    Same as %h, but do not set |flog-'!|.
    --   %(h'x)                The hash at the given commit mark "x".
    --   %b                    The first branch of the commit under the cursor, if any
    --   %(b'x)                The branch at the given commit mark "x".
    --   %l                    The first branch of the commit under the cursor, if any.
    --   %(l'x)                The local branch at the given mark "x".
    --   %p                    If |:Flog-limit| is set, resolves to the path passed to the limit, escaping it.
    --   %t                    A tree for the current index. When this is used, a new
end

init()

return M
