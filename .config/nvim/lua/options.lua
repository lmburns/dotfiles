local utils = require("common.utils")
local opt = utils.opt
local map = utils.map

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

vim.tbl_map(
    function(p)
      vim.g["loaded_" .. p] = vim.endswith(p, "provider") and 0 or 1
    end, {
      "2html_plugin",
      "gzip",
      "matchit",
      "netrw",
      "netrwPlugin",
      "python_provider",
      "ruby_provider",
      "perl_provider",
      "shada_plugin",
      "tar",
      "tarPlugin",
      "vimball",
      "vimballPlugin",
      "zip",
      "zipPlugin",
    }
)

-- Settings
o.path:append("**")
o.number = true
o.cursorline = true
o.clipboard:append("unnamedplus")

o.magic = true
o.tabstop = 2
o.shiftwidth = 0
o.expandtab = true
o.softtabstop = 2

o.smartcase = true
o.ignorecase = true
o.startofline = false
o.backspace = [[indent,eol,start]]
o.synmaxcol = 1000 -- do not highlight long lines

o.foldenable = false
o.foldmethod = "marker"
o.foldmarker = "[[[,]]]"
o.formatoptions:remove({ "c", "r", "o"})

o.scrolloff = 5 -- cursor 5 lines from bottom of page
o.sidescrolloff = 15

o.title = true
o.list = true -- display tabs and trailing spaces visually
o.listchars:append(
    { tab = "‣ ", trail = "•", precedes = "«", extends = "»",
      nbsp = "␣" }
)
o.incsearch = true -- incremential search highlight
o.pumheight = 10 -- number of items in popup menu

o.mouse = "a" -- enable mouse all modes
o.linebreak = true
-- o.history = 1000

o.joinspaces = false -- prevent inserting two spaces with J
o.whichwrap:append("<,>,h,l,[,]")
o.wrap = true
o.lazyredraw = true
o.cmdheight = 2
o.matchtime = 2

o.wildoptions:append("pum")
o.wildignore = { "*.o", "*~", "*.pyc", "*.git", "node_modules" }
o.wildmenu = true
o.wildmode = "full"
o.wildignorecase = true -- ignore case when completing file names and directories
o.wildcharm = 26 -- equals set wildcharm=<C-Z>, used in the mapping section

o.smartindent = true
-- o.cindent = true

o.swapfile = false -- no swap files
o.undolevels = 1000
o.undoreload = 10000
o.undofile = true
o.undodir = fn.stdpath("data") .. "/vim-persisted-undo/"
fn.mkdir(vim.o.undodir, "p")
-- o.shada = "!,'1000,<50,s10,h" -- increase the shadafile size so that history is longer

o.belloff = "all"
o.visualbell = false
o.errorbells = false
o.confirm = true -- confirm when editing readonly
o.diffopt = "vertical"
o.inccommand = "nosplit"
o.splitbelow = true
o.splitright = true

o.concealcursor = "n" -- "vic"
o.conceallevel = 2
o.fillchars:append("msgsep: ,vert:│") -- customize message separator
-- g.cursorhold_updatetime = 1000
o.updatetime = 100
o.timeoutlen = 350
o.showmatch = true
o.showmode = false -- hide file, it's in lightline
o.showcmd = false
o.signcolumn = "yes"
o.hidden = true -- enable modified buffers in background
o.backup = false
o.writebackup = false
o.shortmess:append("c") -- don't give 'ins-completion-menu' messages.

opt("grepprg", "rg --ignore-case --vimgrep --color=never")
opt("grepformat", "%f:%l:%c:%m,%f:%l:%m")

o.background = "dark"

-- ================== Gui ================== [[[
o.termguicolors = true
-- o.guioptions:remove({ "m", "r", "l" })
g.guitablabel = "%M %t"
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50" ..
                  ",a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor" ..
                  ",sm:block-blinkwait175-blinkoff150-blinkon175"
-- ]]] === Gui ===

-- ============== Spell Check ============== [[[
o.completeopt:append({ "menuone", "preview" })
o.complete:append({ "kspell" })
o.complete:remove({ "w", "b", "u", "t" })
o.spelllang = "en_us"
o.spellsuggest = "10"
o.spellfile = fn.stdpath("config") .. "/spell/en.utf-8.add"
-- ]]] === Spell Check ===

-- ============= Abbreviations ============= [[[
cmd [[
    :cabbrev C PackerCompile
    :cabbrev U PackerUpdate
    :cabbrev S PackerSync

    :cnoreabbrev W! w!
    :cnoreabbrev Q! q!
    :cnoreabbrev Qall! qall!
    :cnoreabbrev Wq wq
    :cnoreabbrev Wa wa
    :cnoreabbrev wQ wq
    :cnoreabbrev WQ wq
    :cnoreabbrev W w
    :cnoreabbrev Qall qall
]]
-- ]]] === Abbreviations ===

-- =============== Commands ================ [[[
cmd(
    [[
      filetype on
      filetype plugin on
      filetype plugin indent on

      syntax on
      syntax enable
    ]]
)
-- ]]] === Commands ===
