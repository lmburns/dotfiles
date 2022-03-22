# ============================== Replace =============================
# =========================== Custom builtin =========================

# autoload -Uz replace-string
# autoload -Uz replace-string-again
# zle -N replace-regex replace-string
# zle -N replace-pattern replace-string
# zle -N replace-string-again
# zstyle ':zle:replace-pattern' edit-previous false

# Modified the builtin becuase it doesn't act in one go

zstyle ':zle:@replace-pattern' edit-previous false

function @replace-string() {
  emulate -L zsh
  setopt extendedglob

  autoload -Uz read-from-minibuffer @replace-string-again

  local p1  p2
  integer savelim=$UNDO_LIMIT_NO   changeno=$UNDO_CHANGE_NO
  local   start="$BUFFER"          cursor="$CURSOR"

  {

  if [[ -n $_replace_string_src ]]; then
    p1="[$_replace_string_src -> $_replace_string_rep]"$'\n'
  fi

  p1+="Replace: "; p2="   with: "

  # Saving curwidget is necessary to avoid the widget name being overwritten.
  local REPLY previous curwidget=$WIDGET

  if (( ${+NUMERIC} )); then
    (( $NUMERIC > 0 )) && previous=1
  else
    zstyle -t ":zle:$WIDGET" edit-previous && previous=1
  fi

  read-from-minibuffer $p1 ${previous:+$_replace_string_src} || return 1
  if [[ -n $REPLY ]]; then
    typeset -g _replace_string_src=$REPLY

    read-from-minibuffer "$p1$_replace_string_src$p2" \
      ${previous:+$_replace_string_rep} || return 1
    typeset -g _replace_string_rep=$REPLY
  fi

  } always {
    zle undo $changeno

    # Builtin does not do this
    UNDO_LIMIT_NO=savelim
    BUFFER="$start"
    CURSOR="$cursor"
  }

  @replace-string-again $curwidget
}

zle -N replace-pattern @replace-string

function @replace-string-again() {
  local MATCH MBEGIN MEND curwidget=${1:-$WIDGET}
  local -a match mbegin mend

  if [[ -z $_replace_string_src ]]; then
    zle -M "No string to replace."
    return 1
  fi

  if [[ $curwidget = *(pattern|regex)* ]]; then
      local rep2
      # The following horror is so that an & preceded by an even
      # number of backslashes is active, without stripping backslashes,
      # while preceded by an odd number of backslashes is inactive,
      # with one backslash being stripped.  A similar logic applies
      # to \digit.
      local rep=$_replace_string_rep
      while [[ $rep = (#b)([^\\]#)(\\\\)#(\\|)(\&|\\<->|\\\{<->\})(*) ]]; do
    if [[ -n $match[3] ]]; then
        # Expression is quoted, strip quotes
        rep2="${match[1]}${match[2]}${match[4]}"
    else
        rep2+="${match[1]}${match[2]}"
        if [[ $match[4] = \& ]]; then
      rep2+='${MATCH}'
        elif [[ $match[4] = \\\{* ]]; then
      rep2+='${match['${match[4][3,-2]}']}'
        else
      rep2+='${match['${match[4][2,-1]}']}'
        fi
    fi
    rep=${match[5]}
      done
      rep2+=$rep
      if [[ $curwidget = *regex* ]]; then
        autoload -Uz regexp-replace
        integer ret=1
        regexp-replace LBUFFER $_replace_string_src $rep2 && ret=0
        regexp-replace RBUFFER $_replace_string_src $rep2 && ret=0
        return ret
      else
        LBUFFER=${LBUFFER//(#bm)$~_replace_string_src/${(e)rep2}}
        RBUFFER=${RBUFFER//(#bm)$~_replace_string_src/${(e)rep2}}
      fi
  else
      LBUFFER=${LBUFFER//$_replace_string_src/$_replace_string_rep}
      RBUFFER=${RBUFFER//$_replace_string_src/$_replace_string_rep}
  fi
}
zle -N @replace-string-again

# =============================== ZVM ================================
# ====================================================================

# Switch number keyword
function zvm_switch_number {
  setopt extendedglob
  local -a match mbegin mend
  local word=$1 increase=${2:-true}
  local result= bpos= epos=

  ## === Hexadecimal ===
  if [[ $word =~ [^0-9]?(0[xX][0-9a-fA-F]*) ]]; then
    number=${match[1]}
    local prefix=${number:0:2}
    bpos=$(( mbegin - 1 )) epos=$mend

    local lower=true
    [[ $number =~ [A-Z][0-9]*$ ]] && lower=false

    # Fix the number truncated after 15 digits issue
    if (( $#number > 17 )); then
      integer d=$(($#number - 15))
      integer h=${number:0:$d}
      number="0x${number:$d}"
    fi

    local p=$(($#number - 2))

    if $increase; then
      if (( $number == 0x${(l:15::f:)} )); then
        integer h=$(( [##16] h + 1 ))
        h=${h: -1}
        number=${(l:15::0:)}
      else
        h=${h:2}
        number=$(([##16]$number + 1))
      fi
    else
      if (( $number == 0 )); then
        if (( ${h:-0} == 0 )); then
          h=f
        else
          h=$(([##16]$h-1))
          h=${h: -1}
        fi
        number=${(l:15::f:)}
      else
        h=${h:2}
        number=$(([##16]$number - 1))
      fi
    fi

    # Padding with zero
    if (( $#number < $p )); then
      number=${(l:$p::0:)number}
    fi

    result="${h}${number}"

    # Transform the case
    if $lower; then
      result="${(L)result}"
    fi

    result="${prefix}${result}"

  ## === Binary ===
  elif [[ $word =~ [^0-9]?(0[bB][01]*) ]]; then

    local number=${match[1]}
    local prefix=${number:0:2}
    bpos=$((mbegin-1)) epos=$mend

    # Fix the number truncated after 63 digits issue
    if (( $#number > 65 )); then
      local d=$(($#number - 63))
      local h=${number:0:$d}
      number="0b${number:$d}"
    fi

    local p=$(($#number - 2))

    if $increase; then
      if (( $number == 0b${(l:63::1:)} )); then
        h=$(([##2]$h+1))
        h=${h: -1}
        number=${(l:63::0:)}
      else
        h=${h:2}
        number=$(([##2]$number + 1))
      fi
    else
      if (( $number == 0b0 )); then
        if (( ${h:-0} == 0 )); then
          h=1
        else
          h=$(([##2]$h-1))
          h=${h: -1}
        fi
        number=${(l:63::1:)}
      else
        h=${h:2}
        number=$(([##2]$number - 1))
      fi
    fi

    # Padding with zero
    if (( $#number < $p )); then
      number=${(l:$p::0:)number}
    fi

    result="${prefix}${number}"

  ## Decimal
  elif [[ $word =~ ([-+]?[0-9]+) ]]; then

    local number=${match[1]}
    bpos=$((mbegin-1)) epos=$mend

    if $increase; then
      result=$(($number + 1))
    else
      result=$(($number - 1))
    fi

    # Check if need the plus sign prefix
    if [[ ${word:$bpos:1} == '+' ]]; then
      result="+${result}"
    fi
  fi

  if [[ $result ]]; then
    echo $result $bpos $epos
  fi
}

# Switch boolean keyword
function zvm_switch_boolean() {
  local word=$1
  local increase=$2
  local result=
  local bpos=0 epos=$#word

  # Remove option prefix
  if [[ $word =~ (^[+-]{0,2}) ]]; then
    local prefix=${match[1]}
    bpos=$mend
    word=${word:$bpos}
  fi

  case ${(L)word} in
    true) result=false;;
    false) result=true;;
    yes) result=no;;
    no) result=yes;;
    on) result=off;;
    off) result=on;;
    y) result=n;;
    n) result=y;;
    t) result=f;;
    f) result=t;;
    *) return;;
  esac

  # Transform the case
  if [[ $word =~ ^[A-Z]+$ ]]; then
    result=${(U)result}
  elif [[ $word =~ ^[A-Z] ]]; then
    result=${(U)result:0:1}${result:1}
  fi

  echo $result $bpos $epos
}

# Switch weekday keyword
function zvm_switch_weekday() {
  local word=$1
  local increase=$2
  local result=${(L)word}
  local weekdays=(
    sunday
    monday
    tuesday
    wednesday
    thursday
    friday
    saturday
  )

  local i=1

  for ((; i<=${#weekdays[@]}; i++)); do
    if [[ ${weekdays[i]:0:$#result} == ${result} ]]; then
      result=${weekdays[i]}
      break
    fi
  done

  # Return if no match
  if (( i > ${#weekdays[@]} )); then
    return
  fi

  if $increase; then
    if (( i == ${#weekdays[@]} )); then
      i=1
    else
      i=$((i+1))
    fi
  else
    if (( i == 1 )); then
      i=${#weekdays[@]}
    else
      i=$((i-1))
    fi
  fi

  # Abbreviation
  if (( $#result == $#word )); then
    result=${weekdays[i]}
  else
    result=${weekdays[i]:0:$#word}
  fi

  # Transform the case
  if [[ $word =~ ^[A-Z]+$ ]]; then
    result=${(U)result}
  elif [[ $word =~ ^[A-Z] ]]; then
    result=${(U)result:0:1}${result:1}
  fi

  echo $result 0 $#word
}

# Switch operator keyword
function zvm_switch_operator() {
  local word=$1
  local increase=$2
  local result=

  case ${(L)word} in
    '&&') result='||';;
    '||') result='&&';;
    '++') result='--';;
    '--') result='++';;
    '==') result='!=';;
    '!=') result='==';;
    '===') result='!==';;
    '!==') result='===';;
    '+') result='-';;
    '-') result='*';;
    '*') result='/';;
    '/') result='+';;
    'and') result='or';;
    'or') result='and';;
    *) return;;
  esac

  # Transform the case
  if [[ $word =~ ^[A-Z]+$ ]]; then
    result=${(U)result}
  elif [[ $word =~ ^[A-Z] ]]; then
    result=${(U)result:0:1}${result:1}
  fi

  # Since the `echo` command can not print the character
  # `-`, here we use `printf` command alternatively.
  printf "%s 0 $#word" "${result}"
}

# Switch month keyword
function zvm_switch_month() {
  local word=$1
  local increase=$2
  local result=${(L)word}
  local months=(
    january
    february
    march
    april
    may
    june
    july
    august
    september
    october
    november
    december
  )

  local i=1

  for ((; i<=${#months[@]}; i++)); do
    if [[ ${months[i]:0:$#result} == ${result} ]]; then
      result=${months[i]}
      break
    fi
  done

  # Return if no match
  if (( i > ${#months[@]} )); then
    return
  fi

  if $increase; then
    if (( i == ${#months[@]} )); then
      i=1
    else
      i=$((i+1))
    fi
  else
    if (( i == 1 )); then
      i=${#months[@]}
    else
      i=$((i-1))
    fi
  fi

  # Abbreviation
  if (( $#result == $#word )); then
    result=${months[i]}
  else
    result=${months[i]:0:$#word}
  fi

  # Transform the case
  if [[ $word =~ ^[A-Z]+$ ]]; then
    result=${(U)result}
  elif [[ $word =~ ^[A-Z] ]]; then
    result=${(U)result:0:1}${result:1}
  fi

  echo $result 0 $#word
}

function zvm_switch_keyword() {
  local bpos= epos= cpos=$CURSOR

  # If cursor is on the `+` or `-`, we need to check if it is a
  # number with a sign or an operator, only the number needs to
  # forward the cursor.
  if [[ ${BUFFER:$cpos:2} =~ [+-][0-9] ]]; then
    if [[ $cpos == 0 || ${BUFFER:$((cpos-1)):1} =~ [^0-9] ]]; then
      cpos=$((cpos+1))
    fi

  # If cursor is on the `+` or `-`, we need to check if it is a
  # short option, only the short option needs to forward the cursor.
  elif [[ ${BUFFER:$cpos:2} =~ [+-][a-zA-Z] ]]; then
    if [[ $cpos == 0 || ${BUFFER:$((cpos-1)):1} == ' ' ]]; then
      cpos=$((cpos+1))
    fi
  fi

  local result=($(zvm_select_in_word $cpos))
  bpos=${result[1]} epos=$((${result[2]}+1))

  # Move backward the cursor
  if [[ $bpos != 0 && ${BUFFER:$((bpos-1)):1} == [+-] ]]; then
    bpos=$((bpos-1))
  fi

  local word=${BUFFER:$bpos:$((epos-bpos))}

  if [[ $KEYS == \+ ]]; then
    local increase=true
  else
    local increase=false
  fi

  # Execute extra commands
  for handler in $zvm_switch_keyword_handlers; do
    if ! zvm_exist_command ${handler}; then
      continue
    fi

    result=($($handler $word $increase));

    if (( $#result == 0 )); then
      continue
    fi

    epos=$(( bpos + ${result[3]} ))
    bpos=$(( bpos + ${result[2]} ))

    if (( cpos < bpos )) || (( cpos >= epos )); then
      continue
    fi

    BUFFER="${BUFFER:0:$bpos}${result[1]}${BUFFER:$epos}"
    CURSOR=$((bpos + ${#result[1]} - 1))

    # zle reset-prompt
    return
  done
}

function zvm_exist_command() {
  command -v "$1" >/dev/null
}

# Select a word under the cursor
function zvm_select_in_word() {
  local cursor=${1:-$CURSOR}
  local buffer=${2:-$BUFFER}
  local bpos=$cursor epos=$cursor
  local pattern='[0-9a-zA-Z_]'

  if ! [[ "${buffer:$cursor:1}" =~ $pattern ]]; then
    pattern="[^${pattern:1:-1} ]"
  fi

  for ((; $bpos>=0; bpos--)); do
    [[ "${buffer:$bpos:1}" =~ $pattern ]] || break
  done
  for ((; $epos<$#buffer; epos++)); do
    [[ "${buffer:$epos:1}" =~ $pattern ]] || break
  done

  bpos=$((bpos+1))

  # The ending position must be greater than 0
  if (( epos > 0 )); then
    epos=$((epos-1))
  fi

  echo $bpos $epos
}

# The widget wrapper
function zvm_widget_wrapper() {
  local rawfunc=$1;
  local func=$2;
  local -i retval
  $func "${@:3}"
  return retval
}

# Define widget function
function zvm_define_widget() {
  local widget=$1
  local func=$2 || $1
  local result=($(zle -l -L "${widget}"))

  # Check if existing the same name
  if [[ ${#result[@]} == 4 ]]; then
    local rawfunc=${result[4]}
    local wrapper="zvm_${widget}-wrapper"
    eval "$wrapper() { zvm_widget_wrapper $rawfunc $func \"\$@\" }"
    func=$wrapper
  fi

  zle -N $widget $func
}

zvm_switch_keyword_handlers=(
  zvm_switch_number
  zvm_switch_boolean
  zvm_switch_operator
  zvm_switch_weekday
  zvm_switch_month
)

zle -N zvm_switch_keyword


# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
