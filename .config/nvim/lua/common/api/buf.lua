--@module common.api.buf
---@description: Interaction with buffers
local M = {}

local D = require("dev")

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local F = vim.F

---Determine whether the buffer is empty
---@param bufnr? integer
---@return boolean
M.buf_is_empty = function(bufnr)
    -- fn.empty(fn.expand("%:t")) ~= 1
    local lines = api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)
    return #lines == 1 and lines[1] == ""
end

---`api.nvim_buf_is_loaded` filters out all hidden buffers
---Has to have attribute 'buflisted'
---@param bufnr integer
---@return boolean
M.buf_is_valid = function(bufnr)
    if not bufnr or bufnr < 1 then
        return false
    end
    local exists = api.nvim_buf_is_valid(bufnr)
    return vim.bo[bufnr].buflisted and exists
end

---Check whether the current buffer is modified
---@param bufnr? integer
---@return boolean
M.buf_is_modified = function(bufnr)
    vim.validate{
        bufnr = {
            bufnr,
            function(b)
                local t = type(b)
                return (t == "number" and b >= 1) or t == "nil"
            end,
            "number >= 1 or nil",
        },
    }

    bufnr = bufnr or api.nvim_get_current_buf()
    return vim.bo[bufnr].modified
end

---Get the number of buffers
---@return number
M.buf_get_count = function()
    return #fn.getbufinfo({buflisted = 1})
end

---List buffers matching options
---@param opts? ListBufOpts
---@return integer[]
M.list_bufs = function(opts)
    opts = opts or {}

    vim.validate{
        loaded = {opts.loaded, {"b"}, true},
        valid = {opts.valid, {"b"}, true},
        listed = {opts.listed, {"b"}, true},
        modified = {opts.modified, {"b"}, true},
        empty = {opts.empty, {"b"}, true},
        no_hidden = {opts.no_hidden, {"b"}, true},
        tabpage = {opts.tabpage, {"n"}, true},
        buftype = {opts.buftype, {"s", "t"}, true},
        bufname = {opts.bufname, {"s"}, true},
        bufpath = {opts.bufpath, {"s"}, true},
        options = {opts.options, {"t"}, true},
        vars = {opts.vars, {"t"}, true},
        winid = {opts.winid, {"n", "t"}, true},
        winnr = {opts.winnr, {"n", "t"}, true},
    }

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

    return D.filter(
        bufs,
        function(bufnr)
            -- if opts.valid and not M.buf_is_valid(bufnr) then

            if opts.loaded and not api.nvim_buf_is_loaded(bufnr) then
                return false
            end
            if opts.valid and not api.nvim_buf_is_valid(bufnr) then
                return false
            end
            if opts.listed and not vim.bo[bufnr].buflisted then
                return false
            end
            -- if opts.modified and not M.buf_is_modified(bufnr) then
            if opts.modified and not vim.bo[bufnr].modified then
                return false
            end
            if opts.empty and M.buf_is_empty(bufnr) then
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
        end
    )
end

---Get buffer info of buffers that match given options
---@param opts ListBufOpts
---@return number[]
M.buf_info = function(opts)
    return D.map(
        M.list_bufs(opts),
        function(bufnr)
            return fn.getbufinfo(bufnr) --[==[@as Array<Dict<any>>]==]
        end
    )
end

---Check if the buffer name matches a terminal buffer name
---@param bufname? string
---@return boolean
M.bufname_is_term = function(bufname)
    bufname = F.unwrap_or(bufname, fn.bufname())
    if bufname:match("term://") then
        return true
    end
    return false
end

---Check if the given buffer is a terminal buffer
---@param bufnr number?
---@return boolean
M.buftype_is_term = function(bufnr)
    bufnr = tonumber(bufnr) or 0
    bufnr = bufnr == 0 and api.nvim_get_current_buf() or bufnr
    local winid = fn.bufwinid(bufnr)
    if tonumber(winid) > 0 and api.nvim_win_is_valid(winid) then
        return fn.getwininfo(winid)[1].terminal == 1
    end
    local bufname = M.buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr)
    return M.bufname_is_term(bufname)
end

--  ══════════════════════════════════════════════════════════════════════

---Bufwipe buffers that aren't modified and haven't been saved (i.e., don't have a titlestring)
M.buf_clean_empty = function()
    local bufnrs = {}
    for _, bufnr in ipairs(M.list_bufs({bufpath = "", modified = false})) do
        table.insert(bufnrs, bufnr)
    end
    if #bufnrs > 0 then
        cmd("bw " .. table.concat(bufnrs, " "))
    end
end

---Set a list of marks
---@param marks string[] builtin marks to be set
---@param bufnr? number buffer where marks should be set
M.buf_set_marks = function(marks, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    for _, mark in pairs(marks) do
        local _, lnum, col, _ = unpack(mark.pos)
        api.nvim_buf_set_mark(bufnr, mark.mark:sub(2, 2), lnum, col, {})
    end
end

return M
