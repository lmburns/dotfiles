---@class UvFS
local M = {}

---@class Promise_t<T>: Promise

local uv = require("luv")
---@type Promise
local promise = require("promise")

---@param name string Function name to wrap
local function assign2(name)
    M[name] = function(a1)
        return promise(
            function(resolve, reject)
                uv["fs_" .. name](a1, function(err, data)
                    if err then reject(err) else resolve(data) end
                end)
            end)
    end
end

---@param name string Function name to wrap
local function assign3(name)
    M[name] = function(a1, a2)
        return promise(
            function(resolve, reject)
                uv["fs_" .. name](a1, a2, function(err, data)
                    if err then reject(err) else resolve(data) end
                end)
            end)
    end
end

---@param name string Function name to wrap
local function assign4(name)
    M[name] = function(a1, a2, a3)
        return promise(
            function(resolve, reject)
                uv["fs_" .. name](a1, a2, a3, function(err, data)
                    if err then reject(err) else resolve(data) end
                end)
            end)
    end
end

---@param name string Function name to wrap
local function assign5(name)
    M[name] = function(a1, a2, a3, a4)
        return promise(
            function(resolve, reject)
                uv["fs_" .. name](a1, a2, a3, a4, function(err, data)
                    if err then reject(err) else resolve(data) end
                end)
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
---Userdata returned is always syncrhonous
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

assign2("close")
assign4("open")
assign4("read")
assign2("unlink")
assign4("write")
assign3("mkdir")
assign2("mkdtemp")
assign2("mkstemp")
assign2("rmdir")
assign2("scandir")
assign2("stat")
assign2("fstat")
assign2("lstat")
assign3("rename")
assign2("fsync")
assign2("fdatasync")
assign3("ftruncate")
assign5("sendfile")
assign3("access")
assign3("chmod")
assign3("fchmod")
assign4("utime")
assign4("futime")
assign4("lutime")
assign3("link")
assign4("symlink")
assign2("readlink")
assign2("realpath")
assign4("chown")
assign4("fchown")
assign4("lchown")
assign4("copyfile")

--@return Promise_t<luv_dir_t> dir Directory
-- TODO: Finish this
---Return: luv_dir_t? dir
---@param path string
---@param entries? integer
---@nodiscard
---@return Promise_t<luv_dir_t> dir Directory
M.opendir = function(path, entries)
    return promise:new(function(resolve, reject)
        uv.fs_opendir(path, function(err, data)
            if err then
                reject(err)
            else
                resolve(data)
            end
        end, entries)
    end)
end

assign2("readdir")
assign2("closedir")
assign2("statfs")

return M
