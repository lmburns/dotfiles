local M = {}

local log = require("plenary.log")

local api = vim.api

-- TODO: Finish this when feature is available
---@enum LogLevelsFinish
---| TRACE = 0 # Trace level
---| DEBUG = 1 # Debug level
---| INFO = 2 # Info level
---| WARN = 3 # Warn level
---| ERROR = 4 # Error level
---| OFF = 5 # Off level

---@alias LogLevels { TRACE: 0, DEBUG: 1, INFO: 2, WARN: 3, ERROR: 4, OFF: 5 }

---@type LogLevels
M.levels = vim.log.levels

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

---INFO message
---@param msg string
---@param notify boolean?
---@param opts NotifyOpts?
M.info = function(msg, notify, opts)
    opts = opts or {}
    if notify then
        vim.notify(msg, M.levels.INFO, opts)
    else
        api.nvim_echo({{msg, F.if_nil(opts.hl, "SpellCap")}}, true, {})
    end
end

---WARN message
---@param msg string
---@param notify boolean?
---@param opts NotifyOpts?
M.warn = function(msg, notify, opts)
    opts = opts or {}
    if notify then
        vim.notify(msg, M.levels.WARN, opts)
    else
        api.nvim_echo({{msg, F.if_nil(opts.hl, "WarningMsg")}}, true, {})
    end
end

---ERROR message
---@param msg string
---@param notify boolean?
---@param opts NotifyOpts?
M.err = function(msg, notify, opts)
    opts = opts or {}
    if notify then
        vim.notify(msg, M.levels.ERROR, opts)
    else
        api.nvim_echo({{msg, F.if_nil(opts.hl, "ErrorMsg")}}, true, {})
    end
end

return M
