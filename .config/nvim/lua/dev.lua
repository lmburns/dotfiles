--- Tools that will help with Lua development

local M = {}

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

-- function string.startswith(s, n)
--     return s:sub(1, #n) == n
-- end
--
-- function string.endswith(self, str)
--     return self:sub(-(#str)) == str
-- end

---Get the output of a system command in a table
---@param cmd string|table
---@return table
M.get_system_output = function(cmd)
    return vim.split(fn.system(cmd), "\n")
end

---@class JobOpts
---@field on_stdout function function to run on stdout
---@field input string input for stdin
---@field on_exit function function to run on exit

---@param cmd string
---@param opts JobOpts
---@return number the job id
M.start_job = function(cmd, opts)
    opts = opts or {}
    local id =
        fn.jobstart(
        cmd,
        {
            stdout_buffered = true,
            on_stdout = function(_, data, _)
                if data and type(opts.on_stdout) == "function" then
                    opts.on_stdout(data)
                end
            end,
            on_exit = function(_, data, _)
                if type(opts.on_exit) == "function" then
                    opts.on_exit(data)
                end
            end
        }
    )

    if opts.input then
        fn.chansend(id, opts.input)
        fn.chanclose(id, "stdin")
    end

    return id
end

-- ============================== Print ===============================
-- ====================================================================

M.inspect = function(v)
    local s
    local t = type(v)
    if t == "nil" then
        s = "nil"
    elseif t == "userdata" then
        s = ("Userdata:\n%s"):format(vim.inspect(getmetatable(v)))
    elseif t ~= "string" then
        s = vim.inspect(v, {depth = math.huge})
    else
        s = tostring(v)
    end
    return s
end

-- Print text nicely (newline)
_G.pln = function(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, M.inspect(arg))
    end

    print(table.concat(msg_tbl, "\n\n"))
end

-- Print text nicely
_G.p = function(...)
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

M.round = function(value)
    return math.floor(value + 0.5)
end

---Split a string on a delimiter
---@param input string
---@param sep string
---@return string
M.split = function(input, sep)
    vim.validate {
        input = {input, {"s"}},
        sep = {sep, {"s"}}
    }
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- ============================== Table ===============================
-- ====================================================================

---Create table whose keys are now the values, and the values are now the keys
---Similar to vim.tbl_add_reverse_lookup
---
---Assumes that the values in tbl are unique and hashable (no nil/NaN)
---@generic K,V
---@param tbl table<K,V>
---@return table<V,K>
M.tbl_reverse_kv = function(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[v] = k
    end
    return ret
end

---Merge two tables
---@param a 'table'
---@param b 'table'
---@return 'table'
M.merge = function(a, b)
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

---Return a table with duplicates filtered out
---@param array table
---@return table
M.filter_duplicates = function(array)
    local seen = {}
    local res = {}

    for _, v in ipairs(array) do
        if not seen[v] then
            res[#res + 1] = v
            seen[v] = true
        end
    end
    return res
end

---Pack a table. Similar to `table.pack`. Sets number of elements to `.n`
---@vararg any any number of items to pack
---@return table
M.tbl_pack = function(...)
    return {n = select("#", ...), ...}
end

---Unpack a table into arguments. Similar to `table.unpack`
---@param t table table to unpack
---@param i number
---@param j number
---@return any
M.tbl_unpack = function(t, i, j)
    return unpack(t, i or 1, j or t.n or #t)
end

---Clone a table
---
---@param t table: Table to clone
---@return table
M.tbl_clone = function(t)
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
M.tbl_deep_clone = function(t)
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
M.vec_slice = function(t, first, last)
    local slice = {}
    for i = first or 1, last or #t do
        table.insert(slice, t[i])
    end

    return slice
end

---Join multiple vectors into one.
---@vararg vector
---@return vector
M.vec_join = function(...)
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

---Find an item in a list
---@generic T
---@param haystack T[]
---@param matcher fun(arg: T):boolean
---@return T
M.find = function(haystack, matcher)
    local found
    for _, needle in ipairs(haystack) do
        if matcher(needle) then
            found = needle
            break
        end
    end
    return found
end

---Return the first index a given object can be found in a vector, or -1 if
---it's not present.
---
---@param t vector
---@param v any
---@return integer
M.vec_indexof = function(t, v)
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
M.vec_push = function(t, ...)
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

---`vim.api.nvim_is_buf_loaded` filters out all hidden buffers
M.buf_is_valid = function(bufnr)
    if not bufnr or bufnr < 1 then
        return false
    end
    local exists = api.nvim_buf_is_valid(bufnr)
    return vim.bo[bufnr].buflisted and exists
end

---Get the number of buffers
---@return number
M.get_buf_count = function()
    return #fn.getbufinfo({buflisted = 1})
end

---Get valid buffers
---@return number[]
M.get_valid_buffers = function()
    return vim.tbl_filter(M.buf_is_valid, api.nvim_list_bufs())
end

---Return a table of the id's of loaded buffers (hidden are removed)
---@return table
M.get_loaded_bufs = function()
    return vim.tbl_filter(
        function(id)
            return api.nvim_buf_is_loaded(id)
        end,
        api.nvim_list_bufs()
    )
end

---Find a buffer that has a given variable with a value
---@param var string variable to search for
---@param value string|number value the variable should have
---@return any
M.find_buf_with_var = function(var, value)
    for _, id in ipairs(api.nvim_list_bufs()) do
        local ok, v = pcall(api.nvim_buf_get_var, id, var)
        if ok and v == value then
            return id
        end
    end

    return nil
end

---Find a buffer that has an option set at a value
---@param option string option to search for
---@param value string|number value the option should have
---@return any
M.find_buf_with_option = function(option, value)
    for _, id in ipairs(api.nvim_list_bufs()) do
        local ok, v = pcall(api.nvim_buf_get_option, id, option)
        if ok and v == value then
            return id
        end
    end

    return nil
end

---Get the nubmer of tabs
---@return number
M.get_tab_count = function()
    return #fn.gettabinfo()
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Reload                          │
-- ╰──────────────────────────────────────────────────────────╯
---Reload all lua modules
---FIX: This fails in treesitter, where a module is loaded inside another module
M.reload_config = function()
    -- Handle impatient.nvim automatically.
    local luacache = (_G.__luacache or {}).modpaths.cache

    -- local lua_dirs = fn.glob(("%s/lua/*"):format(fn.stdpath("config")), 0, 1)
    -- require("plenary.reload").reload_module(dir)

    for name, _ in pairs(package.loaded) do
        if name:match("^plugs.") then
            package.loaded[name] = nil

            if luacache then
                luacache[name] = nil
            end
        end
    end

    dofile(env.VIMRC)
    require("plugins").compile()
end

---Reload lua modules in a given path and reload the module
---@param path string
---@param recursive string
M.rreload_module = function(path, recursive)
    if recursive then
        for key, value in pairs(package.loaded) do
            if key ~= "_G" and value and fn.match(key, path) ~= -1 then
                package.loaded[key] = nil
                require(key)
            end
        end
    else
        package.loaded[path] = nil
        require(path)
    end
end

---NOTE: this plugin returns the currently loaded state of a plugin given
---given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
M.plugin_loaded = function(plugin_name)
    local plugins = _G.packer_plugins or {}
    return plugins[plugin_name] and plugins[plugin_name].loaded
end

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
M.plugin_installed = function(plugin_name)
    if not installed then
        local dirs = fn.expand(fn.stdpath("data") .. "/site/pack/packer/start/*", true, true)
        local opt = fn.expand(fn.stdpath("data") .. "/site/pack/packer/opt/*", true, true)
        vim.list_extend(dirs, opt)
        installed =
            vim.tbl_map(
            function(path)
                return fn.fnamemodify(path, ":t")
            end,
            dirs
        )
    end
    return vim.tbl_contains(installed, plugin_name)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           List                           │
-- ╰──────────────────────────────────────────────────────────╯
---Return a concatenated table as as string
---@param value table: Table to concatenate
---@param str string: String to concatenate to the table
---@param sep string: Separator to concatenate the table
---@return string
M.list = function(value, str, sep)
    sep = sep or ","
    str = str or ""
    value = type(value) == "table" and table.concat(value, sep) or value
    return str ~= "" and table.concat({value, str}, sep) or value
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Switch-case                        │
-- ╰──────────────────────────────────────────────────────────╯

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
M.switch = function(c)
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

-- Examples:  https://github.com/luvit/luv/tree/master/examples

return M
