---@module 'usr.lib.render'
---@description Functions to render text
---@class Usr.Lib.Render
local M = {}

local utils = Rc.shared.utils
local A = utils.async

-- local lazy = require("usr.lazy")
-- local F = lazy.require("usr.shared.F") ---@module 'usr.shared.F'
-- local uva = require("uva")
-- local async = require("async")

-- local uv = vim.loop
local api = vim.api
local fn = vim.fn

M.ns = api.nvim_create_namespace("rc.base.highlight")

---Return a 24 byte colored string
---@param color_num integer
---@param fg integer
---@return string
local function color2csi24b(color_num, fg)
    local r = math.floor(color_num / 2 ^ 16)
    local g = math.floor(math.floor(color_num / 2 ^ 8) % 2 ^ 8)
    local b = math.floor(color_num % 2 ^ 8)
    return ("%d;2;%d;%d;%d"):format(fg and 38 or 48, r, g, b)
end

local function color2csi8b(colorNum, fg)
    return ("%d;5;%d"):format(fg and 38 or 48, colorNum)
end

local ansi = {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
}

---Escaped ansi sequence
M.ansi = setmetatable({}, {
    ---@param t table
    ---@param k string
    ---@return string
    __index = function(t, k)
        local v = M.render_str("%s", k)
        rawset(t, k, v)
        return v
    end,
})

---Render an ANSI escape sequence
---@param str string
---@param group_name Highlight.Group
---@param default_fg Color.S_t?
---@param default_bg Color.S_t?
---@return string
function M.render_str(str, group_name, default_fg, default_bg)
    vim.validate({
        str = {str, "string"},
        group_name = {group_name, "string"},
        default_fg = {default_fg, "string", true},
        default_bg = {default_bg, "string", true},
    })
    local gui = vim.o.termguicolors
    local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, gui)
    if not ok or
        not (hl.foreground or hl.background or hl.reverse or hl.bold or hl.italic or hl.underline) then
        return str
    end
    local fg, bg
    if hl.reverse then
        fg = hl.background ~= nil and hl.background or nil
        bg = hl.foreground ~= nil and hl.foreground or nil
    else
        fg = hl.foreground
        bg = hl.background
    end
    local escape_prefix = ("\027[%s%s%s"):format(
        hl.bold and ";1" or "",
        hl.italic and ";3" or "",
        hl.underline and ";4" or ""
    )

    local color_to_csi = gui and color2csi24b or color2csi8b
    local escape_fg, escape_bg = "", ""
    if fg and type(fg) == "number" then
        escape_fg = ";" .. color_to_csi(fg, true)
    elseif default_fg and ansi[default_fg] then
        escape_fg = tostring(ansi[default_fg])
    end
    if bg and type(bg) == "number" then
        escape_fg = ";" .. color_to_csi(bg, false)
    elseif default_bg and ansi[default_bg] then
        escape_fg = tostring(ansi[default_fg])
    end

    return ("%s%s%sm%s\027[m"):format(escape_prefix, escape_fg, escape_bg, str)
end

local function do_unpack(pos)
    vim.validate({pos = {pos, {"t", "n"}, "must be table or number"}})
    local row, col
    if type(pos) == "table" then
        row, col = unpack(pos)
    else
        row = pos
    end
    col = col or 0
    return row, col
end

---Wrapper to deal with extmarks
---@param bufnr bufnr
---@param hl_group Highlight.Group
---@param start row_t|Cursor_t
---@param finish row_t|Cursor_t
---@param opt? Extmark.Set.Opts
---@param delay? time_t
---@param ns? namespace
---@return Promise
function M.highlight(bufnr, hl_group, start, finish, opt, delay, ns)
    vim.validate({
        bufnr = {bufnr, "number"},
        hl_group = {hl_group, "string"},
        start = {start, {"number", "table"}},
        finish = {finish, {"number", "table"}},
        opt = {opt, "table", true},
        delay = {delay, "number", true},
        ns = {ns, "number", true},
    })

    -- vim.highlight.range(bufnr, ns, "Highlight", {srow, scol}, {erow, ecol})
    local row, col = do_unpack(start)
    local end_row, end_col = do_unpack(finish)
    if end_col then
        end_col = math.min(math.max(fn.col({end_row + 1, "$"}) - 1, 0), end_col)
    end

    local o = {hl_group = hl_group, end_row = end_row, end_col = end_col}
    o = opt and vim.tbl_deep_extend("keep", o, opt) or o

    ns = ns or M.ns
    local id = api.nvim_buf_set_extmark(bufnr, ns, row, col, o)

    return A.wait(delay or 300):thenCall(function()
        pcall(api.nvim_buf_del_extmark, bufnr, ns, id)
    end)
end

---Set highlighted text
---@param bufnr bufnr
---@param ns namespace
---@param row row_t
---@param col col_t
---@param erow row_t
---@param ecol col_t
---@param hlgroup Highlight.Group
---@param priority integer
---@return uuid_t id
function M.set_highlight(bufnr, ns, row, col, erow, ecol, hlgroup, priority)
    return api.nvim_buf_set_extmark(bufnr, ns, row, col, {
        end_row = erow,
        end_col = ecol,
        hl_group = hlgroup,
        priority = priority,
    })
end

---Set virtual text
---@param bufnr bufnr
---@param ns namespace
---@param row row_t
---@param virttext string
---@param opts Extmark.Set.Opts
---@return uuid_t id
function M.set_virttext(bufnr, ns, row, virttext, opts)
    opts = opts or {}
    return api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
        id = opts.id,
        virt_text = virttext,
        virt_text_win_col = 0,
        priority = opts.priority or 10,
        hl_mode = opts.hl_mode or "combine",
    })
end

---Clears a given namespace
---@param ns namespace
---@param bufnr? bufnr
function M.clear_highlight(ns, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return M
