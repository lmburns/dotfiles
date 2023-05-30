---@module 'usr.plugs.bufclean'
---@description Automatically delete listed buffers that have been untouched for 10 minutes
local M = {}

local async = require("async")
-- local debounce = require("usr.lib.debounce")
-- local throttle = require("usr.lib.throttle")
local a = require("usr.shared.utils.async")
local log = require("usr.lib.log")

local api = vim.api
local uv = vim.loop

M.CLEANUP_INTERVAL = 1000 * 60
M.EXPIRATION_TIME = 1000 * 60 * 10 -- 10 min

---@type Closeable?
M._interval = nil

---@type { [integer]: bufclean.BufState }
M.state_map = {}

---@class bufclean.BufState
---@field changetick integer
---@field timestamp number

---@return bufclean.BufState
local function new_buf_state(bufnr, opt)
    opt = opt or {}
    return {
        changetick = opt.changetick or api.nvim_buf_get_changedtick(bufnr),
        timestamp = opt.timestamp or (uv.hrtime() / 1000000),
    }
end

function M.enable()
    if M._interval then
        log.warn("Already running.", {title = "bufclean"})
        return
    end

    M._interval = a.setInterval(function()
        async(function()
            await(a.scheduler())
            local bufs = vim.tbl_filter(
                function(bufnr)
                    return vim.bo[bufnr].buflisted
                end,
                api.nvim_list_bufs()
            ) --[[@as integer[] ]]

            local win_buf_map = {}

            for _, winid in ipairs(api.nvim_list_wins()) do
                win_buf_map[api.nvim_win_get_buf(winid)] = winid
            end

            local now = uv.hrtime() / 1000000

            for _, bufnr in ipairs(bufs) do
                local buf_state = M.state_map[bufnr]

                if not buf_state then
                    -- This is a new buffer: save its state and continue
                    M.state_map[bufnr] = new_buf_state(bufnr, {timestamp = now})
                else
                    local changetick = api.nvim_buf_get_changedtick(bufnr)

                    if changetick > buf_state.changetick then
                        -- changetick has been incremented: update state
                        M.state_map[bufnr] = new_buf_state(bufnr,
                            {changetick = changetick, timestamp = now})
                    else
                        -- Check timestamp
                        if
                            now - buf_state.timestamp > M.EXPIRATION_TIME -- Check if expired
                            and not win_buf_map[bufnr]                    -- Don't delete buffers that are displayed in a window
                            and not vim.bo[bufnr].modified                -- Don't delete buffers if they're modified
                        then
                            -- Buffer has expired: delete
                            local ok, err = pcall(api.nvim_buf_delete, bufnr, {})

                            if not ok and err then
                                api.nvim_err_writeln(err)
                            else
                                M.state_map[bufnr] = nil
                            end
                        end
                    end
                end
            end
        end)
    end, M.CLEANUP_INTERVAL)
end

function M.disable()
    if M._interval then
        M._interval.close()
        M._interval = nil
    end
end

return M
