" ==============================================================================
" Vim filetype plugin file
" Language:     jq (Command-line JSON processor)
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-jq
" Last Change:  Aug 16, 2021
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

setlocal comments=:#
setlocal commentstring=#%s
setlocal suffixesadd=.jq,.json
setlocal include=^\\s*\\(import\\\|include\\)
setlocal define=^\\s*def
setlocal formatoptions=cqornlj
setlocal includeexpr=findfile(v:fname)!=''?v:fname:substitute(v:fname,'\\(\\(\\w\\+/\\)*\\)\\(\\w\\+\\)$','\\1\\3/\\3','')

let b:undo_ftplugin = 'setlocal comments< commentstring< suffixesadd< include< define< formatoptions< includeexpr<'


" Append default module search paths to 'path'
let s:paths = split(&path, '\\\@1<!\%(\\\\\)*\zs,')
let s:default_paths = [expand('~/.jq'), simplify(fnamemodify(exepath('jq'), ':h') .. '/../lib/jq')]

call extend(s:paths, filter(s:default_paths, '!count(s:paths, v:val) && isdirectory(v:val)'))
let &l:path = join(s:paths, ',')
unlet s:paths s:default_paths
let b:undo_ftplugin ..= ' | setlocal path<'


" matchit.vim
if exists('g:loaded_matchit')
    let b:match_words =
            \    '\<if\>:\<elif\>:\<else\>:\<end\>,'
            \ .. '\<try\>:\<catch\>,'
            \ .. '\<def\>:\%(([^)]*\|#.\{-}\)\@<!;'
    let b:match_skip = 'synIDattr(synID(line("."), col("."), 1), "name") =~? "comment"'
    let b:undo_ftplugin ..= ' | unlet b:match_words b:match_skip'
endif


if !exists('g:no_plugin_maps') && !exists('g:no_jq_maps')
    " Go to [count] next global function definition
    nnoremap <silent> <buffer> ]] :<c-u>call jq#jump('n', '^def', 'W',  v:count1)<cr>
    xnoremap <silent> <buffer> ]] :<c-u>call jq#jump('x', '^def', 'W',  v:count1)<cr>
    onoremap <silent> <buffer> ]] :<c-u>call jq#jump('o', '^def', 'W',  v:count1)<cr>

    " Go to [count] previous global function definition
    nnoremap <silent> <buffer> [[ :<c-u>call jq#jump('n', '^def', 'Wb', v:count1)<cr>
    xnoremap <silent> <buffer> [[ :<c-u>call jq#jump('x', '^def', 'Wb', v:count1)<cr>
    onoremap <silent> <buffer> [[ :<c-u>call jq#jump('o', '^def', 'Wb', v:count1)<cr>

    " Go to [count] next nested function definition
    nnoremap <silent> <buffer> ]m :<c-u>call jq#jump('n', '^\s\+\zsdef', 'W',  v:count1)<cr>
    xnoremap <silent> <buffer> ]m :<c-u>call jq#jump('x', '^\s\+\zsdef', 'W',  v:count1)<cr>
    onoremap <silent> <buffer> ]m :<c-u>call jq#jump('o', '^\s\+\zsdef', 'W',  v:count1)<cr>

    " Go to [count] previous nested function definition
    nnoremap <silent> <buffer> [m :<c-u>call jq#jump('n', '^\s\+\zsdef', 'Wb', v:count1)<cr>
    xnoremap <silent> <buffer> [m :<c-u>call jq#jump('x', '^\s\+\zsdef', 'Wb', v:count1)<cr>
    onoremap <silent> <buffer> [m :<c-u>call jq#jump('o', '^\s\+\zsdef', 'Wb', v:count1)<cr>

    let b:undo_ftplugin ..=
            \    ' | execute "nunmap <buffer> ]]" | execute "nunmap <buffer> [["'
            \ .. ' | execute "xunmap <buffer> ]]" | execute "xunmap <buffer> [["'
            \ .. ' | execute "ounmap <buffer> ]]" | execute "ounmap <buffer> [["'
            \ .. ' | execute "nunmap <buffer> ]m" | execute "nunmap <buffer> [m"'
            \ .. ' | execute "xunmap <buffer> ]m" | execute "xunmap <buffer> [m"'
            \ .. ' | execute "ounmap <buffer> ]m" | execute "ounmap <buffer> [m"'

    " Enhanced gf
    " FIXME 'E446: No file name under cursor'
    cmap <buffer><script><expr> <plug><cfile> jq#cfile()
    nnoremap <sid>: :<c-u><c-r>=v:count ? v:count : ''<cr>
    nmap <buffer><silent> gf          <sid>:find    <plug><cfile><cr>
    nmap <buffer><silent> <c-w>f      <sid>:sfind   <plug><cfile><cr>
    nmap <buffer><silent> <c-w><c-f>  <sid>:sfind   <plug><cfile><cr>
    nmap <buffer><silent> <c-w>gf     <sid>:tabfind <plug><cfile><cr>
    cmap <buffer>         <c-r><c-f>  <plug><cfile>
    cmap <buffer>         <c-r><c-p>  <c-r>=findfile(expand('<plug><cfile>'))<cr>

    let b:undo_ftplugin ..=
            \    ' | execute "nunmap <buffer> gf"'
            \ .. ' | execute "nunmap <buffer> <c-w>f"'
            \ .. ' | execute "nunmap <buffer> <c-w><c-f>"'
            \ .. ' | execute "nunmap <buffer> <c-w>gf"'
            \ .. ' | execute "cunmap <buffer> <c-r><c-f>"'
            \ .. ' | execute "cunmap <buffer> <c-r><c-p>"'
            \ .. ' | execute "cunmap <buffer> <plug><cfile>"'
endif

let &cpoptions = s:cpo_save
unlet s:cpo_save
