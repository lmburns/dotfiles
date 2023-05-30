---@module 'usr.lib.op'
local M = {}

local utils = require("usr.shared.utils")
local log = require("usr.lib.log")

local api = vim.api
local fn = vim.fn

---@alias MarkPos {row: integer, col: integer}
---@alias MarkPosTable {start: MarkPos, finish: MarkPos}

---Determine whether user in in visual mode
---@param mode? string optional mode
---@return boolean
function M.is_visual(mode)
    return (mode and mode:match("[vV]") ~= nil) or M.is_blockwise(mode)
end

---Determine whether user in in blockwise visual mode
---@param mode? string optional mode
---@return boolean
function M.is_blockwise(mode)
    return (mode and mode:byte() == 22) or mode == "block" or mode == "b"
end

---A function to return the register type to distinguish between visual modes
---@param mode string
---@return char
function M.register_type(mode)
    if M.is_blockwise(mode) or mode == "b" then
        return "b"
    end
    if mode == "V" or mode == "line" or mode == "l" then
        return "l"
    end
    return "c"
end

---@param opts OperatorOpts
function M.operator(opts)
    if not opts.cb then
        log.err("'opfunc' was not given a function", {dprint = true})
        return
    end

    local count = opts.count or (vim.v.count > 0 and vim.v.count or 1)
    if not opts.cb:startswith("v:lua.") then
        opts.cb = ("v:lua.%s"):format(opts.cb)
    end

    vim.o.operatorfunc = opts.cb
    utils.normal({"m", "i"}, ("%dg@%s"):format(count, opts.motion or ""))
end

---Get the current visual selection
---@return string
M.get_visual_selection_og = function()
    -- this will exit visual mode
    -- use 'gv' to reselect the text
    local _, csrow, cscol, cerow, cecol
    local mode = utils.mode()
    local is_visual = M.is_visual(mode)
    if is_visual then
        -- if we are in visual mode use the live position
        _, csrow, cscol, _ = unpack(fn.getpos("."))
        _, cerow, cecol, _ = unpack(fn.getpos("v"))
        if mode == "V" then
            -- visual line doesn't provide columns
            cscol, cecol = 0, 999
        end
        -- Exit visual mode
        utils.normal("n", "<Esc>")
    else
        -- otherwise, use the last known visual position
        _, csrow, cscol, _ = unpack(fn.getpos("'<"))
        _, cerow, cecol, _ = unpack(fn.getpos("'>"))
    end
    -- swap vars if needed
    if cerow < csrow then
        csrow, cerow = cerow, csrow
    end
    if cecol < cscol then
        cscol, cecol = cecol, cscol
    end
    local lines = fn.getline(csrow, cerow)
    -- local n = cerow-csrow+1
    local n = #lines
    if n <= 0 then
        return ""
    end
    lines[n] = lines[n]:sub(1, cecol)
    lines[1] = lines[1]:sub(cscol)
    return table.concat(lines, "\n")
end

---Get the current selection
---@param mode string
---@return string
function M.get_selection(mode)
    local regions = M.get_region(mode)
    local txt = table.concat(M.get_text(regions, mode), "\n")
    return txt
end

---Get the current visual selection
---@return string
function M.get_visual_selection()
    local sel = M.get_selection(fn.visualmode())
    return sel
end

---
---@param mode string
---@return MarkPosTable
function M.get_region(mode)
    local is_visual = M.is_visual(mode)
    local smark, emark = "[", "]"
    if is_visual then
        smark, emark = "<", ">"
    end

    local spos = api.nvim_buf_get_mark(0, smark)
    local epos = api.nvim_buf_get_mark(0, emark)

    return {
        start = {row = spos[1], col = spos[2]},
        finish = {row = epos[1], col = epos[2]},
    }
end

---Turn region markers into text
---@param region MarkPosTable
---@param mode? string
---@return table
function M.get_text(region, mode)
    local regtype = M.register_type(mode)
    local start, finish = region.start, region.finish
    if finish.row < start.row then
        start.row, finish.row = finish.row, start.row
    end
    if finish.col < start.col then
        start.col, finish.col = finish.col, start.col
    end

    if regtype == "l" then
        return api.nvim_buf_get_lines(0, start.row - 1, finish.row, false)
    end

    if "b" == regtype then
        local text = {}
        for row = start.row, finish.row, 1 do
            local rowlen = fn.getline(row):len()
            local ecol = rowlen > finish.col and finish.col + 1 or rowlen
            -- local ecol = rowlen > finish.col and finish.col or rowlen
            if start.col > ecol then
                ecol = start.col
            end

            local lines = api.nvim_buf_get_text(0, row - 1, start.col, row - 1, ecol, {})
            for _, line in pairs(lines) do
                table.insert(text, line)
            end
        end

        return text
    end

    return api.nvim_buf_get_text(0, start.row - 1, start.col, finish.row - 1, finish.col + 1, {})
end

---Get the location of the visual selection start.
---@return MarkPos
function M.get_visual_start()
    local pos = fn.getpos(".")
    return {row = pos[2], col = pos[3]}
    -- return {
    --     row = fn.getpos("'<")[2] - 1,
    --     col = fn.match(fn.getline("."), "\\S"),
    -- }
end

---Get the location of the visual selection end.
---@return MarkPos
function M.get_visual_end()
    local pos = fn.getpos("v")
    return {row = pos[2], col = pos[3]}
    -- return {
    --     row = fn.getpos("'>")[2] - 1,
    --     col = fn.getpos("'>")[3] - 1,
    -- }
end

function M.escape(str, exact)
  local esc = fn.escape(str, "/\\.$[]")
  return exact and ("\\<%s\\>"):format(esc) or esc
end

return M