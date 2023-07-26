func! s:shouldDisable(x)
    let l:cmd = wilder#cmdline#parse(a:x).cmd
    return l:cmd ==# 'Man' || a:x =~# 'Git fetch origin '
endfu

func! plugs#wilder#setup() abort
    call wilder#enable_cmdline_enter()
    " cmap <expr> <Tab> wilder#in_context() ? wilder#next() : "\<Tab>"
    " cmap <expr> <S-Tab> wilder#in_context() ? wilder#previous() : "\<S-Tab>"

    call wilder#setup({
        \  'modes': [':', '/', '?'],
        \  'next_key': '<Tab>',
        \  'previous_key': '<S-Tab>',
        \  'accept_key': '<M-,>',
        \  'reject_key': '<M-.>',
        \ })

    call wilder#set_option('renderer', wilder#renderer_mux({
        \ ':': wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
        \   'highlighter': wilder#basic_highlighter(),
        \   'border': 'rounded',
        \   'max_height': 15,
        \   'highlights': {
        \     'border': 'Normal',
        \     'default': 'Normal',
        \     'accent': wilder#make_hl(
        \       'PopupmenuAccent', 'Normal', [{}, {}, {'foreground': '#A06469'}]),
        \   },
        \   'left':  [' ', wilder#popupmenu_devicons()],
        \   'right': [' ', wilder#popupmenu_scrollbar()],
        \ })),
        \
        \ '/': wilder#wildmenu_renderer({
        \   'highlighter': wilder#basic_highlighter(),
        \   'highlights': {
        \     'accent': wilder#make_hl(
        \       'WildmenuAccent', 'StatusLine', [{}, {}, {'foreground': '#A06469'}]),
        \   },
        \ }),
        \ }))

    call wilder#set_option('pipeline', [
        \  wilder#branch(
        \    [
        \      wilder#check({-> getcmdtype() ==# ':'}),
        \      {ctx, x -> s:shouldDisable(x) ? v:true : v:false},
        \    ],
        \    wilder#python_file_finder_pipeline({
        \      'file_command': {_, arg ->
        \         arg[0] ==# '.' ? ['rg', '--files', '--hidden'] : ['rg', '--files']},
        \      'dir_command':  {_, arg ->
        \         arg[0] ==# '.' ? ['fd', '-tf', '-H'] : ['fd', '-tf']},
        \      'filters': ['difflib_sorter'],
        \    }),
        \    wilder#cmdline_pipeline({
        \      'language': 'python',
        \      'set_pcre2_pattern': 1,
        \    }),
        \    wilder#python_search_pipeline({
        \      'pattern': wilder#python_fuzzy_pattern(),
        \      'sorter': wilder#python_difflib_sorter(),
        \      'engine': 're',
        \    }),
        \   ),
        \ ])
endfu
