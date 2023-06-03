# Switch number keyword
function zvm::switch_number {
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
function zvm::switch_boolean() {
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
function zvm::switch_weekday() {
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
function zvm::switch_operator() {
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
function zvm::switch_month() {
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

function zvm::switch_keyword() {
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

  local result=($(zvm::select_in_word $cpos))
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
    if ! zvm::exist_command ${handler}; then
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

function zvm::exist_command() {
  command -v "$1" >/dev/null
}

# Select a word under the cursor
function zvm::select_in_word() {
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
function zvm::widget_wrapper() {
  local rawfunc=$1;
  local func=$2;
  local -i retval
  $func "${@:3}"
  return retval
}

# Define widget function
function zvm::define_widget() {
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
  zvm::switch_number
  zvm::switch_boolean
  zvm::switch_operator
  zvm::switch_weekday
  zvm::switch_month
)

zle -N zvm::switch_keyword

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
