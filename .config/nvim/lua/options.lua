local utils = require("common.utils")
local opt = utils.opt
local map = utils.map

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

cmd [[set nocompatible]]

map({ "n", "x" }, "<SubLeader>", "<Nop>", { noremap = true, silent = true })
map({ "n", "x" }, ";", "<SubLeader>", { noremap = false })

-- vim.g.loaded_logiPat = 1
-- vim.g.loaded_getscriptPlugin = 1
-- vim.g.loaded_matchparen = 1
-- vim.g.loaded_netrwFileHandlers = 1
-- vim.g.loaded_rrhelper = 1
-- vim.g.loaded_spellfile_plugin = 1
-- vim.g.loaded_zipPlugin = 1

-- Lua filetype detection
g.do_filetype_lua = 1

-- Runs `filetype.lua` and uses builtin filetype detection
-- I have noticed that treesitter syntax highlighting is delayed when this is used
g.did_load_filetypes = 1

vim.filetype.add(
    {
      extension = {
        eslintrc = "json",
        prettierrc = "json",
        conf = "conf",
        mdx = "markdown",
        mjml = "html",
        sxhkdrc = "sxhkdrc",
      },
      pattern = { [".*%.env.*"] = "sh", [".*ignore"] = "conf" },
      filename = { ["yup.lock"] = "yaml", [".editorconfig"] = "dosini" },
    }
)

vim.tbl_map(
    function(p)
      vim.g["loaded_" .. p] = vim.endswith(p, "provider") and 0 or 1
    end, {
      "2html_plugin",
      "gzip",
      "matchit",
      "netrw",
      "netrwPlugin",
      "netrwSettings",
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

g.c_syntax_for_h = 1

-- Base
vim.env.LANG = "en_US.UTF-8"

o.encoding = "utf-8"
o.fileencoding = "utf-8" -- utf-8 files
o.fileformat = "unix" -- use unix line endings
o.fileformats = "unix,dos,mac" -- try unix line endings before dos, use unix

-- Settings
o.path:append("**")
o.number = true
o.cursorline = true
o.cursorlineopt = "number,screenline"
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

-- cmd [[set foldmethod=expr]] -- use treesitter folding support
-- cmd [[set foldexpr=nvim_treesitter#foldexpr()]]
-- opt.foldlevelstart = 99
-- opt.foldnestmax = 10 -- deepest fold is 10 levels
-- opt.foldenable = false -- don't fold by default
-- opt.foldlevel = 1

-- This does not work globally for whatever reason (didn't in vim either)
o.formatoptions:remove({ "c", "r", "o" })
o.nrformats = "octal,hex,bin,unsigned"
o.scrolloff = 5 -- cursor 5 lines from bottom of page
o.sidescrolloff = 15

o.title = true
o.titlestring = "%(%m%)%(%{expand(\"%:~\")}%)"
o.list = true -- display tabs and trailing spaces visually
o.listchars:append(
    { tab = "‣ ", trail = "•", precedes = "«", extends = "»",
      nbsp = "␣" }
)
o.showbreak = [[↪ ]] -- "⏎"
o.showtabline = 2
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
o.shada = "!,'1000,<50,s10,h" -- increase the shadafile size so that history is longer

o.belloff = "all"
o.visualbell = false
o.errorbells = false
o.confirm = true -- confirm when editing readonly
o.diffopt:append(",vertical,internal,algorithm:patience")
o.inccommand = "nosplit"
o.splitbelow = true
o.splitright = true

o.concealcursor = "vic" -- "-=n"
o.conceallevel = 0
o.fillchars:append("msgsep: ,vert:│") -- customize message separator
-- g.cursorhold_updatetime = 1000
o.updatetime = 100
o.timeoutlen = 350
o.showmatch = true
o.showmode = false -- hide file, it's in lightline
o.showcmd = false
o.signcolumn = "yes:1"
o.hidden = true -- enable modified buffers in background
o.backup = false
o.writebackup = false
o.shortmess:append("acsIS") -- don't give 'ins-completion-menu' messages.

opt("grepprg", "rg --ignore-case --vimgrep --color=never")
opt("grepformat", "%f:%l:%c:%m,%f:%l:%m")

o.background = "dark"
o.cedit = "<C-x>"

-- ================== Gui ================== [[[
o.termguicolors = true
-- o.guioptions:remove({ "m", "r", "l" })
g.guitablabel = "%M %t"
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50" ..
                  ",a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor" ..
                  ",sm:block-blinkwait175-blinkoff150-blinkon175"
o.guifont = [[FiraMono Nerd Font Mono:style=Medium:h12]]

if fn.exists("g:neovide") then
  map("n", "<D-v>", "\"+p")
  map("i", "<D-v>", "<C-r>+")
end

g.neovide_input_use_logo = true
g.neovide_transparency = 0.9
g.neovide_cursor_vfx_particle_lifetime = 2.0
g.neovide_cursor_vfx_particle_density = 12.0
g.neovide_cursor_vfx_mode = "torpedo"
-- ]]] === Gui ===

-- ============== Spell Check ============== [[[
o.completeopt:append({ "menuone", "preview" })
o.complete:append({ "kspell" })
o.complete:remove({ "w", "b", "u", "t" })
o.spelllang = "en_us"
o.spellsuggest = "10"
o.spellfile = fn.stdpath("config") .. "/spell/en.utf-8.add"
-- ]]] === Spell Check ===

-- =============== Clipboard =============== [[[
local clipboard
if env.DISPLAY and fn.executable("xsel") == 1 then
  clipboard = {
    name = "xsel",
    copy = {
      ["+"] = { "xsel", "--nodetach", "-i", "-b" },
      ["*"] = { "xsel", "--nodetach", "-i", "-p" },
    },
    paste = { ["+"] = { "xsel", "-o", "-b" }, ["*"] = { "xsel", "-o", "-p" } },
    cache_enabled = true,
  }
elseif env.TMUX then
  clipboard = {
    name = "tmux",
    copy = { ["+"] = { "tmux", "load-buffer", "-w", "-" } },
    paste = { ["+"] = { "tmux", "save-buffer", "-" } },
    cache_enabled = true,
  }
  clipboard.copy["*"] = clipboard.copy["+"]
  clipboard.paste["*"] = clipboard.paste["+"]
end

g.clipboard = clipboard
-- ]]] === Clipboard ===

-- ============= Abbreviations ============= [[[
cmd [[
    cnoreabbrev W! w!
    cnoreabbrev Q! q!
    cnoreabbrev Qall! qall!
    cnoreabbrev Wq wq
    cnoreabbrev Wa wa
    cnoreabbrev wQ wq
    cnoreabbrev WQ wq
    cnoreabbrev W w
    cnoreabbrev Qall qall
]]

cmd [[cabbrev tel <C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Telescope' : 'tel')<CR>]]

-- ]]] === Abbreviations ===

-- =============== Commands ================ [[[
-- filetype on
-- filetype plugin on
cmd(
    [[
      filetype plugin indent on
      syntax enable
    ]]
)
-- ]]] === Commands ===
