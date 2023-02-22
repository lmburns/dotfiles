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

# 'm:{a-z\-}={A-Z\_}' 'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' 'r:|?=** m:{a-z\-}={A-Z\_}'

function _my-cache-policy() { [[ ! -f $1 && -n "$1"(Nm+14) ]]; }
zstyle ':completion:complete:*' cache-policy _my-cache-policy

# function compctl() {
#   print::error "Don't use compctl";
#   print -Pru2 -- "%F{12}%B${(l:COLUMNS::=:):-}%f%b"
#
#   (
#     for k v ( ${functrace:^funcfiletrace} ) {
#       print -Pac "%F{13}${(D)k}%f" "%F{2}${(D)v}%f"
#     } | column -t
#   ) 1>&2
#
#   print -Pru2 -- "%F{12}%B${(l:COLUMNS::=:):-}%f%b"
#
#   # print -Pl -- "%F{13}%B=== Func File Trace ===\n%f%b$funcfiletrace[@]"
#   # print -Pl -- "\n%F{13}%B=== Func Trace ===\n%f%b$functrace[@]"
#   # print -Pl -- "\n%F{13}%B=== Func Stack ===\n%f%b$funcstack[@]"
#   # print -Pl -- "\n%F{13}%B=== Func Source Trace ===\n%f%b$funcsourcetrace[@]"
# }

function defer_completion() {

zstyle ':completion:*' use-compctl false
zstyle '*' single-ignored show # don't insert single value

# + ''                show-completer = debugging
# + ''                accept-exact '*(N)' \
# + ''                use-compctl false \
# + ':correct:*'      insert-unambiguous true \
# + ''                list-dirs-first true \ # Shows directories first in sep group
# + ':messages'       format ' %F{4} -- %f' \
# + ''                list-grouped true \

zstyle+ ':completion:*'   list-separator '→' \
      + ''                completer _complete _match _list _prefix _extensions _expand _ignored _correct _approximate _oldlist \
      + ''                special-dirs false \
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
      + ':descriptions'   format '[%d]' \
      + ':warnings'       format ' %F{1}-- no matches found --%f' \
      + ':corrections'    format '%F{5}!- %d (errors: %e) -!%f' \
      + ':default'        list-prompt '%S%M matches%s' \
      + ':default'        select-prompt '%F{2}%S-- %p -- [%m]%s%f' \
      + ':manuals.*'      insert-sections   true \
      + ':manuals'        separate-sections true \
      + ':jobs'           numbers true \
      + ':sudo:*'         command-path /usr/{local/{sbin,bin},(s|)bin} /sbin /bin \
                                       $CARGO_HOME/bin $ZINIT[BIN_DIR] \
      + ':sudo::'         environ PATH="$PATH" \
      + ':expand:*'       tag-order all-expansions \
      + ':complete:-command-::commands'          ignored-patterns '*\~' \
      + ':-tilde-:*'      group-order named-directories directory-stack path-directories \
      + ':*:-command-:*:*'                       group-order path-directories functions commands builtins \
      + ':*:-subscript-:*'                       tag-order indexes parameters \
      + ':*:-subscript-:*'                       group-order indexes parameters

zstyle+ ':completion:' '' '' \
      + ':complete:*'                  gain-privileges 1 \
      + ':*:(-command-|export):*'      fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-} \
      + ':(^approximate*):*:functions' ignored-patterns '_*' \
      + '*:processes'                  command "ps -u $USER -o pid,user,comm -w -w"
}

# pattern:tag:description
#  - Description adds them to another group
zstyle+ ':completion:*' '' '' \
      + ':feh:*'          file-patterns    '*.{png,jpg,svg}:images:images *(-/):directories:dirs' \
      + ':sxiv:*'         file-patterns    '*.{png,gif,jpg}:images:images *(-/):directories:dirs' \
      + ':*:perl:*'       file-patterns    '*.(#i)pl:perl(-.) *(-/):directories *((^-/)|(^(#i)pl)):globbed-files' '*:all-files'    \
      + ':*:python:*'     file-patterns    '*.(#i)py:python(-.) *(-/):directories' '*:all-files'  \
      + ':*:ruby:*'       file-patterns    '*.(#i)rb:ruby(-.) *(-/):directories'  '*:all-files'   \
      + ':(rm|rip):*'     file-patterns    '*:all-files'                                          \
      + ':jq:*'           file-patterns    '*.{json,jsonc}:json:json *(-/):directories:dirs' \
      + ':git-checkout:*' sort             false                                                  \
      + ':*:zcompile:*'   ignored-patterns '(*~|*.zwc)'                                           \
      + ':*:nvim:*files'  ignored-patterns '*.(avi|mkv|pyc|zwc)'                                  \
      + ':xcompress:*'    file-patterns    '*.{7z,bz2,gz,rar,tar,tbz,tgz,zip,xz,lzma}:compressed:compressed *:all-files:' \
      + ':*:-redirect-,2(>|)>,*:*'  file-patterns '*.(log|txt)' '%p:all_files' \
      + ''                sort true                                                     \
      + ':(cd|rm|rip|diff(|sitter)|delta|git-dsf|dsf|git-(add|rm)|bat|nvim):*'   sort false \
      + ':(rm|rip|kill|diff(|sitter)|delta|git-dsf|dsf|git-(add,rm)|bat|nvim):*' ignore-line other \
      + ':(comm):*' ignore-line other

zstyle+ ':completion:complete:*' '' '' \
      + ':(nvim|cd):*' file-sort access

# zstyle ':completion::approximate*:*' prefix-needed false

## Complete options for cd with '-'
# zstyle ':completion:*' complete-options true

## Shows ls -la when completing files
# zstyle ':completion:*' file-list list=20 insert=10
# zstyle ':completion:*' file-patterns '%p:globbed-files' '*(-/):directories' '*:all-files'

zstyle ':completion:*:*:-command-:*:*' group-order builtins functions commands
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
# zstyle -e ':completion:*'             special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)' # only if prefix is ../

# ADD: completion patterns for others
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

# Numeric ternary operator doesn't allow returning strings
# So, the one that is used is equivalent to a ternary operation
#
# + ''           fzf-flags "--color=hl:$(( $#_ftb_headers == 0 ? 188 : 0xFF ))" \
# + ''           fzf-flags "--color=hl:${${${(M)${#_ftb_headers}:#0}:+#689d6a}:-#458588}" \

zstyle+ ':fzf-tab:*' print-query ctrl-c \
      + ''           accept-line space \
      + ''           prefix '' \
      + ''           switch-group ',' '.' \
      + ''           single-group header color \
      + ''           fzf-pad 4 \
      + ''           fzf-flags "--color=hl:${${${(M)${#_ftb_headers}:#0}:+#689d6a}:-#458588}" \
      + ''           group-colors $FZF_TAB_GROUP_COLORS \
      + ''           fzf-bindings \
                        'enter:accept' \
                        'backward-eof:abort' \
                        'ctrl-e:execute-silent({_FTB_INIT_}nvim "$realpath" < /dev/tty > /dev/tty)'

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
          fzf-preview '[[ -d $realpath ]] && bkt -- exa -TL 4 --color=always -- "$(readlink -f $realpath)"' \
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
    + ':git-(add|dif|restore):*' fzf-preview 'git diff $word | delta' \
    + ':git-log:*'               fzf-preview 'git log --color=always $word' \
    + ':git-help:*'              fzf-preview 'git help $word | bat -plman --color=always'
    # + ':git-show:*'              fzf-preview 'case "$group" in \
    #                                            ("commit tag") git show --color=always $word ;; \
    #                                            (*) git show --color=always $word | delta    ;; \
    #                                           esac' \
    # + ':git-checkout:*'          fzf-preview  'case "$group" in
    #                                             ("modified file") git diff $word | delta                            ;;
    #                                             ("recent commit object name") git show --color=always $word | delta ;;
    #                                             (*) git log --color=always $word                                    ;;
    #                                            esac' \

# zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
#   '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'


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

# === ls-colors === [[[

# zstyle ':completion:*:options:*' list-colors '=(#b)(*)/(*)==1;35=1;33'
# zstyle ':completion:*:options:*'  list-colors '=^(| *)=34'
# zstyle ':completion:*:options:*'   list-colors '=(#b)(--[^ ]|-[^- ]#)(*)=1;38;2;152;103;106;1=0;38;2;254;128;25'
# zstyle ':completion:*:default:*' list-colors '=(#b)(--[^ ]#)(*)=38;5;220;1=0;38;2;254;128;25'
# zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==35=35}:${(s.:.)LS_COLORS}")';

# zstyle ':completion:complete:*' list-colors ${(s.:.)LS_COLORS}

# zstyle+ ':completion'        ''          ''                                                         \
#       + ':complete:*'        list-colors ${(s.:.)LS_COLORS}                                         \
#       + ':*:options:*'       list-colors '=(#b)(--[^ ]#)(*)=1;38;2;152;103;106;1=0;38;2;254;128;25' \
#       + ':*:commands:*'      list-colors '=*=32'                                                    \
#       + ':*:cpan-module'     list-colors '=(#b)(*)=1;30=37;46'                                      \
#       + ':*:remote-pip'      list-colors '=(#b)(*)=1;30=37;46'                                      \
#       + ':*:remote-gem'      list-colors '=(#b)(*)=1;30=37;46'                                      \
#       + ':*:remote-crate'    list-colors '=(#b)(*)=1;30=1;36;44'                                    \
#       + ':*:processes'       list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'                 \
#       + ':*:processes-names' list-colors '=(#b)(*)=1;30=1;37;43'
#
# zstyle+ ':completion:*'                 list-colors 'ma=37;1;4;44'            \
#       + ':builtins'                     list-colors '=(#b)(*)=1;30=1;37;4;43' \
#       + ':executables'                  list-colors '=(#b)(*)=1;30=1;37;44'   \
#       + ':parameters'                   list-colors '=(#b)(*)=1;30=1;32;45'   \
#       + ':abs-directories'              list-colors '=(#b)(*)=1;30=1;32;45'   \
#       + ':reserved-words'               list-colors '=(#b)(*)=1;30=1;4;37;45' \
#       + ':functions'                    list-colors '=(#b)(*)=1;30=1;37;41'   \
#       + ':aliases'                      list-colors '=(#b)(*)=1;30=34;42;4'   \
#       + ':alias'                        list-colors '=(#b)(*)=1;30=34;42;4'   \
#       + ':suffix-aliases'               list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':global-aliases'               list-colors '=(#b)(*)=1;30=1;34;43;4' \
#       + ':users'                        list-colors '=(#b)(*)=1;30=1;37;42'   \
#       + ':hosts'                        list-colors '=(#b)(*)=1;30=1;37;43'   \
#       + ':global-aliases'               list-colors '=(#b)(*)=1;30=1;34;43;4' \
#       + ':corrections'                  list-colors '=(#b)(*)=0;38;2;160;100;105' \
#       + ':original'                     list-colors '=(#b)(*)=0;38;2;76;150;168'   \
#       + ':*:commits'                    list-colors '=(#b)(*)=1;30=34;42;4'   \
#       + ':heads'                        list-colors '=(#b)(*)=1;30=34;42;4'   \
#       + ':commit-tags'                  list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':cached-files'                 list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':files'                        list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':blobs'                        list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':blob-objects'                 list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':trees'                        list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':tags'                         list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':heads-local'                  list-colors '=(#b)(*)=1;30=1;34;43;4' \
#       + ':heads-remote'                 list-colors '=(#b)(*)=1;30=1;37;46'   \
#       + ':modified-files'               list-colors '=(#b)(*)=1;30=1;37;42'   \
#       + ':revisions'                    list-colors '=(#b)(*)=1;30=1;37;42'   \
#       + ':recent-branches'              list-colors '=(#b)(*)=1;30=1;37;44'   \
#       + ':remote-branch-names-noprefix' list-colors '=(#b)(*)=1;30=1;33;46'   \
#       + ':blobs-and-trees-in-treeish'   list-colors '=(#b)(*)=1;30=1;34;43'   \
#       + ':commit-objects'               list-colors '=(#b)(*)=1;30=1;37;43'   \
#       + ':*(git|git-checkout):*:files'  list-colors '=(#b)(*)=1;30=1;32;43'   \
#       + ':prefixes'                     list-colors '=(#b)(*)=1;30=1;37;43'   \
#       + ':manuals.1'                    list-colors '=(#b)(*)=1;30=1;36;44'   \
#       + ':manuals.2'                    list-colors '=(#b)(*)=1;30=1;37;42'   \
#       + ':manuals.3'                    list-colors '=(#b)(*)=1;30=1;37;43'   \
#       + ':manuals.4'                    list-colors '=(#b)(*)=1;30=37;46'     \
#       + ':manuals.5'                    list-colors '=(#b)(*)=1;30=1;34;43;4' \
#       + ':manuals.6'                    list-colors '=(#b)(*)=1;30=1;37;41'   \
#       + ':manuals.7'                    list-colors '=(#b)(*)=1;30=34;42;4'   \
#       + ':manuals.8'                    list-colors '=(#b)(*)=1;30=1;34;41;4' \
#       + ':manuals.9'                    list-colors '=(#b)(*)=1;30=1;36;44'   \
#       + ':manuals.n'                    list-colors '=(#b)(*)=1;30=1;4;37;45' \
#       + ':manuals.0p'                   list-colors '=(#b)(*)=1;30=37;46'     \
#       + ':manuals.1p'                   list-colors '=(#b)(*)=1;30=37;46'     \
#       + ':manuals.3p'                   list-colors '=(#b)(*)=1;30=37;46'     \
#       + ':npm-search'                   list-colors '=(#b)(*)=1;30=1;36;44'   \
#       + ':npm-cache'                    list-colors '=(#b)(*)=1;30=1;37;46'   \
#     +   ':*:*:*:attached-sessions'      list-colors '=(#b)(*)=1;30=1;37;43'   \
#     +   ':*:*:*:detached-sessions'      list-colors '=(#b)(*)=1;30=1;37;45'   \
#     +   ':*:commands'                   list-colors '=(#b)(*)=1;37;45'        \
#     +   ':*:tmux'                       list-colors '=(#b)(*)=1;37;45'        \
#     +   ':*:last-ten'                   list-colors '=(#b)(*)=1;33;45'        \
#     +   ':*:last-line'                  list-colors '=(#b)(*)=1;37;44'        \
#     +   ':*:last-clip'                  list-colors '=(#b)(*)=1;37;45'

# zstyle -e ':completion:*:local-directories' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle -e ':completion:*:*:f:*:*' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle -e ':completion:*:globbed-files' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle -e ':completion:*:argument-rest:*' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle -e ':completion:*:all-files' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle -e ':completion:*:files' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle -e ':completion:*:directories' list-colors '=(#b)(*)=0;38;2;129;156;59'
# zstyle ':completion:*:named-directories' list-colors '=(#b)(*)=1;30=1;37;46'

#zstyle ':completion:*:*:commands' list-colors '=(#b)([a-zA-Z]#)([0-9_.-]#)([a-zA-Z]#)*=0;34=1;37;45=0;34=1;37;45'


# zstyle ':completion:*:*:*:*:options' \
#   list-colors \
#   '=(#b)([-<)(>]##)[ ]#([a-zA-Z0-9_.,:?@#-]##)[ ]#([<)(>]#)[ ]#([a-zA-Z0-9+?.,()@3-]#)*=1;32=1;31=34=1;31=34'


# Highlight typed part of command
# zstyle -e ':completion:*:-command-:*:commands' \
#   list-colors \
#   'reply=( '\''=(#b)('\''$words[CURRENT]'\''|)*-- #(*)=0=38;5;45=38;5;136'\'' '\''=(#b)('\''$words[CURRENT]'\''|)*=0=38;5;45'\'' )'

zstyle ':completion:*:command-descriptions' \
  command '_call_whatis -l -s 1 -r .\*; _call_whatis -l -s 6 -r .\* 2>/dev/null'

# ]]] === ls-colors ===

# ========================================================================

# === testing ground === [[[
# Ignore all completions starting with '_' in command position
zstyle+ ':completion:*' '' '' \
      + ':*:-command-:*:*'      tag-order 'functions:-non-comp *' functions \
      + ':*:functions-non-comp' ignored-patterns '_*'

# FIX: Good, but annoying showing with vim and such
# Separates --long and -s hort flags
# zstyle+ ':completion:*' tag-order \
#                              'options:-long:long\ options
#                              options:-short:short\ options
#                              options:-single-letter:single\ letter\ options' \
#       + ':options-long'          ignored-patterns '[-+](|-|[^-]*)' \
#       + ':options-short'         ignored-patterns '--*' '[-+]?' \
#       + ':options-single-letter' ignored-patterns '???*'

# FIX:
# zstyle ':completion:*:exa:*' tag-order globbed-files options
# zstyle ':completion:*:cd:*' tag-order globbed-files options

# + ':cd:*'           group-order local-directories path-directories \
# + ':cd:*'           tag-order local-directories directory-stack path-directories \

# zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# zstyle+ ':completion:*:complete:cd:*' tag-order \
#                                       'named-directories:-mine:extra\ directories
#                                        named-directories:-normal:named\ directories *' \
#       + ':named-directories-mine' fake-always ~/ghq \
#       + ':named-directories-mine' ignored-patterns '*'

# DOESNT WORK:
zstyle ':completion:*:complete:cdh:*:*' group-order local-directories recent-dirs path-directories
zstyle ':completion:*:complete:cdh:*:*' tag-order local-directories recent-dirs path-directories

zstyle ':completion:*:cd:*' tag-order local-directories path-directories
zstyle ':completion:*:cd:*' group-order local-directories path-directories

# zstyle ':completion:*:match:*' original only
# zstyle ':completion::prefix-1:*' completer _complete
# zstyle ':completion:predict:*' completer _complete
# zstyle ':completion:incremental:*' completer _complete _correct
# zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate
# ]]] === testing ground ===

# ============================== Compdef =============================
# ====================================================================
compdef _aliases       ealias
compdef _functions     efunc
compdef _command_names from-where
compdef _command_names whichcomp
compdef _command_names wim
compdef _functions     fim
compdef _functions     freload
compdef _tmsu_vared    '-value-,tmsu_tag,-default-'

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:
