emulate -L zsh
zmodload -Fa zsh/param/private b:private
setopt extendedglob globstarshort nullglob rcexpandparam \
       no_shortloops warncreateglobal localloops

# Lazy load commands
# args: <func name> ... <init code>
function lazyload() {
  zmodload -F zsh/parameter p:funcstack
  zmodload -F zsh/param/private b:private
  private seperator='--'
  local seperator_index=${@[(ie)$seperator]}
  local -a cmd_list=(${@:1:(($seperator_index - 1))});
  local load_cmd=${@[(($seperator_index + 1))]};

  if [[ ! $load_cmd ]]
  then
    zerr "lazyload: No load command defined"
    zerr "  $@"
    return 1
  fi

  # check if lazyload was called by placeholder function
  if (( ${cmd_list[(I)${funcstack[2]}]} )); then
    # unset "functions[$cmd_list]"
    unfunction $cmd_list
    eval "$load_cmd"
  else
    # create placeholder function for each command
    # ${(qqqq)VAR} will quote VAR value as $'...'
    local cmd
    for cmd ($cmd_list[@]) {
      eval "function $cmd {
        lazyload $cmd_list $seperator ${(qqqq)load_cmd}
        $cmd \"\$@\"
      }"
    }
  fi
}

# @usage: *(o+rand) or *(+rand)
function rand() {
  REPLY=$RANDOM; (( REPLY > 16383 ))
}

function num() {
  (( $# == 0 )) && {
    tr '[:lower:]' '[:upper:]' | numfmt --from iec
  } || numfmt --from iec "${(U)@}"
}

function fnum() {
  (( $# == 0 )) && {
    numfmt --to iec
  } || numfmt --to iec "${@}"
}

function vcurl() {
  local TMPFILE="$(mktemp -t --suffix=.json)"
  trap "command rm -f '$TMPFILE'" EXIT INT TERM HUP
  $EDITOR "$TMPFILE" >/dev/tty
  curl ${(@f)"$(<$TMPFILE)"}
}

function kcurl() {
  local BUFFER="/tmp/curl-body-buffer.json"
  touch "$BUFFER" && $EDITOR "$BUFFER" >/dev/tty
  curl "$@" < "$BUFFER"
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
