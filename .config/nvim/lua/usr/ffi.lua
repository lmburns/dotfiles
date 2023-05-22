local D = require("usr.shared.dev")
local ffi = require("ffi")

---@module 'usr.ffi'
local M = setmetatable({}, {__index = ffi})

M.i8p = ffi.typeof("int8_t*")
M.i8a = ffi.typeof("int8_t[?]")
M.u8p = ffi.typeof("uint8_t*")
M.u8a = ffi.typeof("uint8_t[?]")

M.i16p = ffi.typeof("int16_t*")
M.i16a = ffi.typeof("int16_t[?]")
M.u16p = ffi.typeof("uint16_t*")
M.u16a = ffi.typeof("uint16_t[?]")

M.i32p = ffi.typeof("int32_t*")
M.i32a = ffi.typeof("int32_t[?]")
M.u32p = ffi.typeof("uint32_t*")
M.u32a = ffi.typeof("uint32_t[?]")

M.i64p = ffi.typeof("int64_t*")
M.i64a = ffi.typeof("int64_t[?]")
M.u64p = ffi.typeof("uint64_t*")
M.u64a = ffi.typeof("uint64_t[?]")

M.f32p = ffi.typeof("float*")
M.f32a = ffi.typeof("float[?]")
M.f64p = ffi.typeof("double*")
M.f64a = ffi.typeof("double[?]")

local intptr_ct = ffi.typeof("intptr_t")
local intptrptr_ct = ffi.typeof("const intptr_t*")
local intptr1_ct = ffi.typeof("intptr_t[1]")
local voidptr_ct = ffi.typeof("void*")

---Generate a random string
---@param n number length
---@return string
function M.random_string(n)
    local buf = M.u32a(n / 4 + 1)
    for i = 0, n / 4 do
        buf[i] = math.random(0, 2 ^ 32 - 1)
    end
    return ffi.string(buf, n)
end

--x64: convert a pointer's address to a Lua number or possibly string.
function M.addr(p)
    local np = ffi.cast(intptr_ct, ffi.cast(voidptr_ct, p))
    local n = tonumber(np)
    if ffi.cast(intptr_ct, n) ~= np then
        --address too big (ASLR? tagged pointers?): convert to string.
        return ffi.string(intptr1_ct(np), 8)
    end
    return n
end

--x64: convert a number or string to a pointer, optionally specifying a ctype.
function M.ptr(ctype, addr)
    if not addr then
        ctype, addr = voidptr_ct, ctype
    end
    if type(addr) == "string" then
        return ffi.cast(ctype, ffi.cast(voidptr_ct,
            ffi.cast(intptrptr_ct, addr)[0]))
    else
        return ffi.cast(ctype, addr)
    end
end

function M.buffer(ctype)
    local vla = ffi.typeof(ctype or M.u8a)
    local buf, len = nil, -1
    return function(minlen)
        if minlen == false then
            buf, len = nil, -1
        elseif minlen > len then
            len = D.nextpow2(minlen)
            buf = vla(len)
        end
        return buf, len
    end
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

M.array = {}

---Create a new Array
---@param typ carray.dtypes
---@param size? integer
---@return CArray
function M.array.new(typ, size)
    return require("carray").new(typ, size)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

M.enum = {}

local cache = setmetatable({}, {__mode = "v"})

local inline_comment = "^%s*//[^\n]*\n()"
local multi_line_comment = "^%s*/%*.-*/%s*()"
local enumpat = "^(%s*([%w_][%a_]*)%s*(=?)%s*([x%x]*)%s*())"

---```lua
---  e = enum('foo, bar, baz')
---  assert(e.foo == 0, e.bar == 1, e.baz == 2)
---
---  e = enum [[
---    foo, bar,
---    baz = 5, qux,
---    quux = 0xFe
---  ]]
---
---  enum({'VISUAL', 'NORMAL'})
---  enum({{'VISUAL', 4}, {'NORMAL', 6}})
---```
---@param defs string|string[]|{[1]: string, [2]: integer}[]
---@return ffi.cdata*
function M.enum.new(defs)
    local cached = cache[defs]
    if cached then
        return cached
    end

    local N = 0
    local pos = 1
    local len = #defs
    local res = {}
    local coma = false

    if type(defs) == "table" then
        local name, int
        for _, def in ipairs(defs) do
            if type(def) == "table" then
                name, int = unpack(def)
                N = tonumber(int)
            else
                name, int = def, N
            end
            table.insert(res, ("  static const int %s = %s;"):format(name, int))
            N = N + 1
        end
    else
        while true do
            if pos == len + 1 then break end
            if pos > len + 1 then
                error(("LARGER: %d %d"):format(pos, len))
            end

            local p = defs:match(inline_comment, pos) or defs:match(multi_line_comment, pos)

            if not p then
                if coma then
                    p = defs:match("^%s*,%s*()", pos)
                    if not p then
                        error("malformed enum: coma expected")
                    end
                    coma = false
                else
                    local chunk, name, eq, value
                    chunk, name, eq, value, p = defs:match(enumpat, pos)
                    if not p then error("malformed enum definition") end

                    if value ~= "" then
                        assert(value:find("^%-?%d+$") or value:find("0x%x+"),
                            ("badly formed number %s in enum"):format(value))
                        N = tonumber(value)
                    end

                    local i = N
                    N = N + 1

                    if eq == "" and value == "" or eq == "=" and value ~= "" then
                        table.insert(res, ("  static const int %s = %s;"):format(name, i))
                    else
                        error(("badly formed enum: %s"):format(chunk))
                    end
                    coma = true
                end -- if coma
            end     -- if not p

            pos = p
        end -- while true
    end

    res = ffi.new("struct{ \n" .. table.concat(res, "\n") .. "\n}")
    cache[defs] = res
    return res
end

local definepat = "^(#define[ \t]+([%w_][%a_]*)[ \t]+([x%x]+)[ \t]*(\n?)())"

---```lua
---  local e = define [[
---    // comment
---    #define foo 0
---    #define bar 12
---  ]]
--- assert(e.bar == 12)
---```
---@param defs string
---@return ffi.cdata*
function M.enum.define(defs)
    local cached = cache[defs]
    if cached then
        return cached
    end

    local pos = defs:match("^%s*\n()") or 1
    local len = #defs
    local res = {}

    while true do
        if pos == len + 1 then break end
        if pos > len + 1 then
            error(("LARGER: %d %d"):format(pos, len))
        end

        local chunk, name, value, lf, p = defs:match(definepat, pos)
        p = p or defs:match(inline_comment, pos) or defs:match(multi_line_comment, pos)
        if chunk then
            if lf ~= "\n" and p ~= len + 1 then
                error(("end of line expected after: %s"):format(chunk))
            end
            assert(value:find("^%-?%d+$") or value:find("0x%x+"),
                ("badly formed number %s in enum"):format(value))

            res[#res+1] = ("  static const int %s = %s;"):format(name, value)
        elseif not p then
            p = defs:match("^[ \t]+()", pos)
            assert(p, "malformed #define")
        end -- if chunk
        pos = p
    end     -- while true
    res = ffi.new("struct{ \n" .. table.concat(res, "\n") .. "\n}")
    cache[defs] = res
    return res
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local C = ffi.C

---Check if the |textlock| is active.
---@return boolean
function M.nvim_is_textlocked()
    return C.textlock > 0
end

---Check if the nvim API is locked for any reason.
---See: |api-fast|, |textlock|
---@return boolean
function M.nvim_is_locked()
    if vim.in_fast_event() then return true end
    return C.textlock > 0 or C.allbuf_lock > 0 or C.expr_map_lock > 0
end

ffi.cdef([[
  /// Non-zero when changing text and jumping to another window or editing another buffer is not
  /// allowed.
  extern int textlock;

  /// Non-zero when no buffer name can be changed, no buffer can be deleted and
  /// current directory can't be changed. Used for SwapExists et al.
  extern int allbuf_lock;

  /// Running expr mapping, prevent use of ex_normal() and text changes
  extern int expr_map_lock;
]])

return M
