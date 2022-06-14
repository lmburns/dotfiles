-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
-- ==========================================================================
-- FIX: Folding causing cursor to move one left on startup
-- FIX: Changelist is overridden somewhat when re-opening a file (I think coc?)
-- FIX: When opening Lf right after opening a file, sometimes 'p', 'o', or ')' are sent as keys
-- FIX: When opening command line window (i.e., <C-c>) todo-comments autocmd error

-- Tab character hides part of the line when file doesn't have tabs on (indent-blankline)

-- NOTE: A lot of credit can be given to kevinhwang91 for this setup
local ok, impatient = pcall(require, "impatient")
if ok then
    impatient.enable_profile()
end

require("common.global")
local utils = require("common.utils")
local augroup = utils.augroup
local autocmd = utils.autocmd
local command = utils.command
local map = utils.map

local ex = nvim.ex
local g = vim.g
local fn = vim.fn
local uv = vim.loop
local cmd = vim.cmd

-- Lua utilities
require("common.nvim")
require("dev")
require("options")

local conf_dir = fn.stdpath("config")
if uv.fs_stat(conf_dir .. "/plugin/packer_compiled.lua") then
    local packer_loader_complete = [[customlist,v:lua.require'packer'.loader_complete]]
    local config = ("%s/%s"):format(fn.stdpath("config"), "lua")
    cmd(
        ([[
        com! PackerUpdate lua require('plugins').update()
        com! PackerSync lua require('plugins').sync()
        com! PackerClean lua require('plugins').clean()
        com! PackerStatus lua require('plugins').status()
        com! PackerProfile lua require('plugins').profile_output()

        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)

        com! PSC so %s/plugins.lua | PackerCompile
        com! PSS so %s/plugins.lua | PackerSync
    ]]):format(
            packer_loader_complete,
            config,
            config
        )
    )

    map(
        "n",
        "<Leader>pp",
        function()
            require("plugins").compile()
        end,
        {desc = "Packer compile"}
    )

    local snargs = [[customlist,v:lua.require'packer.snapshot'.completion]]
    command(
        "PackerSnapshot",
        function(tbl)
            require("plugins").snapshot(tbl.fargs)
        end,
        {nargs = "+", complete = ("%s.create"):format(snargs)}
    )
    command(
        "PackerSnapshotRollback",
        function(tbl)
            require("plugins").rollback(tbl.fargs)
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

a.async_void(
    function()
        ex.packadd("cfilter")
        require("mapping")
        require("abbr")
        require("functions")
        require("autocmds")
        require("common.qf")
        require("common.mru")
        require("common.grepper")
        -- require("common.reg")
        -- require("plugs.fold")
    end
)()

-- ============================ Notify ================================ [[[
-- vim.notify = function(...)
--     ex.PackerLoad("nvim-notify")
--     vim.notify = require("notify")
--     vim.notify(...)
-- end
-- ]]]

-- ========================= Defer Loading ============================ [[[
-- ex.filetype("off")
g.loaded_clipboard_provider = 1

g.do_filetype_lua = 1
-- FIX: I noticed that filetype.vim is still being ran
g.did_load_filetypes = 0

require("plugs.filetype")

vim.schedule(
    function()
        local color = require("common.color")
        local set_hl = color.set_hl

        -- === Treesitter
        vim.defer_fn(
            function()
                require("plugs.treesitter")

                augroup(
                    "syntaxset",
                    {
                        event = "FileType",
                        pattern = "*",
                        command = function()
                            require("plugs.treesitter").hijack_synset()
                        end
                    }
                )

                ex.syntax("on")
                ex.filetype("on")
                ex.doautoall("filetypedetect BufRead")
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
                ex.runtime("autoload/provider/clipboard.vim")
                require("plugs.yanking") -- Needs to be loaded after clipboard is set

                if fn.exists("##ModeChanged") == 1 then
                    augroup(
                        "SelectModeNoYank",
                        {
                            event = "ModeChanged",
                            pattern = "*:s",
                            command = function()
                                ex.set("clipboard=")
                            end
                        },
                        {
                            event = "ModeChanged",
                            pattern = "s:*",
                            command = function()
                                ex.set("clipboard=unnamedplus")
                            end
                        }
                    )
                else
                    ex.packadd("nvim-hclipboard")
                    require("hclipboard").start()
                end

                augroup(
                    "lmb__Packer",
                    {
                        event = "BufWritePost",
                        pattern = {"*/plugins.lua", "*/common/control.lua"},
                        command = function()
                            ex.source("<afile>")
                            ex.PackerCompile()
                        end,
                        description = "Source plugins file"
                    }
                    -- {
                    --     event = "User",
                    --     pattern = "PackerCompileDone",
                    --     command = function()
                    --         vim.notify("Finished compiling")
                    --     end,
                    --     desc = "Send compilation done notification"
                    -- }
                )

                -- Highlight syntax
                if fn.exists("##SearchWrapped") == 1 then
                    augroup(
                        "SearchWrappedHighlight",
                        {
                            event = "SearchWrapped",
                            pattern = "*",
                            command = function()
                                require("common.builtin").search_wrap()
                            end
                        }
                    )
                end
            end,
            200
        )

        vim.defer_fn(
            function()
                vim.g.coc_global_extensions = {
                    -- "coc-docker",
                    -- "coc-lua",
                    -- "coc-git",
                    -- "coc-lists",
                    -- "coc-sh",
                    -- "coc-tslint",
                    -- "coc-vimtex",
                    -- "coc-rescript",
                    --
                    -- RLS is not needed with rust-analyzer
                    -- However, I've noticed that diagnostics are better and quicker
                    "coc-rls",
                    "coc-sumneko-lua",
                    "coc-json",
                    "coc-clangd",
                    "coc-css",
                    "coc-dlang",
                    "coc-go",
                    "coc-html",
                    "coc-markdownlint",
                    "coc-java",
                    "coc-perl",
                    "coc-pyright",
                    "coc-r-lsp",
                    "coc-rust-analyzer",
                    "coc-solargraph",
                    "coc-solidity",
                    "coc-sql",
                    "coc-toml",
                    "coc-vimlsp",
                    "coc-xml",
                    "coc-yaml",
                    "coc-zig",
                    "coc-tsserver",
                    "coc-eslint",
                    --
                    "coc-syntax",
                    "coc-prettier",
                    "coc-snippets",
                    "coc-yank",
                    "coc-diagnostic",
                    "coc-fzf-preview",
                    "coc-lightbulb",
                    "coc-marketplace",
                    "coc-tabnine",
                    "coc-tag",
                    "coc-word"
                }

                g.coc_enable_locationlist = 0
                g.coc_selectmode_mapping = 0

                -- Disable CocFzfList
                vim.schedule(
                    function()
                        -- augroup(
                        --     "CocFzfLocation",
                        --     {
                        --         event = "User",
                        --         pattern = "CocLocationsChange",
                        --         nested = true,
                        --         command = function()
                        --             return true
                        --         end
                        --     }
                        -- )

                        cmd("au! CocFzfLocation User ++nested CocLocationsChange")
                    end
                )

                autocmd(
                    {
                        event = "User",
                        pattern = "CocNvimInit",
                        once = true,
                        command = function()
                            require("plugs.coc").init()
                        end
                    }
                )

                set_hl("CocUnderline", {gui = "none"})
                set_hl("CocSemStatic", {gui = "bold"})
                set_hl("CocSemDefaultLibrary", {link = "Constant"})
                set_hl("CocSemDocumentation", {link = "Number"})
                -- set_hl("CocSemDefaultLibraryNamespace", {link = "TSNamespace"})

                ex.packadd("coc-kvs")
                ex.packadd("coc.nvim")
                ex.packadd("nvim-autopairs")
            end,
            300
        )
    end
)
