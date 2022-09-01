local M = {}

local utils = require("common.utils")
local augroup = utils.augroup

local api = vim.api

local last_wv
local winid
local bufnr
local report

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
    last_wv = utils.save_win_positions(bufnr)
    report = vim.o.report
    -- skip `update_topline_redraw` in `op_yank_reg` caller
    vim.o.report = 65535
end

---Reset window view options
function M.clear_wv()
    last_wv = nil
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
        vim.v.event.operator == "y" and last_wv and api.nvim_get_current_win() == winid and
            api.nvim_get_current_buf() == bufnr
     then
        last_wv.restore()
    end
    M.clear_wv()
end

---Yank an item to a given register and notify
---@param regname string register to copy to
---@param context string text to copy
---@param level number?
---@param opts table?
function M.yank_reg(regname, context, level, opts)
    nvim.reg[regname] = context
    vim.notify(context, level, opts)
end

local function init()
    augroup(
        "TextYank",
        {
            event = "TextYankPost",
            pattern = "*",
            command = function()
                require("common.yank").restore()
            end
        }
    )
end

init()

return M
