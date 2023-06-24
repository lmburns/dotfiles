#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2022-03-11 23:00
#===========================================================================

# ============================ Zsh Specific ==========================
# ====================================================================

# @desc: `which` tool which has all information from `whence`
function ww() {
  (alias; declare -f) |
    /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@;
}

# @desc: display colors used with zinit
function zinit-palette() {
  for k ( "${(@kon)ZINIT[(I)col-*]}" ); do
    local i=$ZINIT[$k]
    print "$reset_color${(r:14:: :):-$k:} $i###########"
  done
}

# @desc: create temporary directory and cd to it
function cdt() {
  local t=$(mktemp -d)
  setopt localtraps
  trap "[[ $PWD != $t && -d $t ]] && command rm $t" EXIT
  zmsg "{dir}$t{%}"
  builtin cd -q "$t"
}

function zsh-minimal() {
  builtin cd "$(mktemp -d)"
  ZDOTDIR=$PWD HOME=$PWD zsh -df
}

# @desc: reload zsh function without sourcing zshrc
function freload() {
  # while (( $# )); do; unfunction $1; autoload -U $1; shift; done
  while (($#)) { unfunction $1 && autoload -U $1 && shift }
}

# @desc: edit an alias via zle (whim -a)
function ealias() {
  [[ -z "$1" ]] && {
    print::usage "ealias" "<alias_to_edit>"; return 1;
  }
  vared aliases'[$1]' ;
}

# @desc: edit a function via zle (whim -f)
function efunc() {
  [[ -z "$1" ]] && {
    print::usage "efunc" "<func_to_edit>"; return 1;
  }
  zed -f "$1"
}

# @desc: find functions that follow this pattern: func()
function ffunc() {
  eval "() { $functions[RG] } ${@}\\\\\(";
}

# @desc: list all commands
function allcmds() {
  print -l ${(k)commands[@]} | sk --preview-window=hidden;
}

# @desc: list loaded ZLE modules
function lszle() {
  # print -rl -- \
  #   ${${${(@f):-"$(zle -Ll)"}//(#m)*/${${(ws: :)MATCH}[1,3]}}//*(autosuggest|orig-s)*/} | \
  print -rl -- ${${(@f):-"$(zle -la)"}//*(autosuggest|orig-s)*/} \
    | command bat --terminal-width=$(( COLUMNS-2 ))
}

# @desc: list zstyle modules
function lszstyle() {
  emulate -L zsh -o extendedglob
  print -Plr -- \
    ${${(@)${(@f):-"$(zstyle -L ':*')"}/*list-colors*/}//(#b)(zstyle) (*) (*) (*)/\
%F{1}$match[1]%f %F{3}$match[2]%f %F{14}%B$match[3]%b%f %F{2}$match[4]} \
  | command bat --terminal-width=$(( COLUMNS-2 ))
}

# @desc: list functions
function lsfuncs() {
  emulate -L zsh -o extendedglob
  zmodload -Fa zsh/parameter p:functions

  (
    [[ $1 = -a ]] && {
      print -rl -- ${${(@o)${(k)functions[(I)^[→_.+:@-]*]}}}
    } || {
      print -rl -- $^fpath/${^${(@o)${(k)functions[(I)^[→_.+:@-]*]}}}(#qN) | lscolors
    }
  ) | bat
}

# @desc: tells from-where a zsh completion is coming from
function from-where {
  print -l -- $^fpath/$_comps[$1](N)
  whence -v $_comps[$1]
  #which $_comps[$1] 2>&1 | head
}

# @desc: tell which completion a command is using
function whichcomp() {
  for 1; do
      ( print -raC 2 -- $^fpath/${_comps[$1]:?unknown command}(NP-$1-) )
  done
}

# @desc: print path of zsh function
function whichfunc() {
  (( $+functions[$1] )) || zerr "$1 is not a function"
  for 1; do
    (
      print -PraC 2 -- \
        ${${(j: :):-$(print -r ${^fpath}/$1(#qNP-$1-))}//(#b)(*) (*)/%F{1}%B$match[1]%b %F{2}$match[2]}
    )
  done
}

# @desc: disown a process
function run_diso {
  sh -c "${(z)@}" &>/dev/null &
  disown
}

# @desc: nohup a process
function background() {
  nohup "${(z)@}" >/dev/null 2>&1 &
}

# @desc: nohup a process and immediately disown
function background!() {
  nohup "${(z)@}" >/dev/null 2>&1 &!
}

# @desc: reinstall completions
function creinstall() {
  ___creinstall() {
    emulate zsh -ic "zinit creinstall -q $GENCOMP_DIR 1>/dev/null" &!
  }

  (( $+functions[defer] )) && { defer -c '___creinstall && src' }
  unfunction 'creinstall'
}

# === Wifi =============================================================== [[[
# @desc: lsof open fd
zmodload -F zsh/system p:sysparams
# @desc: get your IP address
function n1ip()      { curl -s ipinfo.io/json | jq .; }
function n1ip6()     { dig myip.opendns.com @resolver1.opendns.com ; } # +short
# @desc: get wifi information
function n1wifi() { command iw dev ${${=${${(f)"$(</proc/net/wireless)"}:#*\|*}[1]}[1]%:} link; }
# @desc: list available Wifi networks
function lswifi()    { nmcli device wifi; }
# @desc: nmap info
function lsnmap()    { nmap --iflist; }
# ]]]

# === Listing ============================================================ [[[
# @desc: list information about current zsh process
function mem()      { sudo px $$; }
# @desc: list file descriptors
function lsfd()     { lsof -p $sysparams[ppid] | hck -f1,4,5- ; }
# @desc: list deleted items
function lsdelete() { lsof -n | rg -i --color=always deleted }
# @desc: list users on the computer
function lsusers()  { hck -d':' -f1 <<< "$(</etc/passwd)"; }
# @desc: list the fonts
function lsfont()   { fc-list -f '%{family}\n' | awk '!x[$0]++'; }
# ]]]

# === Profiling ========================================================== [[[
# @desc: profile zsh: Method 1
function time-zsh() { for i ({1..10}) { /usr/bin/time $SHELL -i -c 'print; exit' }; }
# @desc: profile zsh: Method 2 (hyperfine)
function hyperfine-zsh() { hyperfine "$SHELL -ic 'exit'"; }
# @desc: profile zsh: Method 2 (zprof)
function profile-zsh() { $SHELL -i -c zprof | bat; }
# @desc: profile zsh: Method 3 (any cmd)
# function profile() { $SHELL "$@"; }
# ]]]

# === ls ext ============================================================= [[[
# emulate -R zsh -c 'print -l -- *(a-${1:-1})'
# @desc: list files which have been accessed within the last n days
function accessed() { ls -- */*(a-${1:-1}); }
function changed()  { ls -- */*(c-${1:-1}); }
function modified() { fd --changed-within ${1:-1day} -d${2:-1}; }

# @desc: list files which have been accessed within the last n days recursively
#        The above is recursive, but this lists differently
function accessedr() { ll -R -- *(a-${1:-1}); }
function changedr()  { ll -R -- *(c-${1:-1}); }
function modifiedr() { ll -R -- *(m-${1:-1}); }
# ]]]

# === Backup ============================================================= [[[
# function bak()  { renamer '$=.bak' "$@"; }
# function rbak() { renamer '.bak$=' "$@"; }

# @desc: Perl rename
function backup-t()  { rename -n 's/^(.*)$/$1.bak/g' $@ }
function backup()    { rename    's/^(.*)$/$1.bak/g' $@ }
function restore-t() { rename -n 's/^(.*).bak$/$1/g' $@ }
function restore()   { rename    's/^(.*).bak$/$1/g' $@ }

# @desc: backup files
function bak()  {
  command cp -vruT --preserve=all --force --backup=existing $1 $1
}
function rbak() { command cp -vr --preserve=all --force $1.bak $1 }

# @desc: backup a file. 'fname' -> 'fname_2023-01-30T14:23-06:00'
function bk() {
  emulate -L zsh
  command cp -ivrT --preserve=all -b "$1" "${1:r}_$(date --iso-8601=m)${${${1:e}:+.${1:e}}:-}"
}

# @desc: backup a file with only a date. 'fname' -> 'fname_2023_01_30'
function bk-today() {
  emulate -L zsh
  command cp -ivruT --preserve=all -b "$1" "${1:r}_$(date '+%Y_%m_%d')${${${1:e}:+.${1:e}}:-}"
}

# @desc: add a date suffix to a file
function datify() {
  emulate -L zsh
  # command mv -iv $1 ${1:r}_$(date '+%Y_%m_%d')${${${1:e}:+.${1:e}}:-}
  f2 -FRf "${1}$" -r "${1:r}_{{mtime.YYYY}}_{{mtime.MM}}_{{mtime.DD}}${${${1:e}:+.${1:e}}:-}" "${@:2}"
}

# @desc: only renames using f2
function dbak-t()  { f2 -f "${1}$" -r "${1}.bak" -F; }
function dbak()    { f2 -f "${1}$" -r "${1}.bak" -Fx; }
function drbak-t() { f2 -f "${1}.bak$" -r "${1}" -F; }
function drbak()   { f2 -f "${1}.bak$" -r "${1}" -Fx; }
# ]]]

# === File Mod =========================================================== [[[
# @desc: remove broken symlinks
function rmsym() { command rm -- *(-@D); }
# @desc: remove broken symlinks recursively
function rmsymr() { command rm -- **/*(-@D); }
# @desc: remove space from file name
function rmspace() { f2 -f '[ ]{1,}' -r '_' -f '_-_' -r '-' -RFHd $@ }
function rmdouble() { f2 -f '(\w+) \((\d+)\).(\w+)' -r '$2-$1.$3' $@ }
function tolower() { f2 -r '{.lw}' -RFHd $@ }
# ]]]

# === Files ============================================================== [[[
# @desc: shred and delete file
# dd f=/dev/random of="$1"
function shredd() { shred -v -n 1 -z -u  $1;  }

# @desc: copy directory
function pbcpd() { builtin pwd | tr -d "\r\n" | xsel -b; }
# @desc: create file from clipboard
function pbpf() { xsel -b > "$1"; }
# @desc: copy contents of file to clipboard
function pbcf() { xsel -ib --trim < "${1:-/dev/stdin}"; }

# ============== Moving Files ============= [[[
# @desc: rsync from local pc to server
function rst()  { rsync -kuvrP "$1" root@lmburns.com:"$2" ; }
function rsf()  { rsync -kuvrP root@lmburns.com:"$1" "$2" ; }
function rstm() { rsync -kuvrP "$1" macbook:/Users/lucasburns/"$2" ; }
function rsfm() { rsync -kuvrP macbook:"$1" "$2" ; }
function cp-mac() { cp -r /run/media/lucas/exfat/macos-full/lucasburns/${1} ${2}; }
# ]]]

# @desc: add current directory to zoxide N times
function zoxide-add() {
  typeset -gH desc; desc='add current directory to zoxide N times'
  integer n; n=${1:-10}
  for 1 ({1..$n}) { zoxide add $PWD }
}

# @desc: directory hash
function sha256dir() { fd . -tf -x sha256sum | cut -d' ' -f1 | sort | sha256sum | cut -d' ' -f1; }
function b3sumdir()  { b3sum <<<${(@of):-"$(fd $1 -tf -x b3sum --no-names)"} }

function megahash() { b3sum <<<${(pj:\0:)${(@s: :)"$(rhash --all $@)"}[2,-1]}; }
# ]]]

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

function print::help() {
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
function print::header() {
  print -Pr -- "%F{$1}%B$2:%f%b"
}
function print::usage() {
  print::header 12 "USAGE"
  print -Pr -- "  %F{52}%BUsage%b%f: %F{2}$1%f ${@:2}"
}

# === Tools ============================================================== [[[
# @desc: create py file to sync with ipynb
function jupyt() { jupytext --set-formats ipynb,py $1; }

# @desc: use `up` pipe with any file
function upp() { cat $1 | up; }

# @desc: crypto information
function ratesx() { curl rate.sx/$1; }

# @desc: latex documentation search (as best I can)
function latexh() { zathura -f "$@" "$HOME/projects/latex/docs/latex2e.pdf" }

# @desc: monitor core dumps
function moncore() { fswatch --event-flags /cores/ | xargs -I{} notify-send "Coredump" {} }

# @desc: search for a keyword in a manpage and open it
function man-search() {
  man -P "less -p $2" "$1"
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
  nvim +"help $1" +'map q ZQ' +'bw 1'
  # +only
}

# ============== File Format ============== [[[
function pj() { perl -MCpanel::JSON::XS -0777 -E '$ip=decode_json <>;'"$@" ; }
function jqy() { yq e -j "$1" | jq "$2" | yq - e; }

# @desc: HTML to Markdown
function w2md() {
  local isurl=${${${(M)1:#https#:\/\/*}:+1}:-0}
  local output="${2:-${${1:t:r}:-output}.md}"
  function ___w2md() {
    html2text \
      --unicode-snob \
      --asterisk-emphasis \
      --body-width 0 \
      --open-quote="'" \
      --mark-code \
      --links-after-para \
      --no-wrap-links \
      --ignore-images \
      --default-image-alt='NULL' \
      "$@"
  }

  (
    (( $isurl )) && {
      wget -q "$1" \
        | iconv -t utf-8 \
        | ___w2md
    } || ___w2md "$1"
  ) | sponge -a "$output"
}

function w2md-clean() {
  fastmod '\[code\]' '```zsh' "$1"
  fastmod '\[/code\]' '```' "$1"
  fastmod '^\s*$\n```' '```' "$1"
  fastmod '^(\s*\n){2,}' $'\n' "$1"
  fastmod '\[\*\*' '[' "$1"
  fastmod '\*\*]' ']' "$1"
}
# ]]]

# ================== Bin ================== [[[
# @desc: link file from mybin to $PATH
function lnbin() {
  zmodload -F zsh/files b:zf_ln 2>/dev/null &&
    zf_ln -si $HOME/mybin/$1 $XDG_BIN_HOME
}
# @desc: unlink file from mybin to $PATH
function unlbin() {
  zmodload -F zsh/files b:zf_rm 2>/dev/null &&
    zf_rm rm -v $XDG_BIN_HOME/$1
}

# @desc: removes /$HOME/mybin from $PATH
function mybin_off() { path=( "${path[@]:#$HOME/mybin}" ) }
# @desc: adds /$HOME/mybin to $PATH
function mybin_on()  { mybin_off; PATH=$PATH:$HOME/mybin; }

# @desc: removes /$HOME/bin from $PATH
function homebin_off() { path=( "${path[@]:#$HOME/bin}" ) }
# @desc: adds /$HOME/bin to $PATH
function homebin_on()  { homebin_off; PATH=$PATH:$HOME/bin; }

# @desc: removes /usr/local/{bin,sbin} from $PATH
function localbin_off() { path=( "${path[@]:#/usr/local/bin}" ); path=( "${path[@]:#/usr/local/sbin}" ); }
# @desc: adds /usr/local/{bin,sbin} to $PATH
function localbin_on()  { localbin_off; PATH=$PATH:/usr/local/bin:/usr/local/sbin }
# ]]]

# ================= Image ================= [[[
function jpeg() { jpegoptim -S "${2:-1000}" "$1"; jhead -purejpg "$1" && du -sh "$1"; }
function pngo() { optipng -o"${2:-3}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
function png()  { pngquant --speed "${2:-4}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
# ]]]

# @desc: date format for taskwarrior
function td() { date -d "+${*}" "+%FT%R" ; }
# @desc: edit file recursively
function ee() { lax -f nvim "@${1}" ; }
# @desc: open $PWD in file browser
function ofd() { handlr open "$PWD" ; }

# @desc: convert hexadecimal to base 10
function h2d() { builtin print $(( [#10_3] 0x${1#0x} )); }
# @desc: convert hexadecimal to octal
function h2o() { builtin print $(( [#8_3] 0x${1#0x} )); }
# @desc: convert hexadecimal to binary
function h2b() { builtin print "0b$(( [##2_4] 0x${1#0x} ))"; }

# @desc: convert base 10 to hexadecimal
function d2h() { builtin print $(( [#16] $1 )); }
# @desc: convert base 10 to octal
function d2o() { builtin print $(( [#8_3] $1 )); }
# @desc: convert base 10 to binary
function d2b() { builtin print "0b$(( [##2_4] $1 ))"; }

# @desc: convert octal to base 10
function o2d() { builtin print $(( [#10_3] 0${1#0} )); }
# @desc: convert octal to hexadecimal
function o2h() { builtin print $(( [#16] 0${1#0} )); }
# @desc: convert octal to binary
function o2b() { builtin print "0b$(( [##2_4] 0${1#0} ))"; }

# @desc: convert binary to base 10
function b2d() { builtin print $(( [#10_3] 0b${1#0b} )); }
# @desc: convert binary to hexadecimal
function b2h() { builtin print $(( [#16] 0b${1#0b} )); }
# @desc: convert binary to octal
function b2o() { builtin print $(( [#8_3] 0b${1#0b} )); }

# function b2o() { print "0o$(( [##8_3] 0b${1#0b} ))"; }
# print 'obase=16; ibase=8; $1' | bc
# [#16_4]   printf 0x%X\\n $1;

# @desc: move items out of a directory
function mvout() { command cp -vaR ${1:?Invalid directory}/ . }
function mvoutc() { command cp -vaR ${1:?Invalid directory}/ . && rip ${1}/ }

# @desc: create 'gif' and 'video' dirs, then move those filetypes into the directory
function mvmedia() {
  mkdir -p gif video
  fd -e gif -d1 -x mv {} gif &&
    fd -e webm -d1 -x mv {} video
}

# @desc: create png from gif
function create-gif() {
  convert -verbose -coalesce ${1} ${1:r}.png
}

# @desc: use youtube-dl to get audio
function get-mp3() {
  youtube-dl -f bestaudio -x --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s' $@
}

# @desc: copy 4chan thread
function threadc() {
  local t=$1
  threadwatcher add $t $PWD/${t:t}
}
# ]]]

# === Git ================================================================ [[[
compdef _rg nrg
function nrg() {
  if [[ $* ]]; then
     nvim +'pa nvim-treesitter' \
          +"Grepper -noprompt -dir cwd -grepprg rg $* --max-columns=200 -H --no-heading --vimgrep -C0 --color=never"
  else
     rg
  fi
}
function ngf() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 && nvim +"lua require('plugs.fugitive').index()"
}
function ngd() {
  command git rev-parse >/dev/null 2>&1 && nvim +"DiffviewFileHistory"
}
function ngo() {
  command git rev-parse >/dev/null 2>&1 && nvim +"DiffviewOpen"
}
function ngl() {
  command git rev-parse >/dev/null 2>&1 && nvim +"Flog -raw-args=${*:+${(q)*}}" +'bw 1'
}

function __ngl_compdef() {
  (( $+functions[_git-log] )) || _git
  _git-log
}
compdef __ngl_compdef ngl

# @desc: git change root
function gcr() {
  builtin cd "$(git rev-parse --show-toplevel)"
}

# @desc: check what master branch's name is
function git_main_branch() {
  local b branch="master"
  for b (main trunk) {
    command git show-ref -q --verify refs/heads/$b && { branch=$b; break; }
  }
  print -Pr -- "%B$branch%b"
}

function git_urls() {
  () {
    rmansi -i $1;
    cat $1 >| out
  } =(mgit remote get-url origin)
}
# ]]]

# === X11 ================================================================ [[[
# @desc: list X11 windows
function lswindows() {
  # Has a lot more info
  typeset -ga xlist
  xlist=("${(@)${(M@)${(@f)$(xwininfo -root -tree)}:#[  ]#0x[0-9a-f]# \"*}##[   ]#}")

  typeset -gA xlistmap
  for val ($xlist[@]) {
    xlistmap[${val%% *}]=${${(@)val#*\"}%%\"*}
  }

  print -raC 2 ${(kv)xlistmap}
}
# ]]]

# === Typescript ========================================================= [[[
# @desc: Hardlink relevant files to a Typescript project
function linkts() {
  command ln -v $XDG_DATA_HOME/typescript/ts_justfile $PWD/justfile
  command ln -v $XDG_CONFIG_HOME/typescript/eslintrc.js $PWD/.eslintrc.js
  command ln -v $XDG_CONFIG_HOME/typescript/tsconfig.json $PWD/tsconfig.json
  # command cp -v $HOME/projects/rust/.pre-commit-config.yaml $PWD/.pre-commit-config.yaml
}
# ]]]

# === Rust =============================================================== [[[
# @desc: Hardlink relevant files to a Rust project
function linkrust() {
  command ln -v $XDG_CONFIG_HOME/rust/rust_justfile $PWD/justfile
  command ln -v $XDG_CONFIG_HOME/rust/rustfmt.toml $PWD/rustfmt.toml
  command cp -v $XDG_CONFIG_HOME/rust/pre-commit-config.yaml $PWD/.pre-commit-config.yaml
}

function cargo-bin() {
  local root binpath bin
  root=${$(cargo locate-project | jq -r '.root'):h} bin=${root:t}
  binpath=${root}/target/release/${bin}
  if [[ -x $binpath ]] {
      command mv $binpath $root && cargo trim clear
  } elif [[ -x $root/$bin ]] {
      cargo trim clear
  }
}

# function cargo-take() { cargo new "$@" && builtin cd "$@"; }
function cargo-home() { cargo show "${@}" --json | jq -r .crate.homepage; }
function cdc() { builtin cd ${$(cargo locate-project | jq -r '.root'):h}; }
function cme() { $EDITOR ${$(cargo locate-project | jq -r '.root'):h}/src/main.rs; }
function cml() { $EDITOR ${$(cargo locate-project | jq -r '.root'):h}/src/lib.rs; }
function cmc() { $EDITOR ${$(cargo locate-project | jq -r '.root'):h}/Cargo.toml; }

# @desc: wrapper for rusty-man for tui
function rmant() { rusty-man "$1" --theme 'Solarized (dark)' --viewer tui "${@:2}"; }
# ]]]

# === TIP: =========================================================== [[[
# print -P '%15>...>%d' => /home/lucas/...
# print -P '%15<...<%d' => ...fig/nvim/lua

# Longest element
# ${arr[(r)${(l.${#${(O@)arr//?/X}[1]}..?.)}]}
# ${(M)array:#${~${(O@)array//?/?}[1]}}

# Reverse word
# ${(j::)${(@Oa)${(s::):-word}}}

# All .c files with no matching .o
# *.c(e_'[[ ! -e $REPLY:r.o ]]'_)
# *.zsh(Noe!'REPLY=${REPLY:t}'!oe!'[[ $REPLY == *local* ]] && REPLY=0 || REPLY=1'!^-@)

# Save arrays
# print -r -- ${(qq)m} > $fname
# m=( "${(@Q)${(z)"$(<$fname)"}}" )

# ━Best Practices━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# typeset -g prjef
# prjef=( ${(k)functions} )
# trap "unset -f -- \"\${(k)functions[@]:|prjef}\" &>/dev/null; unset prjef" EXIT
# trap "unset -f -- \"\${(k)functions[@]:|prjef}\" &>/dev/null; unset prjef; return 1" INT

# ━Scope━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# .func = private
# →func = hooks
# +func = output
# /func = debug
# @func = api

# ━Variables━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ${langinfo[T_FMT_AMPM]}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# find -L . -inum 101715870  (not present in fd)
# print -l /proc/*/cwd(:h:t:s/self//)

# emulate -L zsh -o cbases -o octalzeroes
# local REPLY
# local -a reply stat lstat

# zstat -A lstat -L -- $1
# # follow symlink
# (( lstat[3] & 0170000 )) && zstat -A stat -- $1 2>/dev/null
# ]]]

# vim: ft=zsh:et:sw=0:ts=2:sts=2
