---@module 'usr.shared.utils'
---@description Utility functions that are used in multiple files
---@class Usr.Util
local M = {}

local lazy = require("usr.lazy")

M.is = lazy.require_on.expcall("usr.shared.utils.is") ---@module 'usr.shared.utils.is'
M.async = lazy.require_on.expcall("usr.shared.utils.async") ---@module 'usr.shared.utils.async'
M.mod = lazy.require_on.expcall("usr.shared.utils.mod") ---@module 'usr.shared.utils.mod'
M.fs = lazy.require_on.call_rec("usr.shared.utils.fs") ---@module 'usr.shared.utils.fs'
M.git = lazy.require_on.expcall("usr.shared.utils.git") ---@module 'usr.shared.utils.git'

---Path lib
---@type PathLib
M.pl = lazy.require("diffview.path", function(m)
    return m.PathLib({separator = "/"})
end)

local funcs = require("usr.shared.utils.funcs") ---@module 'usr.shared.utils.funcs'
---@type Usr.Util|Usr.Util.Fns
M = vim.tbl_deep_extend("force", M, funcs)

-- setmetatable(M, {
--     __index = function(self, k)
--         local mt = getmetatable(self)
--         local x = rawget(mt, k)
--         if x ~= nil then return x end
--
--         local modname = ("usr.shared.utils.%s"):format(k)
--         local pkg = package.loaded[modname]
--         local mod = type(pkg) == "table" and pkg or lazy.require_on.index(modname)
--         rawset(mt, k, mod)
--         return mod
--     end,
-- })

return M

-- TIP: ======================================= [[[
-- EmmyLua
--   https://github.com/LuaLS/lua-language-server/wiki/Annotations

-- Metatable Events
--   http://lua-users.org/wiki/MetatableEvents

-- String Recipes
--   http://lua-users.org/wiki/StringRecipes

-- Patterns
--   http://lua-users.org/wiki/PatternsTutorial
--   http://lua-users.org/wiki/FrontierPattern
--   https://www.lua.org/pil/20.2.html
--   https://riptutorial.com/lua/example/20315/lua-pattern-matching
--
--   %b:
--     p(("capture {what is inside} these brackets"):match("%b{}"))
--     --> {what is inside}
--
--   %f:
--     - Detects transition from "not set in" to "in set"
--     - %f[%a]: Find transition from non-letter to letter
--     - %u+:    Find multiple uppercase letters after previous transition
--     - %f[%A]: Find transition from letter to non-letter
--
--     p(("THE (QUICK) brOWN FOx JUMPS"):match("%f[%a]%u+%f[%A]"))
--     --> THE
--         QUICK
--         JUMPS
--
--   Special characters: ( ) . % + - * ? [ ^ $
--
-- LPEG:
--    https://www.inf.puc-rio.br/~roberto/lpeg/
--    https://www.inf.puc-rio.br/~roberto/lpeg/re.html
--
-- Replace Nth occurence:        s/\v(.{-}\zsPATT.){N}/REPL/
-- Replace every Nth occurrence: s/\v(\zsPATT.{-}){N}/REPL/g
-- Sort on a given column:       :sort f /\v^(.{-},){2}/
-- ]]] === Tips ===
