" run and view go output in floating or split window
fun! s:run_go(...)
    if filereadable(expand("%:r"))
        call delete(expand("%:r"))
    endif
    write
    let arg = get(a:, 1, 0)
    if arg == "split"
        execute 'FloatermNew --autoclose=0 --wintype=vsplit --width=0.5 '
            \ . ' go build ./% && ./%:r'
    elseif arg == "float"
        execute 'FloatermNew --autoclose=0 go build ./% && ./%:r'
    endif
endfun

function! s:build_go_files()
    let l:file = expand('%')
    if l:file =~# '^\f\+_test\.go$'
        call go#test#Test(0, 1)
    elseif l:file =~# '^\f\+\.go$'
        call go#cmd#Build(0)
    endif
endfunction

fun! plugs#ft#go#commands() abort
    com! GORUNS :call s:run_go("split")
    com! GORUN  :call s:run_go("float")
    com! -bang A call go#alternate#Switch(<bang>0, 'edit')
    com! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
    com! -bang AS call go#alternate#Switch(<bang>0, 'split')
endfun

fun! plugs#ft#go#mappings() abort
    " nmap <Leader>rp <Plug>(go-run)
    " nmap <Leader>rv <Plug>(go-run-vertical)
    " nmap <buffer> <Leader>K <Plug>(go-doc)
    nmap <buffer> <Leader>rv <Cmd>GORUNS<CR>
    nmap <buffer> <Leader>ru <Cmd>GORUN<CR>
    nmap <buffer> <Leader>b<CR> <Cmd>call <SID>build_go_files()<CR>
    nmap <buffer> <Leader>r<CR> <Plug>(go-run)
    nmap <buffer> <Leader>rr    <Cmd>GoRun %<CR>
    nmap <buffer> <Leader>ri    :GoRun %<space>
    nmap <buffer> <Leader>t<CR> <Plug>(go-test)
    nmap <buffer> <Leader>c<CR> <Plug>(go-coverage-toggle)
    nmap <buffer> <Leader>gae <Plug>(go-alternate-edit)
    nmap <buffer> <Leader>i <Plug>(go-info)
    nmap <buffer> <Leader>sm <Cmd>GoSameIdsToggle<CR>
    nmap <buffer> <Leader>f <Cmd>GoDeclsDir<CR>
    nmap <buffer> ;ff <Cmd>GoFmt<CR>
endfun

fun! plugs#ft#go#autocmds() abort
    augroup lmb__GoEnv
        au!
        au FileType go
            \ call plugs#ft#go#mappings()
            \ | call plugs#ft#go#commands()
    augroup END
endfun

fun! plugs#ft#go#setup() abort
    let g:go_fmt_command = "goimports"
    let g:go_list_type = "quickfix"
    let g:go_rename_command = 'gopls'
    let g:go_highlight_types = 1
    let g:go_highlight_fields = 1
    let g:go_highlight_functions = 1
    let g:go_highlight_methods = 1
    let g:go_highlight_operators = 1
    let g:go_highlight_build_constraints = 1
    let g:go_highlight_generate_tags = 1
    let g:go_gocode_propose_builtins = 1
    let g:go_gocode_unimported_packages = 1
    let g:go_doc_keywordprg_enabled = 0
    let g:go_fmt_fail_silently = 1
    " let g:go_doc_popup_window = 1
    " let g:go_auto_type_info = 1
    " let g:go_updatetime = 100
    " let g:go_auto_sameids = 1
    " let g:go_play_open_browser = 1

    call plugs#ft#go#autocmds()
endfun
