local M = {}

local log = require("plenary.log")

---@enum LogLevels
M.levels = {
    TRACE = 0,
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    OFF = 5
}

-- ---@type LogLevels
-- vim.log.levels = vim.log.levels

-- _G.__FILE__ = function() return debug.getinfo(3, 'S').source end
-- _G.__LINE__ = function() return debug.getinfo(3, 'l').currentline end
-- _G.__FUNC__ = function() return debug.getinfo(3, 'n').name end

local default_config = {
    -- Name of the plugin. Prepended to log messages
    plugin = "nvim",
    -- Should print the output to neovim while running
    -- values: 'sync','async',false
    use_console = "async",
    -- Should highlighting be used in console (using echohl)
    highlights = true,
    -- Should write to a file
    use_file = true,
    -- Should write to the quickfix list
    use_quickfix = false,
    -- Any messages above this level will be logged.
    level = "info",
    -- Level configuration
    modes = {
        {name = "trace", hl = "Comment"},
        {name = "debug", hl = "Comment"},
        {name = "info", hl = "None"},
        {name = "warn", hl = "WarningMsg"},
        {name = "error", hl = "ErrorMsg"},
        {name = "fatal", hl = "ErrorMsg"}
    },
    -- Can limit the number of decimals displayed for floats
    float_precision = 0.01
}

local built = log.new(default_config, true)

M.logger = built

-- api.nvim_err_writeln()

---TRACE message
---@param msg string
---@param opts? NotifyOpts
M.trace = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo(
            {
                {"[DEBUG]: ", "@text.trace"},
                {msg, F.if_nil(opts.hl, "NotifyTRACEBody")}
            }
        )
    else
        require("common.utils").notify(msg, M.levels.TRACE, opts)
    end
end

---DEBUG message
---@param msg string
---@param opts? NotifyOpts
M.debug = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo(
            {
                {"[DEBUG]: ", "@text.debug"},
                {msg, F.if_nil(opts.hl, "NotifyDEBUGBody")}
            }
        )
    else
        require("common.utils").notify(msg, M.levels.DEBUG, opts)
    end
end

---INFO message
---@param msg string
---@param opts? NotifyOpts
M.info = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo(
            {
                {"[INFO]: ", "@text.info"},
                {msg, F.if_nil(opts.hl, "NotifyINFOBorder")}
            }
        )
    else
        require("common.utils").notify(msg, M.levels.INFO, opts)
    end
end

---WARN message
---@param msg string
---@param opts? NotifyOpts
M.warn = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo(
            {
                {"[WARN]: ", "@text.warning"},
                {msg, F.if_nil(opts.hl, "NotifyWARNBorder")}
            }
        )
    else
        require("common.utils").notify(msg, M.levels.WARN, opts)
    end
end

---ERROR message
---@param msg string
---@param opts? NotifyOpts
M.err = function(msg, opts)
    opts = opts or {}
    if opts.print then
        nvim.echo(
            {
                {"[ERROR]: ", "@text.error"},
                {msg, F.if_nil(opts.hl, "NotifyERRORBorder")}
            }
        )
    else
        require("common.utils").notify(msg, M.levels.ERROR, opts)
    end
end

return M
