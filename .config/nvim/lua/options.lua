local M = {}
local utils = require("common.utils")
local map = utils.map
local list = require("dev").list

local o = vim.opt
local g = vim.g

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

-- map({ "n", "x" }, "<SubLeader>", "<Nop>", { noremap = true, silent = true })
-- map({ "n", "x" }, ";", "<SubLeader>", { noremap = false })

vim.tbl_map(
    function(p)
        g["loaded_" .. p] = vim.endswith(p, "provider") and 0 or 1
    end,
    {
        "ftplugin",
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logiPat", -- boolean logical pattern matcher
        "matchit",
        "matchparen",
        "rrhelper",
        "tar",
        "tarPlugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "ruby_provider",
        "perl_provider",
        "node_provider"
        -- "python_provider",
        -- "netrw",
        -- "netrwFileHandlers",
        -- "netrwPlugin",
        -- "netrwSettings",
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

o.infercase = true -- change case inference with completions
o.ignorecase = true
o.smartcase = true
o.wrapscan = true -- searches wrap around the end of the file
o.startofline = false
o.scrolloff = 5 -- cursor 5 lines from bottom of page
o.sidescrolloff = 15

-- o.foldmethod = "marker"
-- o.foldmarker = "[[[,]]]"
-- o.foldmethod = "expr"
-- o.foldexpr = "nvim_treesitter#foldexpr()"

o.foldenable = true
o.foldopen = o.foldopen:append("search")
o.foldlevelstart = 99
o.foldcolumn = "1"
-- o.foldlevel = 1

o.indentexpr = "nvim_treesitter#indent()"

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

-- A pattern that is used to recognize a list header. This is used for the "n"
-- flag in 'formatoptions'.
--                        ┌ recognize numbered lists (default)
--                        ├─────────────┐
o.formatlistpat = [[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\)\s*]]
--                                          ├───┘
--                                          └ recognize unordered lists

o.nrformats = list {"octal", "hex", "bin", "unsigned"}

o.title = true
o.titlestring = '%(%m%)%(%{expand("%:~")}%)'
o.titlelen = 70
o.titleold = fn.fnamemodify(os.getenv("SHELL"), ":t")

o.list = true -- display tabs and trailing spaces visually
-- FIX: For some reason tab hides actual text
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
o.showbreak = [[↳ ]] -- ↪
o.cpoptions:append("n") -- cursorcolumn used for wraptext
o.showtabline = 2
o.incsearch = true -- incremental search highlight

o.mouse = "a" -- enable mouse all modes
o.mousefocus = true

o.backspace = list {"indent", "eol", "start"}
o.breakindentopt = "sbr" -- shift:2,min:20
o.smartindent = true
o.cindent = true
-- o.autoindent = true
o.linebreak = true -- lines wrap at words rather than random characters

o.magic = true
o.joinspaces = false -- prevent inserting two spaces with J
o.lazyredraw = true
o.redrawtime = 1500
o.ruler = false
o.cmdheight = 2
o.equalalways = false -- don't always make windows equal size
o.autoread = true
o.autowriteall = true -- automatically :write before running commands and changing files

o.whichwrap:append(list {"<", ">", "h", "l", "[", "]"})
o.wrap = true
o.wrapmargin = 2

o.smarttab = true -- insert blanks spaces for tabs
o.tabstop = 2
o.expandtab = true
o.softtabstop = 2
o.shiftwidth = 0
-- o.shiftround = true -- round </> indenting
-- o.textwidth = 80
-- o.shiftround = true

o.wildoptions:append("pum")
o.wildignore = {"*.o", "*~", "*.pyc", "*.git", "node_modules"}
o.wildmenu = true
o.wildmode = "longest:full,full" -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true -- ignore case when completing file names and directories
o.wildcharm = fn.char2nr(utils.termcodes["<Tab>"])

o.pumheight = 10 -- number of items in popup menu
o.pumblend = 3 -- Make popup window translucent

-- o.secure = true -- Disable autocmd etc for project local vimrc files.
-- o.exrc = true -- Allow project local vimrc files example .nvimrc see :h exrc

o.sessionoptions = {"globals", "buffers", "curdir", "tabpages", "winsize", "winpos", "help"}
o.viewdir = fn.stdpath("data") .. "views"
if not uv.fs_stat(vim.o.viewdir) then
    fn.mkdir(vim.o.viewdir, "p")
end
o.viewoptions = {"cursor", "folds"} -- save/restore just these (with `:{mk,load}view`)
o.virtualedit = "block" -- allow cursor to move where there is no text in visual block mode
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
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
    -- Use thick lines for window separators
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋"
}

-- g.cursorhold_updatetime = 1000
o.updatetime = 200 -- cursorhold event time
o.timeoutlen = 375 -- time to wait for mapping sequence to complete
o.ttimeoutlen = 10 -- time to wait for keysequence to complete used for ctrl-\ - ctrl-g
o.showmatch = true -- show matching brackets when text indicator is over them
o.matchtime = 2 -- ms to blink when matching brackets
o.showmode = false -- hide file, it's in lightline
o.showcmd = false
o.signcolumn = "yes:1"
o.synmaxcol = 1000 -- do not highlight long lines
o.hidden = true -- enable modified buffers in background
o.shortmess:append("acsIS") -- aoOTIcF don't give 'ins-completion-menu' messages.

o.cedit = "<C-c>" -- Key used to open command window on the CLI
o.tagfunc = "CocTagFunc"

o.grepprg = "rg -H --no-heading --max-columns=200 --vimgrep --smart-case --color=never --glob '!.git'"
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
o.spelloptions = "camel"
o.spellcapcheck = "" -- don't check for capital letters at start of sentence
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

-- o.winbar = "%{%v:lua.require'options'.winbar()%}"

M.winbar_filetype_exclude = {
    "help",
    "startify",
    "dashboard",
    "packer",
    "neogitstatus",
    "NvimTree",
    "Trouble",
    "alpha",
    "lir",
    "Outline",
    "spectre_panel",
    "toggleterm"
}

M.winbar = function()
    if
        api.nvim_eval_statusline("%f", {}).str == "[No Name]" or
            vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype)
     then
        return ""
    end

    return "%#WinBarSeparator#" ..
        "%*" .. "%#WinBarContent#" .. "%m" .. " " .. "%F" .. "%*" .. "%#WinBarSeparator#" .. "%*"
end

-- if nvim.executable('nvr') then
--   env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
--   env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- end

return M
