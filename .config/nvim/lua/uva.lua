---@class UvFS
local M = {}

---Taken from promise-async.lua

local uv = require("luv")
local promise = require("promise")
local compat = require("promise-async.compat")

local function wrap(name, argc)
    return function(...)
        local argv = {...}
        return promise.new(
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

---@param fd number
---@return Promise
function M.close(fd)
end

---@param path string
---@param flags string|number
---@param mode number
---@return Promise
function M.open(path, flags, mode)
end

---@param fd number
---@param size number
---@param offset? number
---@return Promise
function M.read(fd, size, offset)
end

---@param path string
---@return Promise
function M.unlink(path)
end

---@param fd number
---@param data string
---@param offset? number
---@return Promise
function M.write(fd, data, offset)
end

---@param path string
---@param mode number
---@return Promise
function M.mkdir(path, mode)
end

---@param template string
---@return Promise
function M.mkdtemp(template)
end

---@param template string
---@return Promise
function M.mkstemp(template)
end

---@param path string
---@return Promise
function M.rmdir(path)
end

---@param path string
---@return Promise
function M.scandir(path)
end

---@param path string
---@return Promise
function M.stat(path)
end

---@param fd number
---@return Promise
function M.fstat(fd)
end

---@param path string
---@return Promise
function M.lstat(path)
end

---@param path string
---@param new_path string
---@return Promise
function M.rename(path, new_path)
end

---@param fd number
---@return Promise
function M.fsync(fd)
end

---@param fd number
---@return Promise
function M.fdatasync(fd)
end

---@param fd number
---@param offset number
---@return Promise
function M.ftruncate(fd, offset)
end

---@param out_fd number
---@param in_fd number
---@param in_offset number
---@param size number
---@return Promise
function M.sendfile(out_fd, in_fd, in_offset, size)
end

---@param path string
---@param mode number
---@return Promise
function M.access(path, mode)
end

---@param path string
---@param mode number
---@return Promise
function M.chmod(path, mode)
end

---@param fd number
---@param mode number
---@return Promise
function M.fchmod(path, mode)
end

---@param path string
---@param atime number
---@param mtime number
---@return Promise
function M.utime(path, atime, mtime)
end

---@param path string
---@param atime number
---@param mtime number
---@return Promise
function M.futime(path, atime, mtime)
end

---@param path string
---@param atime number
---@param mtime number
---@return Promise
function M.lutime(path, atime, mtime)
end

---@param path string
---@param newPath string
---@return Promise
function M.link(path, newPath)
end

---@param path string
---@param newPath string
---@param flags? table|number
---@return Promise
function M.symlink(path, newPath, flags)
end

---@param path string
---@return Promise
function M.readlink(path)
end

---@param path string
---@return Promise
function M.realpath(path)
end

---@param path string
---@param uid number
---@param gid number
---@return Promise
function M.chown(path, uid, gid)
end

---@param path string
---@param uid number
---@param gid number
---@return Promise
function M.fchown(path, uid, gid)
end

---@param path string
---@param uid number
---@param gid number
---@return Promise
function M.lchown(path, uid, gid)
end

---@param path string
---@param newPath string
---@param flags? table|number
---@return Promise
function M.copyfile(path, newPath, flags)
end

---@param dir userdata
---@return Promise
function M.readdir(dir)
end

---@param dir userdata
---@return Promise
function M.closedir(dir)
end

---@param path string
---@return Promise
function M.statfs(path)
end

---@diagnostic enable unused-local

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

-- TODO: Finish this
---@param path string
---@param entries number
---@return Promise
M.opendir = function(path, entries)
    return promise.new(
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
