--- Stuff to help with reloading Lua modules
-- @module common.reload
local reload = {}

--- Unload modules with a prefix
--
-- @tparam string prefix The prefix of modules to unload
function reload.unload_modules(prefix)
    local to_unload = {}

    for k, _ in pairs(package.loaded) do
        if vim.startswith(k, prefix .. ".") then
            table.insert(to_unload, k)
        end
    end

    for _, v in pairs(to_unload) do
        -- Give modules a chance to clean up
        local unload_func = package.loaded[v].__unload
        if unload_func ~= nil then
            unload_func()
        end

        package.loaded[v] = nil
    end
end

--- Unloads modules from this user config
--
-- <br>
-- This unloads modules prefixed with `c.` or `l.`.
function reload.unload_user_modules()
    reload.unload_modules("common") -- Unload config core
    reload.unload_modules("loaders") -- Unload layers
end

--- Updates `package.path` from Vim's `runtimepath`
function reload.update_package_path()
    vim._update_package_paths()
end

return reload
