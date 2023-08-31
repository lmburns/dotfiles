(){
  emulate -L zsh

  typeset -gA dir_marks
  [[ -r ${VI_DIR_MARKS__CACHE_FILE:="${XDG_CACHE_HOME:-$HOME/.cache}/vi-dir-marks.cache.zsh"} ]] &&
    source $VI_DIR_MARKS__CACHE_FILE

  autoload add-zsh-hook
  zmodload zsh/datetime
  zmodload zsh/sched
  zmodload zsh/system
  add-zsh-hook zshexit vi-dir-marks::sync

  zle -N remove-dir  vi-dir-marks::remove
  zle -N mark-dir    vi-dir-marks::mark
  zle -N jump-dir    vi-dir-marks::jump
  zle -N marks       vi-dir-marks::list

  alias marks::sync="vi-dir-marks::sync"  marks::list="vi-dir-marks::list"
  alias marks::mark="vi-dir-marks::mark"  marks::jump="vi-dir-marks::jump"
  alias marks::rm="vi-dir-marks::remove"

  bindkey -M vicmd 'gl' marks
  bindkey -M vicmd 'dm' remove-dir
  bindkey -M vicmd 'm'  mark-dir
  bindkey -M vicmd "'"  jump-dir
  bindkey -M vicmd '`'  jump-dir
}

function vi-dir-marks::mark(){
  emulate -L zsh

  local REPLY
  [[ -n ${REPLY:=$1} ]] || read -k1
  dir_marks[$REPLY]=${${2:a}:-$PWD}

  zle -M "$REPLY:  $dir_marks[$REPLY] [ADDED]"

  # schedule cache writeout
  if [[ ( $REPLY = [[:upper:]] || $REPLY = [^${(j::)${(@As::)VI_DIR_MARKS__TEMP_MARKS:=1234567890}}] ) \
        && ! ${(M)zsh_scheduled_events:#*vi-dir-marks::sync} ]]; then
    sched +${VI_DIR_MARKS__SYNC_SECONDS:=10} vi-dir-marks::sync
  fi
}

function vi-dir-marks::remove(){
  emulate -L zsh

  local REPLY
  [[ -n ${REPLY:=$1} ]] || read -k1
  local old_dir=$dir_marks[$REPLY]
  unset "dir_marks[$REPLY]"

  # zle -M ${(%):-"%F{52}%B$REPLY%b%f: $old_dir %F{1}%B[R]%b%f")}
  if [[ -n "$old_dir" ]]; then
    zle -M "$REPLY: $old_dir [REMOVED]"

    # schedule cache writeout
    if [[ ! ${(M)zsh_scheduled_events:#*vi-dir-marks::sync} ]]; then
      sched +${VI_DIR_MARKS__SYNC_SECONDS:=10} vi-dir-marks::sync
    fi
  else
    zle -M "$REPLY: [DOESN'T EXIST]"
  fi
}

function vi-dir-marks::jump(){
  emulate -L zsh

  local REPLY
  [[ -n ${REPLY:=${1[1]}} ]] || read -k1
  if [[ -n $dir_marks[$REPLY] ]] && builtin cd ${dir_marks[$REPLY]#*:} &>/dev/null; then
    for f (chpwd $chpwd_functions precmd $precmd_functions)
      (($+functions[$f])) && $f &>/dev/null
    zle .reset-prompt
    zle -R
  fi
}

function vi-dir-marks::sync(){
  emulate -L zsh -o extendedglob
  local -i fd
  if [[ ! $1 = noflock ]] && zsystem supports flock; then
    zsystem flock -f fd $VI_DIR_MARKS__CACHE_FILE
    ($funcstack[-1] noflock)
    zsystem flock -u $fd
    return
  fi
  local -A old=(${(kv)dir_marks})
  source $VI_DIR_MARKS__CACHE_FILE
  # remove the deleted marks from dir_marks
  dir_marks=(${(kv)old:|dir_marks})
  # overwrite new global marks
  dir_marks+=("${(@kv)old[(I)[[:upper:]]]}")
  # overwrite new lower marks
  dir_marks+=("${(@kv)old[(I)*~[:upper:]${VI_DIR_MARKS__TEMP_MARKS}]}")
  # write out new global marks
  typeset -p dir_marks >| $VI_DIR_MARKS__CACHE_FILE
  zcompile $VI_DIR_MARKS__CACHE_FILE
  # join temp local marks
  dir_marks+=("${(@kv)old[(I)[${VI_DIR_MARKS__TEMP_MARKS}]]}")
}

function vi-dir-marks::list(){
  emulate -L zsh
  local k v
  local dir_mark_str=()
  for k v in ${(@kv)dir_marks#?*:}; do
      dir_mark_str+=( "${(r:3:)k}${v}" )
  done

  zle -M "${(F)dir_mark_str}"
}
