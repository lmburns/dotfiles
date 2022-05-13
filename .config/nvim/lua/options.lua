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
        "ftplugin",
        "2html_plugin",
        "gzip",
        "logiPat", -- boolean logical pattern matcher
        "matchit",
        "netrw",
        "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
        "rrhelper",
        "tar",
        "tarPlugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        -- "python_provider",
        "ruby_provider",
        "perl_provider",
        "node_provider"
    }
)

-- We do this to prevent the loading of the system fzf.vim plugin. This is
-- present at least on Arch/Manjaro/Void
o.rtp:remove("/usr/share/vim/vimfiles")

-- Base
env.LANG = "en_US.UTF-8"
o.shell = os.getenv("SHELL")

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

o.ignorecase = true
o.smartcase = true
o.wrapscan = true -- Searches wrap around the end of the file
o.startofline = false
o.scrolloff = 5 -- cursor 5 lines from bottom of page
o.sidescrolloff = 15

o.foldenable = false
-- o.foldmethod = "marker"
-- o.foldmarker = "[[[,]]]"

-- o.foldmethod = "expr"
-- o.foldexpr = "nvim_treesitter#foldexpr()"

o.foldopen = o.foldopen:append("search")
o.foldlevelstart = 99
-- o.foldnestmax = 10 -- deepest fold is 10 levels
-- o.foldenable = false -- don't fold by default
-- o.foldlevel = 1

-- This does not work globally for whatever reason (didn't in vim either)
-- o.formatoptions:remove({"c", "r", "o"})

o.formatoptions = {
    ["1"] = true,
    ["2"] = true, -- Use indent from 2nd line of a paragraph
    q = true, -- Continue comments with gq"
    n = true, -- Recognize numbered lists
    j = true, -- Remove a comment leader when joining lines.
    -- Only break if the line was not longer than 'textwidth' when the insert
    -- started and only at a white character that has been entered during the
    -- current insert command.
    l = true,
    v = true, -- Only break line at blank line I've entered
    c = true, -- Auto-wrap comments using textwidth
    r = false, -- Continue comments when pressing Enter
    t = false, -- Autowrap lines using text width value
    o = false --- Automatically insert comment leader after <enter>
}

o.nrformats = list {"octal", "hex", "bin", "unsigned"}

o.title = true
o.titlestring = '%(%m%)%(%{expand("%:~")}%)'
o.titlelen = 70
o.titleold = fn.fnamemodify(os.getenv("SHELL"), ":t")

o.list = true -- display tabs and trailing spaces visually
o.listchars:append(
    {
        eol = nil,
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

o.mouse = "a" -- enable mouse all modes
o.mousefocus = true

o.backspace = list {"indent", "eol", "start"}
o.breakindentopt = "sbr"
o.smartindent = true
o.cindent = true
o.linebreak = true -- lines wrap at words rather than random characters
-- o.autoindent = true

o.magic = true
o.joinspaces = false -- prevent inserting two spaces with J
o.lazyredraw = true
o.ruler = false
o.cmdheight = 2
o.matchtime = 2
-- o.autoread = true
o.autowriteall = true -- automatically :write before running commands and changing files

o.whichwrap:append("<,>,h,l,[,]")
o.wrap = true
o.wrapmargin = 2

o.tabstop = 2
o.shiftwidth = 0
o.expandtab = true
o.softtabstop = 2
-- o.textwidth = 80
-- o.shiftround = true

o.wildoptions:append("pum")
o.wildignore = {"*.o", "*~", "*.pyc", "*.git", "node_modules"}
o.wildmenu = true
o.wildmode = "longest:full,full" -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true -- ignore case when completing file names and directories
o.wildcharm = fn.char2nr(utils.t("<Tab>")) -- tab

o.pumheight = 10 -- number of items in popup menu
o.pumblend = 3 -- Make popup window translucent

-- o.secure = true -- Disable autocmd etc for project local vimrc files.
-- o.exrc = true -- Allow project local vimrc files example .nvimrc see :h exrc

o.sessionoptions = {"globals", "buffers", "curdir", "tabpages", "winsize", "winpos", "help"}
o.viewoptions = { 'cursor', 'folds' } -- save/restore just these (with `:{mk,load}view`)
o.virtualedit = 'block' -- allow cursor to move where there is no text in visual block mode
o.jumpoptions = "stack"

o.history = 10000
o.backup = false
o.writebackup = false
o.swapfile = false -- no swap files
o.undofile = true
o.undolevels = 1000
o.undoreload = 10000
o.undodir = fn.stdpath("data") .. "/vim-persisted-undo/"
if not uv.fs_stat(vim.o.undodir) then
    fn.mkdir(vim.o.undodir, "p")
end

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

-- o.diffopt:append(",vertical,internal,algorithm:patience")
o.diffopt =
    o.diffopt +
    {
        "vertical",
        "iwhite",
        "hiddenoff",
        "foldcolumn:0",
        "context:4",
        "algorithm:histogram",
        "indent-heuristic"
    }

o.inccommand = "split" -- nosplit
o.splitright = true
o.splitbelow = true
o.eadirection = "hor" -- when equalsalways option applies
-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
o.switchbuf = "useopen,uselast"

o.conceallevel = 2
o.concealcursor = "vic" -- "-=n"
o.fillchars = {
    fold = " ",
    eob = " ", -- suppress ~ at EndOfBuffer
    diff = "╱", -- alternatives = ⣿ ░ ─
    msgsep = " ", -- alternatives: ‾ ─
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
    vert = "│"
}

-- g.cursorhold_updatetime = 1000
o.updatetime = 200
o.timeoutlen = 375
o.ttimeoutlen = 10
o.showmatch = true
o.showmode = false -- hide file, it's in lightline
o.showcmd = false
o.signcolumn = "yes:1"
o.synmaxcol = 1000 -- do not highlight long lines
o.hidden = true -- enable modified buffers in background
o.shortmess:append("acsIS") -- don't give 'ins-completion-menu' messages.

o.grepprg = "rg -H --no-heading --max-columns=200 --vimgrep --smart-case --color=never --glob '!.git'"
-- o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
o.grepformat = o.grepformat:prepend({"%f:%l:%c:%m"})

o.background = "dark"
o.cedit = "<C-x>"

-- ================== Gui ================== [[[
o.termguicolors = true
-- o.guioptions:remove({ "m", "r", "l" })
g.guitablabel = "%M %t"
o.guicursor = {
    [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]],
    [[a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]],
    [[sm:block-blinkwait175-blinkoff150-blinkon175]]
}
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
o.spelllang:append({'programming', "en_us"})
o.spelloptions = 'camel'
o.spellcapcheck = '' -- don't check for capital letters at start of sentence
o.spellsuggest = "12"
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

-- if nvim.executable('nvr') then
--   env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
--   env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- end
