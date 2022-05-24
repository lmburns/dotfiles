-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
-- ==========================================================================
-- FIX: Folding causing cursor to move one left on startup
-- FIX: Tab character hides part of the line

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

require("mapping")
require("abbr")

-- =========================== Markdown =============================== [[[
g.vimwiki_ext2syntax = {
    [".Rmd"] = "markdown",
    [".rmd"] = "markdown",
    [".md"] = "markdown",
    [".markdown"] = "markdown",
    [".mdown"] = "markdown"
}
g.vimwiki_list = {{path = "~/vimwiki", syntax = "markdown", ext = ".md"}}
g.vimwiki_table_mappings = 0
-- ]]] === Markdown ===

require("functions")
require("autocmds")
require("common.qf")
require("common.mru")
-- require("common.reg")
require("common.grepper")

-- ============================ Notify ================================ [[[
a.async_void(
    function()
        vim.notify = function(...)
            ex.PackerLoad("nvim-notify")
            vim.notify = require("notify")
            vim.notify(...)
        end
    end
)()
-- ]]]

-- ========================= Defer Loading ============================ [[[
g.loaded_clipboard_provider = 1
g.do_filetype_lua = 1
g.did_load_filetypes = 0

-- ex.filetype("off")
-- g.did_load_filetypes = 0 -- this messes up NvimRestart

vim.schedule(
    function()
        local color = require("common.color")
        local set_hl = color.set_hl

        vim.defer_fn(
            function()
                require("plugs.fold")
            end,
            50
        )

        -- === Treesitter
        vim.defer_fn(
            function()
                require("plugs.tree-sitter")

                -- require("filetype").resolve()
                -- g.did_load_filetypes = nil
                -- cmd("runtime! filetype.vim")

                augroup(
                    "syntaxset",
                    {
                        event = "FileType",
                        pattern = "*",
                        command = function()
                            require("plugs.tree-sitter").hijack_synset()
                        end
                    }
                )

                ex.syntax("on")
                ex.filetype("on")
                ex.doautoall("filetypedetect BufRead") -- Runs filetype.resolve()
            end,
            15
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
                            command = [[set clipboard=]]
                        },
                        {
                            event = "ModeChanged",
                            pattern = "s:*",
                            command = [[set clipboard=unnamedplus]]
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
                    "coc-clangd",
                    "coc-css",
                    "coc-diagnostic",
                    "coc-dlang",
                    "coc-fzf-preview",
                    "coc-go",
                    "coc-html",
                    "coc-json",
                    "coc-lightbulb",
                    "coc-marketplace",
                    "coc-perl",
                    "coc-prettier",
                    "coc-pyright",
                    "coc-rls",
                    "coc-r-lsp",
                    "coc-rust-analyzer",
                    "coc-sh",
                    "coc-snippets",
                    "coc-solargraph",
                    "coc-solidity",
                    "coc-sql",
                    "coc-syntax",
                    "coc-tabnine",
                    "coc-tag",
                    "coc-toml",
                    "coc-tsserver",
                    "coc-eslint",
                    "coc-vimlsp",
                    "coc-vimtex",
                    "coc-xml",
                    "coc-yaml",
                    "coc-yank",
                    "coc-zig"
                }

                g.coc_enable_locationlist = 0
                g.coc_selectmode_mapping = 0

                -- Disable CocFzfList
                vim.schedule(
                    function()
                        -- augroup(
                        --     {"CocFzfLocation", false},
                        --     {
                        --         event = "User",
                        --         nested = true,
                        --         pattern = "CocLocationsChange"
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
                ex.packadd("coc-wxy")
                ex.packadd("coc.nvim")
            end,
            300
        )
    end
)
