---@module 'common.utils'
---@description Utility functions that are used in multiple files
---@class UtilCommon
local M = {}

local lazy = require("common.lazy")

M.is = lazy.require_on.expcall("common.utils.is") ---@module 'common.utils.is'
M.async = lazy.require_on.expcall("common.utils.async") ---@module 'common.utils.async'
M.mod = lazy.require_on.expcall("common.utils.mod") ---@module 'common.utils.mod'
M.fs = lazy.require_on.expcall("common.utils.fs") ---@module 'common.utils.fs'

---Path lib
---@type PathLib
M.pl = lazy.require("diffview.path", function(m)
  return m.PathLib({ separator = "/" })
end)

local funcs = require("common.utils.funcs") ---@module 'common.utils.funcs'
---@type UtilCommon|UtilFuncs
M = vim.tbl_deep_extend("force", M, funcs)

setmetatable(M, {
    __index = function(self, k)
        local mt = getmetatable(self)
        local x = rawget(mt, k)
        if x ~= nil then return x end

        local modname = ("common.utils.%s"):format(k)
        local mod = lazy.require_on.index(modname)
        if package.loaded[modname] then
            rawset(mt, k, package.loaded[modname])
        else
            rawset(mt, k, mod)
        end
        return rawget(mt, k)
    end,
})

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
