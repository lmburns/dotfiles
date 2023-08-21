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
  # reply+=( PAGER="${commands[less]:-$PAGER}" )
  reply+=( PAGER="less $less_less" )
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
  # command perldoc -n less "$@" | man -l -
}

# @desc: colorize go docs
function godoc() {
  # set-termcap-env 52 53
  go doc "${(z)@}" | bat -l go -p --theme=kimbox
}

# @desc: search for a keyword in a manpage and open it
function man-search() {
  man -P "less -p'$2'" "$1"
}

# @desc: grep through man pages
function man-grep() {
  local section

  man -Kw "$@" |
    sort -u |
    while IFS= read -r file; do
      section=${file%/*}
      section=${section##*/man}
      lexgrog -- "$file" |
        perl -spe's/.*?: "(.*)"/$1/; s/ - / ($s)$&/' -- "-s=$section"
    done
}

function :he :h :help {
  local -A Opts
  zparseopts -F -D -E -A Opts -- p: -pack: s -same
  local MATCH; integer MEND MBEGIN
  local topic="$1" packadd; shift
  local -a moreargs

  # Packadd the same argument given to the first arg
  (($+Opts[-s]+$+Opts[--same])) && { packadd="packadd $topic"; }
  (($+Opts[-p]+$+Opts[--pack])) && { packadd="packadd ${Opts[-p]:-$Opts[--pack]}"; }
  (( $#@ )) && moreargs=${@//(#m)*/+"$MATCH"}

  ## All equivalent
  # allows ':h vimwiki packadd vimwiki'
  # allows ':h vimwiki -p vimwiki'
  # allows ':h vimwiki -s'
  nvim $moreargs ${packadd:++"$packadd"} +"help $topic" +'map q ZQ' +'bw 1'
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]:
