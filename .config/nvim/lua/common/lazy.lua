---@module 'common.lazy'
---@class Lazy
local M = {}

---@version >5.2,JIT
---lazy_table returns a placeholder table and defers callback cb until someone
---tries to access or iterate the table in some way, at which point cb will be
---called and its result becomes the value of the table.
--
---To work, requires LuaJIT compiled with -DLUAJIT_ENABLE_LUA52COMPAT.
---If not, the result of the callback will be returned immediately.
---See: https://luajit.org/extensions.html
---@param cb fun(): any
---@return table|any
M.table = function(cb)
    local log = require("common.log")

    ---Check if Lua 5.2 compatability is available by testing whether goto is a
    ---valid identifier name, which is not the case in 5.2.
    ---
    ---This check doesn't seem to do anything
    ---My neovim setup allows goto to be set, but it is a valid keyword
    if loadstring("local goto = true")() ~= nil then
        log.err("LuaJIT 5.2 is required", {title = "Lazy"})
        return cb()
    end

    local t = {data = nil}
    local init = function()
        if t.data == nil then
            t.data = cb()
            assert(type(t.data) == "table", "lazy: expected callback to return value of type table")
        end
    end

    t.__len = function()
        init()
        return #t.data
    end

    t.__index = function(_, key)
        init()
        return t.data[key]
    end

    t.__pairs = function()
        init()
        return pairs(t.data)
    end

    t.__ipairs = function()
        init()
        return ipairs(t.data)
    end
    return setmetatable({}, t)
end

M.on_call_rec = function(base, fn, indices)
    indices = indices or {}
    return setmetatable({}, {
        __index = function(_, k)
            local new_indices = vim.deepcopy(indices)
            table.insert(new_indices, k)
            return M.on_call_rec(base, fn, new_indices)
        end,
        __call = function(_, ...)
            if type(base) == "function" then
                base = base()
            end
            local target = base
            for _, k in ipairs(indices) do
                target = target[k]
            end
            if type(fn) == "function" then
                return fn(target, ...)
            end
            return target(...)
        end,
    })
end

---Require on index.
---Will only require the module after the first index of a module.
---Only works for modules that export a table.
---@param require_path string
---@return table
M.require_on_index = function(require_path)
    return setmetatable({}, {
        __index = function(_, key)
            return require(require_path)[key]
        end,
        __newindex = function(_, key, value)
            require(require_path)[key] = value
        end,
    })
end

---Requires only when you call the *module* itself.
---If you want to require an exported value from the module,
---see instead `lazy.require_on_exported_call()`.
---
---```lua
---  -- not loaded yet
---  local s = lazy.require_on_module_call("style")
---
---  -- ...later
---  s() <- only loads the module now
---```
---@param require_path string
---@return table
M.require_on_module_call = function(require_path)
    return setmetatable({}, {
        __call = function(_, ...)
            local args = {...}
            return require(require_path)(unpack(args))
        end,
    })
end

---Require when an exported method is called.
---Creates a new function. Cannot be used to compare functions,
---set new values, etc. Only useful for waiting to do the require until you actually
---call the code.
---
---```lua
--- -- not loaded yet
---  local lazy_mod = lazy.require_on_exported_call('my_module')
---  local lazy_func = lazy_mod.exported_func
---
---  -- ...later
---  lazy_func(42)  -- <- only loads the module now
---```
---@param require_path string
---@return table
M.require_on_exported_call = function(require_path)
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                local args = {...}
                return require(require_path)[k](unpack(args))
            end
        end,
    })
end

---Require when any descendant is called
---This is like `require_on_module_call` plus `require_on_exported_call` but also
---works with arbitrarily nested indices.
---@param require_path string
---@return table
M.require_on_call_rec = function(require_path)
    return M.on_call_rec(function()
        return require(require_path)
    end)
end

return M
