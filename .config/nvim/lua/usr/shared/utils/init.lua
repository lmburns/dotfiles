---@module 'usr.shared.utils'
---@description Utility functions that are used in multiple files
---@class Usr.Utils
local M = {}

local lazy = require("usr.lazy")
---@type Usr.Utils
M = lazy.require("usr.shared.utils.funcs") ---@module 'usr.shared.utils.funcs'
M.async = lazy.require_on.expcall("usr.shared.utils.async") ---@module 'usr.shared.utils.async'
M.mod = lazy.require_on.expcall("usr.shared.utils.mod") ---@module 'usr.shared.utils.mod'
M.git = lazy.require_on.expcall("usr.shared.utils.git") ---@module 'usr.shared.utils.git'
M.fs = lazy.require_on.call_rec("usr.shared.utils.fs") ---@module 'usr.shared.utils.fs'

Rc.async = M.async

---@type PathLib
M.pl = lazy.require("diffview.path", function(m)
    cmd.packadd("diffview.nvim")
    return m.PathLib({separator = "/"})
end)

return M
