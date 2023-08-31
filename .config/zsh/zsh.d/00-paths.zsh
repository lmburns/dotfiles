
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: paths                                                        #
#      @desc: Modify zsh PATH parameter                                    #
#===========================================================================

# === Paths ============================================================== [[[
# @desc: add a path to the beginning of a path array
function path::insert() {
  zmodload -Fa zsh/zutil b:zparseopts
  local -A Opts
  builtin zparseopts -F -D -E -A Opts -- f

  local dir; for dir in "$@"; do
    [[ -L "$dir" ]] && dir=$dir:A
    [[ ! -d "$dir" ]] && return
    if [[ -n "${path[(re)$dir]}" && !($+Opts[-f]+$+Opts[--force]) ]]; then
      return
    fi
    if [[ -d "$dir" && -r "$dir" ]]; then
      path=("$dir" "${path[@]}")
    fi
  done
}
# @desc: add a path to the end of a path array
function path::append() {
  zmodload -Fa zsh/zutil b:zparseopts
  local -A Opts
  builtin zparseopts -F -D -E -A Opts -- f -force

  local dir; for dir in "$@"; do
    [[ -L "$dir" ]] && dir=$dir:A
    [[ ! -d "$dir" ]] && return
    if [[ -n "${path[(re)$dir]}" && !($+Opts[-f]+$+Opts[--force]) ]]; then
      return
    fi
    if [[ -d "$dir" && -r "$dir" ]]; then
      path=("${path[@]}" "$dir")
    fi
  done
}

path::insert $HOME/.local/bin
path::insert /usr/local/sbin

[[ -z ${fpath[(re)/usr/share/zsh/site-functions]} ]] && fpath=( "${fpath[@]}" /usr/share/zsh/site-functions )

typeset -g HELPDIR='/usr/share/zsh/help'
if [[ ! -d $HELPDIR ]]; then
  HELPDIR="/usr/share/zsh/${ZSH_VERSION}/help"
fi

# export CPATH="/usr/include:/usr/local/include:$CPATH"
# export LIBRARY_PATH="/usr/lib:/usr/local/lib:$LIBRARY_PATH"
# export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:$LIBRARY_PATH"

local texlive=$HOME/texlive/2021

typeset -axUT LUA_PATH lua_path ';'
eval "$(luarocks path --bin --lua-version=5.1)"
export LUA_PATH="/usr/share/luajit-2.1/?.lua;/usr/share/luajit-2.1/?/init.lua;${LUA_PATH}"
# export LUA_CPATH='/usr/lib/lua/5.1/?.so;/usr/lib/lua/5.1/loadall.so;./?.so;/home/lucas/.local/share/luarocks/lib/lua/5.1/?.so'

# alias gcc='/usr/lib/colorgcc/bin/gcc'
path=(
  # /usr/lib/ccache/bin(N-/)
  # /usr/lib/colorgcc/bin(N-/)
  $HOME/mybin
  $HOME/mybin/linux(N-/)
  $HOME/mybin/gtk(N-/)
  $HOME/bin(N-/)

  $HOME/.ghg/bin(N-/)
  $PYENV_ROOT/{shims,bin}(N-/)
  $GOENV_ROOT/{shims,bin}(N-/)
  $CARGO_HOME/bin(N-/)
  $XDG_DATA_HOME/gem/bin(N-/)
  $GEM_HOME/bin(N-/)               # prefer arch installed
  $XDG_DATA_HOME/luarocks/bin(N-/)
  $NPM_PACKAGES/bin(N-/)
  $texlive/bin/x86_64-linux(N-/)   # prefer arch installed

  $XDG_DATA_HOME/neovim-nightly/bin(N-/)
  $XDG_DATA_HOME/neovim/bin(N-/)

  /usr/bin                   # add again to be ahead of /bin
  /usr/lib/w3m(N-/)
  # $ZPFX/libexec/w3m(N-/)

  $HOME/.ghcup/bin(N-/)
  $HOME/.cabal/bin(N-/)
  # $(stack path --stack-root)/programs/x86_64-linux/ghc-tinfo6-8.10.7/bin
  # $HOME/.poetry/bin(N-/)
  # $RUSTUP_HOME/toolchains/*/bin(N-/)
  "${path[@]}"
)

path::insert "$XDG_BIN_HOME"
path::insert -f "$ZPFX/bin"
path=( "${path[@]:#}" )   # remove empties (if any)
path=( "${(u)path[@]}" )  # remove duplicates; goenv adds twice?

# cdpath=( $HOME/{projects/github,.config} )
cdpath=( $XDG_CONFIG_HOME )

manpath=(
  $XDG_DATA_HOME/man
  $ZINIT[MAN_DIR](N-/)
  $ZPFX/share/man(N-/)
  $NPM_PACKAGES/share/man(N-/)
  $texlive/texmf-dist/doc/man(N-/)
  $RUST_SYSROOT/share/man(N-/)
  "${manpath[@]}"
)

infopath=(
  $texlive/texmf-dist/doc/info(N-/)
  /usr/share/info
  "${infopath[@]}"
)
