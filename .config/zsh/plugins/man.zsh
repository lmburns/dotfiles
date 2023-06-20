# Other random functions

# ========================== Colored Man Pages ==========================
# termcap
# ks       make the keypad send commands
# ke       make the keypad send digits
# vb       emit visual bell
# mb       start blink
# md       start bold
# me       turn off bold, blink and underline
# so       start standout (reverse video)
# se       stop standout
# us       start underline
# ue       stop underline

function set-termcap() {
  typeset -AHg less_termcap
  local k v
  less_termcap[md]="$(tput bold; tput setaf ${1:-4})"
  less_termcap[mb]="$(tput blink)"
  less_termcap[me]="$(tput sgr0)"
  less_termcap[so]="$(tput smso)" # tput smso
  less_termcap[se]="$(tput rmso)" # tput rmso
  less_termcap[us]="$(tput setaf ${2:-2})"
  less_termcap[ue]="$(tput sgr0)"
}

function set-termcap-export() {
  local k v
  set-termcap $@
  for k v ( "${(@kv)less_termcap}" ) {
    eval "typeset -g LESS_TERMCAP_${k}=${v}"
  }
}

function set-termcap-env() {
  builtin emulate -L zsh -o warncreateglobal
  set-termcap $@
  typeset -ga reply
  local k v

  for k v ( "${(@kv)less_termcap}" ) {
    reply+=( "LESS_TERMCAP_${k}=${v}" )
  }
  reply+=( PAGER="${commands[less]:-$PAGER}" )
}

# @desc: wrapper to colorize man pages
function man() {
  set-termcap-env
  command env $reply man "$@"
}

# @desc: wrapper to colorize um man pages
function um() {
  set-termcap-env 52 53
  command env $reply um "$@"
}

# @desc: wrapper to colorize perldoc man pages
function perldoc() {
  set-termcap-env 52 53
  reply+=( PERLDOC_PAGER="sh -c 'col -bx | bat -l man -p --theme='kimbox''" )
  reply+=( PERLDOC_SRC_PAGER="sh -c 'col -bx | bat -l man -p --theme='kimbox''" )
  command env $reply perldoc "$@"

  # less -+C -E
  # command perldoc -n less "$@" | gman -l -
}
