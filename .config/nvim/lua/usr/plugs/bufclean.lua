---@module 'usr.plugs.bufclean'
---@description Automatically delete listed buffers that have been untouched for 10 minutes
local M = {}

local async = require("async")
-- local debounce = require("usr.lib.debounce")
-- local throttle = require("usr.lib.throttle")
local utils = require("usr.shared.utils")
local a = utils.async
local lib = require("usr.lib")
local log = lib.log

local api = vim.api
local uv = vim.uv

M.CLEANUP_INTERVAL = 1000 * 60
M.EXPIRATION_TIME = 1000 * 60 * 10 -- 10 min

---@type Closeable?
M._interval_handle = nil
---@type { [integer]: BufClean.BufState }
M.state_map = {}

local function get_timestamp()
    return uv.hrtime() / 1000000
end

---@return BufClean.BufState
local function new_buf_state(bufnr, opt)
    opt = opt or {}
    return {
        changetick = opt.changetick or api.nvim_buf_get_changedtick(bufnr),
        timestamp = opt.timestamp or get_timestamp(),
    }
end

---@param bufnr bufnr
---@param now time_t
---@param buf_state BufClean.BufState
---@param win_buf_map table<bufnr, winid>
local function should_delete(bufnr, now, buf_state, win_buf_map)
    if now - buf_state.timestamp < M.EXPIRATION_TIME then return false end -- check if expired
    if win_buf_map[bufnr] then return false end                            -- check if displayed in window
    if vim.bo[bufnr].modified then return false end                        -- check if modified

    if vim.bo[bufnr].bt ~= "" and vim.bo[bufnr].modifiable then
        return false -- ignore modifiable non-standard buffers
    end

    if vim.b[bufnr].bufclean_ignore ~= nil then
        return false -- ignore buffers if they have this variable
    end

    return true
end

function M.enable()
    if M._interval_handle then
        log.warn("already running", {debug = true})
        return
    end

    nvim.autocmd.lmb__BufClean = {
        event = {"BufLeave"},
        clear = true,
        pattern = "*",
        desc = "Update timestamp on tracked buffers",
        command = function(a)
            local buf_state = M.state_map[a.buf]
            if buf_state then
                buf_state.timestamp = math.max(
                    buf_state.timestamp,
                    get_timestamp() - M.EXPIRATION_TIME / 2
                )
            end
        end,
    }

    M._interval_handle = a.setInterval(function()
        async(function()
            await(a.scheduler())

            local bufs = Rc.api.buf.list_bufs({listed = true})
            local win_buf_map = {}

            for _, winid in ipairs(api.nvim_list_wins()) do
                win_buf_map[api.nvim_win_get_buf(winid)] = winid
            end

            local now = get_timestamp()

            for _, bufnr in ipairs(bufs) do
                local buf_state = M.state_map[bufnr]

                if not buf_state then
                    M.state_map[bufnr] = new_buf_state(bufnr, {timestamp = now}) -- found new buf
                else
                    local changetick = api.nvim_buf_get_changedtick(bufnr)

                    if changetick > buf_state.changetick then
                        -- changetick has been incremented: update state
                        M.state_map[bufnr] =
                            new_buf_state(
                                bufnr,
                                {changetick = changetick, timestamp = now}
                            )
                    elseif should_delete(bufnr, now, buf_state, win_buf_map) then
                        -- Buffer has expired: delete
                        local ok, err = pcall(function()
                            api.nvim_buf_delete(bufnr, {unload = true})
                            vim.bo[bufnr].buflisted = false
                        end)

                        if not ok and err then
                            api.nvim_err_writeln(err)
                        else
                            M.state_map[bufnr] = nil
                        end
                    end
                end
            end
        end)
    end, M.CLEANUP_INTERVAL)
end

function M.disable()
    Rc.api.clear_autocmd("BufClean", "BufLeave")
    if M._interval_handle then
        M._interval_handle.close()
        M._interval_handle = nil
    end
end

---@class BufClean.BufState
---@field changetick integer
---@field timestamp number

return M
