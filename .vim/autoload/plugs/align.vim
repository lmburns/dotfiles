fun! plugs#align#setup()
    let g:easy_align_bypass_fold = 1
    let l:equals = [
                \ '===',
                \ '<=>',
                \ '\(&&\|||\|<<\|>>\)=',
                \ '=\~[#?]\?',
                \ '=>',
                \ ':+/*!%^=><&|.-]\?=[#?]\?',
                \ '\~=',
                \ ]
    let l:gt_sign = ['>>', '=>', '>']
    let l:lt_sign = ['<<', '<=', '<']

    let g:easy_align_delimiters = {
                \ 'f': {'pattern': ' \(\S\+(\)\@=', 'left_margin': 0, 'right_margin': 0},
                \ '>': {'pattern': join(l:gt_sign, '\|')},
                \ '<': {'pattern': join(l:lt_sign, '\|')},
                \ "#": {'pattern': "#", 'ignore_unmatched': 0, 'ignore_groups': ["String"]},
                \ '\': {'pattern': '\\'},
                \ '/': {'pattern': '//\+\|/\*\|\*/', 'delimiter_align': 'l', 'ignore_groups': ['!Comment']},
                \ ';': {'pattern': ";", 'left_margin': 0},
                \ ',': {'pattern': ",", 'left_margin': 0, 'right_margin': 1},
                \ '=': {'pattern': '<\?=>\?', 'left_margin': 1, 'right_margin': 1},
                \ '|': {'pattern': '|\?|', 'left_margin': 1, 'right_margin': 1},
                \ '&': {'pattern': '&\?&', 'left_margin': 1, 'right_margin': 1},
                \ ':': {'pattern': ":", 'left_margin': 1, 'right_margin': 1},
                \ '?': {'pattern': "?", 'left_margin': 1, 'right_margin': 1},
                \ '+': {'pattern': "+", 'left_margin': 1, 'right_margin': 1},
                \ '[': {'pattern': "[", 'left_margin': 1, 'right_margin': 0},
                \ ']': {'pattern': '\]\zs', 'left_margin': 0, 'right_margin': 1, 'stick_to_left': 0},
                \ '(': {'pattern': "(", 'left_margin': 0, 'right_margin': 0},
                \ ')': {'pattern': ')\zs', 'left_margin': 0, 'right_margin': 1, 'stick_to_left': 0},
                \ 'd': {'pattern': '  \ze\S\+\s*[;=]', 'left_margin': 0, 'right_margin': 0},
                \ 't': {'pattern': '\t', 'left_margin': 0, 'right_margin': 0, 'ignore_groups': ['Comment', 'String']},
                \ 'T': {'pattern': '\t', 'left_margin': 0, 'right_margin': 0, 'ignore_groups': ['!Comment']},
                \ 's': {'pattern':
                \           join(extend(l:equals, extend(l:lt_sign, l:gt_sign)), '\|'),
                \           'left_margin': 0, 'right_margin': 0, 'stick_to_left': 0},
                \ '"': {'pattern': '\"', 'ignore_groups': ['!Comment'], 'ignore_unmatched': 0},
                \ }

    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)
    xmap <Leader>ga <Plug>(LiveEasyAlign)
    xmap <Leader>gi :EasyAlign//ig['Comment']<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
    xmap <Leader>gs :EasyAlign//ig['String']<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
endfun
