vim.loader.enable()

require("usr.global")
local mpi = require("usr.api")
local autocmd = mpi.autocmd
local map = mpi.map

local uv = vim.loop
local g = vim.g
local cmd = vim.cmd

require("usr.nvim")
require("usr.core.options")

if uv.fs_stat(("%s/plugin/packer_compiled.lua"):format(Rc.dirs.config)) then
    local loader = [[customlist,v:lua.require'packer'.loader_complete]]
    local snargs = [[customlist,v:lua.require'packer.snapshot'.completion]]
    local config = ("%s/lua"):format(Rc.dirs.config)
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
    vim.notify = require("usr.shared.utils").notify
    vim.notify(...)
end

map("n", "<C-S-n>", function()
    require("notify").dismiss()
end)

-- ========================= Defer Loading ============================ [[[
g.loaded_clipboard_provider = 1
require("usr.core.lsp")
require("usr.core.autocmds")
require("usr.core.commands")
require("usr.core.filetype")
local maps = require("usr.core.mappings")

vim.g.coc_global_extensions = {
    --
    -- "coc-teal",
    -- "coc-markdownlint",
    "coc-vimtex",
    "coc-texlab",
    "coc-sql",
    "coc-toml",
    "coc-xml",
    "coc-yaml",
    "coc-json",
    --
    "coc-css",
    -- "coc-stylelintplus", -- FIX: Need to make this work
    "coc-html",
    -- "coc-html-css-support",
    "coc-tsserver",
    "coc-eslint",
    "coc-react-refactor",
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
    "coc-zls",
    --
    -- "coc-syntax",
    -- "coc-fzf-preview",
    -- "coc-tag",
    "coc-prettier",
    "coc-diagnostic",
    "coc-marketplace",
    "coc-tabnine",
    "coc-word",
    "coc-snippets",
}

require("usr.lib.ftplugin").setup()

vim.schedule(
    function()
        vim.defer_fn(function()
            for _, m in ipairs(maps.deferred) do
                map(unpack(m))
            end
        end, 5)

        -- === Treesitter
        vim.defer_fn(function()
            -- require("usr.plugs.bufclean").enable()
            -- cmd("doau filetypedetect BufRead")

            require("plugs.treesitter")

            -- cmd("unlet g:did_load_filetypes")
            -- cmd.runtime({"filetype.vim", bang = true})
            cmd.syntax("on")
            api.nvim_clear_autocmds({group = "syntaxset", event = "FileType"})
            autocmd({
                group = "syntaxset",
                event = "FileType",
                pattern = "*",
                command = function()
                    require("plugs.treesitter").hijack_synset()
                end,
            })
            cmd.filetype("on")
            -- cmd.filetype("plugin", "on")
            -- cmd.filetype("indent", "on")

            -- cmd [[
            --     unlet g:did_load_filetypes
            --     runtime! filetype.vim
            --     syntax on
            --     au! syntaxset
            --     au  syntaxset FileType * lua require('plugs.treesitter').hijack_synset()
            --     filetype on
            --     " filetype plugin on
            --     " filetype indent on
            -- ]]
        end, 15)

        -- === Clipboard
        vim.defer_fn(function()
            g.loaded_clipboard_provider = nil
            cmd.runtime("autoload/provider/clipboard.vim")
            require("plugs.neoclip") -- Needs to be loaded after clipboard is set
        end, 50)

        vim.defer_fn(function()
            require("usr.api.abbr")
            require("usr.lib.qf")
            require("usr.plugs.mru")
            require("usr.plugs.grepper")
            require("usr.plugs.jump")
        end, 80)

        vim.defer_fn(function()
            g.coc_enable_locationlist = 0
            g.coc_selectmode_mapping = 0

            -- Disable CocFzfList
            vim.defer_fn(function()
                if not pcall(cmd, "au! CocFzfLocation User ++nested CocLocationsChange") then
                    vim.schedule(function()
                        vim.notify("Failed to disable CocFzfLocation")
                    end)
                end
            end, 50)

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
        end, 100)

        -- === Folding
        -- Deferring this function will override any modeline with foldelevel=0
        vim.defer_fn(function()
            require("plugs.fold")
        end, 800)

        vim.defer_fn(function()
            cmd.packadd("cfilter")

            if not vim.bo.filetype:match("^git") then
                cmd.helptags("ALL")
            end
        end, 1000)
    end
)
