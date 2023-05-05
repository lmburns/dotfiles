local M = {}

local utils = require("common.utils")
local mpi = require("common.api")
local map = mpi.map
local uva = require("uva")

local env = vim.env
local o = vim.opt
local g = vim.g
local fn = vim.fn
local fs = vim.fs
local uv = vim.loop
local F = vim.F

-- env.NVIM_COC_LOG_LEVEL = "trace"
-- env.NVIM_COC_LOG_FILE = "/tmp/coc1.log"

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

_t(
    {
        -- "man",
        -- "shada",
        -- "shada_plugin",
        -- "spellfile",
        -- "spellfile_plugin",
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
        "syntax_completion",
        --
        -- "perl_provider",
        -- "python3_provider",
        "pythonx_provider",
        "python_provider",
        "ruby_provider",
        "node_provider",
        --
        "2html_plugin", -- convert to HTML
        "getscript",
        "getscriptPlugin",
        "logiPat", -- boolean logical pattern matcher
        -- "matchit",
        "matchparen",
        -- "netrw",
        -- "netrwFileHandlers",
        "netrwPlugin",
        "netrwSettings",
        "rrhelper",
        "tutor_mode_plugin",
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
        "compiler",
        "synmenu",
        -- "syntax",
        -- "optwin", -- show window of options
        -- "ftplugin",
        --
        "gzip",
        "tar",
        "tarPlugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
    }
):map(
    function(p)
        g["loaded_" .. p] = F.if_expr(p:endswith("provider"), 0, 1)
    end
)

g.did_install_default_menus = 1
g.did_install_syntax_menu = 1
-- g.do_filetype_lua = 1
-- g.did_load_filetypes = 0
-- g.did_indent_on = 1
-- g.did_load_ftplugin = 1
-- g.loaded_nvim_hlslens = 1
-- g.load_black = 1

if #fn.glob("$XDG_DATA_HOME/pyenv/shims/python3") ~= 0 then
    g.python3_host_prog = fn.glob("$XDG_DATA_HOME/pyenv/shims/python")
end

--  ╭────────────────╮
--  │ Syntax options │
--  ╰────────────────╯
g.c_gnu = 1             -- GNU gcc specific settings
g.c_syntax_for_h = 1    -- use C syntax instead of C++ for .h
g.c_space_errors = 1    -- highlight space errors
-- g.c_no_trail_space_error = 0 -- don't highlight trailing space
g.c_curly_error = 1     -- highlight missing '}'
g.c_comment_strings = 1 -- strings and numbers in comment
-- g.c_no_comment_fold = 0 -- don't fold comments
-- g.c_no_cformat = 0 -- don't highlight %-formats in strings
-- g.c_no_if0 = 0 -- don't highlight "#if 0" blocks as comments
-- g.c_no_if0_fold = 0 -- don't fold #if 0 blocks
g.c_ansi_typedefs = 1        -- do ANSI types
g.c_ansi_constants = 1       -- do ANSI constants

g.desktop_enable_nonstd = 1  -- highlight nonstd ext. of .desktop files
g.load_doxygen_syntax = 1    -- enable doxygen syntax
g.doxygen_enhanced_color = 1 -- use nonstd hl for doxygen comments

g.html_syntax_folding = 1
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
g.no_man_maps = 1

-- Do this to prevent the loading of the system fzf.vim plugin. This is
-- present at least on Arch/Manjaro/Void
o.rtp:remove("/usr/share/vim/vimfiles")
o.rtp:remove("/etc/xdg/nvim/after")
o.rtp:remove("/etc/xdg/nvim")

-- Base
env.LANG = "en_US.UTF-8"
o.shell = lb.vars.shell
o.encoding = "utf-8"
o.fileencoding = "utf-8"                                   -- utf-8 files
o.fileformat = "unix"                                      -- use unix line endings
o.fileformats = {"unix", "mac", "dos"}
o.nrformats = {"octal", "hex", "bin", "unsigned", "alpha"} -- increment / decrement

-- ================= Files ================= [[[
o.backup = false      -- backup files
o.writebackup = false -- make backup before overwriting curbuf
o.backupcopy = "yes"  -- overwrite original backup file
---@diagnostic disable-next-line: assign-type-mismatch
o.backupdir = lb.dirs.data .. "/backup/"
uva.stat(vim.o.backupdir):catch(function()
    fn.mkdir(vim.o.backupdir, "p")
end)

-- nvim.autocmd.lmb__BackupFilename = {
--     event = "BufWritePre",
--     pattern = "*",
--     command = function()
--         -- Meaningful backup name, ex: filename@2023-03-05T14
--         -- Overwrite each and keep one per day. Can add '_%M_%S'
--         o.backupext = ("@%s"):format(fn.strftime("%FT%H"))
--     end,
-- }

o.swapfile = false -- no swap files
o.history = 10000
o.undofile = true
o.undolevels = 1000
o.undoreload = 10000
---@diagnostic disable-next-line: assign-type-mismatch
o.undodir = lb.dirs.data .. "/vim-persisted-undo/"
uva.stat(vim.o.undodir):catch(function()
    fn.mkdir(vim.o.undodir, "p")
end)

---@diagnostic disable-next-line: assign-type-mismatch
o.shadafile = lb.dirs.data .. "/shada/main.shada"
o.shada = {
    "!",     -- save and restore global variables starting with uppercase
    "'1000", -- previously edited files
    "<20",   -- lines saved in each register
    "s100",  -- maximum size of an item in KiB
    "/5000", -- search pattern history
    "@1000", -- input line history
    ":5000", -- command line history
    "h",     -- disable `hlsearch` on loading
}

o.sessionoptions = {
    "globals",
    "buffers",
    "curdir",
    "tabpages",
    "winsize",
    "winpos",
    "help",
}                                   -- :mksession
o.viewoptions = {"cursor", "folds"} -- save/restore just these (with `:{mk,load}view`)
---@diagnostic disable-next-line: assign-type-mismatch
o.viewdir = lb.dirs.data .. "views"
uva.stat(vim.o.viewdir):catch(function()
    fn.mkdir(vim.o.viewdir, "p")
end)
-- ]]]

-- ============== Spell Check ============== [[[
o.completeopt = {"menuone", "noselect"}
o.complete:append({"kspell"})
o.complete:remove({"w", "b", "u", "t"})
o.spelllang:append("en_us")
o.spelloptions:append({"camel", "noplainbuffer"})
o.spellcapcheck = "" -- don't check for capital letters at start of sentence
o.spellsuggest:prepend({12})
---@diagnostic disable-next-line: assign-type-mismatch
o.spellfile = ("%s%s"):format(lb.dirs.config, "/spell/en.utf-8.add")
-- ]]] === Spell Check ===

o.magic = true     -- :h pattern-overview
o.infercase = true -- change case inference with completions
o.ignorecase = true
o.smartcase = true
o.wrapscan = true  -- searches wrap around the end of the file
o.incsearch = true -- incremental search highlight
o.inccommand = "split"

o.redrawtime = 2000  -- time it takes to redraw ('hlsearch', 'inccommand')
o.lazyredraw = false -- screen not redrawn with macros, registers
-- I like to have a differeniation between CursorHold and updatetime
-- Also, when only using updatetime, CursorHold doesn't seem to fire
g.cursorhold_updatetime = 250
o.updatetime = 2000
o.timeoutlen = 375           -- time to wait for mapping sequence to complete
o.ttimeoutlen = 50           -- time to wait for keysequence to complete used for ctrl-\ - ctrl-g

o.matchpairs:append({"<:>"}) -- pairs to highlight with showmatch -- "=:;"
o.matchtime = 5              -- ms to blink when matching brackets
o.showmatch = true           -- when inserting pair, jump to matching one

o.belloff = "all"
o.visualbell = false
o.errorbells = false
o.confirm = true -- confirm when editing readonly
o.report = 2     -- report if at least 1 line changed

o.title = true
o.titlestring = "%(%m%)%(%{expand(\"%:~\")}%)"
o.titlelen = 70
---@diagnostic disable-next-line: assign-type-mismatch
o.titleold = fs.basename(lb.vars.shell) -- This doesn't seem to work
-- o.titleold = ("%s %s"):format(fn.fnamemodify(os.getenv("SHELL"), ":t"), global.name)

-- Mouse
o.mouse = "a" -- enable mouse all modes
o.mousefocus = true
o.mousemoveevent = true
o.mousescroll = {"ver:3", "hor:6"} -- number of cols when scrolling with mouse
o.mousemodel = "popup"             -- what right-click does

o.tagfunc = "CocTagFunc"
-- exclude usetab as we do not want to jump to buffers in already open tabs
-- do not use split or vsplit to ensure we don't open any new windows
o.switchbuf = {"useopen", "uselast"}
-- change behavior of 'jumplist'
o.jumpoptions = {
    -- behave like tagstack - relloc is preserved (sumneko jumps to top clearing a bunch)
    "stack",
    "view", -- try to restore mark-view
}

o.cmdheight = 2    -- number of screen lines to use for the command-line
o.pumheight = 10   -- number of items in popup menu
o.pumblend = 3     -- make popup window translucent
o.showtabline = 2
o.synmaxcol = 300  -- do not highlight long lines
o.ruler = false
o.showmode = false -- hide file, it's in statusline
o.showcmd = true   -- show command
o.hidden = true    -- enable modified buffers in background

o.cursorline = true
o.cursorlineopt = {"number", "screenline"}
o.scrolloff = 5       -- cursor 5 lines from bottom of page
o.sidescrolloff = 10  -- minimal number of screen columns to keep to the left
o.sidescroll = 1      -- minimal number of columns to scroll horizontally
o.textwidth = 100     -- maximum width of text
o.winminwidth = 2     -- minimal width of a window, when it's not the current window
o.equalalways = false -- don't always make windows equal size
o.splitright = true
o.splitbelow = true

o.numberwidth = 4       -- minimal number of columns to use for the line number
o.number = true         -- print the line number in front of each line
o.relativenumber = true -- show the line number relative to the line with the cursor
o.signcolumn = "yes:1"

-- Fold
o.foldenable = true
-- want to add 'g;', 'g,'
o.foldopen = {
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

-- Autocompletion
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
    "node_modules/*",
}
o.wildmenu = true
o.wildmode = {"longest:full", "full"} -- Shows a menu bar as opposed to an enormous list
o.wildignorecase = true               -- ignore case when completing file names and directories
---@diagnostic disable-next-line: assign-type-mismatch
o.wildcharm = ("\t"):byte()
-- o.wildchar = fn.char2nr([[\<M-,>]])

o.cedit = "<C-c>"        -- key used to open command window on the CLI
o.virtualedit = "block"  -- allow cursor to move where there is no text in visual block mode
o.startofline = false    -- CTRL-D, CTRL-U, CTRL-B, CTRL-F, "G", "H", "M", "L", gg go to start of line

o.display = {"lastline"} -- display line instead of continuation '@@@'
o.list = true            -- display tabs and trailing spaces visually
o.listchars = {
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
o.fillchars = {
    fold = " ",
    eob = " ",       -- suppress ~ at EndOfBuffer
    diff = "╱",    -- alternatives = ⣿ ░ ─
    msgsep = " ",    -- alternatives: ‾ ─
    foldopen = "▾", --  ▽
    foldsep = "│",
    foldclose = "▸", --  ▶
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
o.cpoptions:append(
    {
        _ = true, -- do not include whitespace with 'cw'
        a = true, -- ":read" sets alternate file name
        A = true, -- ":write" sets alternate file name
        I = true, -- cursor up/down after inserting indent doesn't delete it
        -- t = true, -- search pattern for tag command is remembered for 'n'/'N'
        -- ["%"] = true, -- matching pairs inside quotes is different from outside
        M = false, -- "%" matching takes into account backslashes
        -- n = true, -- signcolumn used for wraptext
        -- q = true, -- when joining multiple lines, leave cursor position at first spot
        -- r = true, -- redo uses '/' to repeat search
    }
)

-- Helps avoid 'hit-enter' prompts (filnxtToOF)
o.shortmess:append("a") -- enable shorter flags ('filmnrwx')
o.shortmess:append("c") -- don't give ins-completion-menu messages
o.shortmess:append("s") -- don't give "search hit BOTTOM
o.shortmess:append("I") -- don't give the intro message when starting Vim
o.shortmess:append("S") -- do not show search count message when searching (HLSLens)
o.shortmess:append("T") -- truncate messages if they're too long

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
o.whichwrap = {
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
o.formatoptions:append(
    {
        ["1"] = true, -- don't break a line after a one-letter word; break before
        -- ["2"] = false, -- use indent from 2nd line of a paragraph
        q = true,     -- format comments with gq"
        n = true,     -- recognize numbered lists. Indent past formatlistpat not under
        M = true,     -- when joining lines, don't insert a space before or after a multibyte char
        j = true,     -- remove a comment leader when joining lines.
        -- Only break if the line was not longer than 'textwidth' when the insert
        -- started and only at a white character that has been entered during the
        -- current insert command.
        l = true,
        v = false,    -- only break line at blank line I've entered
        c = false,    -- auto-wrap comments using textwidth
        t = false,    -- autowrap lines using text width value
        p = true,     -- don't break lines at single spaces that follow periods
        r = false,    -- continue comments when pressing Enter
        o = false,    -- automatically insert comment leader after 'o'/'O'
        ["/"] = true, -- when 'o' included: don't insert comment leader for // comment after statement
    }
)

-- recognize list header ('n' flag in 'formatoptions')
-- o.formatlistpat = [[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\+\)\s*]]
o.formatlistpat =
[==[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\+\)\s*\|^\[^\ze[^\]]\+\]:]==]
-- o.formatlistpat=^\s*\w\+[.\)]\s\+\|^\s*[-+*]\+\s\+

-- Indenting
local indent = 2
o.shiftwidth = indent                    -- # of spaces to use for each step
o.tabstop = indent                       -- # of spaces a <Tab> in the file counts for
o.softtabstop = indent                   -- # of spaces a <Tab> counts for while editing
o.expandtab = true                       -- use the appropriate number of spaces to insert a <Tab>
o.smarttab = true                        -- line start insert blanks equal to 'sw'. 'ts'/'sts' for other places
o.shiftround = true                      -- round </> indenting
o.backspace = {"indent", "eol", "start"} -- <BS>, <Del>, CTRL-W and CTRL-U in insert

-- o.indentexpr = "nvim_treesitter#indent()" -- (overrules 'smartindent', 'cindent')
o.autoindent = true  -- copy indent from current line when starting a new line (<CR>, o, O)
o.smartindent = true -- smart autoindenting when starting a new line (C-like progs)
o.cindent = true     -- automatic C program indenting
-- o.copyindent = true -- copy structure of existing lines indent when autoindenting a new line
-- o.preserveindent = true -- preserve most indent structure as possible when reindenting line
o.showbreak = [[↳ ]] -- ↪  ⌐
o.breakindent = true -- each wrapped line will continue same indent level
-- settings of 'breakindent'
o.breakindentopt = {
    "sbr",         -- display 'showbreak' value before applying indent
    "list:2",      -- add additional indent for lines matching 'formatlistpat'
    "min:20",      --- min width kept after breaking line
    "shift:2",     -- all lines after break are shifted N
}
o.linebreak = true -- lines wrap at words rather than random characters
-- which chars cause break with 'linebreak'
-- vim.o.breakat = "  !@*-+;:,./?"
-- o.breakat = {
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
-- o.comments = {
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

o.cinoptions = {
    ">1s", -- any: amount added for "normal" indent
    "L0",  -- placement of jump labels
    "=1s", -- ? case: statement after case label: N chars from indent of label
    "l1",  -- N!=0 case: align w/ case label instead of statement after it on same line
    "b1",  -- N!=0 case: align final "break" w/ case label so it looks like block (0=break cinkeys)
    "g1s", -- ? C++ scope decls: N chars from indent of block they're in
    "h1s", -- ? C++: after scope decl: N chars from indent of label
    "N0",  -- ? C++: inside namespace: N chars extra
    "E0",  -- ? C++: inside linkage specifications: N chars extra
    "p1s", -- ? K&R: function decl: N chars from margin
    "t0",  -- K&R: return type of function decl: N chars from margin
    "i1s", -- ? C++: base class decl/constructor init if they start on newline
    "+0",  -- line continuation: N chars extra inside function; 2*N outside func if line end = '\'
    "c1s", -- comment lines: N chars from comment opener if no other text to align with
    "(1s", -- inside unclosed paren: N chars from line ('sw' for every unclosed paren)
    "u1s", -- same as (N but one level deeper
    "U1",  -- N!=0 : do not ignore nested parens that are on line by themselves
    -- "wN", "WN" --
    "k1s", -- unclosed paren in 'if' 'for' 'while' override '(N'
    "m1",  -- N!=0 line up line starting w/ closing paren w/ 1st char of line w/ opening
    "j1",  -- java: anon classes
    "J1",  -- javascript: object classes
    ")40", -- search for parens N lines away
    "*70", -- search for unclosed comments N lines away
    "#0",  -- N!=0 recognized '#' comments otherwise preproc (toggle this for files)
    "P1",  -- N!=0 format C pragmas
}

-- keys in insert mode that cause reindenting of current line 'cinkeys-format'
-- 0#
-- o.cinkeys = {"0{", "0}", "0)", "0]", ":", "!^F", "o", "O", "e"}

o.diffopt = o.diffopt + {
    "vertical",
    "iwhite",
    "hiddenoff",
    "foldcolumn:0",
    "context:4",
    "algorithm:patience",
    "indent-heuristic",
    -- "linematch:60"
}

---@diagnostic disable-next-line: assign-type-mismatch
o.grepprg = utils.list(
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
        "--glob='!node_modules'",
    }, " "
)
-- o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
o.grepformat:prepend({"%f:%l:%c:%m"})

-- o.secure = true -- Disable autocmd etc for project local vimrc files.
-- o.exrc = true -- allow project local vimrc files example .nvimrc see :h exrc
-- o.autoread = true
o.autowriteall = true -- automatically :write before running commands and changing files

-- ================== Gui ================== [[[
o.background = "dark"
o.termguicolors = true
-- o.guioptions:remove({ "m", "r", "l" })
g.guitablabel = "%M %t"
o.guicursor = {
    [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]],
    [[a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]],
    [[sm:block-blinkwait175-blinkoff150-blinkon175]],
}
o.guifont = [[FiraCode Nerd Font Mono:h13]]
o.emoji = false

if fn.exists("g:neovide") then
    map("n", "<C-p>", "\"+p")
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
end

o.clipboard:append("unnamedplus")
g.clipboard = clipboard
-- ]]] === Clipboard ===

-- if nvim.executable("nvr") then
--     env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- --     env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
-- end

env.MANWIDTH = 80

---Notify with nvim-notify if nvim is focused,
---Otherwise send a desktop notification.
g.nvim_focused = true
g.treesitter_refactor_maxlines = 10 * 1024
g.treesitter_highlight_maxlines = 12 * 1024
g.editorconfig = true

return M
