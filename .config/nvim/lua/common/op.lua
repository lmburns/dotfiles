local M = {}

local utils = require("common.utils")
local log = require("common.log")
local mpi = require("common.api")
local map = mpi.map

local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local F = vim.F

---@alias MarkPos {row: integer, col: integer}
---@alias MarkPosTable {start: MarkPos, finish: MarkPos}

---Determine whether user in in visual mode
---@param mode? string optional mode
---@param ret? boolean return mode
---@return boolean|boolean, string
function M.is_visual(mode, ret)
    mode = mode or utils.mode()
    local matches = mode:match("[vV]") ~= nil or M.is_blockwise(mode)
    -- return ret and matches, mode or matches
    if F.unwrap_or(ret, false) then
        return matches, mode
    end
    return matches
end

---Determine whether user in in blockwise visual mode
---@param mode? string optional mode
---@param ret? boolean return mode
---@return boolean|boolean, string
function M.is_blockwise(mode, ret)
    mode = mode or utils.mode()
    local matches = mode:byte() == 22 or mode == "block" or mode == "b"
    -- return ret and matches, mode or matches
    if F.unwrap_or(ret, false) then
        return matches, mode
    end
    return matches
end

---A function to return the register type to distinguish between visual modes
---@param mode string
---@return char
function M.register_type(mode)
    mode = mode or utils.mode()
    if M.is_blockwise(mode) or "b" == mode then
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

    -- M.state.register = opts.reg or vim.v.register

    -- local select_save = vim.o.selection
    -- vim.o.selection = "inclusive"
    -- local reg_save = nvim.reg["@"]

    local count = opts.count or (vim.v.count > 0 and vim.v.count or 1)
    if not opts.cb:startswith("v:lua.") then
        opts.cb = ("v:lua.%s"):format(opts.cb)
    end

    vim.o.operatorfunc = opts.cb
    utils.normal({"m", "i"}, ("%dg@%s"):format(count, opts.motion or ""))

    -- vim.o.selection = select_save
    -- nvim.reg["@"] = reg_save
end

---Get the current visual selection
---@return string
M.get_visual_selection_og = function()
    -- this will exit visual mode
    -- use 'gv' to reselect the text
    local _, csrow, cscol, cerow, cecol
    local is_visual, mode = M.is_visual(nil, true)
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
    mode = mode or utils.mode()
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
---@param bufnr? integer
---@return MarkPosTable
function M.get_region(mode, bufnr)
    bufnr = F.unwrap_or(bufnr, 0)
    local is_visual = M.is_visual(mode)
    local smark, emark = "[", "]"
    if is_visual then
        smark, emark = "<", ">"
    end

    local spos = api.nvim_buf_get_mark(bufnr, smark)
    local epos = api.nvim_buf_get_mark(bufnr, emark)

    local ret = {
        start = {row = spos[1], col = spos[2]},
        finish = {row = epos[1], col = epos[2]},
    }
    if ret.finish.row < ret.start.row then
        ret.start.row, ret.finish.row = ret.finish.row, ret.start.row
    end
    if ret.finish.col < ret.start.col then
        ret.start.col, ret.finish.col = ret.finish.col, ret.start.col
    end
    return ret
end

---Turn region markers into text
---@param region MarkPosTable
---@param mode? string
---@param bufnr? integer
---@return table
function M.get_text(region, mode, bufnr)
    bufnr = F.unwrap_or(bufnr, 0)
    local regtype = M.register_type(mode)
    local start, finish = region.start, region.finish

    if regtype == "l" then
        return api.nvim_buf_get_lines(bufnr, start.row - 1, finish.row, false)
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

            local lines = api.nvim_buf_get_text(bufnr, row - 1, start.col, row - 1, ecol, {})
            for _, line in pairs(lines) do
                table.insert(text, line)
            end
        end

        return text
    end

    return api.nvim_buf_get_text(0, start.row - 1, start.col, finish.row - 1, finish.col + 1, {})
end

local function init()
end

init()

return M
