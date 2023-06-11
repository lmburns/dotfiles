func! usr#global#setup() abort
      let g:lbdirs = #{
      \  home: expand('$HOME'),
      \  config: expand('$XDG_CONFIG_HOME'),
      \  cache: expand('$XDG_CACHE_HOME'),
      \  data: expand('$XDG_DATA_HOME'),
      \  run: expand('$XDG_RUNTIME_DIR'),
      \  state: expand('$XDG_STATE_HOME'),
      \  tmp: expand('$TMPDIR'),
      \  plugs: expand('$VIMHOME/bundles')
      \ }

      " \ home: $'{$VIMHOME}/.vim'
      let g:vimrc = #{
      \ loaded: 0,
      \ home: expand('$HOME/.vim'),
      \ started_at: getcwd(),
      \ is_ivim: has('ivim'),
      \ is_tmux: exists('$TMUX'),
      \ }

      let g:vimrc.backupdir  = expand('$HOME/backup/vim')
      let g:vimrc.undodir    = g:vimrc.backupdir . '/undo'
      let g:vimrc.viewdir    = g:vimrc.backupdir . '/view'
      let g:vimrc.sessiondir = g:vimrc.backupdir . '/session'
      let g:vimrc.directory  = g:vimrc.backupdir . '/swp'
      let g:vimrc.viminfo = g:vimrc.backupdir . '/viminfo'
      let g:vimrc.spelldir = g:vimrc.backupdir . '/spell'
endf
