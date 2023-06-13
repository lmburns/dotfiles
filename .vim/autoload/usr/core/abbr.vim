func! usr#core#abbr#setup() abort
  cnoreabbr W! w!
  cnoreabbr Q! q!
  cnoreabbr Qall! qall!
  cnoreabbr Wq wq
  cnoreabbr Wa wa
  cnoreabbr wQ wq
  cnoreabbr WQ wq
  cnoreabbr W w
  cnoreabbr Qall qall

  cnoreabbr <expr> ld api#abbr('ld', 'Linediff')
  cnoreabbr <expr> man api#abbr('man', 'Man')
  cnoreabbr <expr> ggr api#abbr('ggr', 'Ggrep')
  cnoreabbr <expr> ggrep api#abbr('ggrep', 'Ggrep')
  cnoreabbr <expr> vgr api#abbr('vgr', 'vimgrep')
  cnoreabbr <expr> gr api#abbr('gr', 'Grep')
  cnoreabbr <expr> lg api#abbr('lg', 'LGrep')
  cnoreabbr <expr> hgr api#abbr('hgr', 'helpgrep')
  cnoreabbr <expr> helpg api#abbr('helpg', 'helpgrep')
  cnoreabbr <expr> fil api#abbr('fil', 'filter')
  cnoreabbr <expr> cdo api#abbr('cdo', 'Cdo')
  cnoreabbr <expr> ldo api#abbr('ldo', 'Ldo')
endfunc
