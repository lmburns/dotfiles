---@module 'usr.lib.log'
---@class Log
local M = {}

local log = require("plenary.log")
local lazy = require("usr.lazy") ---@type Lazy
local ffi = lazy.require("usr.ffi") ---@module 'usr.ffi'
local shared = require("usr.shared")
local utils = shared.utils ---@module 'usr.shared.utils'
local F = shared.F ---@module 'usr.shared.F'
local C = shared.collection

local api = vim.api
local fn = vim.fn
local uv = vim.loop

---@enum Log.Level
M.levels = {
    TRACE = 0,
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    OFF = 5,
}

---Format a module name
---@param src string
---@return string
function M.module_fmt(src)
    -- local src = debug.getinfo(2, "S").source:gsub("@", "")

    -- 1. /home/lucas/.config/nvim/lua/autocmds.lua
    -- 2. /home/lucas/.config/nvim/lua/autocmds
    local fname_p = fn.fnamemodify(src:gsub("@", ""), ":r")
    -- 3. autocmds
    local fname = fn.fnamemodify(fname_p, ":t")
    -- 4. lua
    local dir = fn.fnamemodify(fname_p, ":h:t")
    -- If the file is an init.lua, use the module name
    return F.if_expr(fname == "init", dir,
        F.if_expr(dir == "nvim", fname, ("%s.%s"):format(dir, fname))
    )
end

---@return string file #calling file name
M.__FILE__ = function()
    return debug.getinfo(3, "S").source
end
---@return number line #calling line
M.__LINE__ = function()
    return debug.getinfo(3, "l").currentline
end
---@return string funcname #calling func
M.__FUNC__ = function()
    return debug.getinfo(3, "n").name or "NA"
end
---@return string module #calling module
M.__MODULE__ = function()
    return M.module_fmt(debug.getinfo(3, "S").source)
end
---@return string #'module.function:line'
M.__TRACEBACK__ = function()
    local info = debug.getinfo(3)
    local module = M.module_fmt(info.source)
    return ("%s.%s:%d"):format(module, info.name, info.currentline)
end

---@return string module #calling module (callstack level 2)
local __FMODULE__ = function()
    return M.module_fmt(debug.getinfo(2, "S").source)
end

---@param syntax string
---@return fun(win: winid)
function M.on_open(syntax)
    return function(win)
        vim.wo[win].conceallevel = 3
        vim.wo[win].concealcursor = ""
        vim.wo[win].spell = false

        local syn = F.ift_then(syntax, "markdown")
        local buf = api.nvim_win_get_buf(win)
        if not pcall(vim.treesitter.start, buf, syn) then
            vim.bo[buf].ft = syn
        end
    end
end

---Get current location
---@param thread? number
---@return string
function M.get_loc(thread)
    thread = F.unwrap_or(thread, 1)
    local me = debug.getinfo(thread)
    local level = thread + 1
    local info = debug.getinfo(level)
    while info and info.source == me.source do
        level = level + 1
        info = debug.getinfo(level)
    end
    info = info or me
    local source = info.source:sub(2)
    source = uv.fs_realpath(source) or source
    local module = M.module_fmt(source)
    return ("%s.%s:%d"):format(module, info.name, info.currentline)
    -- return source .. ":" .. info.linedefined
end

---@class LogDump.Opts
---@field loc? string location
---@field level? integer log level
---@field thread? integer debug thread scope
---@field title? string notification title
---@field once? boolean exec once

---@param value any
---@param opts? LogDump.Opts
---@return nil
function M.dump(value, opts)
    opts = opts or {}
    opts.loc = opts.loc or M.get_loc(opts.thread)
    if ffi.nvim_is_locked() or vim.in_fast_event() then
        return vim.schedule(function()
            M.dump(value, opts)
        end)
    end
    -- opts.loc = fn.fnamemodify(opts.loc, ":~:.")
    local msg = vim.inspect(value)
    local built_opts = {
        title = ("%s: %s"):format(opts.title or "Debug", opts.loc),
        on_open = M.on_open("lua"),
    }

    if opts.once then
        vim.notify_once(msg, opts.level or M.levels.INFO, built_opts)
    else
        vim.notify(msg, opts.level or M.levels.INFO, built_opts)
    end
end

---@class Log.Config
local default_config = {
    -- Name of the plugin. Prepended to log messages
    plugin = "nvim",
    -- Should print the output to neovim while running
    -- values: 'sync','async',false
    ---@type string|boolean
    use_console = "async",
    -- Should highlighting be used in console (using echohl)
    highlights = true,
    -- Should write to a file
    use_file = false,
    -- Should write to the quickfix list
    use_quickfix = false,
    -- Any messages above this level will be logged.
    level = "info",
    -- Level configuration
    modes = {
        {name = "trace", hl = "@text.trace"},
        {name = "debug", hl = "@text.debug"},
        {name = "info", hl = "MoreMsg"},
        {name = "warn", hl = "@text.warn"},
        {name = "error", hl = "@text.error"},
        {name = "fatal", hl = "@text.danger"},
    },
    -- Can limit the number of decimals displayed for floats
    float_precision = 0.01,
}

local built = log.new(default_config, false)
local qf_built, file_built

---@return fun(name?: string): table
M.qf_config = (function()
    local qf_config
    return function(name)
        if not qf_config then
            qf_config = C.tbl_clone(default_config)
        end
        qf_config.plugin = name or "nvim"
        qf_config.use_quickfix = true
        qf_config.use_console = false

        if not qf_built then
            qf_built = log.new(qf_config, false)
        end
        return qf_built
    end
end)()

---@return fun(fname?: string): table
M.file_config = (function()
    local file_config
    return function(fname)
        if not file_config then
            file_config = C.tbl_clone(default_config)
        end
        file_config.plugin = fname or "nvim"
        file_config.use_file = true
        file_config.use_console = false

        if not file_built then
            file_built = log.new(file_config, false)
        end
        return file_built
    end
end)()

---# Examples
---```lua
---  logger.info("these", "are", "separated")
---  logger.fmt_info("These are %s strings", "formatted")
---  logger.lazy_info(expensive_to_calculate)
---  logger.file_info("do not print")
---  logger.qf().info("add to qf")
---```
---@class Logger
M.logger =
    setmetatable(
        {
            qf = M.qf_config,
            file = M.file_config,
        },
        {
            __index = function(_, fn)
                local tocall = built[fn]
                if type(tocall) == "function" then
                    return tocall
                end
            end,
            __call = function(self, ...)
                self.info(...)
            end,
        }
    )

---TRACE message
---@param msg string|string[]
---@param opts? Notify.Opts
function M.trace(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo({
            {"[DEBUG]: ", "@text.trace"},
            {msg, F.if_nil(opts.hl, "NotifyTRACEBody")},
        })
    else
        utils.notify(msg, M.levels.TRACE, opts)
    end
end

---DEBUG message
---@param msg string|string[]
---@param opts? Notify.Opts
function M.debug(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo({
            {"[DEBUG]: ", "@text.debug"},
            {msg, F.if_nil(opts.hl, "NotifyDEBUGBody")},
        })
    else
        utils.notify(msg, M.levels.DEBUG, opts)
    end
end

---INFO message
---@param msg string|any[]
---@param opts? Notify.Opts
function M.info(msg, opts)
    opts = opts or {}
    if type(msg) == "table" then
        msg = C.map(msg, utils.inspect)
    end
    local args = {{msg, F.if_nil(opts.hl, "NotifyINFOorder")}}
    if opts.dprint then
        opts.debug = true
        opts.print = true
    end
    if opts.debug and opts.print then
        args = C.vec_insert(
            args,
            {__FMODULE__(), "Title"},
            {".", "Normal"},
            {M.__FUNC__(), "Function"},
            {":", "Normal"},
            {("%d: "):format(M.__LINE__()), "MoreMsg"}
        )
    end
    if opts.print then
        nvim.echo({{"[INFO]: ", "@text.info"}, unpack(args)})
    else
        if opts.debug then
            if not opts.title then
                opts.title = M.__TRACEBACK__()
                opts.debug = nil
            else
                msg = ("%s\n%s"):format(M.__TRACEBACK__(), msg)
            end
        end
        utils.notify(msg, M.levels.INFO, opts)
    end
end

---WARN message
---@param msg string|any[]
---@param opts? Notify.Opts
function M.warn(msg, opts)
    opts = opts or {}
    if type(msg) == "table" then
        msg = C.map(msg, utils.inspect)
    end
    local args = {{msg, F.if_nil(opts.hl, "NotifyWARNorder")}}
    if opts.dprint then
        opts.debug = true
        opts.print = true
    end
    if opts.debug and opts.print then
        args = C.vec_insert(
            args,
            {__FMODULE__(), "Title"},
            {".", "Normal"},
            {M.__FUNC__(), "Function"},
            {":", "Normal"},
            {("%d: "):format(M.__LINE__()), "MoreMsg"}
        )
    end
    if opts.print then
        nvim.echo({{"[WARN]: ", "@text.warning"}, unpack(args)})
    else
        if opts.debug then
            if not opts.title then
                opts.title = M.__TRACEBACK__()
                opts.debug = nil
            else
                msg = ("%s\n%s"):format(M.__TRACEBACK__(), msg)
            end
        end
        utils.notify(msg, M.levels.WARN, opts)
    end
end

---ERROR message
---@param msg string|any[]
---@param opts? Notify.Opts
function M.err(msg, opts)
    opts = opts or {}
    if type(msg) == "table" then
        msg = C.map(msg, utils.inspect)
    end
    local args = {{msg, F.if_nil(opts.hl, "NotifyERRORBorder")}}
    if opts.dprint then
        opts.debug = true
        opts.print = true
    end
    if opts.debug and opts.print then
        args = C.vec_insert(
            args,
            {__FMODULE__(), "Title"},
            {".", "Normal"},
            {M.__FUNC__(), "Function"},
            {":", "Normal"},
            {("%d: "):format(M.__LINE__()), "MoreMsg"}
        )
    end
    if opts.print then
        nvim.echo({{"[ERROR]: ", "@text.error"}, unpack(args)})
    else
        if opts.debug then
            if not opts.title then
                opts.title = M.__TRACEBACK__()
                opts.debug = nil
            else
                msg = ("%s\n%s"):format(M.__TRACEBACK__(), msg)
            end
        end
        utils.notify(msg, M.levels.ERROR, opts)
    end
end

return M
