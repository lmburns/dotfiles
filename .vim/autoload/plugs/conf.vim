fun! plugs#conf#startuptime() abort
    let g:startuptime_tries = 15
    let g:startuptime_exe_args = ["+let g:auto_session_enabled = 0"]
endfun

fun! plugs#conf#suda() abort
    nnoremap <silent> <Leader>W :SudaWrite<CR>
endfun

fun! plugs#conf#splitjoin() abort
    let g:splitjoin_join_mapping = 'gS'
    let g:splitjoin_split_mapping = 'gJ'
endfun

fun! plugs#conf#linediff() abort
    nnoremap <silent> <Leader>ld :Linediff<CR>
    xnoremap <silent> <Leader>ld :Linediff<CR>
    nnoremap <silent> <Leader>lD :LinediffReset<CR>
    xnoremap <expr> D (mode() ==# "V" ? ':Linediff<CR>' : 'D')
    cnoreabbrev ldr LinediffReset
endfun

fun! plugs#conf#eregex() abort
    let g:eregex_default_enable = 0
    let g:eregex_forward_delim = "/"
    let g:eregex_backward_delim = "?"

    " Toggle eregex
    nnoremap <Leader>es <Cmd>call eregex#toggle()<CR>
    " Toggle eregex
    nnoremap ,/ <Cmd>call eregex#toggle()<CR>
    " Global replace (E2v)
    nnoremap <Leader>S :%S//g<Left><Left>
endfun

fun! plugs#conf#caser() abort
    let g:caser_prefix = 'cr'
    nmap crs <Plug>CaserSnakeCase
    nmap crd <Plug>CaserDotCase
    nmap crS <Plug>CaserSentenceCase
endfun

fun! plugs#conf#subversive() abort
    nmap s <Plug>(SubversiveSubstitute)
    nmap ss <Plug>(SubversiveSubstituteLine)
    nmap se <Plug>(SubversiveSubstituteToEndOfLine)
    nmap <Leader>sr <Plug>(SubversiveSubstituteRange)
    nmap sr <Plug>(SubversiveSubstituteWordRange)
    xmap ss <Plug>(SubversiveSubstituteRange)
    nmap sd <Plug>(SubversiveSubstituteRangeDelete)
endfun

fun! plugs#conf#exchange() abort
    nmap sx <Plug>(Exchange)
    nmap sxx <Plug>(ExchangeLine)
    nmap sxc <Plug>(ExchangeClear)
    xmap X <Plug>(Exchange)
endfun

fun! plugs#conf#definitive() abort
    nnoremap <Leader>D :FindDefinition<CR>
    xnoremap <Leader>D "ay:FindDefinition <C-R>a<CR>
endfun

fun! plugs#conf#ultisnips() abort
    let g:UltiSnipsExpandTrigger = "<Nop>"
    let g:UltiSnipsListSnippets = "<Nop>"
    let g:UltiSnipsEditSplit = "horizontal"
endfun

fun! plugs#conf#delimit() abort
    let g:delimitMate_jump_expansion = 1
    let g:delimitMate_expand_cr = 2
    " <BS>     <Plug>delimitMateBS
    " <S-BS>   <Plug>delimitMateS-BS
    " <S-Tab>  <Plug>delimitMateS-Tab
    " <C-G>g   <Plug>delimitMateJumpMany
    imap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() :
                \ (getline('.') =~ '^\s*$' ? '' : "\<C-g>u")."\<Plug>delimitMateCR"

    " \<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
endfun

fun! plugs#conf#hlyank() abort
    if !exists('##TextYankPost')
        nmap y <Plug>(highlightedyank)
        xmap y <Plug>(highlightedyank)
        omap y <Plug>(highlightedyank)
    endif
    let g:highlightedyank_highlight_duration = 350
    hi clear HighlightedyankRegion
    hi HighlightedyankRegion gui=bold guifg=#A06469
endfun

fun! plugs#conf#hlundo() abort
    nmap u <Plug>(highlightedundo-undo)
    nmap U <Plug>(highlightedundo-redo)
    " nmap <C-S-u> <Plug>(highlightedundo-Undo)

   let g:highlightedundo#highlight_mode = 1
   let g:highlightedundo#highlight_duration_delete = 250
   let g:highlightedundo#highlight_duration_add = 500

    hi link HighlightedundoAdd DiffAdd
    hi link HighlightedundoDelete DiffDelete
    hi link HighlightedundoChange DiffChange
endfun

fun! plugs#conf#swap() abort
    let g:swap_no_default_key_mappings = 1
    nmap vs <Plug>(swap-interactive)
    xmap vs <Plug>(swap-interactive)
    nmap sv <Plug>(swap-interactive)
    xmap sv <Plug>(swap-interactive)
    nmap s, <Plug>(swap-prev)
    nmap s. <Plug>(swap-next)
    nmap sh <Plug>(swap-textobject-i)
    nmap sl <Plug>(swap-textobject-a)
endfun

fun! plugs#conf#niceblock() abort
    xmap I <Plug>(niceblock-I)
    xmap gI <Plug>(niceblock-gI)
    xmap A <Plug>(niceblock-A)
endfun

fun! plugs#conf#lf() abort
  let g:lf_map_keys = 0
  let g:lf_replace_netrw = 1
  nnoremap <M-o> :Lf<CR>
endfun

fun! plugs#conf#marks() abort
    nnoremap <silent> qm :SignatureListBufferMarks<CR>
    nnoremap <silent> qM :SignatureListGlobalMarks<CR>
endfun
