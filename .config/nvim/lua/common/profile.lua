local M = {}

PROFILE_LOAD = false

if PROFILE_LOAD then
  require("plenary.profile").start("/tmp/nvim_flame.log", { flame = true })
end

--- Usage:
--- 1. Call `local stop = utils.profile('my-log')` at the top of the file
--- 2. At the bottom of the file call `stop()`
--- 3. Restart neovim, the newly created log file should open
M.profile = function(filename)
    local base = "/tmp/config/profile/"
    fn.mkdir(base, "p")
    local success, profile = pcall(require, "plenary.profile.lua_profiler")
    if not success then
        api.nvim_echo({{"Plenary is not installed.", "Title"}}, true, {})
    end
    profile.start()
    return function()
        profile.stop()
        local logfile = base .. filename .. ".log"
        profile.report(logfile)
        vim.defer_fn(
            function()
                cmd("tabedit " .. logfile)
            end,
            1000
        )
    end
end

return M
