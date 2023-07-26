local M = {}

local uva = require("uva")
local lib = Rc.lib
local F = Rc.F
local utils = Rc.shared.utils

local map = Rc.api.map

local env = vim.env
local o = vim.o
local opt = vim.opt
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd

g.mapleader = [[ ]]
g.maplocalleader = [[,]]

-- env.NVIM_COC_LOG_FILE = "/tmp/coc1.log"
-- env.NVIM_COC_LOG_LEVEL = "TRACE"
-- env.NVIM_PYTHON_LOG_FILE = "/tmp/nvim_log"
-- env.NVIM_PYTHON_LOG_LEVEL = "DEBUG"

-- o.debug = "msg"
-- o.redrawdebug = ""
-- o.writedelay = 2
-- o.verbosefile = ""
-- o.errorfile = "" -- quickfix file
-- o.makeef = ""    -- :make file

-- === Path ===============================================================
function M.path()
    opt.path:append({
        "**",
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
end

-- === BASE ===============================================================
function M.base()
    env.LANG = "en_US.UTF-8"
    o.shell = Rc.meta.shell
    o.encoding = "utf-8"                     -- string-encoding used internally
    o.fileencoding = "utf-8"                 -- file-encoding for current buffer
    opt.fileencodings = {"ucs-bom", "utf-8", "default", "latin1"}
    o.fileformat = "unix"                    -- use unix line endings
    opt.fileformats = {"unix", "mac", "dos"} -- EOL formats to try
    opt.nrformats = {"octal", "hex", "bin", "unsigned", "alpha"}
    opt.isfname:append(":")
end

-- === Files ==============================================================
function M.files()
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

    o.viewdir = Rc.dirs.data .. "views"
    uva.stat(o.viewdir):catch(function()
        fn.mkdir(o.viewdir, "p")
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
        -- ignore these paths
        "r/tmp/",
        "r/private/",
        "r/dev/shm/",
        "r/mnt/",
        "rtemp://",
        "rterm://",
        "rfugitive://",
        "rgitsigns://",
        "rman://",
        "rhealth://",
        "rzipfile://",
    }

    o.browsedir = "buffer" -- use the directory of the related buffer
    -- save/restore just these (with `:{mk,load}view`)
    opt.viewoptions = {"cursor", "folds"}
    opt.sessionoptions = { -- changes behavior of `:mksession`
        "buffers",         -- hidden/unloaded buffers
        "curdir",          -- current directory
        "folds",           -- manually created folds
        "globals",         -- global variables (str/int types)
        "help",            -- help window
        "localoptions",    -- local options/mappings
        "options",         -- all options/mappings
        "tabpages",        -- all tabpages
        "winpos",          -- position of whole vim window
        "winsize",         -- window sizes
    }
end

-- === BEHAVIOR ===========================================================
function M.behavior()
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
    o.updatecount = 0              -- don't write swap file
    o.redrawtime = 2000            -- time it takes to redraw ('hlsearch', 'inccommand')
    o.timeoutlen = 375             -- wait time for map sequence to complete
    o.ttimeoutlen = 50             -- wait time for keycode to complete
    o.lazyredraw = true            -- screen not redrawn with macros, registers

    opt.matchpairs:append({"<:>"}) -- pairs to highlight with showmatch -- "=:;"
    o.matchtime = 2                -- ms to blink when matching brackets
    o.showmatch = true             -- when inserting pair, jump to matching one -- NOTE: maybe change

    -- ━━━━ Mouse ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    o.mouse = "a" -- enable mouse all modes
    o.mousefocus = true
    o.mousemoveevent = true
    o.mousehide = true
    o.mousemodel = "popup" -- right click behavior
    opt.mousescroll = {"ver:3", "hor:6"}

    o.cedit = "<C-c>"         -- key used to open command window on the CLI
    o.selectmode = ""         -- when select mode is used -- mouse
    o.selection = "inclusive" -- select can go 1 past EOL
    o.virtualedit = "block"   -- allow cursor to move where there's no text in V-mode
    o.startofline = false     -- CTRL-D, CTRL-U, CTRL-B, CTRL-F, "G", "H", "M", "L", gg go to start of line

    -- ━━━━ Warnings ━━━━━━━━━━━━━━━━━━━━━━━━━━
    o.belloff = "all"    -- disable all bells
    o.visualbell = false -- disable visual bells
    o.errorbells = false -- disable error bells
    o.report = 2         -- report if at least 1 line changed
    o.confirm = true     -- confirm when leaving buffer
    o.warn = true        -- notify about buffer changes outside of vim
    o.autoread = false   -- auto reload if changed outside vim (autocmd for this)
    -- o.autowrite = true    -- auto :write before running commands & changing files
    -- o.autowriteall = true -- auto :write for all buffers
    -- o.autochdir = true    -- change current directory to fn.expand('%:p:h')
    -- o.exrc = nvim.has("nvim-0.9") -- exec .nvimrc/.exrc in current dir

    -- Vi-compatible options
    opt.cpoptions:append({
        _ = true, -- do not include whitespace with 'cw'
        a = true, -- ":read" sets alternate filename
        A = true, -- ":write" sets alternate filename
        -- f = true,      -- ":read" sets filename if buf doesn't have it
        -- F = true,      -- ":write" sets filename if buf doesn't have it
        -- d = true,      -- "./" in tags means tag file current directory
        I = true,  -- up/down after inserting indent doesn't delete it
        -- R = false,     -- filtered lines keep marks
        M = false, -- "%" matching takes into account backslashes
        -- ["%"] = false, -- matching pairs inside quotes is different from outside
        -- m = true, -- showmatch always waits half a second
        -- t = true, -- search pattern for tag command is remembered for 'n'/'N'
        -- n = true, -- signcolumn used for wraptext
        -- q = true, -- when joining multiple lines, leave cursor position at first spot
        -- r = true, -- redo uses '/' to repeat search
    })

    -- Helps avoid 'hit-enter' prompts (filnxtToOF)
    opt.shortmess:append("a") -- enable shorter flags ('filmnrwx')
    opt.shortmess:append("s") -- don't give "search hit BOTTOM
    opt.shortmess:append("I") -- don't give the intro message when starting Vim
    opt.shortmess:append("S") -- do not show search count message when searching (HLSLens)
    opt.shortmess:append("T") -- truncate messages if they're too long
    opt.shortmess:append("c") -- don't give ins-completion-menu messages
    opt.shortmess:remove("C") -- don't give msg scanning for ins-completion items

    -- ━━━━ Typing ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
    o.joinspaces = false -- prevent inserting two spaces with J

    -- recognize list header ('n' flag in 'formatoptions')
    o.formatlistpat = [==[^\s*\%(\d\+[\]:.)}\t ]\|[-*+]\+\)\s*\|^\[^\ze[^\]]\+\]:]==]
    opt.formatoptions:append({
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
        v = false,                 -- only break line at blank line I've entered
        c = false,                 -- auto-wrap comments using textwidth
        t = false,                 -- autowrap lines using text width value
        p = true,                  -- don't break lines at single spaces that follow periods
        ["/"] = true,              -- when 'o' included: don't insert comment leader for // comment after statement
        r = lib.fn.set_formatopts, -- continue comments when pressing Enter
        o = lib.fn.set_formatopts, -- auto insert comment leader after 'o'/'O'
    })

    -- ━━━━ Indenting ━━━━━━━━━━━━━━━━━━━━━━━━━
    local indent = 4
    o.shiftwidth = indent                      -- # of spaces to use for each step
    o.tabstop = indent                         -- # of spaces a <Tab> in the file counts for
    o.softtabstop = indent                     -- # of spaces a <Tab> counts for while editing
    o.expandtab = true                         -- use the appropriate number of spaces to insert a <Tab>
    o.smarttab = true                          -- line start insert blanks equal to 'sw'. 'ts'/'sts' for other places
    o.shiftround = true                        -- round </> indenting
    opt.backspace = {"indent", "eol", "start"} -- <BS>, <Del>, CTRL-W and CTRL-U in insert

    -- o.copyindent = true -- copy structure of existing lines indent when autoindenting a new line
    -- o.preserveindent = true -- preserve most indent structure as possible when reindenting line
    -- o.indentexpr = "nvim_treesitter#indent()" -- (overrules 'smartindent', 'cindent')
    -- Priority: indentexpr > cindent > smartindent

    o.autoindent = true    -- copy indent from current line when starting a new line (<CR>, o, O)
    o.smartindent = true   -- smart autoindenting when starting a new line (C-like progs)
    o.cindent = true       -- automatic C program indenting
    o.showbreak = [[↳ ]] -- ↪  ⌐
    o.linebreak = true     -- lines wrap at words rather than random characters
    o.breakindent = true   -- each wrapped line will continue same indent level
    opt.breakindentopt = { -- settings of 'breakindent'
        "sbr",             -- display 'showbreak' value before applying indent
        "list:2",          -- add additional indent for lines matching 'formatlistpat'
        "min:20",          -- min width kept after breaking line
        "shift:2",         -- all lines after break are shifted N
    }
end

-- === VIEW ===============================================================
function M.view()
    o.previewheight = math.floor(o.lines / 3)    -- height of preview window (:ptag)
    o.cmdheight = 2                              -- height (screenlines) of command-line
    o.pumheight = 10                             -- number of items in popup menu
    o.pumblend = 3                               -- make popup window translucent
    o.showtabline = 2                            -- always show tabline
    o.laststatus = 3                             -- global statusline
    o.synmaxcol = 300                            -- do not highlight long lines (longer than 300)
    o.ruler = false                              -- cursor position is in statusline
    o.showmode = false                           -- hide mode, it's in statusline
    o.showcmd = true                             -- show command (noice does it)
    o.hidden = true                              -- enable modified buffers in background
    o.more = true

    opt.cursorlineopt = {"number", "screenline"} -- highlight number and screenline
    o.cursorline = true
    o.smoothscroll = true                        -- ctrl-e ctrl-y
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
    o.relativenumber = true -- show the line number relative to the line with the cursor
    o.signcolumn = "yes:1"
    -- o.colorcolumn = "+1"
    -- o.statuscolumn = "%C %s %r %l"
    -- o.statuscolumn = "%C%=%s%=%{v:relnum?v:relnum:v:lnum}"

    o.title = true
    o.titlestring = "%(%m%)%(%{expand(\"%:~\")}%)"
    o.titlelen = 70
    o.titleold = fn.fnamemodify(Rc.meta.shell, ":t")

    o.conceallevel = 2
    o.concealcursor = "c"
    o.list = true          -- display tabs and trailing spaces visually
    opt.listchars = {
        eol = nil,
        tab = "‣ ",
        trail = "•",
        precedes = "«",
        extends = "…", -- »
        nbsp = "␣",
        -- leadmultispace = "---+"
    }

    o.display = "lastline" -- display line instead of continuation '@@@'
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
end

-- === FOLD ===============================================================
function M.fold()
    o.foldenable = true -- enable folding
    opt.foldopen = {
        -- want to add 'g;', 'g,'
        -- "jump", "insert",
        -- "hor",
        "block",
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
end

-- === COMPLETION =========================================================
function M.completion()
    -- ━━━━ Spell Checking ━━━━━━━━━━━━━━━━━━━━
    opt.completeopt = {"menuone", "noselect"}
    opt.complete:append("kspell")
    opt.complete:remove({"w", "b", "u", "t", "i"})
    opt.spelllang:append({"en_us"})
    opt.spelloptions:append({"camel", "noplainbuffer"})
    opt.spellcapcheck = "" -- don't check for capital letters at start of sentence
    opt.spellsuggest:prepend({12})
    o.spellfile = Rc.dirs.config .. "/spell/en.utf-8.add"

    -- ━━━━ Autocompletion ━━━━━━━━━━━━━━━━━━━━
    -- o.showfulltag = true
    o.menuitems = 30
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
    opt.suffixes:append({".aux", ".log", ".dvi", ".bbl", ".blg", ".brf", ".cb", ".ind", ".idx",
        ".ilg",
        ".inx", ".out", ".toc", ".o", ".obj", ".dll", ".class", ".pyc", ".ipynb", ".so", ".swp",
        ".zip",
        ".exe", ".jar", ".gz",})
end

-- === MISC ===============================================================
function M.misc()
    o.includeexpr = [=[substitute(v:fname, '^[^\\/]*/', '', 'g')]=]
    o.tagfunc = "CocTagFunc"
    -- exclude usetab as we do not want to jump to buffers in already open tabs
    -- do not use split or vsplit to ensure we don't open any new windows
    opt.switchbuf = {"useopen", "uselast"}
    -- change behavior of 'jumplist'
    opt.jumpoptions = {"stack", "view" --[[try to restore mark-view]]}

    opt.diffopt = {
        "algorithm:histogram",
        "internal",
        "indent-heuristic",
        "filler",
        "closeoff",
        "iwhite",
        "vertical",
        "linematch:100",
    }

    if utils.executable("rg") then
        o.grepprg = _j({
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
        }):concat(" ")
        opt.grepformat:prepend({"%f:%l:%c:%m", "%f:%l:%m"})
        -- o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
    end
end

-- === CLIPBOARD ==========================================================
function M.clipboard()
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
end

-- === GUI ================================================================
function M.gui()
    o.background = "dark"
    o.termguicolors = true
    o.emoji = false
    g.guitablabel = "%M %t"
    opt.guicursor = {
        [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]],
        [[a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor]],
        [[sm:block-blinkwait175-blinkoff150-blinkon175]],
    }
    o.guifont = [[FiraCode Nerd Font Mono:h13]]

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
end

-- === Digraphs ===========================================================
function M.digraphs()
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
end

-- === Other ==============================================================

-- === PRELOAD ============================================================
local function set_variables()
    o.pyxversion = 3
    if #fn.glob("$XDG_DATA_HOME/pyenv/shims/python3") ~= 0 then
        g.python3_host_prog = fn.glob("$XDG_DATA_HOME/pyenv/shims/python")
    end

    env.MANWIDTH = 80

    ---Notify with nvim-notify if nvim is focused, otherwise send a desktop notification.
    g.nvim_focused = true

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
end

local function set_loaded()
    g.editorconfig = false
    g.skip_defaults_vim = 1
    g.skip_loading_mswin = 1
    g.did_install_default_menus = 1
    g.did_install_syntax_menu = 1
    g.did_menu_trans = 1
    g.did_toolbar_tmenu = 1
    g.no_buffers_menu = 1
    -- g.do_no_lazyload_menus = 1
    -- g.do_filetype_lua = 1
    -- g.did_load_filetypes = 0
    -- g.did_load_ftplugin = 1
    -- b.did_ftplugin = ""
    -- g.did_load_polyglot = 1
    -- g.did_setup_compilers = 1
    -- g.current_compiler = ""
    -- g.did_indent_on = 1
    -- b.did_indent = 1
    -- g.syntax_on = 1
    -- b.current_syntax = ""

    -- b.man_default_sects = "3,2"

    -- g.loaded_man = 1
    -- g.loaded_less = 1
    -- g.load_black = 1

    -- g.loaded_nvim_treesitter = 1
    -- g.loaded_targets = 1
    -- g.loaded_sandwich = 1
    -- g.loaded_textobj_sandwich = 1
    -- g.loaded_operator_sandwich = 1
    -- g.matchup_enabled = 1
    -- g.loaded_neoformat = 1
    -- g.loaded_nvim_hlslens = 1
    -- g.loaded_devicons = 1
    -- g.loaded_floaterm = 1
    -- g.loaded_telescope = 1
    -- g.loaded_browser_bookmarks = 1
    -- g.indent_blankline_enabled = 0
    -- g.loaded_indent_blankline = 1
    -- g.loaded_specs = 1
    -- g.loaded_marks = 1
    -- g.loaded_vista = 1
    -- g.loaded_redact_pass = 1
    -- g.loaded_close_buffers = 1
    -- g.loaded_rhubarb = 1
    -- g.loaded_coc_fzf = 1
    -- g.did_coc_loaded = 1
    -- g.gutentags_dont_load = 1
    -- g.vimtex_enabled = 1
    -- g.registers_migration_loaded = 1

    -- g.did_cobol_ftplugin_functions = 1
    -- g.did_ruby_ftplugin_functions = 1
    -- g.did_changelog_ftplugin = 1
    -- g.did_ocaml_switch = 1

    -- g.ftplugin_sql_statements = 1
    -- g.ftplugin_sql_objects = 1
    -- g.ftplugin_sql_omni_key_left = 1

    _t({
        -- "less",
        "manpager_plugin",
        -- "man",
        -- "shada",
        -- "shada_plugin",
        -- "fzf",
        -- "health",
        -- "spell",
        -- "spellfile",
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
        "rubycomplete_rails",
        "sqlcomplete",
        "vimexpect",
        "xmlcomplete",
        "xmlformat",
        "dbext",
        "sql_completion",
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
        "matchit",
        -- "matchparen",
        -- "netrw",
        -- "netrwFileHandlers",
        -- "netrwPlugin",
        -- "netrwSettings",
        "rrhelper",
        "tutor_mode_plugin",
        "dvorak_plugin",
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
    }):map(function(p)
        g["loaded_" .. p] = F.if_expr(p:endswith("provider"), 0, 1)
    end)

    -- Prevents loading termdebug
    Rc.api.command("TermDebug", "echo 'Empty'", {nargs = 0})
end

local function plug_maps()
    g.no_man_maps = 1
    g.no_plugin_maps = 1
    g.no_markdown_maps = 1
    g.no_changelog_maps = 1
    g.no_csv_maps = 1
    g.no_cobol_maps = 1
    g.no_cucumber_maps = 1
    g.no_context_maps = 1
    g.context_mappings = 0
    g.no_eiffel_maps = 1
    g.no_gitcommit_commands = 1
    g.no_gitrebase_maps = 1
    g.no_gprof_maps = 1
    g.no_j_maps = 1
    g.no_lprolog_maps = 1
    g.no_mail_maps = 1
    g.no_ocaml_maps = 1
    g.no_pdf_maps = 1
    g.no_php_maps = 1
    g.no_pod_maps = 1
    g.no_python_maps = 1
    g.no_racket_maps = 1
    g.no_ruby_maps = 1
    g.no_spec_maps = 1
    g.omni_sql_no_default_maps = 1
    g.no_vb_maps = 1
    -- g.no_vim_maps = 1
    g.no_zimbu_maps = 1
    g.llvm_ext_no_mapping = 1
end

function M.preload()
    plug_maps()
    set_variables()
    set_loaded()
end

-- === NETRW ==============================================================
local function plug_netrw()
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
end

function M.plugs()
    plug_netrw()
end

-- === SYNTAX =============================================================
local function syntax_builtin()
    g.c_syntax_for_h = 1         -- use C syntax instead of C++ for .h
    g.c_gnu = 1                  -- GNU gcc specific settings
    -- g.c_autodoc = 1              -- extra autodoc parsing
    g.c_comment_strings = 1      -- strings and numbers in comment
    g.c_ansi_typedefs = 1        -- do ANSI types
    g.c_ansi_constants = 1       -- do ANSI constants

    g.c_no_if0 = 1               -- don't highlight "#if 0" blocks as comments
    g.c_no_if0_fold = 1          -- don't fold #if 0 blocks
    g.c_no_comment_fold = 1      -- don't fold comments

    -- g.c_space_errors = 0         -- highlight space errors
    -- g.c_curly_error = 0          -- highlight missing '}'
    -- g.c_no_trail_space_error = 0 -- don't highlight trailing space
    -- g.c_no_cformat = 0           -- don't highlight %-formats in strings

    -- g.cpp_no_function_highlight = 1        -- disable function highlighting
    -- g.cpp_simple_highlight = 1             -- highlight all standard C keywords with `Statement`
    -- g.cpp_named_requirements_highlight = 1 -- enable highlighting of named requirements

    -- g.load_doxygen_syntax = 0              -- enable doxygen syntax
    -- g.doxygen_enhanced_color = 0           -- use nonstd hl for doxygen comments

    g.nroff_is_groff = 1
    g.nroff_space_errors = 1
    -- b.preprocs_as_sections = 1

    -- g.perl_no_scope_in_variables = 0 -- don't hl pkgname differently in '$PkgName::Var'
    -- g.perl_no_extended_vars = 0 -- don't hl complex variables
    -- g.perl_string_as_statement = 1 -- highlight string different if 2 on same line
    g.perl_fold = 0
    -- g.perl_fold_blocks = 1
    -- g.perl_fold_anonymous_subs = 1
    -- g.ruby_operators = 1
    g.ruby_fold = 0
    g.vim_json_conceal = 0  -- disable json concealment
    g.vim_json_warnings = 0 -- disable highlight warnings
    g.vimsyn_embed = "lPr"
    g.vimsyn_folding = "afP"

    g.ft_man_folding_enable = 0
    g.markdown_folding = 0
    g.meson_recommended_style = 0
    g.python_recommended_style = 0
    g.yaml_recommended_style = 0
    g.html_syntax_folding = 0 -- don't use html syntax folding
    g.rst_fold_enabled = 0
    g.rst_style = 0

    g.asmsyntax = "asm"
    -- g.filetype_cfg = ""
    g.zig_fmt_parse_errors = 1
    g.zig_fmt_autosave = 0
    g.pyindent_searchpair_timeout = 1
    g.pyindent_disable_parentheses_indenting = true
    g.rubycomplete_rails = 0
    g.spellfile_URL = ""

    g.sed_highlight_tabs = 1
    g.lifelines_deprecated = 1 -- hl deprecated funcs as errors
    -- g.desktop_enable_nonstd = 0            -- highlight nonstd ext. of .desktop files
end

-- === NON-BUILTIN ==========================
local function syntax_other()
    g.vim_jsx_pretty_disable_js = 1
    g.vim_jsx_pretty_disable_tsx = 1
    -- g.vim_jsx_pretty_colorful_config = 1
    -- g.vim_jsx_pretty_template_tags = "jsx"
    -- g.llvm_extends_official = 0
end

function M.syntax()
    syntax_builtin()
    syntax_other()
end

-- === FORMAT OPTIONS =====================================================
function M.formatoptions()
    vim.opt_local.formatoptions:append({
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
        v = false,                 -- only break line at blank line I've entered
        c = false,                 -- auto-wrap comments using textwidth
        t = false,                 -- autowrap lines using text width value
        p = true,                  -- don't break lines at single spaces that follow periods
        ["/"] = true,              -- when 'o' included: don't insert comment leader for // comment after statement
        r = lib.fn.set_formatopts, -- continue comments when pressing Enter
        o = lib.fn.set_formatopts, -- auto insert comment leader after 'o'/'O'
    })
end

M.preload()
M.clipboard()
M.path()
M.base()
M.behavior()
M.view()
M.files()
M.fold()
M.misc()
M.gui()

vim.defer_fn(function()
    M.completion()
    M.plugs()
    M.syntax()
    -- M.formatoptions()
    vim.defer_fn(function()
        M.digraphs()
    end, 200)
end, 200)

return M
