---@module 'plugs.gutentags'
local M = {}

local log = Rc.lib.log
local utils = Rc.shared.utils
local augroup = Rc.api.augroup
local map = Rc.api.map

local cmd = vim.cmd
-- local fn = vim.fn
local o = vim.opt
local g = vim.g

function M.setup()
    o.tags = {"tags", "./tags", "./.tags", ".tags"}

    g.gutentags_enabled = 1
    g.gutentags_define_advanced_commands = 1
    g.gutentags_cache_dir = ("%s/tags"):format(Rc.dirs.xdg.cache)

    g.gutentags_generate_on_write = 1
    g.gutentags_generate_on_new = 1
    g.gutentags_generate_on_missing = 1
    g.gutentags_generate_on_empty_buffer = 0
    g.gutentags_resolve_symlinks = 1
    -- g.gutentags_init_user_func =

    g.gutentags_file_list_command = {
        markers = {
            -- -- 'git grep --cached -I -l -e $""'
            [".git"] = "git ls-files",
            [".root"] = _j({
                "fd",
                "--color=never",
                "--strip-cwd-prefix",
                "--type f",
                "--hidden",
                "--follow",
                "--exclude=.git",
                "--exclude=.github",
                "--exclude=.svn",
                "--exclude=target",
                "--exclude=BUILD",
                "--exclude=node_modules",
                "--exclude=vendor",
                "--exclude=log",
                "--exclude=*.swp",
                "--exclude=*.bak",
                "--exclude=*.dll",
                "--exclude=*~",
                "--exclude=0-extra",
                "--exclude=_ignore",
            }):concat(" "),

        },
    }

    g.gutentags_modules = {"ctags"}

    g.gutentags_project_root = {
        ".git",
        ".hg",
        ".svn",
        ".root",
        ".project",
        "package.json",
        "go.mod",
        "CMakeLists.txt",
        "Makefile",
        "makefile",
        "pom.xml",
        "Gemfile",
        "Gemfile.lock",
        "Cargo.toml",
        "Cargo.lock",
        ".idea",
        ".vscode",
        ".zinit",
    }
    g.gutentags_exclude_project_root = {
        "/opt",
        "/mnt",
        "/media",
        "/usr/local",
        "/usr",
        "/etc",
    }
    -- g.gutentags_project_info = { }

    g.gutentags_exclude_filetypes = Rc.blacklist.ft:merge({
        "text",
        "conf",
        "markdown",
        "vimwiki",
    })

    g.gutentags_gtags_dbpath = ("%s/gtags"):format(g.gutentags_cache_dir)
    g.gutentags_gtags_options_file = ".gutgtags"
    g.gutentags_auto_add_gtags_cscope = 0

    g.gutentags_scopefile = "cscope.out"
    g.gutentags_auto_add_cscope = 0
    g.gutentags_cscope_build_inverted_index = 0

    g.gutentags_ctags_tagfile = "tags"
    g.gutentags_ctags_auto_set_tags = 1
    g.gutentags_ctags_check_tagfile = 0
    g.gutentags_ctags_post_process_cmd = ""
    g.gutentags_ctags_exclude_wildignore = 1

    -- --tag-relative=yes
    g.gutentags_ctags_extra_args = {
        "--fields=+niazSks", -- molt
        -- "--fields=+ailmnzS",
        "--extras=+q",
        "--c++-kinds=+px",
        "--c-kinds=+px",
        "--rust-kinds=+fPM",
        "--vim-kinds=acfvmn",
        "--awk-kinds=f",
        "--guess-language-eagerly",
        -- "--sort=no",
        -- "--append=no",
        -- "--recurse=no",
        -- "--output-format=e-ctags",
    }

    g.gutentags_ctags_exclude = {
        "*~",
        "*.min.*",
        "*.bak",
        "*.zip",
        "*.pyc",
        "*.class",
        "*.sln",
        "*.csproj",
        "*.csproj.user",
        "*.tmp",
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
        "*.md",
        "*-lock.json",
        "*.lock",
        "*bundle*.js",
        "*build*.js",
        ".*rc*",
        "*.json",
        "*.map",
        "*.Master",
        "tags*",
        "cscope.*",
        "*.css",
        "*.less",
        "*.scss",
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        "*.cache",
        "*.vscode",
        "*.git",
        "*.hg",
        "*.svn",
        ".github",
        "BUILD",
        "__pycache__",
        "bin",
        "bower_components",
        "build",
        "cache",
        "dist",
        "log",
        "node_modules",
        "target",
        "target",
        "vendor",
        "venv",
        "virtualenv",
        "0-extra/",
        "_ignore/",
        "*/tests/*",
        "*sites/*/files/*",
        "compiled",
        "docs",
        "example",
        "bundle",
    }
end

function M.setup_ctags()
    g.gutentags_ctags_extra_args =
        vim.list_extend(g.gutentags_ctags_extra_args, {"*.h", "*.c"})
    -- vim.list_extend(g.gutentags_ctags_extra_args, {"/usr/include", "/usr/local/include"})
end

function M.setup_cpptags()
    g.gutentags_ctags_extra_args = vim.list_extend(g.gutentags_ctags_extra_args, {
        "/home/lucas/.config/tags/cpp_src",
        "--language-force=C++"
    })
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

    map(
        "n",
        "<Leader>jc",
        function()
            cmd.GutentagsToggleEnabled()
            log.info(("status: %s"):format(
                g.gutentags_enabled == 1 and "enabled" or "disabled"
            ), {title = "Gutentags"})
        end,
        {desc = "Toggle gutentags"}
    )
    augroup(
        "lmb__Gutentags",
        {
            event = "User",
            pattern = "vim-gutentags",
            command = [[call gutentags#setup_gutentags()]],
        },
        -- {
        --     event = "FileType",
        --     pattern = "rust",
        --     command = function()
        --         g.gutentags_enabled = 0
        --     end
        -- },
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
        --     end,
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
