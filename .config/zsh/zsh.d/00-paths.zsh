#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: paths                                                        #
#      @desc: Modify zsh PATH parameter                                    #
#===========================================================================

# === Paths ============================================================== [[[
[[ -z ${path[(re)$HOME/.local/bin]} ]] && path=( "$HOME/.local/bin" "${path[@]}" )
[[ -z ${path[(re)/usr/local/sbin]} ]]  && path=( "/usr/local/sbin"  "${path[@]}" )
[[ -z ${fpath[(re)/usr/share/zsh/site-functions]} ]] && fpath=( "${fpath[@]}" /usr/share/zsh/site-functions )

typeset -g HELPDIR='/usr/share/zsh/help'
if [[ ! -d $HELPDIR ]]; then
  HELPDIR="/usr/share/zsh/${ZSH_VERSION}/help"
fi

local texlive=$HOME/texlive/2021

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

eval "$(luarocks path --bin --lua-version=5.1)"
# LUA_PATH="/usr/share/luajit-2.1.0-beta3/?.lua:/usr/share/luajit-2.1.0-beta3/?/init.lua${LUA_PATH}"

path=(
  # /usr/lib/ccache/bin
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

  $XDG_DATA_HOME/neovim/bin(N-/)
  $XDG_DATA_HOME/neovim-nightly/bin(N-/)

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

[[ -z ${path[(re)$XDG_BIN_HOME]} && -d "$XDG_BIN_HOME" ]] && path=( "$XDG_BIN_HOME" "${path[@]}")

path=( "${ZPFX}/bin" "${path[@]}" )                # add back to be beginning
path=( "${path[@]:#}" )                            # remove empties (if any)
path=( "${(u)path[@]}" )                           # remove duplicates; goenv adds twice?

# export CPATH="/usr/include:/usr/local/include:$CPATH"
# export LIBRARY_PATH="/usr/lib:/usr/local/lib:$LIBRARY_PATH"
# export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:$LIBRARY_PATH"

# @desc: Add a path to the beginning of a path
function _prepath() {
  local dir; for dir in "$@"; do
    [[ -L "$dir" ]] && dir=$dir:A
    [[ ! -d "$dir" ]] && return
    if [[ -d "$dir" && -r "$dir" ]]; then
      path=("$dir" "${path[@]}")
    fi
  done
}
# @desc: Add a path to the end of a path
function _postpath() {
  local dir; for dir in "$@"; do
    [[ -L "$dir" ]] && dir=$dir:A
    [[ ! -d "$dir" ]] && return
    if [[ -d "$dir" && -r "$dir" ]]; then
      path=("${path[@]}" "$dir")
    fi
  done
}
