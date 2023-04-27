--@module common.utils.async
---@description: Async utility functions
---              They are a higher-level set than `dev`
local M = {}

-- local debounce = require("common.debounce")
-- local disposable = require("common.disposable")
-- local uva = require("uva")
-- local async = require("async")

local uv = vim.loop
-- local api = vim.api
-- local fn = vim.fn
-- local cmd = vim.cmd
-- local F = vim.F

---Set a timeout
---@param callback function
---@param ms number
---@return uv_timer_t?
M.setTimeout = function(callback, ms)
    local timer = uv.new_timer()
    timer:start(
        ms,
        0,
        function()
            timer:close()
            callback()
        end
    )
    return timer
end

---@param ms number
---@return Promise
M.wait = function(ms)
    return require("promise")(
        function(resolve)
            local timer = uv.new_timer()
            timer:start(
                ms,
                0,
                function()
                    timer:close()
                    resolve()
                end
            )
        end
    )
end

return M
