---@module 'usr.shared.utils.mod'
---@description Utililty functions for dealing with modules
local M = {}

local shared = require("usr.shared")
local F = shared.F
local log = require("usr.lib.log")

local fn = vim.fn
local env = vim.env

---Safely check if a plugin is installed with a `Promise`
---@param mods string|string[] Module(s) to check if is installed
---@param notify? boolean Whether to notify of an error
---@return Promise
M.prequire = function(mods, notify)
    local first_mod
    local loaded = {}
    mods = type(mods) == "string" and {mods} or mods
    return promise:new(function(resolve, reject)
        for _, m in ipairs(mods) do
            local ok, mod = pcall(require, m)
            if ok then
                if not first_mod then
                    first_mod = mod
                end
                table.insert(loaded, mod)
            else
                if notify then
                    log.err(("Invalid module: %s"):format(m), {dprint = true})
                end
                reject(mod)
            end
        end
        return resolve(#loaded == 1 and unpack(loaded) or loaded)
    end)
    -- return first_mod
end

---Note: this function returns the currently loaded state
---Given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
M.loaded = function(plugin_name)
    local plugins = packer_plugins or {}
    return plugins[plugin_name] and plugins[plugin_name].loaded
end

---Safely check if a plugin is installed. Allows a return value.
---```lua
---   -- Can call this, even if "abcd" doesn't exist
---   xprequire("abcd").setup()
---   xprequire("abcd").setup().another().more()
---   xprequire("abcd", function(m) m.setup() end)
---
---   -- Only time an error should arise is if the module does exist,
---   -- but the function call/index doesn't. i.e.,
---   xprequire("noice.config").disable() -- Error!
---   xprequire("noice").disable()        -- Should be this
---```
---@generic T : table
---@param mods string|string[] Module(s) to check if is installed
---@param cb? fun(mod1: T, ...: table): table? Function to call on successfully required modules
---@param ret_cb_ret? boolean If true, the value returned by the callback is returned from this function
---@param notify? boolean Whether to notify of an error
---@return table|T|Void module First required module
M.xprequire = function(mods, cb, ret_cb_ret, notify)
    local first_mod
    local loaded = {}
    mods = type(mods) == "string" and {mods} or mods
    for _, m in ipairs(mods) do
        local ok, mod = pcall(require, m)
        if ok then
            if not first_mod then
                first_mod = mod
            end
            table.insert(loaded, mod)
        else
            if notify then
                log.err(("Invalid module: %s"):format(m), {debug = true})
            end
            return Rc.t.VOID
        end
    end
    local ok, ret
    if type(cb) == "function" then
        ok, ret = F.xpcall(cb, unpack(loaded))
    end
    if ret_cb_ret then
        if ok then
            return ret
        elseif notify then
            log.err("Callback failed", {debug = true, once = true})
        end
    end
    return first_mod
end

_G.prequire = M.prequire
_G.xprequire = M.xprequire

---Reload all lua modules
M.reload_config = function()
    -- Handle impatient.nvim automatically.
    ---@diagnostic disable-next-line:undefined-field
    local luacache = (_G.__luacache or {}).modpaths.cache

    -- local lua_dirs = fn.glob(("%s/lua/*"):format(Rc.dirs.config), 0, 1)
    -- require("plenary.reload").reload_module(dir)

    for name, _ in pairs(package.loaded) do
        if name:match("^plugs.") then
            package.loaded[name] = nil

            if luacache then
                luacache[name] = nil
            end
        end
    end

    dofile(env.NVIMRC)
    require("plugins").compile()
end

---Reload lua modules in a given path and reload the module
---@param path string module to invalidate
---@param recursive boolean? should the module be invalidated recursively?
---@param req boolean? should a require be returned? If used with recursive, top module is returned
---@return module?
M.reload = function(path, recursive, req)
    path = vim.trim(path)

    if recursive then
        local to_return
        for key, value in pairs(package.loaded) do
            if key ~= "_G" and value and fn.match(key, path) ~= -1 then
                package.loaded[key] = nil
                if req then
                    local r = require(key)
                    if key:sub(1, #path) == path then
                        to_return = r
                    end
                end
            end
        end
        if req then
            return to_return
        end
    else
        package.loaded[path] = nil
        if req then
            return require(path)
        end
    end
end

local installed
---Check if a plugin is on installed. Doesn't have to be loaded
---@param plugin_name string
---@return boolean
M.plugin_installed = function(plugin_name)
    if not installed then
        local dirs = fn.glob(("%s/start/*"):format(Rc.dirs.pack), true, true)
        local opt = fn.glob(("%s/opt/*"):format(Rc.dirs.pack), true, true)
        vim.list_extend(dirs, opt)
        installed =
            vim.tbl_map(
                function(path)
                    return fn.fnamemodify(path, ":t")
                end,
                dirs
            )
    end
    return vim.tbl_contains(installed, plugin_name)
end

---defer_plugin: defer loading plugin until timeout passes
---@param plugin string
---@param timeout number
M.defer_plugin = function(plugin, timeout)
    vim.defer_fn(
        function()
            require("plugins").loader(plugin)
        end,
        timeout or 0
    )
end

return M
