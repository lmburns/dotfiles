---@module 'plugs.polyglot'
local M = {}

local g = vim.g

function M.setup()
    g.polyglot_disabled = {
        "ftdetect",
        -- "sensible",

        "rustpeg",
        "doxygen",
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
        "json",
        "make",
        "scss",
        "tmux",
        "typescript",
        "typescriptreact",
        "zig",
        "zsh",
        "markdown",

        -- enabled to have better hover docs
        -- "lua",
        -- "rust",
        -- "perl",
        -- "python",
        -- "query",
        -- "ruby",
        -- "vim",
        -- "solidity",
        -- "teal",
        -- "tsx",
        -- "javascript",
        -- "sh",
        -- "kotlin",
    }
end

local function init()
    M.setup()
end

init()

return M
