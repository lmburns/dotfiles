############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# This file is sourced on each shell invocation. Including lf
skip_global_compinit=1

export DO_NOT_TRACK=1
export HINT_TELEMETRY="off"
export NEXT_TELEMETRY_DISABLED=1

export LANGUAGE="en_US.UTF-8"
export LANG="$LANGUAGE"
# export LC_ALL="$LANGUAGE"
# export LC_CTYPE="$LANGUAGE"

export TMP=${TMP:-${TMPDIR:-/tmp}}
export TMPDIR=$TMP

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"    # only one that is actually needed
export ZROOT="$ZDOTDIR"                    # alias for $ZDOTDIR
export ZUSRDIR="${ZROOT}/usr"
export ZRCDIR="${ZROOT}/zsh.d"           # zsh config dir
export ZSRCDIR="${ZROOT}/src"            # zsh config dir
export ZDATADIR="${ZROOT}/data"
export ZCACHEDIR="${ZROOT}/cache"
export ZSH_CACHE_DIR="${ZCACHEDIR}/zinit"

typeset -a Zdirs__FUNC_reg=(lib utils zonly)     # + functions
typeset -a Zdirs__FUNC_zwc=(hooks widgets wrap)  # + completions
typeset -a Zdirs__FUNC=("$Zdirs__FUNC_reg[@]" "$Zdirs__FUNC_zwc[@]")
typeset -a Zdirs__ZWC=(
  $ZROOT/functions/${^Zdirs__FUNC_zwc[@]}
  $ZROOT/completions
  $ZROOT/.zshrc
  $ZROOT/.zshenv
)

# Can be used like: ${${(P)Zinfo[dirs]}[CACHE]}
# Can be used like: ${(@P)Zdirs[FUNC_D]}
declare -gxA Zdirs=(
  ROOT       $ZROOT
  RC         $ZRCDIR
  SRC        $ZSRCDIR
  USR        $ZUSRDIR
  DATA       $ZDATADIR
  CACHE      $ZCACHEDIR
  COMPL      $ZDOTDIR/completions
  PATCH      $ZDOTDIR/patches
  THEME      $ZDOTDIR/themes
  PLUG       $ZDOTDIR/plugins
  SNIP       $ZDOTDIR/snippets
  ALIAS      $ZDOTDIR/aliases

  FUNC       $ZDOTDIR/functions
  FUNC_D_reg Zdirs__FUNC_reg
  FUNC_D_zwc Zdirs__FUNC_zwc
  FUNC_D     Zdirs__FUNC
  ZWC        Zdirs__ZWC
)
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
export LYNX_CFG="${XDG_CONFIG_HOME}/lynx/lynx.cfg"

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
  # setopt braceexpand
  if (( $+LF_LEVEL )); then
    setopt aliases
    declare -gx LFLOGF="${Zdirs[CACHE]}/lf-zsh.log"
    alias -g LFIO=&>>!"${LFLOGF::=/tmp/lf-zsh.log}"

    typeset -gaxU fpath
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
        ${(u)^${(@fQ)$(<${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null)}[@]:#(\.|${PWD:h}|/tmp/*)}(N-/)
      )
    }

    # setopt interactive_comments # allow comments in history
    # setopt interactive          # this is an interactive shell
    # setopt shin_stdin           # commands are being read from the standard input

    setopt aliases       # expand aliases
    setopt unset         # don't error out when unset parameters are used
    setopt sh_word_split # field split on unquoted
    setopt err_exit      # if cmd has a non-zero exit status, execute ZERR trap, if set, and exit
    setopt rc_quotes     # allow '' inside '' to indicate a single '
    setopt extended_glob # extension of glob patterns

    # setopt xtrace           # print commands and their arguments as they are executed
    # setopt source_trace     # print an informational message announcing name of each file it loads
    # setopt eval_lineno      # lineno of expr evaled using builtin eval are tracked separately of enclosing environment
    # setopt debug_before_cmd # run DEBUG trap before each command; otherwise it is run after each command
    # setopt err_returns      # if cmd has a non-zero exit status, return immediately from enclosing function
    # setopt traps_async      # while waiting for a program to exit, handle signals and run traps immediately

    # setopt localloops       # break/continue propagate out of function affecting loops in calling funcs
    # setopt localtraps       # global traps are restored when exiting function
    # setopt localoptions     # make options local to function
    # setopt localpatterns    # disable pattern matching

    setopt auto_cd             # if command name is a dir, cd to it
    setopt auto_pushd          # cd pushes old dir onto dirstack
    setopt pushd_ignore_dups   # don't push dupes onto dirstack
    setopt pushd_minus         # inverse meaning of '-' and '+'
    setopt pushd_silent        # don't print dirstack after 'pushd' / 'popd'
    setopt cd_silent           # don't print dirstack after 'cd'
    setopt cdable_vars         # if item isn't a dir, try to expand as if it started with '~'

    setopt rematch_pcre      # when using =~ use PCRE regex
    setopt glob_complete     # generate glob matches as completions
    setopt glob_dots         # do not require leading '.' for dotfiles
    setopt glob_star_short   # ** == **/*      *** == ***/*
    setopt case_paths        # nocaseglob + casepaths treats only path components containing glob chars as insensitive
    setopt numeric_glob_sort # sort globs numerically
    setopt no_nomatch        # don't print an error if pattern doesn't match
    setopt no_case_glob      # case insensitive globbing
    # setopt case_match      # when using =~ make expression sensitive to case
    # setopt csh_null_glob   # don't report if a pattern has no matches unless all do
    # setopt glob_assign     # expand globs on RHS of assignment
    # setopt glob_subst      # results from param exp are eligible for filename generation

    setopt short_loops          # allow short forms of for, repeat, select, if, function
    setopt no_rm_star_silent    # query the user before executing `rm *' or `rm path/*'
    setopt no_bg_nice           # don't run background jobs in lower priority by default
    setopt long_list_jobs       # list jobs in long format by default
    # setopt interactive_comments # allow comments in history
    # setopt notify               # report status of jobs immediately
    # setopt monitor              # enable job control
    # setopt auto_resume         # for single commands, resume matching jobs instead
    # setopt ksh_option_print    # print all options
    # setopt brace_ccl           # expand in braces, which would not otherwise, into a sorted list

    setopt c_bases              # 0xFF instead of 16#FF
    setopt c_precedences        # use precendence of operators found in C
    setopt octal_zeroes         # 077 instead of 8#77
    setopt multios              # perform multiple implicit tees and cats with redirection

    setopt hash_cmds     # save location of command preventing path search
    setopt hash_dirs     # when command is completed hash it and all in the dir
    # setopt hash_list_all # when a completion is attempted, hash it first

    setopt no_clobber      # don't overwrite files without >! >|
    setopt no_flow_control # don't output flow control chars (^S/^Q)
    setopt no_hup          # don't send HUP to jobs when shell exits
    setopt no_beep         # don't beep on error
    setopt no_mail_warning # don't print mail warning

    setopt hist_ignore_space      # don't add if starts with space
    setopt hist_ignore_dups       # do not enter command lines into the history list if they are duplicates
    setopt hist_reduce_blanks     # remove superfluous blanks from each command
    setopt hist_expire_dups_first # if the internal history needs to be trimmed, trim oldest
    setopt hist_fcntl_lock        # use fcntl to lock hist file
    setopt hist_subst_pattern     # allow :s/:& to use patterns instead of strings
    setopt extended_history       # add beginning time, and duration to history
    setopt append_history         # all zsh sessions append to history, not replace
    setopt share_history          # imports commands and appends, can't be used with inc_append_history
    setopt no_hist_no_functions   # don't remove function defs from history

    # for func ($chpwd_functions) { $func }
    set-dirstack
  fi
fi

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]
