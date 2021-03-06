############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

skip_global_compinit=1
# setopt no_global_rcs

# [[ -x '/usr/libexec/path_helper' ]] && source <(/usr/libexec/path_helper -s)

export LANGUAGE="en_US.UTF-8"
export LANG="${LANGUAGE}"
export LC_ALL="${LANGUAGE}"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/tmp"
export XDG_BIN_HOME="$HOME/bin"
export XDG_MBIN_HOME="$HOME/mybin"
export LOCAL_OPT="$HOME/opt"
export SUDO_ASKPASS="$XDG_MBIN_HOME/zenity_passphrase"

export BROWSER='/Applications/LibreWolf.app/Contents/MacOS/librewolf-bin'
export BROWSERCLI="w3m"
export SR_BROWSER="$BROWSERCLI"
export RTV_BROWSER="$BROWSERCLI"
export EDITOR='nvim'
# export VISUAL="${EDITOR}"
export GIT_EDITOR="${EDITOR}"
export RGV_EDITOR="${EDITOR} $file +$line"

export LESS="-r -M -f -F -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]"
# export PAGER="${commands[less]:-$PAGER}"
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
# export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"
export PERLDOC_PAGER="sh -c 'col -bx | bat -l man -p --theme='kimbie''" \
export PERLDOC_SRC_PAGER="sh -c 'col -bx | bat -l man -p --theme='kimbie''" \

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

export VIMRC="${XDG_CONFIG_HOME}/nvim/init.vim"
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME}/notmuch/notmuch-config"
export TIMEWARRIORDB="${XDG_DATA_HOME}/timewarrior/tw.db"
export TASKRC="${XDG_CONFIG_HOME}/task/taskrc"
export TASKDATA="${XDG_CONFIG_HOME}/task"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/ripgreprc"
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
export TIGRC_USER="${XDG_CONFIG_HOME}/tig/tigrc"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export GOPATH="${HOME}/go"
export GEM_HOME="${XDG_DATA_HOME}/ruby/gems"
export GEM_SPEC_CACHE="${XDG_DATA_HOME}/ruby/specs"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
export CONDARC="${XDG_CONFIG_HOME}/conda/condarc"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PIPX_BIN_DIR="${XDG_DATA_HOME:h}/bin"
export IPYTHONDIR="${XDG_CACHE_HOME}/ipython"
# export PTPYTHON_CONFIG_HOME="${XDG_CONFIG_HOME}/ptpython/config.py"
# export R_USER="${XDG_CONFIG_HOME}/r/R"
export R_ENVIRON_USER="${XDG_CONFIG_HOME}/r/Renviron"
export R_MAKE_VARS_USER="${XDG_CONFIG_HOME}/r/Makevars"
export R_HISTFILE="${XDG_CONFIG_HOME}/r/Rhistory"
export R_PROFILE_USER="${XDG_CONFIG_HOME}/r/Rprofile"
export R_LIBS_USER="${XDG_CONFIG_HOME}/r"
export LESSHISTFILE="-"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME}/password-store"

export DO_NOT_TRACK=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_BAT=1
export HOMEBREW_BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/config"
export HOMEBREW_COLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/config"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export GPG_TTY=$TTY
export GPG_AGENT_INFO="${GNUPGHOME}/S.gpg-agent"
export PINENTRY_USER_DATA="USE_CURSES=1"
export OSFONTDIR="$HOME/Library/Fonts"
export UMCONFIG_HOME="${XDG_CONFIG_HOME}/um"
export PIER_CONFIG_PATH="${XDG_CONFIG_HOME}/pier/config.toml"
export GRIPHOME="${XDG_CONFIG_HOME}/grip"

export NNN_PLUG='P:preview-tui;f:finder;o:fzopen;d:diffs;t:treeview;v:imgview;J:autojump;e:gpge;d:gpgd;m:mimelist;b:nbak;s:organize;B:_renamer;p:_bat $nnn*;y:-_sync*;L:-_git log;k:-_fuser -kiv $nnn*'
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'
export NNN_BMS="d:$XDG_CONFIG_HOME/;u:$LOCAL_OPT/;D:$HOME/Documents/"
export NNN_TRASH=1
export NNN_FIFO='/tmp/nnn.fifo'

export URLPORTAL="$XDG_MBIN_HOME/urlportal"
export MATES_DIR="${XDG_DATA_HOME}/mates"

source "${XDG_DATA_HOME}/cargo/env"

[[ -x /usr/libexec/path_helper ]] && {
  PATH=""
  eval `/usr/libexec/path_helper -s`
}

# vim:ft=zsh:et:sw=0:ts=2:sts=2:
