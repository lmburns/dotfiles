--@module common.utils.mod
---@description: Utililty functions for dealing with modules
local M = {}

local D = require("dev")
local log = require("common.log")

local fn = vim.fn
local env = vim.env

---Safely check if a plugin is installed
---@generic M string
---@param mods string|string[] Module(s) to check if is installed
---@param cb fun(mod: table<any, any>):nil Function to call on successfully required modules
---@param notify? boolean Whether to notify of an error
---@return module
M.prequire = function(mods, cb, notify)
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
                log.error(
                    ("Invalid module: %s"):format(m),
                    {debug = true, once = true}
                )
            end
            -- Return a dummy item that returns functions, so we can do things like
            -- prequire("module").setup()
            return Void
        end
    end
    if type(cb) == "function" then
        D.wrap_err(cb, unpack(loaded))
    end
    return first_mod
end

---Reload all lua modules
M.reload_config = function()
    -- Handle impatient.nvim automatically.
    ---@diagnostic disable-next-line:undefined-field
    local luacache = (_G.__luacache or {}).modpaths.cache

    -- local lua_dirs = fn.glob(("%s/lua/*"):format(dirs.config), 0, 1)
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
M.reload_module = function(path, recursive, req)
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

---Note: this function returns the currently loaded state
---Given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
M.plugin_loaded = function(plugin_name)
    local plugins = packer_plugins or {}
    return plugins[plugin_name] and plugins[plugin_name].loaded
end

local installed
---Check if a plugin is on installed. Doesn't have to be loaded
---@param plugin_name string
---@return boolean
M.plugin_installed = function(plugin_name)
    if not installed then
        local dirs = fn.expand(fn.stdpath("data") .. "/site/pack/packer/start/*", true, true)
        local opt = fn.expand(fn.stdpath("data") .. "/site/pack/packer/opt/*", true, true)
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
