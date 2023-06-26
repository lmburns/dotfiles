local M = {}

local uva = require("uva")
local F = Rc.F
local utils = Rc.shared.utils

local map = Rc.api.map

local env = vim.env
local o = vim.o
local opt = vim.opt
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

-- env.NVIM_COC_LOG_LEVEL = "trace"
-- env.NVIM_COC_LOG_FILE = "/tmp/coc1.log"

g.mapleader = [[ ]]
g.maplocalleader = [[,]]

_t({
    -- "man",
    -- "shada",
    -- "shada_plugin",
    -- "spellfile",
    -- "spell",
    -- "fzf",
    -- "health",
    -- "remote_plugins", -- required for wilder.nvim
    -- "rplugin", -- involved with remote_plugins
    --
    "ada",
    "clojurecomplete",
    "context",
    "contextcomplete",
    "csscomplete",
    "decada",
    "freebasic",
    "gnat",
    "haskellcomplete",
    "htmlcomplete",
    "javascriptcomplete",
    "phpcomplete",
    "pythoncomplete",
    "python3complete",
    "RstFold",
    "rubycomplete",
    "sqlcomplete",
    "vimexpect",
    "xmlcomplete",
    "xmlformat",
    "syntax_completion", -- omnicompletion
    "spellfile_plugin",  -- download spellfile
    --
    -- "perl_provider",
    -- "python3_provider",
    -- "pythonx_provider",
    "python_provider",
    "ruby_provider",
    "node_provider",
    --
    "2html_plugin", -- convert to HTML
    "getscript",
    "getscriptPlugin",
    "logiPat", -- boolean logical pattern matcher
    -- "matchit",
    -- "matchparen",
    -- "netrw",
    -- "netrwFileHandlers",
    -- "netrwPlugin",
    -- "netrwSettings",
    "rrhelper",
    "tutor_mode_plugin",
    "msgpack_autoload",
    "shada_autoload",
    --
    "gzip",
    "tar",
    "tarPlugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
    --
    "spec",
    "macmap",
    "sleuth",
    "gtags",
    "gtags_cscope",
    "editorconfig",
    "tohtml",
    "tutor",
    --
    "bugreport",
    "synmenu",
    -- "compiler",
    -- "syntax",
    -- "optwin", -- show window of options
    -- "ftplugin",
}):map(
    function(p)
        g["loaded_" .. p] = F.if_expr(p:endswith("provider"), 0, 1)
    end
)

g.did_install_default_menus = 1
g.did_install_syntax_menu = 1
g.skip_loading_mswin = 1
-- g.do_filetype_lua = 1
-- g.did_load_filetypes = 0
-- g.did_indent_on = 1
-- g.did_load_ftplugin = 1
-- g.loaded_nvim_hlslens = 1
-- g.load_black = 1

if #fn.glob("$XDG_DATA_HOME/pyenv/shims/python3") ~= 0 then
    g.python3_host_prog = fn.glob("$XDG_DATA_HOME/pyenv/shims/python")
end

-- === Path =============================================================== [[[
opt.path:append({
    -- "**",
    "/usr/include",
    -- "/usr/lib/gcc/**/include",
    -- "/usr/lib/clang/**/include",
})

-- Prevent loading the system fzf.vim plugin
opt.pp:remove("/etc/xdg/nvim")
opt.pp:remove("/etc/xdg/nvim/after")
opt.pp:remove("/usr/share/nvim/site")
opt.pp:remove("/usr/share/nvim/site/after")
opt.pp:remove("/usr/local/share/nvim/site")
opt.pp:remove("/usr/local/share/nvim/site/after")

opt.rtp:remove("/etc/xdg/nvim")
opt.rtp:remove("/etc/xdg/nvim/after")
opt.rtp:remove("/usr/share/nvim")
opt.rtp:remove("/usr/share/nvim/site")
opt.rtp:remove("/usr/share/nvim/site/after")
opt.rtp:remove("/usr/local/share/nvim")
opt.rtp:remove("/usr/local/share/nvim/site")
opt.rtp:remove("/usr/local/share/nvim/site/after")
opt.rtp:remove("/usr/share/vim/vimfiles")

opt.cdhome = true -- :cd/:tcd/:lcd with no args goes home
-- o.cdpath:append({"~/projects/github", "~/projects", "~/.config"})
-- ]]]

-- Base
env.LANG = "en_US.UTF-8"
o.shell = Rc.meta.shell
o.encoding = "utf-8"                     -- string-encoding used internally
o.fileencoding = "utf-8"                 -- file-encoding for current buffer
o.fileformat = "unix"                    -- use unix line endings
opt.fileformats = {"unix", "mac", "dos"} -- EOL formats to try
-- increment / decrement
opt.nrformats = {"octal", "hex", "bin", "unsigned", "alpha"}

-- === Files ============================================================== [[[
o.backup = false -- backup files
o.writebackup = false
o.backupdir = Rc.dirs.data .. "/backup/"
-- o.patchmode = ".orig"
uva.stat(o.backupdir):catch(function()
    fn.mkdir(o.backupdir, "p")
end)

if o.backup then
    o.writebackup = true -- make backup before overwriting curbuf
    o.backupcopy = "yes" -- overwrite original backup file

    nvim.autocmd.lmb__BackupFilename = {
        event = "BufWritePre",
        pattern = "*",
        command = function()
            -- Meaningful backup name, ex: filename@2023-03-05T14
            -- Overwrite each and keep one per day. Can add '_%M_%S'
            o.backupext = ("@%s"):format(fn.strftime("%FT%H")) --[[@as vim.opt.backupext]]
        end,
    }
end

o.swapfile = false -- disable swapfiles
o.directory = Rc.dirs.data .. "/swap/"

o.history = 10000    -- number of lines of history to keep
o.undofile = true    -- enable undo files
o.undolevels = 1000  -- number of changes that can be undone
o.undoreload = 10000 -- save whole buffer for undo when reloading it
o.undodir = Rc.dirs.data .. "/vim-persisted-undo/"
uva.stat(o.undodir):catch(function()
    fn.mkdir(o.undodir, "p")
end)

o.shadafile = Rc.dirs.data .. "/shada/main.shada"
opt.shada = {
    "!",     -- save and restore global variables starting with uppercase
    "'1000", -- previously edited files
    "<20",   -- lines saved in each register
    "s100",  -- maximum size of an item in KiB
    "/5000", -- search pattern history
    "@1000", -- input line history
    ":5000", -- command line history
    "h",     -- disable `hlsearch` on loading
    "r/tmp/",
    "r/private/",
    "r/dev/shm/",
    "rtemp://", -- ignore these paths
    "rterm://",
    "rfugitive://",
    "rgitsigns://",
    "rman://",
    "rhealth://",
    "rzipfile://",
}

o.browsedir = "buffer"                -- use the directory of the related buffer
opt.sessionoptions = {                -- changes behavior of `:mksession`
    "buffers",                        -- hidden/unloaded buffers
    "curdir",                         -- current directory
    "folds",                          -- manually created folds
    "globals",                        -- global variables (str/int types)
    "help",                           -- help window
    "localoptions",                   -- local options/mappings
    "options",                        -- all options/mappings
    "tabpages",                       -- all tabpages
    "winpos",                         -- position of whole vim window
    "winsize",                        -- window sizes
}
opt.viewoptions = {"cursor", "folds"} -- save/restore just these (with `:{mk,load}view`)
o.viewdir = Rc.dirs.data .. "views"
uva.stat(o.viewdir):catch(function()
    fn.mkdir(o.viewdir, "p")
end)

o.autowrite = true    -- auto :write before running commands & changing files
o.autowriteall = true -- auto :write for all buffers
-- o.autoread = true     -- auto reload if changed outside vim (autocmd for this)
-- o.autochdir = true    -- change current directory to fn.expand('%:p:h')
o.exrc = nvim.has("nvim-0.9") -- exec .nvimrc/.exrc in current dir
-- ]]]

-- === Spell Checking ===================================================== [[[
opt.completeopt = {"menuone", "noselect"}
opt.complete:append("kspell")
opt.complete:remove({"w", "b", "u", "t", "i"})
opt.spelllang:append({"en_us"})
opt.spelloptions:append({"camel", "noplainbuffer"})
opt.spellcapcheck = "" -- don't check for capital letters at start of sentence
opt.spellsuggest:prepend({12})
o.spellfile = Rc.dirs.config .. "/spell/en.utf-8.add"
-- ]]]

o.magic = true         -- :h pattern-overview
o.infercase = true     -- change case inference with completions
o.ignorecase = true    -- ignore case of matches
o.smartcase = true     -- if captial letter in pattern, match case
o.wrapscan = true      -- searches wrap around the end of the file
o.incsearch = true     -- incremental search highlight
o.inccommand = "split" -- :subst :smagic :sno preview

-- I like to have a differeniation between CursorHold and updatetime
-- Also, when only using updatetime, CursorHold doesn't seem to fire
g.cursorhold_updatetime = 250
o.updatetime = 2000
o.redrawtime = 2000            -- time it takes to redraw ('hlsearch', 'inccommand')
o.timeoutlen = 375             -- wait time for map sequence to complete
o.ttimeoutlen = 50             -- wait time for keycode to complete
o.lazyredraw = false           -- screen not redrawn with macros, registers

opt.matchpairs:append({"<:>"}) -- pairs to highlight with showmatch -- "=:;"
o.matchtime = 2                -- ms to blink when matching brackets
o.showmatch = false            -- when inserting pair, jump to matching one -- NOTE: maybe change

o.belloff = "all"              -- disable all bells
o.visualbell = false           -- disable visual bells
o.errorbells = false           -- disable error bells
o.confirm = true               -- confirm when leaving buffer
o.report = 2                   -- report if at least 1 line changed

o.title = true
o.titlestring = "%(%m%)%(%{expand(\"%:~\")}%)"
o.titlelen = 70
o.titleold = fn.fnamemodify(Rc.meta.shell, ":t")

-- Mouse
o.mouse = "a" -- enable mouse all modes
o.mousefocus = true
o.mousemoveevent = true
o.mousemodel = "popup"               -- what right-click does
opt.mousescroll = {"ver:3", "hor:6"} -- number of cols when scrolling with mouse

o.includeexpr = [=[substitute(v:fname, '^[^\\/]*/', '', 'g')]=]
o.tagfunc = "CocTagFunc"
-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
opt.switchbuf = {"useopen", "uselast"}
-- change behavior of 'jumplist'
opt.jumpoptions = {
    -- behave like tagstack - relloc is preserved (sumneko jumps to top clearing a bunch)
    -- "stack",
    "view", -- try to restore mark-view
}

o.cmdheight = 2    -- number of screen lines to use for the command-line
o.pumheight = 10   -- number of items in popup menu
o.pumblend = 3     -- make popup window translucent
o.showtabline = 2  -- always show tabline
o.laststatus = 3   -- global statusline
o.synmaxcol = 300  -- do not highlight long lines
o.ruler = false    -- cursor position is in statusline
o.showmode = false -- hide mode, it's in statusline
o.showcmd = false  -- show command (noice does it)
o.hidden = true    -- enable modified buffers in background

o.cursorline = true
opt.cursorlineopt = {"number", "screenline"} -- highlight number and screenline
o.scrolloff = 5                              -- cursor 5 lines from bottom of page
o.sidescrolloff = 10                         -- minimal number of screen columns to keep to the left
o.sidescroll = 1                             -- minimal number of columns to scroll horizontally
o.textwidth = 100                            -- maximum width of text
o.winminwidth = 2                            -- minimal width of a window, when it's not the current window
o.equalalways = false                        -- don't always make windows equal size
o.splitright = true                          -- prefer splitting right
o.splitbelow = true

o.numberwidth = 4       -- minimal number of columns to use for the line number
o.number = true         -- print the line number in front of each line
-- o.relativenumber = true -- show the line number relative to the line with the cursor
o.signcolumn = "yes:1"

-- === Folding ============================================================ [[[
o.foldenable = true -- enable folding
opt.foldopen = {
    -- want to add 'g;', 'g,'
    -- "jump", "insert",
    "block",
    "hor",
    "mark",
    "percent",
    "quickfix",
    "search",
    "tag",
    "undo",
}                     -- commands that open a fold
o.foldlevel = 99      -- folds higher than this will be closed (zm, zM, zR)
o.foldlevelstart = 99 -- sets 'foldlevel' when editing buffer
o.foldcolumn = "1"    -- when to draw fold column
-- ]]]

-- Autocompletion
opt.wildoptions = {"pum", "fuzzy"}
opt.wildignore = {
    "*.o",
    "*.pyc",
    "*.swp",
    "*.aux",
    "*.out",
    "*.toc",
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
    "node_modules/*",
}
opt.wildmenu = true
o.wildmode = "list:full"
o.wildignorecase = true -- ignore case when completing file names and directories
o.wildcharm = ("\t"):byte() --[[@as vim.opt.wildcharm]]
-- o.wildcharm = fn.char2nr([[\<C-'>]]) --[[@as vim.opt.wildcharm]]
-- o.wildchar = fn.char2nr([[\<C-'>]]) --[[@as vim.opt.wildchar]]

opt.suffixesadd:append({".rs", ".go", ".c", ".h", ".cpp", ".zsh", ".rb", ".pl", ".py"})
opt.suffixes:append({".aux", ".log", ".dvi", ".bbl", ".blg", ".brf", ".cb", ".ind", ".idx", ".ilg",
    ".inx", ".out", ".toc", ".o", ".obj", ".dll", ".class", ".pyc", ".ipynb", ".so", ".swp", ".zip",
    ".exe", ".jar", ".gz",})

o.cedit = "<C-c>"         -- key used to open command window on the CLI
o.selectmode = ""         -- when select mode is used -- mouse
o.selection = "inclusive" -- select can go 1 past EOL
o.mousemodel = "popup"    -- right click behavior
o.virtualedit = "block"   -- allow cursor to move where there is no text in visual block mode
o.startofline = false     -- CTRL-D, CTRL-U, CTRL-B, CTRL-F, "G", "H", "M", "L", gg go to start of line

o.display = "lastline"    -- display line instead of continuation '@@@'
o.list = true             -- display tabs and trailing spaces visually
opt.listchars = {
    eol = nil,
    tab = "‣ ",
    trail = "•",
    precedes = "«",
    extends = "…", -- »
    nbsp = "␣",
    -- leadmultispace = "---+"
}

o.conceallevel = 2
o.concealcursor = "c"
opt.fillchars = {
    fold = " ",
    eob = " ",       -- suppress ~ at EndOfBuffer
    diff = "╱",    -- alternatives = ⣿ ░ ─
    msgsep = " ",    -- alternatives: ‾ ─
    foldopen = "", --  ▽  ▾ 
    foldsep = "┃", -- │
    foldclose = "", --  ▶  ▸ 
    -- Use thick lines for window separators
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
    lastline = "@", -- 
}

-- Vi-compatible options
opt.cpoptions:append({
    _ = true,      -- do not include whitespace with 'cw'
    a = true,      -- ":read" sets alternate filename
    A = true,      -- ":write" sets alternate filename
    -- f = true,      -- ":read" sets filename if buf doesn't have it
    -- F = true,      -- ":write" sets filename if buf doesn't have it

    -- d = true,      -- "./" in tags means tag file current directory
    I = true,      -- up/down after inserting indent doesn't delete it

    -- R = false,     -- filtered lines keep marks
    M = false,     -- "%" matching takes into account backslashes
    -- ["%"] = false, -- matching pairs inside quotes is different from outside
    -- m = true, -- showmatch always waits half a second

    -- t = true, -- search pattern for tag command is remembered for 'n'/'N'
    -- n = true, -- signcolumn used for wraptext
    -- q = true, -- when joining multiple lines, leave cursor position at first spot
    -- r = true, -- redo uses '/' to repeat search
})

-- Helps avoid 'hit-enter' prompts (filnxtToOF)
opt.shortmess:append("a") -- enable shorter flags ('filmnrwx')
opt.shortmess:append("c") -- don't give ins-completion-menu messages
opt.shortmess:append("s") -- don't give "search hit BOTTOM
opt.shortmess:append("I") -- don't give the intro message when starting Vim
opt.shortmess:append("S") -- do not show search count message when searching (HLSLens)
opt.shortmess:append("T") -- truncate messages if they're too long

-- o.shortmess = {
--     f = true, -- (x of y) instead of (file x of y)
--     i = true, -- use "[noeol]" instead of "[Incomplete last line]"
--     l = true, -- use "999L, 888B" instead of "999 lines, 888 bytes"
--     m = true, -- use "[+]" instead of "[Modified]"
--     n = true, -- use "[New]" instead of "[New File]"
--     x = true, -- "[unix]"-x* instead of "[unix format]"
--     -- a = true, -- enable shorter flags ('filmnrwx')
--     A = true, -- don't give the "ATTENTION" message when an existing swap file
--     c = true, -- don't give ins-completion messages
--     I = true, -- don't give intro message when starting vim
--     o = true, -- overwrite msg for writing file with msg for reading file
--     O = true, -- file-read/quickfix message overwrites previous
--     s = true, -- don't give "search hit BOTTOM" or "TOP"
--     t = true, -- truncate file messages at start
--     T = true, -- truncate other messages in the middle if they are too long "..."
--     F = true, -- don't give file info when editing a file
--     S = true -- don't show search count message when searching (HLSLens)
-- }

-- keys that move the cursor to the next line on last char
opt.whichwrap = {
    ["<"] = true, -- <Left>  (NV)
    [">"] = true, -- <Right> (NV)
    ["["] = true, -- <Left>  (IR)
    ["]"] = true, -- <Right> (IR)
    b = true,     --    <BS> (NV)
    h = true,     --       h (NV)
    l = true,     --       l (NV)
    s = true,     -- <Space> (NV) (this is leader)
}
o.wrap = true
o.wrapmargin = 2

-- https://stackoverflow.com/questions/37149002/vim-indenting-bullet-lists-within-comments-in-python

o.joinspaces = false -- prevent inserting two spaces with J
opt.formatoptions = {
    ["/"] = true,    -- when 'o' included: don't insert comment leader for // comment after statement
    ["1"] = true,    -- don't break a line after a one-letter word; break before
    M = true,        -- when joining lines, don't insert a space before or after a multibyte char
    j = true,        -- remove a comment leader when joining lines.
    -- Only break if the line was not longer than 'textwidth' when the insert
    -- started and only at a white character that has been entered during the
    -- current insert command.
    l = true,
    p = true,      -- don't break lines at single spaces that follow periods
    r = true,      -- continue comments when pressing Enter
    o = true,      -- automatically insert comment leader after 'o'/'O'
    q = true,      -- format comments with gq"
    -- PERF: checking to see if this increases performance
    n = false,      -- recognize numbered lists. Indent past formatlistpat not under
    --
    ["2"] = false, -- use indent from 2nd line of a paragraph
    v = false,     -- only break line at blank line I've entered
    c = false,     -- auto-wrap comments using textwidth
    t = false,     -- autowrap lines using text width value
}

-- recognize list header ('n' flag in 'formatoptions')
-- o.formatlistpat = [[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\+\)\s*]]
-- o.formatlistpat=^\s*\w\+[.\)]\s\+\|^\s*[-+*]\+\s\+
o.formatlistpat = [==[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\+\)\s*\|^\[^\ze[^\]]\+\]:]==]

-- Indenting
local indent = 2
o.shiftwidth = indent                      -- # of spaces to use for each step
o.tabstop = indent                         -- # of spaces a <Tab> in the file counts for
o.softtabstop = indent                     -- # of spaces a <Tab> counts for while editing
o.expandtab = true                         -- use the appropriate number of spaces to insert a <Tab>
o.smarttab = true                          -- line start insert blanks equal to 'sw'. 'ts'/'sts' for other places
o.shiftround = true                        -- round </> indenting
opt.backspace = {"indent", "eol", "start"} -- <BS>, <Del>, CTRL-W and CTRL-U in insert

-- o.indentexpr = "nvim_treesitter#indent()" -- (overrules 'smartindent', 'cindent')
-- Priority: indentexpr > cindent > smartindent
o.autoindent = true  -- copy indent from current line when starting a new line (<CR>, o, O)
o.smartindent = true -- smart autoindenting when starting a new line (C-like progs)
o.cindent = true     -- automatic C program indenting
-- o.copyindent = true -- copy structure of existing lines indent when autoindenting a new line
-- o.preserveindent = true -- preserve most indent structure as possible when reindenting line
o.showbreak = [[↳ ]] -- ↪  ⌐
o.breakindent = true   -- each wrapped line will continue same indent level
opt.breakindentopt = { -- settings of 'breakindent'
    "sbr",             -- display 'showbreak' value before applying indent
    "list:2",          -- add additional indent for lines matching 'formatlistpat'
    "min:20",          --- min width kept after breaking line
    "shift:2",         -- all lines after break are shifted N
}
o.linebreak = true     -- lines wrap at words rather than random characters
-- which chars cause break with 'linebreak'
-- o.breakat = "  !@*-+;:,./?"
-- opt.breakat = {
--     -- ["\t"] = true,
--     [" "] = true,
--     ["!"] = true,
--     ["*"] = true,
--     ["+"] = true,
--     [","] = true,
--     ["-"] = true,
--     ["."] = true,
--     ["/"] = true,
--     [":"] = true,
--     [";"] = true,
--     ["?"] = true,
--     ["@"] = true
-- }

-- strings that can start a comment line
-- opt.comments = {
--     "n:>", -- nested comment prefix
--     "b:#", -- blank (<Space>, <Tab>, or <EOL>) required after prefix
--     "fb:-", -- only first line has comment string (e.g., a bullet-list)
--     "fb:*", -- only first line has comment string (e.g., a bullet-list)
--     "s1:/*", -- start of three-piece comment
--     "mb:*", -- middle of three-piece comment
--     "ex:*/", -- end of three-piece comment
--     "://",
--     ":%",
--     ":XCOMM"
-- }

-- Builtin
-- vim.o.cinoptions =
--     "s,e0,n0,f0,{0,}0,^0,L-1,:s,=s,l0,b0,gs,hs,N0,E0,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,k0,m0,j0,J0,)20,*70,#0,P0"

-- opt.cinoptions = {
--     ">1s", -- any: amount added for "normal" indent
--     "L0",  -- placement of jump labels
--     "=1s", -- ? case: statement after case label: N chars from indent of label
--     "l1",  -- N!=0 case: align w/ case label instead of statement after it on same line
--     "b1",  -- N!=0 case: align final "break" w/ case label so it looks like block (0=break cinkeys)
--     "g1s", -- ? C++ scope decls: N chars from indent of block they're in
--     "h1s", -- ? C++: after scope decl: N chars from indent of label
--     "N0",  -- ? C++: inside namespace: N chars extra
--     "E0",  -- ? C++: inside linkage specifications: N chars extra
--     "p1s", -- ? K&R: function decl: N chars from margin
--     "t0",  -- K&R: return type of function decl: N chars from margin
--     "i1s", -- ? C++: base class decl/constructor init if they start on newline
--     "+0",  -- line continuation: N chars extra inside function; 2*N outside func if line end = '\'
--     "c1s", -- comment lines: N chars from comment opener if no other text to align with
--     "(1s", -- inside unclosed paren: N chars from line ('sw' for every unclosed paren)
--     "u1s", -- same as (N but one level deeper
--     "U1",  -- N!=0 : do not ignore nested parens that are on line by themselves
--     -- "wN", "WN" --
--     "k1s", -- unclosed paren in 'if' 'for' 'while' override '(N'
--     "m1",  -- N!=0 line up line starting w/ closing paren w/ 1st char of line w/ opening
--     "j1",  -- java: anon classes
--     "J1",  -- javascript: object classes
--     ")40", -- search for parens N lines away
--     "*70", -- search for unclosed comments N lines away
--     "#0",  -- N!=0 recognized '#' comments otherwise preproc (toggle this for files)
--     "P1",  -- N!=0 format C pragmas
-- }

-- keys in insert mode that cause reindenting of current line 'cinkeys-format'
-- 0#
-- opt.cinkeys = {"0{", "0}", "0)", "0]", ":", "!^F", "o", "O", "e"}

opt.diffopt = {
    "algorithm:histogram",
    "internal",
    "indent-heuristic",
    "filler",
    "closeoff",
    "iwhite",
    "vertical",
    "linematch:100",

    -- "vertical",
    -- "iwhite",
    -- "hiddenoff",
    -- "foldcolumn:0",
    -- "context:4",
    -- "algorithm:patience",
    -- "indent-heuristic",
    -- "linematch:60"
}

if utils.executable("rg") then
    o.grepprg = utils.list({
        "rg",
        "--color=never",
        "--hidden",
        "--follow",
        "--smart-case",
        "--auto-hybrid-regex",
        "--max-columns=150",
        "--max-depth=6",
        "--max-columns-preview",
        "--no-binary",
        "--no-heading",
        "--vimgrep",
        "--glob='!.git'",
        "--glob='!target'",
        "--glob='!node_modules'",

        -- "--with-filename",
        -- "--line-number",
        -- "--column",
    }, " ") --[[@as vim.opt.grepprg]]
    opt.grepformat:prepend({"%f:%l:%c:%m", "%f:%l:%m"})
    -- o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- ================== Gui ================== [[[
o.background = "dark"
o.termguicolors = true
-- o.guioptions:remove({ "m", "r", "l" })
g.guitablabel = "%M %t"
opt.guicursor = {
    [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]],
    [[a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]],
    [[sm:block-blinkwait175-blinkoff150-blinkon175]],
}
o.guifont = [[FiraCode Nerd Font Mono:h13]]
o.emoji = false

if fn.exists("g:neovide") then
    map("n", "<C-p>", [["+p]])
    map("i", "<C-p>", "<C-r>+")
    map("c", "<C-p>", "<C-r>+")
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

-- =============== Clipboard =============== [[[
local clipboard
if env.DISPLAY and utils.executable("xsel") then
    clipboard = {
        name = "xsel",
        copy = {
            ["+"] = {"xsel", "--nodetach", "-i", "-b"},
            ["*"] = {"xsel", "--nodetach", "-i", "-p"},
        },
        paste = {
            ["+"] = {"xsel", "-o", "-b"},
            ["*"] = {"xsel", "-o", "-p"},
        },
        cache_enabled = true,
    }
elseif env.TMUX then
    clipboard = {
        name = "tmux",
        copy = {
            ["+"] = {"tmux", "load-buffer", "-w", "-"},
        },
        paste = {
            ["+"] = {"tmux", "save-buffer", "-"},
        },
        cache_enabled = true,
    }
    clipboard.copy["*"] = clipboard.copy["+"]
    clipboard.paste["*"] = clipboard.paste["+"]
elseif fn.executable("osc52send") == 1 then
    clipboard = {
        name = "osc52send",
        copy = {["+"] = {"osc52send"}},
        paste = {
            ["+"] = function()
                return {fn.getreg("0", 1, true), fn.getregtype("0")}
            end,
        },
        cache_enabled = false,
    }
    clipboard.copy["*"] = clipboard.copy["+"]
    clipboard.paste["*"] = clipboard.paste["+"]
end

opt.clipboard:append("unnamedplus")
g.clipboard = clipboard
-- ]]] === Clipboard ===

-- === Digraphs =========================================================== [[[
cmd.digraph([[// 8800]]) -- ≡ identical
cmd.digraph([[/= 8801]]) -- ≠ not equal
cmd.digraph([[\= 8776]]) -- ≈ almost equal to
cmd.digraph([[\< 8804]]) -- ≤ less than or equal
cmd.digraph([[\> 8805]]) -- ≥ greater than or equal
cmd.digraph([[\* 215]])  -- × cartesian product
cmd.digraph([[\. 9675]]) -- ○ composite
cmd.digraph([[\/ 247]])  -- ÷ division
cmd.digraph([[\a 8704]]) -- ∀ forall
cmd.digraph([[\e 8707]]) -- ∃ exists
cmd.digraph([[\E 8708]]) -- ∄ does not exist
cmd.digraph([[\t 8756]]) -- ∴ therefore
cmd.digraph([[\b 8757]]) -- ∵ because
cmd.digraph([[!! 172]])  -- ¬ not
cmd.digraph([[!t 8872]]) -- ⊨ true
cmd.digraph([[!f 8877]]) -- ⊭ not true
cmd.digraph([[&& 8743]]) -- ∧ and
cmd.digraph([[&n 8891]]) -- ⊼ nand
cmd.digraph([[|| 8744]]) -- ∨ or
cmd.digraph([[|n 8893]]) -- ⊽ nor
cmd.digraph([[|x 8891]]) -- ⊻ xor
cmd.digraph([[\m 8871]]) -- ⊧ models
cmd.digraph([[\A 8870]]) -- ⊦ assertion
cmd.digraph([[\U 8745]]) -- ∩ intersect
cmd.digraph([[\u 8746]]) -- ∪ union
cmd.digraph([[(( 8834]]) -- ⊂ subset
cmd.digraph([[(= 8838]]) -- ⊆ subset of or equal to
cmd.digraph([[(! 8836]]) -- ⊄ not a subset of
cmd.digraph([[)) 8835]]) -- ⊃ superset
cmd.digraph([[)= 8839]]) -- ⊇ superset of or equal to
cmd.digraph([[)! 8837]]) -- ⊅ not a superset of
cmd.digraph([[]e 8712]]) -- ∈ element of
cmd.digraph([[]E 8713]]) -- ∉ not an element of
cmd.digraph([[|^ 8593]]) -- ↑ arrow up
cmd.digraph([[|v 8595]]) -- ↓ arrow down
cmd.digraph([[oo 8734]]) -- ∞ infinity
cmd.digraph([[sq 8730]]) -- √ square root

cmd.digraph([[\r 8658]]) -- ⇒ rightwards double

-- '⇒'  U+21D2  8658   e2 87 92    &rArr;     RIGHTWARDS DOUBLE ARROW (Math_Symbol)

-- '∎'  U+220E  8718   e2 88 8e    &#x220e;   END OF PROOF (Math_Symbol)
-- '≉'  U+2249  8777   e2 89 89    &nap;      NOT ALMOST EQUAL TO (Math_Symbol)
-- '≅'  U+2245  8773   e2 89 85    &cong;     APPROXIMATELY EQUAL TO (Math_Symbol)
-- '∶'  U+2236  8758   e2 88 b6    &ratio;    RATIO (Math_Symbol)
-- '⊬'  U+22AC  8876   e2 8a ac    &nvdash;   DOES NOT PROVE (Math_Symbol)
-- '∹'  U+2239  8761   e2 88 b9    &#x2239;   EXCESS (Math_Symbol)
-- '≔'  U+2254  8788   e2 89 94    &colone;   COLON EQUALS (Math_Symbol)
-- '≕'  U+2255  8789   e2 89 95    &ecolon;   EQUALS COLON (Math_Symbol)
-- '⊩'  U+22A9  8873   e2 8a a9    &Vdash;    FORCES (Math_Symbol)
-- '∫'  U+222B  8747   e2 88 ab    &int;      INTEGRAL (Math_Symbol)
-- '∷'  U+2237  8759   e2 88 b7    &Colon;    PROPORTION (Math_Symbol)

cmd.digraph([[.e 8230]]) -- … ellipses

cmd.digraph([[pH 934]])  -- Φ phi
cmd.digraph([[ph 966]])  -- φ phi
cmd.digraph([[ps 936]])  -- Ψ psi
cmd.digraph([[pi 960]])  -- π pi
cmd.digraph([[be 946]])  -- β beta
cmd.digraph([[al 945]])  -- α alpha
cmd.digraph([[de 948]])  -- δ delta
cmd.digraph([[th 1012]]) -- ϴ theta
cmd.digraph([[sI 931]])  -- Σ sigma
cmd.digraph([[si 964]])  -- σ sigma
cmd.digraph([[mu 956]])  -- μ mu
cmd.digraph([[ko 990]])  -- Ϟ koppa
cmd.digraph([[Dn 8469]]) -- ℕ double struck N
cmd.digraph([[Dp 8473]]) -- ℙ double struck P
cmd.digraph([[Dr 8477]]) -- ℝ double struck R
cmd.digraph([[Dz 8484]]) -- ℤ double struck Z
cmd.digraph([[Dc 8450]]) -- ℂ double struck C
cmd.digraph([[Dq 8474]]) -- ℚ double struck Q
cmd.digraph([[Dh 8461]]) -- ℍ double struck H

-- '𝞉'  U+1D789 120713 f0 9d 9e 89 &#x1d789;  MATHEMATICAL SANS-SERIF BOLD PARTIAL DIFFERENTIAL (Math_Symbol)
-- '𝛛'  U+1D6DB 120539 f0 9d 9b 9b &#x1d6db;  MATHEMATICAL BOLD PARTIAL DIFFERENTIAL (Math_Symbol)
-- 'ϸ'  U+03F8  1016   cf b8       &#x3f8;    GREEK SMALL LETTER SHO (Lowercase_Letter)
-- 'ℼ'  U+213C  8508   e2 84 bc    &#x213c;   DOUBLE-STRUCK SMALL PI (Lowercase_Letter)
-- 'ℿ'  U+213F  8511   e2 84 bf    &#x213f;   DOUBLE-STRUCK CAPITAL PI (Uppercase_Letter)
-- '⅀'  U+2140  8512   e2 85 80    &#x2140;   DOUBLE-STRUCK N-ARY SUMMATION (Math_Symbol)
-- 'ⅅ'  U+2145  8517   e2 85 85    &DD;       DOUBLE-STRUCK ITALIC CAPITAL D (Uppercase_Letter)

-- ]]]

-- === Other ============================================================== [[[

-- if nvim.executable("nvr") then
--     local nvr = "nvr --servername " .. vim.v.servername .. " "
--     env.GIT_EDITOR = nvr .. "-cc split +'setl bh=delete' --remote-wait"
--     -- env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
--
--     -- env.EDITOR = nvr .. "-l --remote"
--     -- env.VISUAL = nvr .. "-l --remote"
--     -- env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- end

env.MANWIDTH = 80

---Notify with nvim-notify if nvim is focused,
---Otherwise send a desktop notification.
g.nvim_focused = true
g.treesitter_refactor_maxlines = 10 * 1024
g.treesitter_highlight_maxlines = 12 * 1024
g.editorconfig = false

g.markdown_fenced_languages = {
    "bash=sh",
    "c",
    "console=sh",
    "go",
    "help",
    "html",
    "javascript",
    "js=javascript",
    "json",
    "lua",
    "py=python",
    "python",
    "rs=rust",
    "rust",
    "sh=zsh",
    "shell=zsh",
    "toml",
    "ts=typescript",
    "typescript",
    "vim",
    "yaml",
}

g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_dirhistmax = 20
g.netrw_fastbrowse = 0
g.netrw_browse_split = 4
g.netrw_sizestyle = "H" -- human readable
g.netrw_alto = 1
g.netrw_altv = 1
g.netrw_hide = 0
g.netrw_special_syntax = 1
g.netrw_sort_sequence = [[[\/]$,*]]
g.netrw_sort_options = "in"
g.netrw_list_hide = [[,\(^\|\s\s\)\zs\.\S\+]]
g.netrw_browsex_viewer = "handlr open"
g.netrw_localcopycmd = "cp"
g.netrw_localcopycmdopt = " -ivp --reflink=auto"
g.netrw_localcopydircmd = "cp"
g.netrw_localcopydircmdopt = " -ivpr --reflink=auto"
g.netrw_localmovecmd = "mv"
g.netrw_localmovecmdopt = " -iv"
g.netrw_localmkdir = "mkdir"
g.netrw_localmkdiropt = " -p"
g.netrw_localrmdir = "rip"
g.netrw_localrm = "rip"
g.netrw_keepj = "keepj"
-- g.netrw_browse_split = 4
-- g.netrw_use_noswf = 0

--  ╭────────────────╮
--  │ Syntax options │
--  ╰────────────────╯
g.no_man_maps = 1
g.no_plugin_maps = 1

g.c_syntax_for_h = 1 -- use C syntax instead of C++ for .h
-- g.c_gnu = 1          -- GNU gcc specific settings
-- g.c_space_errors = 0    -- highlight space errors
-- g.c_curly_error = 0     -- highlight missing '}'
-- g.c_comment_strings = 0 -- strings and numbers in comment
-- g.c_ansi_typedefs = 1   -- do ANSI types
-- g.c_ansi_constants = 1  -- do ANSI constants
-- g.c_no_trail_space_error = 0 -- don't highlight trailing space
-- g.c_no_comment_fold = 0      -- don't fold comments
-- g.c_no_cformat = 0           -- don't highlight %-formats in strings
-- g.c_no_if0 = 0               -- don't highlight "#if 0" blocks as comments
-- g.c_no_if0_fold = 0          -- don't fold #if 0 blocks

g.cpp_no_function_highlight = 1        -- disable function highlighting
g.cpp_simple_highlight = 1             -- highlight all standard C keywords with `Statement`
g.cpp_named_requirements_highlight = 1 -- enable highlighting of named requirements

g.load_doxygen_syntax = 0              -- enable doxygen syntax
g.doxygen_enhanced_color = 0           -- use nonstd hl for doxygen comments
g.desktop_enable_nonstd = 0            -- highlight nonstd ext. of .desktop files

g.html_syntax_folding = 0
g.vim_json_conceal = 0     -- don't conceal json
g.lifelines_deprecated = 1 -- hl deprecated funcs as errors

g.nroff_is_groff = 1
g.nroff_space_errors = 1
-- b.preprocs_as_sections = 1

-- g.perl_no_scope_in_variables = 0 -- don't hl pkgname differently in '$PkgName::Var'
-- g.perl_no_extended_vars = 0 -- don't hl complex variables
g.perl_string_as_statement = 1 -- highlight string different if 2 on same line
g.perl_fold = 1
g.perl_fold_blocks = 1
g.perl_fold_anonymous_subs = 1

g.ruby_operators = 1
g.ruby_fold = 1

g.sed_highlight_tabs = 1

g.vimsyn_embed = "lPr"
g.vimsyn_folding = "afP"
-- ]]]

return M
