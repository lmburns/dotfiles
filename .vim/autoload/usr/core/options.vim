func! usr#core#options#setup() abort
  " === Base ================================================================ [[[
  " :h modifyOtherKeys
  " https://superuser.com/questions/121568/mapping-left-alt-key-in-vim
  let &t_TI = "\<Esc>[>4;2m"
  let &t_TE = "\<Esc>[>4;m"
  " Enables FocusLost/Gained
  let &t_fe = "\<Esc>[?1004h"
  let &t_fd = "\<Esc>[?1004l"

  set path+=**,/usr/include
  set shell=$SHELL
  set fileformat=unix
  set fileformats=unix,dos
  set nrformats=hex,bin,unsigned,alpha
  set langmenu=en_US
  set suffixes+=.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
      \,.o,.obj,.dll,.class,.pyc,.ipynb,.so,.swp,.zip,.exe,.jar,.gz
  set suffixesadd=.java,.cs,.rs,.go,.zsh,.pl,.py,.rb
  " ]]]

  " === Files =============================================================== [[[
  set browsedir=buffer
  set nobackup
  set nowritebackup
  set noswapfile
  let &directory=g:Rc.dirs.opt.directory
  let &backupdir=g:Rc.dirs.opt.backup

  " UndoHistory: store undo history in a file. even after closing and reopening vim
  if has('persistent_undo')
    if !isdirectory(g:Rc.dirs.opt.undo)
      call mkdir(g:Rc.dirs.opt.undo, 'p', 0700)
    endif

    let &undodir=g:Rc.dirs.opt.undo
    set undofile
    set undolevels=1000
    set undoreload=10000
  endif

  if exists('+viminfo')
    let &viminfofile=g:Rc.dirs.opt.viminfo
    set viminfo=!,'1000,/5000,:5000,<20,@1000,h,s100,r/tmp,r/run,rterm://,rfugitive://,rman://,rtemp://
  end

  if exists('+viewdir')
    if !isdirectory(g:Rc.dirs.opt.view)
      call mkdir(g:Rc.dirs.opt.view, 'p', 0700)
    endif

    let &viewdir=g:Rc.dirs.opt.view
    set viewoptions=cursor,folds

    if !isdirectory(g:Rc.dirs.opt.session)
      call mkdir(g:Rc.dirs.opt.session, 'p', 0700)
    endif

    set sessionoptions=globals,buffers,curdir,tabpages,winsize,winpos,help
    " let &sessiondir=g:Rc.sessiondir
  end

  " set autowriteall
  " set autochdir
  " set secure
  " set exrc
  " set autoread
  " ]]]

  " === Spellcheck ========================================================== [[[
  set completeopt+=menuone,preview,noselect
  set complete+=kspell
  set complete-=w,b,u,t
  set spelllang=en_us
  set spelloptions+=camel
  set spellcapcheck=''
  set spellsuggest^=10
  if !isdirectory(g:Rc.dirs.opt.spell)
    call mkdir(g:Rc.dirs.opt.spell, 'p', 0700)
  endif
  let &spellfile=g:Rc.dirs.opt.spell . '/en.utf-8.add'
  " ]]]

  set magic
  set infercase
  set ignorecase
  set smartcase
  set wrapscan           " searches wrap around the end of the file
  set incsearch          " incremental search highlight
  set hlsearch

  set lazyredraw         " screen not redrawn with macros, registers
  set updatetime=2000
  set redrawtime=2000    " time it takes to redraw ('hlsearch', 'inccommand')

  if !g:Rc.is_ivim
    set timeoutlen=375     " time to wait for mapping sequence to complete
    set ttimeoutlen=50     " time to wait for keysequence to complete used for ctrl-\ - ctrl-g
  endif

  set confirm            " confirm when editing readonly
  set report=2           " report if at least 1 line changed

  set belloff=all
  set novisualbell
  set noerrorbells
  set t_vb=

  set title
  set titlelen=70
  set titlestring=%(%m%)%(%{expand(\"%:~\")}%)
  let &titleold=fnamemodify(&shell, ':t')

  if has('mouse')
    set mouse=a
    set mousefocus
    set mousemoveevent
    set mousemodel=popup

    if !has('nvim')
      " Make mouse work with Vim in tmux
      try
        set ttymouse=sgr
      catch
        set ttymouse=xterm2
      endtry
    endif
  endif

  " set selectmode=
  set keymodel-=stopsel " do not stop visual selection with cursor keys
  set selection=inclusive

  set switchbuf=useopen
  if !g:Rc.is_ivim
    set switchbuf+=uselast
    set tagfunc=CocTagFunc
  endif
  " set jumpoptions=stack,view

  set matchpairs+=<:>    " pairs to highlight with showmatch
  set showmatch          " when inserting pair, jump to matching one
  set matchtime=2        " ms to blink when matching brackets

  set hidden
  if exists('+showcmdloc')
    set showcmdloc=last
  endif
  set ruler showmode
  " set noruler noshowmode
  set showcmd
  set modeline
  set modelines=5
  set cmdheight=2
  set pumheight=10
  set showtabline=2
  set synmaxcol=300   " don't highlight long lines
  set laststatus=2    " when last window has stl
  set history=500     " keep 500 lines of command line history

  set cursorline
  if exists('+cursorlineopt')
    set cursorlineopt=number,screenline
  endif
  set scrolloff=5
  set sidescrolloff=10
  set sidescroll=1
  set textwidth=100
  set winminwidth=2
  set noequalalways
  set splitright
  set splitbelow

  set numberwidth=4
  set number
  set relativenumber
  set signcolumn=yes

  " === Fold ================================================================ [[[
  set foldenable
  set foldcolumn=1
  set foldlevel=99
  set foldlevelstart=99
  set foldopen=block,hor,mark,percent,quickfix,search,tag,undo
  set foldmethod=marker
  set foldmarker=[[[,]]]
  " set foldmethod=indent
  " set foldmethod=expr
  " set foldexpr=nvim_treesitter#foldexpr()
  " ]]]

  " === Autocompletion ====================================================== [[[
  set wildmenu
  set wildmode=longest:full,full
  set wildignore+=.git,.DS_Store,node_modules
  set wildignore+=*~,*.git,*.lock,*.wav,*.avi,*.png
  set wildignore+=*.o,*.pyc,*.swp,*.aux,*.out,*.toc,*.o,*.obj,*.dll,*.jar
  set wildignore+=*.pyc,*.rbc,*.class,*.gif,*.ico,*.jpg,*.jpeg
  set wildignorecase
  set wildoptions=tagfile
  if !g:Rc.is_ivim
    set wildoptions^=pum,fuzzy
  endif
  set wildcharm=<Tab>
  set wildchar=<Tab>
  " ]]]

  if has('virtualedit')
    set virtualedit=block
  endif
  set cedit=<C-c>
  set nostartofline

  set display=lastline
  set list
  set listchars=tab:‣\ ,trail:•,nbsp:␣,precedes:«,extends:…

  set conceallevel=2
  set concealcursor=c

  set fillchars=stl:\ ,stlnc:\ ,vert:┃,diff:╱
  if !g:Rc.is_ivim
    set fillchars+=eob:\ ,lastline:@
    set fillchars+=fold:,foldopen:,foldsep:│,foldclose:
  endif

  set cpoptions+=I
  set shortmess+=acsIST
  set whichwrap+=<,>,[,],b,h,l,s
  set wrap
  set wrapmargin=2

  set nojoinspaces
  set formatoptions+=1qnMjlpro
  set formatoptions-=vct
  if !g:Rc.is_ivim
    set formatoptions+=/
  endif
  set formatlistpat=^\s*\%(\d\+[\]:.)}\t\ \|[-*+]\+\)\s*\|^\[^\ze[^\]]\+\]:

  set shiftwidth=2
  set tabstop=2
  set softtabstop=2
  set expandtab
  set smarttab
  set shiftround
  set backspace=eol,start,indent

  " set indentexpr=nvim_treesitter#indent()
  set autoindent     " copy indent from current line when starting a new line (<CR>, o, O)
  set smartindent    " smart autoindenting when starting a new line (C-like progs)
  set cindent        " automatic C program indenting
  " set copyindent     " copy structure of existing lines indent when autoindenting a new line
  " set preserveindent " preserve most indent structure as possible when reindenting line

  if exists('+breakindent')
    set breakindentopt=sbr,list:2,min:20,shift:2
    set breakindent             " each wrapped line will continue same indent level
  endif

  if exists('+showbreak')
    set showbreak=↳
  endif
  set linebreak               " lines wrap at words rather than random characters
  set breakat=\ ^I!@*-+;:,./? " which chars cause break with 'linebreak'
  " set comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-  " strings that can start a comment line

  " set cinoptions=>1s,L0,=1s,l1,b1,g1s,h1s,N0,E0,p1s,t0,i1s,+0,c1S,(1s,u1s,U1,k1s,m1,j1,J1,)40,*70,#0,P1
  " set cinkeys=0},0),0],:,!^F,o,O,e

  set diffopt+=internal,filler,iwhite,vertical,algorithm:histogram,context:4,indent-heuristic

  if !g:Rc.is_ivim
    set diffopt+=closeoff

    set grepprg=rg\ --with-filename\ --no-heading\ --max-columns=200\ --vimgrep\ --smart-case\ --color=never\ --follow
    set grepprg+=\ --glob=!.git\ --glob=!target\ --glob=!node_modules
  endif

  set grepformat^=%f:%l:%c:%m,%f:%l:%m

  " === GUI ================================================================= [[[
  " let &statusline = join([
  "     \ '%1*[%F(%n)]%*',
  "     \ '%2*[FT=%y]%*',
  "     \ '[%l,%v]',
  "     \ '[Fenc=%{&fileencoding}]',
  "     \ '[Enc=%{&encoding}]',
  "     \ '%4*%m%*',
  "     \ '%5*%r%*',
  "     \ ], '')

  set background=dark

  if has('gui_running')
    set t_Co=256
    set guioptions-=T
    set guioptions-=e
    set guitablabel=%M\ %t
    " set hlsearch
    syntax on
  endif

  if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let &t_8u = "\<Esc>[58;2;%lu;%lu;%lum"
  endif

  " This causes no true color
  " set termguicolors

  if !exists('g:neovide')
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
        \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
        \,sm:block-blinkwait175-blinkoff150-blinkon175

    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[4 q"
    let &t_EI = "\<Esc>[2 q"
  endif

  set guifont=FiraCode\ Nerd\ Font\ Mono:h13

  " uses <Esc>]
  set t_IS=  " icon text start
  set t_RF=  " request terminal foreground
  set t_RB=  " request terminal background
  set t_SC=  " set cursor color start
  set t_ts=  " set window title start
  set t_Cs=  " undercurl mode

  " uses <Esc>P and <ESC>\
  set t_RS=  " request terminal cursor style

  " <M-BS>, <C-space> are not :set-able
  exec "set <F34>=\<Esc>\<C-?>"
  map! <F34> <M-BS>

  " :h undercurl
  let &t_Cs = "\e[4:3m"
  let &t_Ce = "\e[4:0m"

  " if !has("patch-9.0.1117")
  "   if !empty($TMUX) && exists('&t_BE')
  "     let &t_BE = "\033[?2004h"
  "     let &t_BD = "\033[?2004l"
  "     let &t_PS = "\033[200~"
  "     let &t_PE = "\033[201~"
  "   endif
  " endif

  " set t_BE=  " bracketed paste
  " set t_BD=  " bracketed paste
  " exe "set <C-M-n>=\<Esc>\<C-n>"
  " exe "set <C-M-k>=\<Esc>\<C-k>"
  " exe "set <C-M-l>=\<Esc>\<C-l>"
  " ]]]

  " === Clipboard =========================================================== [[[
  if exists('$DISPLAY') && executable('xsel')
    let g:clipboard = {
        \   'name': 'xsel',
        \   'copy': {
        \      '+': ['xsel', '--nodetach', '-i', '-b'],
        \      '*': ['xsel', '--nodetach', '-i', '-p'],
        \    },
        \   'paste': {
        \      '+': ['xsel', '-o', '-b'],
        \      '*': ['xsel', '-o', '-p'],
        \   },
        \   'cache_enabled': 1,
        \ }
  elseif g:Rc.is_tmux
    let g:clipboard = {
        \   'name': 'tmux',
        \   'copy': {
        \      '+': ['tmux', 'load-buffer', '-w', '-'],
        \      '*': ['tmux', 'load-buffer', '-w', '-'],
        \    },
        \   'paste': {
        \      '+': ['tmux', 'save-buffer', '-'],
        \      '*': ['tmux', 'save-buffer', '-'],
        \   },
        \   'cache_enabled': 1,
        \ }
  endif

  set clipboard=unnamedplus,unnamed
  " ]]]

  call usr#core#options#syntax()
  call usr#core#options#plugins()
  call usr#core#options#netrw()
endf

func! usr#core#options#plugins() abort
  " let g:loaded_man = 1
  let g:loaded_spellfile = 1
  let g:loaded_spellfile_plugin = 1
  let g:loaded_spell = 1

  " let g:loaded_matchit = 1
  " let g:loaded_fzf = 1
  " let g:loaded_health = 1
  " let g:loaded_remote_plugins = 1
  " let g:loaded_rplugin = 1
  " let g:loaded_netrw = 1
  " let g:loaded_netrwFileHandlers = 1

  let g:loaded_ada = 1
  let g:loaded_clojurecomplete = 1
  let g:loaded_context = 1
  let g:loaded_contextcomplete = 1
  let g:loaded_csscomplete = 1
  let g:loaded_decada = 1
  let g:loaded_freebasic = 1
  let g:loaded_gnat = 1
  let g:loaded_haskellcomplete = 1
  let g:loaded_htmlcomplete = 1
  let g:loaded_javascriptcomplete = 1
  let g:loaded_phpcomplete = 1
  let g:loaded_pythoncomplete = 1
  let g:loaded_python3complete = 1
  let g:loaded_RstFold = 1
  let g:loaded_rubycomplete = 1
  let g:loaded_sqlcomplete = 1
  let g:loaded_vimexpect = 1
  let g:loaded_xmlcomplete = 1
  let g:loaded_xmlformat = 1
  let g:loaded_syntax_completion = 1

  " let g:loaded_perl_provider = 1
  " let g:loaded_python3_provider = 1
  " let g:pythonx_provider = 0
  let g:python_provider = 0
  let g:ruby_provider = 0
  let g:node_provider = 0

  " let g:loaded_syntax = 1
  " let g:loaded_optwin = 1
  " let g:loaded_ftplugin = 1

  let g:loaded_2html_plugin = 1
  let g:loaded_getscript = 1
  let g:loaded_getscriptPlugin = 1
  let g:loaded_logiPat = 1
  let g:loaded_matchparen = 1
  let g:loaded_netrwPlugin = 1
  let g:loaded_netrwSettings = 1
  let g:loaded_rrhelper = 1
  let g:loaded_tutor_mode_plugin = 1
  let g:loaded_spec = 1
  let g:loaded_macmap = 1
  let g:loaded_sleuth = 1
  let g:loaded_gtags = 1
  let g:loaded_gtags_cscope = 1
  let g:loaded_editorconfig = 1
  let g:loaded_tohtml = 1
  let g:loaded_tutor = 1
  let g:loaded_bugreport = 1
  let g:loaded_compiler = 1
  let g:loaded_synmenu = 1
  let g:loaded_gzip = 1
  let g:loaded_tar = 1
  let g:loaded_tarPlugin = 1
  let g:loaded_vimball = 1
  let g:loaded_vimballPlugin = 1
  let g:loaded_zip = 1
  let g:loaded_zipPlugin = 1
endfu

func! usr#core#options#netrw() abort
  let g:netrw_banner = 0
  let g:netrw_liststyle = 3
  let g:netrw_dirhistmax = 20
  let g:netrw_fastbrowse = 0
  let g:netrw_browse_split = 4
  let g:netrw_sizestyle = "H"
  let g:netrw_alto = 1
  let g:netrw_altv = 1
  let g:netrw_hide = 0
  let g:netrw_special_syntax = 1
  let g:netrw_sort_sequence = '[\/]$,\d+*,*'
  let g:netrw_sort_options = "in"
  let g:netrw_list_hide = ',\(^\|\s\s\)\zs\.\S\+'
  let g:netrw_browsex_viewer = "handlr open"
  let g:netrw_localcopycmd = "cp"
  let g:netrw_localcopycmdopt = " -ivp --reflink=auto"
  let g:netrw_localcopydircmd = "cp"
  let g:netrw_localcopydircmdopt = " -ivpr --reflink=auto"
  let g:netrw_localmovecmd = "mv"
  let g:netrw_localmovecmdopt = " -iv"
  let g:netrw_localmkdir = "mkdir"
  let g:netrw_localmkdiropt = " -p"
  let g:netrw_localrmdir = "rip"
  let g:netrw_localrm = "rip"
  let g:netrw_keepj = "keepj"
endfu

func! usr#core#options#syntax() abort
  " let g:c_no_trail_space_error = 0 " don't highlight trailing space
  " let g:c_no_comment_fold = 0      " don't fold comments
  " let g:c_no_cformat = 0           " don't highlight %-formats in strings
  " let g:c_no_if0 = 0               " don't highlight "#if 0" blocks as comments
  " let g:c_no_if0_fold = 0          " don't fold #if 0 blocks

  let g:c_gnu = 1                  " GNU gcc specific settings
  let g:c_syntax_for_h = 1         " use C syntax instead of C++ for .h
  let g:c_space_errors = 1         " highlight space errors
  let g:c_curly_error = 1          " highlight missing '}'
  let g:c_comment_strings = 1      " strings and numbers in comment
  let g:c_ansi_typedefs = 1        " do ANSI types
  let g:c_ansi_constants = 1       " do ANSI constants

  let g:desktop_enable_nonstd = 1  " highlight nonstd ext. of .desktop files
  let g:load_doxygen_syntax = 1    " enable doxygen syntax
  let g:doxygen_enhanced_color = 1 " use nonstd hl for doxygen comments

  let g:html_syntax_folding = 1
  let g:vim_json_conceal = 0     " don't conceal json
  let g:lifelines_deprecated = 1 " hl deprecated funcs as errors

  let g:nroff_is_groff = 1
  let g:nroff_space_errors = 1
  let b:preprocs_as_sections = 1

  let g:perl_string_as_statement = 1   " highlight string different if 2 on same line
  let g:perl_fold = 1
  let g:perl_fold_blocks = 1
  let g:perl_fold_anonymous_subs = 1

  let g:sh_fold_enabled = 1              " enable folding in bash files
  let g:ruby_operators = 1
  let g:ruby_fold = 1
  let g:sed_highlight_tabs = 1
  let g:no_man_maps = 1
  let g:vimsyn_embed = "lPr"
  let g:vimsyn_folding = "afP"
endfu

func! usr#core#options#formatoptions() abort
  setl formatoptions+=1 " don't break a line after a one-letter word; break before
  setl formatoptions-=2 " use indent from 2nd line of a paragraph
  setl formatoptions+=q " format comments with gq"
  setl formatoptions+=n " recognize numbered lists. Indent past formatlistpat not under
  setl formatoptions+=M " when joining lines, don't insert a space before or after a multibyte char
  " Only break if the line was not longer than 'textwidth' when the insert
  " started and only at a white character that has been entered during the
  " current insert command.
  setl formatoptions+=l
  setl formatoptions-=v  " only break line at blank line I've entered
  setl formatoptions-=c  " auto-wrap comments using textwidth
  setl formatoptions-=t  " autowrap lines using text width value
  setl formatoptions+=r  " continue comments when pressing Enter
  setl formatoptions+=p  " don't break lines at single spaces that follow periods
  setl formatoptions+=o  " automatically insert comment leader after 'o'/'O'
  setl formatoptions-=a  " auto formatting
  setl formatoptions+=/  " when 'o' included: don't insert comment leader for // comment after statement

  if v:version > 703 || v:version == 703 && has("patch541")
    setl formatoptions+=j " remove a comment leader when joining lines.
  endif
endfunc
