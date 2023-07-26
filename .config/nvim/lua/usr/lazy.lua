---@module 'usr.lazy'
---@class Lazy
local M = {}

---Create a table the triggers a given handler every time it's accessed or
---called, until the handler returns a table. Once the handler has returned a
---table, any subsequent accessing of the wrapper will instead access the table
---returned from the handler.
---@param t any
---@param handler fun(t: any): table?
---@return LazyModule
function M.wrap(t, handler)
    local export
    local ret = {
        __get = function()
            if export == nil then
                ---@cast handler function
                export = handler(t)
            end

            return export
        end,
        __loaded = function()
            return export ~= nil
        end,
    }

    return setmetatable(ret, {
        __index = function(_, key)
            if export == nil then ret.__get() end
            ---@cast export table
            return export[key]
        end,
        __newindex = function(_, key, value)
            if export == nil then ret.__get() end
            export[key] = value
        end,
        __call = function(_, ...)
            if export == nil then ret.__get() end
            ---@cast export table
            return export(...)
        end,
    })
end

---Will only require the module after first either indexing, or calling it.
---
---You can pass a handler function to process the module in some way before
---returning it. This is useful i.e. if you're trying to require the result of
---an exported function.
---
---Example:
---
---```lua
--- -- Without handler
--- local foo = require("bar")
--- local foo = lazy.require("bar")
---
--- -- With handler
--- local foo = require("bar").baz({ qux = true })
--- local foo = lazy.require("bar", function(module)
---    return module.baz({ qux = true })
--- end)
---```
---@param require_path string
---@param handler? fun(module: any): any
---@return LazyModule
function M.require(require_path, handler)
    local use_handler = type(handler) == "function"

    return M.wrap(require_path, function(s)
        if use_handler then
            ---@cast handler function
            return handler(require(s))
        end
        return require(s)
    end)
end

---@class LazyModule : table
---@field __get fun(): any Load the module if needed, and return it.
---@field __loaded boolean Indicates that the module has been loaded.

---Lazily access a table value. The `access_path` is a `.` separated string of
---table keys. If `x` is a string, it's treated as a lazy require.
---
---Example:
---
---```lua
--- -- With table:
--- local foo = bar.baz.qux.quux
--- local foo = lazy.access(bar, "baz.qux.quux")
---
--- -- With require path:
--- local foo = require("bar").baz.qux.quux
--- local foo = lazy.access("bar", "baz.qux.quux")
---```
---@param x table|string table to be accessed, or a module require path
---@param access_path string|string[] a `.` separated string of table keys, or a list
---@return LazyModule
function M.access(x, access_path)
    local keys = type(access_path) == "table"
        and access_path
        or vim.split(access_path, ".", {plain = true})

    local handler = function(module)
        local export = module

        for _, key in ipairs(keys) do
            export = export[key]
            assert(export ~= nil, ("Failed to lazy-access! No key '%s' in table!"):format(key))
        end

        return export
    end

    if type(x) == "string" then
        return M.require(x, handler)
    else
        return M.wrap(x, handler)
    end
end

M.require_on = {}

---Require on index.
---Will only require the module after the first index of a module.
---Only works for modules that export a table.
---@param modname string
---@return table
M.require_on.index = function(modname)
    local mod = nil
    local function loadmod()
        if not mod then
            mod = require(modname)
            package.loaded[modname] = mod
        end
        return mod
    end
    return setmetatable({}, {
        __index = function(_, key)
            return loadmod()[key]
            -- return require(modname)[key]
        end,
        __newindex = function(_, key, value)
            loadmod()[key] = value
            -- require(modname)[key] = value
        end,
    })
end

---Requires only when you call the *module* itself.
---If you want to require an exported value from the module,
---see instead `lazy.require_on.expcall()`.
---
---```lua
---  -- not loaded yet
---  local s = lazy.require_on.modcall("usr.style")
---
---  -- ...later
---  s() <- only loads the module now
---```
---@param modname string
---@return table
M.require_on.modcall = function(modname)
    local mod = nil
    return setmetatable({}, {
        __call = function(_, ...)
            local args = {...}
            if not mod then
                mod = require(modname)
                package.loaded[modname] = mod
            end
            return mod(unpack(args))
            -- return require(modname)(unpack(args))
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
---  local lazy_mod = lazy.require_on.expcall('my_module')
---  local lazy_func = lazy_mod.exported_func
---
---  -- ...later
---  lazy_func(42)  -- <- only loads the module now
---```
---@param modname string
---@return table
M.require_on.expcall = function(modname)
    local mod = nil
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                local args = {...}
                if not mod then
                    mod = require(modname)
                    package.loaded[modname] = mod
                end
                return mod[k](unpack(args))
                -- return require(modname)[k](unpack(args))
            end
        end,
    })
end

---Require when any descendant is called
---This is like `require_on.modcall` plus `require_on.expcall` but also
---works with arbitrarily nested indices.
---@param require_path string
---@return table
M.require_on.call_rec = function(require_path)
    return M.on_call_rec(function()
        return require(require_path)
    end)
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

return M
