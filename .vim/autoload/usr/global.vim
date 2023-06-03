func! usr#global#setup() abort
  " \  'log': expand('$XDG_'),
  let g:lbdirs = {
        \  'home': expand('$HOME'),
        \  'config': expand('$XDG_CONFIG_HOME'),
        \  'cache': expand('$XDG_CACHE_HOME'),
        \  'data': expand('$XDG_DATA_HOME'),
        \  'run': expand('$XDG_RUNTIME_DIR'),
        \  'state': expand('$XDG_STATE_HOME'),
        \  'tmp': expand('$TMPDIR'),
        \  'plugs': expand('$VIMHOME/bundles')
        \ }
endf
