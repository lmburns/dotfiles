---@description: Utility functions that interact with the filesystem
---@module "common.utils.fs"
local M = {}

local utils = require("common.utils")
local uva = require("uva")
local async = require("async")

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local F = vim.F

--  ╭──────────────────────────────────────────────────────────╮
--  │                           Sync                           │
--  ╰──────────────────────────────────────────────────────────╯

M.sync = {}

---Write a file using libuv
---@param path string
---@param data string
---@param sync? boolean
M.sync.write_file = function(path, data, sync)
    local path_ = path .. "_"
    if sync then
        local fd = assert(uv.fs_open(path_, "w", 438))
        assert(uv.fs_write(fd, data))
        assert(uv.fs_close(fd))
        uv.fs_rename(path_, path)
    else
        uv.fs_open(
            path_,
            "w",
            438,
            function(err_open, fd)
                assert(not err_open, err_open)
                uv.fs_write(
                    fd,
                    data,
                    -1,
                    function(err_write)
                        assert(not err_write, err_write)
                        uv.fs_close(
                            fd,
                            function(err_close, succ)
                                assert(not err_close, err_close)
                                if succ then
                                    -- may rename by other syn write
                                    uv.fs_rename(
                                        path_,
                                        path,
                                        function()
                                        end
                                    )
                                end
                            end
                        )
                    end
                )
            end
        )
    end
end

---@param path string
---@return uv_fs_t|string
---@return uv.aliases.fs_stat_table?
M.sync.read_file = function(path)
    -- tonumber(444, 8) == 292
    local fd = assert(uv.fs_open(fn.expand(path), "r", 292))
    local stat = assert(uv.fs_fstat(fd))
    local buffer = assert(uv.fs_read(fd, stat.size, 0))
    uv.fs_close(fd)
    return buffer, stat
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Async                           │
--  ╰──────────────────────────────────────────────────────────╯

M.async = {}

---Read a file asynchronously (using Promises)
---@param path string
---@return Promise_t<string> data File data
M.read_file = function(path)
    -- tonumber(666, 8)
    return async(
        function()
            local fd = await(uva.open(fn.expand(path), "r", 438))
            local stat = await(uva.fstat(fd))
            local data = await(uva.read(fd, stat.size, 0))
            await(uva.close(fd))
            return data
        end
    )
end

---Write to a file asynchronously (using Promises)
---@param path string
---@param data string
---@return Promise
M.write_file = function(path, data)
    return async(
        function()
            local p = path .. ".__"
            local fd = await(uva.open(p, "w", 438))
            await(uva.write(fd, data))
            await(uva.close(fd))
            pcall(await, uva.rename(p, path))
        end
    )
end

---Copy a file
---@param path string
---@param new_path string
---@return Promise
M.copy_file = function(path, new_path)
    return async(
        function()
            local p = new_path .. ".__"
            await(uva.copyfile(path, p))
            pcall(await, uva.rename(p, new_path))
        end
    )
end

---Stat a given file
---@param path string
---@return Promise_t<uv.aliases.fs_stat_table> stat Stat table
M.stat = function(path)
    return async(
        function()
            local fd = await(uva.open(fn.expand(path), "r", 438))
            local stat = await(uva.fstat(fd))
            await(uva.close(fd))
            return stat
        end
    )
end

M.async = {
    read_file = M.read_file,
    write_file = M.write_file,
    stat = M.stat,
}

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Other                           │
--  ╰──────────────────────────────────────────────────────────╯

---Follow a symbolic link
---@param fname string filename to follow
---@param func string|fun() action to execute after following symlink
M.follow_symlink = function(fname, func)
    fname = F.if_expr(
        not utils.is.empty(fname),
        fn.fnamemodify(fname, ":p"),
        api.nvim_buf_get_name(0)
    )
    local linked_path = uv.fs_readlink(fname)
    if linked_path then
        cmd(("keepalt file %s"):format(linked_path))

        if func then
            local f_type = type(func)
            if f_type == "string" then
                cmd(func)
            elseif f_type == "function" then
                f_type()
            end
        end
    end
end

local M2 = require("common.utils")
M2.fs = M

return M
