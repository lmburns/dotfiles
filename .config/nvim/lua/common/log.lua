local M = {}

local log = require("plenary.log")

local api = vim.api

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
M.info = function(msg, notify)
    if notify then
        vim.notify(msg, M.levels.INFO)
    else
        api.nvim_echo({{msg, "SpellCap"}}, true, {})
    end
end

M.warn = function(msg, notify)
    if notify then
        vim.notify(msg, M.levels.WARN)
    else
        api.nvim_echo({{msg, "WarningMsg"}}, true, {})
    end
end

M.err = function(msg, notify)
    if notify then
        vim.notify(msg, M.levels.ERROR)
    else
        api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    end
end

return M
