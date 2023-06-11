---@module 'usr.lib.yank'
---@class Usr.Lib.Yank
local M = {}

local log = Rc.lib.log
local utils = Rc.shared.utils
local W = Rc.api.win
local augroup = Rc.api.augroup

local api = vim.api

local wv
local winid
local bufnr
local report

---
---@param suffix string
---@return string
function M.wrap(suffix)
    if utils.mode() == "n" then
        M.set_wv()
    else
        M.clear_wv()
    end
    return type(suffix) == "string" and ("y" .. suffix) or "y"
end

---Set window view options
function M.set_wv()
    winid = api.nvim_get_current_win()
    bufnr = api.nvim_get_current_buf()
    wv = W.win_save_positions(bufnr)
    report = vim.o.report
    -- skip `update_topline_redraw` in `op_yank_reg` caller
    vim.o.report = 65535
end

---Reset window view options
function M.clear_wv()
    wv = nil
    winid = nil
    bufnr = nil
    if report then
        vim.o.report = report
        report = nil
    end
end

---Restore window view
function M.restore()
    if
        vim.v.event.operator == "y"
        and wv
        and api.nvim_get_current_win() == winid
        and api.nvim_get_current_buf() == bufnr
    then
        wv.restore()
    end
    M.clear_wv()
end

---Yank an item to a given register and notify
---@param regname string register to copy to
---@param context string text to copy
---@param opts? NotifyOpts
function M.yank_reg(regname, context, opts)
    context = fn.expand(context)
    nvim.reg[regname] = context
    log.info(context, opts)
end

local function init()
    augroup(
        "TextYank",
        {
            event = "TextYankPost",
            pattern = "*",
            command = function()
                require("usr.lib.yank").restore()
            end,
        }
    )
end

init()

return M
