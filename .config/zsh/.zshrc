############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# === general settings === [[[
0="${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}"
# 0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
# 0="${${(M)0:#/*}:-$PWD/$0}"

umask 022
# limit coredumpsize 0

typeset -gaxU path fpath manpath infopath cdpath mailpath
typeset -fuz zkbd

typeset -ga mylogs
typeset -F4 SECONDS=0
function zflai-msg()    { mylogs+=( "$1" ); }
function zflai-assert() { mylogs+=( "$4"${${${1:#$2}:+FAIL}:-OK}": $3" ); }
function zflai-print()  {
  print -rl -- ${(%)mylogs//(#b)(\[*\]): (*)/"%F{1}$match[1]%f: $match[2]"};
}

# Write zprof to $mylogs
function zflai-zprof() {
  local -a arr; arr=( ${(@f)"$(zprof)"} )
  for idx ({3..7}) {
    zflai-msg "[zprof]: ${arr[$idx]##*)[[:space:]]##}"
  }
}

zflai-msg "[path]: ${${(pj:\n\t:)path}}"

setopt c_bases              # 0xFF instead of 16#FF
setopt c_precedences        # use precendence of operators found in C
setopt octal_zeroes         # 077 instead of 8#77

typeset -g DIRSTACKSIZE=20
typeset -g HISTORY_IGNORE="(youtube-dl|you-get|yt-dlp|history|exit)"
# typeset -g SAVEHIST=10_000_000
typeset -g SAVEHIST=$(( [#_] 10 ** 7 ))
typeset -g HISTSIZE=$(( 1.2 * SAVEHIST ))
typeset -g HISTFILE="${XDG_CACHE_HOME}/zsh/zsh_history"
typeset -g HIST_STAMPS="yyyy-mm-dd"
typeset -g LISTMAX=50                         # Size of asking history
typeset -g PROMPT_EOL_MARK="%F{14}⏎%f"        # Show non-newline ending
typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)' # Don't eat space with | with tabs
typeset -g ZLE_SPACE_SUFFIX_CHARS=$'&|'
typeset -g MAILCHECK=0                 # Don't check for mail
typeset -g KEYTIMEOUT=15               # Key action time
typeset -g FCEDIT=$EDITOR              # History editor
typeset -g READNULLCMD=$PAGER          # Read contents of file with <file
typeset -g TMPPREFIX="${TMPDIR%/}/zsh" # Temporary file prefix for zsh

watch=( notme )
PERIOD=3600
function periodic() { builtin rehash; }

# Various highlights for CLI
typeset -ga zle_highlight=(
  # region:fg="#a89983",bg="#4c96a8"
  # paste:standout
  region:standout
  special:standout
  suffix:bold
  isearch:underline
  paste:none
)

[[ "$UID" = 0 ]] && { unset HISTFILE && SAVEHIST=0 }

() {
  # local i; i=${(@j::):-%\({1..36}"e,$( echoti cuf 2 ),)"}
  # typeset -g PS4=$'%(?,,\t\t-> %F{9}%?%f\n)'
  # PS4+=$'%2<< %{\e[2m%}%e%22<<             %F{10}%N%<<%f %3<<  %I%<<%b %(1_,%F{11}%_%f ,)'

  declare -g SPROMPT="Correct '%F{17}%B%R%f%b' to '%F{20}%B%r%f%b'? [%F{18}%Bnyae%f%b] : "  # Spelling correction prompt
  declare -g PS2="%F{1}%B>%f%b "  # Secondary prompt
  declare -g RPS2="%F{14}%i:%_%f" # Right-hand side of secondary prompt

  autoload -Uz colors; colors
  local red=$fg_bold[red] blue=$fg[blue] rst=$reset_color
  declare -g TIMEFMT=(
    "$red%J$rst"$'\n'
    "User: $blue%U$rst"$'\t'"System: $blue%S$rst  Total: $blue%*Es$rst"$'\n'
    "CPU:  $blue%P$rst"$'\t'"Mem:    $blue%M MB$rst"
  )
}

setopt hist_ignore_space      # don't add if starts with space
setopt hist_reduce_blanks     # remove superfluous blanks from each command
setopt hist_ignore_all_dups   # replace duplicate commands in history file
setopt hist_expire_dups_first # if the internal history needs to be trimmed, trim oldest
setopt hist_ignore_dups       # do not enter command lines into the history list if they are duplicates
setopt hist_fcntl_lock        # use fcntl to lock hist file
setopt hist_subst_pattern     # allow :s/:& to use patterns instead of strings
setopt extended_history       # add beginning time, and duration to history
setopt append_history         # all zsh sessions append to history, not replace
setopt share_history          # imports commands and appends, can't be used with inc_append_history
setopt no_hist_no_functions   # don't remove function defs from history
# setopt inc_append_history # append to history file immediately, not when shell exits

# cd settings
setopt auto_cd      auto_pushd  pushd_ignore_dups  pushd_minus  pushd_silent
setopt cdable_vars  # if item isn't a dir, try to expand as if it started with '~'

setopt prompt_subst # allow substitution in prompt (p10k?)

setopt numeric_glob_sort # sort globs numerically
setopt case_paths        # nocaseglob + casepaths treats only path components containing glob chars as insensitive
setopt no_case_glob      # case insensitive globbing
setopt extended_glob     # extension of glob patterns
setopt rematch_pcre      # when using =~ use PCRE regex
setopt glob_complete     # generate glob matches as completions
setopt glob_dots         # do not require leading '.' for dotfiles
setopt glob_star_short   # ** = **/*; *** = ***/*

setopt complete_in_word # cursor stays in same spot with completion
setopt always_to_end    # cursor moves to end of word if completion is executed
setopt auto_menu        # automatically use menu completion (fzf-tab?)

# setopt hash_cmds     # save location of command preventing path search
setopt hash_list_all # when a completion is attempted, hash it first
setopt correct      # try to correct mistakes

setopt rc_quotes            # allow '' inside '' to indicate a single '
setopt rm_star_silent       # do not query the user before executing `rm *' or `rm path/*'
setopt interactive_comments # allow comments in history
setopt unset                # don't error out when unset parameters are used
setopt long_list_jobs       # list jobs in long format by default
setopt notify               # report status of jobs immediately
setopt short_loops          # allow short forms of for, repeat, select, if, function
# setopt ksh_option_print    # print all options
# setopt brace_ccl           # expand in braces, which would not otherwise, into a sorted list
# setopt list_types          # show type of file with indicator at end

setopt multios              # perform multiple implicit tees and cats with redirection

setopt no_flow_control # don't output flow control chars (^S/^Q)
setopt no_hup          # don't send HUP to jobs when shell exits
setopt no_nomatch      # don't print an error if pattern doesn't match
setopt no_beep         # don't beep on error
setopt no_mail_warning # don't print mail warning

typeset -gx ZINIT_HOME="${0:h}/zinit"
typeset -gx GENCOMP_DIR="${0:h}/completions"
typeset -gx GENCOMPL_FPATH="${0:h}/completions"
local pchf="${0:h}/patches"
local thmf="${0:h}/themes"

typeset -gA ZINIT=(
    HOME_DIR        ${0:h}/zinit
    BIN_DIR         ${0:h}/zinit/bin
    PLUGINS_DIR     ${0:h}/zinit/plugins
    SNIPPETS_DIR    ${0:h}/zinit/snippets
    COMPLETIONS_DIR ${0:h}/zinit/completions
    ZCOMPDUMP_PATH  ${0:h}/.zcompdump-${HOST/.*/}-${ZSH_VERSION}
    COMPINIT_OPTS   -C
)

alias ziu='zi update'
alias zid='zi delete'

zmodload -F zsh/parameter p:dirstack
autoload -Uz chpwd_recent_dirs add-zsh-hook cdr zstyle+
add-zsh-hook chpwd chpwd_recent_dirs
add-zsh-hook -Uz zsh_directory_name zsh_directory_name_cdr # cd ~[1]

zstyle+ ':chpwd:*' recent-dirs-default true \
      + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs" \
      + ''         recent-dirs-max     20 \
      + ''         recent-dirs-prune   'pattern:/tmp(|/*)'

zstyle ':completion:*' recent-dirs-insert  both

# Can be called across sessions to update the dirstack without sourcing
# This should be fixed to update across sessions without ever needing to be called
function set-dirstack() {
  [[ -v dirstack ]] || typeset -gaU dirstack
  dirstack=(
    ${(u)^${(@fQ)$(<${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null)}[@]:#(\.|$PWD|/tmp/*)}(N-/)
  )
}
set-dirstack

# Taken from romkatv/zsh4humans
# ${(D)PWD}
local dir=${(%):-%~}
[[ $dir = ('~'|/)* ]] && () {
  # if (( ! $#dirstack && (DIRSTACKSIZE || ! $+DIRSTACKSIZE) )); then
    local d stack=()
    foreach d ($dirstack) {
      {
        if [[ ($#stack -ne 0 || $d != $dir) ]]; then
          d=${~d}
          if [[ -d ${d::=${(g:ceo:)d}} ]]; then
            stack+=($d)
            (( $+DIRSTACKSIZE && $#stack >= DIRSTACKSIZE - 1 )) && break
          fi
        fi
      } always {
        let TRY_BLOCK_ERROR=0
      }
    } 2>/dev/null
    dirstack=($stack)
  # fi
}
alias c=cdr

fpath=( ${0:h}/{functions,completions} "${fpath[@]}" )
autoload -Uz $fpath[1]/*(:t)
# module_path+=( "$ZINIT[BIN_DIR]/zmodules/Src" ); zmodload zdharma/zplugin &>/dev/null
# ]]]

# === zinit === [[[
# ========================== zinit-functions ========================== [[[
# Shorten zinit command
zt()       { zinit depth'3' lucid ${1/#[0-9][a-c]/wait"${1}"} "${@:2}"; }
# Zinit wait if command is already installed
has()      { print -lr -- ${(j: && :):-"[[ ! -v commands[${^@}] ]]"}; }
# Print command to be executed by zinit
mv_clean() { print -lr -- "command mv -f tar*/rel*/${1:-%PLUGIN%} . && cargo clean"; }

# Shorten url with `dl` annex
grman() {
  local graw="https://raw.githubusercontent.com"; local -A opts
  zparseopts -D -E -A opts -- r: e:
  print -r "${graw}/%USER%/%PLUGIN%/master/${@:1}${opts[-r]:-%PLUGIN%}${opts[-e]:-.1}";
}

# Show the url <owner/repo>
id_as() {
  print -rl -- ${${(S)${(M)${(@f)"$(cargo show $1)"}:#repository: *}/repository: https:\/\/*\//}//(#m)*/<$MATCH>}
}
# ]]] ========================== zinit-functions ==========================

{
  [[ ! -f $ZINIT[BIN_DIR]/zinit.zsh ]] && {
    command mkdir -p "$ZINIT_HOME" && command chmod g-rwX "$ZINIT_HOME"
    command git clone https://github.com/zdarma-continuum/zinit "$ZINIT[BIN_DIR]"
  }
} always {
  builtin source "$ZINIT[BIN_DIR]/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit
}

local zstart=$EPOCHREALTIME

# Unsure if all of this defer here does anything with turbo
zt light-mode for \
  atinit'
  function defer() {
    { [[ -v functions[zsh-defer] ]] && zsh-defer -a "$@"; } || return 0;
  }' \
      romkatv/zsh-defer

# Completions do not work properly if they are placed after the fzf-tab block
# If turbo mode is not used, it doesn't matter where
zt 0b light-mode null id-as for \
  src"$ZDOTDIR/zsh.d/completions.zsh" \
    zdharma-continuum/null

# === annex, prompt === [[[
zt light-mode for \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-submods \
  zdharma-continuum/zinit-annex-bin-gem-node \
  NICHOLAS85/z-a-linkman \
  NICHOLAS85/z-a-linkbin \
    atinit'Z_A_USECOMP=1' \
  NICHOLAS85/z-a-eval \
  lmburns/z-a-check

# zdharma-continuum/zinit-annex-rust
# zdharma-continuum/zinit-annex-as-monitor
# zdharma-continuum/zinit-annex-readurl

(){
  [[ -f "${thmf}/${1}-pre.zsh" || -f "${thmf}/${1}-post.zsh" ]] && {
    zt light-mode for \
        romkatv/powerlevel10k \
      id-as"${1}-theme" \
      atinit"[[ -f ${thmf}/${1}-pre.zsh ]] && source ${thmf}/${1}-pre.zsh" \
      atload"[[ -f ${thmf}/${1}-post.zsh ]] && source ${thmf}/${1}-post.zsh" \
      atload'alias ntheme="$EDITOR ${thmf}/${MYPROMPT}-post.zsh"' \
        zdharma-continuum/null
  } || {
    [[ -f "${thmf}/${1}.toml" ]] && {
      export STARSHIP_CONFIG="${thmf}/${MYPROMPT}.toml"
      export STARSHIP_CACHE="${XDG_CACHE_HOME}/${MYPROMPT}"
      eval "$(starship init zsh)"
      zt 0a light-mode for \
        lbin atclone'cargo br --features=notify-rust' atpull'%atclone' atclone"$(mv_clean)" \
        atclone'./starship completions zsh > _starship' atload'alias ntheme="$EDITOR $STARSHIP_CONFIG"' \
        starship/starship
    }
  } || print -P "%F{4}Theme ${1} not found%f"
} "${MYPROMPT=p10k}"

add-zsh-hook chpwd chpwd_ls
# ]]] === annex, prompt ===

# === trigger-load block ===[[[
zt 0a light-mode for \
  is-snippet trigger-load'!x' blockf svn \
    OMZ::plugins/extract \
  trigger-load'!zhooks' \
    agkozak/zhooks \
  trigger-load'!ugit' \
    Bhupesh-V/ugit \
  trigger-load'!ga;!gi;!grh;!grb;!glo;!gd;!gcf;!gco;!gclean;!gss;!gcp;!gcb' \
    wfxr/forgit \
  trigger-load'!hist' blockf nocompletions compile'f*/*~*.zwc' \
    marlonrichert/zsh-hist

# patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' \
# trigger-load'!updatelocal' blockf compile'f*/*~*.zwc' \
# atinit'typeset -gx UPDATELOCAL_GITDIR="${HOME}/opt"' \
#   NICHOLAS85/updatelocal \
#
# atinit'forgit_ignore="/dev/null"' \

zt 0a light-mode for \
  trigger-load'!gcomp' blockf \
  atclone'command rm -rf lib/*;git ls-files -z lib/ |xargs -0 git update-index --skip-worktree' \
  submods'RobSis/zsh-completion-generator -> lib/zsh-completion-generator;
  nevesnunes/sh-manpage-completions -> lib/sh-manpage-completions' \
  atload'gcomp(){gencomp "${@}" && zinit creinstall -q "${GENCOMP_DIR}" 1>/dev/null}' \
    Aloxaf/gencomp

# ]]] === trigger-load block ===

# === wait'0a' block === [[[
zt 0a light-mode for \
    OMZ::lib/completion.zsh \
  as'completion' atpull'zinit cclear' blockf \
    zsh-users/zsh-completions \
  ver'develop' atload'_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions \
  as'completion' nocompile mv'*.zsh -> _git' \
    felipec/git-completion \
  pick'you-should-use.plugin.zsh' \
    MichaelAquilina/zsh-you-should-use \
  lbin'!' patch"${pchf}/%PLUGIN%.patch" reset nocompletions \
  atinit'_w_db_faddf() { dotbare fadd -f; }; zle -N db-faddf _w_db_faddf' \
  pick'dotbare.plugin.zsh' \
    kazhala/dotbare \
  pick'timewarrior.plugin.zsh' \
    svenXY/timewarrior \
  pick'async.zsh' \
    mafredri/zsh-async \
  patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' blockf \
    psprint/zsh-navigation-tools \
    zdharma-continuum/zflai \
  patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' \
  atinit'alias wzman="ZMAN_BROWSER=w3m zman"' \
  atinit'alias zmand="info zsh "' \
    mattmc3/zman \
    anatolykopyl/doas-zsh-plugin
# ]]] === wait'0a' block ===

#  === wait'0b' - patched === [[[
zt 0b light-mode patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' for \
  blockf atclone'cd -q functions;renamer --verbose "^\.=@" .*' \
  compile'functions/*~*.zwc' \
    marlonrichert/zsh-edit \
  atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
    hlissner/zsh-autopair \
  trackbinds bindmap'\e[1\;6D -> ^[[1\;6D; \e[1\;6C -> ^[[1\;6C' \
    michaelxmcbride/zsh-dircycle \
  trackbinds bindmap'^H -> ^X^T' \
  atload'add-zsh-hook chpwd @chwpd_dir-history-var;
  add-zsh-hook zshaddhistory @append_dir-history-var; @chwpd_dir-history-var now' \
    kadaan/per-directory-history \
  atinit'zicompinit_fast; zicdreplay;' atload'unset "FAST_HIGHLIGHT[chroma-man]"' \
  atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- $f};}' \
  compile'.*fast*~*.zwc' nocompletions atpull'%atclone' \
    zdharma-continuum/fast-syntax-highlighting \
  atload'vbindkey "Up" history-substring-search-up;
         vbindkey "Down" history-substring-search-down' \
    zsh-users/zsh-history-substring-search \
  trackbinds bindmap"^R -> ^W" \
    m42e/zsh-histdb-fzf
#  ]]] === wait'0b' - patched ===

#  === wait'0b' === [[[
zt 0b light-mode for \
  blockf compile'lib/*f*~*.zwc' \
    Aloxaf/fzf-tab \
  autoload'#manydots-magic' \
    knu/zsh-manydots-magic \
    RobSis/zsh-reentry-hook \
  compile'h*~*.zwc' trackbinds bindmap'^R -> ^F' \
  atload'
  zstyle ":history-search-multi-word" highlight-color "fg=cyan,bold";
  zstyle ":history-search-multi-word" page-size "16"' \
    zdharma-continuum/history-search-multi-word \
  pick'*plugin*' blockf nocompletions compile'*.zsh~*.zwc' \
  src"histdb-interactive.zsh" atload'HISTDB_FILE="${ZDOTDIR}/.zsh-history.db"' \
  atinit'bindkey "\Ce" _histdb-isearch' \
    larkery/zsh-histdb \
  pick'autoenv.zsh' nocompletions \
  atload'AUTOENV_AUTH_FILE="${ZPFX}/share/autoenv/autoenv_auth"' \
    Tarrasch/zsh-autoenv \
  blockf \
    zdharma-continuum/zui \
    zdharma-continuum/zbrowse \
  atinit'alias marks::sync="vi-dir-marks::sync"  marks::list="vi-dir-marks::list"
         alias marks::mark="vi-dir-marks::mark"  marks::jump="vi-dir-marks::jump"
         bindkey -a "gl" marks' \
    zsh-vi-more/directory-marks \
    zsh-vi-more/vi-motions \
    zsh-vi-more/vi-quote \
    OMZP::systemd/systemd.plugin.zsh

# wait'[[ -n $DISPLAY ]]' atload'
# zstyle ":notify:*" expire-time 6
# zstyle ":notify:*" error-title "Command failed (in #{time_elapsed} seconds)"
# zstyle ":notify:*" success-title "Command finished (in #{time_elapsed} seconds)"' \
#   marzocchi/zsh-notify \
#
# jeffreytse/zsh-vi-mode
#  ]]] === wait'0b' ===

#  === wait'0c' - programs - sourced === [[[
zt 0c light-mode binary for \
  lbin'!**/*grep;**/*man;**/*diff' has'bat' atpull'%atclone' \
  atclone'(){local f;builtin cd -q src;for f (*.sh){mv ${f} ${f:r}};}' \
  atload'alias bdiff="batdiff" bm="batman" bgrep="env -u RIPGREP_CONFIG_PATH batgrep"' \
    eth-p/bat-extras \
  lbin'cht.sh -> cht' id-as'cht.sh' \
    https://cht.sh/:cht.sh \
  lbin"$ZPFX/bin/git-*" atclone'rm -f **/*ignore' \
  src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" \
    tj/git-extras \
  lbin atload'alias giti="git-ignore"'\
    laggardkernel/git-ignore \
  lbin'f*~*.zsh' pick'*.zsh' atinit'alias fs="fstat"' \
    lmburns/fzfgit \
  patch"${pchf}/%PLUGIN%.patch" reset lbin'!src/pt*(*)' \
  atclone'(){local f;builtin cd -q src;for f (*.sh){mv ${f} ${f:r:l}};}' \
  atclone"command mv -f config $ZPFX/share/ptSh/config" \
  atload'alias mkd="ptmkdir -pv"' \
    jszczerbinsky/ptSh \
  lbin atclone"mkdir -p $XDG_CONFIG_HOME/ytfzf; cp **/conf.sh $XDG_CONFIG_HOME/ytfzf" \
    pystardust/ytfzf \
  wait"$(has surfraw)" lbin from'gl' atclone'./prebuild; ./configure --prefix="$ZPFX"; make' \
  make"install"  atpull'%atclone' \
    surfraw/Surfraw \
  wait"$(has xsel)" lbin atclone'./autogen.sh; ./configure --prefix="$ZPFX"; make' \
  make"install" atpull'%atclone' lman \
    kfish/xsel \
  wait"$(has w3m)" lbin atclone'./configure --prefix="$ZPFX"; make' \
  make"install" atpull'%atclone' lman \
    tats/w3m \
  lbin atclone'./autogen.sh && ./configure --enable-unicode --prefix="$ZPFX"' \
  make'install' atpull'%atclone' lman \
    KoffeinFlummi/htop-vim \
  wait"$(has tmux)" lbin patch"${pchf}/%PLUGIN%.patch" lman \
  atclone'./autogen.sh && ./configure --prefix=$ZPFX' make"install PREFIX=$ZPFX" atpull'%atclone' \
    tmux/tmux \
    tmux-plugins/tpm \
  lbin lman \
    sdushantha/tmpmail \
  lbin'**/rga;**/rga-*' from'gh-r' mv'rip* -> rga' \
    phiresky/ripgrep-all \
  lbin from'gh-r' atinit'export NAVI_FZF_OVERRIDES="--height=70%"' \
    denisidoro/navi \
  lbin atload'alias palette::full="ansi --color-codes" palette::codes="ansi --color-table"' \
    fidian/ansi \
  lbin atclone"./build.zsh" mv"*.*completion -> _zunit" atpull"%atclone" \
    molovo/zunit \
  lbin mv"*.*completion -> _revolver" \
    molovo/revolver \
  lbin'**/fzf-panes.tmux; **/fzfp' \
    kevinhwang91/fzf-tmux-script

# atclone'local d="$XDG_CONFIG_HOME/tmux/plugins";
# [[ ! -d "$d" ]] && mkdir -p "$d"; ln -sf %DIR% "$d/tpm"' \
# atpull'%atclone' \
#   tmux-plugins/tpm \
#  ]]] === wait'0c' - programs - sourced ===

#  === wait'0c' - programs + man === [[[
zt 0c light-mode binary lbin lman from'gh-r' for \
  atclone'mv -f **/*.zsh _bat' atpull'%atclone' \
    @sharkdp/bat \
    @sharkdp/hyperfine \
    @sharkdp/fd \
    @sharkdp/diskus \
    @sharkdp/pastel \
  atclone'mv rip*/* .' \
    BurntSushi/ripgrep \
  atclone'mv -f **/**.zsh _exa' atpull'%atclone' \
    ogham/exa \
  atclone'mv -f **/**.zsh _dog' atpull'%atclone' \
    ogham/dog \
  atclone'./just --completions zsh > _just' atpull'%atclone' \
    casey/just \
  atclone'./imdl completions zsh > _imdl' atpull'%atclone' \
    casey/intermodal \
  lbin'**/hub' extract'!' atclone'mv -f **/**.zsh* _hub' atpull'%atclone' \
    @github/hub \
  lbin'rclone/rclone' mv'rclone* -> rclone' \
  atclone'./rclone/rclone genautocomplete zsh _rclone' atpull'%atclone' \
    rclone/rclone \
  lman'*/**.1' atinit'export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"' \
    ajeetdsouza/zoxide

# lbin'**/gh' atclone'./**/gh completion --shell zsh > _gh' atpull'%atclone' \
# bpick'*linux_amd64.tar.gz' \
#   cli/cli \

#  ]]] === wait'0c' - programs + man ===


#  === wait'0c' - programs === [[[
zt 0c light-mode null for \
  lbin'sk' dl"$(grman man/man1/ -r sk)" lman atclone'cargo br' atclone"$(mv_clean sk)" atpull'%atclone' \
    lotabout/skim \
  id-as'skim_comp' multisrc'shell/{completion,key-bindings}.zsh' pick'/dev/null' \
    lotabout/skim \
  id-as'sk-tmux' lbin \
  atclone"xh --download https://raw.githubusercontent.com/lotabout/skim/master/bin/sk-tmux -o sk-tmux" \
    zdharma-continuum/null \
  lbin from'gh-r' dl"$(grman man/man1/)" lman \
    junegunn/fzf \
  id-as'fzf_comp' multisrc'shell/{completion,key-bindings}.zsh' pick'/dev/null' \
  atload"bindkey -r '\ec'; bindkey '^[c' fzf-cd-widget" \
    junegunn/fzf \
  lbin'antidot* -> antidot' from'gh-r' atclone'./**/antidot* update 1>/dev/null' \
  atpull'%atclone' \
    doron-cohen/antidot \
  lbin'xurls* -> xurls' from'gh-r' \
    @mvdan/xurls \
  lbin'q -> dq' from'gh-r' bpick'*linux*gz' \
    natesales/q \
  lbin'*/*/lax' atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' has'cargo' \
    Property404/lax \
  lbin'*/*/desed' lman dl"$(grman)" atclone'cargo br' atclone"$(mv_clean)" \
  atpull'%atclone' has'cargo' \
    SoptikHa2/desed \
  lbin'f2' from'gh-r' bpick'*linux_amd64*z' \
    ayoisaiah/f2 \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo br' \
  atclone"$(mv_clean)" atpull'%atclone' has'cargo' \
    crockeo/taskn \
  lbin atclone'make build' \
    @motemen/gore \
  lbin from'gh-r' \
    traefik/yaegi \
  lbin'bin/*' dl"$(grman man/)" lman \
    mklement0/perli \
  lbin from'gh-r' \
    koalaman/shellcheck \
  lbin'shfmt* -> shfmt' from'gh-r' \
    @mvdan/sh \
  lbin'q-* -> q' from'gh-r' \
    harelba/q \
  lbin lman make"YANKCMD='xsel -ib --trim' PREFIX=$ZPFX install" \
    mptre/yank \
  lbin'uni* -> uni' from'gh-r' \
    arp242/uni \
  lbin'dad;diana' atinit'export DIANA_DOWNLOAD_DIR="$HOME/Downloads/Aria"' \
    baskerville/diana \
  lbin has'recode' \
    Bugswriter/tuxi \
  lbin'jq-* -> jq' from'gh-r' dl"$(grman -e '1.prebuilt')" lman \
  atclone'mv jq.1* jq.1' \
    stedolan/jq \
   lbin from'gh-r' mv'yq_* -> yq' atclone'./yq shell-completion zsh > _yq' \
  atpull'%atclone' \
    mikefarah/yq \
  lbin'das* -> dasel' from'gh-r' \
    TomWright/dasel \
  lbin'yj* -> yj' from'gh-r' \
    sclevine/yj \
  lbin'b**/r**/crex' atclone'chmod +x build.sh; ./build.sh -r;' \
    octobanana/crex \
  lbin from'gh-r' \
    pemistahl/grex \
  id-as'bisqwit/regex-opt' lbin atclone'xh --download https://bisqwit.iki.fi/src/arch/regex-opt-1.2.4.tar.gz' \
  atclone'ziextract --move --auto regex-*.tar.gz' make'all' \
    zdharma-continuum/null \
  lbin from'gh-r' \
    muesli/duf \
  lbin patch"${pchf}/%PLUGIN%.patch" make"PREFIX=$ZPFX install" reset \
  atpull'%atclone' atdelete"PREFIX=$ZPFX make uninstall"  \
    zdharma-continuum/zshelldoc \
  lbin from'gh-r' bpick'*linux_amd*gz' \
  atload"source $ZPFX/share/pet/pet_atload.zsh" \
    knqyf263/pet \
  atclone'ln -sf %DIR% "$ZPFX/libexec/goenv"' atpull'%atclone' \
  atinit'export GOENV_ROOT="$ZPFX/libexec/goenv"' \
    syndbg/goenv

# eval"atuin init zsh | sed 's/bindkey .*\^\[.*$//g'"
#   greymd/teip

# === Testing [[[
zt 0c light-mode for \
  pipx'jrnl' id-as'jrnl' \
    zdharma-continuum/null

# gem'!kramdown' id-as'kramdown' null \
#   zdharma-continuum/null \
# binary cargo'!viu' id-as"$(id_as viu)" \
#   zdharma-continuum/null
# === Testing ]]]

# == rust [[[
zt 0c light-mode null check'!%PLUGIN%' for \
  lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
    miserlou/loop \
  lbin'ff* -> ffsend' from'gh-r' \
    timvisee/ffsend \
  has'!pacaptr' lbin from'gh-r' \
    rami3l/pacaptr \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo br' atclone"$(mv_clean)" \
    XAMPPRocky/tokei \
  lbin from'gh-r' \
    ms-jpq/sad \
  lbin from'gh-r' \
    ducaale/xh \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    pkolaczk/fclones \
  lbin from'gh-r' \
    itchyny/mmv \
  lbin atclone'cargo br' \
  atclone"./atuin gen-completions --shell zsh --out-dir $GENCOMP_DIR" atclone"$(mv_clean)" \
  atpull'%atclone' eval"atuin init zsh | sed 's/bindkey .*\^\[.*$//g'" \
    ellie/atuin \
  lbin'* -> sd' from'gh-r' \
    chmln/sd \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atpull'%atclone' \
    lmburns/hoard \
  lbin'ruplacer-* -> ruplacer' from'gh-r' atinit'alias rup="ruplacer"' \
    your-tools/ruplacer \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo br' \
  atclone"$(mv_clean rgr)" lman \
    acheronfail/repgrep \
  lbin'* -> renamer' from'gh-r' \
    adriangoransson/renamer \
  lbin atclone'cargo br' atclone"$(mv_clean tldr)" atclone"mv -f **/zsh_* _tldr" \
  atpull'%atclone' reset \
    dbrgn/tealdeer \
  lbin'e-* -> pueue' lbin'd-* -> pueued' from'gh-r' \
  bpick'*ue-*-x86_64' bpick'*ued-*-x86_64' \
    Nukesor/pueue \
  lbin from'gh-r' bpick'*linux.zip' \
    @dalance/procs \
  lbin atclone"cargo br" atclone"$(mv_clean)" atpull'%atclone' \
    imsnif/bandwhich \
  lbin atclone"cargo br" atclone"$(mv_clean)" atpull'%atclone' \
    theryangeary/choose \
  lbin atclone'cargo br' atclone"$(mv_clean dua)" atpull'%atclone' \
    Byron/dua-cli \
  lbin atclone'cargo br' atclone"$(mv_clean lolcate)" \
  atpull'%atclone' atload'alias le=lolcate' \
    lmburns/lolcate-rs \
  lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
  atload'export FW_CONFIG_DIR="$XDG_CONFIG_HOME/fw"; alias wo="workon"' \
    brocode/fw \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    WindSoilder/hors \
  lbin from'gh-r' \
    samtay/so \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' reset \
  atclone'./podcast completion > _podcast' \
    njaremko/podcast \
  lbin from'gh-r' \
    rcoh/angle-grinder \
  lbin atclone'cargo br' atclone"$(mv_clean hm)" atpull'%atclone' \
    hlmtre/homemaker \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    rdmitr/inventorize \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' reset \
    magiclen/xcompress \
  lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
  atclone"./rip completions --shell zsh > _rip" \
    lmburns/rip \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  eval'command sauce --shell zsh shell init' \
    dancardin/sauce \
  lbin atclone'cargo br' atclone"$(mv_clean petname)" atpull'%atclone' \
    allenap/rust-petname \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    neosmart/rewrite \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atclone"./rualdi completions shell zsh > _rualdi" \
  atload'alias ru="rualdi"' eval'rualdi init zsh --cmd k' \
    lmburns/rualdi \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atload'alias orgr="organize-rt"' \
    lmburns/organize-rt \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atload'alias touch="feel"' \
    lmburns/feel \
  lbin'parallel -> par' atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    lmburns/parallel \
  lbin atclone'cargo br --features=backend-gpgme' atpull'%atclone' \
  atclone"$(mv_clean)" atclone'./prs internal completions zsh' \
    lmburns/prs \
  lbin atclone'cargo br' atclone"$(mv_clean tidy-viewer)" atpull'%atclone' \
  atload"alias tv='tidy-viewer'" \
    alexhallam/tv \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    evansmurithi/cloak \
  lbin from'gh-r' \
    lotabout/rargs

# lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
# atclone"emplace init zsh | tail -n +20 > _emplace" \
# eval'emplace init zsh | head -n 20' atload"alias em='emplace'" \
# atload'export EMPLACE_CONFIG="$XDG_CONFIG_HOME/emplace/emplace.toml"' \
#   tversteeg/emplace

# === rust extensions === [[[
zt 0c light-mode null lbin \
  atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" for \
    fornwall/rust-script \
    reitermarkus/cargo-eval \
    fanzeyi/cargo-play \
    iamsauravsharma/cargo-trim \
    andrewradev/cargo-local \
    celeo/cargo-nav \
    g-k/cargo-show \
    mre/cargo-inspect \
    sminez/roc \
    MordechaiHadad/bob

# razrfalcon/cargo-bloat \
# matthiaskrgr/cargo-cache \

# has'!cargo-deps' lbin from'gh-r' \
#   est31/cargo-udeps \
# lbin'tar*/rel*/cargo-{rm,add,upgrade}' \
# atclone'cargo br' atpull'%atclone' \
#   killercup/cargo-edit \
# lbin from'gh-r' \
#   cargo-generate/cargo-generate \
# lbin'{cargo-make,makers}' atclone'cargo br' atpull'%atclone' \
# atclone"command mv -f tar*/rel*/{cargo-make,makers} . && cargo clean" \
# atload'export CARGO_MAKE_HOME="$XDG_CONFIG_HOME/cargo-make"' \
# atload'alias ncmake="$EDITOR $CARGO_MAKE_HOME/Makefile.toml"' \
# atload'alias cm="makers --makefile $CARGO_MAKE_HOME/Makefile.toml"' \
#   sagiegurari/cargo-make \

zt 0c light-mode null for \
  lbin'* -> cargo-temp' from'gh-r' \
    yozhgoor/cargo-temp \
  lbin'tar*/rel*/evcxr' atclone'cargo br' atpull'%atclone' \
    google/evcxr \
  lbin atclone'cargo br' atclone"$(mv_clean unused-features)" atpull'%atclone' \
    TimonPost/cargo-unused-features \
  id-as'sr-ht/rusty-man' lbin'rusty-man' atclone'command git clone https://git.sr.ht/~ireas/rusty-man' \
  atclone'command mv -vf rusty-man/* . && rm -rf rusty-man' \
  atclone'cargo br && cargo doc' atclone"command mv -f tar*/rel*/rusty-man ." atpull'%atclone' \
  atinit'alias rman="rusty-man" rmand="handlr open https://git.sr.ht/~ireas/rusty-man"' \
    zdharma-continuum/null

# Canop/bacon
# ]]] == rust extensions
# ]]] == rust

# === tui specific block === [[[
zt 0c light-mode null for \
  lbin from'gh-r' bpick'*linux*.tar.gz' \
    wagoodman/dive \
  lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
    orhun/gpg-tui \
  lbin from'gh-r' ver'nightly' \
    ClementTsang/bottom \
  lbin dl"$(grman)" lman \
  atclone'CGO_ENABLED=0 go build -ldflags="-s -w" .' atpull'%atclone' \
    gokcehan/lf \
  lbin from'gh-r' \
  atinit'export XPLR_BOOKMARK_FILE="$XDG_CONFIG_HOME/xplr/bookmarks"' \
    sayanarijit/xplr \
  lbin from'gh-r' atload'alias ld="lazydocker"' \
    jesseduffield/lazydocker \
  lbin from'gh-r' atload'alias lnpm="lazynpm"' \
    jesseduffield/lazynpm
# ]]] === tui specifi block ===

# kdheepak/taskwarrior-tui

# === git specific block === [[[
zt 0c light-mode null for \
  lbin from'gh-r' \
    isacikgoz/gitbatch \
  lbin from'gh-r' atload'alias lg="lazygit"' \
    jesseduffield/lazygit \
  lbin from'gh-r' blockf atload'export GHQ_ROOT="$HOME/ghq"' \
    x-motemen/ghq \
  lbin from'gh-r' \
    Songmu/ghg \
  lbin'tig' atclone'./autogen.sh; ./configure --prefix="$ZPFX"; mv -f **/**.zsh _tig' \
  make'install' atpull'%atclone' mv"_tig -> $GENCOMP_DIR" reset \
    jonas/tig \
  lbin'**/delta' from'gh-r' patch"${pchf}/%PLUGIN%.patch" \
    dandavison/delta \
  lbin from'gh-r' \
    extrawurst/gitui \
  lbin from'gh-r' lman \
    rhysd/git-brws \
  lbin'tar*/rel*/mgit' atclone'cargo br' atpull'%atclone' \
    koozz/mgit
# ]]] === git specific block ===

# tshepang/mrh
# cosmos72/gomacro
# gruntwork-io/git-xargs

#  ]]] === wait'0c' - programs ===

#  === snippet block === [[[
zt light-mode is-snippet for \
  atload'zle -N RG' \
    $ZDOTDIR/csnippets/*.zsh
#  ]]] === snippet block ===
# ]]] == zinit closing ===

# === powerlevel10k === [[[
[[ $MYPROMPT == p10k ]] && {
  () {
    local f; f="${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
    [[ -r "$f" ]] && builtin source "$f"
  }
}
# ]]]

# === zsh keybindings === [[[
stty intr '^C'
stty susp '^Z'
stty stop undef
stty discard undef <$TTY >$TTY
# Load when they are needed
zmodload zsh/zprof             # ztodo
zmodload zsh/attr              # extended attributes
zmodload -mF zsh/files b:zf_\* # zf_ln zf_rm etc
autoload -Uz zmv zcalc zargs zed relative zrecompile # sticky-note
alias fned="zed -f"
alias zmv='noglob zmv -v'  zcp='noglob zmv -Cv' zmvn='noglob zmv -W'
alias zln='noglob zmv -Lv' zlns='noglob zmv -o "-s" -Lv'

# autoload -Uz sticky-note regexp-replace

[[ -v aliases[run-help] ]] && unalias run-help
autoload +X -Uz run-help
autoload -Uz $^fpath/run-help-^*.zwc(N:t)

# zmodload -F zsh/parameter p:functions_source
# autoload -Uz $functions_source[run-help]-*~*.zwc
# ]]]

# === Helper Functions === [[[
# Shorten command length
function max_history_len() {
  if (( $#1 > 240 )) {
    return 2
  }

  return 0
}

# Function that is ran on each command
function zshaddhistory() {
  emulate -L zsh
  # whence ${${(z)1}[1]} >| /dev/null || return 1 # doesn't add setting arrays
  [[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
}

add-zsh-hook zshaddhistory max_history_len

# Based on directory history
function _zsh_autosuggest_strategy_dir_history() {
  emulate -L zsh -o extended_glob
  if $_per_directory_history_is_global && [[ -r "$_per_directory_history_path" ]]; then
    local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
    local pattern="$prefix*"
    if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
      pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
    fi
    [[ "${dir_history[(r)$pattern]}" != "$prefix" ]] && \
      typeset -g suggestion="${dir_history[(r)$pattern]}"
  fi
}

# Same as above, but not directory specific
function _zsh_autosuggest_strategy_custom_history() {
  emulate -L zsh -o extended_glob
  local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
  local pattern="$prefix*"
  if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
    pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
  fi
  [[ "${history[(r)$pattern]}" != "$prefix" ]] && \
    typeset -g suggestion="${history[(r)$pattern]}"
}

# Histdb is good, though, the above allows for toggling on and off

# Return the latest used command in the current directory
# Else, find most recent command
function _zsh_autosuggest_strategy_histdb_top_here() {
    (( $+functions[_histdb_query] )) || return
#   local query="
# SELECT commands.argv
# FROM   history
#   LEFT JOIN commands
#     ON history.command_id = commands.rowid
#   LEFT JOIN places
#     ON history.place_id = places.rowid
# WHERE places.dir LIKE '$(sql_escape $PWD)%'
#     AND commands.argv LIKE '$(sql_escape $1)%'
# GROUP BY commands.argv
# ORDER BY count(*) desc
# LIMIT    1
# "

  local query="
SELECT commands.argv
FROM   history
  LEFT JOIN commands
    ON history.command_id = commands.rowid
  LEFT JOIN places
    ON history.place_id = places.rowid
WHERE    commands.argv LIKE '$(sql_escape $1)%'
-- GROUP BY commands.argv, places.dir
ORDER BY places.dir != '$(sql_escape $PWD)',
  history.start_time DESC
LIMIT 1
"

# count(*) desc

# Is this complexity necessary?
#    local query="
# SELECT commands.argv
# FROM   history
#   LEFT JOIN commands ON history.command_id = commands.rowid
#   LEFT JOIN places   ON history.place_id   = places.rowid
# WHERE  places.dir LIKE
#   CASE WHEN exists(
#       SELECT commands.argv
#       FROM   history
#         LEFT JOIN commands ON history.command_id = commands.rowid
#         LEFT JOIN places   ON history.place_id   = places.rowid
#       WHERE  places.dir LIKE '$(sql_escape $PWD)%'
#         AND commands.argv LIKE '$(sql_escape $1)%'
#     ) THEN '$(sql_escape $PWD)%'
#     ELSE '%'
#   END
#   AND commands.argv LIKE '$(sql_escape $1)%'
# GROUP BY  commands.argv
# ORDER BY  places.dir LIKE '$(sql_escape $PWD)%' DESC,
#   history.start_time DESC
# LIMIT 1
# "

  typeset -g suggestion=$(_histdb_query "$query")
}
# ]]]

# === paths (GNU) === [[[
[[ -z ${path[(re)$HOME/.local/bin]} ]] && path=( "$HOME/.local/bin" "${path[@]}" )
[[ -z ${path[(re)/usr/local/sbin]} ]]  && path=( "/usr/local/sbin"  "${path[@]}" )


# hash -d git=$HOME/projects/github
# hash -d opt=$HOME/opt
hash -d pro=$HOME/projects
hash -d ghq=$HOME/ghq
hash -d config=$XDG_CONFIG_HOME

# cdpath=( $HOME/{projects/github,.config} )
# cdpath=( $XDG_CONFIG_HOME )

manpath=(
  $XDG_DATA_HOME/man
  $NPM_PACKAGES/share/man
  "${manpath[@]}"
)

# $HOME/.poetry/bin(N-/)
path=(
  $HOME/mybin
  $HOME/texlive/2021/bin/x86_64-linux
  $HOME/mybin/linux
  $HOME/bin(N-/)
  $HOME/.ghg/bin(N-/)
  $PYENV_ROOT/{shims,bin}(N-/)
  $GOENV_ROOT/{shims,bin}(N-/)
  $CARGO_HOME/bin(N-/)
  $RUSTUP_HOME/toolchains/*/bin(N-/)
  $XDG_DATA_HOME/gem/bin(N-/)
  $XDG_DATA_HOME/luarocks/bin(N-/)
  $XDG_DATA_HOME/neovim-nightly/bin(N-/)
  $XDG_DATA_HOME/neovim/bin(N-/)
  $GEM_HOME/bin(N-/)
  $NPM_PACKAGES/bin(N-/)
  /usr/bin                   # add again to be ahead of /bin
  /usr/lib/w3m
  $(stack path --stack-root)/programs/x86_64-linux/ghc-tinfo6-8.10.7/bin
  "${path[@]}"
)
# ]]]

#===== completions ===== [[[
zt 0c light-mode as'completion' for \
  id-as'poetry_comp' atclone='poetry completions zsh > _poetry' \
  atpull'%atclone' has'poetry' \
    zdharma-continuum/null \
  id-as'rust_comp' atclone'rustup completions zsh rustup > _rustup' \
  atclone'rustup completions zsh cargo > _cargo' \
  atpull='%atclone' has'rustup' \
    zdharma-continuum/null \
  id-as'pueue_comp' atclone'pueue completions zsh "${GENCOMP_DIR}"' \
  atpull'%atclone' has'pueue' \
    zdharma-continuum/null
# ]]] ===== completions =====

#===== variables ===== [[[
zt 0c light-mode run-atpull nocompile'!' for \
  id-as'pipx_comp' has'pipx' nocd eval"register-python-argcomplete pipx" \
  atload'zicdreplay -q' \
    zdharma-continuum/null \
  id-as'pyenv_init' has'pyenv' nocd eval'pyenv init - zsh' \
    zdharma-continuum/null \
  id-as'pipenv_comp' has'pipenv' nocd eval'_PIPENV_COMPLETE=zsh_source pipenv' \
    zdharma-continuum/null \
  id-as'navi_comp' has'navi' nocd eval'navi widget zsh' \
    zdharma-continuum/null \
  id-as'go_env' has'goenv' nocd eval'goenv init -' \
    zdharma-continuum/null \
  id-as'zoxide_init' has'zoxide' nocd eval'zoxide init --no-cmd --hook prompt zsh' \
  atload'alias o=__zoxide_z z=__zoxide_zi' \
    zdharma-continuum/null \
  id-as'abra_hook' has'abra' nocd eval'abra hook zsh' \
    zdharma-continuum/null \
  id-as'keychain_init' has'keychain' nocd \
  eval'keychain --noask --agents ssh -q --inherit any --eval id_rsa \
    && keychain --agents ssh -q --inherit any --eval git \
    && keychain --agents gpg -q --eval 0xC011CBEF6628B679' \
      zdharma-continuum/null

# id-as'antidot_conf' has'antidot' nocd eval'antidot init' \
#   zdharma-continuum/null \
# id-as'ruby_env' has'rbenv' nocd eval'rbenv init - | sed "s|source .*|source $ZDOTDIR/extra/rbenv.zsh|"' \
#   zdharma-continuum/null \

zt 0c light-mode for \
  id-as'Cleanup' nocd atinit'unset -f zt grman mv_clean has id_as;
  _zsh_autosuggest_bind_widgets' \
    zdharma-continuum/null

zflai-msg "[zshrc]: Zinit block took ${(M)$(( (EPOCHREALTIME - zstart) * 1000 ))#*.?} ms"

# `GOROOT/GOPATH` needs to be added after `goenv init`
path=( $GOROOT/bin(N-/) "${path[@]}" $GOPATH/bin(N-/) )

# LS_COLORS defined before zstyle
typeset -gx LS_COLORS="$(vivid -d $ZDOTDIR/zsh.d/vivid/filetypes.yml generate $ZDOTDIR/zsh.d/vivid/kimbie.yml)"
typeset -gx {ZLS_COLORS,TREE_COLORS}="$LS_COLORS"
typeset -gx JQ_COLORS="1;30:0;39:1;36:1;39:0;35:1;32:1;32:1"

typeset -gx GPG_TTY=$TTY
typeset -gx PDFVIEWER='zathura'                                                   # texdoc pdfviewer
typeset -gx FORGIT_LOG_FORMAT="%C(red)%C(bold)%h%C(reset) %Cblue%an%Creset: %s%Creset%C(yellow)%d%Creset %Cgreen(%cr)%Creset"
typeset -gx RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
#
# typeset -gx _ZO_ECHO=1
typeset -gx ZSH_AUTOSUGGEST_USE_ASYNC=set
typeset -gx ZSH_AUTOSUGGEST_MANUAL_REBIND=set
typeset -gx ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
typeset -gx ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c100,))' # no 100+ char
typeset -gx ZSH_AUTOSUGGEST_COMPLETION_IGNORE="[[:space:]]*" # no leading space
typeset -gx ZSH_AUTOSUGGEST_STRATEGY=(histdb_top_here dir_history custom_history match_prev_cmd completion)
typeset -gx HISTORY_SUBSTRING_SEARCH_FUZZY=set
typeset -gx HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=set
typeset -gx AUTOPAIR_CTRL_BKSPC_WIDGET=".backward-kill-word"
typeset -ga chwpd_dir_history_funcs=( "_dircycle_update_cycled" ".zinit-cd" )
typeset -g PER_DIRECTORY_HISTORY_BASE="${ZPFX}/share/per-directory-history"
typeset -gx NQDIR="/tmp/nq" FNQ_DIR="$HOME/tmp/fnq"
typeset -gx FZFGIT_BACKUP="${XDG_DATA_HOME}/gitback"
typeset -gx FZFGIT_DEFAULT_OPTS="--preview-window=':nohidden,right:65%:wrap'"

typeset -gx PASSWORD_STORE_ENABLE_EXTENSIONS='true'
# ]]]

# === fzf === [[[
# ❱❯❮

# I have custom colors for 1-53. They're set in alacritty
FZF_COLORS="\
--color=fg:42,fg+:53,hl:22:bold,hl+:23,bg+:-1
--color=query:51,info:43:bold,border:33,separator:51,scrollbar:51
--color=label:27,preview-label:27
--color=pointer:17,marker:19,spinner:13
--color=header:12,prompt:18"

declare -a SKIM_COLORS=(
  "fg:42" "fg+:53" "hl:22" "hl+:#689d6a" "bg+:-1" "marker:#fe8019"
  "spinner:#b8bb26" "header:#cc241d" "prompt:#fb4934"
)

FZF_HISTFILE="$XDG_CACHE_HOME/fzf/history"
FZF_FILE_PREVIEW="([[ -f {} ]] && (bkt -- bat --style=numbers --color=always -- {}))"
FZF_DIR_PREVIEW="([[ -d {} ]] && (bkt -- exa -T {} | less))"
FZF_BIN_PREVIEW="([[ \$(file --mime-type -b {}) = *binary* ]] && (echo {} is a binary file))"

export FZF_HISTFILE FZF_FILE_PREVIEW FZF_DIR_PREVIEW FZF_BIN_PREVIEW

export FZF_DEFAULT_OPTS="
--prompt='❱ '
--pointer='》'
--marker='▍'
--cycle
$FZF_COLORS
--reverse
--ansi
--multi
--border
--height=80%
--tabstop=4
--history=$FZF_HISTFILE
--jump-labels='abcdefghijklmnopqrstuvwxyz'
--preview-window=':hidden,right:60%:border-double'
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='alt-a:toggle-all'
--bind='ctrl-alt-a:toggle-all+accept'
--bind='ctrl-s:toggle-sort'
--bind='alt-,:first'
--bind='alt-.:last'
--bind='<:beginning-of-line'
--bind='>:end-of-line'
--bind='page-up:prev-history'
--bind='page-down:next-history'
--bind='alt-(:prev-history'
--bind='alt-):next-history'
--bind='alt-{:prev-selected'
--bind='alt-}:next-selected'
--bind='ctrl-/:jump'
--bind='esc:abort'
--bind='ctrl-c:abort'
--bind='ctrl-q:abort'
--bind='ctrl-g:cancel'
--bind='alt-x:unix-line-discard'
--bind='alt-c:unix-word-rubout'
--bind='ctrl-r:clear-selection'
--bind='alt-d:kill-word'
--bind='?:toggle-preview'
--bind='alt-]:change-preview-window(70%|45%,down,border-top|45%,up,border-bottom|)+show-preview'
--bind='alt-w:toggle-preview-wrap'
--bind='alt-p:preview-up'
--bind='alt-n:preview-down'
--bind='ctrl-alt-p:preview-page-up'
--bind='ctrl-alt-n:preview-page-down'
--bind='shift-up:preview-page-up'
--bind='shift-down:preview-page-down'
--bind='ctrl-u:half-page-up'
--bind='ctrl-d:half-page-down'
--bind='ctrl-alt-u:page-up'
--bind='ctrl-alt-d:page-down'
--bind='alt-o:replace-query+print-query'
--bind='ctrl-e:become($EDITOR {+})'
--bind='ctrl-b:become(bat --paging=always -f {+})'
--bind='ctrl-y:execute-silent(xsel --trim -b <<< {+})'
--bind='ctrl-]:preview(bat --color=always -l bash \"$XDG_DATA_HOME/gkeys/fzf\")'
--bind='alt-?:unbind(?)'
--bind='alt-<:unbind(<)'
--bind='alt->:unbind(>)'
--bind='change:first'"

# --bind=\"alt-':beginning-of-line\"
# --bind='alt-\":end-of-line'

SKIM_DEFAULT_OPTIONS="
--prompt '❱ '
--cmd-prompt 'c❱ '
--cycle
--reverse --height 80% --ansi --inline-info --multi --border
--preview-window=':hidden,right:60%'
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='?:toggle-preview,alt-w:toggle-preview-wrap'
--bind='alt-a:select-all,ctrl-r:toggle-all'
--bind='ctrl-b:execute(bat --paging=always -f {+})'
--bind=\"ctrl-y:execute-silent(ruby -e 'puts ARGV' {+} | xsel --trim -b)+abort\"
--bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--bind='ctrl-s:toggle-sort'
--bind='alt-p:preview-up,alt-n:preview-down'
--bind='ctrl-k:preview-up,ctrl-j:preview-down'
--bind='ctrl-u:half-page-up,ctrl-d:half-page-down'"
# SKIM_DEFAULT_OPTIONS=${(F)${(M)${(@f)FZF_DEFAULT_OPTS}/(#m)*info*/${${(@s. .)MATCH}:#--info*}}:#--(bind=change:top|pointer*|marker*|color*)}
# SKIM_DEFAULT_OPTIONS+=$'\n'"--cmd-prompt=➤"
# SKIM_DEFAULT_OPTIONS+=$'\n'"--bind='ctrl-p:preview-up,ctrl-n:preview-down'"
SKIM_DEFAULT_OPTIONS+=$'\n'"--color=${(j:,:)SKIM_COLORS}"
export SKIM_DEFAULT_OPTIONS

export FZF_ALT_E_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_E_OPTS="
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--preview-window default:right:60%"
export FZF_CTRL_R_OPTS="\
--preview='echo {}'
--preview-window='down:2:wrap'
--bind='ctrl-y:execute-silent(echo -n {2..} | xclip -r -selection c)+abort'
--header='Press CTRL-Y to copy command into clipboard'
--exact
--expect=ctrl-x"
export SKIM_CTRL_R_OPTS="\
--preview='echo {}'
--preview-window=':hidden,down:2:wrap'
--bind='ctrl-y:execute-silent(echo -n {2..} | xclip -r -selection c)+abort'
--header='Press CTRL-Y to copy command into clipboard'
--exact
--expect=ctrl-x"
export SKIM_DEFAULT_COMMAND='fd --no-ignore --hidden --follow --exclude ".git"'
export FZF_DEFAULT_COMMAND="(git ls-tree -r --name-only HEAD | lscolors ||
         rg --files --no-ignore --hidden -g '!{.git,node_modules,target}/*') 2> /dev/null"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export SKIM_COMPLETION_TRIGGER='~~'
export FZF_COMPLETION_TRIGGER='**'
(( $+commands[fd] )) && {
    _fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1" }
    _fzf_compgen_dir()  { fd --type d --hidden --follow --exclude ".git" . "$1" }
}

export FZF_ALT_C_COMMAND="fd --no-ignore --hidden --follow --strip-cwd-prefix --exclude '.git' --type d -d 1 | lscolors"
export SKIM_ALT_C_COMMAND="$FZF_ALT_C_COMMAND"
export FZF_ALT_C_OPTS="
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--preview-window default:right:60%
"
export FORGIT_FZF_DEFAULT_OPTS="--preview-window='right:60%:nohidden' --bind='ctrl-e:become(nvim {2})'"
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview='(exa -T {2} | less) 2>/dev/null | head -200' --scheme=path"

alias db='dotbare'
export DOTBARE_DIR="${XDG_DATA_HOME}/dotfiles"
export DOTBARE_TREE="$HOME"
export DOTBARE_BACKUP="${XDG_DATA_HOME}/dotbare-b"
export DOTBARE_FZF_DEFAULT_OPTS="
$FZF_DEFAULT_OPTS
--header='M-A:select-all, C-B:pager, C-Y:copy, C-E:nvim'
--preview-window=:nohidden
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\""
# ]]]

# == sourcing === [[[
zt 0b light-mode null id-as for \
  multisrc="$ZDOTDIR/zsh.d/{aliases,keybindings,lficons,functions,tmux,git-token}.zsh" \
    zdharma-continuum/null \
  atinit'
  export PERLBREW_ROOT="${XDG_DATA_HOME}/perl5/perlbrew";
  export PERLBREW_HOME="${XDG_DATA_HOME}/perl5/perlbrew-h";
  export PERL_CPANM_HOME="${XDG_DATA_HOME}/perl5/cpanm"' \
  atload'local x="$PERLBREW_ROOT/etc/bashrc"; [ -f "$x" ] && source "$x"' \
    zdharma-continuum/null \
  atinit'
  export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
  export NVM_COMPLETION=true' \
  atload'local x="$NVM_DIR/nvm.sh"; [ -s "$x" ] && source "$x"' \
    zdharma-continuum/null \
  atload'export FAST_WORK_DIR=XDG;
  fast-theme XDG:kimbox.ini &>/dev/null' \
    zdharma-continuum/null

# recache keychain if older than GPG cache time or first login
# local first=${${${(M)${(%):-%l}:#*01}:+1}:-0}
[[ -f "$ZINIT[PLUGINS_DIR]/keychain_init"/eval*~*.zwc(#qN.ms+45000) ]] || [[ "$TTY" = /dev/tty1 ]] && {
  zinit recache keychain_init
  local msg="Keychain recached"
  local len="${(l:(COLUMNS-$#msg-4)/2::=:):-}"
  print -Pr "%F{13}${(l:COLUMNS::=:):-}%f"
  print -Pr "%F{12}$len> %B$msg%b <$len%f"
  print -Pr "%F{13}${(l:COLUMNS::=:):-}%f"
  zle && zle reset-prompt
}
# ]]]

[[ -z ${path[(re)$XDG_BIN_HOME]} && -d "$XDG_BIN_HOME" ]] && path=( "$XDG_BIN_HOME" "${path[@]}")

path=( "${ZPFX}/bin" "${path[@]}" )                # add back to be beginning
path=( "${path[@]:#}" )                            # remove empties (if any)
path=( "${(u)path[@]}" )                           # remove duplicates; goenv adds twice?

zflai-msg "[zshrc]: File took ${(M)$(( SECONDS * 1000 ))#*.?} ms"
zflai-zprof

# vim: set sw=0 ts=2 sts=2 et ft=zsh
