#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-07-11                                                   #
#    @module: display                                                      #
#      @desc: functions to display text to the screen                      #
#===========================================================================

function log::dump() {
  local cpat="\~config/"; local zpat="\~zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{14}%B[DUMP]%b%f:%F{20}${func}%f:%F{21}${file}%f: $*"

  # $LINENO

  zmodload -Fa zsh/parameter p:functrace p:funcfiletrace p:funcstack p:funcsourcetrace
  local t tl eq
  t='Func File Trace' tl=$#t eq=${(l:(COLUMNS-tl-2) / 2::=:):-}
  print -Pl -- "%F{13}%B${eq} ${t} ${eq}\n%f%b$funcfiletrace[@]"
  t='Func Trace' tl=$#t eq=${(l:(COLUMNS-tl-2) / 2::=:):-}
  print -Pl -- "\n%F{13}%B${eq} ${t} ${eq}\n%f%b$functrace[@]"
  t='Func Stack' tl=$#t eq=${(l:(COLUMNS-tl-2) / 2::=:):-}
  print -Pl -- "\n%F{13}%B${eq} ${t} ${eq}\n%f%b$funcstack[@]"
  t='Func Source Trace' tl=$#t eq=${(l:(COLUMNS-tl-2) / 2::=:):-}
  print -Pl -- "\n%F{13}%B${eq} ${t} ${eq}\n%f%b$funcsourcetrace[@]"
}

function print::flag() {
  setopt extendedglob
  local MATCH MEND MBEGIN
  local str="  "
  str+=${(j:, :)${(@)${(@s:,:)2}//(#m)*/%${1}F${MATCH}%f}}
  if [[ -n "$4" ]] {
    str+=${${${4}:+%${3}F${4}%f}:-}
  } else {
    str+="$3"
  }
  print -Pr -- "$str"
}
function print::subc() {
  setopt extendedglob
  local MATCH MEND MBEGIN
  local str="  "
  str+="%${1}F%B${2}%b%f"
  if [[ -n "$4" ]] {
    str+=${${${4}:+%${3}F${4}%f}:-}
  } else {
    str+="$3"
  }
  print -Pr -- "$str"
}
function print::header() {
  print -Pr -- "%F{$1}%B$2:%f%b"
}
function print::usage() {
  print::header 12 "USAGE"
  setopt extendedglob
  local MATCH MEND MBEGIN
  local str="  "
  str+=${(j:, :)${(@)${(@s:,:)2}//(#m)*/%${1}F${MATCH}%f}}
  if [[ -n "$4" ]] {
    str+=${${${4}:+%${3}F${4}%f}:-}
  } else {
    str+="$3"
  }
  print -Pr -- "  %52F%BUsage%b%f: %2F$1%f ${@[2,-1]}"
}
