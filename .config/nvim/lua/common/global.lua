local M = {}

local fn = vim.fn
local uv = vim.loop

-- ╓                                                          ╖
-- ║                          Global                          ║
-- ╙                                                          ╜

P = function(...)
    local vars = vim.tbl_map(vim.inspect, {...})
    print(unpack(vars))
    return {...}
end

---Reload a module
---@vararg string
---@return nil
RELOAD = function(...)
    return require("plenary.reload").reload_module(...)
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

_G.o = vim.opt -- vim options: behaves like `:set`
_G.opt_local = vim.opt_local
_G.opt_global = vim.opt_global
-- o           --  behaves like `:set` (global)
-- opt         --  behaves like `:set` (global and local)
-- opt_global  --  behaves like `:setglobal`
-- opt_local   --  behaves like `:setlocal`

-- Only use 'vim.ex' when indexing 'vim.cmd'
vim.ex = vim.cmd

-- Having these be global helps when typing the command after pressing ':'

_G.g = vim.g -- vim global variables:
_G.go = vim.go -- vim global options
_G.w = vim.wo -- vim window options: behaves like `:setlocal` (alias for vim.wo)
_G.b = vim.bo -- vim buffer options: behaves like `:setlocal` (alias for vim.bo)

_G.fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
_G.cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
_G.env = vim.env -- environment variable access
_G.api = vim.api
_G.uv = vim.loop
_G.F = vim.F

_G.fmt = string.format

_G.dev = require("dev")
_G.List = require("plenary.collections.py_list")
-- _G.Path = require("plenary.path")
-- _G.Job = require("plenary.job")
-- _G.async = require("plenary.async")
-- _G.a = require("plenary.async_lib")

_G.promise = require("promise")
_G.async = require("async")
_G.await = require("async").wait

_G.nvim = require("nvim")
-- _G.ex = nvim.ex -- nvim ex functions e.g., PackerInstall()

---@type { [string]: { [string]: any } }
_G.packer_plugins = _G.packer_plugins

-- Makes `_t` global
require("arshlib")

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
    run = fn.stdpath("run"),
}

return M
