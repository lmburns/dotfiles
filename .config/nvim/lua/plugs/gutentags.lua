---@module 'plugs.gutentags'
local M = {}

local utils = require("common.utils")
local mpi = require("common.api")
local augroup = mpi.augroup

local fn = vim.fn
local o = vim.opt
local g = vim.g

function M.setup()
    o.tags = {"tags", "./tags", "./.tags", ".tags"}

    g.gutentags_enabled = 0
    g.gutentags_define_advanced_commands = 1
    g.gutentags_cache_dir = fn.expand("$XDG_CACHE_HOME/tags")

    g.gutentags_generate_on_write = 0
    g.gutentags_generate_on_new = 1
    g.gutentags_generate_on_missing = 1
    g.gutentags_generate_on_empty_buffer = 0
    g.gutentags_resolve_symlinks = 1
    g.gutentags_file_list_command =
        utils.list(
            {
                "fd",
                "--color=never",
                "--strip-cwd-prefix",
                "--type f",
                "--hidden",
                "--follow",
                "--exclude=.git",
                "--exclude=.svn",
                "--exclude=target/*",
                "--exclude=BUILD",
                "--exclude=node_modules/*",
                "--exclude=vendor/*",
                "--exclude=log/*",
                "--exclude=*.swp",
                "--exclude=*.bak",
                "--exclude=*.dll",
                "--exclude=*~",
            },
            " "
        )

    -- g.gutentags_file_list_command = {
    --     markers = {
    --         [".git"] = "git ls-files" -- 'git grep --cached -I -l -e $""'
    --     }
    -- }

    -- Tips: If we need the tags for a project not managed by vcs, we can touch a .root file
    g.gutentags_project_root = {".git", ".root", ".project", "package.json", "Cargo.toml", "go.mod"}
    g.gutentags_exclude_project_root = {"/opt", "/mnt", "/media", "/usr/local"}

    g.gutentags_gtags_dbpath = g.gutentags_cache_dir
    g.gutentags_modules = {"ctags"}

    -- --tag-relative=yes
    g.gutentags_ctags_extra_args = {
        "--fields=+niazS", -- molt
        "--extras=+q",
        -- "--c++-kinds=+px",
        -- "--c-kinds=+px",
        -- "--rust-kinds=+fPM",
        "--guess-language-eagerly",
    }

    g.gutentags_ctags_tagfile = ".tags"

    g.gutentags_exclude_filetypes = {
        "text",
        "conf",
        "markdown",
        "help",
        "man",
        "gitcommit",
        "gitconfig",
        "gitrebase",
        "gitsendemail",
        "git",
        "log",
        "Telescope",
        "TelescopePrompt",
        "TelescopeResults",
        "fugitive",
    }

    g.gutentags_ctags_exclude = {
        "*.git",
        "*.svn",
        "*.hg",
        "cache",
        "build",
        "dist",
        "bin",
        "node_modules",
        "bower_components",
        "target",
        "venv",
        "virtualenv",
        "__pycache__",
        "*-lock.json",
        "*.lock",
        "*.min.*",
        "*.bak",
        "*.zip",
        "*.pyc",
        "*.class",
        "*.sln",
        "*.csproj",
        "*.csproj.user",
        "*.tmp",
        "*.cache",
        "*.vscode",
        "*.pdb",
        "*.exe",
        "*.dll",
        "*.bin",
        "*.mp3",
        "*.ogg",
        "*.flac",
        "*.swp",
        "*.swo",
        ".DS_Store",
        "*.plist",
        "*.bmp",
        "*.gif",
        "*.ico",
        "*.jpg",
        "*.png",
        "*.svg",
        "*.rar",
        "*.zip",
        "*.tar",
        "*.tar.gz",
        "*.tar.xz",
        "*.tar.bz2",
        "*.pdf",
        "*.doc",
        "*.docx",
        "*.ppt",
        "*.pptx",
        "*.xls",
    }
end

function M.setup_ctags()
    g.gutentags_ctags_extra_args =
        vim.list_extend(g.gutentags_ctags_extra_args, {"/usr/include", "/usr/local/include"})
end

function M.setup_cpptags()
    g.gutentags_ctags_extra_args =
        vim.list_extend(g.gutentags_ctags_extra_args, {"/home/lucas/.config/tags/cpp_src"})
end

function M.setup_rubytags()
    if nvim.executable("ripper-tags") then
        g.gutentags_ctags_executable_ruby = "ripper-tags"
        g.gutentags_ctags_extra_args = {"--ignore-unsupported-options", "--recursive"}
    else
        g.gutentags_ctags_extra_args =
            vim.list_extend(
                g.gutentags_ctags_extra_args,
                {"/home/lucas/.local/share/rbenv/versions/3.1.0/lib/ruby/3.1.0"}
            )
    end
end

function M.setup_rusttags()
    g.gutentags_ctags_extra_args = {"--rust-kinds=fPM"}
end

function M.setup_perltags()
    g.gutentags_ctags_extra_args =
        vim.list_extend(
            g.gutentags_ctags_extra_args,
            {"/home/lucas/.local/share/perl5/perlbrew/build/perl-5.35.4/perl-5.35.4"}
        )
end

function M.setup_luatags()
    local runtime = require("plugs.coc").get_lua_runtime()
    local ret = {}

    for k, _ in pairs(runtime) do
        table.insert(ret, k)
    end

    g.gutentags_ctags_extra_args = vim.list_extend(g.gutentags_ctags_extra_args, ret)
end

local function init()
    M.setup()

    augroup(
        "lmb__Gutentags",
        {
            event = "User",
            pattern = "vim-gutentags",
            command = [[call gutentags#setup_gutentags()]],
        },
        -- {
        --     event = "FileType",
        --     pattern = "cpp",
        --     command = function()
        --         require("plugs.gutentags").setup_cpptags()
        --     end
        -- },
        -- {
        --     event = "FileType",
        --     pattern = "c",
        --     command = function()
        --         require("plugs.gutentags").setup_ctags()
        --     end
        -- },
        -- {
        --     event = "FileType",
        --     pattern = "rust",
        --     command = function()
        --         require("plugs.gutentags").setup_rusttags()
        --     end
        -- },
        -- {
        --     event = "FileType",
        --     pattern = "perl",
        --     command = function()
        --         require("plugs.gutentags").setup_perltags()
        --     end
        -- },
        {
            event = "FileType",
            pattern = "ruby",
            command = function()
                require("plugs.gutentags").setup_rubytags()
            end,
        }
    -- {
    --     event = "FileType",
    --     pattern = "lua",
    --     command = function()
    --         require("plugs.gutentags").setup_luatags()
    --     end
    -- }
    )
end

-- ft_opt = {
--     aspvbs = "--asp-kinds=f",
--     awk = "--awk-kinds=f",
--     c = "--c-kinds=fp",
--     cpp = "--c++-kinds=fp --language-force=C++",
--     cs = "--c#-kinds=m",
--     erlang = "--erlang-kinds=f",
--     fortran = "--fortran-kinds=f",
--     java = "--java-kinds=m",
--     javascript = "--javascript-kinds=f",
--     lisp = "--lisp-kinds=f",
--     lua = "--lua-kinds=f",
--     matla = "--matlab-kinds=f",
--     pascal = "--pascal-kinds=f",
--     php = "--php-kinds=f",
--     python = "--python-kinds=fm --language-force=Python",
--     ruby = "--ruby-kinds=fF",
--     scheme = "--scheme-kinds=f",
--     sh = "--sh-kinds=f",
--     sql = "--sql-kinds=f",
--     tcl = "--tcl-kinds=m",
--     verilog = "--verilog-kinds=f",
--     vim = "--vim-kinds=f",
--     go = "--go-kinds=f",
--     rust = "--rust-kinds=fPM",
--     ocaml = "--ocaml-kinds=mf"
-- }

init()

return M
