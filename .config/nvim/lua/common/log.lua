---@module 'common.log'
---@class Log
local M = {}

local log = require("plenary.log")
---@type Lazy
local lazy = require("common.lazy")
---@type DevL
local D = lazy.require_on_exported_call("dev")

local api = vim.api
local fn = vim.fn
local uv = vim.loop
local F = vim.F

---@enum Log.Levels
M.levels = {
    TRACE = 0,
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    OFF = 5,
}

-- ---@type LogLevels
-- vim.log.levels = vim.log.levels

---Format a module name
---@param src string
---@return string
local function module_fmt(src)
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
_G.__FILE__ = function()
    return debug.getinfo(3, "S").source
end
---@return number line #calling line
_G.__LINE__ = function()
    return debug.getinfo(3, "l").currentline
end
---@return string funcname #calling func
_G.__FUNC__ = function()
    return debug.getinfo(3, "n").name or "NA"
end
---@return string module #calling module
_G.__MODULE__ = function()
    return module_fmt(debug.getinfo(3, "S").source)
end
---@return string #'module.function:line'
_G.__TRACEBACK__ = function()
    local info = debug.getinfo(3)
    local module = module_fmt(info.source)
    return ("%s.%s:%d"):format(module, info.name, info.currentline)
end

---@return string module #calling module (callstack level 2)
local __FMODULE__ = function()
    return module_fmt(debug.getinfo(2, "S").source)
end

---Get current file name
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
    local module = module_fmt(source)
    return ("%s.%s:%d"):format(module, info.name, info.currentline)
    -- return source .. ":" .. info.linedefined
end

---@class LogDumpOpts
---@field loc? string location
---@field level? integer log level
---@field thread? integer debug thread scope
---@field title? string notification title
---@field once? boolean exec once

---@param value any
---@param opts? LogDumpOpts
---@return nil
function M.dump(value, opts)
    opts = opts or {}
    opts.loc = opts.loc or M.get_loc(opts.thread)
    if vim.in_fast_event() then
        return vim.schedule(function()
            M.dump(value, opts)
        end)
    end
    -- opts.loc = fn.fnamemodify(opts.loc, ":~:.")
    local msg = vim.inspect(value)
    vim.notify(msg, opts.level or M.levels.INFO, {
        title = ("%s: %s"):format(opts.title or "Debug", opts.loc),
        on_open = function(win)
            vim.wo[win].conceallevel = 3
            vim.wo[win].concealcursor = ""
            vim.wo[win].spell = false
            local buf = api.nvim_win_get_buf(win)
            if not pcall(vim.treesitter.start, buf, "lua") then
                vim.bo[buf].ft = "lua"
            end
        end,
        once = opts.once,
    })
end

---@class Log.Config
local default_config = {
    -- Name of the plugin. Prepended to log messages
    plugin = "nvim",
    -- Should print the output to neovim while running
    -- values: 'sync','async',false
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
        {name = "trace", hl = "@bold"},
        {name = "debug", hl = "Title"},
        {name = "info", hl = "MoreMsg"},
        {name = "warn", hl = "@text.warning"},
        {name = "error", hl = "ErrorMsg"},
        {name = "fatal", hl = "ErrorMsg"},
    },
    -- Can limit the number of decimals displayed for floats
    float_precision = 0.01,
}

local built = log.new(default_config, false)
local qf_built
local file_built

---@return fun(): table
M.qf_config = (function()
    local qf_config
    return function()
        if not qf_config then
            qf_config = D.tbl_clone(default_config)
        end
        qf_config.use_quickfix = true
        qf_config.use_console = false

        if not qf_built then
            qf_built = log.new(qf_config, false)
        end
        return qf_built
    end
end)()

---@return fun(fname: string): table
M.file_config = (function()
    local file_config
    return function(fname)
        if not file_config then
            file_config = D.tbl_clone(default_config)
        end
        file_config.plugin = fname
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
---@param opts? NotifyOpts
M.trace = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo({
            {"[DEBUG]: ", "@text.trace"},
            {msg, F.if_nil(opts.hl, "NotifyTRACEBody")},
        })
    else
        require("common.utils").notify(msg, M.levels.TRACE, opts)
    end
end

---DEBUG message
---@param msg string|string[]
---@param opts? NotifyOpts
M.debug = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo({
            {"[DEBUG]: ", "@text.debug"},
            {msg, F.if_nil(opts.hl, "NotifyDEBUGBody")},
        })
    else
        require("common.utils").notify(msg, M.levels.DEBUG, opts)
    end
end

---INFO message
---@param msg string|string[]
---@param opts? NotifyOpts
M.info = function(msg, opts)
    opts = opts or {}
    local args = {{msg, F.if_nil(opts.hl, "NotifyINFOorder")}}
    if opts.dprint then
        opts.debug = true
        opts.print = true
    end
    if opts.debug and opts.print then
        args = D.vec_insert(
            args,
            {__FMODULE__(), "Title"},
            {".", "Normal"},
            {__FUNC__(), "Function"},
            {":", "Normal"},
            {("%d: "):format(__LINE__()), "MoreMsg"}
        )
    end
    if opts.print then
        nvim.echo({{"[INFO]: ", "@text.info"}, unpack(args)})
    else
        if opts.debug then
            if not opts.title then
                opts.title = __TRACEBACK__()
                opts.debug = nil
            else
                msg = ("%s\n%s"):format(__TRACEBACK__(), msg)
            end
        end
        require("common.utils").notify(msg, M.levels.INFO, opts)
    end
end

---WARN message
---@param msg string|string[]
---@param opts? NotifyOpts
M.warn = function(msg, opts)
    opts = opts or {}
    local args = {{msg, F.if_nil(opts.hl, "NotifyWARNorder")}}
    if opts.dprint then
        opts.debug = true
        opts.print = true
    end
    if opts.debug and opts.print then
        args = D.vec_insert(
            args,
            {__FMODULE__(), "Title"},
            {".", "Normal"},
            {__FUNC__(), "Function"},
            {":", "Normal"},
            {("%d: "):format(__LINE__()), "MoreMsg"}
        )
    end
    if opts.print then
        nvim.echo({{"[WARN]: ", "@text.warning"}, unpack(args)})
    else
        if opts.debug then
            if not opts.title then
                opts.title = __TRACEBACK__()
                opts.debug = nil
            else
                msg = ("%s\n%s"):format(__TRACEBACK__(), msg)
            end
        end
        require("common.utils").notify(msg, M.levels.WARN, opts)
    end
end

---ERROR message
---@param msg string|string[]
---@param opts? NotifyOpts
M.err = function(msg, opts)
    opts = opts or {}
    local args = {{msg, F.if_nil(opts.hl, "NotifyERRORBorder")}}
    if opts.dprint then
        opts.debug = true
        opts.print = true
    end
    if opts.debug and opts.print then
        args = D.vec_insert(
            args,
            {__FMODULE__(), "Title"},
            {".", "Normal"},
            {__FUNC__(), "Function"},
            {":", "Normal"},
            {("%d: "):format(__LINE__()), "MoreMsg"}
        )
    end
    if opts.print then
        nvim.echo({{"[ERROR]: ", "@text.error"}, unpack(args)})
    else
        if opts.debug then
            if not opts.title then
                opts.title = __TRACEBACK__()
                opts.debug = nil
            else
                msg = ("%s\n%s"):format(__TRACEBACK__(), msg)
            end
        end
        require("common.utils").notify(msg, M.levels.ERROR, opts)
    end
end

return M
