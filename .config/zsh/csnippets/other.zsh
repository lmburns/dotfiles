# Other random functions

function expand-aliases() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]=$BUFFER
  (($+functions[_expand-aliases])) &&
    BUFFER=${functions[_expand-aliases]#$'\t'} &&
    CURSOR=$#BUFFER
}

function minenv() {
  cd "$(mktemp -d)"
  ZDOTDIR=$PWD HOME=$PWD zsh -df
}


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

typeset -AHg less_termcap

# fg_bold, etc doesn't seem to work
less_termcap[md]="$(tput bold; tput setaf 4)"
less_termcap[mb]="$(tput blink)"
less_termcap[me]="$(tput sgr0)"
less_termcap[so]="$(tput smso)" # tput smso
less_termcap[se]="$(tput rmso)" # tput rmso
less_termcap[us]="$(tput setaf 2)"
less_termcap[ue]="$(tput sgr0)"

function man() {
  local -a environment
  local k v

  for k v ( "${(@kv)less_termcap}" ) {
    environment+=( "LESS_TERMCAP_${k}=${v}" )
  }

  environment+=( PAGER="${commands[less]:-$PAGER}" )

  command env $environment man "$@"
}

# function man() {
#   env \
#     LESS_TERMCAP_md=$(tput bold; tput setaf 4) \
#     LESS_TERMCAP_me=$(tput sgr0) \
#     LESS_TERMCAP_mb=$(tput blink) \
#     LESS_TERMCAP_us=$(tput setaf 2) \
#     LESS_TERMCAP_ue=$(tput sgr0) \
#     LESS_TERMCAP_so=$(tput smso) \
#     LESS_TERMCAP_se=$(tput rmso) \
#     PAGER="${commands[less]:-$PAGER}" \
#     man "$@"
# }

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
