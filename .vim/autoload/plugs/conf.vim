fun! plugs#conf#startuptime() abort
    let g:startuptime_tries = 15
    let g:startuptime_exe_args = ["+let g:auto_session_enabled = 0"]
endfun

fun! plugs#conf#suda() abort
    nnoremap <silent> <Leader>W <Cmd>SudaWrite<CR>
endfun

fun! plugs#conf#splitjoin() abort
    let g:splitjoin_join_mapping = 'gS'
    let g:splitjoin_split_mapping = 'gJ'
endfun

fun! plugs#conf#linediff() abort
    nnoremap <silent> <Leader>ld :Linediff<CR>
    xnoremap <silent> <Leader>ld :Linediff<CR>
    nnoremap <silent> <Leader>lD :LinediffReset<CR>
    xnoremap <silent><expr> D (mode() ==# "V" ? ':Linediff<CR>' : 'D')
    cnoreabbrev ldr LinediffReset
endfun

fun! plugs#conf#eregex() abort
    let g:eregex_default_enable = 0
    let g:eregex_forward_delim = "/"
    let g:eregex_backward_delim = "?"

    " Toggle eregex
    nnoremap <silent> <Leader>es <Cmd>call eregex#toggle()<CR>
    " Toggle eregex
    nnoremap <silent> ,/ <Cmd>call eregex#toggle()<CR>
    " Global replace (E2v)
    nnoremap <Leader>S :%S//g<Left><Left>
endfun

fun! plugs#conf#caser() abort
    let g:caser_prefix = 'cr'
    nmap <silent> crs <Plug>CaserSnakeCase
    nmap <silent> crd <Plug>CaserDotCase
    nmap <silent> crS <Plug>CaserSentenceCase
endfun

fun! plugs#conf#subversive() abort
    nmap <silent> s <Plug>(SubversiveSubstitute)
    nmap <silent> ss <Plug>(SubversiveSubstituteLine)
    nmap <silent> se <Plug>(SubversiveSubstituteToEndOfLine)
    nmap <silent> <Leader>sr <Plug>(SubversiveSubstituteRange)
    nmap <silent> sr <Plug>(SubversiveSubstituteWordRange)
    xmap <silent> ss <Plug>(SubversiveSubstituteRange)
    nmap <silent> sd <Plug>(SubversiveSubstituteRangeDelete)
endfun

fun! plugs#conf#exchange() abort
    nmap <silent> sx <Plug>(Exchange)
    nmap <silent> sxx <Plug>(ExchangeLine)
    nmap <silent> sxc <Plug>(ExchangeClear)
    xmap <silent> X <Plug>(Exchange)
endfun

fun! plugs#conf#definitive() abort
    nnoremap <Leader>D <Cmd>FindDefinition<CR>
    xnoremap <Leader>D "ay:FindDefinition <C-R>a<CR>
endfun

fun! plugs#conf#ultisnips() abort
    let g:UltiSnipsExpandTrigger = "<Nop>"
    let g:UltiSnipsListSnippets  = "<Nop>"
    let g:UltiSnipsEditSplit     = "horizontal"
    let g:UltiSnipsRemoveSelectModeMappings = 0

    " let g:UltiSnipsJumpForwardTrigger  = '<C-j>'
    " let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
    " let g:UltiSnipsListSnippets        = "<C-u>"
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

" Highlight the yanked region. Similar to neovim's HighlightedyankRegion
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

" Highlight the undone region
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
    nmap <silent> vs <Plug>(swap-interactive)
    xmap <silent> vs <Plug>(swap-interactive)
    nmap <silent> sv <Plug>(swap-interactive)
    xmap <silent> sv <Plug>(swap-interactive)
    nmap <silent> s, <Plug>(swap-prev)
    nmap <silent> s. <Plug>(swap-next)
    nmap <silent> sh <Plug>(swap-textobject-i)
    nmap <silent> sl <Plug>(swap-textobject-a)
endfun

fun! plugs#conf#niceblock() abort
    xmap <silent> I  <Plug>(niceblock-I)
    xmap <silent> gI <Plug>(niceblock-gI)
    xmap <silent> A  <Plug>(niceblock-A)
endfun

fun! plugs#conf#lf() abort
  let g:lf_map_keys = 0
  let g:lf_replace_netrw = 1
  nnoremap <silent> <M-o> <Cmd>Lf<CR>
endfun

fun! plugs#conf#marks() abort
    " List buffer marks
    nnoremap <silent> qm <Cmd>SignatureListBufferMarks<CR>
    " List global marks
    nnoremap <silent> qM <Cmd>SignatureListGlobalMarks<CR>

    " List buffer marks
    nnoremap <silent> <Leader>mm <Cmd>SignatureListBufferMarks<CR>
    " List global marks
    nnoremap <silent> <Leader>mlg <Cmd>SignatureListGlobalMarks<CR>

    " Standard listing of marks
    nnoremap <Leader>mlm <Cmd>marks<CR>
    " Delete all marks in buffer
    nnoremap <Leader>mfD <Cmd>delmarks a-zA-Z0-9<CR>
    " Delete all uppercase marks
    nnoremap <Leader>mfd <Cmd>delmarks A-Z<CR>
    " Delete all lowercase marks
    nnoremap <Leader>mld <Cmd>delmarks a-z<CR>
endfun
