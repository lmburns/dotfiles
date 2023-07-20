---@module 'usr.api.buf'
---@description Interaction with buffers
---@class Api.Buf
local M = {}

local lazy = require("usr.lazy")
local shared = require("usr.shared")
local utils = shared.utils
local F = shared.F
local C = shared.collection
local W = lazy.require("usr.api.win") ---@module 'usr.api.win'

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

---Determine whether the buffer is empty
---@param bufnr? integer
---@return boolean
function M.buf_is_empty(bufnr)
    -- fn.empty(fn.expand("%:t")) ~= 1
    local lines = api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)
    return #lines == 1 and lines[1] == ""
end

---`api.nvim_buf_is_loaded` filters out all hidden buffers
---Has to have attribute 'buflisted'
---@param bufnr integer
---@return boolean
function M.buf_is_valid(bufnr)
    if not bufnr or bufnr < 1 then
        return false
    end
    local exists = api.nvim_buf_is_valid(bufnr)
    return vim.bo[bufnr].buflisted and exists
end

---Check whether the current buffer is modified
---@param bufnr? integer
---@return boolean
function M.buf_is_modified(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    return vim.bo[bufnr].modified
end

---Get the number of listed buffers
---@return number
function M.buf_get_count()
    return #fn.getbufinfo({buflisted = 1})
end

---Get the byte size of a buffer in kilobytes.
---
---Approximations of file size going by number of lines in normal code
---(i.e. not minified):
---
--- 2500 lines   ≅ 84.62 kb
--- 5000 lines   ≅ 165.76 kb
--- 10000 lines  ≅ 320.86 kb
--- 20000 lines  ≅ 649.94 kb
--- 40000 lines  ≅ 1314.56 kb
--- 80000 lines  ≅ 2634.88 kb
--- 160000 lines ≅ 5249.33 kb
--- 320000 lines ≅ 10656.35 kb
---@param bufnr? bufnr
---@return integer
function M.buf_get_size(bufnr)
    bufnr = F.tern(bufnr == 0 or bufnr == nil, api.nvim_get_current_buf(), bufnr)
    local bytes = api.nvim_buf_get_offset(bufnr, api.nvim_buf_line_count(bufnr))
    return bytes / 1024
end

---Like `fn.bufwinid` except it works across tabpages
---@param bufnr bufnr
---@return winid?
function M.buftabwinid(bufnr)
    for _, win in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(win) == bufnr then
            return win
        end
    end
end

---Determine whether a buffer is hidden
---@param bufnr bufnr
---@return boolean
function M.buf_is_hidden(bufnr)
    for _, tabid in ipairs(api.nvim_list_tabpages()) do
        for _, winid in ipairs(api.nvim_tabpage_list_wins(tabid)) do
            local winbuf = api.nvim_win_get_buf(winid)
            if api.nvim_win_is_valid(winid) and winbuf == bufnr then
                return false
            end
        end
    end
    -- for _, tabnr in ipairs(fn.range(1, fn.tabpagenr("$"))) do
    --     for _, buf in ipairs(fn.tabpagebuflist(tabnr)) do
    --     end
    -- end
    return true
end

---List buffers matching options
---@param opts? ListBuf.Opts
---@return integer[]
function M.list_bufs(opts)
    opts = opts or {}

    vim.validate({
        loaded = {opts.loaded, {"b"}, true},
        valid = {opts.valid, {"b"}, true},
        listed = {opts.listed, {"b"}, true},
        modified = {opts.modified, {"b"}, true},
        empty = {opts.empty, {"b"}, true},
        no_hidden = {opts.no_hidden, {"b"}, true},
        hidden = {opts.hidden, {"b"}, true},
        tabpage = {opts.tabpage, {"n"}, true},
        buftype = {opts.buftype, {"s", "t"}, true},
        bufname = {opts.bufname, {"s"}, true},
        bufpath = {opts.bufpath, {"s"}, true},
        options = {opts.options, {"t"}, true},
        vars = {opts.vars, {"t"}, true},
        winid = {opts.winid, {"n", "t"}, true},
        winnr = {opts.winnr, {"n", "t"}, true},
    })

    -- lnum = line count
    -- last_used
    -- bufinfo.windows

    ---@type integer[]
    local bufs

    if opts.no_hidden or opts.tabpage then
        local wins = opts.tabpage
            and api.nvim_tabpage_list_wins(opts.tabpage)
            or api.nvim_list_wins()
        local bufnr ---@type integer
        local seen = {} ---@type { [number]: boolean }
        bufs = {} ---@type integer[]
        for _, winid in ipairs(wins) do
            bufnr = api.nvim_win_get_buf(winid)
            if not seen[bufnr] then
                table.insert(bufs, bufnr)
            end
            seen[bufnr] = true
        end
    else
        bufs = api.nvim_list_bufs()
    end

    local winids = {} ---@type integer[]
    if opts.winid then
        local id = opts.winid
        winids = type(id) == "number" and {id} or id --[=[@as integer[]]=]
    end

    local winnrs = {} ---@type integer[]
    if opts.winnr then
        local nr = opts.winnr
        winnrs = type(nr) == "number" and {nr} or nr --[=[@as integer[]]=]
    end

    return C.filter(bufs, function(bufnr)
        -- if opts.valid and not M.buf_is_valid(bufnr) then
        -- if opts.modified and not M.buf_is_modified(bufnr) then

        if F.is.bool(opts.hidden)
            and ((opts.hidden and not M.buf_is_hidden(bufnr))
                or (not opts.hidden and M.buf_is_hidden(bufnr))) then
            return false
        end

        if F.is.bool(opts.loaded)
            and ((opts.loaded and not api.nvim_buf_is_loaded(bufnr))
                or (not opts.loaded and api.nvim_buf_is_loaded(bufnr))) then
            return false
        end

        if F.is.bool(opts.valid)
            and ((opts.valid and not api.nvim_buf_is_valid(bufnr))
                or (not opts.valid and api.nvim_buf_is_valid(bufnr))) then
            return false
        end

        if F.is.bool(opts.listed)
            and ((opts.listed and not vim.bo[bufnr].buflisted)
                or (not opts.listed and vim.bo[bufnr].buflisted)) then
            return false
        end

        if F.is.bool(opts.modified)
            and ((opts.modified and not vim.bo[bufnr].modified)
                or (not opts.modified and vim.bo[bufnr].modified)) then
            return false
        end

        if F.is.bool(opts.empty)
            and ((opts.empty and not M.buf_is_empty(bufnr))
                or (not opts.empty and M.buf_is_empty(bufnr))) then
            return false
        end

        if opts.bufname then
            local bufname = fn.bufname(bufnr)
            if opts.bufname == "" then
                if opts.bufname ~= bufname then
                    return false
                end
            else
                if not bufname:match(opts.bufname) then
                    return false
                end
            end
        end
        if opts.bufpath then
            local bufpath = api.nvim_buf_get_name(bufnr)
            if opts.bufpath == "" then
                if opts.bufpath ~= bufpath then
                    return false
                end
            else
                if not bufpath:match(opts.bufpath) then
                    return false
                end
            end
        end

        local buftype_t = type(opts.buftype)
        if buftype_t == "string" and not vim.bo[bufnr].buftype == opts.buftype then
            -- Have to check for "" buftype
            return false
        end
        if buftype_t == "table" then
            for _, bt in ipairs(opts.buftype) do
                if type(bt) == "string" and not vim.bo[bufnr].buftype == bt then
                    return false
                end
            end
        end
        if opts.options then
            for option, value in pairs(opts.options) do
                -- if vim.bo[bufnr][var] ~= value then
                local ok, v = pcall(api.nvim_buf_get_option, bufnr, option)
                if not ok or v ~= value then
                    return false
                end
            end
        end
        if opts.vars then
            for var, value in pairs(opts.vars) do
                -- if vim.b[bufnr][var] ~= value then
                local ok, v = pcall(api.nvim_buf_get_var, bufnr, var)
                if not ok or v ~= value then
                    return false
                end
            end
        end

        if opts.winnr then
            for _, nr in ipairs(winnrs) do
                if fn.winbufnr(nr) ~= bufnr then
                    return false
                end
            end
        end
        if opts.winid then
            for _, id in ipairs(winids) do
                local found = fn.win_findbuf(bufnr)
                for _, idr in ipairs(found) do
                    if idr ~= id then
                        return false
                    end
                end
            end
        end
        return true
    end)
end

---Get buffer info of buffers that match given options
---@param opts ListBuf.Opts
---@return table[]
function M.buf_info(opts)
    return C.map(M.list_bufs(opts), function(bufnr)
        return unpack(fn.getbufinfo(bufnr))
    end)
end

---Get buffer info of buffers that match given options. Minus extra junk
---@param opts ListBuf.Opts
---@return table[]
function M.buf_info_short(opts)
    return C.map(M.list_bufs(opts), function(bufnr)
        return unpack(C.map(fn.getbufinfo(bufnr), function(b)
            return {
                bufnr = b.bufnr,
                name = b.name,
                changed = b.changed,
                changedtick = b.changedtick,
                hidden = b.hidden,
                lastused = b.lastused,
                linecount = b.linecount,
                listed = b.listed,
                lnum = b.lnum,
                loaded = b.loaded,
                windows = b.windows,
                -- undo_ftplugin = b.variables and b.variables.undo_ftplugin,
            }
        end))
    end)
end

---Check if the buffer name matches a terminal buffer name
---@param bufname? string
---@return boolean
function M.bufname_is_term(bufname)
    bufname = F.unwrap_or(bufname, fn.bufname()) --[[@as string]]
    if bufname:match("term://") then
        return true
    end
    return false
end

---Check if the given buffer is a terminal buffer
---@param bufnr number?
---@return boolean
function M.buftype_is_term(bufnr)
    bufnr = tonumber(bufnr) or 0
    bufnr = bufnr == 0 and api.nvim_get_current_buf() or bufnr
    local winid = fn.bufwinid(bufnr)
    if tonumber(winid) > 0 and api.nvim_win_is_valid(winid) then
        return fn.getwininfo(winid)[1].terminal == 1
    end
    local bufname = M.buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr)
    return M.bufname_is_term(bufname)
end

local exclude_ft = Rc.blacklist.ft:filter(utils.lambda("x -> x ~= ''"))
local include_bt = _t({"", "acwrite"})
local exclude_bufname = Rc.blacklist.bufname:filter(utils.lambda("x -> x ~= ''"))

---
---@param bufnr? number
---@param winid? number
---@param exft? string[] filetypes to exclude
---@param inbt? string[] buffer types to include
---@return boolean
function M.buf_should_exclude(bufnr, winid, exft, inbt)
    bufnr = bufnr or api.nvim_get_current_buf()
    local bufpath = api.nvim_buf_get_name(bufnr)
    local bufname = fn.bufname(bufnr)
    winid = winid or fn.bufwinid(bufnr)
    exft = exft or exclude_ft
    inbt = inbt or include_bt
    if
        bufpath == ""
        or not fn.filereadable(bufpath)
        or bufname == "[No Name]"
        or exclude_bufname:any(function(b) return bufname:match(b) end)
        or exclude_ft:contains(vim.bo[bufnr].ft)
        or not include_bt:contains(vim.bo[bufnr].bt)
        or not vim.bo[bufnr].buflisted
        or W.win_is_float(winid)
    then
        return true
    end
    return false
end

--  ══════════════════════════════════════════════════════════════════════

---Bufwipe buffers that aren't modified and haven't been saved (i.e., don't have a titlestring)
---Using `bw` instead of `api.nvim_buf_delete` will show a notification of
---the number of buffers wiped.
function M.buf_clean_empty()
    local bufnrs = M.list_bufs({bufpath = "", modified = false})
    if #bufnrs > 0 then
        cmd("bw " .. table.concat(bufnrs, " "))
    end
end

---Bufwipe buffers that are hidden.
function M.buf_clean_hidden()
    local bufnrs = M.list_bufs({hidden = true, modified = false})
    if #bufnrs > 0 then
        cmd("bw " .. table.concat(bufnrs, " "))
    end
end

---Wipe all buffers
function M.buf_wipe_all()
    for _, id in ipairs(api.nvim_list_bufs()) do
        pcall(api.nvim_buf_delete, id, {})
    end
end

---Set a list of marks
---@param marks {mark: string, pos: {[1]: int, [2]: int, [3]: int, [4]: int}}[] builtin marks to be set
---@param bufnr? bufnr buffer where marks should be set
function M.buf_set_marks(marks, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    for _, mark in pairs(marks) do
        local _, lnum, col, _ = unpack(mark.pos)
        api.nvim_buf_set_mark(bufnr, mark.mark:sub(2, 2), lnum, col, {})
    end
end

return M
