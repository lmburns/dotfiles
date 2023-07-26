func! s:curr_file() abort
    let l:has_forest = executable('git-forest')
    if l:has_forest == 1
        unlet g:flog_build_log_command_fn
    endif
    Flog -raw-args=--follow -path=%
    if l:has_forest
        let g:flog_build_log_command_fn = "flog#build_git_forest_log_command"
    endif
endfu

func! plugs#flog#setup() abort
    let l:has_forest = executable('git-forest')
    let g:flog_default_opts = {'max_count': 1000}
    " let g:flog_use_internal_lua = v:true

    if l:has_forest
        let g:flog_build_log_command_fn = "flog#build_git_forest_log_command"
    endif

    " Flog
    nnoremap <Leader>gl <Cmd>Flog<CR>
    " Flog current file
    nnoremap <Leader>gi <Cmd>call <SID>curr_file()<CR>

    " Flog: split current file
    nnoremap <Leader>gg <Cmd>Flogsplit -path=%<CR>
    " Flog: tab all
    nnoremap <Leader>yl <Cmd>Flog<CR>
    " Flog: split all
    nnoremap <Leader>yL <Cmd>Flogsplit<CR>
    " Flog current file
    nnoremap <Leader>yi <Cmd>call <SID>curr_file()<CR>
    " " Flog: split current file
    nnoremap <Leader>yI <Cmd>Flogsplit -path=%<CR>
endfu
