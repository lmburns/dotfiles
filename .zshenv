############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

skip_global_compinit=1
# setopt no_global_rcs

export DO_NOT_TRACK=1
export HINT_TELEMETRY="off"
export LANGUAGE="en_US.UTF-8"
export LANG="$LANGUAGE"
export LC_ALL="$LANGUAGE"
export LC_CTYPE="$LANGUAGE"

export TMP=${TMP:-${TMPDIR:-/tmp}}
export TMPDIR=$TMP

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_VIDEOS_DIR="$HOME/Videos"
export XDG_TEMPLATES_DIR="$HOME/Templates"

export XDG_BIN_HOME="$HOME/bin"
export XDG_MBIN_HOME="$HOME/mybin"
export BACKUP_DIR="$HOME/backup"
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export LOCAL_OPT="$HOME/opt"
export SUDO_ASKPASS="${XDG_MBIN_HOME}/linux/zenpass" # xfsudo
# export SUDO_PROMPT="%u entered passwd to become %U: "

export BC_ENV_ARGS="-q"

export TEXLIVE="$HOME/texlive"

export TERMINAL="alacritty"
export BROWSER="librewolf"
# export BROWSER="brave"
export BROWSERCLI="w3m"
export SR_BROWSER="$BROWSERCLI"
export RTV_BROWSER="$BROWSERCLI"

if [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi

export GIT_EDITOR="${EDITOR}"
export RTV_EDITOR="${EDITOR}"
export RGV_EDITOR="${EDITOR} $file +$line"
export SYSTEMD_COLORS=1

# -z-4
# -i -n -w -g -M -X -F -R -f
# export LESS="--mouse --wheel-lines=3 -r -M -f -F -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"
export LESS="\
  --ignore-case \
  --line-numbers \
  --hilite-search \
  --LONG-PROMPT \
  --no-init \
  --quit-if-one-screen \
  --RAW-CONTROL-CHARS \
  --mouse \
  --wheel-lines=3 \
  --tabs 4 \
  --force \
  --prompt ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"

# export PAGER="${commands[less]:-$PAGER}"
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
# export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"
export PERLDOC_PAGER="sh -c 'col -bx | bat -l man -p --theme=kimbro'" \
export PERLDOC_SRC_PAGER="sh -c 'col -bx | bat -l man -p --theme=kimbro'" \
export PERLTIDY="${XDG_CONFIG_HOME}/perltidy/perltidyrc"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

export CCACHE_DIR="${XDG_CACHE_HOME}/ccache"
# export CCACHE_COMPRESS=1
# export CCACHE_SLOPPINESS=time_macros,file_macro
# export CCACHE_BASEDIR="$TRAVIS_BUILD_DIR"
# export CCACHE_CPP2=1

export GTK_USE_PORTAL=1
export GTK_THEME_VARIANT=dark
export QT_QPA_PLATFORMTHEME=qt5ct
# export QT_QPA_PLATFORMTHEME=gtk2
# export QT_STYLE_OVERRIDE=kvantum

export XINITRC="${HOME}/.xinitrc"
export VIMRC="${HOME}/vim/.vimrc"
export MYVIMRC="${HOME}/vim/.vimrc"
export NVIMRC="${XDG_CONFIG_HOME}/nvim/init.lua"
export PACKDIR="${XDG_DATA_HOME}/nvim/site/pack/packer"
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME}/notmuch/notmuch-config"
export TIMEWARRIORDB="${XDG_DATA_HOME}/timewarrior/tw.db"
export TASKRC="${XDG_CONFIG_HOME}/task/taskrc"
export TASKDATA="${XDG_CONFIG_HOME}/task"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/ripgreprc"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
export TIGRC_USER="${XDG_CONFIG_HOME}/tig/tigrc"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export LUAROCKS_CONFIG="${XDG_CONFIG_HOME}/luarocks/config.lua"
export GOPATH="${XDG_DATA_HOME}/go"
export GOROOT="${XDG_DATA_HOME}/go"
export GOENV_ROOT="${XDG_DATA_HOME}/goenv"
# export GEM_PATH="${XDG_DATA_HOME}/ruby/gems"
export GEM_PATH="$(ruby -e 'puts Gem.user_dir')"
export GEM_HOME="$GEM_PATH"
export GEM_SPEC_CACHE="${XDG_DATA_HOME}/ruby/specs"
export RBENV_ROOT="${XDG_DATA_HOME}/rbenv"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NPM_PACKAGES="${XDG_DATA_HOME}/npm-packages"
export CONDARC="${XDG_CONFIG_HOME}/conda/condarc"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PIPX_BIN_DIR="${XDG_DATA_HOME:h}/bin"
export PIPX_HOME="${XDG_DATA_HOME:h}/pipx"
export IPYTHONDIR="${XDG_CACHE_HOME}/ipython"
# export PTPYTHON_CONFIG_HOME="${XDG_CONFIG_HOME}/ptpython/config.py"
export R_ENVIRON_USER="${XDG_CONFIG_HOME}/r/Renviron"
export R_MAKE_VARS_USER="${XDG_CONFIG_HOME}/r/Makevars"
export R_HISTFILE="${XDG_CONFIG_HOME}/r/Rhistory.Rhistory"
export R_PROFILE_USER="${XDG_CONFIG_HOME}/r/Rprofile"
export R_LIBS_USER="${XDG_CONFIG_HOME}/r/library"
export R_HOME_USER="${XDG_CONFIG_HOME}/r"
export R_BROWSER="$BROWSER"
export RLWRAP_HOME="${XDG_DATA_HOME}/rlwrap"
export STACK_ROOT="${XDG_DATA_HOME}/stack"
export OPAMROOT="${XDG_DATA_HOME}/opam"
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"
export MYSQL_HISTFILE="${XDG_DATA_HOME}/mysql_history"
export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite/history"
export GTK2_RC_FILES="${XDG_CONFIG_HOME}/gtk-2.0/gtkrc"
# export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"
export LESSHISTFILE=/dev/null
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME}/password-store"
export TMUXINATOR_CONFIG_DIR="${XDG_CONFIG_HOME}/tmux/tmuxinator"

export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/config"
export PIER_CONFIG_PATH="${XDG_CONFIG_HOME}/pier/config.toml"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export GPG_AGENT_INFO="${GNUPGHOME}/S.gpg-agent"
export PINENTRY_USER_DATA="USE_CURSES=1"
export UMCONFIG_HOME="${XDG_CONFIG_HOME}/um"
export GRIPHOME="${XDG_CONFIG_HOME}/grip"
# export MBSYNCRC="${XDG_CONFIG_HOME}/isync/mbsyncrc"
export TMUXINATOR_CONFIG_DIR="${XDG_CONFIG_HOME}/tmux/tmuxinator"

export GOGODB_PATH="${XDG_DATA_HOME}/gogo/gogo.db"
export BKT_TMPDIR="${XDG_DATA_HOME}/bkt/cache"

export NNN_PLUG='P:preview-tui;f:finder;o:fzopen;d:diffs;t:treeview;v:imgview;J:autojump;e:gpge;d:gpgd;m:mimelist;b:nbak;s:organize;B:_renamer;p:_bat $nnn*;y:-_sync*;L:-_git log;k:-_fuser -kiv $nnn*'
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'
export NNN_BMS="d:$XDG_CONFIG_HOME/;u:$LOCAL_OPT/;D:$HOME/Documents/"
export NNN_TRASH=1
export NNN_FIFO='/tmp/nnn.fifo'

export URLPORTAL="$XDG_MBIN_HOME/urlportal"
export MATES_DIR="${XDG_DATA_HOME}/mates"
export JAIME_CACHE_DIR="${XDG_CONFIG_HOME}/jaime"
export BARTIB_FILE="${XDG_CONFIG_HOME}/bartib/tasklog"
export RPASTE_CONFIG="${XDG_CONFIG_HOME}/rpaste/config.toml"
export PRE_COMMIT_COLOR='auto'

# [ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx "$XINITRC"

# vim:ft=zsh:et:sw=0:ts=2:sts=2:
