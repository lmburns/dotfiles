"      \                                'mkdxCheckboxEmpty': 'conceal cchar=1',
"      \                                'mkdxCheckboxPending': 'conceal cchar=2',
"      \                                'mkdxCheckboxComplete': 'conceal cchar=3',
"      \                                'mkdxCheckboxEmpty': '',
"      \                                'mkdxCheckboxPending': '',
"      \                                'mkdxCheckboxComplete': '',

let g:mkdx#settings = {
                  \ 'tab': {'enable': 1},
                  \ 'insert_indent_mappings': 0,
                  \ 'restore_visual': 0,
                  \ 'auto_update': {'enable': 0},
                  \ 'gf_on_steroids': 0,
                  \ 'map': {'enable': 1, 'prefix': 'M'},
                  \ 'fold': {'components': ['toc', 'fence'], 'enable': 0},
                  \ 'enter': {
                  \     'close_pum': 0,
                  \     'shifto': 0,
                  \     'enable': 0,
                  \     'increment': 1,
                  \     'malformed': 1,
                  \     'shift': 0,
                  \     'o': 0
                  \ },
                  \ 'highlight': {'enable': 0, 'frontmatter': {'json': 0, 'toml': 0, 'yaml': 1}},
                  \ 'toc': {
                  \     'update_on_write': 0,
                  \     'list_token': '-',
                  \     'text': 'Table of Contents',
                  \     'position': 0,
                  \     'details': {
                  \         'enable': 0,
                  \         'child_count': 5,
                  \         'child_summary': 'show {{count}} items',
                  \         'summary': 'Expand {{toc.text}}',
                  \         'nesting_level': -1
                  \     }
                  \ },
                  \ 'table': {
                  \     'header_divider': '-',
                  \     'divider': '|',
                  \     'align': {
                  \         'right': [],
                  \         'center': [],
                  \         'left': [],
                  \         'default': 'center'
                  \     }
                  \ },
                  \ 'tokens': {
                  \     'list': '-',
                  \     'bold': '**',
                  \     'italic': '*',
                  \     'fence': '`',
                  \     'header': '#',
                  \     'enter': ['>'],
                  \     'strike': '~~'
                  \ },
                  \ 'checkbox': {
                  \     'update_tree': 2,
                  \     'toggles': [' ', '-', 'X'],
                  \     'initial_state': ' ',
                  \     'match_attrs': {
                  \         'mkdxCheckboxPending': '',
                  \         'mkdxCheckboxComplete': '',
                  \         'mkdxCheckboxEmpty': ''
                  \     }
                  \ },
                  \ 'image_extension_pattern': 'a\?png\|jpe\?g\|gif',
                  \ 'links': {
                  \     'conceal': 1,
                  \     'external': {
                  \         'host': '',
                  \         'timeout': 3,
                  \         'enable': 1,
                  \         'relative': 1,
                  \         'user_agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/537.36'
                  \               .. '(KHTML, like Gecko) Chrome/9001.0.0000.000 vim-mkdx/1.10.0'
                  \     },
                  \     'fragment': {
                  \         'jumplist': 1,
                  \         'complete': 1,
                  \         'pumheight': 15,
                  \         'completeopt': 'noinsert,menuone'
                  \     }
                  \ },
                  \}

function! <SID>MkdxGoToHeader(header)
      call cursor(str2nr(get(matchlist(a:header, ' *\([0-9]\+\)'), 1, '')), 1)
endfunction

function! <SID>MkdxFormatHeader(key, val)
      let text = get(a:val, 'text', '')
      let lnum = get(a:val, 'lnum', '')

      if (empty(text) || empty(lnum)) | return text | endif
      return repeat(' ', 4 - strlen(lnum)) . lnum . ': ' . text
endfunction

function! <SID>MkdxFzfQuickfixHeaders()
      let headers = filter(
                        \ map(mkdx#QuickfixHeaders(0),function('<SID>MkdxFormatHeader')),
                        \ 'v:val != ""'
                        \ )

      call fzf#run(fzf#wrap({
                        \ 'source': headers,
                        \ 'sink': function('<SID>MkdxGoToHeader')
                        \ }))
endfunction

augroup lmb__MkdxBindings
      autocmd!
      autocmd FileType vimwiki,markdown
            \ nnoremap <silent> <LocalLeader>i :call <SID>MkdxFzfQuickfixHeaders()<Cr>|
            \ nnoremap <silent> Mc <Plug>(mkdx-text-inline-code-n)|
            \ nnoremap <silent> mB :<C-U>call mkdx#WrapText('n', '***', '***', 'custom-bold-italic')<CR>|
            \ nnoremap <silent> m, :<C-U>call mkdx#WrapText('n', '***', '***', 'custom-bold-italic')<CR>|
            \ nnoremap <silent> m: :<C-U>call mkdx#WrapText('n', ':', ':', 'custom-tag')<CR>|
            \ nmap <silent> m- <Plug>(mkdx-checkbox-prev-n)|
            \ nmap <silent> m= <Plug>(mkdx-checkbox-next-n)|
            \ nmap <silent> m= <Plug>(mkdx-toggle-checkbox-n)|
            \ nmap <silent> gl; <Plug>(mkdx-wrap-link-n)|
            \ nmap <silent> glL <Plug>(mkdx-wrap-link-n)|
            \ nmap <silent> mi <Plug>(mkdx-gen-or-upd-toc)|
            \ nmap <silent> mj <Plug>(mkdx-jump-to-header)|
            \ nmap <silent> mk <Plug>(mkdx-toggle-to-kbd-n)|
            \ nmap <silent> mI <Plug>(mkdx-quickfix-toc)|
            \ nmap <silent> mL <Plug>(mkdx-quickfix-links)|
            \ nmap <silent> mb <Plug>(mkdx-text-bold-n)|
            \ nmap <silent> mS <Plug>(mkdx-text-strike-n)|
            \ nmap <silent> mc <Plug>(mkdx-text-inline-code-n)|
            \ nmap <silent> m' <Plug>(mkdx-toggle-quote-n)|
            \ nmap <silent> m/ <Plug>(mkdx-text-italic-n)|
            \ vmap <silent> mb <Plug>(mkdx-text-bold-v)|
            \ vmap <silent> mS <Plug>(mkdx-text-strike-v)|
            \ vmap <silent> mc <Plug>(mkdx-text-inline-code-v)|
            \ vmap <silent> m' <Plug>(mkdx-toggle-quote-v)|
            \ vmap <silent> m/ <Plug>(mkdx-text-italic-v)|
            \ vmap <silent> mB :<C-U>call mkdx#WrapText('v', '***', '***', 'custom-bold-italic')<CR>|
            \ vmap <silent> m, :<C-U>call mkdx#WrapText('v', '***', '***', 'custom-bold-italic')<CR>|
            \ vmap <silent> m: :<C-U>call mkdx#WrapText('v', ':', ':', 'custom-tag')<CR>|
            \ vmap <silent> <Leader>tc <Plug>(mkdx-tableize)|
augroup END
" \ nunmap M[ |
" \ nunmap M]

" imap <buffer><silent><unique> <<Tab> <kbd></kbd><C-o>2h<C-o>cit
" inoremap <buffer><silent><unique> ~~~ ```<Enter>```<C-o>k<C-o>A

" vnoremap <buffer><silent> mb <Plug>(mkdx-text-bold-v)
" nmap Mb <Plug>(mkdx-text-bold-n)
" vmap Mb <Plug>(mkdx-text-bold-v)
