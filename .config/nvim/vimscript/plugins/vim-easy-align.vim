let g:easy_align_delimiters = {
    \ '>': { 'pattern': '>>\|=>\|>' },
    \ '\': { 'pattern': '\\' },
    \ '/': { 'pattern': '//\+\|/\*\|\*/', 'delimiter_align': 'l', 'ignore_groups': ['!Comment'] },
    \ ']': {
    \     'pattern':       '\]\zs',
    \     'left_margin':   0,
    \     'right_margin':  1,
    \     'stick_to_left': 0
    \   },
    \ ')': {
    \     'pattern':       ')\zs',
    \     'left_margin':   0,
    \     'right_margin':  1,
    \     'stick_to_left': 0
    \   },
    \ 'f': {
    \     'pattern': ' \(\S\+(\)\@=',
    \     'left_margin': 0,
    \     'right_margin': 0
    \   },
    \ 'd': {
    \     'pattern': ' \ze\S\+\s*[;=]',
    \     'left_margin': 0,
    \     'right_margin': 0
    \   }
    \ }

xmap ga <Plug>(EasyAlign)
xmap <Leader>ga <Plug>(LiveEasyAlign)
xmap <Leader>gi :EasyAlign//ig['Comment']<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
xmap <Leader>gs :EasyAlign//ig['String']<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
