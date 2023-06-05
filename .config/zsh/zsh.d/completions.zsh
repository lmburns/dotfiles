#===========================================================================
#    Author: Lucas Burns
#     Email: burnsac@me.com
#   Created: 2022-02-18 13:43
#===========================================================================

# TODO: Select first group on startup with fzf-tab

# ============================== zinit ===============================
# ====================================================================
autoload -Uz zstyle+

ZINIT+=(
  col-pname   $'\e[1;4m\e[38;5;004m'               col-uname   $'\e[1;4m\e[38;5;013m' col-keyword $'\e[14m'
  col-note    $'\e[38;5;007m'                      col-error   $'\e[1m\e[38;5;001m'   col-p       $'\e[38;5;81m'
  col-info    $'\e[38;5;82m'                       col-info2   $'\e[38;5;011m'        col-profile $'\e[38;5;007m'
  col-uninst  $'\e[38;5;010m'                      col-info3   $'\e[1m\e[38;5;011m'   col-slight  $'\e[38;5;230m'
  col-failure $'\e[38;5;001m'                      col-happy   $'\e[1m\e[38;5;82m'    col-annex   $'\e[38;5;002m'
  col-id-as   $'\e[4;38;5;011m'                    col-version $'\e[3;38;5;87m'
  col-pre     $'\e[38;5;135m'                      col-msg     $'\e[0m'               col-msg2    $'\e[38;5;009m'
  col-obj     $'\e[38;5;012m'                      col-obj2    $'\e[38;5;010m'        col-file    $'\e[3;38;5;117m'
  col-dir     $'\e[3;38;5;002m'                    col-func    $'\e[38;5;219m'
  col-url     $'\e[38;5;75m'                       col-meta    $'\e[38;5;57m'         col-meta2   $'\e[38;5;147m'
  col-data    $'\e[38;5;010m'                      col-data2   $'\e[38;5;010m'        col-hi      $'\e[1m\e[38;5;010m'
  col-var     $'\e[38;5;81m'                       col-glob    $'\e[38;5;011m'        col-ehi     $'\e[1m\e[38;5;210m'
  col-cmd     $'\e[38;5;002m'                      col-ice     $'\e[38;5;39m'         col-nl      $'\n'
  col-txt     $'\e[38;5;010m'                      col-num     $'\e[3;38;5;155m'      col-term    $'\e[38;5;185m'
  col-warn    $'\e[38;5;009m'                      col-apo     $'\e[1;38;5;220m'      col-ok      $'\e[38;5;220m'
  col-faint   $'\e[38;5;238m'                      col-opt     $'\e[38;5;219m'        col-lhi     $'\e[38;5;81m'
  col-tab     $' \t '                              col-msg3    $'\e[38;5;238m'        col-b-lhi   $'\e[1m\e[38;5;75m'
  col-bar     $'\e[38;5;82m'                       col-th-bar  $'\e[38;5;82m'
  col-rst     $'\e[0m'                             col-b       $'\e[1m'               col-nb      $'\e[22m'
  col-u       $'\e[4m'                             col-it      $'\e[3m'               col-st      $'\e[9m'
  col-nu      $'\e[24m'                            col-nit     $'\e[23m'              col-nst     $'\e[29m'
  col-bspc    $'\b'                                col-b-warn  $'\e[1;38;5;009m'      col-u-warn  $'\e[4;38;5;009m'
  col-mdsh    $'\e[1;38;5;220m'"${${${(M)LANG:#*UTF-8*}:+–}:--}"$'\e[0m'
  col-mmdsh   $'\e[1;38;5;220m'"${${${(M)LANG:#*UTF-8*}:+――}:--}"$'\e[0m'
  col-↔       ${${${(M)LANG:#*UTF-8*}:+$'\e[38;5;82m↔\e[0m'}:-$'\e[38;5;82m«-»\e[0m'}
  col-…       "${${${(M)LANG:#*UTF-8*}:+…}:-...}"  col-ndsh    "${${${(M)LANG:#*UTF-8*}:+–}:-}"
  col--…      "${${${(M)LANG:#*UTF-8*}:+⋯⋯}:-···}" col-lr      "${${${(M)LANG:#*UTF-8*}:+↔}:-"«-»"}"
)

# ============================== zstyle ==============================
# ====================================================================

# === completion === [[[

# ========================================================================

# === established === [[[

function _my-cache-policy() { [[ ! -f "$1" && -n "$1"(Nm+14) ]]; }

function compctl() {
  print::error "Don't use compctl";
  print -Pru2 -- "%F{12}%B${(l:COLUMNS::=:):-}%f%b"

  (
    for k v ( ${functrace:^funcfiletrace} ) {
      print -Pac "%F{13}${(D)k}%f" "%F{2}${(D)v}%f"
    } | column -t
  ) 1>&2

  print -Pru2 -- "%F{12}%B${(l:COLUMNS::=:):-}%f%b"
  log::dump
  print -Pru2 -- "%F{12}%B${(l:COLUMNS::=:):-}%f%b"

  # print -Pl -- "%F{13}%B=== Func File Trace ===\n%f%b$funcfiletrace[@]"
  # print -Pl -- "\n%F{13}%B=== Func Trace ===\n%f%b$functrace[@]"
  # print -Pl -- "\n%F{13}%B=== Func Stack ===\n%f%b$funcstack[@]"
  # print -Pl -- "\n%F{13}%B=== Func Source Trace ===\n%f%b$funcsourcetrace[@]"
}

function _force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1
}

function defer_completion() {

zstyle ':completion:complete:*' cache-policy _my-cache-policy
zstyle ':completion:*' use-compctl false
zstyle '*' single-ignored show # don't insert single value

# + ''                show-completer = debugging
# + ''                accept-exact '*(N)' \
# + ''                use-compctl false \
# + ':correct:*'      insert-unambiguous true \
# + ''                list-dirs-first true \ # Shows directories first in sep group
# + ':messages'       format ' %F{4} -- %f' \
# + ''                list-grouped true \
# + ''                special-dirs false \

# 'm:{a-z\-}={A-Z\_}' 'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' 'r:|?=** m:{a-z\-}={A-Z\_}'

zstyle+ ':completion:*'   list-separator '→' \
      + ''                completer _oldlist _extensions _complete _match _force_rehash _expand _prefix _ignored _approximate _correct \
      + ''                file-sort access \
      + ''                use-cache true \
      + ''                cache-path "${ZSH_CACHE_DIR}/.zcompcache" \
      + ''                verbose true \
      + ''                extra-verbose true \
      + ''                rehash true \
      + ''                squeeze-slashes true \
      + ''                ignore-parents parent pwd \
      + ''                matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-,]=* r:|=*' 'l:|=* r:|=*' 'r:|?=** m:{a-z\-}={A-Z\_}' \
      + ''                muttrc "$XDG_CONFIG_HOME/mutt/muttrc" \
      + ':(^systemctl):*' group-name '' \
      + ''                list-colors ${(s.:.)LS_COLORS} \
      + ':default'        list-colors ${(s.:.)LS_COLORS} \
      + ':matches'        group true \
      + ':functions'      ignored-patterns '(pre(cmd|exec))' \
      + ':approximate:*'  max-errors 1 numeric \
      + ':match:*'        original only \
      + ':options'        description true \
      + ':options'        auto-description '%d' \
      + ':descriptions'   format '[%d]' \
      + ':warnings'       format ' %F{1}-- no matches found --%f' \
      + ':corrections'    format '%F{5}!- %d (errors: %e) -!%f' \
      + ':expansions'     format '%F{22}>> %d for %B%o%b <<%f' \
      + ':default'        list-prompt '%S%M matches%s' \
      + ':default'        select-prompt '%F{2}%S-- %p -- [%m]%s%f' \
      + ':manuals.(^1*)'  insert-sections   true \
      + ':manuals'        separate-sections true \
      + ':jobs'           numbers true \
      + ':sudo:*'         command-path /usr/{local/{sbin,bin},(s|)bin}(N-/) \
                                       /sbin \
                                       /bin \
                                       $CARGO_HOME/bin(N-/) \
                                       $ZINIT[BIN_DIR](N-/) \
      + ':sudo::'         environ PATH="$PATH"

zstyle+ ':completion:*' '' '' \
      + ':complete:*'                  gain-privileges 1 \
      + ':*:(-command-|export):*'      fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-} \
      + '*:processes'                  command "ps -u $USER -o pid,user,comm -w -w" \
      + ':expand:*'       tag-order all-expansions \
      + ':complete:-command-::commands'          ignored-patterns '*\~' \
      + ':-tilde-:*'      group-order named-directories directory-stack path-directories \
      + ':*:-command-:*:*'  group-order path-directories functions commands builtins \
      + ':*:-subscript-:*'  tag-order   indexes parameters \
      + ':*:-subscript-:*'  group-order indexes parameters

# For sudo kill, show all processes except childs of kthreadd (ie, kernel
# threads), which is assumed to be PID 2. otherwise, show user processes only.
zstyle -e ':completion:*:*:kill:*:processes' \
  command '[[ $BUFFER == sudo* ]] \
             && reply=( "ps --forest -p 2 --ppid 2 --deselect -o pid,user,cmd" ) \
             || reply=( "ps x --forest -o pid,cmd" )'
# zstyle ':completion:*:processes-names' command 'ps axho command'

# Ignore all completions starting with '_' in command position
zstyle+ ':completion:*' '' '' \
      + ':*:-command-:*:*'      tag-order 'functions:-non-comp *' functions \
      + ':(^approximate*):*:functions' ignored-patterns '_*'
      # + ':*:functions-non-comp' ignored-patterns '_*' \

## Complete options for cd with '-'
zstyle ':completion:*' complete-options true
# zstyle ':completion::approximate*:*' prefix-needed false
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
# only if prefix is ../
zstyle -e ':completion:*'  special-dirs '[[ $PREFIX = (../)#(.|..) ]] && reply=(..)'
}

# pattern:tag:description
#  - Description adds them to another group
zstyle+ ':completion:*' '' '' \
      + ':feh:*'                   file-patterns    '*.{png,jpg,svg}:images:images *(-/):directories:dirs'                               \
      + ':sxiv:*'                  file-patterns    '*.{png,gif,jpg}:images:images *(-/):directories:dirs'                               \
      + ':*:perl:*'                file-patterns    '*.(#i)pl:perl(-.) *(-/):directories *((^-/)|(^(#i)pl)):globbed-files' '*:all-files' \
      + ':*:python:*'              file-patterns    '*.(#i)py:python(-.) *(-/):directories' '*:all-files'                                \
      + ':*:ruby:*'                file-patterns    '*.(#i)rb:ruby(-.) *(-/):directories'  '*:all-files'                                 \
      + ':(rm|rip):*'              file-patterns    '*:all-files'                                                                        \
      + ':jq:*'                    file-patterns    '*.{json,jsonc}:json:json *(-/):directories:dirs'                                    \
      + ':xcompress:*'             file-patterns    '*.{7z,bz2,gz,rar,tar,tbz,tgz,zip,xz,lzma}:compressed:compressed *:all-files:'       \
      + ':*:-redirect-,2(>|)>,*:*' file-patterns    '*.(log|txt)' '%p:all_files'                                                         \
      + ':*:z(re|)compile:*'       ignored-patterns '(*~|*.zwc)'                                                                         \
      + ':*:nvim:*files'           ignored-patterns '*.(avi|mkv|pyc|zwc|mp4|webm|png)'                                                   \
      + ':git-checkout:*' sort             false                                                  \
      + ''                sort true                                                     \
      + ':(cd|rm|rip|diff(|sitter)|delta|git-dsf|dsf|difft|git-(add|rm)|bat|nvim):*'   sort false \
      + ':(rm|rip|kill|diff(|sitter)|delta|git-dsf|dsf|difft|git-(add,rm)|bat|nvim):*' ignore-line other \
      + ':(zcompile|zrecompile|comm):*' ignore-line other

zstyle+ ':completion:complete:*' '' '' \
      + ':(nvim|cd):*' file-sort access

## Shows ls -la when completing files
# zstyle ':completion:*' file-list list=20 insert=10
# zstyle ':completion:*' file-patterns '%p:globbed-files' '*(-/):directories' '*:all-files'
# zstyle ':completion:*:*:ogg123:*'  file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
# zstyle ':completion:*:*:mocp:*'    file-patterns '*.(wav|df):ogg\ files *(-/):directories'

# ]]] === established ===

defer -c defer_completion

# ========================================================================

# === zui === [[[
zstyle+  ':plugin:zui' \
           colorpair        white/default \
      + '' border           yes                 \
      + '' border_cp        14/default          \
      + '' bold             no                  \
      + '' status_colorpair white/default       \
      + '' status_border    yes                 \
      + '' status_border_cp 4/default           \
      + '' status_bold      no                  \
      + '' mark             blue bold lineund \
      + '' mark2            yellow bold \
      + '' status_size      4 \
      + '' status_pointer   yes \
      + '' top_anchors      yes

zstyle+ ':plugin:zui' log_append above \
      + ''            log_time_format "[%H:%M] " \
      + ''            log_index yes \
      + ''            log_size 32 \
      + ''            log_colors "white cyan yellow green cyan red magenta yellow blue"
# ]]] === zui ===

# ========================================================================

# === fzf-tab === [[[
### `$desc`
# This is the string fzf shows to you.
# Example: `--accessed     use the accessed timestamp field`, `README.md`

### `$word`
# This is the real string to be insert into your commandline.
# For example, if the `$desc` is `--accessed     use the accessed timestamp field`, the `$word` is `--accessed`.

### `$group`
# This is the description of the group which the `$word` belongs to.
# For example, `--accessed` belongs to group named `[option]`, and `README.md` belongs to `[filename]`.
# `README.md` belongs to `[filename]` to completing `exa`, but belongs to `[files]` when completing `ls`.
# NOTE: To use this variable, please make sure you have set `zstyle ':completion:*:descriptions' format '[%d]'`.

### `$realpath`
# If you are completing a path and want to access this path when previewing, then you should use `$realpath`.
# For example, if you are completing directories in `/usr/`, `$word` will be something like `bin`, `lib`,
# but `$realpath` will be `/usr/bin`, `/usr/lib`.

### `$words`
# Any array of your current input.

typeset -ga FZF_TAB_GROUP_COLORS=(
    $'\e[38;5;1m'  $'\e[38;5;17m' $'\e[38;5;3m'   $'\e[38;5;4m'  \
    $'\e[38;5;5m'  $'\e[38;5;6m'  $'\e[38;5;16m'  $'\e[38;5;19m' \
    $'\e[38;5;2m'  $'\e[38;5;21m' $'\e[38;5;22m'  $'\e[38;5;12m' \
    $'\e[38;5;13m' $'\e[38;5;14m' $'\e[38;5;129m' $'\e[38;5;16m'
  )

# zstyle ':fzf-tab:complete:cdr:*' fzf-preview 'exa -TL 3 --color=always ${${~${${(@s: → :)desc}[2]}}}'
# zstyle ':fzf-tab:complete:<command in denylist>:*' disabled-on any
# + ':zoxide-command-query:argument-rest:*'               query-string input

# Numeric ternary operator doesn't allow returning strings
# So, the one that is used is equivalent to a ternary operation
#
# + ''           fzf-flags "--color=hl:$(( $#_ftb_headers == 0 ? 188 : 0xFF ))" \
# + ''           fzf-flags "--color=hl:${${${(M)${#_ftb_headers}:#0}:+#689d6a}:-#458588}" \

zstyle+ ':fzf-tab:*' print-query ctrl-c \
      + ''           accept-line space \
      + ''           prefix '' \
      + ''           switch-group 'alt-,' 'alt-.' \
      + ''           show-group full \
      + ''           single-group header color \
      + ''           fzf-pad 4 \
      + ''           fzf-flags "--color=hl:${${${(M)${#_ftb_headers}:#0}:+#689d6a}:-#458588}" \
      + ''           group-colors $FZF_TAB_GROUP_COLORS \
      + ''           fzf-bindings \
                        'enter:accept' \
                        'backward-eof:abort' \
                        'alt-e:become({_FTB_INIT_}$EDITOR "$realpath" < /dev/tty > /dev/tty)' \
                        'alt-b:become(bat --paging=always -f {+})' \
                        'ctrl-y:execute(xsel -b --trim <<<{+})'
# 'alt-e:execute-silent({_FTB_INIT_}$EDITOR "$realpath" < /dev/tty > /dev/tty)' \

zstyle+ \
  ':fzf-tab:complete' '' '' \
    + ':nvim:argument-rest' \
          fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':nvim:argument-rest' \
          fzf-bindings 'alt-e:execute-silent({_FTB_INIT_}nvim "$realpath" < /dev/tty > /dev/tty)' \
    + ':nvim:*' \
          fzf-preview 'r=$realpath; w=$(( COLUMNS * 0.60 )); integer w; \
                      ([[ -f $r ]] && bat --style=numbers --terminal-width=$w --color=always $r) \
                        || ([[ -d $r ]] && tree -C $r | less) || (echo $r 2> /dev/null | head -200)' \
    + ':systemctl-*:*' \
          fzf-preview 'local user; \
                       [[ $words == *--user* || $words == ^se ]] && user="--user"; \
                       SYSTEMD_COLORS=1 systemctl $user status $word' \
    + ':systemctl-*:*'           fzf-flags '--preview-window=nohidden,right:65%:nowrap' \
    + ':figlet:option-f-1'       fzf-preview 'figlet -f $word Hello world' \
    + ':figlet:option-f-1'       fzf-flags '--preview-window=nohidden,right:65%:nowrap' \
    + ':run-help:*'              fzf-preview 'autoload +X -Uz run-help; eval "() { $functions[run-help] } $word"' \
    + ':run-help:*'              fzf-flags '--preview-window=nohidden,right:65%:nowrap' \
    + ':man:*'                   fzf-preview 'man $word | bat --color=always -l man' \
    + ':man:(^options)'          fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':ssh:*'                   fzf-preview 'dig $desc' \
    + ':ssh:*'                   fzf-flags '--preview-window=nohidden,right:65%:nowrap' \
    + ':jq:argument-rest'           fzf-preview 'jq --color-output . "$desc"' \
    + ':jq:argument-rest'           fzf-flags '--preview-window=nohidden,right:65%:nowrap' \
    + ':kill:*'                  popup-pad 0 3 \
    + ':(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap' \
    + ':(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w' \
    + ':cdr:*'                   fzf-preview 'exa -TL 3 --color=always ${~desc}' \
    + ':(exa|cd):*'              popup-pad 30 0 \
    + ':((cd|cdr|cd_):*|exa:argument-*)' fzf-flags '--preview-window=nohidden,right:45%:nowrap' \
    + ':exa:argument-*' \
          fzf-preview 'r=$(readlink -f $realpath); \
                      ([[ -d $r ]] && bkt -- exa -TL 4 --color=always -- $r) \
                        || ([[ -f $r ]] && stdbuf -oL grc --colour=on stat $r)' \
    + ':(cd|cd_):*' \
          fzf-preview 'zmodload -Fa zsh/parameter p:nameddirs; \
                       nameddirs=( '"${(kv)nameddirs}"' ); local named=${(e)~${${(@s: → :)desc}[2]}}; \
                       ([[ -d $named ]] && bkt -- exa -TL 4 --color=always -- "$named") \
                         || ([[ -d $realpath ]] && bkt -- exa -TL 4 --color=always -- "$(readlink -f $realpath)")' \
    + ':((cp|rm|rip|mv|bat):argument-rest|diff:argument-(1|2)|diffsitter:)' \
          fzf-preview 'r=$(readlink -f $realpath); w=$(( COLUMNS * 0.60 )); integer w; \
                      ([[ -f $r ]] && bat --color=always --terminal-width=$w -- $r) \
                        || ([[ -d $r ]] && bkt -- ls --color=always -- $r)' \
    + ':((cp|rm|rip|mv|bat):argument-rest|diff:argument-(1|2)|diffsitter:)' \
          fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}' \
    + ':tldr:argument-1'         fzf-preview 'tldr --color always $word' \
    + ':diff:*'                   popup-min-size 80 12 \
    + ':git-(add|diff|restore):*' popup-min-size 80 12 \
    + ':git-(add|diff|restore):*' fzf-preview 'git diff $word | delta' \
    + ':git-(add|diff|restore|show|checkout):*' fzf-flags '--preview-window=nohidden,right:65%:nowrap' \
    + ':git-log:*'               fzf-preview 'git log --color=always $word' \
    + ':git-help:*'              fzf-preview 'git help $word | bat -plman --color=always' \
    + ':git-show:*'              fzf-preview 'case "$group" in \
                                               ("commit tag") git show --color=always $word ;;
                                               (*) git show --color=always $word | delta    ;;
                                              esac' \
    + ':git-checkout:*'          fzf-preview  'case "$group" in
                                                ("modified file") git diff $word | delta ;;
                                                ("recent commit object name") git show --color=always $word | delta ;;
                                                (*) git log --color=always -p --stat --ignore-all-space $word ;;
                                               esac'

  zstyle ':fzf-tab:user-expand:*' fzf-preview 'less ${(Q)word}'

# + ':updatelocal:argument-rest' \
#       fzf-flags '--preview-window=down:5:wrap' \
# + ':updatelocal:argument-rest' \
#       fzf-preview "git --git-dir=$UPDATELOCAL_GITDIR/\${word}/.git log --color \
#                   --date=short --pretty=format:'%Cgreen%cd %h %Creset%s %Cred%d%Creset ||%b' ..FETCH_HEAD 2>/dev/null" \
# ]]] === fzf-tab ===

# ========================================================================

# === hosts === [[[
zstyle ':completion:*:(scp|rsync):*'      group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*'              group-order users hosts-domain hosts-host users hosts-ipaddr

zstyle+ ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *' \
      + ':hosts-host' \
            ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost \
      + ':hosts-domain' \
            ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*' \
      + ':hosts-ipaddr' \
            ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

zstyle -e ':completion:*:hosts' hosts 'reply=(
      ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
      ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
      ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
    )'


# zstyle -e ':completion:*:(ssh|scp|sftp|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

local -a _ssh_hosts _etc_hosts hosts
[[ -r $HOME/.ssh/known_hosts ]] && \
    _ssh_hosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*} ) || \
    _ssh_hosts=()

[[ -r /etc/hosts ]] && \
    : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || \
    _etc_hosts=()

hosts=( $(hostname) $_ssh_hosts[@] $_etc_hosts[@] localhost )
zstyle ':completion:*:hosts' hosts ${(u)hosts}
# ]]] === hosts ===
# ]]] === completion ===

# ========================================================================

# === command specific === [[[
# TODO: Find a way to get descriptions for aliases
zstyle ':completion:*:command-descriptions' \
  command '_call_whatis -l -s 1 -r .\*; _call_whatis -l -s 6 -r .\* 2>/dev/null'

# Highlight typed part of command (non-fzf-tab)
zstyle -e ':completion:*:-command-:*:commands' \
  list-colors \
  'reply=( '\''=(#b)('\''$words[CURRENT]'\''|)*-- #(*)=0=38;5;45=38;5;136'\'' '\''=(#b)('\''$words[CURRENT]'\''|)*=0=38;5;45'\'' )'

# zstyle ":completion:*:colors" path '/etc/X11/rgb.txt'
# ]]]

# ========================================================================

# === testing ground === [[[
# # for backward-kill, all but / are word chars (ie, delete word up to last directory)
# zstyle ':zle:backward-kill-word*' word-style standard
# zstyle ':zle:*kill*' word-chars '*?_-.[]~=&;!#$%^(){}<>'

# FIX: Good, but annoying showing with vim and such
# Separates --long and -s hort flags
# zstyle+ ':completion:*' tag-order \
#                              'options:-long:long\ options
#                              options:-short:short\ options
#                              options:-single-letter:single\ letter\ options' \
#       + ':options-long'          ignored-patterns '[-+](|-|[^-]*)' \
#       + ':options-short'         ignored-patterns '--*' '[-+]?' \
#       + ':options-single-letter' ignored-patterns '???*'

# + ':cd:*'           group-order local-directories path-directories \
# + ':cd:*'           tag-order local-directories directory-stack path-directories \

# zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# zstyle+ ':completion:*:complete:cd:*' tag-order \
#                                       'named-directories:-mine:extra\ directories
#                                        named-directories:-normal:named\ directories *' \
#       + ':named-directories-mine' fake-always ~/ghq \
#       + ':named-directories-mine' ignored-patterns '*'

# zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# zstyle ':completion:*:cd:*' group-order local-directories directory-stack path-directories
# zstyle ':completion:*:*:cd:*:directory-stack' menu true=long select

# ]]] === testing ground ===

# ============================== Compdef =============================
# ====================================================================
# zicompdef _gnu_generic
# compdef _which         ww
# compdef _gnu_generic   rofi

# compdef _gnu_generic cmd
# print -r -- ${(F)${(@qqq)_args_cache_cmd}} > _cmd

# compdef '_files -g "*.log"' '-redirect-,2>,-default-'
# zstyle ':completion:*:*:-redirect-,2>,*:*' file-patterns '*.log'


function set_hub_commands() {
  # zstyle ':completion:*:*:git:*' user-commands ${${(M)${(k)commands}:#git-*}/git-/}
  zstyle -g existing_user_commands ':completion:*:*:git:*' user-commands
  zstyle ':completion:*:*:hub:*' user-commands $existing_user_commands
  unset -f set_hub_commands
}
defer -t 3 -c set_hub_commands

compdef '_files -g "*.html"' w2md
compdef _tmsu_vared    '-value-,tmsu_tag,-default-'
compdef _hub           g
compdef _git           h
compdef _aliases       ealias
compdef _functions     efunc whichfunc
compdef _command_names from-where whichcomp wim
compdef _functions     fim freload
compdef _man           man-search
compdef _gnu_generic \
  bandwhich dunst ffprobe histdb notify-send pamixer tlmgr zstd \
  brotli

autoload -U +X bashcompinit && bashcompinit

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:
