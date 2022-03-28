require("common.utils")

-- Run and view go output in floating or split window
cmd [[
  function! s:run_go(...)
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
  endfunction

  command! GORUNS :call s:run_go("split")
  command! GORUN :call s:run_go("float")

  augroup GoRunCust
    autocmd!
    autocmd FileType go nnoremap <Leader>rv :GORUNS<CR>
    autocmd FileType go nnoremap <Leader>ru :GORUN<CR>
  augroup END
  " au FileType go nmap <Leader>rp <Plug>(go-run)
  " au FileType go nmap <Leader>rv <Plug>(go-run-vertical)

  function! s:build_go_files()
    let l:file = expand('%')
    if l:file =~# '^\f\+_test\.go$'
        call go#test#Test(0, 1)
    elseif l:file =~# '^\f\+\.go$'
        call go#cmd#Build(0)
    endif
  endfunction

  augroup go_env
    autocmd!
    " Note: Do not change the order!
    " Note: Do not comment lines inplace
    " nmap <buffer> <Leader>K <Plug>(go-doc)|
    " let g:go_doc_popup_window = 1
    let g:go_rename_command = 'gopls'
    autocmd FileType go
      \ setl nolist|
      \ nmap <buffer> <Leader>b<CR> :call <SID>build_go_files()<CR>|
      \ nmap <buffer> <Leader>r<CR> <Plug>(go-run)|
      \ nmap <buffer> <Leader>rr    :GoRun %<CR>|
      \ nmap <buffer> <Leader>ri    :GoRun %<space>|
      \ nmap <buffer> <Leader>t<CR> <Plug>(go-test)|
      \ nmap <buffer> <Leader>c<CR> <Plug>(go-coverage-toggle)|
      \ nmap <buffer> <Leader>gae <Plug>(go-alternate-edit)|
      \ nmap <buffer> <Leader>i <Plug>(go-info)|
      \ nmap <buffer> <Leader>sm :GoSameIdsToggle<CR>|
      \ nmap <buffer> <C-A-n> :cnext<CR>|
      \ nmap <buffer> <C-A-m> :cprevious<CR>|
      \ nmap <buffer> <Leader>f :GoDeclsDir<cr>|
      \ nmap <buffer> ;ff :GoFmt<CR>|
      \ let g:go_fmt_command = "goimports"|
      \ let g:go_list_type = "quickfix"|
      \ let g:go_highlight_types = 1|
      \ let g:go_highlight_fields = 1|
      \ let g:go_highlight_functions = 1|
      \ let g:go_highlight_methods = 1|
      \ let g:go_highlight_operators = 1|
      \ let g:go_highlight_build_constraints = 1|
      \ let g:go_highlight_generate_tags = 1|
      \ let g:go_gocode_propose_builtins = 1|
      \ let g:go_gocode_unimported_packages = 1|
      \ let g:go_doc_keywordprg_enabled = 0|
      \ let g:go_fmt_fail_silently = 1|
      \ command! -bang A call go#alternate#Switch(<bang>0, 'edit')|
      \ command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')|
      \ command! -bang AS call go#alternate#Switch(<bang>0, 'split')|
      "\ let g:go_auto_type_info = 1|
      "\ let g:go_updatetime = 100|
      "\ let g:go_auto_sameids = 1|
      "\ let g:go_play_open_browser = 1|
  augroup END
]]
