local M = {}

local fn = vim.fn
local cmd = vim.cmd

local scan_dir = require("plenary.scandir").scan_dir
local Path = require("plenary.path")

-- Paths to unload Lua modules from
-- M.lua_reload_dirs = {fn.stdpath("config")}
M.lua_reload_dirs = {}

-- Paths to reload Vim files from
M.vim_reload_dirs = {}
-- M.vim_reload_dirs = {fn.stdpath("config"), fn.stdpath("data") .. "/site/pack/*/start/*"}

-- External files outside the runtimepaths to source
M.files_reload_external = {}

-- External Lua modules outside the runtimepaths to unload
M.modules_reload_external = {}

-- Pre-reload hook
M.pre_reload_hook = nil
M.post_reload_hook = nil

local viml_subdirs = {
    "compiler",
    "doc",
    "keymap",
    "syntax",
    "plugin",
    "after"
}

-- Escape lua string
local function escape_str(str)
    local patterns_to_escape = {
        "%^",
        "%$",
        "%(",
        "%)",
        "%%",
        "%.",
        "%[",
        "%]",
        "%*",
        "%+",
        "%-",
        "%?"
    }

    return string.gsub(str, string.format("([%s])", table.concat(patterns_to_escape)), "%%%1")
end

local function get_runtime_files_in_path(runtimepath)
    -- Ignore opt plugins
    if string.match(runtimepath, "/site/pack/.-/opt") then
        return {}
    end

    local runtime_files = {}

    -- Search each subdirectory listed listed in viml_subdirs of runtimepath for files
    for _, subdir in ipairs(viml_subdirs) do
        local viml_path = Path:new(("%s/%s"):format(runtimepath, subdir))

        if viml_path:exists() then
            local files = scan_dir(viml_path.filename, {search_pattern = "%.n?vim$", hidden = true})

            for _, file in ipairs(files) do
                runtime_files[#runtime_files + 1] = file
            end
        end
    end

    return runtime_files
end

local function get_lua_modules_in_path(runtimepath)
    local luapath = ("%s/lua"):format(runtimepath)
    local path = Path:new(luapath)

    if not path:exists() then
        return {}
    end

    -- Search lua directory of runtimepath for modules
    local modules = scan_dir(luapath, {search_pattern = "%.lua$", hidden = true})

    for i, module in ipairs(modules) do
        -- Remove runtimepath and file extension from module path
        module = string.match(module, string.format("%s/(.*)%%.lua", escape_str(luapath)))

        -- Changes slash in path to dot to follow lua module format
        module = string.gsub(module, "/", ".")

        -- If module ends with '.init', remove it.
        module = string.gsub(module, "%.init$", "")

        -- Override previous value with new value
        modules[i] = module
    end

    return modules
end

-- Reload all start plugins
local function reload_runtime_files()
    -- Search each runtime path for files
    -- cmd("UpdateRemotePlugins")
    for _, runtimepath_suffix in ipairs(M.vim_reload_dirs) do
        -- Expand the globs and get the result as a list
        local paths = fn.glob(runtimepath_suffix, 0, 1)

        for _, path in ipairs(paths) do
            local runtime_files = get_runtime_files_in_path(path)

            for _, file in ipairs(runtime_files) do
                -- if not pcall(ex.source, file) then
                --     vim.notify(file)
                -- end

                -- iswap and 2 others error out
                pcall(ex.source, file)
            end
        end
    end

    for _, file in ipairs(M.files_reload_external) do
        ex.source(file)
    end
end

-- Unload all loaded Lua modules
local function unload_lua_modules()
    -- Search each runtime path for modules
    for _, runtimepath_suffix in ipairs(M.lua_reload_dirs) do
        local paths = fn.glob(runtimepath_suffix, 0, 1)

        for _, path in ipairs(paths) do
            local modules = get_lua_modules_in_path(path)

            for _, module in ipairs(modules) do
                package.loaded[module] = nil
            end
        end
    end

    for _, module in ipairs(M.modules_reload_external) do
        package.loaded[module] = nil
        -- RELOAD(module)
    end
end

-- Reload Vim configuration
function M.Reload()
    -- Run pre-reload hook
    if type(M.pre_reload_hook) == "function" then
        M.pre_reload_hook()
    end

    -- Clear highlights
    ex.highlight("clear")

    -- Stop LSP if it's configured
    if fn.exists(":LspStop") ~= 0 then
        ex.LspStop()
    end

    -- Unload all already loaded modules
    unload_lua_modules()

    -- Source init file
    if string.match(fn.expand("$NVIMRC"), "%.lua$") then
        -- ex.luafile("$VIMRC")
        vim.cmd("luafile $NVIMRC")
    else
        -- ex.source("$NVIMRC")
        vim.cmd("source $NVIMRC")
    end

    -- Reload start plugins
    reload_runtime_files()

    -- Run post-reload hook
    if type(M.post_reload_hook) == "function" then
        M.post_reload_hook()
    end
end

-- Restart Vim without having to close and run again
function M.Restart()
    -- Reload config
    M.Reload()

    -- Manually run VimEnter autocmd to emulate a new run of Vim
    vim.cmd("doautoall BufEnter")
    vim.cmd("doautoall FileType")
    vim.cmd("doautoall VimEnter")
    -- ex.doautoall("BufEnter")
    -- ex.doautoall("FileType")
    -- ex.doautoall("VimEnter")
end

return M
