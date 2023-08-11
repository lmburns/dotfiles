#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-08-10                                                   #
#    @module: paths                                                        #
#      @desc: Modify zsh PATH parameter                                    #
#===========================================================================

emulate -L zsh -o warncreateglobal

# === Paths ============================================================== [[[
[[ -z ${path[(re)$HOME/.local/bin]} ]] && path=( "$HOME/.local/bin" "${path[@]}" )
[[ -z ${path[(re)/usr/local/sbin]} ]]  && path=( "/usr/local/sbin"  "${path[@]}" )
[[ -z ${fpath[(re)/usr/share/zsh/site-functions]} ]] && fpath=( "${fpath[@]}" /usr/share/zsh/site-functions )

local texlive=$HOME/texlive/2021

# cdpath=( $HOME/{projects/github,.config} )
cdpath=( $XDG_CONFIG_HOME )

manpath=(
  $XDG_DATA_HOME/man
  $ZINIT_HOME/polaris/man(N-/)
  $ZINIT_HOME/polaris/share/man(N-/)
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

  $XDG_DATA_HOME/neovim/bin(N-/)
  $XDG_DATA_HOME/neovim-nightly/bin(N-/)

  $HOME/.ghg/bin(N-/)
  $PYENV_ROOT/{shims,bin}(N-/)
  $GOENV_ROOT/{shims,bin}(N-/)
  $CARGO_HOME/bin(N-/)
  $XDG_DATA_HOME/luarocks/bin(N-/)
  $NPM_PACKAGES/bin(N-/)

  /usr/bin                   # add again to be ahead of /bin
  $texlive/bin/x86_64-linux(N-/)   # prefer arch installed
  $GEM_HOME/bin(N-/)               # prefer arch installed

  # /usr/lib/w3m(N-/)
  $ZPFX/libexec/w3m(N-/)

  $HOME/.ghcup/bin(N-/)
  $HOME/.cabal/bin(N-/)
  # $(stack path --stack-root)/programs/x86_64-linux/ghc-tinfo6-8.10.7/bin
  # $HOME/.poetry/bin(N-/)
  # $RUSTUP_HOME/toolchains/*/bin(N-/)
  "${path[@]}"
)

# export CPATH="/usr/include:/usr/local/include:$CPATH"
# export LIBRARY_PATH="/usr/lib:/usr/local/lib:$LIBRARY_PATH"
# export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:$LIBRARY_PATH"
