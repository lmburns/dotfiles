local log = require("common.log")

-- ╒══════════════════════════════════════════════════════════╕
--                            Result
-- ╘══════════════════════════════════════════════════════════╛
-- A simple Result<V, E> type
-- This allows for a Result similar to rust

---@class Result
---@field ok fun(v: any): Ok
---@field err fun(v: any): Err
local Result = {}

---@enum ResultKind
local result_kind = {ERROR = 1, OK = 2}

---@class Result_t<T>
---@field value any
---@field kind ResultKind
-- ---@field value T

---@param lhs Result_t
---@param rhs Result_t
---@return boolean
local function result_lt(lhs, rhs)
    return lhs.kind == rhs.kind
        and lhs.value ~= nil and rhs.value ~= nil
        and lhs.value < rhs.value
end

---@param lhs Result_t
---@param rhs Result_t
---@return boolean
local function result_lte(lhs, rhs)
    return lhs.kind == rhs.kind
        and lhs.value ~= nil and rhs.value ~= nil
        and lhs.value <= rhs.value
end

---@param lhs Result_t
---@param rhs Result_t
---@return boolean
local function result_eq(lhs, rhs)
    return lhs.kind == rhs.kind and lhs.value == rhs.value
end

-- ╒══════════════════════════════════════════════════════════╕
--                              Ok
-- ╘══════════════════════════════════════════════════════════╛

---@class Ok<T> : Result_t<T>
---@field kind ResultKind
local Ok = {}

local Ok_mt = {
    __index = Ok,
    __lt = result_lt,
    __le = result_lte,
    __eq = result_eq,
    __call = function(_, ...)
        return Ok:new(...)
    end,
    __tostring = function(r)
        local typ = type(r)
        if typ == "nil" then
            return "Result::Ok(nil)"
        elseif typ == "table" or typ == "function" then
            return ("Result::Ok(%s)"):format(vim.inspect(r.value))
        else
            return ("Result::Ok(%s)"):format(r.value)
        end
    end,
}

---Create a new Result::Ok
---@generic T
---@param value T
---@return Ok<T>
function Ok:new(value)
    local o = setmetatable({}, Ok_mt)
    o.value = value
    o.kind = result_kind.OK
    return o
end

---Execute `f` if the Result is Ok, else return an Err
---@generic A, T : Result_t
---@param f fun(...: A): T
---@param ... A
---@return T
function Ok:and_then(f, ...)
    local r = f(...)
    if r == nil then
        return Result.err("Result == nil (and_then) " .. vim.inspect(debug.traceback()))
    end

    self.value = r.value
    self.kind = r.kind
    setmetatable(self, getmetatable(r))
    return self
end

---Return another value if not okay
---@param _ any
---@return Ok
function Ok:or_(_)
    return self
end

---Return another value if not okay
---@param _ any
---@return Ok
function Ok:or_else(_)
    return self
end

---Map the successful result
---@generic T
---@param f fun(v: any): T
---@return Ok<T>
function Ok:map_ok(f)
    return Result.ok(f(self.value))
end

---Map the non-existing error
---@return Ok
function Ok:map_err()
    return self
end

---Return the underlying value
---@return Ok
function Ok:unwrap()
    return self.value
end

---Return the underlying value
---@param _ any
---@return Ok
function Ok:unwrap_or(_)
    return self.value
end

---Return the underlying value
---@param _ any
---@return Ok
function Ok:unwrap_or_else(_)
    return self.value
end

---Return the underlying error (if any)
---@return Ok
function Ok:unwrap_err()
    return self.value
end

---Return the underlying error (if any)
---@param _ any
---@return Ok
function Ok:expect(_)
    return self.value
end

---Test whether the result is okay
---@return boolean
function Ok:is_ok()
    return true
end

---Test whether the result is okay
---@return boolean
function Ok:is_err()
    return false
end

---Check whether given value is ok
---@param o any
---@return boolean
function Ok:is_instance(o)
    return Ok() == o
end

Ok.__index = Ok

-- ╒══════════════════════════════════════════════════════════╕
--                             Err
-- ╘══════════════════════════════════════════════════════════╛

---@class Err<T> : Result_t<T>
---@field value any
---@field kind ResultKind
local Err = {}

local Err_mt = {
    __index = Err,
    __lt = result_lt,
    __le = result_lte,
    __eq = result_eq,
    __call = function(_, ...)
        return Err:new(...)
    end,
    __tostring = function(t)
        local typ = type(t.value)
        if typ == "nil" then
            return "Result::Ok(nil)"
        elseif typ == "table" or typ == "function" then
            return ("Result::Err(%s)"):format(vim.inspect(t.value))
        else
            return ("Result::Err(%s)"):format(t.value)
        end
    end,
}

---Create a new Result::Err
---@generic T
---@param value T
---@return Err<T>
function Err:new(value)
    local o = setmetatable({}, Err_mt)
    o.value = value
    o.kind = result_kind.ERROR
    return o
end

---Return the underlying error to do something else with
---@return Err
function Err:and_then()
    return self
end

---Return another value if not okay
---@generic T : Result_t
---@param r T
---@return T
function Err:or_(r)
    self.value = r.value
    self.kind = r.kind
    setmetatable(self, getmetatable(r))
    return self
end

---Execute a function if result is an error
---@generic A, T : Result_t
---@param f fun(...: A): T
---@param ... A
---@return T
function Err:or_else(f, ...)
    local r = f(...)
    if r == nil then
        return Result.err("Result == nil (or_else) " .. vim.inspect(debug.traceback()))
    end

    self.value = r.value
    self.kind = r.kind
    setmetatable(self, getmetatable(r))
    return self
end

---Return the underlying error
---@return Err
function Err:map_ok()
    return self
end

---Execute a function on underlying error
---@generic T
---@param f fun(e: any): T
---@return Err<T>
function Err:map_err(f)
    return Result.err(f(self.value))
end

---Return the underlying value
function Err:unwrap()
    error(vim.inspect(self.value))
end

---Return the underlying error
---@return any
function Err:unwrap_err()
    return self.value
end

---Return an alternate value
---@generic T
---@param f T
---@return T
function Err:unwrap_or(f)
    if type(f) == "function" then
        log.err("use `unwrap_or_else` for functions")
    end
    return f
end

---Return an alternate value from a function
---@generic T, A
---@param f fun(...: A): T
---@param ... A
---@return T
function Err:unwrap_or_else(f, ...)
    if type(f) == "function" then
        return f(...)
    end
    return f
end

---Return the underlying error (if any)
---@param msg string
function Err:expect(msg)
    error(msg)
end

---Test whether the result is okay
---@return boolean
function Err:is_ok()
    return false
end

---Test whether the result is an error
---@return boolean
function Err:is_err()
    return true
end

---Check whether given value is an error
---@param o any
---@return boolean
function Err:is_instance(o)
    return Err() == o
end

Err.__index = Err

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@generic T
---@param val T
---@return Ok<T>
Result.ok = function(val)
    return Ok:new(val)
end

---@generic E
---@param err E
---@return Err<E>
Result.err = function(err)
    return Err:new(err)
end

---Create a Result from a value. If `nil`, then Error
---@generic R
---@param o R
---@return Result_t<R>
Result.from_nil = function(o)
    if type(o) == "nil" then
        return Err(o)
    end
    return Ok(o)
end

---@generic A, R
---@param f fun(...: A): R
---@param ... A
---@return Result_t<R>
Result.pcall = function(f, ...)
    local ok, result = pcall(f, ...)
    if ok then
        return Result.ok(result)
    else
        return Result.err(result)
    end
end

return Result
