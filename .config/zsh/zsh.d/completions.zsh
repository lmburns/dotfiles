ZINIT+=(
  col-pname   $'\e[1;4m\e[38;5;004m' col-uname   $'\e[1;4m\e[38;5;013m' col-keyword $'\e[14m'
  col-note    $'\e[38;5;007m'        col-error   $'\e[1m\e[38;5;001m'   col-p       $'\e[38;5;81m'
  col-info    $'\e[38;5;82m'         col-info2   $'\e[38;5;011m'      col-profile $'\e[38;5;007m'
  col-uninst  $'\e[38;5;010m'        col-info3   $'\e[1m\e[38;5;011m' col-slight  $'\e[38;5;230m'
  col-failure $'\e[38;5;001m'        col-happy   $'\e[1m\e[38;5;82m'  col-annex   $'\e[38;5;002m'
  col-id-as   $'\e[4;38;5;011m'      col-version $'\e[3;38;5;87m'
  col-pre     $'\e[38;5;135m'        col-msg   $'\e[0m'        col-msg2  $'\e[38;5;009m'
  col-obj     $'\e[38;5;012m'        col-obj2  $'\e[38;5;010m' col-file  $'\e[3;38;5;117m'
  col-dir     $'\e[3;38;5;002m'      col-func $'\e[38;5;219m'
  col-url     $'\e[38;5;75m'         col-meta  $'\e[38;5;57m'  col-meta2 $'\e[38;5;147m'
  col-data    $'\e[38;5;010m'         col-data2 $'\e[38;5;010m' col-hi    $'\e[1m\e[38;5;010m'
  col-var     $'\e[38;5;81m'         col-glob  $'\e[38;5;011m' col-ehi   $'\e[1m\e[38;5;210m'
  col-cmd     $'\e[38;5;002m'         col-ice   $'\e[38;5;39m'  col-nl    $'\n'
  col-txt     $'\e[38;5;010m'        col-num  $'\e[3;38;5;155m' col-term  $'\e[38;5;185m'
  col-warn    $'\e[38;5;009m'        col-apo $'\e[1;38;5;220m' col-ok    $'\e[38;5;220m'
  col-faint   $'\e[38;5;238m'        col-opt   $'\e[38;5;219m' col-lhi   $'\e[38;5;81m'
  col-tab     $' \t '                col-msg3  $'\e[38;5;238m' col-b-lhi $'\e[1m\e[38;5;75m'
  col-bar     $'\e[38;5;82m'         col-th-bar $'\e[38;5;82m'
  col-rst     $'\e[0m'               col-b     $'\e[1m'        col-nb     $'\e[22m'
  col-u       $'\e[4m'               col-it    $'\e[3m'        col-st     $'\e[9m'
  col-nu      $'\e[24m'              col-nit   $'\e[23m'       col-nst    $'\e[29m'
  col-bspc    $'\b'                  col-b-warn $'\e[1;38;5;009m' col-u-warn $'\e[4;38;5;009m'
  col-mdsh    $'\e[1;38;5;220m'"${${${(M)LANG:#*UTF-8*}:+–}:--}"$'\e[0m'
  col-mmdsh   $'\e[1;38;5;220m'"${${${(M)LANG:#*UTF-8*}:+――}:--}"$'\e[0m'
  col-↔       ${${${(M)LANG:#*UTF-8*}:+$'\e[38;5;82m↔\e[0m'}:-$'\e[38;5;82m«-»\e[0m'}
  col-…       "${${${(M)LANG:#*UTF-8*}:+…}:-...}"  col-ndsh  "${${${(M)LANG:#*UTF-8*}:+–}:-}"
  col--…      "${${${(M)LANG:#*UTF-8*}:+⋯⋯}:-···}" col-lr    "${${${(M)LANG:#*UTF-8*}:+↔}:-"«-»"}"
)

# ============================== zstyle ==============================
# ====================================================================

autoload -Uz zstyle+

zstyle+ ':completion:*'                 list-colors 'ma=37;1;4;44'            \
      + ':builtins'                     list-colors '=(#b)(*)=1;30=1;37;4;43' \
      + ':executables'                  list-colors '=(#b)(*)=1;30=1;37;44'   \
      + ':parameters'                   list-colors '=(#b)(*)=1;30=1;32;45'   \
      + ':abs-directories'              list-colors '=(#b)(*)=1;30=1;32;45'   \
      + ':reserved-words'               list-colors '=(#b)(*)=1;30=1;4;37;45' \
      + ':functions'                    list-colors '=(#b)(*)=1;30=1;37;41'   \
      + ':aliases'                      list-colors '=(#b)(*)=1;30=34;42;4'   \
      + ':alias'                        list-colors '=(#b)(*)=1;30=34;42;4'   \
      + ':suffix-aliases'               list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':global-aliases'               list-colors '=(#b)(*)=1;30=1;34;43;4' \
      + ':users'                        list-colors '=(#b)(*)=1;30=1;37;42'   \
      + ':hosts'                        list-colors '=(#b)(*)=1;30=1;37;43'   \
      + ':global-aliases'               list-colors '=(#b)(*)=1;30=1;34;43;4' \
      + ':corrections'                  list-colors '=(#b)(*)=0;38;2;160;100;105' \
      + ':original'                     list-colors '=(#b)(*)=0;38;2;76;150;168'   \
      + ':*:commits'                    list-colors '=(#b)(*)=1;30=34;42;4'   \
      + ':heads'                        list-colors '=(#b)(*)=1;30=34;42;4'   \
      + ':commit-tags'                  list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':cached-files'                 list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':files'                        list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':blobs'                        list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':blob-objects'                 list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':trees'                        list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':tags'                         list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':heads-local'                  list-colors '=(#b)(*)=1;30=1;34;43;4' \
      + ':heads-remote'                 list-colors '=(#b)(*)=1;30=1;37;46'   \
      + ':modified-files'               list-colors '=(#b)(*)=1;30=1;37;42'   \
      + ':revisions'                    list-colors '=(#b)(*)=1;30=1;37;42'   \
      + ':recent-branches'              list-colors '=(#b)(*)=1;30=1;37;44'   \
      + ':remote-branch-names-noprefix' list-colors '=(#b)(*)=1;30=1;33;46'   \
      + ':blobs-and-trees-in-treeish'   list-colors '=(#b)(*)=1;30=1;34;43'   \
      + ':commit-objects'               list-colors '=(#b)(*)=1;30=1;37;43'   \
      + ':*(git|git-checkout):*:files'  list-colors '=(#b)(*)=1;30=1;32;43'   \
      + ':prefixes'                     list-colors '=(#b)(*)=1;30=1;37;43'   \
      + ':manuals.1'                    list-colors '=(#b)(*)=1;30=1;36;44'   \
      + ':manuals.2'                    list-colors '=(#b)(*)=1;30=1;37;42'   \
      + ':manuals.3'                    list-colors '=(#b)(*)=1;30=1;37;43'   \
      + ':manuals.4'                    list-colors '=(#b)(*)=1;30=37;46'     \
      + ':manuals.5'                    list-colors '=(#b)(*)=1;30=1;34;43;4' \
      + ':manuals.6'                    list-colors '=(#b)(*)=1;30=1;37;41'   \
      + ':manuals.7'                    list-colors '=(#b)(*)=1;30=34;42;4'   \
      + ':manuals.8'                    list-colors '=(#b)(*)=1;30=1;34;41;4' \
      + ':manuals.9'                    list-colors '=(#b)(*)=1;30=1;36;44'   \
      + ':manuals.n'                    list-colors '=(#b)(*)=1;30=1;4;37;45' \
      + ':manuals.0p'                   list-colors '=(#b)(*)=1;30=37;46'     \
      + ':manuals.1p'                   list-colors '=(#b)(*)=1;30=37;46'     \
      + ':manuals.3p'                   list-colors '=(#b)(*)=1;30=37;46'     \
      + ':npm-search'                   list-colors '=(#b)(*)=1;30=1;36;44'   \
      + ':npm-cache'                    list-colors '=(#b)(*)=1;30=1;37;46'   \
    +   ':*:*:*:attached-sessions'      list-colors '=(#b)(*)=1;30=1;37;43'   \
    +   ':*:*:*:detached-sessions'      list-colors '=(#b)(*)=1;30=1;37;45'   \
    +   ':*:commands'                   list-colors '=(#b)(*)=1;37;45'        \
    +   ':*:tmux'                       list-colors '=(#b)(*)=1;37;45'        \
    +   ':*:last-ten'                   list-colors '=(#b)(*)=1;33;45'        \
    +   ':*:last-line'                  list-colors '=(#b)(*)=1;37;44'        \
    +   ':*:last-clip'                  list-colors '=(#b)(*)=1;37;45'

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


# ========================== MATCHER ==========================
# zstyle ':completion:*:match:*' original only
# zstyle ':completion::prefix-1:*' completer _complete
# zstyle ':completion:predict:*' completer _complete
# zstyle ':completion:incremental:*' completer _complete _correct
# zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:fdm=marker:fmr={{{,}}}:
