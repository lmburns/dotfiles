# Various color functions

# Desc: huge blog test
function colortest::256() {
  curl -s 'https://raw.githubusercontent.com/stark/Color-Scripts/master/test-color-support/color-support2' \
    | bash
}

# Desc: print colors only with numbers (256)
function palette::nums() {
  local -a colors
  for i ({1..255}) {
    colors+=( $'\e'"[38;5;${i}m${(l:3::0:)i} " )
  }
  print -c $colors
}

# Desc: same as above, just taller and simpler
function palette::plain() {
  local -a colors
  for i in {000..255}; do
    colors+=("%F{$i}$i%f")
  done
  print -cP $colors
}

# Desc: print small blocks of colors (256)
function palette::blocks() {
  for i ({0..255}) {
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
  }
}

# Desc: print large solid blocks
function palette::colortest() {
  # The text for the color test, At least 3 characters
  T=${1:-'•••'}; [ ${#T} -lt 3 ] && T=$(cut -c 1-3 <<< "$T$T$T"); TLEN=${#T};
  RP=$(((TLEN - 3) / 2  + 3)); R=$(head -c $RP </dev/zero | tr '\0', ' ') # right padding
  LP=$(((TLEN - 3) - RP + 5)); L=$(head -c $LP </dev/zero | tr '\0', ' ') # left padding
  print -n "\n       "
  print "${L}def${R}${L}40m${R}${L}41m${R}${L}42m${R}${L}43m${R}${L}44m${R}${L}45m${R}${L}46m${R}${L}47m${R}"
  for FGs (
    'm'     '1m' '30m' '1;30m' '31m' '1;31m' '32m' '1;32m' '33m' \
    '1;33m' '34m' '1;34m' '35m' '1;35m' '36m' '1;36m' '37m' '1;37m'
  ) {
  FG=${FGs// /}
    printf "%6s \033[%s  %s  " $FG $FG $T
    for BG (40m 41m 42m 43m 44m 45m 46m 47m) {
      printf "$EINS \033[$FG\033[$BG  $T  \033[0m";
    }
    echo
  }
  print
}
