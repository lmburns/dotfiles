############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

skip_global_compinit=1

export DO_NOT_TRACK=1
export HINT_TELEMETRY="off"
export NEXT_TELEMETRY_DISABLED=1

export LANGUAGE="en_US.UTF-8"
export LANG="$LANGUAGE"
export LC_ALL="$LANGUAGE"
export LC_CTYPE="$LANGUAGE"

export TMP=${TMP:-${TMPDIR:-/tmp}}
export TMPDIR=$TMP

# export TERMINFO=$XDG_DATA_HOME/terminfo
# export TERMINFO_DIRS=$XDG_DATA_HOME/terminfo:/usr/share/terminfo

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/share/state"

export XDG_DESKTOP_DIR="${HOME}/Desktop"
export XDG_DOWNLOAD_DIR="${HOME}/Downloads"
export XDG_TEMPLATES_DIR="${HOME}/Templates"
export XDG_PUBLICSHARE_DIR="${HOME}/Public"
export XDG_DOCUMENTS_DIR="${HOME}/Documents"
export XDG_MUSIC_DIR="${HOME}/Music"
export XDG_PICTURES_DIR="${HOME}/Pictures"
export XDG_VIDEOS_DIR="${HOME}/Videos"

export XDG_TEST_DIR="${HOME}/test"
export XDG_PROJECT_DIR="${HOME}/projects"
export XDG_BIN_DIR="${HOME}/bin"
export XDG_MBIN_DIR="${HOME}/mybin"

export BACKUP_DIR="${XDG_DOCUMENTS_DIR}/backup"

export LOCAL_OPT="$HOME/opt"
export SUDO_ASKPASS="${XDG_MBIN_DIR}/linux/zenpass" # xfsudo

# export SUDO_PROMPT="%u entered passwd to become %U: "
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh" # Only one that is actually needed
export ZHOMEDIR="${XDG_CONFIG_HOME}/zsh"
export ZRCDIR="${ZHOMEDIR}/zsh.d"
export ZDATADIR="${XDG_DATA_HOME}/zsh"
export ZCACHEDIR="${XDG_CACHE_HOME}/zsh"

export BC_ENV_ARGS="-q"
export TEXLIVE="$HOME/texlive"

export TERMINAL="alacritty"
# export BROWSER="librewolf"
export BROWSER="brave"
export BROWSERCLI="w3m"
export SR_BROWSER="$BROWSERCLI"
export RTV_BROWSER="$BROWSERCLI"

# if [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
#   export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
#   export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
# else
export VISUAL="nvim"
export EDITOR="nvim"
# fi

export RTV_EDITOR="$EDITOR"
export GIT_EDITOR="$EDITOR"
export SVN_EDITOR="$EDITOR"
export SUDO_EDITOR="$EDITOR"
# export RGV_EDITOR="$EDITOR $file +$line"
export SYSTEMD_EDITOR="$EDITOR"
export SYSTEMD_COLORS=1
export SYSTEMD_LOG_COLOR=1

# -F    --quit-if-one-screen
# -s    --squeeze-blank-lines
# -u    --underline-special
# -~    --tilde
#       --modelines=
#       --status-line
#       --save-marks

# -i    --ignore-case
# -J    --status-column
# -n    --line-numbers
# -g    --hilite-search
# -M    --LONG-PROMPT
# -X    --no-init
# -R    --RAW-CONTROL-CHARS
#       --mouse
#       --wheel-lines=3
# -x4   --tabs=4
# -f    --force
# -W    --HILITE-UNREAD
#       --incsearch
#       --save-marks
local l_less='-ingMfRW -x4 --mouse --wheel-lines=3 --incsearch --save-marks'
local l_prompt='--prompt="?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"'
local l_color='--use-color --color=M+52$'
export LESS_OWN_SCREEN="$l_less $l_color $l_prompt"
# export LESS_NO_QUIT="--no-init $LESS_OWN_SCREEN"
# export LESS="--quit-if-one-screen $LESS_NO_QUIT"
export LESS="--no-init $LESS_OWN_SCREEN"
export LESS_QUIT="--quit-if-one-screen $LESS"
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey"
export LESSHISTFILE=/dev/null
# export LESSHISTSIZE=0
# export LESSEDIT=""
# export LESSECHO="lessecho"
# export LESSCLOSE=""
# export LESSOPEN=""
export GROFF_NO_SGR=1

# Opts passed to less when running in more-compatible mode
# export MORE=""

# export DELTA_PAGER="less $LESS"
# export BAT_PAGER="less $LESS"
export LF_PAGER="less $LESS"
# export PAGER="less"
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
# export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"
export AUR_PAGER='lf'
export PERLDOC_PAGER="sh -c 'col -bx | bat -l man -p --theme=kimbox'"
export PERLDOC_SRC_PAGER="sh -c 'col -bx | bat -l man -p --theme=kimbox'"

export PERLTIDY="${XDG_CONFIG_HOME}/perltidy/perltidyrc"

export CCACHE_DIR="${XDG_CACHE_HOME}/ccache"
# export CCACHE_CONFIGPATH="${XDG_CONFIG_HOME}/ccache/ccache.config"
# export CCACHE_COMPRESS=1
# export CCACHE_SLOPPINESS=time_macros,file_macro
# export CCACHE_BASEDIR="$TRAVIS_BUILD_DIR"
# export CCACHE_CPP2=1

export XCURSOR_THEME="Capitaine-Cursors-Gruvbox-White"
export XCURSOR_PATH=${XCURSOR_PATH}:${HOME}/.icons
export GTK2_RC_FILES="${XDG_CONFIG_HOME}/gtk-2.0/gtkrc"
# export GTK_USE_PORTAL=1
export GTK_THEME_VARIANT=dark
export QT_QPA_PLATFORMTHEME=qt5ct
# export QT_QPA_PLATFORMTHEME=gtk2
# export QT_STYLE_OVERRIDE=kvantum

# Smooth scrolling
export MOZ_USE_XINPUT2=1

export XINITRC="${HOME}/.xinitrc"
export VIMRC="${HOME}/.vim/vimrc"
export MYVIMRC="${HOME}/.vim/vimrc"
export NVIMD="${XDG_CONFIG_HOME}/nvim"
export NVIMRC="${NVIMD}/init.lua"
export PACKDIR="${XDG_DATA_HOME}/nvim/site/pack/packer"

export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export LUAROCKS_CONFIG="${XDG_CONFIG_HOME}/luarocks/config.lua"
export GOPATH="${XDG_DATA_HOME}/go"
export GOROOT="${XDG_DATA_HOME}/go"
# export GOENV_ROOT="${XDG_DATA_HOME}/goenv"
# export GEM_PATH="${XDG_DATA_HOME}/ruby/gems"

export GEM_PATH="$(ruby -e 'puts Gem.user_dir')"
export GEM_HOME="$GEM_PATH"
export GEM_SPEC_CACHE="${XDG_DATA_HOME}/ruby/specs"
export RBENV_ROOT="${XDG_DATA_HOME}/rbenv"

export BUN_INSTALL="${HOME}/.bun"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NPM_PACKAGES="${XDG_DATA_HOME}/npm-packages"
export YARNBIN="${HOME}/.yarn/bin"
export YARNGLOBAL="${HOME}/.config/yarn/global/node_modules/.bin"

# export PTPYTHON_CONFIG_HOME="${XDG_CONFIG_HOME}/ptpython/config.py"
export CONDARC="${XDG_CONFIG_HOME}/conda/condarc"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PIPX_BIN_DIR="${XDG_DATA_HOME:h}/bin"
export PIPX_HOME="${XDG_DATA_HOME:h}/pipx"
export IPYTHONDIR="${XDG_CACHE_HOME}/ipython"
export MYPY_CACHE_DIR="${XDG_CACHE_HOME}/mypy"
export POETRY_VENV_IN_PROJECT=1
export POETRY_VIRTUALENVS_CREATE=1
export POETRY_VIRTUALENVS_IN_PROJECT=1
export POETRY_INSTALL_DEPENDENCIES=1

export R_ENVIRON_USER="${XDG_CONFIG_HOME}/r/Renviron"
export R_MAKE_VARS_USER="${XDG_CONFIG_HOME}/r/Makevars"
export R_HISTFILE="${XDG_CONFIG_HOME}/r/Rhistory.Rhistory"
export R_PROFILE_USER="${XDG_CONFIG_HOME}/r/Rprofile"
export R_LIBS_USER="${XDG_CONFIG_HOME}/r/library"
export R_HOME_USER="${XDG_CONFIG_HOME}/r"
export R_BROWSER="$BROWSER"

export STACK_ROOT="${XDG_DATA_HOME}/stack"
export OPAMROOT="${XDG_DATA_HOME}/opam"
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"

export MYSQL_HISTFILE="${XDG_DATA_HOME}/mysql_history"
export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite/history"

export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export GPG_AGENT_INFO="${GNUPGHOME}/S.gpg-agent"
export PINENTRY_USER_DATA="USE_CURSES=1"
export TASKRC="${XDG_CONFIG_HOME}/task/taskrc"
export TASKDATA="${XDG_CONFIG_HOME}/task"
export TIMEWARRIORDB="${XDG_DATA_HOME}/timewarrior/tw.db"

export CURL_HOME="${XDG_CONFIG_HOME}/curl"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"

export NOTMUCH_CONFIG="${XDG_CONFIG_HOME}/notmuch/notmuch-config"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/ripgreprc"
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/config"
export PIER_CONFIG_PATH="${XDG_CONFIG_HOME}/pier/config.toml"
export RPASTE_CONFIG="${XDG_CONFIG_HOME}/rpaste/config.toml"
export MBSYNCRC="${XDG_CONFIG_HOME}/isync/mbsyncrc"
export TIGRC_USER="${XDG_CONFIG_HOME}/tig/config"

export UMCONFIG_HOME="${XDG_CONFIG_HOME}/um"
export GRIPHOME="${XDG_CONFIG_HOME}/grip"
export RLWRAP_HOME="${XDG_DATA_HOME}/rlwrap"
export MATES_DIR="${XDG_DATA_HOME}/mates"
export TMUXINATOR_CONFIG_DIR="${XDG_CONFIG_HOME}/tmux/tmuxinator"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME}/password-store"

export GOGODB_PATH="${XDG_DATA_HOME}/gogo/gogo.db"
export BKT_TMPDIR="${XDG_DATA_HOME}/bkt/cache"
export JAIME_CACHE_DIR="${XDG_CONFIG_HOME}/jaime"
export BARTIB_FILE="${XDG_CONFIG_HOME}/bartib/tasklog"

export URLPORTAL="$XDG_MBIN_DIR/urlportal"
export PRE_COMMIT_COLOR='auto'
# export MTR_OPTIONS="--no-dns"

export NNN_PLUG='P:preview-tui;f:finder;o:fzopen;d:diffs;t:treeview;v:imgview;J:autojump;e:gpge;d:gpgd;m:mimelist;b:nbak;s:organize;B:_renamer;p:_bat $nnn*;y:-_sync*;L:-_git log;k:-_fuser -kiv $nnn*'
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'
export NNN_BMS="d:$XDG_CONFIG_HOME/;u:$LOCAL_OPT/;D:$HOME/Documents/"
export NNN_TRASH=1
export NNN_FIFO='/tmp/nnn.fifo'

# set this here so that way zsh functions are available without always logging in

# fpath=( ${ZDOTDIR}/functions "${fpath[@]}" )
# autoload -Uz $fpath[1]/*(:t)
# if [[ -o rcs && ! -o LOGIN && $SHLVL -eq 1 && -s ${ZDOTDIR:-$HOME}/.zprofile ]]; then

if [[ -o rcs && ! -o login ]]; then
  setopt braceexpand
  typeset -gaxU fpath
  # fpath=( ${ZDOTDIR}/functions{/zeditor,/widgets,/hooks,/zonly,} "${fpath[@]}" )
  # autoload -Uz $^fpath[1,5]/*(:t)

  if (( $+LF_LEVEL )); then
    zmodload -F zsh/parameter p:dirstack
    autoload -Uz chpwd_recent_dirs add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs

    fpath=( ${ZDOTDIR}/functions/lf_fns "${fpath[@]}" )
    autoload -Uz $^fpath[1]/*(:t)

    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max     20
    zstyle ':chpwd:*' recent-dirs-file    "$LF_DIRSTACK_FILE"
    zstyle ':chpwd:*' recent-dirs-prune   'pattern:/tmp(|/*)'
    # zstyle ':completion:*' recent-dirs-insert  both

    function set-dirstack() {
      [[ -v dirstack ]] || typeset -gaU dirstack
      dirstack=(
        ${(u)^${(@fQ)$(<${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null)}[@]:#(\.|$PWD|/tmp/*)}(N-/)
      )
    }

    # for func ($chpwd_functions) { $func }

    set-dirstack
  fi
fi

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]
