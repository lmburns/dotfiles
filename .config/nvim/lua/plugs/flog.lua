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

local function init()
    has_forest = nvim.executable("git-forest") == 1

    g.flog_default_opts = {max_count = 1000}
    g.flog_use_internal_lua = true

    if has_forest then
        g.flog_build_log_command_fn = "flog#build_git_forest_log_command"
    end

    wk.register({
        ["<Leader>gl"] = {"<Cmd>Flog<CR>", "Flog"},
        ["<Leader>gi"] = {[[<Cmd>lua require('plugs.flog').curr_file()<CR>]], "Flog current file"},
    })
end

init()

return M
