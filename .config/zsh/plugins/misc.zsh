#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-06-06                                                   #
#===========================================================================

# === Alias Finder =======================================================
# @desc find aliases; taken from OMZ
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

# vim: ft=zsh:et:sw=0:ts=2:sts=2:tw=100
