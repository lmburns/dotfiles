local utils = require("common.utils")
local map = utils.map

-- Colors
cmd [[command! -bang Colors call fzf#vim#colors(g:fzf_vim_opts, <bang>0)]]

-- Files
cmd [[
  command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>,
    \ fzf#vim#with_preview(g:fzf_vim_opts, 'right:60%:default'), <bang>0)
]]

-- Buffers
cmd [[
  command! -bang Buffers
    \ call fzf#vim#buffers(
    \ fzf#vim#with_preview(g:fzf_vim_opts, 'right:60%:default'), <bang>0)
]]

-- LS
cmd [[
  command! -bang -complete=dir -nargs=? LS
    \ call fzf#run(fzf#wrap({'source': 'ls', 'dir': <q-args>}, <bang>0))
]]

-- Conf
cmd [[
  command! -bang Conf
    \ call fzf#vim#files('~/.config', <bang>0)
]]

-- Proj
cmd [[
  command! -bang Proj
    \ call fzf#vim#files('~/projects', fzf#vim#with_preview(), <bang>0)
]]

-- AF
cmd [[
  command! -nargs=? -complete=dir AF
    \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
      \ 'source': 'fd --type f --hidden --follow --exclude .git --no-ignore
      \ . '.expand(<q-args>) })))
]]

-- Rg
cmd [[
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
      \ 'rg --column --line-number --hidden --smart-case '
        \ . '--no-heading --color=always '
        \ . shellescape(<q-args>),
        \ 1,
        \ {'options':  '--delimiter : --nth 4..'},
        \ 0)
]]

-- Rgf
cmd [[
    command! -bang -nargs=* Rgf call RGF()
    function! RGF()
      " . ' -F '.expand('%:t')"
      let fixmestr =
        \ '(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|HACK|BUG|BUGS):'
      call fzf#vim#grep(
        \ 'rg --column --no-heading --line-number --color=always '.shellescape(fixmestr),
        \ 1,
        \ {'options':  '--delimiter : --nth 4..'}, 0)
    endfunction
]]

-- RipgrepFzf
cmd [[
  command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
  function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading '
      \ . '--color=always --smart-case -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options':
      \ ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1,
      \ fzf#vim#with_preview(spec, 'right:60%:default'), a:fullscreen)
  endfunction
]]

-- Dots
cmd [[
  command! Dots call fzf#run(fzf#wrap({
  \ 'source': 'dotbare ls-files --full-name --directory "${DOTBARE_TREE}" '
    \ . '| awk -v home="${DOTBARE_TREE}/" "{print home \$0}"',
  \ 'sink': 'e',
  \ 'options': [ '--multi', '--preview', 'cat {}' ]
  \ }))
]]

-- PlugHelp
cmd [[
  function! s:plug_help_sink(line)
    let dir = g:plugs[a:line].dir
    for pat in ['doc/*.txt', 'README.md']
      let match = get(split(globpath(dir, pat), "\n"), 0, '')
      if len(match)
        execute 'tabedit' match
        return
      endif
    endfor
    tabnew
    execute 'Explore' dir
  endfunction

  command! PlugHelp call fzf#run(fzf#wrap({
    \ 'source': sort(keys(g:plugs)),
    \ 'sink':   function('s:plug_help_sink')}))
]]

-- Apropos
cmd [[
  command! -nargs=? Apropos call fzf#run(fzf#wrap({
      \ 'source': 'apropos '
          \ . (len(<q-args>) > 0 ? shellescape(<q-args>) : ".")
          \ .' | cut -d " " -f 1',
      \ 'sink': 'tab Man',
      \ 'options': [
          \ '--preview', 'MANPAGER=cat MANWIDTH='.(&columns/2-4).' man {}']}))
]]
