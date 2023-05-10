---@module 'common.global'
local M = {}

local fn = vim.fn
local uv = vim.loop
local F = vim.F

_G.lb = {}

-- ╒══════════════════════════════════════════════════════════╕
--                            Global
-- ╘══════════════════════════════════════════════════════════╛

-- Identity assignments for vim objects without a type

---@class vim.g
---@field [string] any
vim.g = vim.g

---@class vim.fn
vim.fn = vim.fn

---@class vim.cmd
---@operator call(Vim.Cmd.Opts|string):nil
vim.cmd = vim.cmd

---@class vim.env
vim.env = vim.env

---@class vim.F
vim.F = vim.F

--  ╭───────────╮
--  │ Variables │
--  ╰───────────╯

-- Want these global for lua commands

---vim options: behaves like `set`
---@type vim.opt
_G.o = vim.opt

---local options: behaves like `setlocal`
---@type vim.opt
_G.opt_local = vim.opt_local

---global options: behaves like `setglobal`
---@type vim.opt
_G.opt_global = vim.opt_global

---global variables
---@type table<string, any>|vim.g
_G.g = vim.g

---global options. like `setglobal`
---@type table<number, vim.go>|vim.go
_G.go = vim.go

---window options: behaves like `:setlocal` (alias for vim.wo)
---@type table<number, vim.wo>|vim.wo
_G.w = vim.wo

---buffer options: behaves like `:setlocal` (alias for vim.bo)
---@type table<number, vim.bo>|vim.bo
_G.b = vim.bo

--  ══════════════════════════════════════════════════════════════════════

---@type vim.fn
_G.fn = vim.fn
---@type vim.cmd
_G.cmd = vim.cmd
---@type vim.env
_G.env = vim.env
---@type vim.api
_G.api = vim.api
---@type uv
_G.uv = vim.loop
---@type vim.F
_G.F = vim.F

---@type UvFS
_G.uva = require("uva")
---@type DevL
_G.dev = require("dev")
---@type Log
_G.log = require("common.log")
---@type UtilCommon|UtilFuncs
_G.utils = require("common.utils")
---@type API
_G.mpi = require("common.api")
---@type PCRE
_G.rex = require("rex_pcre2")

---@type List
_G.List = require("plenary.collections.py_list")
---@type Enum
_G.Enum = require("plenary.enum")
---@type Path
_G.Path = require("plenary.path")

-- _G.Job = require("plenary.job")
-- _G.async = require("plenary.async")
-- _G.a = require("plenary.async_lib")
-- _G.op = require("plenary.operators")

---@type Promise
_G.promise = require("promise")
---@type Async
_G.async = require("async")
_G.await = _G.async.wait

---@type Nvim|Neovim
_G.nvim = require("nvim")

-- ---@type {[string]: {[string]: any}}
-- ---@type Dict<Dict<any>>

---@class PackerPlugins
---@field [string] any
_G.packer_plugins = _G.packer_plugins

-- Makes `_t` global
require("arshlib")

--  ╭───────╮
--  │ Class │
--  ╰───────╯

---@class Void
---@operator call:nil
_G.Void = setmetatable({}, {
    ---@param self self
    ---@return fun(): Void
    __index = function(self) return self end,
    __newindex = function(self) return self end,
    __call = function(self) return self end,
    __metatable = "Void", -- {"Void"},
    __name = "Void",
    __tostring = function() return "Void" end,
    __eq = function(self, cmp) return self == cmp end,
    __concat = function(_, cmp) return cmp end,
    __len = function(_) return 0 end,
    __unm = function(_) return 0 end,
    __add = function(_, cmp) return cmp end,
    __sub = function(_, cmp) return cmp end,
    __mul = function(_, cmp) return cmp end,
    __div = function(_, cmp) return cmp end,
    __idiv = function(_, cmp) return cmp end,
    __mod = function(_, cmp) return cmp end,
    __pow = function(_, cmp) return cmp end,
    __lt = function(_, cmp) return cmp end,
    __le = function(_, cmp) return cmp end,
    __band = function() return 0 end,
    __bnot = function() return 0 end,
    __bor = function() return 0 end,
    __shl = function() return 0 end,
    __shr = function() return 0 end,
})

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
    local msg_tbl = dev.map({...}, utils.inspect)
    -- print(unpack(msg_tbl))
    print(table.concat(msg_tbl, "\n\n"))
end

---Print text nicely, joined with spaces
---@param ... any
_G.p = function(...)
    local msg_tbl = dev.map({...}, utils.inspect)
    print(unpack(msg_tbl))
    -- print(table.concat(msg_tbl, " "))
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

---Tests if string starts with `prefix`
---@param self string
---@param prefix string
---@return boolean
string.startswith = function(self, prefix)
    return vim.startswith(self, prefix)
end

---Tests if string ends with `suffix`
---@param self string
---@param suffix string
---@return boolean
string.endswith = function(self, suffix)
    return vim.endswith(self, suffix)
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

---Split a string on <space> by default. Optional delimiter.
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

---@class Switch
---@field Default table default empty table value
---@field Nil fun() default empty function value
---@operator call(any):Switch.Cases
_G.switch = setmetatable(
    {
        Default = {},
        Nil = function()
        end,
    },
    {
        ---Used like such:
        ---```lua
        ---  -- can also set this to a variale
        ---  switch(case) {
        ---    [1] = function() p('val 1') end, --> prints 'val 1'
        ---    [2] = p,                         --> prints '2'
        ---    abc = 'the value is abc',        --> returns 'the value is abc'
        ---    [switch.Default] = function(val) p('default: ' .. val) end, --> prints 'default: v'
        ---    [switch.Nil]     = function() p('nil val') end, --> does nothing
        ---  }
        ---```
        ---@param super Switch
        ---@param case any case to test against
        ---@return Switch.Cases
        __call = function(super, case)
            ---@class Switch.Cases
            ---@field [string] any
            ---@field [number] any
            ---@field [boolean] any
            ---@operator call(table):any
            return setmetatable({case}, {
                __call = function(self, cases)
                    local item = #self == 0 and super.Nil or self[1]
                    local ret = cases[item] or cases[super.Default] or super.Nil
                    if vim.is_callable(ret) then
                        return ret(item)
                    end
                    return ret
                end,
            })
        end,
    })

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

_G.BLACKLIST_FT = _t({
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
    "DiffviewFileStatus",
    "DiffviewFileHistoryPanel",
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
    "NeogitRebaseTodo",
    "NeogitCommitHistory",
    "NeogitLog",
    "NeogitMergeMessage",
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
    "WhichKey",
    -- "make",
    -- "cmake",
    -- "markdown",
    -- "vimwiki",
})

-- Universal variables that can be referenced from this file
M.user = uv.os_get_passwd()
M.username = M.user.username
M.shell = M.user.shell
M.uname = uv.os_uname()
M.sysname = M.uname.sysname -- jit.os:lower()
M.luajit = jit.version:split()[2]
M.pid = uv.os_getpid()

-- vim.schedule(
--     function()
--         _G.lb.dirs = {
--             home = Path:new(M.user.homedir), ---@type Path
--             config = Path:new(fn.stdpath("config")), ---@type Path
--             cache = Path:new(fn.stdpath("cache")), ---@type Path
--             data = Path:new(fn.stdpath("data")), ---@type Path
--             run = Path:new(fn.stdpath("run")), ---@type Path
--             tmp = Path:new(uv.os_tmpdir()) ---@type Path
--         }
--     end
-- )

M.dirs = {
    home = M.user.homedir,
    config = fn.stdpath("config"),
    cache = fn.stdpath("cache"),
    data = fn.stdpath("data"),
    state = fn.stdpath("state"),
    log = fn.stdpath("log"),
    run = fn.stdpath("run"),
    tmp = uv.os_tmpdir(),
    config_dirs = fn.stdpath("config_dirs"), ---@type string[]
    data_dirs = fn.stdpath("data_dirs"), ---@type string[]
}

-- vim.version() doesn't return a metatable
local version = {vim.version().major, vim.version().minor, vim.version().patch}
M.version = vim.version.parse(("%s.%s.%s"):format(unpack(version))) ---@type Version

-- Globalize
_G.lb.vars = {
    user = M.user,
    username = M.username,
    shell = M.shell,
    uname = M.uname,
    sysname = M.sysname,
    luajit = M.luajit,
    pid = M.pid,
    version = M.version,
}
_G.lb.dirs = M.dirs

return M
