-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
-- ==========================================================================
-- TODO: Fix bqf fzf
-- TODO: Possibly fork rnvimr to lf
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
        com! PI lua require('plugins').install()
        com! PU lua require('plugins').update()
        com! PS lua require('plugins').sync()
        com! PackerClean lua require('plugins').clean()
        com! PSC so ~/.config/nvim/lua/plugins.lua | PackerCompile
        com! PackerStatus lua require('plugins').status()
        com! -nargs=? PC lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)
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

autocmd(
    "c_env", {
      [[FileType c nnoremap <Leader>r<CR> :FloatermNew --autoclose=0 gcc % -o %< && ./%< <CR>]],
    }, true
)

-- autocmd(
--     "cpp_env", {
--       [[FileType cpp nnoremap <Leader>r<CR> :FloatermNew --autoclose=0 g++ % -o %:r && ./%:r <CR>]],
--       [[FileType cpp nnoremap <buffer> <Leader>kk :Fcman<CR>]],
--     }, true
-- )

api.nvim_create_autocmd(
    "FileType", {
      callback = function()
        map(
            "n", "<Leader>r<CR>",
            ":FloatermNew --autoclose=0 g++ % -o %:r && ./%:r <CR>"
        )
        map("n", "<Leader>kk", ":Fcman<CR>", { buffer = true })
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

-- BufRead * autocmd FileType <buffer> if line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif
--
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

          end, 20
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

            -- NOTE: For whatever reason this doesn't save to file
            --       or keep the order in which the history was executed
            --
            -- api.nvim_create_autocmd(
            --     "CmdlineEnter", {
            --       callback = function()
            --         require("common.cmdhist")
            --       end,
            --       group = api.nvim_create_augroup("CmdHist", { clear = true }),
            --     }
            -- )
            --
            -- api.nvim_create_autocmd(
            --     "CmdlineEnter", {
            --       callback = function()
            --         require("common.cmdhijack")
            --       end,
            --       group = api.nvim_create_augroup("CmdHijack", { clear = true }),
            --     }
            -- )

            -- highlight syntax
            if fn.exists("##SearchWrapped") == 1 then
              api.nvim_create_autocmd(
                  "SearchWrapped", {
                    callback = function()
                      require("common.builtin").search_wrap()
                    end,
                    group = api.nvim_create_augroup(
                        "SearchWrappedHighlight", { clear = true }
                    ),
                    pattern = "*",
                  }
              )
            end

            api.nvim_create_autocmd(
                "TextYankPost", {
                  callback = function()
                    if not vim.b.visual_multi then
                      pcall(
                          vim.highlight.on_yank,
                          { higroup = "IncSearch", timeout = 165 }
                      )
                    end
                  end,
                  pattern = "*",
                  group = api.nvim_create_augroup(
                      "LuaHighlight", { clear = true }
                  ),
                }
            )
          end, 200
      )

      vim.defer_fn(
          function()
            g.coc_global_extensions = {
              "coc-snippets",
              "coc-diagnostic",
              "coc-yank",
              "coc-marketplace",
              "coc-tabnine",
              "coc-tag",
              "coc-html",
              "coc-css",
              "coc-json",
              "coc-yaml",
              "coc-pyright",
              "coc-vimtex",
              "coc-vimlsp",
              "coc-sh",
              "coc-sql",
              "coc-xml",
              "coc-fzf-preview",
              "coc-syntax",
              "coc-git",
              "coc-go",
              "coc-clangd",
              "coc-rls",
              "coc-rust-analyzer",
              "coc-toml",
              "coc-solargraph",
              "coc-prettier",
              "coc-r-lsp",
              "coc-perl",
              "coc-tsserver",
              "coc-zig",
              "coc-dlang",
              "coc-lua",
            }

            g.coc_enable_locationlist = 0
            g.coc_selectmode_mapping = 0

            api.nvim_create_autocmd(
                "User", {
                  callback = function()
                    require("plugs.coc").init()
                  end,
                  once = true,
                  group = create_augroup("CocInit", true),
                }
            )

            -- au User CocNvimInit ++once lua require('plugs.coc').init()
            cmd [[
              hi! link CocSemDefaultLibrary Special
              hi! link CocSemDocumentation Number
              hi! CocSemStatic gui=bold
           ]]

            cmd("packadd coc.nvim")
          end, 300
      )

      -- vim.defer_fn(
      --     function()
      --     end, 800
      -- )

    end
)

-- ]]] === Defer Loading ===
