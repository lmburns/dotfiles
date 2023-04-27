---@class UvFS
local M = {}

---@class Promise_t<T>: Promise

local uv = require("luv")

---home/lucas/.local/share/nvim/site/pack/packer/start/promise-async/lua/promise
---file:///home/lucas/.local/share/nvim/site/pack/packer/start/promise-async/lua/promise.lua
---@module "promise"
local promise = require("promise")
local compat = require("promise-async.compat")

---@param name string Function name to wrap
---@param argc integer integer of function args
---@return fun(...): Promise
local function wrap(name, argc)
    return function(...)
        local argv = {...}
        return promise:new(
            function(resolve, reject)
                argv[argc] = function(err, data)
                    if err then
                        reject(err)
                    else
                        resolve(data)
                    end
                end
                uv["fs_" .. name](compat.unpack(argv))
            end
        )
    end
end

---@diagnostic disable unused-local

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@return Promise success boolean Was operation successful?
function M.close(fd)
end

--@return Promise_t<integer> fd File descriptor
---Return: integer? fd
---@param path string
---@param flags uv.aliases.fs_access_flags|integer
---@param mode integer
---@nodiscard
---@return Promise fd integer File descriptor
function M.open(path, flags, mode)
end

--@return Promise data string File data
---Return: string? data
---@param fd integer
---@param size integer
---@param offset? integer
---@nodiscard
---@return Promise data string File data
function M.read(fd, size, offset)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@return Promise success boolean Was operation successful?
function M.unlink(path)
end

--@return Promise_t<integer> bytes Bytes written
---Return: integer? bytes
---@param fd integer
---@param data uv.aliases.buffer
---@param offset? integer
---@return Promise bytes integer Bytes written
function M.write(fd, data, offset)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param mode integer
---@return Promise success boolean Was operation successful?
function M.mkdir(path, mode)
end

--@return Promise_t<string> string Path
---Return: string? path
---@param template string
---@nodiscard
---@return Promise string string Path
function M.mkdtemp(template)
end

--@return Promise_t<integer> fd File descriptor
---Return: integer? fd
---@param template string
---@nodiscard
---@return Promise fd integer File descriptor
function M.mkstemp(template)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@return Promise success boolean Was operation successful?
function M.rmdir(path)
end

--@return Promise_t<uv_fs_t> success Was operation successful?
---Return: uv_fs_t? success
---@param path string
---@nodiscard
---@return Promise success uv_fs_t Was operation successful?
function M.scandir(path)
end

--@return Promise_t<uv.aliases.fs_stat_table> stat Stat table
---Return: uv.aliases.fs_stat_table? stat
---@param path string
---@nodiscard
---@return Promise stat uv.aliases.fs_stat_table Stat table
function M.stat(path)
end

--@return Promise_t<uv.aliases.fs_stat_table> stat Stat table
---Return: uv.aliases.fs_stat_table? stat
---@param fd integer
---@nodiscard
---@return Promise stat uv.aliases.fs_stat_table Stat table
function M.fstat(fd)
end

--@return Promise_t<uv.aliases.fs_stat_table> stat Stat table
---Return: uv.aliases.fs_stat_table? stat
---@param fd integer
---@nodiscard
---@return Promise stat uv.aliases.fs_stat_table Stat table
function M.lstat(fd)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param new_path string
---@return Promise success boolean Was operation successful?
function M.rename(path, new_path)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@return Promise success boolean Was operation successful?
function M.fsync(fd)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@return Promise success boolean Was operation successful?
function M.fdatasync(fd)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? sucess
---@param fd integer
---@param offset integer
---@return Promise success boolean Was operation successful?
function M.ftruncate(fd, offset)
end

--@return Promise_t<integer> bytes Bytes written
---Return: integer? bytes
---@param out_fd integer
---@param in_fd integer
---@param in_offset integer
---@param size integer
---@return Promise bytes integer Bytes written
function M.sendfile(out_fd, in_fd, in_offset, size)
end

--@return Promise_t<boolean> permission Indicate access permission
---Return: boolean? permission
---@param path string
---@param mode uv.aliases.fs_access_mode|integer
---@nodiscard
---@return Promise permission boolean Indicate access permission
function M.access(path, mode)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param mode integer
---@return Promise success boolean Was operation successful?
function M.chmod(path, mode)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@param mode integer
---@return Promise success boolean Was operation successful?
function M.fchmod(path, mode)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param atime number
---@param mtime number
---@return Promise success boolean Was operation successful?
function M.utime(path, atime, mtime)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@param atime number
---@param mtime number
---@return Promise success boolean Was operation successful?
function M.futime(path, atime, mtime)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param atime number
---@param mtime number
---@return Promise success boolean Was operation successful?
function M.lutime(path, atime, mtime)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param new_path string
---@return Promise success boolean Was operation successful?
function M.link(path, newPath)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param new_path string
---@param flags? uv.aliases.fs_symlink_flags|integer
---@return Promise success boolean Was operation successful?
function M.symlink(path, newPath, flags)
end

--@return Promise_t<string> path File path
---Return: string? path
---@param path string
---@nodiscard
---@return Promise path string File path
function M.readlink(path)
end

--@return Promise_t<string> path File path
---Return: string? path
---@param path string
---@nodiscard
---@return Promise path string File path
function M.realpath(path)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param uid integer
---@param gid integer
---@return Promise success boolean Was operation successful?
function M.chown(path, uid, gid)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@param uid integer
---@param gid integer
---@return Promise success boolean Was operation successful?
function M.fchown(path, uid, gid)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param fd integer
---@param uid integer
---@param gid integer
---@return Promise success boolean Was operation successful?
function M.lchown(path, uid, gid)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param path string
---@param new_path string
---@param flags? uv.aliases.fs_copyfile_flags
---@return Promise success boolean Was operation successful?
function M.copyfile(path, newPath, flags)
end

--@return Promise_t<uv.aliases.fs_readdir_entries> entries Directory entries
---Return: uv.aliases.fs_readdir_entries? entries
---@param dir luv_dir_t
---@nodiscard
---@return Promise entries uv.aliases.fs_readdir_entries Directory entries
function M.readdir(dir)
end

--@return Promise_t<boolean> success Was operation successful?
---Return: boolean? success
---@param dir luv_dir_t
---@return Promise success boolean Was operation successful?
function M.closedir(dir)
end

--@return Promise_t<uv.aliases.fs_statfs_stats> stat Stat table
---Return: uv.aliases.fs_statfs_stats? stat
---@param path string
---@nodiscard
---@return Promise stat uv.aliases.fs_statfs_stats Stat table
function M.statfs(path)
end

---@diagnostic enable unused-local

--@type fun(fd: integer): Promise_t<boolean>
--@type fun(path: string, flags: uv.aliases.fs_access_flags|integer, mode: integer): Promise_t<integer>
--@type fun(fd: integer, size: integer, offset?: integer): Promise_t<string>
--@type fun(path: string): Promise_t<boolean>
--@type fun(fd: integer, data: uv.aliases.buffer, offset?: integer): Promise_t<integer>
--@type fun(path: string, mode:integer): Promise_t<boolean>
--@type fun(template: string): Promise_t<string>
--@type fun(template: string): Promise_t<integer>
--@type fun(path: string): Promise_t<boolean>
--@type fun(path: string): Promise_t<uv_fs_t>
--@type fun(path: string): Promise_t<uv.aliases.fs_stat_table>
--@type fun(fd: integer): Promise_t<uv.aliases.fs_stat_table>
--@type fun(fd: integer): Promise_t<uv.aliases.fs_stat_table>
--@type fun(path: string, new_path: string): Promise_t<boolean>
--@type fun(fd: integer): Promise_t<boolean>
--@type fun(fd: integer): Promise_t<boolean>
--@type fun(fd: integer, offset: integer): Promise_t<boolean>
--@type fun(out_fd: integer, in_fd: integer, in_offset: integer, size: integer): Promise_t<integer>
--@type fun(path: string, mode: uv.aliases.fs_access_mode|integer): Promise_t<boolean>
--@type fun(path: string, mode: integer): Promise_t<boolean>
--@type fun(fd: integer, mode: integer): Promise_t<boolean>
--@type fun(path: string, atime: number, mtime: number): Promise_t<boolean>
--@type fun(fd: integer, atime: number, mtime: number): Promise_t<boolean>
--@type fun(path: string, atime: number, mtime: number): Promise_t<boolean>
--@type fun(path: string, new_path: string): Promise_t<boolean>
--@type fun(path: string, new_path: string, flags?: uv.aliases.fs_symlink_flags|integer): Promise_t<boolean>
--@type fun(path: string): Promise_t<string>
--@type fun(path: string): Promise_t<string>
--@type fun(path: string, uid: integer, gid: integer): Promise_t<boolean>
--@type fun(fd: integer, uid: integer, gid: integer): Promise_t<boolean>
--@type fun(fd: integer, uid: integer, gid: integer): Promise_t<boolean>
--@type fun(path: string, new_path: string, flags?: uv.aliases.fs_copyfile_flags): Promise_t<boolean>
--@type fun(dir: luv_dir_t): Promise_t<uv.aliases.fs_readdir_entries>
--@type fun(path: string): Promise_t<uv.aliases.fs_statfs_stats>

M.close = wrap("close", 2)
M.open = wrap("open", 4)
M.read = wrap("read", 4)
M.unlink = wrap("unlink", 2)
M.write = wrap("write", 4)
M.mkdir = wrap("mkdir", 3)
M.mkdtemp = wrap("mkdtemp", 2)
M.mkstemp = wrap("mkstemp", 2)
M.rmdir = wrap("rmdir", 2)
M.scandir = wrap("scandir", 2)
M.stat = wrap("stat", 2)
M.fstat = wrap("fstat", 2)
M.lstat = wrap("lstat", 2)
M.rename = wrap("rename", 3)
M.fsync = wrap("fsync", 2)
M.fdatasync = wrap("fdatasync", 2)
M.ftruncate = wrap("ftruncate", 3)
M.sendfile = wrap("sendfile", 5)
M.access = wrap("access", 3)
M.chmod = wrap("chmod", 3)
M.fchmod = wrap("fchmod", 3)
M.utime = wrap("utime", 4)
M.futime = wrap("futime", 4)
M.lutime = wrap("lutime", 4)
M.link = wrap("link", 3)
M.symlink = wrap("symlink", 4)
M.readlink = wrap("readlink", 2)
M.realpath = wrap("realpath", 2)
M.chown = wrap("chown", 4)
M.fchown = wrap("fchown", 4)
M.lchown = wrap("lchown", 4)
M.copyfile = wrap("copyfile", 4)

--@return Promise_t<luv_dir_t> dir Directory
-- TODO: Finish this
---Return: luv_dir_t? dir
---@param path string
---@param entries? integer
---@nodiscard
---@return Promise_t<luv_dir_t> dir Directory
M.opendir = function(path, entries)
    return promise:new(
        function(resolve, reject)
            uv.fs_opendir(
                path,
                function(err, data)
                    if err then
                        reject(err)
                    else
                        resolve(data)
                    end
                end,
                entries
            )
        end
    )
end

M.readdir = wrap("readdir", 2)
M.closedir = wrap("closedir", 2)
M.statfs = wrap("statfs", 2)

return M
