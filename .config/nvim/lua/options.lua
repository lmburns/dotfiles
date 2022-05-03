local utils = require("common.utils")
local opt = utils.opt
local map = utils.map
local list = require("dev").list

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

-- map({ "n", "x" }, "<SubLeader>", "<Nop>", { noremap = true, silent = true })
-- map({ "n", "x" }, ";", "<SubLeader>", { noremap = false })

-- Lua filetype detection
-- g.do_filetype_lua = 1
-- g.did_load_filetypes = 1
-- vim.filetype.add({
--     extension = {},
--     filename = {}
-- })

-- vim.g.loaded_getscriptPlugin = 1
-- vim.g.loaded_matchparen = 1
vim.tbl_map(
    function(p)
        g["loaded_" .. p] = vim.endswith(p, "provider") and 0 or 1
    end,
    {
        "2html_plugin",
        "gzip",
        "logiPat", -- boolean logical pattern matcher
        "matchit",
        "netrw",
        "netrwPlugin",
        "netrwFileHandlers",
        "netrwSettings",
        -- "python_provider",
        -- "ruby_provider",
        -- "perl_provider",
        "rrhelper",
        "tar",
        "tarPlugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin"
    }
)

-- We do this to prevent the loading of the system fzf.vim plugin. This is
-- present at least on Arch/Manjaro/Void
o.rtp:remove("/usr/share/vim/vimfiles")

-- Base
vim.env.LANG = "en_US.UTF-8"

-- set_option_value / set_option

o.encoding = "utf-8"
o.fileencoding = "utf-8" -- utf-8 files
o.fileformat = "unix" -- use unix line endings
o.fileformats = list {"unix", "mac", "dos"}

-- Settings
o.path:append("**")
o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = list {"number", "screenline"}
o.clipboard:append("unnamedplus")

o.magic = true
o.tabstop = 2
o.shiftwidth = 0
o.expandtab = true
o.softtabstop = 2

o.ignorecase = true
o.smartcase = true
o.startofline = false
o.backspace = list {"indent", "eol", "start"}
o.synmaxcol = 1000 -- do not highlight long lines

o.foldenable = false
-- o.foldmethod = "marker"
-- o.foldmarker = "[[[,]]]"

-- o.foldmethod = "expr"
-- o.foldexpr = "nvim_treesitter#foldexpr()"

o.foldlevelstart = 99
-- o.foldnestmax = 10 -- deepest fold is 10 levels
-- o.foldenable = false -- don't fold by default
-- o.foldlevel = 1

-- This does not work globally for whatever reason (didn't in vim either)
o.formatoptions:remove({"c", "r", "o"})
o.nrformats = list {"octal", "hex", "bin", "unsigned"}
o.scrolloff = 5 -- cursor 5 lines from bottom of page
o.sidescrolloff = 15

o.title = true
o.titlestring = '%(%m%)%(%{expand("%:~")}%)'
o.list = true -- display tabs and trailing spaces visually
o.listchars:append(
    {
        tab = "‣ ",
        trail = "•",
        precedes = "«",
        extends = "»",
        nbsp = "␣"
    }
)
o.showbreak = [[↪ ]] -- "⏎"
o.showtabline = 2
o.incsearch = true -- incremental search highlight
o.pumheight = 10 -- number of items in popup menu

o.mouse = "a" -- enable mouse all modes
o.linebreak = true
o.history = 10000

o.joinspaces = false -- prevent inserting two spaces with J
o.whichwrap:append("<,>,h,l,[,]")
o.wrap = true
o.lazyredraw = true
o.cmdheight = 2
o.matchtime = 2
-- o.autoread = true

o.wildoptions:append("pum")
o.wildignore = {"*.o", "*~", "*.pyc", "*.git", "node_modules"}
o.wildmenu = true
o.wildmode = "full"
o.wildignorecase = true -- ignore case when completing file names and directories
o.wildcharm = 26 -- equals set wildcharm=<C-Z>, used in the mapping section

o.smartindent = true
o.cindent = true
o.sessionoptions = {"buffers", "curdir", "tabpages", "winsize"}

o.jumpoptions = 'stack'
o.swapfile = false -- no swap files
o.undolevels = 1000
o.undoreload = 10000
o.undofile = true
o.undodir = fn.stdpath("data") .. "/vim-persisted-undo/"
fn.mkdir(vim.o.undodir, "p")
o.shada =
    list {
    "!", -- save and restore global variables starting with uppercase
    "'1000", -- previously edited files
    "<50", -- lines saved in each register
    "s100", -- maximum size of an item in KiB
    "/5000", -- search pattern history
    "@1000", -- input line history
    ":5000", -- command line history
    "h" -- disable `hlsearch` on loading
}
o.shadafile = fn.stdpath("data") .. "/shada/main.shada"

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

o.grepprg = "rg -H --no-heading --max-columns=200 --vimgrep --smart-case --color=never"
o.grepformat = "%f:%l:%c:%m,%f:%l:%m"

o.background = "dark"
o.cedit = "<C-x>"

-- ================== Gui ================== [[[
o.termguicolors = true
-- o.guioptions:remove({ "m", "r", "l" })
g.guitablabel = "%M %t"
o.guicursor =
    "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50" ..
    ",a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor" .. ",sm:block-blinkwait175-blinkoff150-blinkon175"
o.guifont = [[FiraMono Nerd Font Mono:style=Medium:h12]]

if fn.exists("g:neovide") then
    map("n", "<C-p>", '"+p')
    map("i", "<C-p>", "<C-r>+")
end

g.neovide_input_use_logo = true
g.neovide_transparency = 0.9
g.neovide_cursor_vfx_particle_lifetime = 2.0
g.neovide_cursor_vfx_particle_density = 12.0
g.neovide_cursor_vfx_mode = "torpedo"
-- ]]] === Gui ===

-- ============== Spell Check ============== [[[
o.completeopt:append({"menuone", "preview"})
o.complete:append({"kspell"})
o.complete:remove({"w", "b", "u", "t"})
o.spelllang = "en_us"
-- o.spellsuggest = "10"
o.spellfile = fn.stdpath("config") .. "/spell/en.utf-8.add"
-- ]]] === Spell Check ===

-- =============== Clipboard =============== [[[
local clipboard
if env.DISPLAY and fn.executable("xsel") == 1 then
    clipboard = {
        name = "xsel",
        copy = {
            ["+"] = {"xsel", "--nodetach", "-i", "-b"},
            ["*"] = {"xsel", "--nodetach", "-i", "-p"}
        },
        paste = {["+"] = {"xsel", "-o", "-b"}, ["*"] = {"xsel", "-o", "-p"}},
        cache_enabled = true
    }
elseif env.TMUX then
    clipboard = {
        name = "tmux",
        copy = {["+"] = {"tmux", "load-buffer", "-w", "-"}},
        paste = {["+"] = {"tmux", "save-buffer", "-"}},
        cache_enabled = true
    }
    clipboard.copy["*"] = clipboard.copy["+"]
    clipboard.paste["*"] = clipboard.paste["+"]
end

g.clipboard = clipboard
-- ]]] === Clipboard ===

-- =============== Commands ================ [[[
-- filetype on
-- filetype plugin on
-- filetype plugin indent on
-- cmd [[
--   syntax enable
-- ]]
-- ]]] === Commands ===
