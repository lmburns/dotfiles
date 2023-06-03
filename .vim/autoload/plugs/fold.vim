function s:set_fold_opt() abort
    setlocal foldenable foldlevel=99
    setlocal foldtext=FoldText()
endfunction

function s:load_treesitter() abort
    let b:lazy_load_fold = str2nr(expand('<abuf>'))
    augroup FoldLazyLoad
        autocmd! BufEnter <buffer=abuf>
        autocmd BufEnter <buffer=abuf> call timer_start(2000, function('s:lazy_load_treesitter'))
    augroup END
endfunction

function s:lazy_load_treesitter(timer) abort
    if exists('b:lazy_load_fold') && b:lazy_load_fold
        call s:set_fold_opt()
        setlocal foldmethod=expr
        setlocal foldexpr=nvim_treesitter#foldexpr()
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . b:lazy_load_fold . '>'
        augroup END
        unlet b:lazy_load_fold
    endif
endfunction

function s:load_anyfold() abort
    let fsize = getfsize(expand('<afile>'))
    if fsize < 524288 && fsize > 0
        let b:lazy_load_fold = str2nr(expand('<abuf>'))
        augroup FoldLazyLoad
            autocmd! BufEnter <buffer=abuf>
            autocmd BufEnter <buffer=abuf> call timer_start(2000, function('s:lazy_load_anyfold'))
        augroup END
    endif
endfunction

function s:lazy_load_anyfold(timer) abort
    if exists('b:lazy_load_fold') && b:lazy_load_fold
        call s:set_fold_opt()
        execute 'AnyFoldActivate'
        augroup FoldLazyLoad
            execute 'autocmd! BufEnter <buffer=' . b:lazy_load_fold . '>'
        augroup END
        unlet b:lazy_load_fold
    endif
endfunction

func! plugs#fold#nav(forward, count)
    let view = winsaveview()
    normal! m'
    let cnt = a:count
    while cnt > 0
        if a:forward
            execute 'keepjumps normal! ]z'
        else
            execute 'keepjumps normal! zk'
        endif
        let cur_pos = getpos('.')
        if a:forward
            execute 'keepjumps normal! zj_'
        else
            execute 'keepjumps normal! [z_'
        endif
        let cnt -= 1
    endwhile
    if cur_pos == getpos('.')
        call winrestview(view)
    else
        normal! m'
    endif
endf

function! FoldText() abort
    let fs = v:foldstart
    while getline(fs) !~ '\w'
        let fs = nextnonblank(fs + 1)
    endwhile

    if fs > v:foldend
        let line = getline(v:foldstart)
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif

    if &number
        let num_wid = 2 + float2nr(log10(line('$')))
        if num_wid < &numberwidth
            let num_wid = &numberwidth
        endif
    else
        if &relativenumber
            let num_wid = &numberwidth
        else
            let num_wid = 0
        endif
    endif

    " TODO how to calculate the signcolumn width? (per width with 2 chars)
    let width = winwidth(0) - &foldcolumn - num_wid  - 2 * 1
    let fold_size_str = ' ' .string(1 + v:foldend - v:foldstart) . ' lines '
    let fold_level_str = repeat(' + ', v:foldlevel)
    let spaces = repeat(' ', width - strwidth(fold_size_str . line . fold_level_str))
    return line . spaces . fold_size_str . fold_level_str
endfunction

fun! plugs#fold#commands() abort
    com! -nargs=0 AnyFold call <SID>set_fold_opt() | AnyFoldActivate
    com! -nargs=0 TreesitterFold call <SID>set_fold_opt() |
                \ setl foldmethod=expr foldexpr=nvim_treesitter#foldexpr()
endfun

fun! plugs#fold#autocmds() abort
    aug lmb__FoldLazyLoad
        au!
        au FileType vim,python,yaml,xml,html,make,sql,tmux call <SID>load_anyfold()
        au FileType c,cpp,go,rust,java,lua,javascript,typescript,css,json,sh,zsh
                    \ if has('nvim-0.5') | call <SID>load_treesitter() |
                    \ else | call <SID>load_anyfold() | endif
    aug END
endfun

func! plugs#fold#mappings() abort
    " Refocus folds
    nmap <LocalLeader>z zMzvzz
    " Center or top current line
    nnoremap <expr> zz (winline() == (winheight(0)+1)/2) ? 'zt' : (winline()==1) ? 'zb' : 'zz'

    " Toggle fold
    nnoremap <expr><silent> z; ((foldclosed('.') < 0) ? 'zc' : 'zo')
    " Toggle all folds
    nnoremap <expr><silent> z' ((foldclosed('.') < 0) ? 'zM' : 'zR')
    " Toggle one/all folds under cursor
    nnoremap <expr><silent> zy ((foldclosed('.') < 0) ? 'zA' : 'za')

    " Inside foldblock
    xnoremap iz <Cmd>keepj norm [zjo]zkL<CR>
    " Inside foldblock
    onoremap iz :norm viz<CR>
    " Around foldblock
    xnoremap az <Cmd>keepj norm [zo]zjLV<CR>
    " Around foldblock
    onoremap az :norm vaz<CR>

    " Top open fold (foldlvls)
    nnoremap <silent> [z [z_
    xnoremap <silent> [z [z_
    " Bottom open fold (foldlvls)
    nnoremap <silent> ]z ]z_
    xnoremap <silent> ]z ]z_
    " Next fold start
    " nnoremap <silent> z] zj_
    xnoremap <silent> z] zj_
    nnoremap <silent> z] <Cmd>call plugs#fold#nav(1, v:count1)<CR>
    " Prev fold bottom
    " nnoremap <silent> z[ zk_
    xnoremap <silent> z[ zk_
    nnoremap <silent> z[ <Cmd>call plugs#fold#nav(0, v:count1)<CR>
    " Next fold start
    nnoremap <silent> zl zj_
    xnoremap <silent> zl zj_

    " Prev fold start
    " nnoremap <silent> zl ufo.goPreviousStartFold
    " xnoremap <silent> zl ufo.goPreviousStartFold
    " Next closed fold
    " nnoremap <silent> z. ufo.goNextClosedFold
    " xnoremap <silent> z. ufo.goNextClosedFold
    " Prev closed fold
    " nnoremap <silent> z, ufo.goPreviousClosedFold
    " xnoremap <silent> z, ufo.goPreviousClosedFold
    " Close folds with v:count
    " nnoremap <silent> zK ufo.closeFoldsWith
    " xnoremap <silent> zK ufo.closeFoldsWith
    " " Open all folds (keep 'fdl')
    " nnoremap <silent> zR ufo.openAllFolds
    " xnoremap <silent> zR ufo.openAllFolds
    " Close all folds (keep 'fdl')
    " nnoremap <silent> zM ufo.closeAllFolds
    " xnoremap <silent> zM ufo.closeAllFolds
endf

fun! plugs#fold#setup() abort
    let g:anyfold_fold_display = 0
    let g:anyfold_identify_comments = 0
    let g:anyfold_motion = 0

    call plugs#fold#autocmds()
    call plugs#fold#commands()
    call plugs#fold#mappings()
endfun
