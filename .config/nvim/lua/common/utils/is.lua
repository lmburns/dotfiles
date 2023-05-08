---@module 'common.utils.is'
---@description Easy way to check type of object
local M = {}

local B = require("common.api.buf")
local F = vim.F

---Will determine whether:
---  - `string` == ""
---  - `table` == {}
---  - `integer` == 0
---An integer can be given to this function, with `{buffer = true}`,
---and the text as the parameter `item` will be treated as a buffer
---and checked to see if it is empty.
---
---@param item string|table|boolean|number|buffer Item to check if empty
---@param buf? { buffer?: boolean }
---@return boolean?
function M.empty(item, buf)
    local item_t = type(item)

    if item_t == "string" then
        return item == ""
    elseif item_t == "table" then
        return vim.tbl_isempty(item)
    elseif item_t == "boolean" then
        return item_t == false
    elseif item_t == "number" then
        buf = F.unwrap_or(buf, {})
        if buf.buffer == true then
            return B.buf_is_empty(item)
        else
            return item <= 0
        end
    end
end

---Check if item is a table
---@param obj any
---@return boolean
function M.table(obj)
    return type(obj) == "table"
end

---Check if item is a list (sequential numbers for keys)
---@param arr any
---@return boolean
function M.list(arr)
    return vim.tbl_islist(arr)
end

---Check if item is an array (numbers for keys)
---@param arr any
---@return boolean
function M.array(arr)
    return vim.tbl_isarray(arr)
end

---Check if item is a string
---@param str any
---@return boolean
function M.string(str)
    return type(str) == "string"
end

---Check if item is a number
---@param num any
---@return boolean
function M.number(num)
    return type(num) == "number"
end

---Check if item is not a number
---@param num any
---@return boolean
function M.nan(num)
    return M.number(num) and num ~= num
end

---Check if item is function
---@param fn any
---@return boolean
function M.func(fn)
    return type(fn) == "function"
end

---Check if item is callable
---@param fn any
---@return boolean
function M.callable(fn)
    return vim.is_callable(fn)
end

---Check if item is a finite number
---@param num any
---@return boolean
function M.finite(num)
    return M.number(num) and -math.huge < num and num < math.huge
end

---Check if item is a boolean
---@param bool any
---@return boolean
function M.boolean(bool)
    return type(bool) == "boolean"
end

---Check if item is nil
---@param null any
---@return boolean
function M.null(null)
    return null == nil
end

--Alternative names

M.tbl = M.table
M.vec = M.array
M.num = M.number
M.fn = M.func
M.bool = M.boolean

return M
