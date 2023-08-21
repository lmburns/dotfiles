#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-14                                                   #
#    @module: fs                                                           #
#      @desc: Filesystem functions                                         #
#===========================================================================

# @desc: convert relative symlinks to absolute
function lnr2a() {
  fd -tl -d${1:-1} -x zsh -c 'command ln -vsfn "$(readlink -f "$0")" "$0"'
}

# @desc: convert absolute symlinks to relative
function lna2r() {
  fd -tl -d${1:-1} -x zsh -c 'command ln -vsfnr "$(readlink -f "$0")" .'
}

# @desc: move items to a directory and dc to it
function mvcd() {
  (( $# > 1 )) && command mv "$@" && builtin cd "${@[-1]}"
}

# @desc: create directory and cd into it
function takedir mkcd {
  command mkdir -p "$@" && builtin cd ${@[-1]}
}

# @desc: create temporary directory and cd to it
function cdtemp() {
  local t=$(mktemp -d)
  setopt localtraps
  trap "[[ $PWD != $t && -d $t ]] && command rm -r $t" EXIT
  zmsg "{dir}$t{%}"
  builtin cd -q "$t"
}

# @desc: download a URL as a tar and cd to it
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

# @desc: General take function
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
