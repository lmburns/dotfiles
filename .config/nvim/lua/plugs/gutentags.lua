local M = {}

local augroup = require("common.utils").augroup

local fn = vim.fn
local o = vim.opt
local g = vim.g

function M.setup()
    -- cmd [[set tags=tags,./.tags,.tags]]
    -- o.tags:append({"tags", "./.tags", ".tags"})
    o.tags = {"tags", "./.tags", "./.tags;", ".tags"}

    g.gutentags_enabled = 1
    g.gutentags_define_advanced_commands = 1
    g.gutentags_cache_dir = fn.expand("$XDG_CACHE_HOME/tags")

    g.gutentags_generate_on_write = 1
    g.gutentags_generate_on_new = 1
    g.gutentags_generate_on_missing = 1
    g.gutentags_generate_on_empty_buffer = 0
    g.gutentags_resolve_symlinks = 1
    -- g.gutentags_file_list_command = "rg --files --hidden"
    g.gutentags_file_list_command = "fd --hidden --strip-cwd-prefix --type f -E .git"

    -- g.gutentags_file_list_command = {
    --     markers = {
    --         [".git"] = "git ls-files" -- 'git grep --cached -I -l -e $""'
    --     }
    -- }

    -- Tips: If we need the tags for a project not managed by vcs, we can touch a .root file
    g.gutentags_project_root = {".git", ".root", ".project", "package.json"}
    g.gutentags_exclude_project_root = {"/opt", "/mnt", "/media", "/usr/local"}

    -- g.gutentags_auto_add_gtags_cscope = 0
    g.gutentags_gtags_dbpath = g.gutentags_cache_dir
    g.gutentags_modules = {"ctags"}

    -- if nvim.executable("gtags-cscope") then
    --     table.insert(g.gutentags_modules, "gtags_cscope")
    -- end

    -- if nvim.executable("cscope") then
    --     table.insert(g.gutentags_modules, "cscope")
    -- end

    g.gutentags_ctags_extra_args = {"--fields=+niazS", "--extras=+q", "--c++-kinds=+px", "--c-kinds=+px"}

    -- --tag-relative=yes
    -- g.gutentags_ctags_extra_args = {
    --     "--append",
    --     "--recurse=yes",
    --     "--c-kinds=+px",
    --     "--c++-kinds=+plx",
    --     "--fields=+n",
    --     "--fields=+i",
    --     "--fields=+a",
    --     "--fields=+z",
    --     "--fields=+S",
    --     "--fields=+m",
    --     "--fields=+l",
    --     "--fields=+t",
    --     "--extras=+q"
    -- }

    -- Tag file name for ctags
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
        "fugitive"
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
        "*.xls"
    }
end

function M.setup_ctags()
    g.gutentags_ctags_extra_args = vim.list_extend(g.gutentags_ctags_extra_args, {"/usr/include", "/usr/local/include"})
end

function M.setup_cpptags()
    g.gutentags_ctags_extra_args = vim.list_extend(g.gutentags_ctags_extra_args, {"/home/lucas/.config/tags/cpp_src"})
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
            command = [[call gutentags#setup_gutentags()]]
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
        {
            event = "FileType",
            pattern = "perl",
            command = function()
                require("plugs.gutentags").setup_perltags()
            end
        },
        {
            event = "FileType",
            pattern = "ruby",
            command = function()
                require("plugs.gutentags").setup_rubytags()
            end
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

init()

return M
