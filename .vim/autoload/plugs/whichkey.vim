fun! plugs#whichkey#setup() abort
    let g:which_key_sort_horizontal = 1
    let g:which_key_sep = ''
    let g:which_key_display_names = {' ': '', '<CR>': '↵', '<C-H>': '', '<C-I>': 'ﲑ', '<TAB>': '⇆'}

    nnoremap <silent> <Leader>      :<C-u>WhichKey '<Space>'<CR>
    nnoremap <silent> <LocalLeader> :<C-u>WhichKey ','<CR>
    vnoremap <silent> <Leader>      :<C-u>WhichKeyVisual '<Space>'<CR>
    vnoremap <silent> <LocalLeader> :<C-u>WhichKeyVisual ','<CR>

    nnoremap <silent> <F3>      :<C-u>WhichKey ''<CR>
    vnoremap <silent> <F3>      :<C-u>WhichKeyVisual ''<CR>

    nnoremap <silent> <Leader>wh      :<C-u>WhichKey ''<CR>
    nnoremap <silent> <Leader><CR>    :<C-u>WhichKey '<Space>'<CR>
    nnoremap <silent> <LocalLeader><CR> :<C-u>WhichKey ','<CR>
    nnoremap <silent> ;<CR> :<C-u>WhichKey ';'<CR>
    nnoremap <silent> ;<Space> :<C-u>WhichKey ';'<CR>
    nnoremap <silent> g<CR> :<C-u>WhichKey 'g'<CR>
    nnoremap <silent> [<CR> :<C-u>WhichKey '['<CR>
    nnoremap <silent> ]<CR> :<C-u>WhichKey ']'<CR>
    nnoremap <silent> <C-x><CR> :<C-u>WhichKey '\<C-x\>'<CR>
    nnoremap <silent> <C-w><CR> :<C-u>WhichKey '\<C-w\>'<CR>
    nnoremap <silent> c<CR> :<C-u>WhichKey 'c'<CR>
    nnoremap <silent> d<CR> :<C-u>WhichKey 'd'<CR>
    nnoremap <silent> y<CR> :<C-u>WhichKey 'y'<CR>
    nnoremap <silent> s<CR> :<C-u>WhichKey 's'<CR>
    nnoremap <silent> s<Space> :<C-u>WhichKey 's'<CR>
    nnoremap <silent> q<CR> :<C-u>WhichKey 'q'<CR>
    nnoremap <silent> q<Space> :<C-u>WhichKey 'q'<CR>
    nnoremap <silent> z<CR> :<C-u>WhichKey 'z'<CR>
    nnoremap <silent> cr<CR> :<C-u>WhichKey 'cr'<CR>
    nnoremap <silent> gc<CR> :<C-u>WhichKey 'gc'<CR>
    nnoremap <silent> ga<CR> :<C-u>WhichKey 'ga'<CR>
    nnoremap <silent> '<CR> :<C-u>WhichKey "'"<CR>
    nnoremap <silent> '<Space> :<C-u>WhichKey "'"<CR>
    nnoremap <silent> `<CR> :<C-u>WhichKey "`"<CR>
    nnoremap <silent> `<Space> :<C-u>WhichKey "`"<CR>

    " onoremap <silent> <Leader>      :<C-u>WhichKeyVisual '<Space>'<CR>

    call which_key#register('<Space>', 'g:which_key_map')
    call which_key#register('<Space>', "g:which_key_map_v", 'v')

    if !exists('g:which_key_map')
        let g:which_key_map = {}
    endif

    if !exists('g:which_key_map_v')
        let g:which_key_map_v = {}
    endif

    " if !exists('g:which_key_map_o')
    "     let g:which_key_map_o = {}
    " endif
endfun
