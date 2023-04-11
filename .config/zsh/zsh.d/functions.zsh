#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2022-03-11 23:00
#===========================================================================

# ============================ Zsh Specific ==========================
# ====================================================================

# `which` tool which has all information from `whence`
function ww() {
  (alias; declare -f) |
    /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@;
}

# List all commands
function allcmds() {
  print -l ${(k)commands[@]} | sk --preview-window=hidden;
}

# Display colors used with zinit
function zinit-palette() {
  for k ( "${(@kon)ZINIT[(I)col-*]}" ); do
    local i=$ZINIT[$k]
    print "$reset_color${(r:14:: :):-$k:} $i###########"
  done
}

# Create temporary directory and cd to it
function cdt() {
  local t=$(mktemp -d)
  # trap "[[ $PWD != $t ]] && rm $t" EXIT
  setopt localtraps
  echo "$t"
  builtin cd -q "$t"
}

function zsh-minimal() {
  cd "$(mktemp -d)"
  ZDOTDIR=$PWD HOME=$PWD zsh -df
}

# reload zsh function without sourcing zshrc
function freload() {
  while (( $# )); do; unfunction $1; autoload -U $1; shift; done
}

# Edit an alias via zle (whim -a)
function ealias() {
  [[ -z "$1" ]] && {
    print -Pr "Usage: %F{1}ealias%f <alias_to_edit>" ; return 1
  } || vared aliases'[$1]' ;
}

# Edit a function via zle (whim -f)
function efunc() {
  [[ -z "$1" ]] && {
    print -Pr "Usage: %F{1}efunc%f <function_to_edit>" ; return 1
  } || zed -f "$1" ;
}

# Find functions that follow this pattern: func()
function ffunc() {
  eval "() { $functions[RG] } ${@}\\\\\(";
}

# List loaded ZLE modules
function lszle() {
  # print -rl -- \
  #   ${${${(@f):-"$(zle -Ll)"}//(#m)*/${${(ws: :)MATCH}[1,3]}}//*(autosuggest|orig-s)*/} | \
  print -rl -- ${${(@f):-"$(zle -la)"}//*(autosuggest|orig-s)*/} \
    | bat
}

# List zstyle modules
function lszstyle() {
  print -Plr -- \
    ${${(@)${(@f):-"$(zstyle -L ':*')"}/*list-colors*/}//(#b)(zstyle) (*) (*) (*)/\
%F{1}$match[1]%f %F{3}$match[2]%f %F{14}%B$match[3]%b%f %F{2}$match[4]} \
  | bat
}

# Desc: tells from-where a zsh completion is coming from
function from-where {
  print -l -- $^fpath/$_comps[$1](N)
  whence -v $_comps[$1]
  #which $_comps[$1] 2>&1 | head
}

# Desc: tell which completion a command is using
function whichcomp() {
  for 1; do
      ( print -raC 2 -- $^fpath/${_comps[$1]:?unknown command}(NP*$1*) )
  done
}

# Desc: print path of zsh function
function whichfunc() {
  (( $+functions[$1] )) || print::error "$1 is not a function"
  for 1; do
    (
      print -PraC 2 -- \
        ${${(j: :):-$(print -r ${^fpath}/$1(#qNP*$1*))}//(#b)(*) (*)/%F{1}%B$match[1]%b %F{2}$match[2]}
    )
  done
}

# Disown a process
function run_diso {
  sh -c "${(z)@}" &>/dev/null &
  disown
}

# Nohup a process
function background() {
  nohup "${(z)@}" >/dev/null 2>&1 &
}

# Reinstall completions
function creinstall() {
  ___creinstall() {
    emulate zsh -ic "zinit creinstall -q $GENCOMP_DIR 1>/dev/null" &!
  }

  (( $+functions[defer] )) && { defer -c '___creinstall && src' }
  unfunction 'creinstall'
}

# ================================ Wifi ==============================
# ====================================================================
# lsof open fd
zmodload -F zsh/system p:sysparams
# Get your IP address
function myip()      { curl ipinfo.io/json | jq .; }
# List available Wifi networks
function lswifi()    { nmcli device wifi; }
# Get wifi information
function wifi-info() { command iw dev ${${=${${(f)"$(</proc/net/wireless)"}:#*\|*}[1]}[1]%:} link; }
# Nmap info
function lsnmap()    { nmap --iflist; }

# =============================== Listing ============================
# ====================================================================
# List information about current zsh process
function mem()      { sudo px $$; }
# List file descriptors
function lsfd()     { lsof -p $sysparams[ppid] | hck -f1,4,5- ; }
# List deleted items
function lsdelete() { lsof -n | rg -i --color=always deleted }
# List users on the computer
function lsusers()  { hck -d':' -f1 <<< "$(</etc/passwd)"; }
# List the fonts
function lsfont()   { fc-list -f '%{family}\n' | awk '!x[$0]++'; }

# List functions
function lsfuncs {
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


# ============================= Profiling ============================
# ====================================================================
# Profile zsh: Method 1
function time-zsh() { for i ({1..10}) { /usr/bin/time $SHELL -i -c 'print; exit' }; }
# Profile zsh: Method 2 (hyperfine)
function hyperfine-zsh() { hyperfine "$SHELL -ic 'exit'"; }
#  Profile zsh: Method 2 (zprof)
function profile-zsh() { $SHELL -i -c zprof | bat; }
# Profile zsh: Method 3 (any cmd)
# function profile() { $SHELL "$@"; }

# ============================= List Ext =============================
# ====================================================================
# List files which have been accessed within the last n days
# emulate -R zsh -c 'print -l -- *(a-${1:-1})'
function accessed() { ls -- */*(a-${1:-1}); }
function changed()  { ls -- */*(c-${1:-1}); }
function modified() { fd --changed-within ${1:-1day} -d${2:-1}; }

# List files which have been accessed within the last n days recursively
# The above is recursive, but this lists differently
function accessedr() { ll -R -- *(a-${1:-1}); }
function changedr()  { ll -R -- *(c-${1:-1}); }
function modifiedr() { ll -R -- *(m-${1:-1}); }

# ============================== Backup ==============================
# ====================================================================
# function bak()  { renamer '$=.bak' "$@"; }
# function rbak() { renamer '.bak$=' "$@"; }

# Perl rename
function backup-t()  { rename -n 's/^(.*)$/$1.bak/g' $@ }
function backup()    { rename    's/^(.*)$/$1.bak/g' $@ }
function restore-t() { rename -n 's/^(.*).bak$/$1/g' $@ }
function restore()   { rename    's/^(.*).bak$/$1/g' $@ }

# Backup files
function bak()  {
  command cp -vruT --preserve=all --force --backup=existing $1 $1
}
function rbak() { command cp -vr --preserve=all --force $1.bak $1 }

# Backup a file. 'fname' -> 'fname_2023-01-30T14:23-06:00'
function bk() {
  emulate -L zsh
  command cp -ivrT --preserve=all -b "$1" "${1:r}_$(date --iso-8601=m)${${${1:e}:+.${1:e}}:-}"
}

# Backup a file with only a date. 'fname' -> 'fname_2023_01_30'
function bk-today() {
  emulate -L zsh
  command cp -ivruT --preserve=all -b "$1" "${1:r}_$(date '+%Y_%m_%d')${${${1:e}:+.${1:e}}:-}"
}

# Add a date suffix to a file
function datify() {
  emulate -L zsh
  # command mv -iv $1 ${1:r}_$(date '+%Y_%m_%d')${${${1:e}:+.${1:e}}:-}
  f2 -FRf "${1}$" -r "${1:r}_{{mtime.YYYY}}_{{mtime.MM}}_{{mtime.DD}}${${${1:e}:+.${1:e}}:-}" "${@:2}"
}

# Only renames using f2
function dbak-t()  { f2 -f "${1}$" -r "${1}.bak" -F; }
function dbak()    { f2 -f "${1}$" -r "${1}.bak" -Fx; }
function drbak-t() { f2 -f "${1}.bak$" -r "${1}" -F; }
function drbak()   { f2 -f "${1}.bak$" -r "${1}" -Fx; }

# ============================= File Mod =============================
# ====================================================================
# Remove broken symlinks
function rmsym() { command rm -- *(-@D); }
# Remove broken symlinks recursively
function rmsymr() { command rm -- **/*(-@D); }
# Remove ansi from file
function rmansi() { sed -i "s,\x1B\[[0-9;]*[a-zA-Z],,g" ${1:-/dev/stdin};  }
# Remove space from file name
function rmspace() { f2 -f '[ ]{1,}' -r '_' -f '_-_' -r '-' -RFHd $@ }
function rmdouble() { f2 -f '(\w+) \((\d+)\).(\w+)' -r '$2-$1.$3' $@ }
function tolower() { f2 -r '{.lw}' -RFHd $@ }

# ============================= Typescript ===========================
# ====================================================================
# Hardlink relevant files to a Typescript project
function linkts() {
  command ln -v $XDG_DATA_HOME/typescript/ts_justfile $PWD/justfile
  command ln -v $XDG_CONFIG_HOME/typescript/eslintrc.js $PWD/.eslintrc.js
  command ln -v $XDG_CONFIG_HOME/typescript/tsconfig.json $PWD/tsconfig.json
  # command cp -v $HOME/projects/rust/.pre-commit-config.yaml $PWD/.pre-commit-config.yaml
}

# ================================ Rust ==============================
# ====================================================================
# Hardlink relevant files to a Rust project
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

# Wrapper for rusty-man for tui
function rmant() { rusty-man "$1" --theme 'Solarized (dark)' --viewer tui "${@:2}"; }

# ============================== Other ===============================
# ====================================================================

# ============================== Files ===============================
# Shred and delete file
# dd f=/dev/random of="$1"
function shredd() { shred -v -n 1 -z -u  $1;  }

# Copy directory
function pbcpd() { builtin pwd | tr -d "\r\n" | xsel -b; }
# Create file from clipboard
function pbpf() { xsel -b > "$1"; }
# Copy file to clipboard
function pbcf() { xsel -ib --trim < "${1:-/dev/stdin}"; }

# === Moving Files ===
# Rsync from local pc to server
function rst() { rsync -uvrP $1 root@lmburns.com:$2 ; }
function rsf() { rsync -uvrP root@lmburns.com:$1 $2 ; }
function cp-mac() { cp -r /run/media/lucas/exfat/macos-full/lucasburns/${1} ${2}; }

# Link unlink file from mybin to $PATH
function lnbin() { ln -siv $HOME/mybin/$1 $XDG_BIN_HOME; }
function unlbin() { rm -v $XDG_BIN_HOME/$1; }

# Directory hash
function sha256dir() { fd . -tf -x sha256sum | cut -d' ' -f1 | sort | sha256sum | cut -d' ' -f1; }
function b3sumdir()  { b3sum <<<${(@of):-"$(fd $1 -tf -x b3sum --no-names)"} }

function megahash() { b3sum <<<${(pj:\0:)${(@s: :)"$(rhash --all $@)"}[2,-1]}; }

# ============================== Tools  ==============================
# Create py file to sync with ipynb
function jupyt() { jupytext --set-formats ipynb,py $1; }

# Use `up` pipe with any file
function upp() { cat $1 | up; }

# Crypto information
function ratesx() { curl rate.sx/$1; }

# Latex documentation search (as best I can)
function latexh() { zathura -f "$@" "$HOME/projects/latex/docs/latex2e.pdf" }

# Monitor core dumps
function moncore() { fswatch --event-flags /cores/ | xargs -I{} notify-send "Coredump" {} }

# === File Format ===
function pj() { perl -MCpanel::JSON::XS -0777 -E '$ip=decode_json <>;'"$@" ; }
function jqy() { yq e -j "$1" | jq "$2" | yq - e; }

# === Image ===
function jpeg() { jpegoptim -S "${2:-1000}" "$1"; jhead -purejpg "$1" && du -sh "$1"; }
function pngo() { optipng -o"${2:-3}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
function png()  { pngquant --speed "${2:-4}" "$1"; exiftool -all= "$1" && du -sh "$1"; }

# Date format for taskwarrior
function td() { date -d "+${*}" "+%FT%R" ; }
# Edit file recursively
function ee() { lax -f nvim "@${1}" ; }
# Open $PWD in file browser
function ofd() { handlr open $PWD ; }

# Convert hexadecimal to base 10
function h2d() { print $(( $1 )); }
# Convert hexadecimal to octal
function h2o() { print $(( [##8] 0x$1 )); }
# Convert base 10 to hexadecimal
function d2h() { print $(( [##16] $1 )); } # printf 0x%X\\n $1;
# Convert base 10 to octal
function d2o() { print $(( [##8] $1 )); }
# Convert octal to base 10
function o2d() { print $(( 0$1 )); }
# Convert octal to hexadecimal
function o2h() { print $(( [##16] 0$1 )); print -- -1 } # print 'obase=16; ibase=8; $1' | bc

# HTML to Markdown
function w2md() { wget -qO - "$1" | iconv -t utf-8 | html2text -b 0; }

# Move items out of a directory
function mvout() { command cp -vaR ${1:?Invalid directory}/ . }
function mvoutc() { command cp -vaR ${1:?Invalid directory}/ . && rmdir ${1}/ }

# Create 'gif' and 'video' dirs, then move those filetypes into the directory
function mvmedia() {
  mkdir -p gif video
  fd -e gif -d1 -x mv {} gif &&
    fd -e webm -d1 -x mv {} video
}

# Create png from gif
function create-gif() {
  convert -verbose -coalesce ${1} ${1:r}.png
}

# ================================ Git ===============================
# ====================================================================
compdef _rg nrg
function nrg() {
  if [[ $* ]]; then
     nvim +'pa nvim-treesitter' \
          +"Grepper -noprompt -dir cwd -grepprg rg $* --max-columns=200 -H --no-heading --vimgrep -C0 --color=never"
  else
     rg
  fi
}

function ng() {
  command git rev-parse >/dev/null 2>&1 && nvim +"lua require('plugs.fugitive').index()"
}

compdef __ngl_compdef ngl
function ngl() {
  command git rev-parse >/dev/null 2>&1 && nvim +"Flog -raw-args=${*:+${(q)*}}" +'bw 1'
}

function __ngl_compdef() {
  (( $+functions[_git-log] )) || _git
  _git-log
}

# Git change root
function cr() {
  builtin cd "$(git rev-parse --show-toplevel)"
}

# ================================ X11 ===============================
# ====================================================================

# List X11 windows
function lswindows() {
  # Has a lot more info
  typeset -ga xlist
  xlist=("${(@)${(M@)${(@f)$(xwininfo -root -tree)}:#[ 	]#0x[0-9a-f]# \"*}##[ 	]#}")

  typeset -gA xlistmap
  for val ($xlist[@]) {
    xlistmap[${val%% *}]=${${(@)val#*\"}%%\"*}
  }

  print -raC 2 ${(kv)xlistmap}
}

# ============================== Helper ==============================
# ====================================================================
# ${${${(D)${${${a[1]#_}%:*}:A}}//\~config\/zsh/ZSH}//\~config/CONFIG}

function print::error()   {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  # local func=${${functrace[1]#_}%:*}
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{12}%B[ERROR]%f%b:%F{20}${func}%f:%F{21}${file}%f: $*"
}
function print::warning() {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{13}%B[WARNING]%b%f:%F{20}${func}%f:%F{21}${file}%f: $*"
}
function print::info()    {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{52}%B[INFO]%b%f:%F{20}${func}%f:%F{21}${file}%f: $*"
}
function print::debug()   {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{18}%B[DEBUG]%b%f:%F{20}${func}%f:%F{21}${file}%f: $*"
}
function print::trace()   {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{47}%B[TRACE]%b%f:%F{20}${func}%f:%F{21}${file}%f: $*"
}
function print::notice()  {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{22}%B[NOTICE]%b%f:%F{20}${func}%f:%F{21}${file}%f: $*"
}
function print::success() {
  local cpat="\~config/"; local zpat="${cpat}zsh/"
  local func=$funcstack[-1]
  local file=${${${(D)${${${funcsourcetrace[-1]#_}%:*}:A}}//${~zpat}}//${~cpat}}
  print -Pru2 -- "%F{53}%B[SUCCESS]%f%b:%F{20}${func}%f:%F{21}${file}%f: $*"
}

function zsh::log() {
  setopt localoptions nopromptsubst
  zmodload -Fa zsh/parameter p:functrace p:funcsourcetrace
  zmodload -Fa zsh/zutil b:zparseopts
  local -A opts; zparseopts -E -D -A opts n:

  local logtype=$1
  local logname=${opts[-n]:-}

  case $logtype in
    (success|0) print -Pn "%U%F{53}${logname:+${logname}:}%f%u";  print::success "$2" ;;
    (notice)    print -Pn "%U%F{54}${logname:+${logname}:}%f%u:"; print::notice  "$2" ;;
    (trace|1)   print -Pn "%U%F{54}${logname:+${logname}:}%f%u:"; print::trace   "$2" ;;
    (debug|2)   print -Pn "%U%F{54}${logname:+${logname}:}%f%u "; print::debug   "$2" ;;
    (info|3)    print -Pn "%U%F{54}${logname:+${logname}:}%f%u "; print::info    "$2" ;;
    (warn|4)    print -Pn "%S%F{54}${logname:+${logname}:}%f%s "; print::warning "$2" ;;
    (error|5)   print -Pn "%S%F{12}${logname:+${logname}:}%f%s "; print::error   "$2" ;;
  esac >&2
}

# Dump all kinds of info
function log::dump() {
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

# === TIP: =========================================================== [[[
# print -P '%15>...>%d' => /home/lucas/...
# print -P '%15<...<%d' => ...fig/nvim/lua
# ]]]

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]
