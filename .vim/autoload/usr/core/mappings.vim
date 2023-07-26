func! usr#core#mappings#setup() abort
  " ============== General Mappings ============== [[[
  imap jk <ESC>
  imap kj <ESC>
  nnoremap q: <Nop>
  nnoremap q/ <Nop>
  nnoremap q? <Nop>

  " === Insert ============================================================== [[[

  " Go beginning of line
  inoremap <M-S-"> <Home>
  " Go end of line
  inoremap <M-'> <End>
  " Go word back
  inoremap <M-b> <C-Left>
  " Go word forward
  inoremap <M-f> <C-Right>
  " Go word back
  inoremap <C-S-h> <C-Left>
  " Go word forward
  inoremap <C-S-l> <C-Right>
  " Go one char left
  inoremap <C-S-n> <Left>
  " Go one char right
  " Go one line up
  inoremap <C-S-k> <C-o>gk
  " Go one line down
  inoremap <C-S-j> <C-o>gj
  " Goto next screen-line
  inoremap <Down> <C-o>gj
  " Goto prev screen-line
  inoremap <Up> <C-o>gk
  " Paste
  inoremap <C-S-p> <C-o>p
  " Paste formatted
  imap <C-M-p> <C-o>ghp
  " Paste formatted
  imap <C-M-,> <C-o>ghp
  " Paste commented
  imap <C-M-.> <C-o>g2p
  " Command mode
  inoremap <C-n> <C-o>:

  if !g:Rc.is_ivim
    " Insert last inserted text
    inoremap <M-/> <C-a>
    " Paste commented
    imap <M-p> <C-o>g2p
  endif

  inoremap , ,<C-g>u
  inoremap . .<C-g>u
  inoremap ! !<C-g>u
  inoremap ? ?<C-g>u
  " inoremap <CR> <CR><C-g>u
  " Start new undo sequence
  inoremap <C-S-u> <C-g>u
  " Start new undo sequence
  inoremap <C-/> <C-g>u
  " Undo typed text
  inoremap <C-o>u <C-g>u<C-o>u
  " Redo
  inoremap <C-o>U <C-g>u<C-o><C-r>
  " Undo typed text
  inoremap <M-u> <C-g>u<C-o>u
  " Redo
  inoremap <M-S-u> <C-g>u<C-o><C-r>
  " Delete previous word
  inoremap <M-BS> <C-g>u<C-w>
  " Delete all typed in insert (before cursor)
  inoremap <C-u> <C-g>u<C-u>
  " Delete character to right
  inoremap <C-l> <C-g>u<Del>
  " Delete to end of word
  inoremap <M-d> <C-g>u<C-o>de
  " Left kill line
  inoremap <M-[> <C-g>u<C-o>dg^
  " Right kill line
  inoremap <M-]> <C-g>u<C-o>dg$
  " Right kill line
  inoremap <M-,> <C-g>u<C-o>dg$
  " Kill whole line
  inoremap <M-x> <C-g>u<C-o>cc

  " Equivalent: 'norm! o'
  inoremap <M-o> <C-g>u<C-o>o
  " Equivalent: 'norm! o'
  inoremap <M-CR> <C-g>u<C-o>o
  " Move current line down
  inoremap <M-i> <C-g>u<C-o>O
  " Move current line down
  inoremap <M-S-o> <C-g>u<C-o>O
  " Insert line above
  imap <C-M-i> <C-g>u<C-o>zk
  " Insert line below
  imap <C-M-o> <C-g>u<C-o>zj

  " Insert file name
  inoremap <F1> <C-R>=expand('%')<CR>
  " Insert directory
  inoremap <F2> <C-R>=expand('%:p:h')<CR>
  " ]]]

  " === Command ============================================================= [[[
  cnoremap <C-b> <Left>
  cnoremap <C-f> <Right>
  cnoremap <C-S-k> <Up>
  cnoremap <C-S-j> <Down>
  cnoremap <C-f> <Right>
  cnoremap <C-,> <Home>
  cnoremap <C-.> <End>
  cnoremap <C-h> <BS>
  cnoremap <C-l> <Del>
  cnoremap <C-d> <Del>
  " Move one word left
  cnoremap <M-b> <C-Left>
  cnoremap <C-S-h> <C-Left>
  " Move one word right
  cnoremap <M-f> <C-Right>
  cnoremap <C-S-l> <C-Right>
  " Delete to end of line
  cnoremap <C-o> <C-\>egetcmdline()[:getcmdpos() - 2]<CR>
  cnoremap <M-]> <C-\>egetcmdline()[:getcmdpos() - 2]<CR>
  cnoremap <F1> <C-r>=fnameescape(expand('%'))<CR>
  cnoremap <F2> <C-r>=fnameescape(expand('%:p:h'))<CR/>
  " Inverse search
  cnoremap <M-/> \v^(()@!.)*$<Left><Left><Left><Left><Left><Left><Left>
  " ]]]

  " === Normal ============================================================= [[[
  call api#map#('n', ';q', '<Cmd>q<CR>', #{noremap: 1})
  call api#map#('n', ';w', '<Cmd>update<CR>', #{noremap: 1, silent: 1})
  call api#map#('n', '<BS>', '<C-^>', #{noremap: 1})

  nnoremap - "_
  xnoremap - "_
  " Remap mark jumping
  noremap ' `
  noremap ` '

  " Repeat last command
  call api#map#(['n', 'x'], '<F2>', '@:')
  call api#map#('n', '<Leader>r.', '@:')
  call api#map#('x', '<Leader>r.', '@:')

  " use qq to record, q to stop, Q to play a macro
  call api#map#('n', 'Q', '@q')
  call api#map#('x', 'Q', ':normal @q')
  call api#map#('n', 'qq', '(reg_recording() ==# "") ? "qq" : "q"', #{expr: 1})
  call api#map#('n', 'ql', '(reg_recording() ==# "") ? "ql" : "q"', #{expr: 1})
  call api#map#('n', 'qk', '(reg_recording() ==# "") ? "qk" : "q"', #{expr: 1})
  call api#map#('x', '@', ':<C-u>call usr#fn#ExecuteMacroVisual()<CR>')
  call api#map#('x', '.', ':norm .<CR>')

  " Perform dot commands over visual blocks
  xnoremap . :normal .<CR>

  " TODO: Differentiate with shift mappings
  " nnoremap U <C-r>
  nmap . <Plug>(RepeatDot)
  nmap u <Plug>(RepeatUndo)
  nmap U <Plug>(RepeatRedo)
  " nmap <C-S-u> <Plug>(RepeatUndoLine)

  " Go to newer text state
  nnoremap ;U <Cmd>execute('later ' . v:count1 . 'f')<CR>
  " Go to older state
  nnoremap ;u <Cmd>execute('earlier ' . v:count1 . 'f')<CR>

  " inserts a line above or below
  nnoremap <silent> zj <Cmd>call append(line('.') + v:count, '')<CR>
  nnoremap <silent> zk <Cmd>call append(line('.') - v:count1, '')<CR>
  " keep focused in center of screen when searching
  nnoremap <expr> n (v:searchforward ? 'nzzzv' : 'Nzzzv')
  nnoremap <expr> N (v:searchforward ? 'Nzzzv' : 'nzzzv')
  " move through folded lines
  nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
  nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
  xnoremap j    gj
  xnoremap k    gk
  nnoremap gj   j
  xnoremap gj   j
  nnoremap gk   k
  xnoremap gk   k
  nnoremap H    g^
  xnoremap H    g^
  onoremap H    g^
  nnoremap <expr> L (v:count > 0 ? '@_1g_' : 'g$'.(getline('.')[strlen(getline('.'))-1] == ' ' ? 'ge' : ''))
  xnoremap L    g_
  onoremap L    g$
  " xnoremap L    :norm! g$<CR><Cmd>exe (getline('.')[col('.')] == ' ' ? 'norm! ge' : '')<CR>

  nnoremap <Down> }
  nnoremap <Up>   {
  nnoremap <expr> 0 (getline('.')[0:col('.')-2] =~# '^\s\+$' ? 'g0' : 'm`g^')

    " move selected text up down
    " TODO: get these mappings to work
    " nnoremap <C-S-j> :m .+1<CR>==
    " nnoremap <C-S-k> :m .-2<CR>==
    xnoremap J :m '>+1<CR>gv=gv
    xnoremap K :m '<-2<CR>gv=gv
    inoremap <C-j> <Esc>:m .+1<CR>==gi
    inoremap <C-k> <Esc>:m .-2<CR>==gi
    " inoremap <C-j> <Esc>:m .+1<CR>==a
    " inoremap <C-k> <Esc>:m .-2<CR>==a

    " Don't lose selection when shifting sideways
    xnoremap < <gv
    xnoremap > >gv

    " Delete blackhole
    nnoremap d "sd
    xnoremap d "sd
    " Delete to end of line (blackhole)
    nnoremap D "sD
    " Delete line (blackhole)
    nnoremap S ^"sD
    " Cut letter (blackhole)
    nnoremap x "_x
    " Yank to EOL (without newline)
    nnoremap Y y$
    " Place the cursor at end of yank
    xnoremap y ygv<Esc>
    " Select entire line (without newline)
    nnoremap vv ^vg_
    " Select entire file
    nnoremap <M-a> ggVG
    " paste over selected text
    xnoremap p "_c<Esc>p
    " reselect the text that has just been pasted
    nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'

    " Goto last insert spot
    nnoremap gI `^
    " Get ASCII value
    nnoremap gA ga
    " Show buffer info
    nnoremap <C-g> 2<C-g>
    " Show word count
    xnoremap <C-g> g<C-g>

    nnoremap <expr> cc (getline('.') =~ '^\s*$' ? '"_cc' : 'cc')
    " cgn start `cword`
    nnoremap c* :let @/='\\<'.expand('<cword>').'\\>'<CR>cgn
    " Change text (dot repeatable)
    xnoremap C "cy:let @/=@c<CR>cgn
    " Change text; search forward
    nnoremap cn *``cgn
    " Change text; search backward
    nnoremap cN *``cgN
    " Last change init `cgn`
    nnoremap g. /\V<C-r>"<CR>cgn<C-a><Esc>

    " Replace under cursor
    nnoremap <Leader>sr :%s/\<<C-r><C-w>\>/
    " Global replace
    nnoremap <Leader>sg :%s//g<Left><Left>
    " Change all matches
    nnoremap cM :%s/<C-r>///g<Left><Left>
    " Delete all search matches
    nnoremap dM :%s/<C-r>//g<CR>

    " Search visible screen
    " nnoremap z/ /\%><C-r>=line("w0")-1<CR>l\%<<C-r>=line("w$")+1<CR>l
    nnoremap <silent> z/ :let old=&so<Bar>so=0<CR>m`HVL<Esc>:let &so=old<CR>``<C-y>/\%V
    " Search visual selection
    " xnoremap z/ <Esc>/\\%V
    xnoremap <silent> z/ :<C-U>call usr#fn#range_search('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
    xnoremap <silent> z? :<C-U>call usr#fn#range_search('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>
    " Search for visual selection
    xnoremap g/ y/<C-R>"<CR>
    " Substitute in visual selection
    xnoremap s/ <Esc>:s/\%V/g<Left><Left>

    " Join lines & remove backslash
    nnoremap <silent><expr> gW (getline('.')[strlen(getline('.'))-1] == '\' ? '$xJ' : 'J')

    " Move cursor to center of line
    nnoremap <expr> gM (virtcol('$') / 2) . '<Bar>'
    " Clear highlight
    nnoremap <silent> <Esc> <Cmd>nohlsearch<CR>:call clearmatches()<CR>

    nnoremap <Leader>b. <Cmd>ls!<CR>
    nnoremap <Leader>ls <Cmd>ls!<CR>
    " nnoremap <Leader>c; :let &mouse=(empty(&mouse) ? 'a' : '')<CR>
    nnoremap <silent><Leader>co <Cmd>set cuc! cuc?<CR>
    nnoremap <silent><Leader>c; <Cmd>exec "set fo"..(stridx(&fo, 'r') == -1 ? "+=ro" : "-=ro").." fo?"<CR>
    nnoremap <silent><Leader>ci <Cmd>exec "set stal="..(&stal == 2 ? "0" : "2").." stal?"<CR>
    nnoremap <silent><Leader>cv <Cmd>exec "set cole="..(&cole == 2 ? "0" : "2").." cole?"<CR>

    nnoremap <Leader>a; <Cmd>h pattern-overview<CR>
    nnoremap <Leader>am <Cmd>h index<CR>
    nnoremap <Leader>ab <Cmd>h builtin-function-list<CR>
    nnoremap <Leader>aB <Cmd>h function-list<CR>
    nnoremap <Leader>ae <Cmd>h ex-commands<CR>
    nnoremap <Leader>aQ <Cmd>h quickref<CR>
    nnoremap <Leader>aa <Cmd>h Q_fl<CR>
    nnoremap <Leader>au <Cmd>h Q_bu<CR>
    nnoremap <Leader>aw <Cmd>h Q_wi<CR>
    nnoremap <Leader>af <Cmd>h Q_fo<CR>
    nnoremap <Leader>ac <Cmd>h Q_ce<CR>
    nnoremap <Leader>aq <Cmd>h Q_qf<CR>
    nnoremap <Leader>ao <Cmd>h Q_op<CR>

    nnoremap <silent> <Leader>rt <Cmd>setl et<CR>
    nnoremap <silent> <Leader>re <Cmd>setl et<CR><Cmd>retab<CR>
    xnoremap <silent> <Leader>re <Cmd>retab<CR>
    nnoremap <silent> <Leader>cd <Cmd>lcd %:p:h<CR><Cmd>pwd<CR>
    "]]]

    " nnoremap <expr> [ usr#builtin#prefix_timeout('[')
    " xnoremap <expr> [ usr#builtin#prefix_timeout('[')
    " nnoremap <expr> ] usr#builtin#prefix_timeout(']')
    " xnoremap <expr> ] usr#builtin#prefix_timeout(']')
    " nnoremap <expr> z usr#builtin#prefix_timeout('z')
    " xnoremap <expr> z usr#builtin#prefix_timeout('z')

    " === Visual ============================================================= [[[
    " Delete (blackhole)
    xnoremap d "_d
    " Place the cursor at end of yank
    xnoremap y ygv<Esc>
    " Show word count
    xnoremap <C-g> g<C-g>
    " Repeat last substitution
    xnoremap & :&&<CR>
    " ]]]

    " === Quickfix =========================================================== [[[
    " Prev item
    nnoremap <silent> [q <Cmd>execute(v:count1 . 'cprev')<CR>
    " Next item
    nnoremap <silent> ]q <Cmd>execute(v:count1 . 'cnext')<CR>
    " First item
    nnoremap <silent> [Q <Cmd>cfirst<CR>
    " Last item
    nnoremap <silent> ]Q <Cmd>clast<CR>
    " Prev quickfix list
    nnoremap <silent> [e <Cmd>colder<CR>
    " Next quickfix list
    nnoremap <silent> ]e <Cmd>cnewer<CR>
    " Goto prev file
    nnoremap <silent> qp <Cmd>cpfile<CR>
    " Goto next file
    nnoremap <silent> qn <Cmd>cnfile<CR>
    " View error
    nnoremap <silent> qi <Cmd>cc<CR>
    " Open quickfix
    nnoremap <silent> qo <Cmd>copen<CR>
    " Close quickfix
    nnoremap <silent> qc <Cmd>call usr#qf#close()<CR>
    " Toggle quickfix
    nnoremap <silent> q. <Cmd>sil call usr#qf#toggle('quickfix')<CR>
    " View most recently used files
    nnoremap <silent> qr <Cmd>Mru<CR>

    " Quickfix window (in quickfix: toggles between qf & loc list)
    nnoremap <silent><expr> <M-e>
          \ '@_:'.(&bt!=#'quickfix'<bar><bar>!empty(getloclist(0))?'lclose<bar>botright copen':'cclose<bar>botright lopen')
          \ .(v:count ? '<bar>wincmd L' : '').'<CR>'
    " ]]]

    " === Loclist ============================================================ [[[
    " Open loclist
    nnoremap <silent> qw <Cmd>lopen<CR>
    " Toggle loclist
    nnoremap <silent> q, <Cmd>sil call usr#qf#toggle('location')<CR>
    " Prev item
    nnoremap <silent> [w <Cmd>execute(v:count1 . 'lprev')<CR>
    " Next item
    nnoremap <silent> ]w <Cmd>execute(v:count1 . 'lnext')<CR>
    " First item
    nnoremap <silent> [W <Cmd>lfirst<CR>
    " Last item
    nnoremap <silent> ]W <Cmd>llast<CR>
    " Prev loclist
    nnoremap <silent> [E <Cmd>lolder<CR>
    " Next loclist
    nnoremap <silent> ]E <Cmd>lnewer<CR>
    " ]]]

    " === Windows ============================================================= [[[
    " move between windows
    nnoremap <C-j> <C-W>j
    nnoremap <C-k> <C-W>k
    nnoremap <C-h> <C-W>h
    nnoremap <C-l> <C-W>l
    " Change vertical to horizontal
    nnoremap <C-w><lt> <C-w>t<C-w>K
    " Change horizontal to vertical
    nnoremap <C-w>> <C-w>t<C-w>H
    " Open curwin in tab
    nnoremap <silent> <C-w>T <Cmd>tab sp<CR>
    " Close all tabs except current
    nnoremap <silent> <C-w>O <Cmd>tabo<CR>
    " Equally high and wide
    nnoremap <C-w>0 <C-w>=

    nnoremap <silent> <C-Up> <Cmd>resize +1<CR>
    nnoremap <silent> <C-Down> <Cmd>resize -1<CR>
    nnoremap <silent> <C-Right> <Cmd>vertical resize +1<CR>
    nnoremap <silent> <C-Left> <Cmd>vertical resize -1<CR>
    " ]]]

    " === Tab ================================================================ [[[
    " Prev tab
    nnoremap <silent> [t <Cmd>tabp<CR>
    " Next tab
    nnoremap <silent> ]t <Cmd>tabn<CR>
    " Close tab
    nnoremap <silent> qt <Cmd>tabc<CR>
    " ]]]

    " === Buffer ============================================================= [[[
    " Buffer switching
    " nnoremap gt :bnext<CR>
    " nnoremap gT :bprevious<CR>
    nnoremap <silent> <C-S-Right> <Cmd>bnext<CR>
    nnoremap <silent> <C-S-Left> <Cmd>bprevious<CR>
    " New buffer
    nnoremap <silent> <Leader>bn <Cmd>enew<CR>
    " Close buffer
    nnoremap <Leader>bq <Cmd>bp<Bar>bd! #<CR>
    " Close all buffers
    nnoremap <Leader>bQ <Cmd>bufdo bd! #<CR>
    " Delete all buffers except this
    nnoremap <Leader>bw <Cmd>up<Bar>%bd<Bar>e#<Bar>bd#<CR>
    " ]]]

    " ============== Syntax ============== [[[
    nnoremap <F9> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
          \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
          \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

    nnoremap <silent> <Leader>sH <Cmd>call usr#fn#synstack()<CR>
    nnoremap <silent> <Leader>sh <Cmd>call usr#fn#syntax_query()<CR>
    nnoremap <Leader>sll :syn list
    nnoremap <Leader>slo :verbose hi

    nnoremap <silent> <Leader>gf <Cmd>call usr#fn#GoGithub()<CR>
    nnoremap <silent> ;p <Cmd>call usr#fn#Profile()<CR>
    " ]]]

    " Grep current dir
    nnoremap \v  mS:<C-u>noau vimgrep /\C/j **<Left><Left><Left><Left><Left>
    " Search all file buffers (clear qf first).
    nnoremap \b  mS:<C-u>cexpr []<Bar>exe 'bufdo sil! noau vimgrepa/\C/j %'<bar>bo cope<S-Left><S-Left><Left><Left><Left>
    " Search current buffer and open results in loclist
    nnoremap \c  ms:<c-u>lvimgrep // % <Bar>lw<S-Left><Left><Left><Left><Left>

    nmap gS <Plug>Opsort

    nnoremap <silent> zZ <Cmd>call api#zz()<CR>
    xnoremap <silent> zZ <Cmd>call api#zz()<CR>

    nnoremap <silent> <M-u> <Cmd>call api#buf#goto_alt()<CR>
    nnoremap <silent> qj <Cmd>Jumps<CR>
    nnoremap <silent><Leader>b. <Cmd>CleanEmptyBuf<CR>
    nnoremap <silent><Leader>ha <Cmd>DiffSaved<CR>

    if has('vim_starting')
      nnoremap <unique> <C-,>; <Cmd>call usr#fn#ToggleLastChar(';')<CR>
      nnoremap <unique> <C-,>: <Cmd>call usr#fn#ToggleLastChar(':')<CR>
      nnoremap <unique> <C-,>, <Cmd>call usr#fn#ToggleLastChar(',')<CR>
      nnoremap <unique> <C-,>. <Cmd>call usr#fn#ToggleLastChar('.')<CR>
      nnoremap <unique> <C-,>qa <Cmd>call usr#fn#ToggleLastChar('  # noqa')<CR>
    endif

    nnoremap <silent> <C-z> <Cmd>call usr#fn#PreserveClipboadAndSuspend()<CR>
    vnoremap <silent> <C-z> :<c-u>call usr#fn#PreserveClipboadAndSuspend()<CR>

    " TODO:
    " Yank directory
    " nnoremap yd :call YankReg(v:register, expand('%:p:h'))<CR>
    " Yank file name
    " nnoremap yn :call YankReg(v:register, expand('%:t'))<CR>
    " Yank full path
    " nnoremap yP :call YankReg(v:register, expand('%:p'))<CR>
    " Yank motion
    " nnoremap y :call YankWrap()<CR>
    " nmap yw :call YankWrap('iw')<CR>
    " nmap yW :call YankWrap('iW')<CR>
    " nmap yl :call YankWrap('aL')<CR>
    " nmap yL :call YankWrap('iL')<CR>
    " nmap yu :call YankWrap('au')<CR>
    " nmap yh :call YankWrap('ai')<CR>
    " nmap yp :call YankWrap('ip')<CR>
    " nmap yo :call YankWrap('iss')<CR>
    " nmap yO :call YankWrap('ass')<CR>
    " nmap yq :call YankWrap('iq')<CR>
    " nmap yQ :call YankWrap('aq')<CR>

    " === SpellCheck ========================================================== [[[
    noremap <Leader>ss <Cmd>setlocal spell!<CR>
    noremap <Leader>sn ]s
    noremap <Leader>sp [s
    noremap <Leader>sa zg
    noremap <Leader>s? z=
    noremap <Leader>su zuw
    " Spell: correct next
    nnoremap <Leader>sl <C-g>u<Esc>[s1z=`]a<C-g>u
    " Spell: fix last spelling mistake
    inoremap <M-s> <C-g>u<Esc>[s1z=`]a<C-g>u
    " ]]]

    " === Other =============================================================== [[[
    nnoremap <Leader>ec <Cmd>CocConfig<CR>
    nnoremap <Leader>ev <Cmd>e $MYVIMRC<CR>
    nnoremap <Leader>sv <Cmd>so $MYVIMRC<CR>
    nnoremap <Leader>ei <Cmd>e $NVIMRC<CR>
    nnoremap <Leader>eo <Cmd>e $VIMHOME/autoload/usr/core/options.vim<CR>
    nnoremap <Leader>em <Cmd>e $VIMHOME/autoload/usr/core/mappings.vim<CR>
    nnoremap <Leader>ed <Cmd>e $VIMHOME/autoload/usr/core/commands.vim<CR>
    nnoremap <Leader>ea <Cmd>e $VIMHOME/autoload/usr/core/autocmds.vim<CR>
    nnoremap <Leader>ez <Cmd>e $ZDOTDIR/.zshrc<CR>
    " ]]]
endfun
