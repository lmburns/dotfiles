--- Tools that will help with Lua development

local M = {}

---@alias vector any[]

P = function(...)
    print(vim.inspect(...))
    return ...
end

RELOAD = function(...)
    return require("plenary.reload").reload_module(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

-- Capture output of command as a string
function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, "r"))
    local s = assert(f:read("*a"))
    f:close()
    if raw then
        return s
    end
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    s = string.gsub(s, "[\n\r]+", " ")
    return s
end

---Capture output of a command in a table
---@param command string: shell command to run
---@return table
function os.caplines(command)
    local lines = {}
    local file = io.popen(command)

    for line in file:lines() do
        table.insert(lines, line)
    end

    file:close()

    return lines
end

-- ============================== Print ===============================
-- ====================================================================

function M.inspect(v)
    local s
    local t = type(v)
    if t == "nil" then
        s = "nil"
    elseif t ~= "string" then
        s = vim.inspect(v)
    else
        s = tostring(v)
    end
    return s
end

-- Print text nicely (newline)
function _G.pln(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, M.inspect(arg))
    end

    print(table.concat(msg_tbl, "\n"))
end

-- Print text nicely
function _G.p(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, M.inspect(arg))
    end

    print(table.concat(msg_tbl, " "))
end

-- Dump table
-- function M.dump(o)
--   if type(o) == "table" then
--     local s = "{ "
--     for k, v in pairs(o) do
--       if type(k) ~= "number" then
--         k = "\"" .. k .. "\""
--       end
--       s = s .. "[" .. k .. "] = " .. dump(v) .. ","
--     end
--     return s .. "} "
--   else
--     return tostring(o)
--   end
-- end

_G.pp = vim.pretty_print

function M.round(value)
    return math.floor(value + 0.5)
end

-- ============================== Table ===============================
-- ====================================================================

---Merge two tables
---@param a 'table'
---@param b 'table'
---@return 'table'
function M.merge(a, b)
    if type(a) == "table" and type(b) == "table" then
        for k, v in pairs(b) do
            if type(v) == "table" and type(a[k] or false) == "table" then
                M.merge(a[k], v)
            else
                a[k] = v
            end
        end
    end
    return a
end

function M.tbl_pack(...)
    return {n = select("#", ...), ...}
end

function M.tbl_unpack(t, i, j)
    return unpack(t, i or 1, j or t.n or #t)
end

---Clone a table
---
---@param t table: Table to clone
---@return table
function M.tbl_clone(t)
    if not t then
        return
    end
    local clone = {}

    for k, v in pairs(t) do
        clone[k] = v
    end

    return clone
end

---Deep clone a table (i.e., clone nested tables)
---@param t table
---@return table
function M.tbl_deep_clone(t)
    if not t then
        return
    end
    local clone = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            clone[k] = M.tbl_deep_clone(v)
        else
            clone[k] = v
        end
    end

    return clone
end

---Create a shallow copy of a portion of a vector.
---@param t vector
---@param first? integer First index, inclusive
---@param last? integer Last index, inclusive
---@return vector
function M.vec_slice(t, first, last)
    local slice = {}
    for i = first or 1, last or #t do
        table.insert(slice, t[i])
    end

    return slice
end

---Join multiple vectors into one.
---@vararg vector
---@return vector
function M.vec_join(...)
    local result = {}
    local args = {...}
    local n = 0

    for i = 1, select("#", ...) do
        if type(args[i]) ~= "nil" then
            if type(args[i]) ~= "table" then
                result[n + 1] = args[i]
                n = n + 1
            else
                for j, v in ipairs(args[i]) do
                    result[n + j] = v
                end
                n = n + #args[i]
            end
        end
    end

    return result
end

---Return the first index a given object can be found in a vector, or -1 if
---it's not present.
---
---@param t vector
---@param v any
---@return integer
function M.vec_indexof(t, v)
    for i, vt in ipairs(t) do
        if vt == v then
            return i
        end
    end
    return -1
end

---Append any number of objects to the end of a vector. Pushing `nil`
---effectively does nothing.
---
---@param t vector
---@return vector t
function M.vec_push(t, ...)
    for _, v in ipairs({...}) do
        t[#t + 1] = v
    end
    return t
end

---Checks if a list-like (vector) table contains `value`.
---
---@param t table Table to check
---@param value any Value to compare
---@returns true if `t` contains `value`
M.contains = function(t, value)
    return vim.tbl_contains(t, value)
end

---Apply a function to each value in a table.
---@param tbl table
---@param func function (value)
M.map = function(tbl, func)
    -- local t = {}
    -- for k, v in pairs(tbl) do
    --     t[k] = func(v)
    -- end
    -- return t
    return vim.tbl_map(func, tbl)
end

---Filter table based on function
---@param tbl table Table to be filtered
---@param func function Function to apply filter
---@return table
M.filter = function(tbl, func)
    return vim.tbl_filter(func, tbl)
end

---Apply function to each element of table
---@param tbl Table A list of elements
---@param func function to be applied
M.each = function(tbl, func)
    for _, item in ipairs(tbl) do
        func(item)
    end
end

-- ============================== Buffers =============================
-- ====================================================================

---Return a table of the id's of loaded buffers
---@return table
function M.list_loaded_bufs()
    return vim.tbl_filter(
        function(id)
            return api.nvim_buf_is_loaded(id)
        end,
        api.nvim_list_bufs()
    )
end

function M.list_listed_bufs()
    return vim.tbl_filter(
        function(id)
            return vim.bo[id].buflisted
        end,
        api.nvim_list_bufs()
    )
end

function M.find_buf_with_var(var, value)
    for _, id in ipairs(api.nvim_list_bufs()) do
        local ok, v = pcall(api.nvim_buf_get_var, id, var)
        if ok and v == value then
            return id
        end
    end

    return nil
end

function M.find_buf_with_option(option, value)
    for _, id in ipairs(api.nvim_list_bufs()) do
        local ok, v = pcall(api.nvim_buf_get_option, id, option)
        if ok and v == value then
            return id
        end
    end

    return nil
end

-- =============================== List ===============================
-- ====================================================================
---Return a concatenated table as as string
---@param value table: Table to concatenate
---@param str string: String to concatenate to the table
---@param sep string: Separator to concatenate the table
---@return string
function M.list(value, str, sep)
    sep = sep or ","
    str = str or ""
    value = type(value) == "table" and table.concat(value, sep) or value
    return str ~= "" and table.concat({value, str}, sep) or value
end

-- ============================ Switch-Case ===========================
-- ====================================================================

---Switch/case statement
---
---Usage:
--- <code>
--- a = switch {
---   [1] = function (x) print(x,10) end,
---   [2] = function (x) print(x,20) end,
---   default = function (x) print(x,0) end,
--- }
---
--- a:case(2)  -- ie. call case 2
--- a:case(9)
--- </code>
---
---@param t table: Table gets `:case` added
---@return table
-- function M.switch(t)
--     t.case = function(self, x)
--         local f = self[x] or self.default
--         if f then
--             if type(f) == "function" then
--                 f(x, self)
--             else
--                 error("case " .. tostring(x) .. " not a function")
--             end
--         end
--     end
--     return t
-- end

---Switch/case statement. Allows return statement
---
---Usage:
---<code>
--- c = 1
--- switch(c) : caseof {
---     [1]   = function (x) print(x,"one") end,
---     [2]   = function (x) print(x,"two") end,
---     [3]   = 12345, -- this is an invalid case stmt
---   default = function (x) print(x,"default") end,
---   missing = function (x) print(x,"missing") end,
--- }
---
--- -- also test the return value
--- -- sort of like the way C's ternary "?" is often used
--- -- but perhaps more like LISP's "cond"
--- --
--- print("expect to see 468:  ".. 123 +
---   switch(2):caseof{
---     [1] = function(x) return 234 end,
---     [2] = function(x) return 345 end
---   })
---</code>
---@param c table
---@return table
function M.switch(c)
    local swtbl = {
        casevar = c,
        caseof = function(self, code)
            local f
            if (self.casevar) then
                f = code[self.casevar] or code.default
            else
                f = code.missing or code.default
            end
            if f then
                if type(f) == "function" then
                    return f(self.casevar, self)
                else
                    error("case " .. tostring(self.casevar) .. " not a function")
                end
            end
        end
    }
    return swtbl
end

-- Capture output of a command using plenary
-- local job = require("plenary.job")
-- job:new(
--     {
--       command = "rg",
--       args = { "--files" },
--       cwd = "~",
--       env = { ["testing"] = "empty" },
--       on_exit = function(j, ret)
--         print(ret)
--         print(j:result())
--       end,
--     }
-- ):sync()

-- Help
-- print(vim.inspect(vim.fn.api_info()))
-- print(vim.inspect(vim))
--
-- print(vim.inspect(vim.loop))
-- Reference: https://github.com/luvit/luv/blob/master/docs.md
-- Examples:  https://github.com/luvit/luv/tree/master/examples

return M
