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

# Desc: wrapper to colorize man pages
function man() {
  set-termcap-env
  command env $reply man "$@"
}

# Desc: wrapper to colorize um man pages
function um() {
  set-termcap-env 52 53
  command env $reply um "$@"
  # if [[ -n "${MANPAGER}" ]]; then BAT_PAGER="$MANPAGER"; fi
  # env \
  #   MANPAGER='sh -c "col -bx | bat -l man -p"' \
  #   MANROFFOPT='-c' \
  #   PAGER="${MANPAGER}" \
  #   um "$@"
}

# ========================== Alias Finder ==========================

# Find aliases; taken from OMZ
function alias-finder() {
  emulate -L zsh
  setopt extendedglob
  local cmd exact longer wordStart wordEnd multiWordEnd
  foreach i ($@) {
    case $i in
      (-e|--exact) exact=1;;
      (-l|--longer) longer=1;;
      (*)
        if [[ -z $cmd ]]; then
          cmd=$i
        else
          cmd="$cmd $i"
        fi
        ;;
    esac
  }
  cmd=$(sed 's/[].\|$(){}?+*^[]/\\&/g' <<< $cmd) # adds escaping for grep
  if (( $(wc -l <<< $cmd) == 1 )); then
    while (( $#cmd )) {
      if (( longer )); then
        wordStart="'{0,1}"
      else
        wordEnd="$"
        multiWordEnd="'$"
      fi
      if [[ $cmd == *" "* ]]; then
        local finder="'$cmd$multiWordEnd"
      else
        local finder=$wordStart$cmd$wordEnd
      fi
      print -Prl -- \
        ${${(@f)"$(alias | rg "=$finder")"}/(#b)(*)=(*)/"%F{14}%B$match[1]%f%b=$match[2]"}
      if (( exact || longer )); then
        break
      else
        cmd=$(sed -E 's/ {0,1}[^ ]*$//' <<< $cmd) # removes last word
      fi
    }
  fi
}
