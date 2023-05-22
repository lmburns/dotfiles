" K {{{1
" keyword based jump dictionary maps {{{2

" Mapping short keywords to their longer version so they can be found
" in man page with 'K'
" '\[' at the end of the keyword ensures the match jumps to the correct
" place in tmux manpage where the option/command is described.

let s:keyword_mappings = {
      \ 'attach'              : 'attach-session',
      \ 'detach'              : 'detach-client',
      \ 'has'                 : 'has-session',
      \ 'lockc'               : 'lock-client',
      \ 'locks'               : 'lock-session',
      \ 'lsc'                 : 'list-clients',
      \ 'lscm'                : 'list-commands',
      \ 'ls'                  : 'list-sessions',
      \ 'new'                 : 'new-session',
      \ 'refresh'             : 'refresh-client',
      \ 'rename'              : 'rename-session',
      \ 'showmsgs'            : 'show-messages',
      \ 'source'              : 'source-file',
      \ 'start'               : 'start-server',
      \ 'suspendc'            : 'suspend-client',
      \ 'switchc'             : 'switch-client \[',
      \ 'switch-client'       : 'switch-client \[',
      \ 'breakp'              : 'break-pane',
      \ 'capturep'            : 'capture-pane',
      \ 'displayp'            : 'display-panes',
      \ 'findw'               : 'find-window',
      \ 'joinp'               : 'join-pane',
      \ 'killp'               : 'kill-pane',
      \ 'killw'               : 'kill-window',
      \ 'last'                : 'last-window',
      \ 'lastp'               : 'last-pane',
      \ 'linkw'               : 'link-window',
      \ 'lsp'                 : 'list-panes',
      \ 'lsw'                 : 'list-windows \[',
      \ 'list-windows'        : 'list-windows \[',
      \ 'movep'               : 'move-pane',
      \ 'movew'               : 'move-window',
      \ 'neww'                : 'new-window',
      \ 'nextl'               : 'next-layout',
      \ 'next'                : 'next-window',
      \ 'pipep'               : 'pipe-pane',
      \ 'prev'                : 'previous-window',
      \ 'prevl'               : 'previous-layout',
      \ 'renamew'             : 'rename-window',
      \ 'resizep'             : 'resize-pane',
      \ 'resizew'             : 'resize-window',
      \ 'respawnp'            : 'respawn-pane',
      \ 'respawnw'            : 'respawn-window',
      \ 'rotatew'             : 'rotate-window',
      \ 'selectl'             : 'select-layout \[',
      \ 'select-layout'       : 'select-layout \[',
      \ 'selectp'             : 'select-pane',
      \ 'selectw'             : 'select-window',
      \ 'splitw'              : 'split-window \[',
      \ 'split-window'        : 'split-window \[',
      \ 'swapp'               : 'swap-pane',
      \ 'swapw'               : 'swap-window',
      \ 'unlinkw'             : 'unlink-window',
      \ 'bind'                : 'bind-key \[',
      \ 'bind-key'            : 'bind-key \[',
      \ 'lsk'                 : 'list-keys',
      \ 'send'                : 'send-keys',
      \ 'unbind'              : 'unbind-key \[',
      \ 'unbind-key'          : 'unbind-key \[',
      \ 'set'                 : 'set-option \[',
      \ 'set-option'          : 'set-option \[',
      \ 'setw'                : 'set-option \[',
      \ 'set-window-option'   : 'set-option \[',
      \ 'show'                : 'show-options',
      \ 'showw'               : 'show-options \[',
      \ 'show-window-options' : 'show-options \[',
      \ 'setenv'              : 'set-environment',
      \ 'showenv'             : 'show-environment',
      \ 'confirm'             : 'confirm-before',
      \ 'menu'                : 'display-menu',
      \ 'display'             : 'display-message',
      \ 'popup'               : 'display-popup',
      \ 'clearphist'          : 'clear-prompt-history',
      \ 'showphist'           : 'show-prompt-history',
      \ 'clearhist'           : 'clear-history',
      \ 'deleteb'             : 'delete-buffer',
      \ 'lsb'                 : 'list-buffers',
      \ 'loadb'               : 'load-buffer',
      \ 'pasteb'              : 'paste-buffer',
      \ 'saveb'               : 'save-buffer',
      \ 'setb'                : 'set-buffer \[',
      \ 'set-buffer'          : 'set-buffer \[',
      \ 'showb'               : 'show-buffer',
      \ 'if'                  : 'if-shell',
      \ 'lock'                : 'lock-server',
      \ 'run'                 : 'run-shell',
      \ 'info'                : 'server-info',
      \ 'wait'                : 'wait-for'
      \ }

" Syntax highlighting group names are arranged by tmux manpage
" sections. That makes it easy to find a section in the manpage where the
" keyword is described.
" This dictionary provides a mapping between a syntax highlighting group and
" related manpage section.
let s:highlight_group_manpage_section = {
      \ 'tmuxClientSessionCmds': 'CLIENTS AND SESSIONS',
      \ 'tmuxWindowPaneCmds':    'WINDOWS AND PANES',
      \ 'tmuxBindingCmds':       'KEY BINDINGS',
      \ 'tmuxOptsSet':           'OPTIONS',
      \ 'tmuxOptsSetw':          'OPTIONS',
      \ 'tmuxEnvironmentCmds':   'ENVIRONMENT',
      \ 'tmuxStatusLineCmds':    'STATUS LINE',
      \ 'tmuxBufferCmds':        'BUFFERS',
      \ 'tmuxMiscCmds':          'MISCELLANEOUS',
      \ 'tmuxOptions':           'OPTIONS',
      \ }

" keyword based jump {{{2

function! s:get_search_keyword(keyword)
  return has_key(s:keyword_mappings, a:keyword)
      \ ? s:keyword_mappings[a:keyword]
      \ : a:keyword
endfunction

function! s:man_tmux_search(section, regex)
    if search('^' .. a:section, 'W') == 0
        return 1
    endif
    if search(a:regex, 'W') == 0
        return 1
    endif
    return 0
endfunction

function! s:keyword_based_jump(highlight_group, keyword)
  let section = s:highlight_group_manpage_section->has_key(a:highlight_group)
        \ ? s:highlight_group_manpage_section[a:highlight_group]
        \ : ''
  let search_keyword = s:get_search_keyword(a:keyword)

  Man tmux

  if s:man_tmux_search(section, '^\s\+\zs' .. search_keyword) ||
        \ s:man_tmux_search(section, search_keyword) ||
        \ s:man_tmux_search('', a:keyword)
    norm! zt
    return 1
  else
    redraw
    echohl ErrorMsg | echo "Sorry, couldn't find " .. a:keyword | echohl None
    return 0
  end
endfunction

" highlight group based jump {{{2

let s:highlight_group_to_match_mapping = {
      \ 'tmuxKeyTable':            ['KEY BINDINGS', '^\s\+\zslist-keys', ''],
      \ 'tmuxLayoutOptionValue':   ['WINDOWS AND PANES', '^\s\+\zs{}', '^\s\+\zsThe following layouts are supported'],
      \ 'tmuxUserOptsSet':         ['.', '^OPTIONS', ''],
      \ 'tmuxKeySymbol':           ['KEY BINDINGS', '^KEY BINDINGS', ''],
      \ 'tmuxKey':                 ['KEY BINDINGS', '^KEY BINDINGS', ''],
      \ 'tmuxAdditionalCommand':   ['COMMANDS', '^\s\+\zsMultiple commands may be specified together', ''],
      \ 'tmuxColor':               ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsmessage-bg'],
      \ 'tmuxStyle':               ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsmessage-attr'],
      \ 'tmuxPromptInpol':         ['STATUS LINE', '^\s\+\zscommand-prompt', ''],
      \ 'tmuxFmtInpol':            ['.', '^FORMATS', ''],
      \ 'tmuxFmtInpolDelimiter':   ['.', '^FORMATS', ''],
      \ 'tmuxFmtAlias':            ['.', '^FORMATS', ''],
      \ 'tmuxFmtVariable':         ['FORMATS', '^\s\+\zs{}', 'The following variables are available'],
      \ 'tmuxFmtConditional':      ['.', '^FORMATS', ''],
      \ 'tmuxFmtLimit':            ['.', '^FORMATS', ''],
      \ 'tmuxDateInpol':           ['OPTIONS', '^\s\+\zsstatus-left', ''],
      \ 'tmuxAttrInpol':           ['OPTIONS', '^\s\+\zsstatus-left', ''],
      \ 'tmuxAttrInpolDelimiter':  ['OPTIONS', '^\s\+\zsstatus-left', ''],
      \ 'tmuxAttrBgFg':            ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsstatus-left'],
      \ 'tmuxAttrEquals':          ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsstatus-left'],
      \ 'tmuxAttrSeparator':       ['OPTIONS', '^\s\+\zsmessage-command-style', '^\s\+\zsstatus-left'],
      \ 'tmuxShellInpol':          ['OPTIONS', '^\s\+\zsstatus-left', ''],
      \ 'tmuxShellInpolDelimiter': ['OPTIONS', '^\s\+\zsstatus-left', '']
      \ }

function! s:highlight_group_based_jump(highlight_group, keyword)
  Man tmux
  let section = s:highlight_group_to_match_mapping[a:highlight_group][0]
  let search_string = s:highlight_group_to_match_mapping[a:highlight_group][1]
  let fallback_string = s:highlight_group_to_match_mapping[a:highlight_group][2]

  let search_keyword = search_string->substitute('{}', a:keyword, "")
  if s:man_tmux_search(section, search_keyword) ||
        \ s:man_tmux_search(section, fallback_string)
    norm! zt
    return 1
  else
    redraw
    echohl ErrorMsg | echo "Sorry, couldn't find the exact description" | echohl None
    return 0
  end
endfunction
" just open manpage {{{2

function! s:just_open_manpage(highlight_group)
      let char_under_cursor = getline('.')->strpart(col('.') - 1)[0]
      " tmuxOptions
      let syn_groups =<< trim END

            tmuxStringDelimiter
            tmuxAction
            tmuxBoolean
            tmuxOptionValue
            tmuxNumber
      END

      return syn_groups->index(a:highlight_group) >= 0 || char_under_cursor =~# '\s'
endfunction

" 'public' function {{{2

function! tmux#man(...)
  let keyword = expand("<cWORD>")
  let retval = 0

"  let highlight_group = synID(".", col("."), 1)->synIDattr("name")
  let highlight_group = synIDattr(synID(line("."), col("."), 1), "name")
  let just_open = s:just_open_manpage(highlight_group)
  if just_open
    Man tmux
    let retval = just_open
  elseif s:highlight_group_to_match_mapping->has_key(highlight_group)
    let retval = s:highlight_group_based_jump(highlight_group, keyword)
  else
    let retval = s:keyword_based_jump(highlight_group, keyword)
  endif

  if retval == 0
    let keyword = expand("<cword>")
    if s:highlight_group_to_match_mapping->has_key(highlight_group)
      let retval = s:highlight_group_based_jump(highlight_group, keyword)
    else
      let retval = s:keyword_based_jump(highlight_group, keyword)
    endif
  endif
  return retval
endfunction

" g! {{{1
" g! is inspired and in good part copied from https://github.com/tpope/vim-scriptease

function! s:opfunc(type) abort
  let sel_save = &selection
  let cb_save = &clipboard
  let reg_save = @@
  try
    set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
    if a:type =~ '^\d\+$'
      silent exe 'normal! ^v'.a:type.'$hy'
    elseif a:type =~# '^.$'
      silent exe "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'line'
      silent exe "normal! '[V']y"
    elseif a:type ==# 'block'
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe "normal! `[v`]y"
    endif
    redraw
    return @@
  finally
    let @@ = reg_save
    let &selection = sel_save
    let &clipboard = cb_save
  endtry
endfunction

function! tmux#filterop(type) abort
  let reg_save = @@
  try
    let expr = s:opfunc(a:type)
    let lines = split(expr, "\n")
    let all_output = ""
    let index = 0
    while index < len(lines)
      let line = lines[index]

      " if line is a part of multi-line string (those have '\' at the end)
      " and not last line, perform " concatenation
      while line =~# '\\\s*$' && index !=# len(lines)-1
        let index += 1
        " remove '\' from line end
        let line = substitute(line, '\\\s*$', '', '')
        " append next line
        let line .= lines[index]
      endwhile

      " skip empty line and comments
      if line =~# '^\s*#' ||
       \ line =~# '^\s*$'
        continue
      endif

      let command = "tmux ".line
      if all_output =~# '\S'
        let all_output .= "\n".command
      else  " empty var, do not include newline first
        let all_output = command
      endif

      let output = system(command)
      if v:shell_error
        throw output
      elseif output =~# '\S'
        let all_output .= "\n> ".output[0:-2]
      endif

      let index += 1
    endwhile

    if all_output =~# '\S'
      redraw
      echo all_output
    endif
  catch /^.*/
    redraw
    echo all_output | echohl ErrorMsg | echo v:exception | echohl NONE
  finally
    let @@ = reg_save
  endtry
endfunction
