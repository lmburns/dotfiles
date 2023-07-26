---@module 'usr.global'
local M = {}

local fn = vim.fn
local uv = vim.uv
local lazy = require("usr.lazy")
local shared = lazy.require("usr.shared") ---@module 'usr.shared'

_G.lb = {}
---@class Rc
_G.Rc = {
    fn = {},
    state = {},
    plugin = {},
    shared = {},
    meta = {},
    blacklist = {},
    t = {},
}

-- ╒══════════════════════════════════════════════════════════╕
--                            Global
-- ╘══════════════════════════════════════════════════════════╛

-- Identity assignments for vim objects without a type

vim.defer_fn(function()
    ---@class vim.g
    ---@field [string] any
    vim.g = vim.g

    ---@class vim.b
    ---@field [string] any
    vim.b = vim.b

    ---@class vim.w
    ---@field [string] any
    vim.w = vim.w

    ---@class vim.t
    ---@field [string] any
    vim.t = vim.t

    ---@class vim.v
    ---@field [string] any
    vim.v = vim.v

    ---@class vim.fn
    ---@field [string] function
    vim.fn = vim.fn

    ---@class vim.env
    ---@field [string] string|integer
    vim.env = vim.env

    ---@class vim.cmd
    ---@operator call(Vim.Cmd.Opts|string):nil
    vim.cmd = vim.cmd
end, 300)

--  ╭───────────╮
--  │ Variables │
--  ╰───────────╯

-- Want these global for lua commands

---vim options: behaves like `set`
_G.o = vim.opt ---@type vim.opt

---global variables
_G.g = vim.g ---@type table<string, any>|vim.g

---global options. like `setglobal`
_G.go = vim.go ---@type table<number, vim.go>|vim.go

---window options: behaves like `:setlocal` (alias for vim.wo)
_G.wo = vim.wo ---@type table<number, vim.wo>|vim.wo

---buffer options: behaves like `:setlocal` (alias for vim.bo)
_G.bo = vim.bo ---@type table<number, vim.bo>|vim.bo

--  ══════════════════════════════════════════════════════════════════════

_G.fn = vim.fn ---@type vim.fn
_G.cmd = vim.cmd ---@type vim.cmd
_G.env = vim.env ---@type vim.env
_G.api = vim.api ---@type vim.api
_G.uv = vim.uv ---@type uv

_G.F = shared.F
_G.C = shared.collection

_G.uva = lazy.require("uva") ---@type UvFS
_G.ffi = lazy.require("usr.ffi") ---@type Usr.FFI
_G.mpi = lazy.require("usr.api") ---@type Api
_G.log = lazy.require("usr.lib.log") ---@type Log
_G.utils = lazy.require("usr.shared.utils") ---@type Usr.Utils|Usr.Utils.Fn

-- _G.async = require("plenary.async")
-- _G.a = require("plenary.async_lib")
-- _G.Job = require("plenary.job") ---@type Job
-- _G.List = lazy.require("plenary.collections.py_list") ---@type List
-- _G.Path = lazy.require("plenary.path") ---@type Path
-- _G.Enum = lazy.require("plenary.enum") ---@type Enum
-- _G.rex = lazy.require("rex_pcre2") ---@type PCRE
-- _G.op = require("plenary.operators")

_G.promise = require("promise") ---@type Promise
_G.async = require("async") ---@type Async
_G.await = _G.async.wait

---@class Nvim : Neovim
_G.nvim = require("nvim")

---@class PackerPlugins
---@field [string] any
_G.packer_plugins = _G.packer_plugins

-- Makes `_t` global
require("arshlib")
require("usr.shared.table")

--  ╭───────╮
--  │ Class │
--  ╰───────╯

---@class Void
---@operator call:nil
M.VOID = setmetatable({}, {
    ---@param self self
    ---@return fun(): Void
    __index = function(self) return self end,
    __newindex = function() end,
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
_G.RELOAD = function(...)
    utils.mod.reload(...)
end

---Reload a module, returning the newly loaded object
---@param name string
---@return module
_G.R = function(name)
    RELOAD(name)
    return require(name)
end

---Inspect a value
---@param v any
---@return string?
_G.I = function(v)
    return vim.inspect(v)
end

---Print text nicely, joined with spaces
---@param ... any
_G.p = function(...)
    local msg_tbl = shared.collection.map({...}, utils.inspect)
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

---Search for first match of `patt` in the string `subj`, starting from offset `init`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#match
---@param self string subject
---@param patt PCRERegex regular expression pattern
---@param init? integer start offset in the subject (can be negative)
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@return PCRECaptures? captures captures on success
string.rxmatch = function(self, patt, init, cf)
    return require("rex_pcre2").match(self, patt, init, cf)
end

---Intended for use in the generic for-loop construct.
---Returns an iterator for repeated matching of the pattern `patt` in the string `subj`,
---subject to flags `cf` and `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#gmatch
---@param self string subject
---@param patt PCRERegex regular expression pattern
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@return (fun(): PCRECaptures)? iterator
string.rxgmatch = function(self, patt, cf)
    return require("rex_pcre2").gmatch(self, patt, cf)
end

---Searches for all matches of the pattern `patt` in the string `subj`,
---and replaces them according to the parameters `repl` and `n`.
---
---More on `repl`:
---  - `string`: template for substitution
---     - `%0`: entire match
---     - `%1`: first capture, or if no captures, entire match
---     - `%X`: if greater than N matches, produces error
---     - `%a`: substituted with `a`
---  - `function`: called each match, submatches passed as args
---     - `string|number`: returns this and used as replacement
---     - `false|nil`: no replacement is made
---  - `table`: submatches
---
---See: https://rrthomas.github.io/lrexlib/manual.html#gsub
---## Example
---```lua
---  print(('what up'):rxsub('(\\w+)', '%1 %1'))      -- => what what up up
---  print(('what  up dude'):rxsub('\\s{2,}', 'XX'))  -- => whatXXup dude
---```
---@param self string subject
---@param patt PCRERegex regular expression pattern
---@param repl string|table|fun(submatches: ...): PCRERet0|false substitution source
---@param n? integer|PCREControlFn maximum number of matches to search for or control func
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@return string substitued
---@return number matches
---@return number substitutions_made
string.rxsub = function(self, patt, repl, n, cf)
    return require("rex_pcre2").gsub(self, patt, repl, n, cf)
end

---Search for first match of `patt` in the string `subj`, starting from offset `init`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#find
---@param self string subject
---@param patt PCRERegex regular expression pattern
---@param init? integer start offset in the subject (can be negative)
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@return number? start nil on failure
---@return number? end
---@return PCRECaptures? captures
string.rxfind = function(self, patt, init, cf)
    return require("rex_pcre2").find(self, patt, init, cf)
end

---Intended for use in the generic for-loop construct.
---Used for splitting a subject string subj into parts (sections).
---The `sep` parameter is a regex pattern representing separators between the sections.
--
---Returns an iterator for repeated matching of the pattern `sep` in the string `subj`,
---subject to flags `cf` and `ef`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#split
---@param self string subject
---@param sep PCRERegex separator (regular expression pattern)
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@return fun(): string, PCRECaptures
string.rxsplit = function(self, sep, cf)
    return require("rex_pcre2").split(self, sep, cf)
end

---Counts matches of the pattern `patt` in the string `subj`.
---
---See: https://rrthomas.github.io/lrexlib/manual.html#count
---@param self string subject
---@param patt PCRERegex regular expression pattern
---@param cf? PCRECompilationFlags compilation flags (bitwise OR)
---@return integer matches_found
string.rxcount = function(self, patt, cf)
    return require("rex_pcre2").count(self, patt, cf)
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
---@field Nil fun(_) default empty function value
---@operator call(any):Switch.Cases
Rc.fn.switch = setmetatable(
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
    local val
    while true do
        idx, val = next(tbl, idx)
        if type(idx) ~= "number" or math.floor(idx) ~= idx then
            break
        end
    end
    return idx, val
end

---Inverse `ipairs` iterator
---Skips keys that are numbers, returning only dictionary values
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

Rc.blacklist.dirs = _j({
    ".cache",
    ".git",
    ".github",
    ".svn",
    "BUILD",
    "__pycache__",
    "bower_components",
    "build",
    "cache",
    "dist",
    "libf_curriculum/*",
    "log",
    "node_modules",
    "public",
    "target",
    "tmp",
    "vendor",
    "venv",
    "virtualenv",
})

Rc.blacklist.ext = _j({
    "*~",
    "*-lock.json",
    "*.aux",
    "*.avi",
    "*.bak",
    "*.bin",
    "*.bmp",
    "*.cache",
    "*.class",
    "*.csproj",
    "*.csproj.user",
    "*.dll",
    "*.doc",
    "*.docx",
    "*.exe",
    "*.flac",
    "*.gif",
    "*.git",
    "*.hg",
    "*.ico",
    "*.jar",
    "*.jpeg",
    "*.jpg",
    "*.lock",
    "*.min.*",
    "*.mp3",
    "*.mp4",
    "*.o",
    "*.obj",
    "*.ogg",
    "*.out",
    "*.pdb",
    "*.pdf",
    "*.plist",
    "*.png",
    "*.ppt",
    "*.pptx",
    "*.pyc",
    "*.rar",
    "*.rbc",
    "*.sln",
    "*.svg",
    "*.svn",
    "*.swo",
    "*.swp",
    "*.tar",
    "*.tar.bz2",
    "*.tar.gz",
    "*.tar.xz",
    "*.tmp",
    "*.toc",
    "*.vscode",
    "*.wav",
    "*.xls",
    "*.zip",
    ".DS_Store",
})

Rc.blacklist.bufname = _j({
    "",
    "%[No Name%]",
    "%[Command Line%]",
    "%[Scratch%]",
    "%[Wilder Float %d%]",
    "%[Wilder Popup %d%]",
    "%[Quickfix List%]",
    "%[dap-repl%]",
    "Bufferize:",
    "Luapad",
    "NetrwMessage",
    "option%-window",
    "__coc_refactor__%d%d?",
    "://*",
    "fugitive://*",
    "gitsigns://*",
    "health://*",
    "man://*",
    "temp://*",
    "zipfile://*",
    "BqfPreviewFloatWin",
    "BqfPreviewScrollBar",
})

Rc.blacklist.buftype = _j({
    "nofile",
    "help",
    "nowrite",
    "quickfix",
    "terminal",
    "prompt",
})

Rc.blacklist.ft = _j({
    "",
    "nofile",
    "aerial",
    "alpha",
    "bqfpreview",
    "bufferize",
    "checkhealth",
    "cmp_docs",
    "cmp_menu",
    "coc-explorer",
    "coc-list",
    "coctree",
    "code-action-menu-menu",
    "code-action-menu-diff",
    "code-action-menu-details",
    "code-action-menu-warning-message",
    "comment",
    "commit",
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
    "DiffviewFiles",
    "DiffviewFileHistory",
    "DiffviewFileStatus",
    "dirdiff",
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
    "gitconfig",
    "gitrebase",
    "gitrebase",
    "gitsendemail",
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
    "NeogitCommitHistory",
    "NeogitCommitMessage",
    "NeogitCommitView",
    "NeogitGitCommandHistory",
    "NeogitLog",
    "NeogitLogView",
    "NeogitMergeMessage",
    "NeogitNotification",
    "NeogitPopup",
    "NeogitRebaseTodo",
    "NeogitStatus",
    "NeogitStatusNew",
    "neoterm",
    "neotest-summary",
    "netrw",
    "noice",
    "norg",
    "notify",
    "org",
    "Outline",
    "packer",
    "PlenaryTestPopup",
    "prompt",
    "qf",
    "quickmenu",
    "rebase",
    "registers",
    "scratchpad",
    "startuptime",
    "svn",
    "telescope",
    "TelescopePrompt",
    "TelescopeResults",
    "toggleterm",
    "Trouble",
    "tsplayground",
    "UltestOutput",
    "UltestSummary",
    "undotree",
    "vim-plug",
    "vista",
    "vista_kind",
    "VistaFloatingWin",
    "WhichKey",
    -- "make",
    -- "cmake",
    -- "markdown",
    -- "vimwiki",
    --  ━━━━━━━━━
    -- "startify",
    -- "neo-tree",
    -- "nerdtree",
    -- "LuaTree",
    -- "NvimTree",
    -- "orgagenda",
})

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Universal variables
-- vim.version() doesn't return a metatable
-- local version = {vim.version().major, vim.version().minor, vim.version().patch}
local user = uv.os_get_passwd()
local username = user.username
local shell = user.shell
local uname = uv.os_uname()
local sysname = uname.sysname

---@class Rc.Vars
local vars = {
    rc = env.NVIMRC,
    user = user,
    username = username,
    shell = shell,
    sysname = sysname,
    uname = uname,
    luajit = jit.version:split()[2],
    pid = uv.os_getpid(),
    -- version = vim.version.parse(("%s.%s.%s"):format(unpack(version))), ---@type Version
}

-- Only once
---@class Rc.Dirs
local dirs = {
    home = user.homedir,
    config = fn.stdpath("config"),
    cache = fn.stdpath("cache"),
    data = fn.stdpath("data"),
    state = fn.stdpath("state"),
    log = fn.stdpath("log"),
    config_dirs = fn.stdpath("config_dirs"), --[[ @as string[] ]]
    data_dirs = fn.stdpath("data_dirs"), --[[ @as string[] ]]

    run = fn.stdpath("run"),
    tmp = uv.os_tmpdir(),
    zdot = env.ZDOTDIR,
    xdg = {
        config = env.XDG_CONFIG_HOME,
        cache = env.XDG_CACHE_HOME,
        data = env.XDG_DATA_HOME,
        state = env.XDG_STATE_HOME,
        desktop = env.XDG_DESKTOP_DIR,
        docs = env.XDG_DOCUMENTS_DIR,
        project = env.XDG_PROJECT_DIR,
        test = env.XDG_TEST_DIR,
        bin = env.XDG_BIN_DIR,
    },
}

dirs.site = ("%s/site"):format(dirs.data)
dirs.pack = ("%s/pack"):format(dirs.site)
dirs.packer = ("%s/packer"):format(dirs.pack)

-- local to config/nvim
dirs.my = {
    lua = ("%s/lua"):format(dirs.config),           -- local lua files
    types = ("%s/types"):format(dirs.config),       -- local lua types

    doc = ("%s/doc"):format(dirs.config),           -- local documentation
    autoload = ("%s/autoload"):format(dirs.config), -- local autoloadable scripts
    compiler = ("%s/compiler"):format(dirs.config), -- local compiler
    ftplugin = ("%s/ftplugin"):format(dirs.config), -- local filetype plugins
    indent = ("%s/indent"):format(dirs.config),     -- local indent scripts
    spell = ("%s/spell"):format(dirs.config),       -- local spell files

    plugin = ("%s/plugin"):format(dirs.config),     -- local plugins
    pack = ("%s/pack"):format(dirs.config),         -- local packages

    parser = ("%s/parser"):format(dirs.config),     -- local treesitter parsers
    queries = ("%s/queries"):format(dirs.config),   -- local treesitter query files
    colors = ("%s/colors"):format(dirs.config),     -- local colorscheme
    syntax = ("%s/syntax"):format(dirs.config),     -- local syntax files

    -- Miscellaneous
    ftdetect = ("%s/ftdetect"):format(dirs.config), -- custom filetype detection
    after = ("%s/after"):format(dirs.config),       -- loading after ftplugin

    -- Non-standard
    patches = ("%s/patches"):format(dirs.config),     -- patch files
    snapshot = ("%s/snapshot"):format(dirs.config),   -- packer snapshot
    snippets = ("%s/UltiSnips"):format(dirs.config),  -- vim snippets
    vimscript = ("%s/vimscript"):format(dirs.config), -- vimscript plugin configs

    -- Not used
    keymap = ("%s/keymap"):format(dirs.config),   -- local keymap files
    rplugin = ("%s/rplugin"):format(dirs.config), -- local remote plugins
}

-- errno = uv.errno
env.NVIM_PID = vars.pid

Rc.F = shared.F
Rc.neo = lazy.require("usr.nvim") ---@type Nvim
Rc.api = lazy.require("usr.api") ---@type Api
Rc.lib = require("usr.lib") ---@type Usr.Lib
Rc.shared.utils = require("usr.shared.utils") ---@module 'usr.shared.utils'
Rc.shared.C = shared.collection
Rc.shared.hl = shared.color
Rc.shared.tbl = shared.tbl
Rc.shared.vec = shared.vec
Rc.dirs = dirs
Rc.meta = vars

Rc.regex = lazy.require("rex_pcre2") ---@type PCRE
Rc.t.VOID = M.VOID

local style = lazy.require("usr.style") ---@type Styles
Rc.style = style.current
Rc.style.plugins = style.plugins
Rc.icons = style.icons

return M
