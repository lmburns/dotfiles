fun! plugs#easymotion#setup() abort
    let g:EasyMotion_do_mapping = 0
    let g:EasyMotion_do_shade = 1
    let g:EasyMotion_use_smartsign_us = 1
    let g:EasyMotion_smartcase = 1
    let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyz;'
    let g:EasyMotion_enter_jump_first = 1
    let g:EasyMotion_add_search_history = 1
    let g:EasyMotion_off_screen_search = 1
    let g:EasyMotion_startofline = 0
    let g:EasyMotion_skipfoldedline = 0
    let g:EasyMotion_inc_highlight = 1

    hi link EasyMotionMoveHL Search
    hi link EasyMotionIncSearch Search
    " \ , 'cterm256': ['011', '160'     , 'bold']
    " \ , 'cterm'   : ['yellow', 'red'     , 'bold']
    let s:target_hl_defaults = {
                \   'gui'     : ['#EF1D55', '#A25BC4' , 'bold']
                \ }

    autocmd! User EasyMotionPromptBegin silent! easycompleteDisable
    autocmd! User EasyMotionPromptEnd   silent! easycompleteEnable

    nmap f  <Plug>(easymotion-fl)
    xmap f  <Plug>(easymotion-fl)
    omap f  <Plug>(easymotion-fl)
    nmap t  <Plug>(easymotion-tl)
    xmap t  <Plug>(easymotion-tl)
    omap t  <Plug>(easymotion-tl)
    nmap F  <Plug>(easymotion-Fl)
    xmap F  <Plug>(easymotion-Fl)
    omap F  <Plug>(easymotion-Fl)
    nmap T  <Plug>(easymotion-Tl)
    xmap T  <Plug>(easymotion-Tl)
    omap T  <Plug>(easymotion-Tl)

    nmap s/ <Plug>(easymotion-bd-f2)

    nmap ;a <Plug>(easymotion-bd-f)
    xmap ;a <Plug>(easymotion-bd-f)
    omap ;a <Plug>(easymotion-bd-f)
    nmap ;A <Plug>(easymotion-bd-f2)
    xmap ;A <Plug>(easymotion-bd-f2)
    omap ;A <Plug>(easymotion-bd-f2)

    nmap <Leader><Leader>j  <Plug>(easymotion-j)
    nmap <Leader><Leader>k  <Plug>(easymotion-k)
    nmap <Leader><Leader>J  <Plug>(easymotion-sol-j)
    nmap <Leader><Leader>K  <Plug>(easymotion-sol-k)

    " nmap <Leader>f  <Plug>(easymotion-s2)

    nmap <Leader><Leader>f <Plug>(easymotion-overwin-f)
    nmap <Leader><Leader>s <Plug>(easymotion-overwin-f2)

    nmap <Leader><Leader>l <Plug>(easymotion-overwin-line)
    xmap <Leader><Leader>l <Plug>(easymotion-bd-jk)
    " omap <Leader><Leader>l <Plug>(easymotion-bd-jk)

    nmap <Leader><Leader>w <Plug>(easymotion-overwin-w)
    xmap <Leader><Leader>w <Plug>(easymotion-bd-w)
    " omap <Leader><Leader>w <Plug>(easymotion-bd-w)

    nmap <Leader><Leader>; <Plug>(easymotion-next)
    nmap <Leader><Leader>, <Plug>(easymotion-prev)

    " map <Leader><Leader>w  <Plug>(easymotion-iskeyword-w)
    " map <Leader><Leader>b  <Plug>(easymotion-iskeyword-b)

    sil! call repeat#set("\<Plug>easymotion/easymotion", v:count)
endfun
