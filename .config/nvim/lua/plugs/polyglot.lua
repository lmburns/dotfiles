---@module 'plugs.polyglot'
---@author 'lmburns'
---@license 'BSD3'
local M = {}

local g = vim.g

function M.setup()
    g.polyglot_disabled = {
        "ftdetect",
        -- "sensible",
        -- "markdown",
        "rustpeg",
        "lf",
        "ron",
        "cmake",
        "css",
        "cpp",
        "d",
        "dart",
        "dockerfile",
        "gitconfig",
        "go",
        "gomod",
        "html",
        "ini",
        "java",
        "julia",
        -- "lua",
        "json",
        -- "kotlin",
        -- "lua",
        "make",
        -- "perl",
        -- "python",
        -- "query",
        -- "ruby",
        "rust",
        "scss",
        -- "vim",
        -- "solidity",
        -- "teal",
        -- "tsx",
        -- "typescript",
        -- "javascript",
        "zig",
        "zsh",
        "sh",
    }

    g.no_csv_maps = 1
    g.vim_jsx_pretty_disable_tsx = 1
    g.vim_jsx_pretty_disable_js = 1
    -- g.vim_jsx_pretty_colorful_config = 1
    -- g.vim_jsx_pretty_template_tags = "jsx"
end

local function init()
    M.setup()
end

init()

return M
