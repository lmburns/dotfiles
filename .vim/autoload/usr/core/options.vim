func! usr#core#options#setup() abort
  " === Base ================================================================ [[[
  " Allow mapping more keycodes. :h modifyOtherKeys
  " https://superuser.com/questions/121568/mapping-left-alt-key-in-vim
  let &t_TI = "\<Esc>[>4;2m"
  let &t_TE = "\<Esc>[>4;m"
  " Enables FocusLost/Gained
  let &t_fe = "\<Esc>[?1004h"
  let &t_fd = "\<Esc>[?1004l"

  set path+=**
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
  " UndoHistory: store undo history in a file. even after closing and reopening vim
  if has('persistent_undo')
    let target = expand('$VIMHOME/dirs/persistent_undo/')
    if !isdirectory(target)
      call mkdir(target, 'p')
    endif

    let &undodir=target
    set undofile
    set undolevels=1000
    set undoreload=10000
  endif

  if exists('+viminfo')
    let &viminfofile=expand('$VIMHOME/dirs/viminfo')
    set viminfo=!,'1000,/5000,:5000,<20,@1000,h,s100,r/tmp,r/run,rterm://,rfugitive://,rman://,rtemp://
  end

  if exists('+viewdir')
    let target = expand('$VIMHOME/dirs/viewdir/')
    if !isdirectory(target)
      call mkdir(target, 'p')
    endif

    let &viewdir=target
    set viewoptions=cursor,folds
    set sessionoptions=globals,buffers,curdir,tabpages,winsize,winpos,help
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
  let &spellfile=expand('$VIMHOME/dirs/en.utf-8.add')
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
  set timeoutlen=375     " time to wait for mapping sequence to complete
  set ttimeoutlen=50     " time to wait for keysequence to complete used for ctrl-\ - ctrl-g

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

  set tagfunc=CocTagFunc
  set switchbuf=useopen,uselast
  " set jumpoptions=stack,view

  set matchpairs+=<:>    " pairs to highlight with showmatch
  set showmatch          " when inserting pair, jump to matching one
  set matchtime=2        " ms to blink when matching brackets

  set hidden
  set showcmdloc=last
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
  set cursorlineopt=number,screenline
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
  set wildoptions=pum,fuzzy
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

  "  ▽  ▾ 
  "  ▶  ▸  |
  set fillchars+=stl:\ ,stlnc:\ ,vert:┃,lastline:@,eob:\ ,diff:╱
  set fillchars+=fold:,foldopen:,foldsep:│,foldclose:

  " TODO: delete-insert

  set cpoptions+=I
  set shortmess+=acsIST
  set whichwrap+=<,>,[,],b,h,l,s
  set wrap
  set wrapmargin=2

  set nojoinspaces
  set formatoptions+=1qnMjlp/ro
  set formatoptions-=vct
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
  " set showbreak=↳
  set linebreak               " lines wrap at words rather than random characters
  set breakat=\ ^I!@*-+;:,./? " which chars cause break with 'linebreak'
  " set comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-  " strings that can start a comment line

  " set cinoptions=>1s,L0,=1s,l1,b1,g1s,h1s,N0,E0,p1s,t0,i1s,+0,c1S,(1s,u1s,U1,k1s,m1,j1,J1,)40,*70,#0,P1
  " set cinkeys=0},0),0],:,!^F,o,O,e

  set diffopt+=internal,filler,closeoff,iwhite,vertical,algorithm:histogram,context:4,indent-heuristic
  set grepprg=rg\ --with-filename\ --no-heading\ --max-columns=200\ --vimgrep\ --smart-case\ --color=never\ --follow
  set grepprg+=\ --glob=!.git\ --glob=!target\ --glob=!node_modules
  set grepformat^=%f:%l:%c:%m
  " set grepformat=%f:%l:%c:%m,%f:%l:%m

  " === GUI ================================================================= [[[
  set background=dark

  if has("termguicolors")
    set termguicolors
  endif

  if has('gui_running')
    set t_Co=256
    set guioptions-=T
    set guioptions-=e
    set guitablabel=%M\ %t
    " set hlsearch
    syntax on
  endif

  if !exists('g:neovide')
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
          \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
          \,sm:block-blinkwait175-blinkoff150-blinkon175

    let &t_SI = "\<Esc>[6 q"
    let &t_SR = "\<Esc>[4 q"
    let &t_EI = "\<Esc>[2 q"
  endif

  set guifont=FiraCode\ Nerd\ Font\ Mono:h13
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
  elseif exists('$TMUX')
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
endf
