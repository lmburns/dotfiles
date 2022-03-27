local M = {}

local utils = require("common.utils")
local map = utils.map

-- Prettier command for coc
cmd [[command! -nargs=0 CocMarket :CocFzfList marketplace]]
cmd [[command! -nargs=0 Prettier :CocCommand prettier.formatFile]]

g.coc_fzf_opts = { "--no-border", "--layout=reverse-list" }
g.coc_global_extensions = {
  "coc-snippets",
  "coc-diagnostic",
  "coc-pairs",
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

-- 'coc-sumneko-lua',
-- 'coc-clojure',
-- 'coc-nginx',
-- 'coc-toml',
-- 'coc-explorer'

g.coc_explorer_global_presets = {
  config = { ["root-uri"] = "~/.config" },
  projects = { ["root-uri"] = "~/projects" },
  github = { ["root-uri"] = "~/projects/github" },
  opt = { ["root-uri"] = "~/opt" },
}

function M.show_documentation()
  local ft = vim.bo.ft
  if ft == "help" then
    cmd(("sil! h %s"):format(fn.expand("<cword>")))
  else
    local err, res = M.a2sync("definitionHover")
    if err then
      if res == "timeout" then
        vim.notify("Show documentation Timeout", vim.log.levels.WARN)
      end
      cmd("norm! K")
    end
  end
end

-- map("n", "<A-c>", ":CocFzfList commands<CR>")
map("n", "<A-'>", ":CocFzfList yank<CR>", { silent = true })
map("n", "<C-x><C-l>", ":CocFzfList<CR>")
-- map("n", "<C-x><C-r>", ":CocCommand fzf-preview.CocReferences<CR>")
map("n", "<C-x><C-d>", ":CocCommand fzf-preview.CocTypeDefinition<CR>")
map("n", "<C-x><C-]>", ":CocCommand fzf-preview.CocImplementations<CR>")
map("n", "<C-x><C-h>", ":CocCommand fzf-preview.CocImplementations<CR>")

-- TODO: Use more!
-- Remap for do codeAction of current line
map("n", "<Leader>wc", "<Plug>(coc-codeaction)")
map("x", "<Leader>w", "<Plug>(coc-codeaction-selected)")
map("n", "<Leader>ww", "<Plug>(coc-codeaction-selected)")

-- map("n", "<C-x><C-r>", ":Telescope coc references<CR>")
-- map("n", "<C-x><C-[>", ":Telescope coc definitions<CR>")
-- map("n", "<C-x><C-]>", ":Telescope coc implementations<CR>")
-- map("n", "<C-x><C-r>", ":Telescope coc diagnostics<CR>")

-- Use `[g` and `]g` to navigate diagnostics
map("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
map("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})
map("n", "<Leader>?", ":call CocAction('diagnosticInfo')<CR>", {silent = true})

-- map("n", ")g", ":call CocAction('diagnosticNext')<CR>", { silent = true })
-- map("n", "(g", ":call CocAction('diagnosticPrevious')<CR>", { silent = true })

-- Goto code navigation
map("n", "gd", "<Plug>(coc-definition)", {silent = true})
map("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
map("n", "gi", "<Plug>(coc-implementation)", {silent = true})
map("n", "gr", "<Plug>(coc-references)", {silent = true})

-- Remap for rename current word
map("n", "<Leader>rn", "<Plug>(coc-rename)")

map("x", "<Leader>fm", "<Plug>(coc-format-selected)")
map("n", "<Leader>fm", "<Plug>(coc-format-selected)")

-- Fix autofix problem of current line
map("n", "<Leader>qf", "<Plug>(coc-fix-current)")

-- Create mappings for function text object
map("x", "if", "<Plug>(coc-funcobj-i)")
map("x", "af", "<Plug>(coc-funcobj-a)")
map("o", "if", "<Plug>(coc-funcobj-i)")
map("o", "af", "<Plug>(coc-funcobj-a)")

-- map("n", "{g", "<Plug>(coc-git-prevchunk)")
-- map("n", "}g", "<Plug>(coc-git-nextchunk)")

-- Navigate conflicts of current buffer
map("n", "[c", "<Plug>(coc-git-prevconflict)")
map("n", "]c", "<Plug>(coc-git-nextconflict)")

-- Show chunk diff at current position
map("n", "gs", "<Plug>(coc-git-chunkinfo)")
-- Show commit contains current position
map("n", "gC", "<Plug>(coc-git-commit)")

return M
