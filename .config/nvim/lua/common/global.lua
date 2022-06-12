-- ╓                                                          ╖
-- ║                          Global                          ║
-- ╙                                                          ╜

P = function(...)
    local vars = vim.tbl_map(vim.inspect, {...})
    print(unpack(vars))
    return {...}
end

-- _G["PRINT"] = _G["P"]

RELOAD = function(...)
    return require("plenary.reload").reload_module(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

-- These may be specified in some files just to supress non-global warnings
--
_G.o = vim.opt -- vim options: behaves like `:set`
_G.opt_local = vim.opt_local
_G.opt_global = vim.opt_global
-- o           --  behaves like `:set` (global)
-- opt         --  behaves like `:set` (global and local)
-- opt_global  --  behaves like `:setglobal`
-- opt_local   --  behaves like `:setlocal`

_G.g = vim.g -- vim global variables:
_G.go = vim.go -- vim global options
_G.w = vim.wo -- vim window options: behaves like `:setlocal` (alias for vim.wo)
_G.b = vim.bo -- vim buffer options: behaves like `:setlocal` (alias for vim.bo)

_G.fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
_G.cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
_G.env = vim.env -- environment variable access
_G.api = vim.api
_G.exec = api.nvim_exec
_G.uv = vim.loop
_G.F = vim.F

_G.fmt = string.format

_G.dev = require("dev")
_G.List = require("plenary.collections.py_list")
_G.Path = require("plenary.path")
_G.Job = require("plenary.job")
_G.async = require("plenary.async")
_G.a = require("plenary.async_lib")
_G.nvim = require("nvim")
_G.ex = nvim.ex -- nvim ex functions e.g., PackerInstall()

-- Makes `_t` global
require("arshlib")

_G.BLACKLIST_FT = {
    "",
    "nofile",
    "alpha",
    "aerial",
    "bqfpreview",
    "bufferize",
    "coc-explorer",
    "coctree",
    "code-action-menu-menu",
    "commit",
    "conf",
    "dap-repl",
    "dapui_breakpoints",
    "dapui_scopes",
    "dapui_stacks",
    "dapui_watches",
    "diff",
    "floaterm",
    "floatline",
    "floggraph",
    "fugitive",
    "fzf",
    "git",
    "gitcommit",
    "gitrebase",
    "godoc",
    "help",
    "log",
    "lsp-installer",
    "luapad",
    "man",
    "minimap",
    "markdown",
    "neoterm",
    "NeogitCommitMessage",
    "NeogitCommitView",
    "NeogitGitCommandHistory",
    "NeogitLogView",
    "NeogitNotification",
    "NeogitPopup",
    "NeogitStatus",
    "NeogitStatusNew",
    "nerdtree",
    "NvimTree",
    "prompt",
    "qf",
    "quickmenu",
    "rebase",
    "scratchpad",
    "startify",
    "telescope",
    "TelescopePrompt",
    "TelescopeResults",
    "Trouble",
    "toggleterm",
    "undotree",
    "vimwiki",
    "vista",
    "VistaFloatingWin",
    "WhichKey"
}
