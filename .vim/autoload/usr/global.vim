func! usr#global#setup() abort
    let s:vars = #{
        \  rc: $MYVIMRC,
        \  shell: $SHELL,
        \  pid: getpid(),
        \  hostname: hostname(),
        \ }

    let s:dirs = #{
        \  home:   expand('$HOME'),
        \  config: expand('$VIMHOME'),
        \  tmp:    expand('$TMPDIR'),
        \  zdot:   expand('$ZDOTDIR'),
        \  xdg: #{
        \    config:  expand('$XDG_CONFIG_HOME'),
        \    cache:   expand('$XDG_CACHE_HOME'),
        \    data:    expand('$XDG_DATA_HOME'),
        \    state:   expand('$XDG_STATE_HOME'),
        \    desktop: expand('$XDG_DESKTOP_DIR'),
        \    docs:    expand('$XDG_DOCUMENTS_DIR'),
        \    project: expand('$XDG_PROJECT_DIR'),
        \    test:    expand('$XDG_TEST_DIR'),
        \    bin:     expand('$XDG_BIN_DIR'),
        \    run:     expand('$XDG_RUNTIME_DIR'),
        \  },
        \  opt: #{},
        \ }

    let s:dirs.vim = s:dirs.config

    let s:dirs.plugs = s:dirs.config .. '/bundles'
    let s:dirs.cache = s:dirs.xdg.cache .. '/vim'
    let s:dirs.data = s:dirs.xdg.data .. '/vim'
    let s:dirs.state = s:dirs.xdg.state .. '/vim'
    let s:dirs.log = s:dirs.state
    let s:dirs.run = s:dirs.xdg.run

    let s:dirs.opt.backup = s:dirs.data .. '/backup'
    let s:dirs.opt.undo = s:dirs.opt.backup .. '/undo'
    let s:dirs.opt.view = s:dirs.opt.backup .. '/view'
    let s:dirs.opt.session = s:dirs.opt.backup .. '/session'
    let s:dirs.opt.directory = s:dirs.opt.backup .. '/swap'
    let s:dirs.opt.spell = s:dirs.opt.backup .. '/spell'
    let s:dirs.opt.viminfo = s:dirs.data .. '/viminfo'

    " \ home: $'{$VIMHOME}/.vim'
    let g:Rc = #{
        \  loaded: 0,
        \  home: s:dirs.config,
        \  started_at: getcwd(),
        \  is_ivim: has('ivim'),
        \  is_tmux: exists('$TMUX'),
        \  meta: s:vars,
        \  dirs: s:dirs,
        \  blacklist: #{},
        \ }

    let g:Rc.blacklist.ft = [
        \ "",
        \ "nofile",
        \ "alpha",
        \ "bufferize",
        \ "checkhealth",
        \ "coc-explorer",
        \ "coc-list",
        \ "coctree",
        \ "comment",
        \ "commit",
        \ "conf",
        \ "diff",
        \ "dirdiff",
        \ "floaterm",
        \ "floatline",
        \ "floggraph",
        \ "fugitive",
        \ "fugitiveblame",
        \ "fzf",
        \ "git",
        \ "git-log",
        \ "git-status",
        \ "gitcommit",
        \ "gitconfig",
        \ "gitrebase",
        \ "gitrebase",
        \ "gitsendemail",
        \ "godoc",
        \ "help",
        \ "hgcommit",
        \ "list",
        \ "log",
        \ "man",
        \ "minimap",
        \ "neoterm",
        \ "neotest-summary",
        \ "netrw",
        \ "norg",
        \ "org",
        \ "Outline",
        \ "prompt",
        \ "qf",
        \ "quickmenu",
        \ "rebase",
        \ "registers",
        \ "scratchpad",
        \ "startify",
        \ "startuptime",
        \ "svn",
        \ "toggleterm",
        \ "undotree",
        \ "vim-plug",
        \ "vista",
        \ "VistaFloatingWin",
        \ "WhichKey",
        \ ]

    let g:Rc.blacklist.bufname = [
        \ "\\[No Name\\]",
        \ "\\[Command Line\\]",
        \ "\\[Scratch\]",
        \ "\\[Wilder Float \\d\\]",
        \ "\\[Wilder Popup \\d\\]",
        \ "\\[Quickfix List\\]",
        \ "Bufferize:",
        \ "NetrwMessage",
        \ "__coc_refactor__\\d\\d\\?",
        \ "://.*",
        \ "fugitive://.*",
        \ "gitsigns://.*",
        \ "man://.*",
        \ "option-window",
        \ ]
endf
