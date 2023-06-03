fun! plugs#comment#nerdcomment_maps() abort
  nnoremap <silent> <C-.> :call nerdcommenter#Comment(0, "Toggle")<CR>j
  xnoremap <silent> <C-.> :call nerdcommenter#Comment(0, "Toggle")<CR>'>j
  xnoremap <silent><nowait> gc :call nerdcommenter#Comment(0, "Toggle")<CR>
  xnoremap <silent> gcc :call nerdcommenter#Comment(0, "Toggle")<CR>
  nnoremap <silent> gcl :call nerdcommenter#Comment(0, "AlignLeft")<CR>
  xnoremap <silent> gcl :call nerdcommenter#Comment(0, "AlignLeft")<CR>
  nnoremap <silent> gcr :call nerdcommenter#Comment(0, "AlignRight")<CR>
  xnoremap <silent> gcr :call nerdcommenter#Comment(0, "AlignRight")<CR>
  " nnoremap <silent> gcr :call nerdcommenter#Comment(0, "AlignBoth")<CR>
  " xnoremap <silent> gcr :call nerdcommenter#Comment(0, "AlignBoth")<CR>
  nnoremap <silent> gcL :call nerdcommenter#Comment(0, "ToEOL")<CR>
  nnoremap <silent> gcA :call nerdcommenter#Comment(0, "Append")<CR>
  nnoremap <silent> gcy :call nerdcommenter#Comment(0, "Yank")<CR>
  xnoremap <silent> gcy :call nerdcommenter#Comment(0, "Yank")<CR>
  nnoremap <silent> gcn :call nerdcommenter#Comment(0, "Nested")<CR>
  xnoremap <silent> gcn :call nerdcommenter#Comment(0, "Nested")<CR>
  nnoremap <silent> gcv :call nerdcommenter#Comment(0, "Invert")<CR>
  xnoremap <silent> gcv :call nerdcommenter#Comment(0, "Invert")<CR>
  nnoremap <silent> gcx :call nerdcommenter#Comment(0, "Sexy")<CR>
  xnoremap <silent> gcx :call nerdcommenter#Comment(0, "Sexy")<CR>
endfun

fun! plugs#comment#nerdcomment_opts() abort
  let g:NERDCreateDefaultMappings = 0
  let g:NERDSpaceDelims = 1
  let g:NERDTrimTrailingWhitespace = 1
  let g:NERDToggleCheckAllLines = 1
  let g:NERDCompactSexyComs = 0
  let g:NERDCommentEmptyLines = 1
  let g:NERDDefaultNesting = 1
  let g:NERDDefaultAlign = 'left'
  let g:NERDCustomDelimiters = {
              \ 'lua':  {'left': '--', 'leftAlt': '', 'rightAlt': ''},
              \ 'just': {'left': '#', 'leftAlt': '', 'rightAlt': ''}
              \ }
endfun

func! plugs#comment#commentary() abort
  xmap gcb  <Plug>Commentary
  nmap gc  <Plug>Commentary
  omap gc  <Plug>Commentary
  " nmap gcc <Plug>CommentaryLine
  nmap gcu <Plug>Commentary<Plug>Commentary
endf

func! plugs#comment#tcomment() abort
  let g:tcomment_maps = 0
  let g:tcomment#blank_lines = 2
  let g:tcomment#rstrip_on_uncomment = 1
  let g:tcomment#mode_extra = ''

  let g:tcomment_mapleader1 = 'gc'
  let g:tcomment_mapleader2 = '<Leader>_'
  let g:tcomment_opleader1 = 'gc'
  let g:tcomment_mapleader_uncomment_anyway = 'g<'
  let g:tcomment_mapleader_comment_anyway = 'g>'
  let g:tcomment_map_modifier = '<silent>'
  let g:tcomment_opmap_modifier = '<silent>'
  " let g:tcomment#options = {'postprocess_uncomment': 'norm! %sgg=%sgg'}

  nmap <silent> <C-.> <Plug>TComment_gccj
  xmap <silent> <C-.> <Plug>TComment_gc

  nmap <silent> gc <Plug>TComment_gc
  xmap <silent> gc <Plug>TComment_gc`>
  nmap <silent> gcc <Plug>TComment_gcc
  nmap <silent> gb <Plug>TComment_gcb
  vmap <silent> gb <Plug>TComment_gcb`>
  omap <silent> gb <Plug>TComment_gcb

  " nmap <silent> gcb <Plug>TComment_<Leader>_b
  " vmap <silent> gcb <Plug>TComment_<Leader>_b

  nmap <silent> gcg <Plug>TComment_<C-_>p

  nmap <silent> gch <Plug>TComment_<C-_>i
  nmap <silent> gcl <Plug>TComment_<C-_>r
  nmap <silent> gcr <Plug>TComment_<C-_>r
  vmap <silent> gbr <Plug>TComment_<C-_>r

  nmap <silent> gc1c <Plug>TComment_gc1c
  nmap <silent> gc1 <Plug>TComment_gc1
  nmap <silent> gc2c <Plug>TComment_gc2c
  nmap <silent> gc2 <Plug>TComment_gc2
  " vmap <silent> gc1 <Plug>TComment_<C-_>1
  " vmap <silent> gc2 <Plug>TComment_<C-_>2

  " vmap <silent> gct <Plug>TComment_ic
  " nmap <silent> gcca <Plug>TComment_<C-_>ca
  " nmap <silent> gccc <Plug>TComment_<C-_>cc
  " nmap <silent> gcs <Plug>TComment_<C-_>s
  " nmap <silent> gcn <Plug>TComment_<C-_>n
  " nmap <silent> gca <Plug>TComment_<C-_>a
  " nmap <silent> gc<Space> <Plug>TComment_<C-_><Space>
  " nmap <silent> gcgc <Plug>TComment_<C-_><C-_>
  " omap <silent> gcgc <Plug>TComment_<C-_><C-_>
endf

fun! plugs#comment#setup() abort
    " call plugs#comment#nerdcomment_opts()
    " call plugs#comment#nerdcomment_maps()
    " call plugs#comment#commentary()
    call plugs#comment#tcomment()
endfun
