-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
-- ==========================================================================
-- TODO: Possibly fork rnvimr to lf
--
-- NOTE: A lot of credit can be given to kevinhwang91 for this setup
local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd
local create_augroup = utils.create_augroup

-- Lua utilities
require("lutils")
require("options")

-- Plugins need to be compiled to work it seems
local conf_dir = fn.stdpath("config")
if uv.fs_stat(conf_dir .. "/plugin/packer_compiled.lua") then
  local packer_loader_complete =
      [[customlist,v:lua.require'packer'.loader_complete]]
  cmd(
      ([[
        com! PackerInstall lua require('plugins').install()
        com! PackerUpdate lua require('plugins').update()
        com! PackerSync lua require('plugins').sync()
        com! PackerClean lua require('plugins').clean()
        com! PackerStatus lua require('plugins').status()
        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)

        cnoreabbrev PI PackerInstall
        cnoreabbrev PU PackerUpdate
        cnoreabbrev PS PackerSync
        cnoreabbrev PC PackerCompile

        com! PSC so ~/.config/nvim/lua/plugins.lua | PackerCompile
        com! PSS so ~/.config/nvim/lua/plugins.lua | PackerSync
    ]]):format(packer_loader_complete)
  )
else
  require("plugins").compile()
end

require("mapping")

-- ============================ UndoTree ============================== [[[
require("common.utils").map("n", "<Leader>ut", ":UndotreeToggle<CR>")
vim.cmd(
    [[command! -nargs=0 UndotreeToggle lua require('plugs.undotree').toggle()]]
) -- ]]]

-- ============================== C/Cpp =============================== [[[
cmd [[
  function! s:FullCppMan()
      let old_isk = &iskeyword
      setl iskeyword+=:
      let str = expand("<cword>")
      let &l:iskeyword = old_isk
      execute 'Man ' . str
  endfunction

  command! Fcman :call s:FullCppMan()
]]

api.nvim_create_autocmd(
    "FileType", {
      callback = function()
        map(
            "n", "<Leader>r<CR>",
            ":FloatermNew --autoclose=0 gcc % -o %< && ./%< <CR>"
        )
      end,
      pattern = "c",
      group = create_augroup("CEnv", true),
    }
)

api.nvim_create_autocmd(
    "FileType", {
      callback = function()
        map(
            "n", "<Leader>r<CR>",
            ":FloatermNew --autoclose=0 g++ % -o %:r && ./%:r <CR>"
        )
        map("n", "<Leader>kk", ":Fcman<CR>")
      end,
      pattern = "cpp",
      group = create_augroup("CppEnv", true),
    }
)
-- ]]]

-- =========================== Markdown =============================== [[[
cmd [[
  augroup markdown
    autocmd!
    autocmd FileType markdown,vimwiki
      \ setl iskeyword+=-|
      \ vnoremap ``` <esc>`<O<esc>S```<esc>`>o<esc>S```<esc>k$|
      \ nnoremap <buffer> <F4> !pandoc % --pdf-engine=xelatex -o %:r.pdf|
      \ inoremap ** ****<Left><Left>|
      \ inoremap <expr> <right> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"|
      \ vnoremap <Leader>si :s/`/*/g<CR>
  augroup END
]]
-- ]]] === Markdown ===

-- ============================== Man ================================= [[[
g.no_man_maps = 1
cmd [[cabbrev man <C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Man' : 'man')<CR>]]
-- ]]]

require("functions")
require("autocmds")
require("common.qf")
require("common.mru")
require("common.reg")
require("highlight")

-- ============================ Notify ================================ [[[
vim.notify = function(...)
  cmd [[PackerLoad nvim-notify]]
  vim.notify = require("notify")
  vim.notify(...)
end
-- ]]]

api.nvim_create_autocmd(
    "BufHidden", {
      callback = function() require("common.builtin").wipe_empty_buf() end,
      buffer = 0,
      once = true,
      group = create_augroup("FirstBuf", true),
    }
)

api.nvim_create_autocmd(
    "WinLeave", {
      callback = function() require("common.win").record() end,
      pattern = "*",
      group = create_augroup("MruWin", true),
    }
)

api.nvim_create_autocmd(
    "BufRead", {
      callback = function()
        -- Buffer option here doesn't work like global
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "v"
      end,
      group = create_augroup("FormatOptions"),
      pattern = "*",
    }
)

-- Don't know why vim-polyglot sets files with no extensions to `sh`
api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" }, {
      command = "if expand('<afile>:e') == '' | set ft= | end",
      group = create_augroup("FixPolyglot"),
      pattern = "*",
    }
)

-- I've noticed that `BufRead` works, but `BufReadPost` doesn't
-- at least, with allowing opening a file with `nvim +5`
api.nvim_create_autocmd(
    "BufRead", {
      callback = function()
        -- local ft = vim.api.nvim_get_option_value("filetype", {})
        local row, col = unpack(api.nvim_buf_get_mark(0, "\""))
        if { row, col } ~= { 0, 0 } and row <= api.nvim_buf_line_count(0) then
          api.nvim_win_set_cursor(0, { row, 0 })
        end
      end,
      pattern = "*",
      once = false,
      group = create_augroup("jump_last_position", true),
    }
)

-- cmd [[
--     filetype off
--     let g:did_load_filetypes = 0
-- ]]

-- ========================= Defer Loading ============================ [[[
g.loaded_clipboard_provider = 1

vim.schedule(
    function()

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

            -- NOTE: This prevents `jsonc` and such being set locally
            -- unlet g:did_load_filetypes
            -- doautoall syntaxset FileType

            -- au! syntaxset
            -- au syntaxset FileType * lua require('plugs.tree-sitter').hijack_synset()
            -- NOTE: This prevents indentline from running
            -- doautoall filetypedetect BufRead
            cmd [[
               runtime! filetype.vim
               filetype plugin indent on
            ]]

          end, 15
      )

      -- === Clipboard
      vim.defer_fn(
          function()
            local autocmd = require("common.utils").autocmd
            g.loaded_clipboard_provider = nil
            cmd("runtime autoload/provider/clipboard.vim")

            if fn.exists("##ModeChanged") == 1 then
              autocmd(
                  "SelectModeNoYank", {
                    [[ModeChanged *:s set clipboard=]],
                    [[ModeChanged s:* set clipboard=unnamedplus]],
                  }, true
              )
            else
              -- Nice, but doesn't copy newline at beginning of line when switching buffers
              --
              -- cmd("packadd nvim-hclipboard")
              -- require("hclipboard").start()
            end

            api.nvim_create_autocmd(
                "BufWritePost", {
                  command = "so <afile> | PackerCompile",
                  pattern = "*/plugins.lua",
                  group = create_augroup("Packer"),
                }
            )

            -- highlight syntax
            if fn.exists("##SearchWrapped") == 1 then
              api.nvim_create_autocmd(
                  "SearchWrapped", {
                    callback = function()
                      require("common.builtin").search_wrap()
                    end,
                    group = create_augroup("SearchWrappedHighlight"),
                    pattern = "*",
                  }
              )
            end

            api.nvim_create_autocmd(
                "TextYankPost", {
                  callback = function()
                    pcall(
                        vim.highlight.on_yank,
                        { higroup = "IncSearch", timeout = 165 }
                    )
                  end,
                  pattern = "*",
                  group = create_augroup("LuaHighlight"),
                }
            )
          end, 200
      )

      vim.defer_fn(
          function()
            -- FIX: This doesn't automatically install like it did in vim
            g.coc_global_extensions = {
              "coc-clangd",
              "coc-css",
              "coc-diagnostic",
              "coc-dlang",
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
              "coc-vimlsp",
              "coc-vimtex",
              "coc-xml",
              "coc-yaml",
              "coc-yank",
              "coc-zig",
            }

            g.coc_enable_locationlist = 0
            g.coc_selectmode_mapping = 0

            -- Disable CocFzfList
            vim.schedule(
                function()
                  cmd("au! CocFzfLocation User ++nested CocLocationsChange")
                end
            )

            -- api.nvim_create_autocmd(
            --     "User", {
            --       callback = function()
            --         require("plugs.coc").init()
            --       end,
            --       once = true,
            --       group = create_augroup("CocNvimInit", true),
            --     }
            -- )

            cmd [[
              au User CocNvimInit ++once lua require('plugs.coc').init()
           ]]

            cmd("packadd coc-kvs")
            cmd("packadd coc.nvim")
          end, 250
      )

      vim.defer_fn(function() require("common.fold") end, 800)

    end
)

-- ]]] === Defer Loading ===
