-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
-- ==========================================================================
-- TODO: Possibly fork rnvimr to lf
-- FIX: Folding causing cursor to move one left on startup
--
-- NOTE: A lot of credit can be given to kevinhwang91 for this setup
local ok, impatient = pcall(require, "impatient")
if ok then
    impatient.enable_profile()
end

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
-- local au = utils.au
local create_augroup = utils.create_augroup

-- Lua utilities
require("dev")
require("options")

-- Plugins need to be compiled each time to work it seems
local conf_dir = fn.stdpath("config")
if uv.fs_stat(conf_dir .. "/plugin/packer_compiled.lua") then
    local packer_loader_complete = [[customlist,v:lua.require'packer'.loader_complete]]
    cmd(
        ([[
        com! PackerInstall lua require('plugins').install()
        com! PackerUpdate lua require('plugins').update()
        com! PackerSync lua require('plugins').sync()
        com! PackerClean lua require('plugins').clean()
        com! PackerStatus lua require('plugins').status()
        com! PackerProfile lua require('plugins').profile_output()

        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)

        com! PSC so ~/.config/nvim/lua/plugins.lua | PackerCompile
        com! PSS so ~/.config/nvim/lua/plugins.lua | PackerSync
    ]]):format(
            packer_loader_complete
        )
    )

    -- Is there a way to repeat these?
    local snargs = [[customlist,v:lua.require'packer.snapshot'.completion]]
    cmd(
        ([[
        com! -nargs=+ -complete=%s.create PackerSnapshot lua require('plugins').snapshot(<f-args>)
        com! -nargs=+ -complete=%s.rollback PackerSnapshotRollback  lua require('plugins').rollback(<f-args>)
        com! -nargs=+ -complete=%s.snapshot PackerSnapshotDelete lua require('plugins.snapshot').delete(<f-args>)
    ]]):format(
            snargs,
            snargs,
            snargs
        )
    )
else
    require("plugins").compile()
end

require("abbr")
require("mapping")

-- =========================== Markdown =============================== [[[
-- FIX: Shift-Tab in markdown
cmd [[
  augroup markdown
    autocmd!
    autocmd FileType markdown,vimwiki
      \ setl iskeyword+=-|
      \ vnoremap ``` <esc>`<O<esc>S```<esc>`>o<esc>S```<esc>k$|
      \ nnoremap <buffer> <F4> !pandoc % --pdf-engine=xelatex -o %:r.pdf|
      \ inoremap ** ****<Left><Left>|
      \ inoremap <expr> <right> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"|
      \ imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"
  augroup END
]]

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
vim.notify = function(...)
    cmd [[PackerLoad nvim-notify]]
    vim.notify = require("notify")
    vim.notify(...)
end
-- ]]]

-- cmd [[
--     filetype off
--     let g:did_load_filetypes = 0
-- ]]

-- ========================= Defer Loading ============================ [[[
g.loaded_clipboard_provider = 1

vim.schedule(
    function()
        -- vim.defer_fn(
        --     function()
        --       require("common.fold")
        --     end, 50
        -- )

        -- === Defer mappings
        -- vim.defer_fn(
        --     function()
        --       local maps = require("mapping").mappings
        --       local map = require("common.utils").map
        --       for _, m in ipairs(maps) do
        --         map(unpack(m))
        --       end
        --     end, 10
        -- )

        -- === Treesitter
        vim.defer_fn(
            function()
                require("plugs.tree-sitter")

                -- au! syntaxset
                -- au syntaxset FileType * lua require('plugs.tree-sitter').hijack_synset()

                -- cmd [[
                --    runtime! filetype.vim
                --    filetype plugin indent on
                -- ]]
            end,
            15
        )

        -- === Clipboard
        vim.defer_fn(
            function()
                g.loaded_clipboard_provider = nil
                cmd("runtime autoload/provider/clipboard.vim")

                if fn.exists("##ModeChanged") == 1 then
                    augroup(
                        "SelectModeNoYank",
                        {
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
                        }
                    )
                else
                    -- Nice, but doesn't copy newline at beginning of line when switching buffers
                    --
                    cmd("packadd nvim-hclipboard")
                    require("hclipboard").start()
                end

                augroup(
                    "lmb__Packer",
                    {
                        {
                            event = "BufWritePost",
                            pattern = "*/plugins.lua",
                            command = [[so <afile> | PackerCompile]]
                        }
                    }
                )

                -- highlight syntax
                if fn.exists("##SearchWrapped") == 1 then
                    api.nvim_create_autocmd(
                        "SearchWrapped",
                        {
                            callback = function()
                                require("common.builtin").search_wrap()
                            end,
                            group = create_augroup("SearchWrappedHighlight"),
                            pattern = "*"
                        }
                    )
                end

                api.nvim_create_autocmd(
                    "TextYankPost",
                    {
                        callback = function()
                            cmd [[hi HighlightedyankRegion ctermbg=Red   guibg=#cc6666]]
                            pcall(vim.highlight.on_yank, {higroup = "HighlightedyankRegion", timeout = 165})
                        end,
                        pattern = "*",
                        group = create_augroup("lmb__Highlight"),
                        desc = "Highlight a selection on yank"
                    }
                )
            end,
            200
        )

        vim.defer_fn(
            function()
                vim.g.coc_global_extensions = {
                    "coc-clangd",
                    "coc-css",
                    "coc-diagnostic",
                    "coc-dlang",
                    "coc-docker",
                    "coc-fzf-preview",
                    "coc-git",
                    "coc-go",
                    "coc-html",
                    "coc-json",
                    "coc-lua",
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
                        cmd("au! CocFzfLocation User ++nested CocLocationsChange")
                    end
                )

                api.nvim_create_autocmd(
                    "User",
                    {
                        callback = function()
                            require("plugs.coc").init()
                        end,
                        once = true,
                        pattern = "CocNvimInit"
                    }
                )

                local color = require("common.color")
                local link = color.link
                local set_hl = color.set_hl

                -- cmd [[
                --   au User CocNvimInit ++once lua require('plugs.coc').init()
                -- ]]

                set_hl("CocSemStatic", {gui = "bold"})
                link("CocSemDefaultLibrary", "Special")
                link("CocSemDocumentation", "Number")

                cmd("packadd coc-kvs")
                cmd("packadd coc.nvim")
            end,
            300
        )
    end
)
