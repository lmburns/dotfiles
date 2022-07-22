--[[
FIX: Changelist is overridden somewhat when re-opening a file (I think coc-lua?)
FIX: Cursor blinking is very fast on text operators which don't trigger which-key (gq)
     * This just started yesterday (i.e., June 22)
     * Firstly, this was able to be fixed by disabling lazyredraw
     * Started again with and without lazyredraw
     * It stops without the Bufferline plugin
     * Is not present in telescope prompt
     * Happens with heavier coc langservers (e.g., Lua, Rust, Python, but not toml, yaml, solidity)
     * It's definitely gotta be that Bufferline and some langservers are refreshing the same thing
     * With "showtabline=2" it happens. Not with any other setting
     * ModeChange gets ran over and over only on operator pending
     * With a timeoutlen over 800 it stops
     * With a timeoutlen = 800 and updatetime=2000, happens every other time
     * With a timeoutlen = 800 and updatetime=4000, happens never

Notes:
    * Tab character hides part of the line when file doesn't have tabs on (indent-blankline)
--]]
-- NOTE: A lot of credit can be given to kevinhwang91 for this setup
local ok, impatient = pcall(require, "impatient")
if ok then
    impatient.enable_profile()
end

-- vim.cmd [[let $NVIM_COC_LOG_LEVEL='debug']]

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
local D = require("dev")
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

ex.packadd("cfilter")
require("mapping")
require("abbr")
require("functions")
require("autocmds")
require("common.qf")
require("common.mru")
require("common.grepper")
require("common.jump")

-- require("common.stl")
-- require("common.reg")
-- require("plugs.fold")

vim.notify = function(...)
    vim.notify = require("notify")
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
        local C = require("common.color")

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
                ex.doau("filetypedetect BufRead")
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
                require("plugs.neoclip") -- Needs to be loaded after clipboard is set

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
                    -- "coc-dlang",
                    -- "coc-yank",
                    -- "coc-lightbulb",
                    --
                    -- RLS is not needed with rust-analyzer
                    -- However, I've noticed that diagnostics are better and quicker
                    "coc-rls",
                    "coc-sumneko-lua",
                    "coc-json",
                    "coc-clangd",
                    "coc-css",
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
                    "coc-diagnostic",
                    "coc-fzf-preview",
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

                C.plugin(
                    "CocInit",
                    {
                        CocUnderline = {gui = "none"},
                        CocSemStatic = {gui = "bold"},
                        CocSemDefaultLibrary = {link = "Constant"},
                        CocSemDocumentation = {link = "Number"}
                    }
                )

                -- set_hl("CocSemDefaultLibraryNamespace", {link = "TSNamespace"})

                ex.packadd("coc-kvs")
                ex.packadd("coc.nvim")
                ex.packadd("nvim-autopairs")
            end,
            300
        )
    end
)
