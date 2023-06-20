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

  # if (( ! $+load_cmd )); then
  if [[ ! $load_cmd ]]
  then
    print::error "lazyload: No load command defined"
    print::error "  $@"
    return 1
  fi

  # check if lazyload was called by placeholder function
  if (( ${cmd_list[(I)${funcstack[2]}]} )); then
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

function mvcd() {
  (( $# > 1 )) && command mv "$@" && builtin cd "$@[-1]"
}

# @desc: create dir and cd into it
function takedir mkcd {
  command mkdir -p $@ && builtin cd ${@[-1]}
}

function takeurl() {
  local data comp
  data=$(mktemp)
  curl -L $1 > $data
  tar xf $data
  comp=$(tar tf $data | head -1)
  command rm $data
  builtin cd $comp
}

# @desc: clone and cd to directory
function takegit() {
  command git clone $1
  builtin cd ${${1%%.git}:t}
}

function take() {
  if [[ $1 =~ ^(https?|ftp).*\.tar\.(gz|bz2|xz)$ ]]; then
    takeurl $1
  elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
    takegit $1
  else
    takedir $1
  fi
}

# @desc: remove broken symbolics
function util::rm-broken-links() {
  local ls; local -a links
  (( $+commands[exa] )) && ls=exa || ls=ls
  # links=( ${(@f)"$(find ${(z)1} -xtype l)"} )
  links=( ${(@f)"$(fd ${(z)1} -tl)"} )
  [[ -z $links ]] && return
  $ls -l --color=always ${links[@]}
  echo -n "Remove? [y/N]: "
  read -q && rm -- ${links[@]}
}

function rm::broken-links()     { util::rm-broken-links '-d 1' }
function rm::broken-links-all() { util::rm-broken-links        }

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

# @desc: dump zsh hash
function dump_map() {
  eval "[[ \${(t)$1} = association ]]" || {
    (( ! $+1 )) && {
      xzmsg -h $funcstack[-1]:$LINENO "{func}$1{%} is not a hash"
    }
    # print::error "$1 is not a hash"
    return 1
  }

  eval "\
    for k ( \"\${(@k)$1}\" ) {
      print -Pr \"%F{2}\$k%f %F{1}%B=>%f%b %F{3}\$$1[\$k]%f\"
    }
  "
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
