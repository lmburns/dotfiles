--- Tools that will help with Lua development

local M = {}

---@alias vector any[]

local is_windows = jit.os == "Windows"
local path_sep = package.config:sub(1, 1)

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

-- Capture output of command
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

-- ============================== Print ===============================
-- ====================================================================

local function inspect(v)
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
        table.insert(msg_tbl, inspect(arg))
    end

    print(table.concat(msg_tbl, "\n"))
end

-- Print text nicely
function _G.p(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, inspect(arg))
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

function M.list(value, str, sep)
    sep = sep or ","
    str = str or ""
    value = type(value) == "table" and table.concat(value, sep) or value
    return str ~= "" and table.concat({value, str}, sep) or value
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
