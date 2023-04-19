local ok, impatient = pcall(require, "impatient")
if ok then
    impatient.enable_profile()
end

local dirs = require("common.global").dirs
local _ = require("common.global")

local D = require("dev")
local utils = require("common.utils")
local augroup = utils.augroup
local autocmd = utils.autocmd
local command = utils.command
local map = utils.map

local g = vim.g
local fn = vim.fn
local uv = vim.loop
local cmd = vim.cmd

require("common.nvim")
require("options")

local conf_dir = dirs.config
if uv.fs_stat(conf_dir .. "/plugin/packer_compiled.lua") then
    local packer_loader_complete = [[customlist,v:lua.require'packer'.loader_complete]]
    local config = ("%s/%s"):format(dirs.config, "lua")
    cmd(
        ([[
        com! PackerUpdate lua require('plugins').update()
        com! PackerSync lua require('plugins').sync()
        com! PackerClean lua require('plugins').clean()
        com! PackerStatus lua require('plugins').status()
        com! PackerProfile lua require('plugins').profile_output()

        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)
        com! -nargs=1 -complete=%s PackerReinstall lua require('common.packer').reinstall(<f-args>)

        com! PSC so %s/plugins.lua | PackerCompile
        com! PSS so %s/plugins.lua | PackerSync
    ]]):format(
            packer_loader_complete,
            packer_loader_complete,
            config,
            config
        )
    )

    map("n", "<Leader>pp", D.ithunk(require("plugins").compile), {desc = "Packer compile"})

    local snargs = [[customlist,v:lua.require'packer.snapshot'.completion]]
    command(
        "PackerSnapshot",
        function(tbl)
            require("plugins").snapshot(tbl.args)
        end,
        {nargs = "+", complete = ("%s.create"):format(snargs)}
    )
    command(
        "PackerSnapshotRollback",
        function(tbl)
            require("plugins").rollback(tbl.args)
        end,
        {nargs = "+", complete = ("%s.rollback"):format(snargs)}
    )
    command(
        "PackerSnapshotDelete",
        function(tbl)
            require("plugins").delete(tbl.fargs)
        end,
        {nargs = "+", complete = ("%s.snapshot"):format(snargs)}
    )
else
    require("plugins").compile()
end

cmd.packadd("cfilter")
require("mapping")
require("abbr")
require("functions")
require("autocmds")
require("lsp")
require("common.qf")
require("common.mru")
require("common.grepper")
require("common.jump")

---@diagnostic disable-next-line:duplicate-set-field
vim.notify = function(...)
    require("plugins").loader("nvim-notify")
    require("plugins").loader("desktop-notify.nvim")
    vim.notify = require("common.utils").notify
    vim.notify(...)
end
-- ========================= Defer Loading ============================ [[[
g.loaded_clipboard_provider = 1

require("plugs.filetype")

vim.schedule(
    function()
        -- === Treesitter
        vim.defer_fn(
            function()
                -- cmd("doau filetypedetect BufRead")
                cmd.syntax("on")
                cmd.filetype("on")
                require("plugs.treesitter")

                augroup(
                    "syntaxset",
                    {
                        event = "FileType",
                        pattern = "*",
                        command = function()
                            require("plugs.treesitter").hijack_synset()
                        end,
                    }
                )
            end,
            15
        )

        -- === Folding
        -- Deferring this function will override any modeline with foldelevel=0
        vim.defer_fn(
            function()
                require("plugs.fold")
            end,
            200
        )

        -- === Clipboard
        vim.defer_fn(
            function()
                g.loaded_clipboard_provider = nil
                cmd.runtime("autoload/provider/clipboard.vim")
                require("plugs.neoclip") -- Needs to be loaded after clipboard is set

                if fn.exists("##ModeChanged") == 1 then
                    augroup(
                        "SelectModeNoYank",
                        {
                            event = "ModeChanged",
                            pattern = "*:s",
                            command = function()
                                vim.o.clipboard = nil
                            end,
                        },
                        {
                            event = "ModeChanged",
                            pattern = "s:*",
                            command = function()
                                vim.o.clipboard = "unnamedplus"
                            end,
                        }
                    )
                    -- else
                    -- cmd.packadd("nvim-hclipboard")
                    -- require("hclipboard").start()
                end

                augroup(
                    "lmb__Packer",
                    {
                        event = "BufWritePost",
                        pattern = {"*/plugins.lua", "*/common/control.lua"},
                        command = function()
                            cmd.source("<afile>")
                            cmd.PackerCompile()
                        end,
                        description = "Source plugins file"
                    }
                )

                -- Highlight syntax
                if nvim.exists("##SearchWrapped") then
                    augroup(
                        "SearchWrappedHighlight",
                        {
                            event = "SearchWrapped",
                            pattern = "*",
                            command = function()
                                require("common.builtin").search_wrap()
                            end,
                        }
                    )
                end
            end,
            200
        )

        vim.defer_fn(
            function()
                vim.g.coc_global_extensions = {
                    -- "coc-vimtex",
                    -- "coc-texlab",
                    --
                    -- "coc-teal",
                    -- "coc-class-css",
                    -- "coc-react-refactor",
                    -- "coc-jest",
                    -- "coc-inline-jest",
                    -- "coc-apollo",
                    -- "coc-apollo-graphql",
                    -- "coc-lightbulb",

                    "coc-sql",
                    "coc-toml",
                    "coc-xml",
                    "coc-yaml",
                    "coc-markdownlint",
                    "coc-markdown-preview-enhanced",
                    "coc-webview",
                    --
                    "coc-stylelintplus", -- FIX: Need to make this work
                    "coc-html-css-support",
                    "coc-css",
                    "coc-html",
                    "coc-json",
                    "coc-tsserver",
                    "coc-eslint",
                    --
                    "coc-rust-analyzer",
                    "coc-sumneko-lua",
                    "coc-clangd",
                    "coc-go",
                    -- "coc-gocode",
                    "coc-java",
                    "coc-julia",
                    "coc-perl",
                    "coc-pyright",
                    "coc-r-lsp",
                    "coc-solargraph",
                    "coc-solidity",
                    "coc-vimlsp",
                    "coc-zig",
                    --
                    -- "coc-snippets",
                    "coc-syntax",
                    "coc-prettier",
                    "coc-diagnostic",
                    "coc-fzf-preview",
                    "coc-marketplace",
                    "coc-tabnine",
                    "coc-tag",
                    "coc-word",
                    "coc-import-cost",
                }

                g.coc_enable_locationlist = 0
                g.coc_selectmode_mapping = 0

                -- Disable CocFzfList
                vim.schedule(
                    function()
                        if not pcall(cmd, "au! CocFzfLocation User ++nested CocLocationsChange") then
                            vim.notify("Failed to disable CocFzfLocation")
                        end
                    end
                )

                autocmd(
                    {
                        event = "User",
                        pattern = "CocNvimInit",
                        once = true,
                        command = function()
                            require("plugs.coc").init()
                        end,
                    }
                )

                cmd.packadd("coc-kvs")
                cmd.packadd("coc.nvim")
                cmd.packadd("nvim-autopairs")
            end,
            1
        )
    end
)
