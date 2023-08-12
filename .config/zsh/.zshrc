############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# TODO: periodic fn MAILCHECK global aliases

# === general settings === [[[
0="${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}"

umask 022
limit coredumpsize unlimited

# typeset -ga discard_fn
# discard_fn=( zt grman mv_clean has id_as zflai-zprof )

(( $UID == 0 )) && { unset HISTFILE && SAVEHIST=0; }
typeset -gaxU path fpath manpath infopath cdpath mailpath
typeset -fuz zkbd
typeset -ga mylogs
typeset -F4 SECONDS=0

typeset -g  sourcestart
typeset -ga files;   files=($ZRCDIR/*.zsh(N.,@))
typeset -ga sourced; sourced=()

zmodload -i zsh/zprof
function zflai-msg()    { mylogs+=( "$1" ); }
function zflai-assert() { mylogs+=( "$4"${${${1:#$2}:+FAIL}:-OK}": $3" ); }
function zflai-log()    { zflai-msg "[$1]: $2: ${(M)$((($EPOCHREALTIME-${3}) * 1000))#*.?}ms ${4:-}" }
function zflai-print()  {
  print -rl -- ${(%)mylogs//(#b)(\[*\]): (*)/"%F{1}$match[1]%f: $match[2]"};
}
# @desc write zprof to $mylogs
function zflai-zprof() {
  local -a arr; arr=( ${(@f)"$(zprof)"} )
  local idx; for idx ({3..7}) {
    zflai-msg "[zprof]: ${arr[$idx]##*)[[:space:]]##}"
  }
}

zflai-msg "[path]: ${${(pj:\n\t:)path}}"
source $ZRCDIR/*-options.zsh
zflai-msg "[file]:   => 00-options.zsh"

files=(${(@)${(@)files:t}:#00-*})

function sourcef() {
  sourcestart=$EPOCHREALTIME
  local file
  local -i num cnt=$1
  local -a match=() mbegin=() mend=()
  sourced=()
  for file ($files[@]) {
    num=${(M)file//(#b)(#s)([0-9]#)-*/$match[1]}
    if (( $num < $cnt && $num > 0 )) {
      sourced+=($file)
      zflai-msg "[file]:   => $file"
    }
  }
  files=(${files[@]:|sourced})
}

sourcef 10; source -- $ZRCDIR/$^sourced[@]

local null="zdharma-continuum/null"
declare -gx ZINIT_HOME="${0:h}/zinit"
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

fpath=(
  ${0:h}/functions/${(P)^Zdirs[FUNC_D_reg]}
  ${0:h}/functions
  "${fpath[@]}"
)
autoload -Uz $^fpath[1,4]/*(:t.)

fpath=(
  ${0:h}/functions/${(P)^Zdirs[FUNC_D_zwc]}.zwc
  "${fpath[@]}"
)
autoload -Uwz ${(@Mz)fpath:#*.zwc}
fpath+=( ${0:h}/completions.zwc )

functions -Ms _zerr
functions -Ms _zerrf
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
  print -rl \
    -- ${${(S)${(M)${(@f)"$(cargo show $1)"}:#repository: *}/repository: https:\/\/*\//}//(#m)*/<$MATCH>}
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

# An empty stub to fill the help handler fields
:za-desc-null-handler() { :; }

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

sourcef 20
zt 0b light-mode null id-as nocd for multisrc="$ZRCDIR/${^sourced[@]}" $null
zflai-log "srcf" "---------- Time" $sourcestart "----------"

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

local ztmp=$EPOCHREALTIME
(){
  [[ -f "${Zdirs[THEME]}/${1}-pre.zsh" || -f "${Zdirs[THEME]}/${1}-post.zsh" ]] && {
    zt light-mode for \
        romkatv/powerlevel10k \
      id-as"${1}-theme" \
      atinit"[[ -f ${Zdirs[THEME]}/${1}-pre.zsh ]] && source ${Zdirs[THEME]}/${1}-pre.zsh" \
      atload"[[ -f ${Zdirs[THEME]}/${1}-post.zsh ]] && source ${Zdirs[THEME]}/${1}-post.zsh" \
      atload'alias ntheme="$EDITOR ${Zdirs[THEME]}/${MYPROMPT}-post.zsh"' \
        $null
  } || {
    [[ -f "${Zdirs[THEME]}/${1}.toml" ]] && {
      export STARSHIP_CONFIG="${Zdirs[THEME]}/${MYPROMPT}.toml"
      export STARSHIP_CACHE="${XDG_CACHE_HOME}/${MYPROMPT}"
      eval "$(starship init zsh)"
      zt 0a light-mode for \
        lbin atclone'cargo br --features=notify-rust' atpull'%atclone' atclone"$(mv_clean)" \
        atclone'./starship completions zsh > _starship' atload'alias ntheme="$EDITOR $STARSHIP_CONFIG"' \
        starship/starship
    }
  } || print -P "%F{4}Theme ${1} not found%f"
} "${MYPROMPT=p10k}"

zflai-log "zinit" "Theme" $ztmp

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
ztmp=$EPOCHREALTIME
zt 0a light-mode for \
  trigger-load'!ga;!gi;!grh;!grb;!glo;!gd;!gcf;!gco;!gclean;!gss;!gcp;!gcb' \
  lbin'git-forgit'                   desc'many git commands with fzf' \
    wfxr/forgit \
  trigger-load'!ugit' lbin'git-undo' desc'undo various git commands' \
    Bhupesh-V/ugit \
  trigger-load'!zhooks'              desc'show code of all zshhooks' \
    agkozak/zhooks \
  trigger-load'!hist'                desc'edit zsh history' \
  compile'f*/*~*.zwc' blockf nocompletions \
    marlonrichert/zsh-hist

# compdef _gnu_generic cmd
# print -r -- ${(F)${(@qqq)_args_cache_cmd}} > _cmd
zt 0a light-mode for \
  trigger-load'!gcomp' blockf \
  atclone'command rm -rf lib/*;git ls-files -z lib/ |xargs -0 git update-index --skip-worktree' \
  submods'RobSis/zsh-completion-generator -> lib/zsh-completion-generator;
  nevesnunes/sh-manpage-completions -> lib/sh-manpage-completions' \
  atload'gcomp(){gencomp "${@}" && zinit creinstall -q "${GENCOMP_DIR}" 1>/dev/null}' \
    Aloxaf/gencomp

zflai-log "zinit" "Trigger" $ztmp
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

# blockf atclone'cd -q functions;renamer --verbose "^\.=@" .*' \
# trackbinds compile'functions/*~*.zwc' \
#   marlonrichert/zsh-edit \

# === wait'0b' - patched === [[[
ztmp=$EPOCHREALTIME
zt 0b light-mode patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset nocompile'!' for \
  atinit'zicompinit_fast; zicdreplay;' atload'unset "FAST_HIGHLIGHT[chroma-man]"' \
  atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- $f};}' \
  compile'.*fast*~*.zwc' atpull'%atclone' nocompletions \
    zdharma-continuum/fast-syntax-highlighting \
  atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
    hlissner/zsh-autopair \
  trackbinds bindmap'\e[1\;6D -> ^[[1\;6D; \e[1\;6C -> ^[[1\;6C' \
    michaelxmcbride/zsh-dircycle \
  trackbinds bindmap'^H -> ^X^T' \
  atload'add-zsh-hook chpwd @chpwd_dir-history-var;
  add-zsh-hook zshaddhistory @append_dir-history-var; @chpwd_dir-history-var now' \
    kadaan/per-directory-history \
  trackbinds bindmap"^R -> '\ew'" \
    m42e/zsh-histdb-fzf
# ]]] === wait'0b' - patched ===

#  === wait'0b' === [[[
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
  nocompile'!' atinit"
    : ${APPZNICK::=${XZAPP:-XZ}}
    : ${XZCONF::=${XDG_CONFIG_HOME:-$HOME/.config}/xzmsg}
    : ${XZCACHE::=$XZCONF/cache}
    : ${XZINI::=$XZCACHE/${(L)APPZNICK}.xzc}
    : ${XZLOG::=$XZCACHE/${(L)APPZNICK}.xzl}
    : ${XZTHEME::=$XZCONF/themes/default.xzt}" \
    psprint/xzmsg \
  pick'*plugin*' blockf nocompletions compile'*.zsh~*.zwc' \
  src'histdb-interactive.zsh' atload'HISTDB_FILE="${ZDOTDIR}/.zsh-history.db"' \
  atinit'Zkeymaps+=("\Ce" _histdb-isearch)' trackbinds \
  cloneopts="--branch zsqlite" \
    Aloxaf/zsh-histdb \
  nocompletions \
    Aloxaf/zsh-sqlite \
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
  pick'autoenv.zsh' nocompletions \
  atload'AUTOENV_AUTH_FILE="${ZPFX}/share/autoenv/autoenv_auth"' \
    Tarrasch/zsh-autoenv \
  blockf \
    zdharma-continuum/zui \
    zdharma-continuum/zbrowse \
  patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset nocompile'!' blockf \
    psprint/zsh-navigation-tools \
  patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset nocompile'!' \
  atinit'alias wzman="ZMAN_BROWSER=w3m zman"
         alias zmand="info zsh "' \
    mattmc3/zman \
    anatolykopyl/doas-zsh-plugin \
  lman param'zs_set_path' \
    psprint/zsh-sweep \
  pick'timewarrior.plugin.zsh' nocompile blockf \
    svenXY/timewarrior
# bindkey -M histdb-isearch '\Cr' _histdb-isearch-up
# bindkey -M histdb-isearch '^[[A' _histdb-isearch-up
# bindkey -M histdb-isearch '\Cs' _histdb-isearch-down
# bindkey -M histdb-isearch '^[[B' _histdb-isearch-down
# bindkey -M histdb-isearch '\Cn' _histdb-isearch-cd
# bindkey -M histdb-isearch '\Ch' _histdb-isearch-toggle-host
# bindkey -M histdb-isearch '\Cd' _histdb-isearch-toggle-dir
# larkery/zsh-histdb \

zflai-log "zinit" "Plugins" $ztmp
#  ]]] === wait'0b' ===

# === wait'0c' - git plugins === [[[
zt 0c light-mode for \
  lbin'!' patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset nocompletions \
  atinit'_w_db_faddf() { dotbare fadd -f; }; zle -N db-faddf _w_db_faddf' \
  pick'dotbare.plugin.zsh' desc'dotfile plugin manager' \
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
    arzzen/git-quick-stats \
  lbin binary \
    Fakerr/git-recall \
  lbin'(git-now*|gitnow-common)' lbin'shFlags/src/shflags -> gitnow-shFlags' \
  binary cloneopts'--recursive' make"PREFIX=$ZPFX" reset \
    iwata/git-now

  # TODO: zinit recall
  # zdharma/zsh-unique-id \
# ]]]

# === wait'0c' - programs - sourced === [[[
ztmp=$EPOCHREALTIME
zt 0c light-mode binary for \
  lbin'!**/*grep;**/*man;**/*diff' has'bat' atpull'%atclone' \
  atclone'(){local f;builtin cd -q src;for f (*.sh){mv ${f} ${f:r}};}' \
  atload'alias bdiff="batdiff" bm="batman" bgrep="env -u RIPGREP_CONFIG_PATH batgrep"' \
    eth-p/bat-extras \
  lbin'cht.sh -> cht' id-as'cht.sh' reset-prompt \
    https://cht.sh/:cht.sh \
  lbin'!src/pt*(*)' patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset \
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
  make"install PREFIX=$ZPFX" atpull'make clean' atpull'%atclone' \
    KoffeinFlummi/htop-vim \
  lbin lman patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset \
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
  lbin patch"${Zdirs[PATCH]}/%PLUGIN%.patch" make"PREFIX=$ZPFX install" reset \
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
  lbin patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset atclone'cargo br' \
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
  lbin patch"${Zdirs[PATCH]}/%PLUGIN%.patch" reset atclone'cargo br' atclone"$(mv_clean)" \
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
  lbin'rgr' lman reset atclone'cargo br' atclone"$(mv_clean rgr)" \
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
  desc'Dotfiles manager thingy TODO: use this' \
    hlmtre/homemaker \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  desc'Builds inventory of file hashes in a directory' \
    rdmitr/inventorize \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' reset \
  desc'Easily compress/decompress files' \
    magiclen/xcompress \
  lbin atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
  atclone"./rip completions --shell zsh > _rip" \
  desc'Trash command with undoing' \
    lmburns/rip \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  eval'command sauce --shell zsh shell init' \
    dancardin/sauce \
  lbin atclone'cargo br' atclone"$(mv_clean petname)" atpull'%atclone' \
  desc'Generate word phrases' \
    allenap/rust-petname \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  desc'Overwrite a file in a series of pipes (usually not possible)' \
    neosmart/rewrite \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atload'alias orgr="organize-rt"' \
    lmburns/organize-rt \
  lbin atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  atload'alias touch="feel"' \
  desc'Colorized touch command in Rust' \
    lmburns/feel \
  lbin'parallel -> par' atclone'cargo br' atclone"$(mv_clean)" atpull'%atclone' \
  desc'GNU parallel command in Rust' \
    lmburns/parallel \
  lbin atclone'cargo br --features=backend-gpgme' atpull'%atclone' \
  atclone"$(mv_clean)" atclone'./prs internal completions zsh' \
  desc'GNU pass command in Rust' \
    lmburns/prs \
  lbin'tidy-viewer -> tv' atclone'cargo br' atclone"$(mv_clean tidy-viewer)" atpull'%atclone' \
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
  lbin'rusty-man' atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
  atinit'alias rman="rusty-man"
         alias rmang="rman --source=$RUST_SYSROOT/share/doc/rust/html"
         alias rmand="rman --source=$RUSTDOC_DIR"
         alias rmano="handlr open https://git.sr.ht/~ireas/rusty-man"' \
    yasuo-ozu/rusty-man
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
  lbin'**/delta' from'gh-r' patch"${Zdirs[PATCH]}/%PLUGIN%.patch" \
    dandavison/delta \
  lbin from'gh-r' lman \
  desc'Open git repo in browser' \
    rhysd/git-brws \
  lbin from'gh-r' \
    isacikgoz/gitbatch \
  lbin'tar*/rel*/mgit' atclone'cargo br' atpull'%atclone' \
  desc'Run a git command on multiple repositories' \
    koozz/mgit \
  lbin"git-(url|guclone);**/zgiturl" lman make cloneopts'--recursive' \
  desc'Encode git URLs, creating a new protocol' \
    zdharma-continuum/git-url \
  lbin from'gh-r' \
  desc'Multi git repo helper' \
    tshepang/mrh \
  lbin'git-xargs' atclone'go build' atpull'%atclone' \
  desc'Make updates across multiple repositories' \
    gruntwork-io/git-xargs \
  lbin"git-cal" atclone'perl Makefile.PL PREFIX=$ZPFX' \
  atpull'%atclone' make \
  desc'Github like contributions calendar on terminal' \
    k4rthik/git-cal \
  lbin lman atclone'cargo br' atpull'%atclone' atclone"$(mv_clean)" \
  desc'Keep track of all the git repositories on your machine' \
    peap/git-global
# ]]] === git specific block ===
# ]]] === wait'0c' - programs ===

# === Testing [[[
zt 0c light-mode for \
  pipx'jrnl' id-as'jrnl' \
    $null
# gem'!kramdown' id-as'kramdown' null $null
# binary cargo'!viu' id-as"$(id_as viu)" $null
# === Testing ]]]
zflai-log "zinit" "Binary" $ztmp

# === snippet block === [[[
ztmp=$EPOCHREALTIME
# Don't have to be recompiled to use
zt light-mode nocompile is-snippet for $ZDOTDIR/plugins/*.zsh
zt light-mode is-snippet for $ZDOTDIR/snippets/*.zsh
zt light-mode is-snippet for $ZDOTDIR/snippets/bundled/*.(z|)sh
zt light-mode is-snippet for $ZDOTDIR/snippets/zle/*.zsh
zflai-log "zinit" "Snippet" $ztmp
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

sourcef 60
zt 0b light-mode null id-as nocd for multisrc="$ZRCDIR/${^sourced[@]}" $null
zflai-log "srcf" "---------- Time" $sourcestart "----------"

ztmp=$EPOCHREALTIME
#===== variables ===== [[[
zt 0a light-mode run-atpull nocd nocompile'!' for \
  id-as'zoxide_init' has'zoxide' eval'zoxide init --no-cmd --hook prompt zsh' \
  atload'alias o=__zoxide_z z=__zoxide_zi' \
    $null \
  id-as'keychain_init' has'keychain' \
  eval'keychain --agents ssh -q --inherit any --eval burnsac git gitlab \
    && keychain --agents gpg -q --eval 0xC011CBEF6628B679' \
    $null
#     && keychain --agents ssh -q --inherit any --eval git \
#     && keychain --agents ssh -q --inherit any --eval gitlab \

zt 1a light-mode run-atpull nocd nocompile'!' for \
  id-as'pipx_comp' has'pipx' eval"register-python-argcomplete pipx" \
  atload'zicdreplay -q' \
    $null \
  id-as'pyenv_init' has'pyenv' eval'pyenv init - zsh' \
    $null \
  id-as'pipenv_comp' has'pipenv' eval'_PIPENV_COMPLETE=zsh_source pipenv' \
    $null \
  id-as'navi_comp' has'navi' eval'navi widget zsh' \
    $null

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

zflai-log "zinit" "Comp/Cache" $ztmp
# ]]]

zt 1a light-mode nocd for \
  id-as multisrc="$ZRCDIR/${^files[@]}" \
    $null \
  id-as'Cleanup' atinit'unset -f zt grman mv_clean has id_as sourcef zflai-zprof;
  unset discard_fn ztmp files;
  _zsh_autosuggest_bind_widgets' \
    $null

# == sourcing === [[[
zt 0b light-mode null id-as for \
  atload'export FAST_WORK_DIR=XDG;
  fast-theme XDG:kimbox.ini &>/dev/null' \
    $null

zt 0c light-mode null id-as for \
  atload'local x="$ZRCDIR/non-config/goenv.zsh"; [ -s "$x" ] && source "$x"' \
  has'goenv' \
    $null \
  atload'local x="$ZRCDIR/non-config/prll.sh"; [ -s "$x" ] && source "$x"' \
    $null

zflai-log "zinit" "All" $zstart

#   atinit'export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
#          export NVM_COMPLETION=true' \
#   atload'local x="$NVM_DIR/nvm.sh"; [ -s "$x" ] && source "$x"' \
#     $null \

#   atinit'
#   export PERLBREW_ROOT="${XDG_DATA_HOME}/perl5/perlbrew";
#   export PERLBREW_HOME="${XDG_DATA_HOME}/perl5/perlbrew-h";
#   export PERL_CPANM_HOME="${XDG_DATA_HOME}/perl5/cpanm"' \
#   atload'local x="$PERLBREW_ROOT/etc/bashrc"; [ -s "$x" ] && source "$x"' \
#   has'perlbrew' \
#     $null \

# `GOROOT/GOPATH` needs to be added after `goenv init`
# path=( $GOROOT/bin(N-/) "${path[@]}" $GOPATH/bin(N-/) )

# Recache keychain if older than GPG cache time or first login
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

# Set up aliases
[[ -f $ZDOTDIR/aliases/*[^~](#qNY1.,@) ]] && for REPLY in $ZDOTDIR/aliases/*[^~](.,@); do
  REPLY="$REPLY:t=$(<$REPLY)"
  alias "${${REPLY#*=}%%:*}" "${(M)REPLY##[^=]##}=${REPLY#*:}"
done
# ]]]

source $ZRCDIR/*-paths.zsh
zflai-msg "[file]:   => 00-paths.zsh"
zflai-msg "[zshrc]: ----- File Time ${(M)$((SECONDS * 1000))#*.?}ms ----------"
# zflai-msg "[zshrc]: Modules: ${(j:, :@)${(k)modules[@]}/zsh\/}"
zflai-zprof

# vim: set sw=0 ts=2 sts=2 et ft=zsh
