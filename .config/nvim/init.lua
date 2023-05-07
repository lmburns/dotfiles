local ok, impatient = pcall(require, "impatient")
if ok then
    impatient.enable_profile()
end
vim.loader.enable()

require("common.global")

local mpi = require("common.api")
local augroup = mpi.augroup
local autocmd = mpi.autocmd
local map = mpi.map

local g = vim.g
local cmd = vim.cmd
local uv = vim.loop

require("common.nvim")
require("options")
require("plugs.legendary").setup()

if uv.fs_stat(("%s/plugin/packer_compiled.lua"):format(lb.dirs.config)) then
    local loader = [[customlist,v:lua.require'packer'.loader_complete]]
    local snargs = [[customlist,v:lua.require'packer.snapshot'.completion]]
    local config = ("%s/lua"):format(lb.dirs.config)
    cmd(
        ([[
        com! PackerUpdate lua require('plugins').update()
        com! PackerSync lua require('plugins').sync()
        com! PackerClean lua require('plugins').clean()
        com! PackerStatus lua require('plugins').status()
        com! PackerProfile lua require('plugins').profile_output()

        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)

        com! -nargs=+ -complete=%s PackerSnapshot lua require('plugins').snapshot(<q-args>)
        com! -nargs=+ -complete=%s PackerSnapshotRollback lua require('plugins').rollback(<q-args>)
        com! -nargs=+ -complete=%s PackerSnapshotDelete lua require('plugins').delete(<f-args>)

        com! PSC so %s/plugins.lua | PackerCompile
        com! PSS so %s/plugins.lua | PackerSync
    ]]):format(
            loader,
            ("%s.create"):format(snargs),
            ("%s.rollback"):format(snargs),
            ("%s.snapshot"):format(snargs),
            config,
            config
        )
    )

    map("n", "<Leader>pp", "PackerCompile", {cmd = true, desc = "Packer compile"})
else
    require("plenary.async_lib").async_void(function()
        require("plugins").compile()
    end)
end

---@diagnostic disable-next-line:duplicate-set-field
vim.notify = function(...)
    require("plugins").loader("nvim-notify")
    require("plugins").loader("desktop-notify.nvim")
    vim.notify = require("common.utils").notify
    vim.notify(...)
end

require("autocmds")
-- ========================= Defer Loading ============================ [[[
g.loaded_clipboard_provider = 1
require("functions")
local maps = require("mapping")

require("lsp")
require("plugs.filetype")

vim.schedule(
    function()
        vim.defer_fn(function()
            cmd.packadd("cfilter")
            vim.iter(maps.deferred):each(function(m)
                map(unpack(m))
            end)
        end, 5)

        -- === Treesitter
        vim.defer_fn(function()
            -- cmd("doau filetypedetect BufRead")
            cmd.syntax("on")
            cmd.filetype("on")
            require("plugs.treesitter")

            augroup("syntaxset", {
                event = "FileType",
                pattern = "*",
                command = function()
                    require("plugs.treesitter").hijack_synset()
                end,
            })
        end, 15)

        -- === Clipboard
        vim.defer_fn(function()
            g.loaded_clipboard_provider = nil
            cmd.runtime("autoload/provider/clipboard.vim")
            require("plugs.neoclip")     -- Needs to be loaded after clipboard is set
        end, 50)

        vim.defer_fn(function()
            require("abbr")
            require("common.qf")
            require("common.mru")
            require("common.grepper")
            require("common.jump")
        end, 80)

        -- === Folding
        -- Deferring this function will override any modeline with foldelevel=0
        vim.defer_fn(function()
                require("plugs.fold")
            end,
            200)

        vim.defer_fn(function()
            vim.g.coc_global_extensions = {
                --
                -- "coc-teal",
                -- "coc-ccls",
                -- "coc-pydoc",
                -- "coc-golines",
                -- "coc-gocode",
                -- "coc-godot",
                --
                -- "coc-class-css",
                -- "coc-react-refactor",
                -- "coc-jest",
                -- "coc-inline-jest",
                -- "coc-apollo",
                -- "coc-apollo-graphql",
                -- "coc-tailwindcss",
                -- "coc-cssmodules",
                -- "coc-htmlhint",
                -- "coc-nginx",
                -- "coc-styled-components",
                -- "coc-style-helper",
                -- "coc-jsref",
                --
                -- "coc-copilot",
                --
                -- "coc-markdown-preview-enhanced",
                -- "coc-webview",
                --
                "coc-vimtex",
                "coc-texlab",
                "coc-markdownlint",
                "coc-sql",
                "coc-toml",
                "coc-xml",
                "coc-yaml",
                "coc-json",
                --
                "coc-css",
                "coc-stylelintplus",     -- FIX: Need to make this work
                "coc-html",
                "coc-html-css-support",
                "coc-tsserver",
                "coc-eslint",
                --
                "coc-rust-analyzer",
                "coc-sumneko-lua",
                "coc-clangd",
                "coc-cmake",
                "coc-go",
                "coc-java",
                "coc-perl",
                "coc-pyright",
                "@yaegassy/coc-ruff",
                "coc-r-lsp",
                "coc-solargraph",
                "coc-solidity",
                "coc-vimlsp",
                "coc-zig",
                --
                "coc-syntax",
                "coc-prettier",
                "coc-diagnostic",
                "coc-fzf-preview",
                "coc-marketplace",
                "coc-tabnine",
                "coc-tag",
                "coc-word",
            }

            g.coc_enable_locationlist = 0
            g.coc_selectmode_mapping = 0

            -- Disable CocFzfList
            vim.schedule(function()
                if not pcall(cmd, "au! CocFzfLocation User ++nested CocLocationsChange") then
                    vim.notify("Failed to disable CocFzfLocation")
                end
            end)

            autocmd({
                event = "User",
                pattern = "CocNvimInit",
                once = true,
                command = function()
                    require("plugs.coc").init()
                end,
            })

            cmd.packadd("coc-kvs")
            cmd.packadd("coc.nvim")
            cmd.packadd("nvim-autopairs")
        end, 50)
    end
)
