#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-06-06                                                   #
#    @module: palette                                                      #
#      @desc: various color functions                                      #
#===========================================================================


# @desc: display colors used with zinit
function zinit-palette() {
  for k ( "${(@kon)ZINIT[(I)col-*]}" ); do
    local i=$ZINIT[$k]
    print "$reset_color${(r:14:: :):-$k:} $i###########"
  done
}

# Desc: print colors only with numbers (256)
function palette::nums() {
  local -a colors
  for i ({1..255}) {
    colors+=( $'\e'"[38;5;${i}m${(l:3::0:)i} " )
  }
  print -c $colors

  #   local -a colors
  #   for i in {000..255}; do
  #     colors+=("%F{$i}$i%f")
  #   done
  #   print -cP $colors
}

# Desc: print small blocks of colors (256)
function palette::blocks() {
  for i ({0..255}) {
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
  }
}

# Desc: print large solid blocks
function palette::blocks16() {
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

function palette::blocks16a() {
  local bold i j
  for bold ({0..1}); do
    for i ({30..38}); do
      for j ({40..48}); do
        print -n "\x1b[$bold;$i;${j}m $bold;$i;$j |\x1b[0m"
      done
      print
    done
    print
  done

  for bold ({0..1}); do
  done
}

function palette::bigblocks() {
  local width=${1:-5}

  for y ({0..13}); do
    print -n '           '
    for i ({0..7}); do
      print -n "\e[0;3$i;4${i}m${(l:width::=:):-}\e[0m"
    done
    print
  done
}

# Desc: Converts hex-triplet into terminal color index
function color::fromhex() {
  local hex r g b

  hex=${${1#"#"}#0x}

  r="0x${hex[1,2]:-0}"
  g="0x${hex[3,4]:-0}"
  b="0x${hex[5,6]:-0}"

  val=$(printf -- '%03d\n' "$(( (r<75?0:(r-35)/40)*6*6 +
                  (g<75?0:(g-35)/40)*6 +
                  (b<75?0:(b-35)/40) + 16 ))" | tee >(xsel -ib --trim))
  print -- "\e\[48\;5\;${val#0}m\e\[30m${val} TEST"
}

# Desc: escape code for colors
function color::printc() {
  local color="%F{$1}"
  echo -E ${(qqqq)${(%)color}}
}

# Desc: perl invocation to strip color codes (use in pipe)
function color::rmansip() {
  perl -pe 's/\e\[[0-9;]*m//g'
}

# Desc: string escape chars
function color::rmansi() {
  typeset -g REPLY; REPLY="${${(j: :)@}//$'\x1b'\[[0-9;]#m/}"
}

# Desc: do not process escape sequences
function color::raw() {
  typeset -g REPLY
  if (($+functions[$1] || $+commands[$1])) {
    builtin print -v REPLY -- ${(V):-"$($1)"}
  } else {
    builtin print -v REPLY -- ${(V)1}
  }
}
