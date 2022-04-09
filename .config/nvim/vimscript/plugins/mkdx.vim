let g:mkdx#settings     = {
      \ 'restore_visual': 1,
      \ 'gf_on_steroids': 1,
      \ 'highlight': { 'enable':   1 },
      \ 'enter':     { 'shift':    1 },
      \ 'map':       { 'prefix': 'm', 'enable': 1 },
      \ 'links':     { 'external': { 'enable': 1 } },
      \ 'checkbox':  {'toggles': [' ', 'x', '-'] },
      \ 'tokens':    { 'strike': '~~',
      \                'list': '*' },
      \ 'fold':      { 'enable':   1,
      \                'components': ['fence'] },
      \ }

" \ 'fold':      { 'enable':   1,
" \                'components': ['toc', 'fence'] },
" \ 'toc': {
" \    'text': 'Table of Contents',
" \    'update_on_write': 0,
" \    'details': { 'nesting_level': 0 }
" \ }

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

nnoremap <silent> <Leader>I :call <SID>MkdxFzfQuickfixHeaders()<Cr>
