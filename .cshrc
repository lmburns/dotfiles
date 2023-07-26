umask 22

alias h   'history 100'
alias j   'jobs -l'

alias ls 'exa -Fhb --git --icons'
alias lss 'ls --group-directories-first'
alias lssa 'ls -a'

alias ll 'exa -FlahHgb --git --icons --time-style long-iso --octal-permissions'
alias lla 'ls -l'
alias lls 'll --group-directories-first'
alias lj 'll --group-directories-first'

alias clear 'clear -x'
alias sane  'stty sane'
alias plast 'last -20'

alias chx 'chmod ug+x'
alias chmx 'chmod -x'
alias cp 'cp -ivp --reflink=auto'
alias cpl 'cp -ivpa'
alias cpa 'cp -ivp --preserve=links,mode,ownership,xattr'
alias cpx 'cp -ivp --preserve=xattr'
alias mv 'mv -iv'
alias lns 'ln -siv'

alias ..  'cd ..'
alias ... 'cd ../..'

set path = (                          \
  /usr/lib/ccache/bin                 \
  $HOME/mybin                         \
  $HOME/mybin/linux                   \
  $HOME/mybin/gtk                     \
  $HOME/bin                           \
  $PYENV_ROOT/shims                   \
  $PYENV_ROOT/bin                     \
  $GOENV_ROOT/shims                   \
  $GOENV_ROOT/bin                     \
  $CARGO_HOME/bin                     \
  $XDG_DATA_HOME/gem/bin              \
  $XDG_DATA_HOME/luarocks/bin         \
  $XDG_DATA_HOME/neovim/bin           \
  $XDG_DATA_HOME/neovim-nightly/bin   \
  $GEM_HOME/bin                       \
  $NPM_PACKAGES/bin                   \
  /usr/lib/w3m                        \
  $HOME/.ghg/bin                      \
  $HOME/.ghcup/bin                    \
  $HOME/.cabal/bin                    \
  /sbin                               \
  /bin                                \
  /usr/sbin                           \
  /usr/bin                            \
  /usr/games                          \
  /usr/local/sbin                     \
  /usr/local/bin                      \
)

setenv  CLICOLOR true
setenv  BLOCKSIZE K

setenv LESS "\
  --ignore-case \
  --line-numbers \
  --hilite-search \
  --LONG-PROMPT \
  --no-init \
  --RAW-CONTROL-CHARS \
  --mouse \
  --wheel-lines=3 \
  --tabs 4 \
  --force \
  --prompt=?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"

setenv TERMINAL alacritty
setenv BROWSER brave
setenv BROWSERCLI w3m
setenv VISUAL nvim
setenv EDITOR nvim
setenv PAGER  less

if ($?prompt == 0) exit 0

# unmap CTRL-S and CTRL-Q
stty -ixon -ixoff

if ($?prompt) then
  if ( $?tcsh ) then
    switch ($TERM)
      case "xterm*":
      set prompt = '%{\033]0;%n@%m:%~\007%}[%B%n@%m%b] %B%~%b%# '
        breaksw
      default:
      set prompt = '[%B%n@%m%b] %B%~%b%# '
        breaksw
    endsw
  endif

  set autolist = ambiguous
  set correct = cmd

  set history = 2000
  set savehist = 2000
  set histdup = prev
  set nobeep
  set notify
  unset {ignoreeof,autologout}

  # Tab completion
  set filec
  set autolist
  set autocorrect
  set autoexpand
  set autorehash
  set color
  set colorcat
  set addsuffix
  set listlinks
  set listjobs
  set complete = ( igncase enhance )

  set mail = (/var/mail/$USER)

  if ( $?tcsh ) then
    bindkey "^W" backward-delete-word
    bindkey -k up history-search-backward
    bindkey -k down history-search-forward
    bindkey -v

    set implicitcd
  endif
endif

# vim: ft=tcsh:et:sw=0:ts=2:sts=2
