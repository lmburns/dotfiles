fun! s:curr_file() abort
    let l:has_forest = executable('git-forest')
    if l:has_forest == 1
        unlet g:flog_build_log_command_fn
    endif
    Flog -raw-args=--follow -path=%
    if l:has_forest
        let g:flog_build_log_command_fn = "flog#build_git_forest_log_command"
    endif
endfun

fun! plugs#flog#setup() abort
    let l:has_forest = executable('git-forest')
    let g:flog_default_opts = {'max_count': 1000}
    " let g:flog_use_internal_lua = v:true

    if l:has_forest
        let g:flog_build_log_command_fn = "flog#build_git_forest_log_command"
    endif

    " Flog
    nnoremap <Leader>gl :Flog<CR>
    " Flog current file
    nnoremap <Leader>gi :call s:curr_file()<CR>
endfun
