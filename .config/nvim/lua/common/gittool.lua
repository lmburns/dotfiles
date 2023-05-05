local M = {}

local log = require("common.log")
local utils = require("common.utils")

local Job = require("plenary.job")

local cmd = vim.cmd
local fs = vim.fs
local fn = vim.fn
local api = vim.api
local uv = vim.loop
local env = vim.env

---Execute a git command
---@param args table arguments to pass to git
---@param cb fun(v: string)
---@return table? stdout in a table
M.cmd = function(args, cb)
    local root = M.root()
    if #root == 0 then
        utils.cecho("Not in a git directory", "TSNote")
        return
    end
    local stdout, _ =
        Job:new(
        {
            command = "git",
            args = args,
            cwd = root,
            on_exit = function(j, ret)
                if ret == 0 then
                    if cb and type(cb) == "function" then
                        cb(j:result())
                    else
                        return j:result()
                    end
                else
                    utils.cecho("Command returned non-zero exit code", "ErrorMsg")
                end
            end
        }
    ):sync()

    return stdout
end

---Get the root path of the git directory
---@param path? string optional path
---@return string
function M.root(path)
    if path then
        path = fn.fnamemodify(path, ":p")
    else
        local git_dir = vim.b.git_dir or (vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.gitdir)
        if git_dir then
            return (env.GIT_WORK_TREE == env.DOTBARE_TREE and git_dir) or fs.dirname(git_dir)
        else
            path = api.nvim_buf_get_name(0)
        end
    end
    local prev = ""
    local ret = ""
    while path ~= prev do
        prev = path
        path = fs.dirname(path)
        local st = uv.fs_stat(path .. "/.git")
        local stt = st and st.type
        if stt and stt == "directory" or stt == "file" then
            ret = path
            break
        end
    end
    return ret
end

---Change directory to git root
---@param path string? optional path
---@param window boolean?
---@return string git root path
function M.cd_root(path, window)
    local cd = window and "lcd" or "cd"
    local r = M.root(path)
    if r ~= "" then
        cmd(("noa %s %s"):format(cd, r))
    end
    return r
end

function M.root_exe(exec, path)
    local cur_winid
    local old_cwd = uv.cwd()

    local r = M.cd_root(path, true)
    if r ~= "" then
        cur_winid = api.nvim_get_current_win()
    end
    local ok, res
    if type(exec) == "string" then
        ok, res = pcall(cmd, exec)
    elseif type(exec) == "function" then
        ok, res = pcall(exec)
    end
    if not ok then
        log.err(res, {print = true})
    end

    if r ~= "" then
        api.nvim_win_call(
            cur_winid,
            function()
                -- FIX: This works with nvim.ex but not vim.cmd
                cmd(("noa lcd %s"):format(old_cwd))
            end
        )
    end

    return ok and res or nil
end

return M
