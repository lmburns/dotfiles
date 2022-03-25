local utils = require("common.utils")
local opt = utils.opt
local map = utils.map

-- Leader/local leader
vim.g.mapleader = " "
vim.g.maplocalleader = [[,]]

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
  "gzip",
  "man",
  "matchit",
  "matchparen",
  "shada_plugin",
  "tarPlugin",
  "tar",
  "zipPlugin",
  "zip",
  "netrwPlugin",
}

for i = 1, 10 do
  g["loaded_" .. disabled_built_ins[i]] = 1
end

-- Settings
opt("termguicolors", true)
opt("background", "dark")
opt("number", true)
opt("cursorline", true)
o.clipboard:append("unnamedplus")

opt("magic", true)
opt("tabstop", 2)
opt("shiftwidth", 0)
opt("expandtab", true)
opt("softtabstop", 2)

opt("smartcase", true)
opt("ignorecase", true)
opt("startofline", false)
opt("synmaxcol", 1000) -- do not highlight long lines

opt("foldenable", false)
opt("foldmethod", "marker")
opt("foldmarker", "[[[,]]]")

opt("scrolloff", 5) -- cursor 5 lines from bottom of page
opt("sidescrolloff", 15)

opt("title", true)
opt("list", true) -- display tabs and trailing spaces visually
o.listchars:append(
    { tab = "‣ ", trail = "•", precedes = "«", extends = "»",
      nbsp = "␣" }
)
opt("incsearch", true) -- incremential search highligh
opt("pumheight", 10) -- number of items in popup menu

opt("mouse", "a") -- enable mouse all modes
opt("linebreak", true)
opt("history", 1000)

opt("wrap", true)
o.whichwrap:append("<,>,h,l")
opt("lazyredraw", true)
opt("cmdheight", 2)
opt("showmatch", true)
opt("matchtime", 2)

o.wildoptions:append("pum")
opt("wildignore", { "*.o", "*~", "*.pyc", "*.git", "node_modules" })
opt("wildmenu", true)
opt("wildmode", "full")

opt("smartindent", true)
-- opt("cindent", true)

opt("autoread", true)
opt("swapfile", false) -- no swap files
opt("undofile", true)
opt("undodir", fn.stdpath("data") .. "/vim-persisted-undo/")
fn.mkdir(vim.o.undodir, "p")

opt("belloff", "all")
opt("visualbell", false)
opt("errorbells", false)
opt("confirm", true) -- confirm when editing readonly
opt("diffopt", "vertical")
opt("inccommand", "nosplit")
opt("splitbelow", true)
opt("splitright", true)

opt("concealcursor", "vic")
opt("conceallevel", 2)
o.fillchars:append("msgsep: ,vert:│") -- customize message separator
opt("updatetime", 100)
opt("timeoutlen", 350)
opt("showmode", false) -- hide file, it's in lightline
opt("showcmd", false)
opt("signcolumn", "yes")
opt("hidden", true)
opt("backup", false)
o.writebackup = false
o.shortmess:append("c") -- don't give 'ins-completion-menu' messages.

-- ============== Spell Check ============== [[[
o.completeopt:append({"menuone", "preview"})
o.complete:append({"kspell"})
o.complete:remove({"w", "b", "u", "t"})
o.spelllang = "en_us"
o.spellsuggest = "10"
o.spellfile = fn.stdpath("config") .. "/spell/en.utf-8.add"
-- ]]] === Spell Check ===
