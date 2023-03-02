local M = {}

local D = require("dev")
local utils = require("common.utils")
local map = utils.map
local list = require("dev").list
local dirs = require("common.global").dirs

local env = vim.env
local o = vim.opt
local g = vim.g
local fn = vim.fn
local fs = vim.fs
local uv = vim.loop

---Notify with nvim-notify if nvim is focused,
---Otherwise send a desktop notification.
g.nvim_focused = true
g.treesitter_refactor_maxlines = 10 * 1024
g.treesitter_highlight_maxlines = 12 * 1024

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

vim.tbl_map(
    function(p)
        g["loaded_" .. p] = vim.endswith(p, "provider") and 0 or 1
    end,
    {
        "2html_plugin",
        -- "ftplugin",
        "getscript",
        "getscriptPlugin",
        -- "gzip",
        "logiPat", -- boolean logical pattern matcher
        -- "man",
        "matchit",
        "matchparen",
        "netrw",
        "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
        "node_provider",
        -- "remote_plugins", -- required for wilder.nvim
        -- "rplugin", -- involved with remote_plugins
        "rrhelper",
        "spec",
        "tar",
        "tarPlugin",
        "tutor_mode_plugin",
        "vimball",
        "vimballPlugin",
        -- "zip",
        -- "zipPlugin",
        "perl_provider",
        "python_provider",
        "ruby_provider"
        -- "python3_provider",
    }
)

-- g.loaded_fzf = 1
-- g.loaded_gtags = 1
-- g.loaded_gtags_cscope = 1
-- g.load_black = 1

if #fn.glob("$XDG_DATA_HOME/pyenv/shims/python3") ~= 0 then
    g.python3_host_prog = fn.glob("$XDG_DATA_HOME/pyenv/shims/python")
end

g.c_syntax_for_h = 1
g.c_comment_strings = 1
g.c_no_if0 = 0

g.no_man_maps = 1

-- Do this to prevent the loading of the system fzf.vim plugin. This is
-- present at least on Arch/Manjaro/Void
o.rtp:remove("/usr/share/vim/vimfiles")
o.rtp:remove("/etc/xdg/nvim/after")
o.rtp:remove("/etc/xdg/nvim")

-- Base
env.LANG = "en_US.UTF-8"
o.shell = env.SHELL
o.encoding = "utf-8"
o.fileencoding = "utf-8" -- utf-8 files
o.fileformat = "unix" -- use unix line endings
o.fileformats = {"unix", "mac", "dos"}

-- Settings
-- o.path:append("**")
o.number = true
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = {"number", "screenline"}

o.infercase = true -- change case inference with completions
o.ignorecase = true
o.smartcase = true
o.wrapscan = true -- searches wrap around the end of the file
o.startofline = false
o.scrolloff = 5 -- cursor 5 lines from bottom of page
o.sidescrolloff = 15

o.indentexpr = "nvim_treesitter#indent()"

-- o.foldmethod = "marker"
-- o.foldmarker = "[[[,]]]"
-- o.foldmethod = "expr"
-- o.foldexpr = "nvim_treesitter#foldexpr()"

o.foldenable = true
o.foldopen = o.foldopen:append("search")
o.foldlevelstart = 99
o.foldcolumn = "1"
-- o.foldlevel = 1

o.formatoptions = {
    ["1"] = true, -- Don't break a line after a one-letter word; break before
    ["2"] = true, -- Use indent from 2nd line of a paragraph
    q = true, -- Format comments with gq"
    n = true, -- Recognize numbered lists. Indent past formatlistpat not under
    M = true, -- When joining lines, don't insert a space before or after a multibyte char
    j = true, -- Remove a comment leader when joining lines.
    -- Only break if the line was not longer than 'textwidth' when the insert
    -- started and only at a white character that has been entered during the
    -- current insert command.
    l = true,
    v = true, -- Only break line at blank line I've entered
    r = false, -- Continue comments when pressing Enter
    c = true, -- Auto-wrap comments using textwidth
    t = false, -- Autowrap lines using text width value
    p = true, -- Don't break lines at single spaces that follow periods
    o = false, --- Automatically insert comment leader after <enter>
    ["/"] = true -- When 'o' included: don't insert comment leader for // comment after statement
}

-- A pattern that is used to recognize a list header. This is used for the "n"
-- flag in 'formatoptions'.
--                        ┌ recognize numbered lists (default)
--                        ├─────────────┐
o.formatlistpat = [[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\)\s*]]
--                                          ├───┘
--                                          └ recognize unordered lists

o.nrformats = {"octal", "hex", "bin", "unsigned"}

o.title = true
o.titlestring = '%(%m%)%(%{expand("%:~")}%)'
o.titlelen = 70
o.titleold = fs.basename(os.getenv("SHELL")) -- This doesn't seem to work
-- o.titleold = ("%s %s"):format(fn.fnamemodify(os.getenv("SHELL"), ":t"), global.name)

o.list = true -- display tabs and trailing spaces visually
-- Tab hides actual text when used with indent blankline
o.listchars:append(
    {
        eol = nil,
        tab = "‣ ",
        trail = "•",
        precedes = "«",
        extends = "…", -- »
        nbsp = "␣"
    }
)
o.showbreak = [[↳ ]] -- ↪  ⌐

-- o.cpoptions = 'aAceFs_B'
-- o.cpoptions:append("n") -- cursorcolumn used for wraptext
o.cpoptions:append("_") -- do not include whitespace with 'cw'
o.cpoptions:append("a") -- ":read" sets alternate file name
o.cpoptions:append("A") -- ":write" sets alternate file name
o.showtabline = 2
o.incsearch = true -- incremental search highlight

o.mouse = "a" -- enable mouse all modes
o.mousefocus = true
o.mousemoveevent = true
o.mousescroll = {"ver:3", "hor:6"}

o.backspace = {"indent", "eol", "start"}
o.breakindentopt = "sbr" -- shift:2,min:20
o.smartindent = true
-- o.copyindent = true
o.cindent = true
-- o.autoindent = true
o.linebreak = true -- lines wrap at words rather than random characters

o.magic = true
o.joinspaces = false -- prevent inserting two spaces with J
o.lazyredraw = false
o.redrawtime = 2000
-- I like to have a differeniation between CursorHold and updatetime
-- Also, when only using updatetime, CursorHold doesn't seem to fire
g.cursorhold_updatetime = 250
o.updatetime = 2000
o.timeoutlen = 375 -- time to wait for mapping sequence to complete
o.ttimeoutlen = 50 -- time to wait for keysequence to complete used for ctrl-\ - ctrl-g
o.matchtime = 5 -- ms to blink when matching brackets
-- o.autoread = true
-- o.autowriteall = true -- automatically :write before running commands and changing files

o.whichwrap:append(list({"<", ">", "h", "l", "[", "]"}))
o.wrap = true
o.wrapmargin = 2

o.smarttab = true -- insert blanks spaces for tabs
o.tabstop = 2
o.expandtab = true
o.softtabstop = 2
o.shiftwidth = 0
-- o.shiftround = true -- round </> indenting
o.textwidth = 100
-- o.shiftround = true

o.wildoptions = {"pum", "fuzzy"}
o.wildignore = {
    "*.o",
    "*.pyc",
    "*.swp",
    "*.aux",
    "*.out",
    "*.toc",
    "*.o",
    "*.obj",
    "*.dll",
    "*.jar",
    "*.pyc",
    "*.rbc",
    "*.class",
    "*.gif",
    "*.ico",
    "*.jpg",
    "*.jpeg",
    "*.png",
    "*.avi",
    "*.wav",
    "*.lock",
    "*~",
    "*.git",
    "node_modules/*"
}
o.wildmenu = true
o.wildmode = "longest:full,full" -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true -- ignore case when completing file names and directories
-- o.wildcharm = fn.char2nr(utils.termcodes["<Tab>"])
o.wildcharm = ("\t"):byte()

o.winminwidth = 10
o.pumheight = 10 -- number of items in popup menu
o.pumblend = 3 -- Make popup window translucent

-- o.secure = true -- Disable autocmd etc for project local vimrc files.
-- o.exrc = true -- Allow project local vimrc files example .nvimrc see :h exrc

o.sessionoptions = {"globals", "buffers", "curdir", "tabpages", "winsize", "winpos", "help"}
o.viewdir = dirs.data .. "views"
if not uv.fs_stat(vim.o.viewdir) then
    fn.mkdir(vim.o.viewdir, "p")
end
o.viewoptions = {"cursor", "folds"} -- save/restore just these (with `:{mk,load}view`)
o.virtualedit = "block" -- allow cursor to move where there is no text in visual block mode
o.jumpoptions = {"stack", "view"}

o.history = 10000
o.backup = false
o.writebackup = false
o.swapfile = false -- no swap files
o.undofile = true
o.undolevels = 1000
o.undoreload = 10000
o.undodir = dirs.data .. "/vim-persisted-undo/"
if not uv.fs_stat(vim.o.undodir) then
    fn.mkdir(vim.o.undodir, "p")
end

o.shada = {
    "!", -- save and restore global variables starting with uppercase
    "'1000", -- previously edited files
    "<50", -- lines saved in each register
    "s100", -- maximum size of an item in KiB
    "/5000", -- search pattern history
    "@1000", -- input line history
    ":5000", -- command line history
    "h" -- disable `hlsearch` on loading
}
o.shadafile = dirs.data .. "/shada/main.shada"

o.belloff = "all"
o.visualbell = false
o.errorbells = false
o.confirm = true -- confirm when editing readonly

o.diffopt =
    o.diffopt +
    {
        "vertical",
        "iwhite",
        "hiddenoff",
        "foldcolumn:0",
        "context:4",
        "algorithm:patience",
        "indent-heuristic"
        -- "linematch:60"
    }

o.inccommand = "split" -- nosplit
o.splitright = true
o.splitbelow = true
-- o.eadirection = "hor" -- when equalsalways option applies

-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
o.switchbuf = "useopen,uselast"

o.conceallevel = 2
o.concealcursor = "c"
o.fillchars = {
    fold = " ",
    eob = " ", -- suppress ~ at EndOfBuffer
    diff = "╱", -- alternatives = ⣿ ░ ─
    msgsep = " ", -- alternatives: ‾ ─
    foldopen = "▾", -- 
    foldsep = "│",
    foldclose = "▸", -- 
    -- Use thick lines for window separators
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋"
}

o.cmdheight = 2
o.ruler = false
o.equalalways = false -- don't always make windows equal size
o.showmatch = true -- show matching brackets when text indicator is over them
o.showmode = false -- hide file, it's in lightline
o.showcmd = true -- show command
o.signcolumn = "yes:1"
o.synmaxcol = 300 -- do not highlight long lines
o.hidden = true -- enable modified buffers in background

-- TOaxSsIinfcFlotA
o.shortmess:append("a") -- enable shorter flags ('filmnrwx')
o.shortmess:append("c") -- don't give ins-completion-menu messages
o.shortmess:append("s") -- don't give "search hit BOTTOM
o.shortmess:append("I") -- don't give the intro message when starting Vim
o.shortmess:append("S") -- do not show search count message when searching (HLSLens)
o.shortmess:append("T") -- truncate messages if they're too long
o.shortmess:append("A") -- don't give the "ATTENTION" message when an existing swap file

-- o.shortmess = {
--     T = true, -- truncate non-file messages in middle
--     O = true, -- file-read message overwrites previous
--     a = true, -- enable shorter flags ('filmnrwx')
--     S = true, -- don't show search count message when searching (HLSLens)
--     s = true, -- don't give "search hit BOTTOM"
--     I = true, -- don't give intro message when starting vim
--     c = true, -- don't give ins-completion messages
--     t = true, -- truncate file messages at start
--     A = true, -- don't give the "ATTENTION" message when an existing swap file
--     o = true, -- file-read message overwrites previous
--     f = true, -- (file x of x) instead of just (x of x
--     F = true, -- don't give file info when editing a file
--     W = true -- don't show [w] or written when writing
-- }

o.cedit = "<C-c>" -- Key used to open command window on the CLI
o.tagfunc = "CocTagFunc"

o.grepprg =
    D.list(
    {
        "rg",
        "--with-filename",
        "--no-heading",
        "--max-columns=200",
        "--vimgrep",
        "--smart-case",
        "--color=never",
        "--follow",
        "--glob='!.git'",
        "--glob='!target'",
        "--glob='!node_modules'"
    },
    " "
)
-- o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
o.grepformat = o.grepformat:prepend({"%f:%l:%c:%m"})

-- ================== Gui ================== [[[
o.background = "dark"
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

g.neovide_refresh_rate = 60
g.neovide_input_use_logo = true
g.neovide_transparency = 0.9
g.neovide_no_idle = true
g.neovide_cursor_animation_length = 0.03
g.neovide_cursor_trail_length = 0.05
g.neovide_cursor_antialiasing = true
g.neovide_cursor_vfx_opacity = 200.0
g.neovide_cursor_vfx_particle_lifetime = 2.0
g.neovide_cursor_vfx_particle_density = 12.0
g.neovide_cursor_vfx_particle_speed = 20.0
g.neovide_cursor_vfx_mode = "torpedo"
-- ]]] === Gui ===

-- ============== Spell Check ============== [[[
o.completeopt:append({"menuone", "preview"})
o.complete:append({"kspell"})
o.complete:remove({"w", "b", "u", "t"})
o.spelllang:append("en_us")
o.spelloptions:append({"camel", "noplainbuffer"})
o.spellcapcheck = "" -- don't check for capital letters at start of sentence
o.spellsuggest = "12"
o.spellfile = ("%s%s"):format(dirs.config, "/spell/en.utf-8.add")
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
        paste = {
            ["+"] = {"xsel", "-o", "-b"},
            ["*"] = {"xsel", "-o", "-p"}
        },
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

o.clipboard:append("unnamedplus")
g.clipboard = clipboard
-- ]]] === Clipboard ===

-- if nvim.executable("nvr") then
--     env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- --     env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- end

env.MANWIDTH = 80

return M
