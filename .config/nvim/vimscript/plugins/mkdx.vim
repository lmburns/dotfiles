" let g:mkdx#settings     = {
"       \ 'restore_visual': 1,
"       \ 'gf_on_steroids': 1,
"       \ 'highlight': { 'enable':   1 },
"       \ 'enter':     { 'shift':    1 },
"       \ 'map':       { 'prefix': 'M', 'enable': 1 },
"       \ 'links':     { 'external': { 'enable': 1 } },
"       \ 'checkbox':  {'toggles': [' ', 'x', '-'] },
"       \ 'tokens':    { 'strike': '~~',
"       \                'list': '*' },
"       \ 'fold':      { 'enable':   1,
"       \                'components': ['fence'] },
"       \ }

" \ 'fold':      { 'enable':   1,
" \                'components': ['toc', 'fence'] },
" \ 'toc': {
" \    'text': 'Table of Contents',
" \    'update_on_write': 0,
" \    'details': { 'nesting_level': 0 }
" \ }

let g:mkdx#settings = {
      \ 'image_extension_pattern': 'a\?png\|jpe\?g\|gif',
      \ 'insert_indent_mappings':  0,
      \ 'gf_on_steroids':          0,
      \ 'restore_visual':          1,
      \ 'enter':                   { 'enable': 0, 'shift': 0, 'o': 0, 'shifto': 0, 'malformed': 0 },
      \ 'map':                     { 'prefix': 'M', 'enable': 1 },
      \ 'tokens':                  { 'enter':  ['-', '*', '>'],
      \                              'bold':   '**', 'italic': '*',
      \                              'strike': '',
      \                              'list':   '-',  'fence':  '',
      \                              'header': '#' },
      \ 'checkbox':                { 'toggles': [' ', '-', 'x'],
      \                              'update_tree': 2,
      \                              'initial_state': ' ',
      \                              'match_attrs': {
      \                                 'mkdxCheckboxEmpty': '',
      \                                 'mkdxCheckboxPending': '',
      \                                 'mkdxCheckboxComplete': '',
      \                               }, },
      \ 'toc':                     { 'text':       "TOC",
      \                              'list_token': '-',
      \                              'position':   0,
      \                              'update_on_write':   0,
      \                              'details':    {
      \                                 'enable':  0,
      \                                 'summary': '{{toc.text}}',
      \                                 'nesting_level': -1,
      \                                 'child_count': 5,
      \                                 'child_summary': 'show {{count}} items'
      \                              }
      \                            },
      \ 'table':                   { 'divider': '|',
      \                              'header_divider': '-',
      \                              'align': {
      \                                 'left':    [],
      \                                 'right':   [],
      \                                 'center':  [],
      \                                 'default': 'center'
      \                              }
      \                            },
      \ 'links':                   { 'external': {
      \                                 'enable':     0,
      \                                 'timeout':    3,
      \                                 'host':       '',
      \                                 'relative':   1,
      \                              },
      \                              'fragment': {
      \                                 'jumplist': 1,
      \                                 'complete': 1
      \                              },
      \                              'conceal': 1
      \                            },
      \ 'highlight':               {
      \                              'enable': 0,
      \                              'frontmatter': {
      \                                'yaml': 1,
      \                                'toml': 0,
      \                                'json': 0
      \                              }
      \                            },
      \ 'auto_update':             { 'enable': 0 },
      \ 'fold':                    { 'enable': 0, 'components': ['toc'] }
    \ }

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
      \ nnoremap <silent> <Leader>I :call <SID>MkdxFzfQuickfixHeaders()<Cr>|
      \ nnoremap <silent> Mc <Plug>(mkdx-text-inline-code-n)|
      \ nnoremap <silent> mB :<C-U>call mkdx#WrapText('n', '***', '***', 'custom-bold-italic')<CR>|
      \ nnoremap <silent> m, :<C-U>call mkdx#WrapText('n', '***', '***', 'custom-bold-italic')<CR>|
      \ nnoremap <silent> m: :<C-U>call mkdx#WrapText('n', ':', ':', 'custom-tag')<CR>|
      \ nmap <silent> m- <Plug>(mkdx-checkbox-prev-n)|
      \ nmap <silent> m= <Plug>(mkdx-checkbox-next-n)|
      \ nmap <silent> m= <Plug>(mkdx-toggle-checkbox-n)|
      \ nmap <silent> mi <Plug>(mkdx-gen-or-upd-toc)|
      \ nmap <silent> mj <Plug>(mkdx-jump-to-header)|
      \ nmap <silent> mk <Plug>(mkdx-toggle-to-kbd-n)|
      \ nmap <silent> mI <Plug>(mkdx-quickfix-toc)|
      \ nmap <silent> mL <Plug>(mkdx-quickfix-links)|
      \ nmap <silent> mb <Plug>(mkdx-text-bold-n)|
      \ nmap <silent> ms <Plug>(mkdx-text-strike-n)|
      \ nmap <silent> mc <Plug>(mkdx-text-inline-code-n)|
      \ nmap <silent> m' <Plug>(mkdx-toggle-quote-n)|
      \ nmap <silent> m/ <Plug>(mkdx-text-italic-n)|
      \ vmap <silent> mb <Plug>(mkdx-text-bold-v)|
      \ vmap <silent> ms <Plug>(mkdx-text-strike-v)|
      \ vmap <silent> mc <Plug>(mkdx-text-inline-code-v)|
      \ vmap <silent> m' <Plug>(mkdx-toggle-quote-v)|
      \ vmap <silent> m/ <Plug>(mkdx-text-italic-v)|
      \ vmap <silent> mB :<C-U>call mkdx#WrapText('v', '***', '***', 'custom-bold-italic')<CR>|
      \ vmap <silent> m, :<C-U>call mkdx#WrapText('v', '***', '***', 'custom-bold-italic')<CR>|
      \ vmap <silent> m: :<C-U>call mkdx#WrapText('v', ':', ':', 'custom-tag')<CR>|
augroup END
" \ nunmap M[ |
" \ nunmap M]

" imap <buffer><silent><unique> <<Tab> <kbd></kbd><C-o>2h<C-o>cit
" inoremap <buffer><silent><unique> ~~~ ```<Enter>```<C-o>k<C-o>A

" vnoremap <buffer><silent> mb <Plug>(mkdx-text-bold-v)
" nmap Mb <Plug>(mkdx-text-bold-n)
" vmap Mb <Plug>(mkdx-text-bold-v)
