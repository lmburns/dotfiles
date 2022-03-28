-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
-- ==========================================================================
require("common.utils")

-- Lua utilities
require("lutils")

require("base")
require("options")
require("autocmds")
require("mapping")
require("functions")

-- cmd([[command! PU packadd packer.nvim | lua require('plugins').update()]])
-- cmd([[command! PI packadd packer.nvim | lua require('plugins').install()]])
-- cmd([[command! PS packadd packer.nvim | lua require('plugins').sync()]])
-- cmd([[command! PC packadd packer.nvim | lua require('plugins').clean()]])

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
        com! PC lua require('plugins').clean()
        com! PSC so plugins.lua | PackerCompile
        com! PackerStatus lua require('plugins').status()
        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)
    ]]):format(packer_loader_complete)
  )
else
  require("plugins").compile()
end

vim.cmd("source ~/.config/nvim/vimscript/plug.vim")

-- ============================ UndoTree ============================== [[[
require("common.utils").map("n", "<Leader>ut", ":UndotreeToggle<CR>")
vim.cmd(
    [[command! -nargs=0 UndotreeToggle lua require('plugs.undotree').toggle()]]
)
-- ]]] === UndoTree ===

-- Man
g.no_man_maps = 1
cmd [[cabbrev man <C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Man' : 'man')<CR>]]

require("highlight")

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

      -- vim.defer_fn(
      --     function()
      --       require("plugs.treesitter")
      --
      --       cmd(
      --           [[
      --       unlet g:did_load_filetypes
      --       runtime! filetype.vim
      --       au! syntaxset
      --       au syntaxset FileType * lua require('plugs.treesitter').hijack_synset()
      --       filetype on
      --       doautoall filetypedetect BufRead
      --   ]]
      --       )
      --     end, 20
      -- )

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
              -- cmd("packadd nvim-hclipboard")
              -- require("hclipboard").start()
            end

            -- autocmd(
            --     "Packer",
            --     [[BufWritePost */plugins.lua so <afile> | PackerCompile]], true
            -- )
            autocmd(
                "CmdHist", [[CmdlineEnter : lua require('common.cmdhist')]],
                true
            )
            autocmd(
                "CmdHijack", [[CmdlineEnter : lua require('common.cmdhijack')]],
                true
            )

            -- highlight syntax
            if fn.exists("##SearchWrapped") == 1 then
              autocmd(
                  "SearchWrappedHighlight",
                  [[SearchWrapped * lua require('common.builtin').search_wrap()]],
                  true
              )
            end

            autocmd(
                "LuaHighlight", {
                  ([[TextYankPost * lua if not vim.b.visual_multi then %s end]]):format(
                      [[pcall(vim.highlight.on_yank, {higroup='IncSearch', timeout=100})]]
                  ),
                }, true
            )
          end, 200
      )

      -- vim.defer_fn(
      --     function()
      --       g.coc_global_extensions = {
      --         "coc-snippets",
      --         "coc-diagnostic",
      --         "coc-yank",
      --         "coc-marketplace",
      --         "coc-tabnine",
      --         "coc-tag",
      --         "coc-html",
      --         "coc-css",
      --         "coc-json",
      --         "coc-yaml",
      --         "coc-pyright",
      --         "coc-vimtex",
      --         "coc-vimlsp",
      --         "coc-sh",
      --         "coc-sql",
      --         "coc-xml",
      --         "coc-fzf-preview",
      --         "coc-syntax",
      --         "coc-git",
      --         "coc-go",
      --         "coc-clangd",
      --         "coc-rls",
      --         "coc-rust-analyzer",
      --         "coc-toml",
      --         "coc-solargraph",
      --         "coc-prettier",
      --         "coc-r-lsp",
      --         "coc-perl",
      --         "coc-tsserver",
      --         "coc-zig",
      --         "coc-dlang",
      --         "coc-lua",
      --       }
      --
      --       -- 'coc-pairs',
      --       -- 'coc-sumneko-lua',
      --       -- 'coc-clojure',
      --       -- 'coc-nginx',
      --       -- 'coc-toml',
      --       -- 'coc-explorer'
      --
      --       g.coc_enable_locationlist = 0
      --       g.coc_selectmode_mapping = 0
      --
      --       cmd [[
      --         au User CocNvimInit ++once lua require('plugs.coc').init()
      --
      --         hi! link CocSemDefaultLibrary Special
      --         hi! link CocSemDocumentation Number
      --         hi! CocSemStatic gui=bold
      --      ]]
      --
      --       cmd("packadd coc.nvim")
      --     end, 300
      -- )

      -- vim.defer_fn(function() require("plugs.fold") end, 800)
    end
)
-- ]]] === Defer Loading ===
