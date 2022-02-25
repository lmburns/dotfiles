# ============================== Rust ==============================
# Hardlink relevant files to a Rust project
function linkrust() {
  command ln -v $XDG_DATA_HOME/just/rust_justfile $PWD/justfile
  command ln -v $HOME/projects/rust/rustfmt.toml $PWD/rustfmt.toml
  command cp -v $HOME/projects/rust/.pre-commit-config.yaml $PWD/.pre-commit-config.yaml
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

# wrapper for rusty-man for tui
function rmant() { rusty-man "$1" --theme 'Solarized (dark)' --viewer tui "${@:2}"; }

# ============================== WiFi ==============================
# lsof open fd
zmodload -F zsh/system p:sysparams
function lsdelete()  { lsof -n | rg -i --color=always deleted }
function myip()      { curl https://api.myip.com; }
function lsfd()      { lsof -p $sysparams[ppid] | hck -f1,4,5- ; }
function lswifi()    { nmcli device wifi; }
function wifi-info() { command iw dev ${${=${${(f)"$(</proc/net/wireless)"}:#*\|*}[1]}[1]%:} link; }

# find functions that follow this pattern: func()
function ffunc() { eval "() { $functions[RG] } ${@}\\\\\("; }

# List functions
function lsfuncs {
  emulate -L zsh -o extendedglob
  zmodload -Fa zsh/parameter p:functions

  [[ $1 = -a ]] && {
    print -rl -- ${${(@o)${(k)functions[(I)^[→_.+:@-]*]}}}
  } || {
    print -rl -- $^fpath/${^${(@o)${(k)functions[(I)^[→_.+:@-]*]}}}(#qN) | lscolors
  } | bat
}

# rsync from local pc to server
function rst() { rsync -uvrP $1 root@lmburns.com:$2 ; }
function rsf() { rsync -uvrP root@lmburns.com:$1 $2 ; }

# create py file to sync with ipynb
function jupyt() { jupytext --set-formats ipynb,py $1; }

# use up pipe with any file
function upp() { cat $1 | up; }

# crypto
function ratesx() { curl rate.sx/$1; }

# Shred and delete file
function sshred() { shred -v -n 1 -z -u  $1;  }

# Move items out of a directory
function mvout-clean() { command rsync -vua --delete-after $1/ . ; }
function mvout() { command rsync -vua $1/ . ; }

# copy directory
function pbcpd() { builtin pwd | tr -d "\r\n" | xsel -b; }
# create file from clipboard
function pbpf() { xsel -b > "$1"; }
# copy file to clipboard
function pbcf() { xsel -b < "${1:-/dev/stdin}"; }

# ========================== Backup ==========================
# function bak()  { renamer '$=.bak' "$@"; }
# function rbak() { renamer '.bak$=' "$@"; }

# Perl rename
function backup-t()  { rename -n 's/^(.*)$/$1.bak/g' $@ }
function backup()    { rename    's/^(.*)$/$1.bak/g' $@ }
function restore-t() { rename -n 's/^(.*).bak$/$1/g' $@ }
function restore()   { rename    's/^(.*).bak$/$1/g' $@ }

# Backup files
function bak()  { command cp -vr --preserve=all --force --suffix=.bak $1 $1 }
function rbak() { command cp -vr --preserve=all --force $1.bak $1 }

# Backup a file
function bk() {
  emulate -L zsh
  cp -iv --preserve=all -b $1 ${1:r}_$(date --iso-8601=m).${1:e}
}

# only renames
function dbak-t()  { f2 -f "${1}$" -r "${1}.bak" -F; }
function dbak()    { f2 -f "${1}$" -r "${1}.bak" -Fx; }
function drbak-t() { f2 -f "${1}.bak$" -r "${1}" -F; }
function drbak()   { f2 -f "${1}.bak$" -r "${1}" -Fx; }

# link unlink file from mybin to $PATH
function lnbin() { ln -siv $HOME/mybin/$1 $XDG_BIN_HOME; }
function unlbin() { rm -v /$XDG_BIN_HOME/$1; }

# Latex documentation serch (as best I can)
function latexh() { zathura -f "$@" "$HOME/projects/latex/docs/latex2e.pdf" }

# cd into directory
# function take() { mkdir -p $@ && cd ${@:$#} }

# html to markdown
function w2md() { wget -qO - "$1" | iconv -t utf-8 | html2text -b 0; }

function allcmds() { print -l ${commands[@]} | awk -F'/' '{print $NF}' | fzf; }

# Directory hash
function sha256dir() { fd . -tf -x sha256sum | cut -d' ' -f1 | sort | sha256sum | cut -d' ' -f1; }
function b3sumdir()  { print -rl -- ${(@of):-"$(fd $1 -tf -x b3sum --no-names)"} | b3sum; }

# Remove broken symlinks
function rmsym() { command rm -- *(-@D); }
# Remove broken symlinks recursively
function rmsymr() { command rm -- **/*(-@D); }
# Remove ansi from file
function rmansi() { sed -i "s,\x1B\[[0-9;]*[a-zA-Z],,g" $1;  }
# Remove space from file name
function rmspace() { f2 -f '\s' -r '_' -RF $@ }
function rmdouble() { f2 -f '(\w+) \((\d+)\).(\w+)' -r '$2-$1.$3' $@ }

# monitor core dumps
function moncore() { fswatch --event-flags /cores/ | xargs -I{} notify-send "Coredump" {} }

function ww() {
  (alias; declare -f) |
    /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@;
}

function pj() { perl -MCpanel::JSON::XS -0777 -E '$ip=decode_json <>;'"$@" ; }
function jqy() { yq e -j "$1" | jq "$2" | yq - e; }

function jpeg() { jpegoptim -S "${2:-1000}" "$1"; jhead -purejpg "$1" && du -sh "$1"; }
function pngo() { optipng -o"${2:-3}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
function png() { pngquant --speed "${2:-4}" "$1"; exiftool -all= "$1" && du -sh "$1"; }

# date format for taskwarrior
function td() { date -d "+${*}" "+%FT%R" ; }
function ee() { lax -f nvim "@${1}" ; }
function ofd() { handlr open $PWD ; }

function cp-mac() { cp -r /run/media/lucas/exfat/macos-full/lucasburns/${1} ${2}; }

function double-accept() { deploy-code "BUFFER[-1]=''"; }
zle -N double-accept

function zinit-palette() {
  for k ( "${(@kon)ZINIT[(I)col-*]}" ); do
    local i=$ZINIT[$k]
    print "$reset_color${(r:14:: :):-$k:} $i###########"
  done
}

# Create temporary directory and cd to it
function cdt() {
  local t
  t=$(mktemp -d)
  echo "$t"
  builtin cd -q "$t"
}

# Profile zsh: Method 1
function time-zsh() {
  for i ({1..10}) { /usr/bin/time $SHELL -i -c 'print; exit' }
}
# Profile zsh: Method 2 (hyperfine)
function hyperfine-zsh() {
  hyperfine "$SHELL -c 'exit'";
}
#  Profile zsh: Method 2 (zprof)
function profile-zsh() {
  ZSHRC_PROFILE=1 zsh -i -c zprof | bat
}
# Profile zsh: Method 3 (any cmd)
function profile() {
  ZSH_PROFILE_RC=1 $SHELL "$@"
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

# ============================== Helper ==============================
# ====================================================================
function print::warning() { print -Pr -- "%F{3}[WARNING]%f: $*"; }
function print::error()   { print -Pr -- "%F{1}%B[ERROR]%f%b: $*"; }
function print::debug()   { print -Pr -- "%F{4}[DEBUG]%f: $*"; }
function print::info()    { print -Pr -- "%F{5}[INFO]%f: $*"; }
function print::notice()  { print -Pr -- "%F{13}[NOTICE]%f: $*"; }
function print::success() { print -Pr -- "%F{2}%B[SUCCESS]%f%b: $*"; }

# ============================== Compdef =============================
# ====================================================================
compdef _aliases       ealias
compdef _functions     efunc
compdef _command_names wim
compdef _functions     fim
compdef _functions     freload

# ======================== Dynamic Directory =========================
# ====================================================================
# Why both?
# typeset -gA zdn_wrap_top=(
#   p         ~/projects
#   c         ~/.config/:second2
#   :default: /:second1
# )
#
# typeset -gA zdn_top=(
#   p         ~/projects
#   c         ~/.config/:second2
#   :default: /:second1
# )
#
# typeset -gA second1=(
#     g  github/:third
#     p  perl
#     py python
#     r  ruby
# )
#
# typeset -gA second2=(
#     zd  zsh/zsh.d
#     zi  zsh/zinit
#     zc  zsh/csnippets
#     zf  zsh/functions
# )
#
# typeset -gA third=(
#   w wutag
#   l lxhkd
#   z zinit
# )
#
# # cdr is used instead
# zstyle ':zdn:zdn_wrap:' mapping zdn_wrap_top
# autoload -Uz add-zsh-hook zsh_directory_name_generic zdn_wrap
# add-zsh-hook -U zsh_directory_name zdn_wrap

# function zdn_wrap() {
#   autoload -Uz zsh_directory_name_generic
#   zsh_directory_name_generic "$@"
# }
