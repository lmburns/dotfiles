local M = {}

local fn = vim.fn
local uv = vim.loop
local api = vim.api
local env = vim.env
local F = vim.F

-- ╒══════════════════════════════════════════════════════════╕
--                            Global
-- ╘══════════════════════════════════════════════════════════╛

--  ╭───────────╮
--  │ Variables │
--  ╰───────────╯

_G.o = vim.opt -- vim options: behaves like `:set`
_G.opt_local = vim.opt_local
_G.opt_global = vim.opt_global
-- o           --  behaves like `:set` (global)
-- opt         --  behaves like `:set` (global and local)
-- opt_global  --  behaves like `:setglobal`
-- opt_local   --  behaves like `:setlocal`

_G.g = vim.g -- global variables:
_G.go = vim.go -- global options
_G.w = vim.wo -- window options: behaves like `:setlocal` (alias for vim.wo)
_G.b = vim.bo -- buffer options: behaves like `:setlocal` (alias for vim.bo)

_G.fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
_G.cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
_G.env = vim.env -- environment variable access
_G.api = vim.api
_G.uv = vim.loop
_G.F = vim.F

_G.dev = require("dev")
_G.List = require("plenary.collections.py_list")
_G.Enum = require("plenary.enum")
_G.Path = require("plenary.path")

-- _G.Job = require("plenary.job")
-- _G.async = require("plenary.async")
-- _G.a = require("plenary.async_lib")
-- _G.op = require("plenary.operators")

_G.promise = require("promise")
_G.async = require("async")
_G.await = require("async").wait

---@type Nvim
_G.nvim = require("nvim")

-- ---@type {[string]: {[string]: any}}
-- ---@type Dict<Dict<any>>

---@type Dict<{[string]: any}>
_G.packer_plugins = _G.packer_plugins

-- Makes `_t` global
require("arshlib")

--  ╭───────╮
--  │ Class │
--  ╰───────╯

---@class Void
---@operator call:nil
_G.Void =
    setmetatable(
    {},
    {
        ---@return Void
        __index = function(self)
            return self
        end,
        __newindex = function()
        end,
        __call = function()
        end
    }
)

--  ╭───────────╮
--  │ Functions │
--  ╰───────────╯

---Reload a module
---@param ... string
---@return nil
RELOAD = function(...)
    return require("common.utils").mod.reload_module(...)
end

---Reload a module, returning the newly loaded object
---@param name string
---@return module
R = function(name)
    RELOAD(name)
    return require(name)
end

---Inspect a value
---@param v any
---@return string?
I = function(v)
    return vim.inspect(v)
end

---Print text nicely, joined with newlines
---@param ... any
_G.pln = function(...)
    local msg_tbl = dev.map({...}, vim.inspect)
    -- print(unpack(msg_tbl))
    print(table.concat(msg_tbl, "\n\n"))
end

---Print text nicely, joined with spaces
---@param ... any
_G.p = function(...)
    local msg_tbl = dev.map({...}, vim.inspect)
    -- print(unpack(msg_tbl))
    print(table.concat(msg_tbl, " "))
end

---Print text nicely
_G.pp = vim.print

---Format a string
---See https://fmt.dev/latest/syntax.html
---See https://github.com/starwing/lua-fmt
---format_spec ::=  `[[fill]align][sign]["#"]["0"][width][grouping]["." precision][type]`
---fill        ::=  `<a character other than '{' or '}'>`
---align       ::=  `"<" | ">" | "^"`
---sign        ::=  `"+" | "-" | " "`
---width       ::=  `integer | "{" [arg_id] "}"`
---grouping    ::=  `"_" | ","`
---precision   ::=  `integer | "{" [arg_id] "}"`
---type        ::=  `int_type | flt_type | str_type`
---int_type    ::=  `"b" | "B" | "d" | "o" | "x" | "X" | "c"`
---flt_type    ::=  `"e" | "E" | "f" | "F" | "g" | "G" | "%"`
---str_type    ::=  `"p" | "s"`
---```lua
---  printf("{2} {1}", 1, 2) --> '2 1'
---  printf("{x} {y}", {x=11, y=22}) --> '11 22'
---  printf("{t.x} {t.y}", {t={x=11, y=22}}) --> '11 22'
---  printf("{:b}", 2) --> '10'
---  printf("{:_}", 10000) --> '10_000'
---```
---@param ... any
_G.printf = function(...)
    p(require("fmt")(...))
end

--  ╭────────╮
--  │ String │
--  ╰────────╯

---Escape a string correctly
---@param self string
---@return string
string.escape = function(self)
    return vim.pesc(self)
end

---Trims whitespace on left and right side by default.
---Can trim characters from both sides as well.
---@param self string
---@param chars? string
---@return string
string.trim = function(self, chars)
    if not chars then
        return self:match("^[%s]*(.-)[%s]*$")
    end
    chars = chars:escape()
    return self:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

---Trims whitespace on right side by default.
---Can trim characters from right as well.
---@param self string
---@param chars? string
---@return string
string.rtrim = function(self, chars)
    if not chars then
        return self:match("^(.-)[%s]*$")
    end
    chars = chars:escape()
    return self:match("^(.-)[" .. chars .. "]*$")
end

---Trims whitespace on left side by default.
---Can trim characters from left as well.
---@param self string
---@param chars? string
---@return string
string.ltrim = function(self, chars)
    if not chars then
        return self:match("^[%s]*(.-)$")
    end
    chars = chars:escape()
    return self:match("^[" .. chars .. "]*(.-)$")
end

---Replace multiple spaces with a single space
---@param self string
---@return string, integer
string.compact = function(self)
    return self:gsub("%s+", " ")
end

---Capitalizes the first letter of a string
---@param self string
---@return string
string.capitalize = function(self)
    local ret = self:sub(1, 1):upper() .. self:sub(2):lower()
    return ret
end

---Split a string on ` ` by default. Optional delimiter.
---@param self string
---@param delim? string
---@param opts? {plain?: boolean, trimempty?: boolean}
---@return string[]
string.split = function(self, delim, opts)
    return vim.split(self, delim or " ", opts)
end

--  ╭──────╮
--  │ PCRE │
--  ╰──────╯

---@alias PCRERet0 string|number|nil
---@alias PCRERet1 string|false|nil

---Use PCRE regular expressions. Equivalent to `string.match`
---See: https://rrthomas.github.io/lrexlib/manual.html#match
---@param self string
---@param pattern string
---@param init? number start offset in the subject (can be negative)
---@return PCRERet1|string[]
string.rxmatch = function(self, pattern, init)
    return require("rex_pcre2").match(self, pattern, init)
end

---Use PCRE regular expressions. Equivalent to `string.gmatch`
---See: https://rrthomas.github.io/lrexlib/manual.html#gmatch
---@param self string
---@param pattern string
---@return nil|fun(): string[] captures
string.rxgmatch = function(self, pattern)
    return require("rex_pcre2").gmatch(self, pattern)
end

---Use PCRE regular expressions. Equivalent to `string.gsub`
---See: https://rrthomas.github.io/lrexlib/manual.html#gsub
---## Example
---```lua
---print(('what up'):rxsub('(\\w+)', '%1 %1'))      -- => what what up up
---print(('what  up dude'):rxsub('\\s{2,}', 'XX'))  -- => whatXXup dude
---```
---@param self string
---@param pattern string
---@param repl string|string[]|fun(s: string): PCRERet0|false '%0' = whole match, '%1' = 1st match
---@param n? number|fun(start: number, end: number, out: string): PCRERet0|boolean, number|boolean|nil max num of matches to repl
---@return string substitued
---@return number matches
---@return number substitutions_made
string.rxsub = function(self, pattern, repl, n)
    return require("rex_pcre2").gsub(self, pattern, repl, n)
end

---Use PCRE regular expressions. Equivalent to `string.find`
---See: https://rrthomas.github.io/lrexlib/manual.html#find
---@param self string
---@param pattern string
---@param init? number start offset in the subject (can be negative)
---@return number? start
---@return number? end
---@return PCRERet1|string[] captured
string.rxfind = function(self, pattern, init)
    return require("rex_pcre2").find(self, pattern, init)
end

---Use PCRE regular expressions to split a string
---See: https://rrthomas.github.io/lrexlib/manual.html#split
---@param self string
---@param sep string pattern string
---@return fun(): string[]
string.rxsplit = function(self, sep)
    return require("rex_pcre2").split(self, sep)
end

---Use PCRE regular expressions to count number of matches in string
---See: https://rrthomas.github.io/lrexlib/manual.html#count
---@param self string
---@param pattern string
---@return number
string.rxcount = function(self, pattern)
    return require("rex_pcre2").count(self, pattern)
end

---Use `vim.regex` to match a string
---@param self string
---@param pattern string
---@return number?
---@return number?
string.vmatch = function(self, pattern)
    return vim.regex(pattern):match_str(self)
end

--  ╭───────╮
--  │ Table │
--  ╰───────╯

table.pack = function(_, ...)
    return {n = select("#", ...), ...}
end

--  ╭──────────╮
--  │ Iterator │
--  ╰──────────╯

---@generic T
---@param tbl Array<T>
---@param idx integer
---@return integer?
---@return T?
local ripairs_iter = function(tbl, idx)
    idx = idx - 1
    local val = tbl[idx]
    if val ~= nil then
        return idx, val
    end
end

---Reverse `ipairs` iterator
---@generic T: table, V
---@param t T
---@return fun(table: V[], i?: integer): integer, V # iterator
---@return T # invariant state
---@return integer i # initial value
_G.ripairs = function(t)
    return ripairs_iter, t, (#t + 1)
end

---@generic T
---@param tbl Array<T>
---@param idx integer
---@return integer?
---@return T?
local kpairs_iter = function(tbl, idx)
    -- While true is needed to skip elements we're not matching against
    while true do
        idx, val = next(tbl, idx)
        if type(idx) ~= "number" or math.floor(idx) ~= idx then
            break
        end
    end
    return idx, val
end

---Inverse `ipairs` iterator
---Skips keys that are a numbers, returning only dictionary values
---@generic T: table, V, K
---@param t T
---@return fun(table: table<K, V>, index?: K): K, V
---@return T
---@return nil
_G.kpairs = function(t)
    return kpairs_iter, t, nil
end

--  ╭───────────╮
--  │ Blacklist │
--  ╰───────────╯

_G.BLACKLIST_FT = {
    "",
    "nofile",
    "aerial",
    "alpha",
    "bqfpreview",
    "bufferize",
    "cmp_docs",
    "cmp_menu",
    "coc-explorer",
    "coc-list",
    "coctree",
    "code-action-menu-menu",
    "commit",
    "comment",
    "conf",
    "dap-float",
    "dap-repl",
    "dapui_breakpoints",
    "dapui_console",
    "dapui_scopes",
    "dapui_stacks",
    "dapui_watches",
    "dbui",
    "diff",
    "DressingInput",
    "DressingSelect",
    "floaterm",
    "floatline",
    "floggraph",
    "frecency",
    "fugitive",
    "fugitiveblame",
    "fzf",
    "git",
    "git-log",
    "git-status",
    "gitcommit",
    "gitrebase",
    "godoc",
    "help",
    "hgcommit",
    "incline",
    "list",
    "log",
    "lsp-installer",
    "lspinfo",
    "luapad",
    "man",
    "minimap",
    "NeogitCommitMessage",
    "NeogitCommitView",
    "NeogitGitCommandHistory",
    "NeogitLogView",
    "NeogitNotification",
    "NeogitPopup",
    "NeogitStatus",
    "NeogitStatusNew",
    "neoterm",
    "neo-tree",
    "nerdtree",
    "neotest-summary",
    "netrw",
    "noice",
    "notify",
    "norg",
    "NvimTree",
    "org",
    "orgagenda",
    "packer",
    "PlenaryTestPopup",
    "prompt",
    "qf",
    "quickmenu",
    "rebase",
    "registers",
    "scratchpad",
    "startify",
    "svn",
    "startuptime",
    "telescope",
    "TelescopePrompt",
    "TelescopeResults",
    "toggleterm",
    "Trouble",
    "tsplayground",
    "UltestSummary",
    "UltestOutput",
    "undotree",
    "vim-plug",
    "vista",
    "VistaFloatingWin",
    "WhichKey"
    -- "make",
    -- "cmake",
    -- "markdown",
    -- "vimwiki",
}

-- ╓                                                          ╖
-- ║       Global variables referenced from this module       ║
-- ╙                                                          ╜

M.user = uv.os_get_passwd()
M.username = M.user.username
M.home = os.getenv("HOME") -- vim.loop.os_homedir()
M.name = uv.os_uname().sysname -- jit.os:lower()
M.luajit = vim.split(jit.version, " ")[2]
M.version = {
    vim.version().major,
    vim.version().minor,
    vim.version().patch
}
M.dirs = {
    config = fn.stdpath("config"),
    cache = fn.stdpath("cache"),
    data = fn.stdpath("data"),
    run = fn.stdpath("run")
}

return M
