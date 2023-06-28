############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# === general settings === [[[
0="${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}"
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

typeset -g DIRSTACKSIZE=20
typeset -ga history_ignore=(youtube-dl you-get yt-dlp history exit)
typeset -g SAVEHIST=$(( 10 ** 7 ))  # 10_000_000
typeset -g HISTSIZE=$(( 1.2 * SAVEHIST ))
typeset -g HISTFILE="${XDG_CACHE_HOME}/zsh/zsh_history"
typeset -g HIST_STAMPS="yyyy-mm-dd"
typeset -g LISTMAX=50                         # Size of asking history
typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)' # Don't eat space with | with tabs
typeset -g ZLE_SPACE_SUFFIX_CHARS=$'&|'
typeset -g MAILCHECK=0                 # Don't check for mail
typeset -g KEYTIMEOUT=25               # Key action time
typeset -g FCEDIT=$EDITOR              # History editor
typeset -g READNULLCMD=$PAGER          # Read contents of file with <file
typeset -g TMPPREFIX="${TMPDIR%/}/zsh" # Temporary file prefix for zsh
typeset -g PROMPT_EOL_MARK="%F{14}⏎%f" # Show non-newline ending
# setopt no_prompt_cr                    # Can turn off above

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

setopt no_global_rcs          # startup files in /etc/ won't be ran

# setopt hist_ignore_all_dups   # replace duplicate commands in history file
# setopt hist_ignore_dups       # do not enter command lines into the history list if they are duplicates
setopt hist_ignore_space      # don't add if starts with space
setopt hist_reduce_blanks     # remove superfluous blanks from each command
setopt hist_expire_dups_first # if the internal history needs to be trimmed, trim oldest
setopt hist_fcntl_lock        # use fcntl to lock hist file
setopt hist_subst_pattern     # allow :s/:& to use patterns instead of strings
setopt extended_history       # add beginning time, and duration to history
setopt append_history         # all zsh sessions append to history, not replace
setopt share_history          # imports commands and appends, can't be used with inc_append_history
setopt no_hist_no_functions   # don't remove function defs from history
# setopt inc_append_history # append to history file immediately, not when shell exits

setopt auto_cd             # if command name is a dir, cd to it
setopt auto_pushd          # cd pushes old dir onto dirstack
setopt pushd_ignore_dups   # don't push dupes onto dirstack
setopt pushd_minus         # inverse meaning of '-' and '+'
setopt pushd_silent        # don't print dirstack after 'pushd' / 'popd'
setopt cd_silent           # don't print dirstack after 'cd'
setopt cdable_vars         # if item isn't a dir, try to expand as if it started with '~'
# setopt chase_dots          # if path segment has '..' within it, resolve it if it's a symlink

# setopt case_match        # when using =~ make expression sensitive to case
setopt rematch_pcre      # when using =~ use PCRE regex
setopt case_paths        # nocaseglob + casepaths treats only path components containing glob chars as insensitive
setopt no_case_glob      # case insensitive globbing
setopt extended_glob     # extension of glob patterns
setopt glob_complete     # generate glob matches as completions
setopt glob_dots         # do not require leading '.' for dotfiles
setopt glob_star_short   # ** == **/*      *** == ***/*
setopt numeric_glob_sort # sort globs numerically
# setopt glob_assign       # expand globs on RHS of assignment
# setopt glob_subst        # results from param exp are eligible for filename generation
# setopt magicequalsubst   # # ~ substitution and tab completion after a = (for --x=filename args)

setopt recexact         # if a word matches exactly, accept it even if ambiguous
setopt complete_in_word # allow completions in middle of word
setopt always_to_end    # cursor moves to end of word if completion is executed
setopt auto_menu        # automatically use menu completion (non-fzf-tab)
setopt menu_complete    # insert first match from menu if ambiguous (non-fzf-tab)
setopt list_types       # show type of file with indicator at end
setopt list_packed      # completions don't have to be equally spaced

# setopt hash_dirs     # when command is completed hash it and all in the dir
# setopt hash_list_all # when a completion is attempted, hash it first
setopt hash_cmds     # save location of command preventing path search
setopt correct       # try to correct mistakes

setopt prompt_subst         # allow substitution in prompt (p10k?)
setopt rc_quotes            # allow '' inside '' to indicate a single '
setopt no_rm_star_silent    # query the user before executing `rm *' or `rm path/*'
setopt interactive_comments # allow comments in history
setopt unset                # don't error out when unset parameters are used
setopt long_list_jobs       # list jobs in long format by default
setopt notify               # report status of jobs immediately
setopt short_loops          # allow short forms of for, repeat, select, if, function
# setopt ksh_option_print    # print all options
# setopt brace_ccl           # expand in braces, which would not otherwise, into a sorted list

setopt c_bases              # 0xFF instead of 16#FF
setopt c_precedences        # use precendence of operators found in C
setopt octal_zeroes         # 077 instead of 8#77
setopt multios              # perform multiple implicit tees and cats with redirection

setopt csh_null_glob   # don't report if a pattern has no matches unless all do
# setopt no_nomatch      # don't print an error if pattern doesn't match
# setopt no_clobber      # don't overwrite files without >! >|
setopt no_flow_control # don't output flow control chars (^S/^Q)
setopt no_hup          # don't send HUP to jobs when shell exits
setopt no_beep         # don't beep on error
setopt no_mail_warning # don't print mail warning

local null="zdharma-continuum/null"
declare -gx ABSD=${${(M)OSTYPE:#*(darwin|bsd)*}:+1}
declare -gx ZINIT_HOME="${0:h}/zinit"
declare -gx GENCOMP_DIR="${0:h}/completions"
declare -gx GENCOMPL_FPATH="${0:h}/completions"

declare -gxA Plugs

declare -gAH Zkeymaps_nvo=()
declare -gAH Zkeymaps_n=()
declare -gAH Zkeymaps_v=()
declare -gAH Zkeymaps_o=()
declare -gAH Zkeymaps_i=()

# NOTE: when zsh 5.9.1 comes out, use typeset -n (ptr ref)
# print -- ${${(AP)Zkms[o]}[C-r]}
# print -- ${${(P)${Zkms[o]}}[C-r]}
# : ${${(AAP)Zkms[o]}[C-r]::=val} # FIX:
# : ${(AAP)Zkms[o][C-r]::=val} # FIX:
# : ${(AAP)=Zkms[o]::=${(@Pkv)Zkms[o]} "mode=vicmd C-r" func}
declare -gxA Zkms=(
  nvo Zkeymaps_nvo
  n   Zkeymaps_n
  v   Zkeymaps_v
  o   Zkeymaps_o
  i   Zkeymaps_i
)
declare -gxA Zkeymaps=(
  # nvo Zkeymaps_nvo
  # n   Zkeymaps_n
  # v   Zkeymaps_v
  # o   Zkeymaps_o
  # i   Zkeymaps_i
)

local -a Zinfo_FnDirs=(hooks lib utils wrap widgets zonly lf)

# Can be used like: ${${(P)Zinfo[dirs]}[cache]}
declare -gA Zinfo_dirs=(
    home   $ZDOTDIR
    rc     $ZRCDIR
    data   $ZDATADIR
    cache  $ZCACHEDIR
    patch  ${0:h}/patches
    theme  ${0:h}/themes
    plug   ${0:h}/plugins
    snip   ${0:h}/snippets
    func   ${0:h}/functions
    fn_t   Zinfo_FnDirs
)
declare -gxA Zinfo=(
    patchd  ${0:h}/patches
    themed  ${0:h}/themes
    plugd   ${0:h}/plugins
    maps    Zkeymaps
    dirs    Zinfo_dirs
)
declare -gA ZINIT=(
    HOME_DIR        ${0:h}/zinit
    BIN_DIR         ${0:h}/zinit/bin
    PLUGINS_DIR     ${0:h}/zinit/plugins
    SNIPPETS_DIR    ${0:h}/zinit/snippets
    COMPLETIONS_DIR ${0:h}/zinit/completions
    # MAN_DIR         $ZPFX/share/man
    ZCOMPDUMP_PATH  ${ZSH_CACHE_DIR:-$XDG_CACHE_HOME}/zcompdump-${HOST/.*/}-${ZSH_VERSION}
    COMPINIT_OPTS   -C
    LIST_COMMAND    'exa --color=always --tree --icons -L3'
)

alias ziu='zi update'
alias zid='zi delete'

zmodload -i zsh/complist
zmodload -F zsh/parameter +p:dirstack
autoload -Uz chpwd_recent_dirs add-zsh-hook cdr zstyle+
add-zsh-hook chpwd chpwd_recent_dirs
# add-zsh-hook -Uz zsh_directory_name zsh_directory_name_cdr # cd ~[1]

zstyle+ ':chpwd:*' recent-dirs-default true \
      + ''         recent-dirs-max     20 \
      + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs" \
      + ''         recent-dirs-prune   'pattern:/tmp(|/*)'
# + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs-${TTY##*/}" "${ZDOTDIR}/chpwd-recent-dirs" + \
# + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs-${TTY##*/}" \

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

fpath=( ${0:h}/{functions{/hooks,/lib,/utils,/wrap,/widgets,/zonly,},completions} "${fpath[@]}" )
autoload -Uz $^fpath[1,7]/*(:t)
fpath+=( ${0:h}/completions.zwc )

# fpath=(
#   ${0:h}/functions/${(@P)^Zinfo_dirs[fn_t]}.zwc
#   ${0:h}/functions.zwc
#   "${fpath[@]}"
# )
# autoload -Uwz ${(@Mz)fpath:#*.zwc}
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

# An empty stub to fill the help handler fields
:za-desc-null-handler() { :; }

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

# Register desc hook that does nothing
@zinit-register-annex "z-a-desc" \
    hook:\!atclone-0 \
    :za-desc-null-handler \
    :za-desc-null-handler \
    "desc''"

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
    $null

# NICHOLAS85/z-a-linkbin \
# === annex, prompt === [[[
zt light-mode for \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-submods \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-binary-symlink \
  NICHOLAS85/z-a-linkman \
  NICHOLAS85/z-a-eval \
    atinit'Z_A_USECOMP=1' \
  lmburns/z-a-check

# zdharma-continuum/zinit-annex-rust
# zdharma-continuum/zinit-annex-as-monitor
# zdharma-continuum/zinit-annex-readurl

(){
  [[ -f "${Zinfo[themed]}/${1}-pre.zsh" || -f "${Zinfo[themed]}/${1}-post.zsh" ]] && {
    zt light-mode for \
        romkatv/powerlevel10k \
      id-as"${1}-theme" \
      atinit"[[ -f ${Zinfo[themed]}/${1}-pre.zsh ]] && source ${Zinfo[themed]}/${1}-pre.zsh" \
      atload"[[ -f ${Zinfo[themed]}/${1}-post.zsh ]] && source ${Zinfo[themed]}/${1}-post.zsh" \
      atload'alias ntheme="$EDITOR ${Zinfo[themed]}/${MYPROMPT}-post.zsh"' \
        $null
  } || {
    [[ -f "${Zinfo[themed]}/${1}.toml" ]] && {
      export STARSHIP_CONFIG="${Zinfo[themed]}/${MYPROMPT}.toml"
      export STARSHIP_CACHE="${XDG_CACHE_HOME}/${MYPROMPT}"
      eval "$(starship init zsh)"
      zt 0a light-mode for \
        lbin atclone'cargo br --features=notify-rust' atpull'%atclone' atclone"$(mv_clean)" \
        atclone'./starship completions zsh > _starship' atload'alias ntheme="$EDITOR $STARSHIP_CONFIG"' \
        starship/starship
    }
  } || print -P "%F{4}Theme ${1} not found%f"
} "${MYPROMPT=p10k}"

add-zsh-hook chpwd @chpwd_ls
# ]]] === annex, prompt ===

# Load when files are modified   subscribe'{~/files-*,/tmp/files-*}' (on-update-of)
# Load on condition              load'[[ $PWD = */github* ]]'
# Unload on condition            unload'[[ $PWD != */github* ]]'
# Function created to load       trigger-load'!x'
#
# Autoload the functions         autoload'fun → my-fun; fun2 → my-fun2'
# Substitute string              subst'autoload → autoload -Uz' …`
# Change keybindings             bindmap'\e[1\;6D -> ^[[1\;6D; \e[1\;6C -> ^[[1\;6C'
# Load with aliases enabled      aliases
# Track a function               wrap-track'_p9k_precmd'
# Track keybindings              trackbinds

# === trigger-load block ===[[[
zt 0a light-mode for \
  is-snippet trigger-load'!x' blockf svn \
    OMZ::plugins/extract \
  trigger-load'!zhooks' \
    agkozak/zhooks \
  lbin'git-undo' trigger-load'!ugit' \
    Bhupesh-V/ugit \
  trigger-load'!ga;!gi;!grh;!grb;!glo;!gd;!gcf;!gco;!gclean;!gss;!gcp;!gcb' \
  lbin'git-forgit' \
    wfxr/forgit \
  trigger-load'!hist' blockf nocompletions compile'f*/*~*.zwc' \
    marlonrichert/zsh-hist

# patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset nocompile'!' \
# trigger-load'!updatelocal' blockf compile'f*/*~*.zwc' \
# atinit'typeset -gx UPDATELOCAL_GITDIR="${HOME}/opt"' \
#   NICHOLAS85/updatelocal \
#
# atinit'forgit_ignore="/dev/null"' \

# compdef _gnu_generic cmd
# print -r -- ${(F)${(@qqq)_args_cache_cmd}} > _cmd
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
  as'completion' atpull'zinit cclear' blockf \
    zsh-users/zsh-completions \
  ver'develop' atload'_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions \
  pick'you-should-use.plugin.zsh' \
    MichaelAquilina/zsh-you-should-use \
  pick'async.zsh' \
    mafredri/zsh-async \
    zdharma-continuum/zflai

# OMZ::lib/completion.zsh \
# wait'[[ -n ${ZLAST_COMMANDS[(r)n-#(alias|c|en|func|hel|hist|kil|opt|panel)]} ]]' \
# ]]] === wait'0a' block ===

# === wait'0c' - git plugins === [[[
zt 0c light-mode for \
  lbin'!' patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset nocompletions \
  atinit'_w_db_faddf() { dotbare fadd -f; }; zle -N db-faddf _w_db_faddf' \
  pick'dotbare.plugin.zsh' \
    kazhala/dotbare \
  lbin"bin/git-*" atclone'rm -f **/*ignore' \
  src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" \
    tj/git-extras \
  lbin atload'alias giti="git-ignore"'\
    laggardkernel/git-ignore \
  lbin'f*~*.zsh' pick'*.zsh' atinit'alias fs="fstat"' \
    lmburns/fzfgit \
  lman param'tig_set_path' pick'tigsuite.plugin.zsh' \
    psprint/tigsuite \
  lbin'git-quick-stats' lman atload"export _MENU_THEME=legacy" \
    arzzen/git-quick-stats

  # TODO: zinit recall

  # Fakerr/git-recall \
  # paulirish/git-open \
  # paulirish/git-recent \
  # davidosomething/git-my \
  # github/git-sizer
  # idc101/git-mkver

  # lbin'git-now*' make"PREFIX=$ZPFX" \
  #   iwata/git-now \
  # lbin'**/*nal;**/*nal-run' from'gh-r' \
  #   tycho-kirchner/shournal \
  # zdharma/zsh-unique-id \

# ]]]
# blockf atclone'cd -q functions;renamer --verbose "^\.=@" .*' \
# trackbinds compile'functions/*~*.zwc' \
#   marlonrichert/zsh-edit \

# === wait'0b' - patched === [[[
zt 0b light-mode patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset nocompile'!' for \
  atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
    hlissner/zsh-autopair \
  trackbinds bindmap'\e[1\;6D -> ^[[1\;6D; \e[1\;6C -> ^[[1\;6C' \
    michaelxmcbride/zsh-dircycle \
  trackbinds bindmap'^H -> ^X^T' \
  atload'add-zsh-hook chpwd @chpwd_dir-history-var;
  add-zsh-hook zshaddhistory @append_dir-history-var; @chpwd_dir-history-var now' \
    kadaan/per-directory-history \
  atinit'zicompinit_fast; zicdreplay;' atload'unset "FAST_HIGHLIGHT[chroma-man]"' \
  atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- $f};}' \
  compile'.*fast*~*.zwc' atpull'%atclone' \
    zdharma-continuum/fast-syntax-highlighting \
  trackbinds bindmap"^R -> '\ew'" \
    m42e/zsh-histdb-fzf
#  ]]] === wait'0b' - patched ===

#  === wait'0b' === [[[
# larkery/zsh-histdb \
# OMZP::systemd/systemd.plugin.zsh \

zt 0b light-mode for \
  blockf compile'lib/*f*~*.zwc' \
    Aloxaf/fzf-tab \
  autoload'#manydots-magic' \
    knu/zsh-manydots-magic \
    RobSis/zsh-reentry-hook \
  trackbinds atload'
    vbindkey "Up" history-substring-search-up
    vbindkey "Down" history-substring-search-down
    vbindkey -M vicmd "k" history-substring-search-up;
    vbindkey -M vicmd "j" history-substring-search-down' \
    zsh-users/zsh-history-substring-search \
  compile'h*~*.zwc' trackbinds bindmap'^R -> ^F' atload'
    zstyle ":history-search-multi-word" highlight-color "fg=52,bold";
    zstyle ":history-search-multi-word" page-size "32";  # entries to show ($LINES/3)
    zstyle ":history-search-multi-word" synhl "yes";     # do syntax highlighting
    zstyle ":history-search-multi-word" active "bold fg=53";
    zstyle ":history-search-multi-word" check-paths "yes";
    zstyle ":history-search-multi-word" clear-on-cancel "no"' \
    zdharma-continuum/history-search-multi-word \
  pick'*plugin*' blockf nocompletions compile'*.zsh~*.zwc' \
  src'histdb-interactive.zsh' atload'HISTDB_FILE="${ZDOTDIR}/.zsh-history.db"' \
  atinit'Zkeymaps+=("\Ce" _histdb-isearch)' trackbinds \
  cloneopts="--branch zsqlite" \
    Aloxaf/zsh-histdb \
  nocompletions \
    Aloxaf/zsh-sqlite \
  pick'autoenv.zsh' nocompletions \
  atload'AUTOENV_AUTH_FILE="${ZPFX}/share/autoenv/autoenv_auth"' \
    Tarrasch/zsh-autoenv \
  blockf \
    zdharma-continuum/zui \
    zdharma-continuum/zbrowse \
  patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset nocompile'!' blockf \
    psprint/zsh-navigation-tools \
  patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset nocompile'!' \
  atinit'alias wzman="ZMAN_BROWSER=w3m zman"
         alias zmand="info zsh "' \
    mattmc3/zman \
    anatolykopyl/doas-zsh-plugin \
  pick'timewarrior.plugin.zsh' nocompile blockf \
    svenXY/timewarrior

zt 0b light-mode for \
  trackbinds atload'
    zstyle :zle:evil-registers:"[A-Za-z%#]" editor nvim
    zstyle :zle:evil-registers:"\*" put  - xsel -o
    zstyle :zle:evil-registers:"+"  put  - xsel -b -o
    zstyle :zle:evil-registers:"\*" yank - xsel -i --trim
    zstyle :zle:evil-registers:"+"  yank - xsel -b -i --trim
    zstyle :zle:evil-registers:"" put  - xsel -b -o
    zstyle :zle:evil-registers:"" yank - xsel -b -i --trim
    bindkey -M viins "^u" →evil-registers::ctrl-r' \
    zsh-vi-more/evil-registers \
  atinit"zstyle ':vimman:' dir ~/.vim/bundle $PACKDIR
         zstyle ':vimman:' verbose yes" \
    yonchu/vimman \
    zdharma-continuum/zed2 \
    zsh-vi-more/ex-commands \
  atload'zstyle ":zce:*" keys "asdghklqwertyuiopzxcvbnmfj;23456789";
         zstyle ":zce:*" fg "fg=19,bold"' \
    hchbaw/zce.zsh \
  lman param'zs_set_path' \
    psprint/zsh-sweep \
  nocompile'!' atinit"
    : ${APPZNICK::=${XZAPP:-XZ}}
    : ${XZCONF::=${XDG_CONFIG_HOME:-$HOME/.config}/xzmsg}
    : ${XZCACHE::=$XZCONF/cache}
    : ${XZINI::=$XZCACHE/${(L)APPZNICK}.xzc}
    : ${XZLOG::=$XZCACHE/${(L)APPZNICK}.xzl}
    : ${XZTHEME::=$XZCONF/themes/default.xzt}" \
    psprint/xzmsg \
  lbin'!bin/{shu2,shu2c}' blockf binary nocompile \
  atclone'bin/shu2c -q' atpull'%atclone' \
    okdana/shu2 \
  nocompile'!' atinit'
    zstyle ":iq:browse-symbol" key "\Cx\Cy"
    zstyle ":iq:action-complete:plugin-id" key "\ea"
    zstyle ":iq:action-complete:ice" key "\ec"' \
    psprint/zsh-angel-iq-system

    # zsh-vi-more/vi-motions \
    # hchbaw/en.zsh \
    # zsh-vi-more/vi-quote \

# wait'[[ -n $DISPLAY ]]' atload'
# zstyle ":notify:*" expire-time 6
# zstyle ":notify:*" error-title "Command failed (in #{time_elapsed} seconds)"
# zstyle ":notify:*" success-title "Command finished (in #{time_elapsed} seconds)"' \
#   marzocchi/zsh-notify \
#  ]]] === wait'0b' ===

#  === wait'0c' - programs - sourced === [[[
zt 0c light-mode binary for \
  lbin'!**/*grep;**/*man;**/*diff' has'bat' atpull'%atclone' \
  atclone'(){local f;builtin cd -q src;for f (*.sh){mv ${f} ${f:r}};}' \
  atload'alias bdiff="batdiff" bm="batman" bgrep="env -u RIPGREP_CONFIG_PATH batgrep"' \
    eth-p/bat-extras \
  lbin'cht.sh -> cht' id-as'cht.sh' reset-prompt \
    https://cht.sh/:cht.sh \
  lbin'!src/pt*(*)' patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset \
  atclone'(){local f;builtin cd -q src;for f (*.sh){mv ${f} ${f:r:l}};}' \
  atclone"command mv -f config $ZPFX/share/ptSh/config" \
  atload'alias mkd="ptmkdir -pv"' \
    jszczerbinsky/ptSh \
  lbin atclone"mkdir -p $XDG_CONFIG_HOME/ytfzf; cp **/conf.sh $XDG_CONFIG_HOME/ytfzf" \
    pystardust/ytfzf \
  if"$(has surfraw)" lbin from'gl' \
  atclone'./prebuild; ./configure --prefix="$ZPFX"; make' make"install"  atpull'%atclone' \
  atinit'SURFRAW_google_safe=off' \
    surfraw/Surfraw \
  if"$(has xsel)" lbin lman atclone'./autogen.sh; ./configure --prefix="$ZPFX"; make' \
  make"install" atpull'%atclone' \
    kfish/xsel \
  if"$(has w3m)" lbin lman atclone'./configure --prefix="$ZPFX"; make' \
  make"install" atpull'%atclone'\
    tats/w3m \
  lbin lman atclone'./autogen.sh && ./configure --enable-unicode --prefix="$ZPFX"' \
  make'install' atpull'%atclone' \
    KoffeinFlummi/htop-vim \
  lbin lman patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset \
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

# RUSTFLAGS="-C target-cpu=native" cargo build --release --features 'simd-accel pcre2'

#  === wait'0c' - programs + man === [[[
zt 0c light-mode binary lbin lman from'gh-r' for \
  atclone'mv -f **/*.zsh _bat' atpull'%atclone' \
    @sharkdp/bat \
    @sharkdp/hyperfine \
  atclone'./fd --gen-completions zsh > _fd' atpull'%atclone' \
    @sharkdp/fd \
    @sharkdp/diskus \
    @sharkdp/pastel \
  atclone'mv rip*/* .' atpull'%atclone' \
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

#  ]]] === wait'0c' - programs + man ===

#  === wait'0c' - programs === [[[
zt 0c light-mode binary for \
  lbin'sk;bin/sk-tmux' lman'*/**.1' src'shell/key-bindings.zsh' \
  trackbinds atclone'cargo br' atclone"$(mv_clean sk)" atpull'%atclone' \
    lotabout/skim

zt 0c light-mode null for \
  lbin patch"${Zinfo[patchd]}/%PLUGIN%.patch" make"PREFIX=$ZPFX install" reset \
  atpull'%atclone' atdelete"PREFIX=$ZPFX make uninstall"  \
    zdharma-continuum/zshelldoc \
  lbin lman from'gh-r' dl"$(grman man/man1/)" \
    junegunn/fzf \
  id-as'fzf_comp' multisrc'shell/{completion,key-bindings}.zsh' pick='/dev/null' \
  trackbinds atload"bindkey -r '^[c'; bindkey '^[c' fzf-cd-widget" \
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
  lbin patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset atclone'cargo br' \
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
  lbin'das* -> dasel' from'gh-r' atclone'./dasel completion zsh > _dasel' \
    TomWright/dasel \
  lbin'yj* -> yj' from'gh-r' \
    sclevine/yj \
  lbin'b**/r**/crex' atclone'chmod +x build.sh; ./build.sh -r;' \
    octobanana/crex \
  lbin from'gh-r' \
    pemistahl/grex \
  id-as'bisqwit/regex-opt' lbin atclone'xh --download https://bisqwit.iki.fi/src/arch/regex-opt-1.2.4.tar.gz' \
  atclone'ziextract --move --auto regex-*.tar.gz' make'all' \
    $null \
  lbin from'gh-r' \
    muesli/duf \
  lbin from'gh-r' bpick'*linux_amd*gz' pick='/dev/null' \
  src"$ZPFX/share/pet/pet_atload.zsh" \
    knqyf263/pet \
  atclone'ln -sf %DIR% "$ZPFX/libexec/goenv"' atpull'%atclone' \
  atinit'export GOENV_ROOT="$ZPFX/libexec/goenv"' \
    syndbg/goenv

# eval"atuin init zsh | sed 's/bindkey .*\^\[.*$//g'"

# == rust [[[
# Load quicker
zt 0a light-mode null check'!%PLUGIN%' for \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atclone"./rualdi completions shell zsh > _rualdi" \
  atload'alias ru="rualdi"' eval'rualdi init zsh --cmd k' \
    lmburns/rualdi

zt 0c light-mode null check'!%PLUGIN%' for \
  lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
    miserlou/loop \
  lbin'ff* -> ffsend' from'gh-r' \
    timvisee/ffsend \
  has'!pacaptr' lbin from'gh-r' \
    rami3l/pacaptr \
  lbin patch"${Zinfo[patchd]}/%PLUGIN%.patch" reset atclone'cargo br' atclone"$(mv_clean)" \
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
  lbin lman reset atclone'cargo br' atclone"$(mv_clean rgr)" \
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
  desc'Command line CSV pretty printer' \
    alexhallam/tv \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
    evansmurithi/cloak \
  lbin from'gh-r' \
    lotabout/rargs

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
    $null
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
  lbin from'gh-r' atload'alias lD="lazydocker"' \
    jesseduffield/lazydocker \
  lbin from'gh-r' atload'alias lnpm="lazynpm"' \
    jesseduffield/lazynpm
# ]]] === tui specifi block ===

# === git specific block === [[[
zt 0c light-mode null for \
  lbin from'gh-r' \
    isacikgoz/gitbatch \
  lbin from'gh-r' atload'alias lg="lazygit"' \
    jesseduffield/lazygit \
  lbin from'gh-r' \
    extrawurst/gitui \
  lbin'tig' atclone'./autogen.sh; ./configure --prefix="$ZPFX"; mv -f **/**.zsh _tig' \
  make atpull'%atclone' reset \
    jonas/tig \
  lbin from'gh-r' blockf atload'export GHQ_ROOT="$HOME/ghq"' \
  desc'Git clone manager' \
    x-motemen/ghq \
  lbin from'gh-r' \
  desc'Get github executable releases' \
    Songmu/ghg \
  lbin'**/delta' from'gh-r' patch"${Zinfo[patchd]}/%PLUGIN%.patch" \
    dandavison/delta \
  lbin from'gh-r' lman \
  desc'Open git repo in browser' \
    rhysd/git-brws \
  lbin'tar*/rel*/mgit' atclone'cargo br' atpull'%atclone' \
  desc'Run a git command on multiple repositories' \
    koozz/mgit \
  lbin"git-url;git-guclone;**/zgiturl" lman make \
  desc'Encode git URLs, creating a new protocol' \
    zdharma-continuum/git-url \
  lbin from'gh-r' \
  desc'Multi git repo helper' \
    tshepang/mrh \
  lbin atclone'go build' atpull'%atclone' \
  desc'Make updates across multiple repositories' \
    gruntwork-io/git-xargs \
  lbin"git-cal" atclone'perl Makefile.PL PREFIX=$ZPFX' \
  atpull'%atclone' make \
  desc'Github like contributions calendar on terminal' \
    k4rthik/git-cal
# ]]] === git specific block ===
# ]]] === wait'0c' - programs ===

# === Testing [[[
zt 0c light-mode for \
  pipx'jrnl' id-as'jrnl' \
    $null

# gem'!kramdown' id-as'kramdown' null $null
# binary cargo'!viu' id-as"$(id_as viu)" $null
# === Testing ]]]

#  === snippet block === [[[
# Don't have to be recompiled to use
zt light-mode nocompile is-snippet for $ZDOTDIR/plugins/*.zsh
zt light-mode is-snippet for $ZDOTDIR/snippets/*.zsh
zt light-mode is-snippet for $ZDOTDIR/snippets/bundled/*.(z|)sh
zt light-mode is-snippet for $ZDOTDIR/snippets/zle/*.zsh
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
zmodload -i zsh/sched
zmodload -F zsh/param/private b:private
zmodload -mF zsh/files b:zf_\*
#   b:zf_chgrp b:zf_chmod b:zf_chown b:zf_ln b:zf_mkdir \
#   b:zf_mv    b:zf_rm    b:zf_rmdir b:zf_sync

autoload -Uz zmv zargs zed relative zrecompile # sticky-note
autoload -Uz allopt # show all options
autoload -Uz zcalc zmathfunc
zmathfunc

alias fned='zed -f' histed='zed -h'
alias zmv='noglob zmv -v'  zcp='noglob zmv -Cv' zmvn='noglob zmv -W'
alias zln='noglob zmv -Lv' zlns='noglob zmv -o "-s" -Lv'

# autoload -Uz sticky-note regexp-replace

zmodload -F zsh/parameter p:functions_source
[[ -v aliases[run-help] ]] && unalias run-help
autoload -RUz run-help
autoload -Uz $functions_source[run-help]-*~*.zwc
# autoload -Uz $^fpath/run-help-^*.zwc(N:t)
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
  # [[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
  local -r line=${1%%$'\n'}
  local -r cmd=${line%% *}
  # [[ ${#line} -lt 5 ]] && return 1
  (( ! $+histignore[(r)${cmd}] ))
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
    emulate -L zsh
    (( $+functions[_histdb_query] && $+builtins[zsqlite_exec] )) || return
    # (( $+functions[_histdb_query] )) || return
    # _histdb_init
    local last_cmd="$(sql_escape ${history[$((HISTCMD-1))]})"
    local cmd="$(sql_escape $1)"
    local pwd="$(sql_escape $PWD)"
#     local reply=$(zsqlite_exec _HISTDB "
# SELECT argv FROM (
#   SELECT c1.argv, p1.dir, h1.session, h1.start_time, 1 AS priority
#   FROM history h1, history h2
#     LEFT JOIN commands c1 ON h1.command_id = c1.ROWID
#     LEFT JOIN commands c2 ON h2.command_id = c2.ROWID
#     LEFT JOIN places p1   ON h1.place_id = p1.ROWID
#   WHERE h1.ROWID = h2.ROWID + 1
#     AND c1.argv LIKE '$cmd%'
#     AND c2.argv = '$last_cmd'
#     -- AND h1.exit_status = 0
#     UNION
#   SELECT c1.argv, p1.dir, h1.session, h1.start_time, 0 AS priority
#   FROM history h1
#     LEFT JOIN commands c1 ON h1.command_id = c1.ROWID
#     LEFT JOIN places p1   ON h1.place_id = p1.ROWID
#   WHERE c1.argv LIKE '$cmd%'
# )
# ORDER BY dir != '$pwd', start_time, priority DESC, session != $HISTDB_SESSION DESC
# LIMIT 1
# ")
    # local reply=$(_histdb_query "
    local reply=$(zsqlite_exec _HISTDB "
SELECT commands.argv
FROM   history
  LEFT JOIN commands
    ON history.command_id = commands.rowid
  LEFT JOIN places
    ON history.place_id = places.rowid
WHERE    commands.argv LIKE '$cmd%'
        AND commands.argv NOT LIKE 'o %'
        AND commands.argv NOT LIKE 'cd %'
-- AND history.exit_status = 0
-- GROUP BY commands.argv, places.dir
ORDER BY places.dir != '$pwd', history.start_time DESC
LIMIT 1
")
    typeset -g suggestion=$reply

# (( $+functions[_histdb_query] )) || return
#   typeset -g suggestion=$(_histdb_query "$query")
}
# ]]]

# === paths (GNU) === [[[
[[ -z ${path[(re)$HOME/.local/bin]} ]] && path=( "$HOME/.local/bin" "${path[@]}" )
[[ -z ${path[(re)/usr/local/sbin]} ]]  && path=( "/usr/local/sbin"  "${path[@]}" )

[[ -z ${fpath[(re)/usr/share/zsh/site-functions]} ]] && fpath=( "${fpath[@]}" /usr/share/zsh/site-functions )

hash -d ghq=$HOME/ghq
hash -d pro=$HOME/projects
hash -d git=$HOME/projects/github
hash -d config=$XDG_CONFIG_HOME
hash -d nvim=$XDG_CACHE_HOME/nvim
hash -d vim=$HOME/.vim
hash -d zsh=$ZDOTDIR

# cdpath=( $HOME/{projects/github,.config} )
cdpath=( $XDG_CONFIG_HOME )

manpath=(
  $XDG_DATA_HOME/man
  $ZINIT_HOME/polaris/man
  $ZINIT_HOME/polaris/share/man
  $NPM_PACKAGES/share/man
  $(rustc --print=sysroot)/share/man
  "${manpath[@]}"
)

eval "$(luarocks path --bin --lua-version=5.1)"
# LUA_PATH="/usr/share/luajit-2.1.0-beta3/?.lua:/usr/share/luajit-2.1.0-beta3/?/init.lua${LUA_PATH}"

path=(
  /usr/lib/ccache/bin
  $HOME/mybin
  $HOME/mybin/linux
  $HOME/mybin/gtk
  $HOME/bin(N-/)
  $HOME/.ghg/bin(N-/)
  $PYENV_ROOT/{shims,bin}(N-/)
  $GOENV_ROOT/{shims,bin}(N-/)
  $CARGO_HOME/bin(N-/)
  # $RUSTUP_HOME/toolchains/*/bin(N-/)
  $XDG_DATA_HOME/gem/bin(N-/)
  $XDG_DATA_HOME/luarocks/bin(N-/)
  $XDG_DATA_HOME/neovim/bin(N-/)
  $XDG_DATA_HOME/neovim-nightly/bin(N-/)
  $GEM_HOME/bin(N-/)
  $NPM_PACKAGES/bin(N-/)
  $HOME/texlive/2021/bin/x86_64-linux(N-/)
  /usr/bin                   # add again to be ahead of /bin
  /usr/lib/w3m
  $HOME/.ghcup/bin(N-/)
  $HOME/.cabal/bin(N-/)
  # $(stack path --stack-root)/programs/x86_64-linux/ghc-tinfo6-8.10.7/bin
  # $HOME/.poetry/bin(N-/)
  "${path[@]}"
)
# ]]]

#===== completions ===== [[[
zt 0c light-mode as'completion' for \
  id-as'poetry_comp' atclone='poetry completions zsh > _poetry' \
  atpull'%atclone' has'poetry' \
    $null \
  id-as'rust_comp' atclone'rustup completions zsh rustup > _rustup' \
  atclone'rustup completions zsh cargo > _cargo' \
  atpull='%atclone' has'rustup' \
    $null \
  id-as'pueue_comp' atclone'pueue completions zsh "${GENCOMP_DIR}"' \
  atpull'%atclone' has'pueue' \
    $null
# ]]] ===== completions =====

#===== variables ===== [[[
zt 0c light-mode run-atpull nocompile'!' for \
  id-as'pipx_comp' has'pipx' nocd eval"register-python-argcomplete pipx" \
  atload'zicdreplay -q' \
    $null \
  id-as'pyenv_init' has'pyenv' nocd eval'pyenv init - zsh' \
    $null \
  id-as'pipenv_comp' has'pipenv' nocd eval'_PIPENV_COMPLETE=zsh_source pipenv' \
    $null \
  id-as'navi_comp' has'navi' nocd eval'navi widget zsh' \
    $null \
  id-as'zoxide_init' has'zoxide' nocd eval'zoxide init --no-cmd --hook prompt zsh' \
  atload'alias o=__zoxide_z z=__zoxide_zi' \
    $null \
  id-as'abra_hook' has'abra' nocd eval'abra hook zsh' \
    $null \
  id-as'keychain_init' has'keychain' nocd \
  eval'keychain --agents ssh -q --inherit any --eval burnsac git gitlab \
    && keychain --agents gpg -q --eval 0xC011CBEF6628B679' \
    $null

  #     && keychain --agents ssh -q --inherit any --eval git \
  #     && keychain --agents ssh -q --inherit any --eval gitlab \

# id-as'antidot_conf' has'antidot' nocd eval'antidot init' $null \
# id-as'go_env' has'goenv' nocd eval'goenv init -' $null \
# id-as'ruby_env' has'rbenv' nocd eval'rbenv init - | sed "s|source .*|source $ZDOTDIR/extra/rbenv.zsh|"' $null \

zt 0c light-mode for \
  id-as'Cleanup' nocd atinit'unset -f zt grman mv_clean has id_as;
  _zsh_autosuggest_bind_widgets' \
    $null

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
typeset -gx ZSH_AUTOSUGGEST_STRATEGY=(
  histdb_top_here   dir_history
  custom_history    match_prev_cmd
  completion
)
typeset -gx ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  vi-find-next-char  vi-find-next-char-skip
  # forward-word       vi-forward-blank-word   vi-forward-blank-word-end
  # vi-forward-word    vi-forward-word-end
  # forward-char       vi-forward-char
  end-of-line        vi-add-eol              vi-end-of-line
)
typeset -gx HISTORY_SUBSTRING_SEARCH_FUZZY=set
typeset -gx HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=set
typeset -gx AUTOPAIR_CTRL_BKSPC_WIDGET=".backward-kill-word"
typeset -ga chpwd_dir_history_funcs=( "_dircycle_update_cycled" ".zinit-cd" )
typeset -g PER_DIRECTORY_HISTORY_BASE="${ZPFX}/share/per-directory-history"
typeset -gx NQDIR="/tmp/nq" FNQ_DIR="$HOME/tmp/fnq"
typeset -gx FZFGIT_BACKUP="${XDG_DATA_HOME}/gitback"
typeset -gx FZFGIT_DEFAULT_OPTS="--preview-window=':nohidden,right:65%:wrap'"
typeset -gx PASSWORD_STORE_ENABLE_EXTENSIONS='true'
# ]]]

# === fzf === [[[
# ❱❯❮

# I have custom colors for 1-53. They're set in alacritty
# If this is an array, even if they're joined, vim doesn't like that
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
FZF_DIR_PREVIEW="([[ -d {} ]] && (bkt -- exa -T {} | bat --color=always))"
FZF_BIN_PREVIEW="([[ \$(file --mime-type -b {}) = *binary* ]] && (echo {} is a binary file))"

export FZF_HISTFILE FZF_FILE_PREVIEW FZF_DIR_PREVIEW FZF_BIN_PREVIEW

export FZF_DEFAULT_OPTS="
--prompt='❱ '
--pointer='》'
--marker='▍'
--separator=''
--info='inline: ❰ '
--scrollbar='█'
--ellipsis=''
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
--preview=\"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='esc:abort'
--bind='ctrl-c:abort'
--bind='ctrl-q:abort'
--bind='ctrl-g:cancel'
--bind='ctrl-j:down'
--bind='ctrl-k:up'
--bind='home:beginning-of-line'
--bind='end:end-of-line'
--bind='ctrl-s:beginning-of-line'
--bind='ctrl-e:end-of-line'
--bind='alt-x:unix-line-discard'
--bind='alt-c:unix-word-rubout'
--bind='alt-d:kill-word'
--bind='ctrl-h:backward-delete-char'
--bind='alt-bs:backward-kill-word'
--bind='ctrl-w:backward-kill-word'
--bind='alt-a:toggle-all'
--bind='ctrl-alt-a:toggle-all+accept'
--bind='alt-s:toggle-sort'
--bind='ctrl-r:clear-selection'
--bind='page-up:prev-history'
--bind='page-down:next-history'
--bind='alt-{:prev-history'
--bind='alt-}:next-history'
--bind='alt-shift-up:prev-history'
--bind='alt-shift-down:next-history'
--bind='alt-left:first'
--bind='alt-right:last'
--bind='alt-up:prev-selected'
--bind='alt-down:next-selected'
--bind='ctrl-u:half-page-up'
--bind='ctrl-d:half-page-down'
--bind='ctrl-alt-u:page-up'
--bind='ctrl-alt-d:page-down'
--bind='alt-enter:replace-query+print-query'
--bind='ctrl-/:jump'
--bind='?:toggle-preview'
--bind='alt-[:toggle-preview'
--bind='alt-]:change-preview-window(70%|45%,down,border-top|45%,up,border-bottom|)+show-preview'
--bind='alt-w:toggle-preview-wrap'
--bind='ctrl-b:preview-page-up'
--bind='ctrl-f:preview-page-down'
--bind='alt-i:preview-page-up'
--bind='alt-o:preview-page-down'
--bind='ctrl-alt-b:preview-up'
--bind='ctrl-alt-f:preview-down'
--bind='alt-e:become($EDITOR {+})'
--bind='alt-b:become(bat --paging=always -f {+})'
--bind='ctrl-y:execute-silent(xsel --trim -b <<< {+})'
--bind='ctrl-]:preview(bat --color=always -l bash \"$XDG_DATA_HOME/gkeys/fzf\")'
--bind='alt-/:unbind(?)'
--bind='ctrl-\\:rebind(?)'
--bind='f2:unbind(?)'
--bind='f3:rebind(?)'
--bind='change:first'"

# FIX: these sometimes work sometimes don't
# --bind='alt-{:prev-history'
# --bind='alt-}:next-history'

# --bind='shift-up:'
# --bind='shift-down:'
# --bind='alt-shift-up:'
# --bind='alt-shift-down:'
# --bind='alt-shift-left:'
# --bind='alt-shift-right:'

# --bind='ctrl-\\:rebind(?)+rebind(<)+rebind(>)'
# --bind='alt-!:unbind(<)'
# --bind='alt-@:unbind(>)'
# --bind=\"alt-':beginning-of-line\"
# --bind='alt-\":end-of-line'

# --separator='━'

SKIM_DEFAULT_OPTIONS="
--prompt '❱ '
--cmd-prompt 'c❱ '
--cycle
--reverse --height 80% --ansi --inline-info --multi --border
--preview-window=':hidden,right:60%'
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='?:toggle-preview,alt-w:toggle-preview-wrap'
--bind='alt-a:select-all,ctrl-r:toggle-all'
--bind='alt-b:execute(bat --paging=always -f {+})'
--bind=\"ctrl-y:execute-silent(ruby -e 'puts ARGV' {+} | xsel --trim -b)+abort\"
--bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--bind='ctrl-s:toggle-sort'
--bind='ctrl-b:preview-up,ctrl-f:preview-down'
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
# (( $+commands[fd] )) && {
#     _fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1" }
#     _fzf_compgen_dir()  { fd --type d --hidden --follow --exclude ".git" . "$1" }
# }

export FZF_ALT_C_COMMAND="\
  fd --no-ignore --hidden --follow --strip-cwd-prefix --exclude '.git' --type d -d 1 | lscolors"
export SKIM_ALT_C_COMMAND="$FZF_ALT_C_COMMAND"
export FZF_ALT_C_OPTS="
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--preview-window default:right:60%"
export FORGIT_FZF_DEFAULT_OPTS="--preview-window='right:60%:nohidden' --bind='ctrl-e:become(nvim {2})'"
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview='(exa -T {2} | less) 2>/dev/null | head -200'"

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
  multisrc="$ZDOTDIR/zsh.d/{aliases,keybindings,lf,functions,tmux,git-token}.zsh" \
    $null \
  atinit'
  export PERLBREW_ROOT="${XDG_DATA_HOME}/perl5/perlbrew";
  export PERLBREW_HOME="${XDG_DATA_HOME}/perl5/perlbrew-h";
  export PERL_CPANM_HOME="${XDG_DATA_HOME}/perl5/cpanm"' \
  atload'local x="$PERLBREW_ROOT/etc/bashrc"; [ -s "$x" ] && source "$x"' \
  has'perlbrew' \
    $null \
  atinit'
  export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
  export NVM_COMPLETION=true' \
  atload'local x="$NVM_DIR/nvm.sh"; [ -s "$x" ] && source "$x"' \
    $null \
  atload'local x="$ZDOTDIR/zsh.d/non-config/goenv.zsh"; [ -s "$x" ] && source "$x"' \
  has'goenv' \
    $null \
  atload'local x="$ZDOTDIR/zsh.d/non-config/prll.sh"; [ -s "$x" ] && source "$x"' \
    $null \
  atload'export FAST_WORK_DIR=XDG;
  fast-theme XDG:kimbox.ini &>/dev/null' \
    $null

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
