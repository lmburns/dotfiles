#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2022-03-11                                                   #
#    @module: functions                                                    #
#      @desc: Other functions for zsh                                      #
#===========================================================================

# TODO: add function fzf files for zsh

# ============================ Zsh Specific ==========================
# ====================================================================

# @desc: `which` tool which has all information from `whence`
function ww() {
  (alias; declare -f) |
    /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@;
}

function zsh-minimal() {
  builtin cd "$(mktemp -d)"
  ZDOTDIR=$PWD HOME=$PWD zsh -df
}

# @desc: reload zsh function without sourcing zshrc
function freload() {
  while (($#)) { unfunction $1 && autoload -U $1 && shift }
}

# @desc: reload zwc functions
function freloadz() {
  local -a zwcdirs=(${Zdirs[FUNC]}/${(P)^Zdirs[FUNC_D_zwc]}.zwc)
  for dir ($zwcdirs[@]) {
    dir=${dir%.zwc}
    zwc=${dir:t}
    if [[ ! -d $dir ]]; then
      zinfo -v "$dir is not a directory to compile"
      continue
    fi
    if [[ $dir == (.|..) || $dir == (.|..)/* ]]; then
      continue
    fi
    files=($dir/*~*.zwc(|.old)(#qN-.))
    if [[ -w $dir:h && -n $files ]]; then
      files=(${${(M)files%/*/*}#/})
      if ( builtin cd -q $dir:h &&
          zrecompile -p -U -z $zwc $files ); then
        zinfo -v "updated: $dir"
      fi
    fi
  }
  fpath=${fpath[@]:|zwcdirs}
  fpath[1,$#zwcdirs]=($zwcdirs)
  autoload -Uwz ${(@z)fpath[1,$#zwcdirs]}
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

# @desc: list all commands
function lscmds() {
  emulate -L zsh
  # zmodload -Fa zsh/parameter p:commands
  # print -rl -- $^path/${(ok)^commands[@]}(#qN) \
    # | lscolors \

  # hash \
  #   | perl -F= -lane 'printf "%-30s %s\n", $F[0], $F[1]' \

  print -rl -- ${(ov)commands[@]} \
    | lscolors \
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

# @desc: print path of zsh function
function wherefunc() {
  (( $+functions[$1] )) || zerr "$1 is not a function"
  for 1; do
    (
      local out=${${(j: :):-$(print -r ${^fpath}/$1(#qNP-$1-))}//(#b)(*) (*)/%F{1}%B$match[1]%b %F{2}$match[2]}
      if ((!$#out)) {
        zinfo -s "{func}$1{%} is a function, but it is in a {file}zwc{%} file"
        out=${${(j: :):-$(\
          print -r ${Zdirs[FUNC]}/${(P)^Zdirs[FUNC_D_zwc]}/$1(#qNP-$1-))}//(#b)(*) (*)/%F{1}%B$match[1]%b %F{2}$match[2]}
      }
      print -PraC 2 -- $out

    )
  done
}

# @desc: tells from-where a zsh completion is coming from
function from-where {
  print -l -- $^fpath/$_comps[$1](N)
  whence -v $_comps[$1]
  #which $_comps[$1] 2>&1 | head
}
functions -c from-where wherefrom

# @desc: tell which completion a command is using
function whichcomp() {
  for 1; do
      ( print -raC 2 -- $^fpath/${_comps[$1]:?unknown command}(NP-$1-) )
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
# @desc: list locked files
function lslockz()  { sudo lslocks --pids=$$; }
# @desc: list open file descriptors
function lsofz()    { lsof -p $sysparams[ppid] | hck -f1,4,5- ; }
# @desc: ps of zsh
function psz()      { grc --colour=always ps -C zsh -lf | bat ; }
# @desc: list all zsh session PIDs
function pidz()     { pgrep zsh | bat ; }
# function pidz()     { pidof -S $'\n' zsh | bat ; }
# @desc: show parent of current process
function lsparent() { ps -q $sysparams[ppid] -lf ; }
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
function rst()  { rsync_w "$1" root@lmburns.com:"$2" ; }
function rsf()  { rsync_w root@lmburns.com:"$1" "$2" ; }
function rstm() { rsync_w "$1" macbook:/Users/lucasburns/"$2" --rsync-path=/usr/local/bin/rsync ; }
function rsfm() { rsync_w macbook:"$1" "$2" --rsync-path=/usr/local/bin/rsync ; }
# ]]]

# @desc: add current directory to zoxide N times
function zoxide-add() {
  typeset -gH desc; desc='add current directory to zoxide N times'
  integer n; n=${1:-10}
  for 1 ({1..$n}) { zoxide add $PWD }
}

# @desc: directory hash
function sha256dir() { fd . -tf -x sha256sum | hck -d' ' -f1 | sort | sha256sum | hck -d' ' -f1 ; }
function b3sumdir()  { b3sum <<<${(@of):-"$(fd ${1:-.} -tf -x b3sum --no-names)"} ; }
function megahash()  { b3sum <<<${(pj:\0:)${(@s: :)"$(rhash --all $@)"}[2,-1]} ; }
# ]]]

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

# ============== File Format ============== [[[
function pj() { perl -MCpanel::JSON::XS -0777 -E '$ip=decode_json <>;'"$@" ; }
function jqy() { yq e -j "$1" | jq "$2" | yq - e; }

# @desc: HTML to Markdown
function w2md() {
  local isurl=${${${(M)1:#https#:\/\/*}:+1}:-0}
  local output="${2:-${${1:t:r}:-output}.md}"
  # h2m
  # --single-line-break
  # --ignore-emphasis
  # --dash-unordered-list
  # --google-doc
  # --hide-strikethrough
  # --reference-links
  # --body-width=0 \
  # --wrap-list-items
  #
  # --links-after-para
  # --no-automatic-links
  function ___w2md() {
    html2text \
      --unicode-snob \
      --asterisk-emphasis \
      --open-quote="'" \
      --close-quote="'" \
      --mark-code \
      --links-after-para \
      --no-automatic-links \
      --google-list-indent=4 \
      --body-width=100 \
      --no-wrap-links \
      --pad-tables \
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
  # fastmod '\[code\]' '```zsh' "$1"
  # fastmod '\[/code\]' '```' "$1"
  # fastmod '^\s*$\n```' '```' "$1"
  # fastmod '^(\s*\n){2,}' $'\n' "$1"
  # fastmod '\[\*\*' '[' "$1"
  # fastmod '\*\*]' ']' "$1"
  # fastmod '\*\s\*\s\*' "* * *${(l:94::*:):-}" "$1"
  # fastmod '(’|‘)' '`' "$1"

  local -A Opts; zparseopts -F -D -E -A Opts -- a -all l: -lang:
  local all lang="${${Opts[-l]:-$Opts[--lang]}:-zsh}"
  (($+Opts[-a]+$+Opts[--all])) && all="--accept-all"

  fastmod $all '\[code\]' '```'"$lang" "$1"
  fastmod $all '\[/code\]' '```' "$1"
  fastmod $all '^\s*$\n```' '```' "$1"
  fastmod $all '^(\s*\n){2,}' $'\n' "$1"
  fastmod $all '\[\*\*' '[' "$1"
  fastmod $all '\*\*]' ']' "$1"
  fastmod $all '\*\s\*\s\*' "* * *${(l:94::*:):-}" "$1"
  fastmod $all '(’|‘)' '`' "$1"
}
# ]]]

function clean-vimpersisted() {
  local f
  for f (${${(@f)"$(fd -tf -d1)"}}) {
    if [[ ! -e ${f//\%/\/} ]]; then
      print "$f"
    fi
  } | rargs rip {}
}

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

# @desc: use youtube-dl to get audio
function get-mp3() {
  youtube-dl -f bestaudio -x --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s' $@
}

# @desc: copy 4chan thread
function threadc() {
  local t=$1
  threadwatcher add $t $PWD/${t:t}
}

# ================= Image ================= [[[
function jpeg() { jpegoptim -S "${2:-1000}" "$1"; jhead -purejpg "$1" && du -sh "$1"; }
function pngo() { optipng -o"${2:-3}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
function png()  { pngquant --speed "${2:-4}" "$1"; exiftool -all= "$1" && du -sh "$1"; }

# @desc: create png from gif
function create-gif() {
  convert -verbose -coalesce ${1} ${1:r}.png
}
# ]]]
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
# @desc: Link relevant files to a Typescript project
function linkts() {
  local d; d="$XDG_CONFIG_HOME/languages/typescript"
  command ln -Lv $d/typescript.just $PWD/justfile
  command ln -Lv $d/eslintrc.js     $PWD/.eslintrc.js
  command ln -Lv $d/tsconfig.json   $PWD/tsconfig.json
  # command cp -v $HOME/projects/rust/.pre-commit-config.yaml $PWD/.pre-commit-config.yaml
}
# ]]]

# === Clang ============================================================== [[[
# @desc: Link relevant files to a C project
function linkclang() {
  local d; d="$XDG_CONFIG_HOME/languages/c"
  command ln -Lv $d/justfile.clang          $PWD/justfile
  command ln -Lv $d/.clang-format           $PWD/.clang-format
  command ln -Lv $d/.clangd                 $PWD/.clangd
  command ln -Lv $d/.clang-tidy             $PWD/.clang-tidy
}
# ]]]

# === Rust =============================================================== [[[
# @desc: Link relevant files to a Rust project
function linkrust() {
  local d; d="$XDG_CONFIG_HOME/languages/rust"
  command ln -Lv $d/justfile.rust           $PWD/justfile
  command ln -Lv $d/rustfmt.toml            $PWD/rustfmt.toml
  command cp -v  $d/build.rs                $PWD/build.rs
  command cp -v  $d/pre-commit-config.yaml  $PWD/.pre-commit-config.yaml
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

(( ${+commands[paru]} )) && {
  function plist() {
    command paru --color=always -Ql ${(z)@} | lscolors | bat --paging=always
  }
}
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

# Save arrays
# print -r -- ${(qq)m} > $fname
# m=( "${(@Q)${(z)"$(<$fname)"}}" )

# print *(e:'[[ -d $REPLY ]]':)
# print *(e:'reply=(${REPLY}{1,2})':)

# : ${(S)string##(#m)([A-Z]##)}    #=> $MATCH = 'LO'

# zmv -n '(*)' '${(U)1}'      =>   mv -- foo FOO              => zmv -nw '*' '${(U)1}'
# zmv -n '(**/)lone' '$1sol'  =>   mv -- test/lone test/sol   =>  zmv -nw '***/lone' '$1sol'
# zmv '(*)' '${1//(#m)[aeiou]/${(U)MATCH}}'

# ${${${${(@)f_opts##-(h|-height(=|))}//=/}}//(#m)*/--height=${MATCH}}
# ${${${(M@)opts:#-(h|-height(=|))*}##-(h|-height(=|))}//(#m)*/--height=${(q-)MATCH}}

# ━Best Practices━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# typeset -ga prevf
# prevf=( ${(@k)functions} )
# trap "unset -f -- \"\${(k)functions[@]:|prevf}\" &>/dev/null; unset prevf" EXIT
# trap "unset -f -- \"\${(k)functions[@]:|prevf}\" &>/dev/null; unset prevf; return 1" INT

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
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ]]]

# vim: ft=zsh:et:sw=0:ts=2:sts=2
