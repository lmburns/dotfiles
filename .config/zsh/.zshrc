############################################################################
#    Author: Lucas Burns                                                   #
#     Email: burnsac@me.com                                                #
#      Home: https://github.com/lmburns                                    #
############################################################################

# TODO: zsh notify

# === general settings === [[[
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

umask 022

typeset -gaxU path fpath manpath infopath cdpath
typeset -fuz zkbd

typeset -ga mylogs
typeset -F4 SECONDS=0
function zflai-msg()    { mylogs+=( "$1" ); }
function zflai-assert() { mylogs+=( "$4"${${${1:#$2}:+FAIL}:-OK}": $3" ); }

zflai-msg "[path] $path"

typeset -g DIRSTACKSIZE=20
typeset -g HISTSIZE=10000000
typeset -g HISTFILE="${XDG_CACHE_HOME}/zsh/zsh_history"
typeset -g SAVEHIST=8000000
typeset -g HIST_STAMPS="yyyy-mm-dd"
typeset -g HISTORY_IGNORE="(youtube-dl|you-get)"
typeset -g TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'
typeset -g PROMPT_EOL_MARK=''
typeset -g ZLE_SPACE_SUFFIX_CHARS=$'&|'
typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)'
typeset -g MAILCHECK=0
# typeset -g ZSH_DISABLE_COMPFIX=true

setopt hist_ignore_space    append_history      hist_ignore_all_dups  no_hist_no_functions
setopt share_history        inc_append_history  extended_history      cdable_vars
setopt auto_menu            complete_in_word    always_to_end         nohup
setopt autocd               auto_pushd          pushd_ignore_dups     rc_quotes
setopt pushdminus           pushd_silent        interactive_comments  hash_cmds
setopt glob_dots            extended_glob       menu_complete         hash_list_all
setopt no_flow_control      no_case_glob        notify                hist_fcntl_lock
setopt long_list_jobs       no_beep             multios               numeric_glob_sort
setopt prompt_subst         no_mail_warning

# don't error out when unset parameters are used?
setopt unset

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

fpath=( ${0:h}/{functions,completions} "${fpath[@]}")
autoload -Uz $fpath[1]/*(:t)
module_path+=( "$ZINIT[BIN_DIR]/zmodules/Src" ); zmodload zdharma/zplugin &>/dev/null

# zstyle ':completion:*' recent-dirs-insert fallback
# zstyle ':chpwd:*' recent-dirs-file "${TMPDIR}/chpwd-recent-dirs"
zmodload -F zsh/parameter p:dirstack
autoload -Uz chpwd_recent_dirs add-zsh-hook cdr
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-file "${ZDOTDIR}/chpwd-recent-dirs"
dirstack=( ${(u)^${(@fQ)$(<${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null)}[@]:#(\.|$PWD|/tmp/*)}(N-/) )
[[ ${PWD} = ${HOME} || ${PWD} = "." ]] && (){
  local dir
  for dir ($dirstack) {
    [[ -d "${dir}" ]] && { cd -q "${dir}"; break }
  }
} 2>/dev/null
alias c=cdr
# ]]]

# === zinit === [[[
zt(){ zinit depth'3' lucid ${1/#[0-9][a-c]/wait"${1}"} "${@:2}"; }
grman() {
  local graw="https://raw.githubusercontent.com"; local -A opts
  # FIX: is zinit substitute needed?
  zparseopts -D -E -A opts -- r: e: ; @zinit-substitute
  print -r "${graw}/%USER%/%PLUGIN%/master/${@:1}${opts[-r]:-%PLUGIN%}.${opts[-e]:-1}";
}

# FIX:
cclean() { command mv -f "tar*/rel*/%PLUGIN%" && cargo clean; }

{
  [[ ! -f $ZINIT[BIN_DIR]/zinit.zsh ]] && {
    command mkdir -p "$ZINIT_HOME" && command chmod g-rwX "$ZINIT_HOME"
    command git clone https://github.com/lmburns/zinit "$ZINIT[BIN_DIR]"
  }
} always {
  builtin source "$ZINIT[BIN_DIR]/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit
}

# === annex, prompt === [[[
zt light-mode for \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-submods \
  NICHOLAS85/z-a-linkman \
  NICHOLAS85/z-a-linkbin \
  atinit'Z_A_USECOMP=1' \
  NICHOLAS85/z-a-eval

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
        lbin atclone'cargo build --release --features=notify-rust' atpull'%atclone' \
        atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
        atclone'./starship completions zsh > _starship' atload'alias ntheme="$EDITOR $STARSHIP_CONFIG"' \
        starship/starship
    }
  } || print -P "%F{4}Theme ${1} not found%f"
} "${MYPROMPT=p10k}"

add-zsh-hook chpwd chpwd_ls
# ]]] === annex, prompt ===

# === trigger-load block ===[[[
# unsure why only works with number
zt 0a light-mode for \
  is-snippet trigger-load'!x' blockf svn \
    OMZ::plugins/extract \
  trigger-load'!bd' pick'bd.zsh' \
    tarrasch/zsh-bd \
  trigger-load'!man' \
    ael-code/zsh-colored-man-pages \
  patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' \
  trigger-load'!updatelocal' blockf compile'f*/*~*.zwc' \
    NICHOLAS85/updatelocal \
  trigger-load'!zhooks' \
    agkozak/zhooks \
  trigger-load'!ugit' \
    Bhupesh-V/ugit \
  trigger-load'!ga;!grh;!grb;!glo;!gd;!gcf;!gco;!gclean;!gss;!gcp;!gcb' \
    wfxr/forgit \
  trigger-load'!gcomp' blockf \
  atclone'command rm -rf lib/*;git ls-files -z lib/ |xargs -0 git update-index --skip-worktree' \
  submods'RobSis/zsh-completion-generator -> lib/zsh-completion-generator;
  nevesnunes/sh-manpage-completions -> lib/sh-manpage-completions' \
  atload'gcomp(){gencomp "${@}" && zinit creinstall -q "${GENCOMP_DIR}" 1>/dev/null}' \
    Aloxaf/gencomp \
  trigger-load'!hist' blockf nocompletions compile'f*/*~*.zwc' \
    marlonrichert/zsh-hist
# ]]] === trigger-load block ===

# OMZP::sudo/sudo.plugin.zsh

# === wait'0a' block === [[[
zt 0a light-mode for \
  atload'zstyle ":completion:*" special-dirs false' \
    OMZ::lib/completion.zsh \
  as'completion' atpull'zinit cclear' blockf \
    zsh-users/zsh-completions \
  ver'develop' atload'_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions \
  as'completion' nocompile mv'*.zsh -> _git' \
    felipec/git-completion \
  pick'you-should-use.plugin.zsh' \
    MichaelAquilina/zsh-you-should-use \
  lbin'!' patch"${pchf}/%PLUGIN%.patch" reset \
  atinit'_w_db_faddf() { dotbare fadd -f; }; zle -N db-faddf _w_db_faddf' \
  pick'dotbare.plugin.zsh' \
    kazhala/dotbare \
  lbin'!' atload'export BMUX_DIR="$XDG_CONFIG_HOME/bmux"' \
  atinit'_wbmux() { bmux }; zle -N _wbmux' \
    kazhala/bmux \
    anatolykopyl/doas-zsh-plugin \
  pick'timewarrior.plugin.zsh' \
    svenXY/timewarrior \
    zdharma-continuum/zflai \
  pick'async.zsh' \
    mafredri/zsh-async \
  patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' blockf \
    psprint/zsh-navigation-tools

# ]]] === wait'0a' block ===

  # blockf nocompletions compile'functions/*~*.zwc' \
  #   marlonrichert/zsh-edit \

#  === wait'0b' - patched === [[[
zt 0b light-mode patch"${pchf}/%PLUGIN%.patch" reset nocompile'!' for \
  atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' \
    hlissner/zsh-autopair \
  trackbinds bindmap'\e[1\;6D -> ^[[1\;6D; \e[1\;6C -> ^[[1\;6C' \
    michaelxmcbride/zsh-dircycle \
  trackbinds bindmap'^G -> ^N' \
    andrewferrier/fzf-z \
  atload'add-zsh-hook chpwd @chwpd_dir-history-var;
  add-zsh-hook zshaddhistory @append_dir-history-var; @chwpd_dir-history-var now' \
    kadaan/per-directory-history \
  atinit'zicompinit_fast; zicdreplay;' atload'unset "FAST_HIGHLIGHT[chroma-man]"' \
  atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- ${f}};}' \
  compile'.*fast*~*.zwc' nocompletions atpull'%atclone' \
    zdharma-continuum/fast-syntax-highlighting \
  atload'vbindkey "Up" history-substring-search-up; vbindkey "Down" history-substring-search-down' \
    zsh-users/zsh-history-substring-search
#  ]]] === wait'0b' - patched ===

#  === wait'0b' === [[[
zt 0b light-mode for \
  blockf compile'lib/*f*~*.zwc' \
    Aloxaf/fzf-tab \
  autoload'#manydots-magic' \
    knu/zsh-manydots-magic \
    RobSis/zsh-reentry-hook \
  compile'h*' trackbinds bindmap'^R -> ^F' \
  atload'
  zstyle ":history-search-multi-word" highlight-color "fg=cyan,bold";
  zstyle ":history-search-multi-word" page-size "16"' \
    zdharma-continuum/history-search-multi-word \
  pick'autoenv.zsh' nocompletions \
  atload'AUTOENV_AUTH_FILE="${ZPFX}/share/autoenv/autoenv_auth"' \
    Tarrasch/zsh-autoenv \
    zdharma-continuum/zui \
    zdharma-continuum/zbrowse \
  atload'
  zstyle ":notify:*" expire-time 6
  zstyle ":notify:*" error-title "Command failed (in #{time_elapsed} seconds)"
  zstyle ":notify:*" success-title "Command finished (in #{time_elapsed} seconds)"
  ' \
    marzocchi/zsh-notify
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
  lbin atload'alias gi="git-ignore"'\
    laggardkernel/git-ignore \
  lbin'f*~*.zsh' pick'*.zsh' atinit'alias fs="fstat"' \
    lmburns/fzfgit \
  patch"${pchf}/%PLUGIN%.patch" reset \
  lbin'!src/pt*(*)' \
  atclone'(){local f;builtin cd -q src;for f (*.sh){mv ${f} ${f:r:l}};}' \
  atclone"command mv -f config $ZPFX/share/ptSh/config" \
  atload'alias ppwd="ptpwd" mkd="ptmkdir -pv"' \
    jszczerbinsky/ptSh \
  lbin atclone"mkdir -p $XDG_CONFIG_HOME/ytfzf; cp **/conf.sh $XDG_CONFIG_HOME/ytfzf" \
    pystardust/ytfzf \
  lbin from'gl' atclone'./prebuild; ./configure --prefix="$ZPFX"; make' \
  make"install"  atpull'%atclone' \
    surfraw/Surfraw \
  lbin atclone'./autogen.sh; ./configure --prefix="$ZPFX"; make' \
  make"install"  atpull'%atclone' lman \
    kfish/xsel \
  lbin atclone'./configure --prefix="$ZPFX"; make' \
  make"install" atpull'%atclone' lman \
    tats/w3m \
  lbin atclone'./autogen.sh && ./configure --enable-unicode --prefix="$ZPFX"' \
  make'install' atpull'%atclone' lman \
    KoffeinFlummi/htop-vim \
  lbin atclone'./autogen.sh && ./configure --prefix=$ZPFX' \
  make"install PREFIX=$ZPFX" atpull'%atclone' lman \
    tmux/tmux \
  atclone'local d="$XDG_CONFIG_HOME/tmux/plugins";
  [[ ! -d "$d" ]] && mkdir -p "$d"; ln -sf %DIR% "$d/tpm"' \
  atpull'%atclone' \
    tmux-plugins/tpm \
  lbin lman \
    sdushantha/tmpmail \
  lbin'**/rga;**/rga-*' from'gh-r' mv'rip* -> rga' \
    phiresky/ripgrep-all \
  lbin from'gh-r' \
  atinit'export NAVI_FZF_OVERRIDES="--height=70%"' \
    denisidoro/navi \
  lbin atload'alias palette::full="ansi --color-codes" palette::codes="ansi --color-table"' \
    fidian/ansi \
  lbin atclone"./build.zsh" mv"*.*completion -> _zunit" atpull"%atclone" \
    molovo/zunit

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
  lbin'**/gh' atclone'./**/gh completion --shell zsh > _gh' atpull'%atclone' \
  bpick'*linux_amd64.tar.gz' \
    cli/cli \
  lbin'**/hub' extract'!' atclone'mv -f **/**.zsh* _hub' atpull'%atclone' \
    @github/hub \
  lbin'rclone/rclone' mv'rclone* -> rclone' \
  atclone'./rclone/rclone genautocomplete zsh _rclone' \
  atpull'%atclone' \
    rclone/rclone \
  lman'*/**.1' atinit'export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"' \
    ajeetdsouza/zoxide
#  ]]] === wait'0c' - programs + man ===

#  === wait'0c' - programs === [[[
zt 0c light-mode null for \
  lbin from'gh-r' dl"$(grman man/man1/ -r sk)" lman \
    lotabout/skim \
  multisrc'shell/{completion,key-bindings}.zsh' id-as'skim_comp' pick'/dev/null' \
    lotabout/skim \
  lbin from'gh-r' dl"$(grman man/man1/)" lman \
    junegunn/fzf \
  multisrc'shell/{completion,key-bindings}.zsh' id-as'fzf_comp' pick'/dev/null' \
  atload"bindkey -r '\ec'; bindkey '^[c' fzf-cd-widget" \
    junegunn/fzf \
  lbin'antidot* -> antidot' from'gh-r' atclone'./**/antidot* update 1>/dev/null' \
  atpull'%atclone' \
    doron-cohen/antidot \
  lbin'xurls* -> xurls' from'gh-r' \
    @mvdan/xurls \
  lbin'q -> dq' from'gh-r' bpick'*linux*gz' \
    natesales/q \
  lbin'a*.pl -> arranger' \
  atclone'mkdir -p $XDG_CONFIG_HOME/arranger; cp *.conf $XDG_CONFIG_HOME/arranger' \
    anhsirk0/file-arranger \
  lbin'*/*/lax' atclone'cargo install --path .' atpull'%atclone'  \
    Property404/lax \
  lbin'*/*/desed' atclone'cargo install --path .' dl"$(grman)" lman \
    SoptikHa2/desed \
  lbin'f2' from'gh-r' bpick'*linux_amd64*z' \
    ayoisaiah/f2 \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo build --release' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atpull'%atclone' has'cargo' \
    crockeo/taskn \
  lbin"!**/nvim" from'gh-r' lman \
    neovim/neovim \
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
  lbin'sops* -> sops' from'gh-r' \
    mozilla/sops \
  lbin'q-* -> q' from'gh-r' \
    harelba/q \
  lbin lman make"YANKCMD='xsel -b' PREFIX=$ZPFX install" \
    mptre/yank \
  lbin'uni* -> uni' from'gh-r' \
    arp242/uni \
  lbin'dad;diana' atinit'export DIANA_DOWNLOAD_DIR="$HOME/Downloads/Aria"' \
    baskerville/diana \
  lbin has'recode' \
    Bugswriter/tuxi \
  lbin from'gh-r' \
    orf/gping \
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
    muesli/duf \
  lbin patch"${pchf}/%PLUGIN%.patch" make"PREFIX=$ZPFX install" reset \
  atpull'%atclone' atdelete"PREFIX=$ZPFX make uninstall"  \
    zdharma-continuum/zshelldoc \
  lbin from'gh-r' bpick'*linux_amd*gz' \
  atload"source $ZPFX/share/pet/pet_atload.zsh" \
    knqyf263/pet \
  lbin from'gh-r' atload'alias of="onefetch"' \
    o2sh/onefetch \
  id-as'bisqwit/regex-opt' lbin atclone'xh --download https://bisqwit.iki.fi/src/arch/regex-opt-1.2.4.tar.gz' \
  atclone'ziextract --move --auto regex-*.tar.gz' make'all' \
    zdharma-zmirror/null

# yq isn't picking up completions

# eval"atuin init zsh | sed 's/bindkey .*\^\[.*$//g'"
# greymd/teip
# == rust [[[
zt 0c light-mode null for \
  lbin'ff* -> ffsend' from'gh-r' \
    timvisee/ffsend \
  lbin from'gh-r' \
    rami3l/pacaptr \
  lbin from'gh-r' \
    pemistahl/grex \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo build --release' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    XAMPPRocky/tokei \
  lbin atclone'cargo build --release' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atpull'%atclone' has'cargo' \
    atanunq/viu \
  lbin from'gh-r' \
    ms-jpq/sad \
  lbin from'gh-r' \
    ducaale/xh \
  lbin from'gh-r' \
    itchyny/mmv \
  lbin from'gh-r' eval"atuin init zsh | sed 's/bindkey .*\^\[.*$//g'" \
  atload'alias clean-atuin="kill -9 $(lsof -c atuin -t)"' \
    ellie/atuin \
  lbin'* -> sd' from'gh-r' \
    chmln/sd \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atpull'%atclone' \
    lmburns/hoard \
  lbin'*/ruplacer' from'gh-r' atinit'alias rup="ruplacer"' \
    dmerejkowsky/ruplacer \
  lbin'*/rgr' from'gh-r' lman \
    acheronfail/repgrep \
  lbin'* -> renamer' from'gh-r' \
    adriangoransson/renamer \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    pkolaczk/fclones \
  lbin atclone'cargo build --release' \
  atclone"command mv -f tar*/rel*/tldr . && cargo clean" \
  atclone"mv -f zsh_* _tldr" \
    dbrgn/tealdeer \
  lbin'pueued-* -> pueued' lbin'pueue-* -> pueue' from'gh-r' \
  bpick'*ue-linux-x86_64' bpick'*ued-linux-x86_64' \
    Nukesor/pueue \
  lbin from'gh-r' bpick'*lnx.zip' \
    @dalance/procs \
  lbin atclone"cargo install --path ." atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    imsnif/bandwhich \
  lbin atclone"cargo build --release" atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    theryangeary/choose \
  lbin'* -> hck' from'gh-r' \
    sstadick/hck \
  lbin from'gh-r' \
    BurntSushi/xsv \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/dua . && cargo clean" \
    Byron/dua-cli \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/lolcate . && cargo clean" \
  atload'alias le=lolcate' \
    lmburns/lolcate-rs \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atload'export FW_CONFIG_DIR="$XDG_CONFIG_HOME/fw"; alias wo="workon"' \
    brocode/fw \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    WindSoilder/hors \
  lbin from'gh-r' \
    samtay/so \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atclone'./podcast completion > _podcast' \
    njaremko/podcast \
  lbin from'gh-r' \
    rcoh/angle-grinder \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/hm . && cargo clean" \
    hlmtre/homemaker \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    rdmitr/inventorize \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo build --release' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" atpull'%atclone' \
    magiclen/xcompress \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    miserlou/loop \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atclone"./rip completions --shell zsh > _rip" \
    lmburns/rip \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  eval'sauce --shell zsh shell init' \
    dancardin/sauce \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/petname . && cargo clean" \
    allenap/rust-petname \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    neosmart/rewrite \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atclone"./rualdi completions shell zsh > _rualdi" \
  atload'alias ru="rualdi"' eval'rualdi init zsh --cmd k' \
    lmburns/rualdi \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atload'alias orgr="organize-rt"' \
    lmburns/organize-rt \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atload'alias touch="feel"' \
    lmburns/feel \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atload"alias par='parallel'" \
    lmburns/parallel \
  lbin patch"${pchf}/%PLUGIN%.patch" reset atclone'cargo build --release --features=backend-gpgme' \
  atpull'%atclone' atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  atclone'./prs internal completions zsh' \
    timvisee/prs \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/tidy-viewer . && cargo clean" \
  atload"alias tv='tidy-viewer'" \
    alexhallam/tv \
  lbin from'gh-r' \
    evansmurithi/cloak \
  lbin from'gh-r' \
    lotabout/rargs
  # lbin atclone'cargo build --release' atpull'%atclone' \
  # atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  # atclone"emplace init zsh | tail -n +20 > _emplace" \
  # eval'emplace init zsh | head -n 20' atload"alias em='emplace'" \
  # atload'export EMPLACE_CONFIG="$XDG_CONFIG_HOME/emplace/emplace.toml"' \
  #   lmburns/emplace

  # lbin atclone'cargo build --release' atpull'%atclone'  \
  # atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
  # atclone'./wutag print-completions --shell zsh > _wutag' \
  #   lmburns/wutag \

# === rust extensions === [[[
zt 0c light-mode null for \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    fornwall/rust-script \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    reitermarkus/cargo-eval \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    fanzeyi/cargo-play \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    matthiaskrgr/cargo-cache \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    iamsauravsharma/cargo-trim \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    razrfalcon/cargo-bloat \
  lbin from'gh-r' \
    est31/cargo-udeps \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    andrewradev/cargo-local \
  lbin'tar*/rel*/cargo-{rm,add,upgrade}' atclone'cargo build --release' atpull'%atclone' \
    killercup/cargo-edit \
  lbin'{cargo-make,makers}' atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/{cargo-make,makers} . && cargo clean" \
  atload'export CARGO_MAKE_HOME="$XDG_CONFIG_HOME/cargo-make"' \
  atload'alias ncmake="$EDITOR $CARGO_MAKE_HOME/Makefile.toml"' \
  atload'alias cm="makers --makefile $CARGO_MAKE_HOME/Makefile.toml"' \
    sagiegurari/cargo-make \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    celeo/cargo-nav \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    g-k/cargo-show \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    mre/cargo-inspect \
  lbin from'gh-r' \
    cargo-generate/cargo-generate \
  lbin from'gh-r' \
    yozhgoor/cargo-temp \
  lbin'tar*/rel*/evcxr' atclone'cargo build --release' atpull'%atclone' \
    google/evcxr \
  lbin atclone'cargo build --release --all-features' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    Canop/bacon \
  lbin'rusty-man' atclone'command git clone https://git.sr.ht/~ireas/rusty-man' \
  atclone'command rsync -vua --delete-after rusty-man/ .' \
  atclone'cargo build --release && cargo doc' atpull'%atclone' id-as'sr-ht/rusty-man' \
  atclone"command mv -f rusty*/tar*/rel*/rusty-man . && cargo clean" \
  atinit'alias rman="rusty-man" rmand="handlr open https://git.sr.ht/~ireas/rusty-man"' \
    zdharma-zmirror/null \
  lbin atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    sminez/roc
# ]]] == rust extensions
# ]]] == rust

# === tui specific block === [[[
zt 0c light-mode null for \
  lbin from'gh-r' \
    wagoodman/dive \
  lbin'*/*/gpg-tui' atclone'cargo build --release' atpull'%atclone' \
  atclone"command mv -f tar*/rel*/%PLUGIN% . && cargo clean" \
    orhun/gpg-tui \
  lbin from'gh-r' ver'nightly' \
    ClementTsang/bottom \
  lbin from'gh-r' dl"$(grman)" lman \
    gokcehan/lf \
  lbin from'gh-r' \
  atinit'export XPLR_BOOKMARK_FILE="$XDG_CONFIG_HOME/xplr/bookmarks"' \
    sayanarijit/xplr \
  lbin from'gh-r' atload'alias ld="lazydocker"' \
    jesseduffield/lazydocker
# ]]] === tui specifi block ===

# lbin from'gh-r' atload'alias tt="taskwarrior-tui"' \
#   kdheepak/taskwarrior-tui \

# === git specific block === [[[
zt 0c light-mode null for \
  lbin from'gh-r' \
    isacikgoz/gitbatch \
  lbin from'gh-r' atload'alias lg="lazygit"' \
    jesseduffield/lazygit \
  lbin from'gh-r' blockf \
  atload'export GHQ_ROOT="$HOME/ghq"' \
    x-motemen/ghq \
  lbin from'gh-r' \
    Songmu/ghg \
  lbin from'gh-r' \
    human37/gee \
  lbin atclone'./autogen.sh; ./configure --prefix="$ZPFX"; mv -f **/**.zsh _tig' \
  make'install' atpull'%atclone' mv"_tig -> $ZINIT[COMPLETIONS_DIR]" \
    jonas/tig \
  lbin'*/delta;git-dsf' from'gh-r' patch"${pchf}/%PLUGIN%.patch" \
  atload'alias dsf="git-dsf"' \
    dandavison/delta \
  lbin from'gh-r' \
    extrawurst/gitui \
  lbin from'gh-r' lman \
    rhysd/git-brws \
  lbin'tar*/rel*/mgit' atclone'cargo build --release' atpull'%atclone' \
    koozz/mgit
# ]]] === git specific block ===

# tshepang/mrh
# cosmos72/gomacro == gruntwork-io/git-xargs

#  ]]] === wait'0c' - programs ===

#  === snippet block === [[[
zt light-mode is-snippet for \
  atload'zle -N RG; bindkey "^P" RG' \
    $ZDOTDIR/csnippets/*.zsh
#  ]]] === snippet block ===
# ]]] == zinit closing ===

# === powerlevel10k === [[[
[[ $MYPROMPT == p10k ]] && {
  if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
}
# ]]]

# === zsh keybindings === [[[
stty intr '^C'
stty susp '^Z'
stty stop undef
stty discard undef <$TTY >$TTY
zmodload zsh/zprof  # ztodo
zmodload zsh/attr   # extended attributes
# autoload -Uz sticky-note
autoload -Uz zmv zcalc zargs zed relative
alias fned="zed -f"
alias zmv='noglob zmv -v' zcp='noglob zmv -Cv' zln='noglob zmv -Lv' zmvn='noglob zmv -W'
alias run-help > /dev/null && unalias run-help
autoload +X -Uz run-help
zmodload -F zsh/parameter p:functions_source
autoload -Uz $functions_source[run-help]-*~*.zwc

# typeset -g HELPDIR='/usr/share/zsh/help'
# ]]]


# === completion === [[[

# $desc, $word, $group, $realpath
autoload -Uz zstyle+
zstyle+ \
  ':fzf-tab:complete' '' '' \
    + ':nvim:argument-rest' \
          fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':nvim:argument-rest' \
          fzf-bindings 'alt-e:execute-silent({_FTB_INIT_}nvim "$realpath" < /dev/tty > /dev/tty)' \
    + ':nvim:*' \
          fzf-preview 'r=$realpath; ([[ -f $r ]] && bat --style=numbers --color=always $r) \
                      || ([[ -d $r ]] && tree -C $r | less) || (echo $r 2> /dev/null | head -200)' \
    + ':updatelocal:argument-rest' \
          fzf-flags '--preview-window=down:5:wrap' \
    + ':updatelocal:argument-rest' \
          fzf-preview "git --git-dir=$UPDATELOCAL_GITDIR/\${word}/.git log --color \
                      --date=short --pretty=format:'%Cgreen%cd %h %Creset%s %Cred%d%Creset ||%b' ..FETCH_HEAD 2>/dev/null" \
    + ':systemctl-*:*'           fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word' \
    + ':systemctl-*:*'           fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':figlet:option-f-1'       fzf-preview 'figlet -f $word Hello world' \
    + ':figlet:option-f-1'       fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':complete:ssh:*'          fzf-preview 'dig $desc' \
    + ':complete:ssh:*'          fzf-flags '--preview-window=nohidden,right:65%:wrap' \
    + ':kill:*'                  popup-pad 0 3 \
    + ':(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap' \
    + ':(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps -p $word -o comm="" -w -w' \
    + ':cdr:*'                   fzf-preview 'exa -TL 3 --color=always ${~desc}' \
    + ':(exa|cd):*'              popup-pad 30 0 \
    + ':(exa|cd|cdr|cd_):*'      fzf-flags '--preview-window=nohidden,right:45%:wrap' \
    + ':(exa|cd|cd_):*' \
          fzf-preview '[[ -d $realpath ]] && exa -T --color=always $(readlink -f $realpath)' \
    + ':(cp|rm|rip|mv|bat):argument-rest' \
          fzf-preview 'r=$(readlink -f $realpath); bat --color=always -- $r || exa --color=always -- $r' \

zstyle+ ':fzf-tab:*' print-query ctrl-c \
      + ''           accept-line space \
      + ''           prefix '' \
      + ''           switch-group ',' '.' \
      + ''           single-group color header \
      + ''           fzf-pad 4 \
      + ''           fzf-bindings \
                        'enter:accept,backward-eof:abort,ctrl-a:toggle-all' \
                        'alt-shift-down:preview-down,alt-shift-up:preview-up' \
                        'alt-e:execute-silent({_FTB_INIT_}nvim "$realpath" < /dev/tty > /dev/tty)'

# zstyle ':fzf-tab:complete:cdr:*' fzf-preview 'exa -TL 3 --color=always ${${~${${(@s: → :)desc}[2]}}}'

zstyle '*' single-ignored show # ??

# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion::complete:*' cache-path "${ZDOTDIR}/.cache/.zcompcache"
# zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

# zstyle ':completion:*' completer _complete _expand _match _oldlist _list _ignored _correct _approximate
# 'm:{a-z\-}={A-Z\_}' 'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' 'r:|?=** m:{a-z\-}={A-Z\_}'

zstyle+ ':completion:*'   list-separator '→' \
      + ''                completer _complete _match _list _prefix _ignored _correct _approximate _oldlist \
      + ''                group-name '' \
      + ''                use-cache on \
      + ''                verbose yes \
      + ''                rehash true \
      + ''                squeeze-slashes true \
      + ''                accept-exact '*(N)' \
      + ''                ignore-parents parent pwd \
      + ''                matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' \
      + ''                list-colors ${(s.:.)LS_COLORS} \
      + ''                muttrc "$XDG_CONFIG_HOME/mutt/muttrc" \
      + ':manuals'        separate-sections true \
      + ':matches'        group 'yes' \
      + ':functions'      ignored-patterns '(_*|pre(cmd|exec))' \
      + ':approximate:*'  max-errors 1 numeric \
      + ':match:*'        original only \
      + ':messages'       format ' %F{purple} -- %d --%f' \
      + ':warnings'       format ' %F{1}-- no matches found --%f' \
      + ':corrections'    format '%F{5}!- %d (errors: %e) -!%f' \
      + ':default'        list-prompt '%S%M matches%s' \
      + ':descriptions'   format '[%d]' \
      + ':options'        description yes \
      + ':-tilde-:*'      group-order named-directories path-directories users expand \
      + ':cd:*'           tag-order local-directories directory-stack path-directories \
      + ':cd:*'           group-order local-directories path-directories \
      + ':git-checkout:*' sort false \
      + ':exa'            file-sort modification \
      + ':exa'            sort false \
      + ':sudo:*'         command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin \
      + ':sudo::'         environ PATH="$PATH" \
      + ':*:zcompile:*'   ignored-patterns '(*~|*.zwc)' \
      + ':(rm|rip|kill|diff|git-dsf):*' ignore-line other \
      + ':(rm|rip|git-dsf):*'           file-patterns '*:all-files' \
      + ':complete:-command-::commands' ignored-patterns '*\~' \
      + ':*:-subscript-:*'              tag-order indexes parameters \
      + ':*:-redirect-,2>,*:*'          file-patterns '*.log'

zstyle ':completion::complete:*' gain-privileges 1     # enabling autocompletion of privileged envs
zstyle ':completion::*:(-command-|export):*'        fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-} # env vars
zstyle ':completion::(^approximate*):*:functions'   ignored-patterns '_*' # ignore for cmds not in path
zstyle -e ':completion:*:approximate:*'             max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# DOEST WORK:
zstyle ':completion:*:*:cdh:*'     group-order local-directories recent-dirs path-directories
zstyle ':completion:*:*:cdh:*'     tag-order local-directories recent-dirs path-directories

zstyle ':completion:*:(scp|rsync):*'      group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*'              group-order users hosts-domain hosts-host users hosts-ipaddr

zstyle+ ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *' \
      + ':hosts-host' \
            ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost \
      + ':hosts-domain' \
            ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*' \
      + ':hosts-ipaddr' \
            ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

zstyle -e ':completion:*:hosts' hosts 'reply=(
      ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
      ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
      ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
    )'

# zstyle -e ':completion:*:(ssh|scp|sftp|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

local -a _ssh_hosts _etc_hosts hosts
[[ -r $HOME/.ssh/known_hosts ]] && _ssh_hosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*} ) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()

hosts=( $(hostname) "$_ssh_hosts[@]" "$_etc_hosts[@]" localhost )
zstyle ':completion:*:hosts' hosts $hosts

# ADD: completion patterns for others
# zstyle ':completion:*:*:ogg123:*'  file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
# zstyle ':completion:*:*:mocp:*'    file-patterns '*.(wav|df):ogg\ files *(-/):directories'
# ]]]

# === one line functions === [[[
function linkrust() {
  ln -v $XDG_DATA_HOME/just/rust_justfile $PWD/justfile
  ln -v $HOME/projects/rust/rustfmt.toml $PWD/rustfmt.toml
  command cp -v $HOME/projects/rust/.pre-commit-config.yaml $PWD/.pre-commit-config.yaml
}
# lsof open fd
zmodload -F zsh/system p:sysparams
function lsfd() { lsof -p $sysparams[ppid] | hck -f1,4,5- ; }
function cargo-bin() {
  root=${$(cargo locate-project | jq -r '.root'):h} bin=${root:t}
  binpath=${root}/target/release/${bin}
  if [[ -x $binpath ]] {
      command mv $binpath $root && cargo trim clear
  } elif [[ -x $root/$bin ]] {
      cargo trim clear
  }
}

function cargo-home() { cargo show "${@}" --json | jq -r .crate.homepage; }
# function cargo-take() { cargo new "$@" && builtin cd "$@"; }
# wrapper for rusty-man for tui
function rmant() { rusty-man "$1" --theme 'Solarized (dark)' --viewer tui "${@:2}"; }
function cdc() { builtin cd ${$(cargo locate-project | jq -r '.root'):h}; }
function cme() { $EDITOR ${$(cargo locate-project | jq -r '.root'):h}/src/main.rs; }
function cml() { $EDITOR ${$(cargo locate-project | jq -r '.root'):h}/src/lib.rs; }
function cmc() { $EDITOR ${$(cargo locate-project | jq -r '.root'):h}/Cargo.toml; }
# find functions that follow this pattern: func()
function ffunc() { eval "() { $functions[RG] } ${@}\\\\\("; }
# rsync from local pc to server
function rst() { rsync -uvrP $1 root@lmburns.com:$2 ; }
function rsf() { rsync -uvrP root@lmburns.com:$1 $2 ; }
function mvout-clean() { command rsync -vua --delete-after $1/ . ; }
function mvout() { command rsync -vua $1/ . ; }
# shred and delete file
function sshred() { shred -v -n 1 -z -u  $1;  }
# create py file to sync with ipynb
function jupyt() { jupytext --set-formats ipynb,py $1; }
# use up pipe with any file
function upp() { cat $1 | up; }
# crypto
function ratesx() { curl rate.sx/$1; }
# copy directory
function pbcpd() { builtin pwd | tr -d "\r\n" | xsel -b; }
# create file from clipboard
function pbpf() { xsel -b > "$1"; }
function pbcf() { xsel -b < "${1:-/dev/stdin}"; }
# backup files
function bak() { /usr/bin/cp -r --force --suffix=.bak $1 $1 }
function rbak() { /usr/bin/cp -r --force $1.bak $1 }
# only renames
function dbak-t()  { f2 -f "${1}$" -r "${1}.bak" -F; }
function dbak()    { f2 -f "${1}$" -r "${1}.bak" -Fx; }
function drbak-t() { f2 -f "${1}.bak$" -r "${1}" -F; }
function drbak()   { f2 -f "${1}.bak$" -r "${1}" -Fx; }
# link unlink file from mybin to $PATH
function lnbin() { ln -siv $HOME/mybin/$1 $XDG_BIN_HOME; }
function unlbin() { rm -v /$XDG_BIN_HOME/$1; }
# latex documentation serch (as best I can)
function latexh() { zathura -f "$@" "$HOME/projects/latex/docs/latex2e.pdf" }
# cd into directory
# function take() { mkdir -p $@ && cd ${@:$#} }
# html to markdown
function w2md() { wget -qO - "$1" | iconv -t utf-8 | html2text -b 0; }
# sha of a directory
function sha256dir() { fd . -tf -x sha256sum {} | cut -d' ' -f1 | sort | sha256sum | cut -d' ' -f1; }
function allcmds() { print -l ${commands[@]} | awk -F'/' '{print $NF}' | fzf; }
# remove broken symlinks
function rmsym() { command rm -- *(-@D); }
function rmsymr() { command rm -- **/*(-@D); }
# add -x to apply changes -- f2 -f ' '
function rmspace() { f2 -f '\s' -r '_' -RF $@ }
function rmdouble() { f2 -f '(\w+) \((\d+)\).(\w+)' -r '$2-$1.$3' $@ }
# monitor core dumps
function moncore() { fswatch --event-flags /cores/ | xargs -I{} notify-send "Coredump" {} }
# reload zsh function without sourcing zshrc
function freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }
function ee() { lax -f nvim "@${1}"; }
function time-zsh() { shell=${1-$SHELL}; for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done; }
function profile-zsh() { ZSHRC_PROFILE=1 zsh -i -c zprof | bat; }
function pj() { perl -MCpanel::JSON::XS -0777 -E '$ip=decode_json <>;'"$@" ; }
function jqy() { yq e -j "$1" | jq "$2" | yq - e; }
function ww() { (alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@; }
function jpeg() { jpegoptim -S "${2:-1000}" "$1"; jhead -purejpg "$1" && du -sh "$1"; }
function pngo() { optipng -o"${2:-3}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
function png() { pngquant --speed "${2:-4}" "$1"; exiftool -all= "$1" && du -sh "$1"; }
function td() { date -d "+${*}" "+%FT%R"; }
function ofd() { xdg-open $PWD; }
function double-accept() { deploy-code "BUFFER[-1]=''"; }
function wifi-info() { command iw dev ${${=${${(f)"$(</proc/net/wireless)"}:#*\|*}[1]}[1]%:} link; }

function cp-mac() { cp -r /run/media/lucas/exfat/macos-full/lucasburns/${1} ${2}; }

zle -N double-accept

function xd() {
  pth="$(xplr)"
  if [[ "$pth" != "$PWD" ]]; then
    if [[ -d "$pth" ]]; then
      cd "$pth"
    elif [[ -f "$pth" ]]; then
      cd "$(dirname "$pth")"
    fi
  fi
}

function zinit-palette() {
  for k ( "${(@kon)ZINIT[(I)col-*]}" ); do
    local i=$ZINIT[$k]
    print "$reset_color${(r:14:: :):-$k:} $i###########"
  done
}

# ]]]

# === helper functions === [[[
zshaddhistory() {
  emulate -L zsh
  # whence ${${(z)1}[1]} >| /dev/null || return 1 # doesn't add setting arrays
  [[ ${1%%$'\n'} != ${~HISTORY_IGNORE} ]]
}

_zsh_autosuggest_strategy_dir_history(){ # avoid zinit picking this up as a completion
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

_zsh_autosuggest_strategy_custom_history () {
  emulate -L zsh -o extended_glob
  local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
  local pattern="$prefix*"
  if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
    pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
  fi
  [[ "${history[(r)$pattern]}" != "$prefix" ]] && \
    typeset -g suggestion="${history[(r)$pattern]}"
}
# ]]]

# === paths (GNU) === [[[
[[ -z ${path[(re)$HOME/.local/bin]} ]] && path=( "$HOME/.local/bin" "${path[@]}" )
[[ -z ${path[(re)/usr/local/sbin]} ]]  && path=( "/usr/local/sbin"  "${path[@]}" )

# cdpath=( $HOME/{projects,}/github $XDG_CONFIG_HOME )

# hash -d git=$HOME/projects/github
# hash -d pro=$HOME/projects
# hash -d opt=$HOME/opt
hash -d ghq=$HOME/ghq

manpath=(
  $XDG_DATA_HOME/man
  $NPM_PACKAGES/share/man
  "${manpath[@]}"
)

path=(
  $HOME/mybin
  $HOME/texlive/2021/bin/x86_64-linux
  $HOME/mybin/linux
  $HOME/bin
  $HOME/.ghg/bin
  $PYENV_ROOT/{shims,bin}
  $GOENV_ROOT/bin(N-/)
  $CARGO_HOME/bin(N-/)
  $XDG_DATA_HOME/gem/bin(N-/)
  $HOME/.poetry/bin(N-/)
  $GEM_HOME/bin(N-/)
  $NPM_PACKAGES/bin(N-/)
  /usr/lib/goenv/libexec
  $(stack path --stack-root)/programs/x86_64-linux/ghc-tinfo6-8.10.7/bin
  "${path[@]}"
)
# ]]]

#===== completions ===== [[[
  zt 0c light-mode as'completion' for \
    id-as'poetry_comp' atclone='poetry completions zsh > _poetry' \
    atpull'%atclone' has'poetry' \
      zdharma-continuum/null \
    id-as'rust_comp' atclone'rustup completions zsh > _rustup' \
    atclone'rustup completions zsh cargo > _cargo' \
    atpull='%atclone' has'rustup' \
      zdharma-continuum/null \
    id-as'pueue_comp' atclone'pueue completions zsh "${GENCOMP_DIR}"' \
    atpull'%atclone' has'pueue' \
      zdharma-continuum/null
# ]]] ===== completions =====

#===== variables ===== [[[
zt 0c light-mode run-atpull for \
  id-as'pipx_comp' has'pipx' nocd nocompile eval"register-python-argcomplete pipx" \
  atload'zicdreplay -q' \
    zdharma-continuum/null \
  id-as'antidot_conf' has'antidot' nocd eval'antidot init' \
    zdharma-continuum/null \
  id-as'pyenv_init' has'pyenv' nocd eval'${${:-pyenv}:c:A} init - zsh' \
    zdharma-continuum/null \
  id-as'pyenv_virtual_init' has'pyenv-virtualenv' nocd \
  eval'${${:-pyenv}:c:A} virtualenv-init -' \
    zdharma-continuum/null \
  id-as'pipenv_comp' has'pipenv' nocd eval'pipenv --completion' \
    zdharma-continuum/null \
  id-as'navi_comp' has'navi' nocd eval'navi widget zsh' \
    zdharma-continuum/null \
  id-as'ruby_env' has'rbenv' nocd eval'rbenv init -' \
    zdharma-continuum/null \
  id-as'go_env' has'goenv' nocd eval'goenv init -' \
    zdharma-continuum/null \
  id-as'thefuck_alias' has'thefuck' nocd eval'thefuck --alias' \
    zdharma-continuum/null \
  id-as'zoxide_init' has'zoxide' nocd eval'zoxide init --no-aliases zsh' \
  atload'alias o=__zoxide_z z=__zoxide_zi' \
    zdharma-continuum/null \
  id-as'keychain_init' has'keychain' nocd \
    eval'keychain --noask --agents ssh -q --inherit any --eval id_rsa git \
    && keychain --agents gpg -q --eval 0xC011CBEF6628B679' \
      zdharma-continuum/null \
  id-as'Cleanup' nocd atinit'unset -f zt grman; _zsh_autosuggest_bind_widgets' \
    zdharma-continuum/null

# Recommended that `GOROOT/GOPATH` is added after `goenv` init
path=( $GOPATH/bin(N-/) "${path[@]}" )

# eval "$(keychain --agents ssh -q --inherit any --eval id_rsa git burnsac)"
# eval "$(keychain --agents gpg -q --eval 0xC011CBEF6628B679)"

# id-as'dircolors' has'gdircolors' nocd eval"gdircolors ${0:h}/gruv.dircolors" \
#   zdharma/null \

# FIX: only one zicdreplay
# id-as'pip_comp' has'pip' nocd eval'pip completion --zsh' zdharma/null

typeset -gx GPG_TTY=$TTY
typeset -gx PDFVIEWER='zathura'                                                   # texdoc pdfviewer
# ??
typeset -gx XML_CATALOG_FILES="/usr/local/etc/xml/catalog"                        # xdg-utils|asciidoc
typeset -gx FORGIT_LOG_FORMAT="%C(red)%C(bold)%h%C(reset) %Cblue%an%Creset: %s%Creset%C(yellow)%d%Creset %Cgreen(%cr)%Creset"
typeset -gx RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
#
# typeset -gx _ZO_ECHO=1
typeset -gx FZFZ_RECENT_DIRS_TOOL='autojump'
typeset -gx ZSH_AUTOSUGGEST_USE_ASYNC=set
typeset -gx ZSH_AUTOSUGGEST_MANUAL_REBIND=set
typeset -gx ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
typeset -gx ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c100,)" # no 100+ char
typeset -gx ZSH_AUTOSUGGEST_COMPLETION_IGNORE="[[:space:]]*" # no lead space
typeset -gx ZSH_AUTOSUGGEST_STRATEGY=(dir_history custom_history completion)
typeset -gx HISTORY_SUBSTRING_SEARCH_FUZZY=set
typeset -gx HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=set
typeset -gx AUTOPAIR_CTRL_BKSPC_WIDGET=".backward-kill-word"
typeset -ga chwpd_dir_history_funcs=( "_dircycle_update_cycled" ".zinit-cd" )
typeset -g PER_DIRECTORY_HISTORY_BASE="${ZPFX}/share/per-directory-history"
typeset -gx UPDATELOCAL_GITDIR="${HOME}/opt"
typeset -g DUMP_DIR="${ZPFX}/share/dump/trash"
typeset -g DUMP_LOG="${ZPFX}/share/dump/log"
typeset -gx CDHISTSIZE=20 CDHISTTILDE=TRUE CDHISTCOMMAND=cdh
# alias c=jd
typeset -gx FZFGIT_BACKUP="${XDG_DATA_HOME}/gitback"
typeset -gx FZFGIT_DEFAULT_OPTS="--preview-window=':nohidden,right:65%:wrap'"
typeset -gx NQDIR="/tmp/nq" FNQ_DIR="$HOME/tmp/fnq"

typeset -g KEYTIMEOUT=15

typeset -gx PASSWORD_STORE_ENABLE_EXTENSIONS='true'
typeset -gx PASSWORD_STORE_EXTENSIONS_DIR="${BREW_PREFIX}/lib/password-store/extensions"
typeset -gx LS_COLORS="$(vivid -d $ZDOTDIR/zsh.d/vivid/filetypes.yml generate $ZDOTDIR/zsh.d/vivid/kimbie.yml)"
typeset -gx ZLS_COLORS=$LS_COLORS
typeset -gx JQ_COLORS="1;30:0;39:1;36:1;39:0;35:1;32:1;32:1"
# ]]]

# === fzf === [[[
# ❱❯❮ --border ,border-left
(( ${+commands[fd]} )) && {
  _fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1"; }
  _fzf_compgen_dir() { fd --exclude ".git" --follow --hidden --type d . "$1"; }
  _fzf_comprun() {
    local command=$1
    shift

    case "$command" in
      cd)           fzf "$@" --preview 'exa -TL 3 --color=always {} | head -200' ;;
      export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
      ssh)          fzf "$@" --preview 'dig {}' ;;
      *)            fzf "$@" ;;
    esac
  }
}

# FZF_COLORS="
# --color=fg:-1,bg:-1,hl:#458588,fg+:-1,bg+:-1,hl+:#689d6a
# --color=prompt:#fabd2f,marker:#fe8019,spinner:#b8bb26
# "

FZF_COLORS="
--color=fg:-1,fg+:-1,hl:#458588,hl+:#689d6a,bg+:-1
--color=pointer:#fabd2f,marker:#fe8019,spinner:#b8bb26
--color=header:#fb4934,prompt:#b16286
"

typeset -a SKIM_COLORS=(
  "fg:-1" "fg+:-1" "hl:#458588" "hl+:#689d6a" "bg+:-1" "marker:#fe8019"
  "spinner:#b8bb26" "header:#cc241d" "prompt:#fb4934"
)

# matched_bg        Background of highlighted substrings
# current_match_bg  Background of highlighted substrings (current line)
# query             Text of Query (the texts after the prompt)
# query_bg          Background of Query

FZF_FILE_PREVIEW="([[ -f {} ]] && (bat --style=numbers --color=always {}))"
FZF_DIR_PREVIEW="([[ -d {} ]] && (exa -T {} | less))"
FZF_BIN_PREVIEW="([[ \$(file --mime-type -b {}) =~ binary ]] && (echo {} is a binary file))"

export FZF_FILE_PREVIEW FZF_DIR_PREVIEW FZF_BIN_PREVIEW

export FZF_DEFAULT_OPTS="
--prompt '❱ '
--pointer '➤'
--marker '┃'
--cycle
$FZF_COLORS
--reverse --height 80% --ansi --info=inline --multi --border
--preview-window=':hidden,right:60%'
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind='?:toggle-preview'
--bind='ctrl-a:select-all,ctrl-r:toggle-all'
--bind='ctrl-b:execute(bat --paging=always -f {+})'
--bind='ctrl-y:execute-silent(echo {+} | pbcopy)'
--bind='alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--bind='ctrl-v:execute(code {+})'
--bind='ctrl-s:toggle-sort'
--bind='alt-p:preview-up,alt-n:preview-down'
--bind='ctrl-k:preview-up,ctrl-j:preview-down'
--bind='ctrl-u:half-page-up,ctrl-d:half-page-down'
--bind=change:top
"
SKIM_DEFAULT_OPTIONS=${(F)${(M)${(@f)FZF_DEFAULT_OPTS}/(#m)*info*/${${(@s. .)MATCH}:#--info*}}:#--(bind=change:top|pointer*|marker*|color*)}
SKIM_DEFAULT_OPTIONS+=$'\n'"--color=${(j:,:)SKIM_COLORS}"
SKIM_DEFAULT_OPTIONS+=$'\n'"--cmd-prompt=➤"
SKIM_DEFAULT_OPTIONS+=$'\n'"--bind='ctrl-p:preview-up,ctrl-n:preview-down'"
export SKIM_DEFAULT_OPTIONS

export FZF_ALT_E_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_E_OPTS="
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind 'alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
--preview-window default:right:60%
"
export FZF_CTRL_R_OPTS="
--preview 'echo {}'
--preview-window 'down:2:wrap'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--header 'Press CTRL-Y to copy command into clipboard'
--exact
--expect=ctrl-x
"
export SKIM_DEFAULT_COMMAND='fd --no-ignore --hidden --follow --exclude ".git"'
# export FZF_DEFAULT_COMMAND='fd --no-ignore --hidden --follow --exclude ".git"'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND="cat $HOME/.cd_history"
# export FZF_ALT_C_COMMAND="print -rl $dirstack"
# export FZF_ALT_C_COMMAND="fd -t d ."
export FORGIT_FZF_DEFAULT_OPTS="--preview-window='right:60%:nohidden' --bind='ctrl-e:execute(echo {2} | xargs -o nvim)'"
export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview \"(exa -T {2} | less) 2>/dev/null | head -200\""

alias db='dotbare'
export DOTBARE_DIR="${XDG_DATA_HOME}/dotfiles"
export DOTBARE_TREE="$HOME"
export DOTBARE_BACKUP="${XDG_DATA_HOME}/dotbare-b"
export DOTBARE_FZF_DEFAULT_OPTS="
$FZF_DEFAULT_OPTS
--header='A:select-all, B:pager, Y:copy, E:nvim'
--preview-window=:nohidden
--preview \"($FZF_FILE_PREVIEW || $FZF_DIR_PREVIEW) 2>/dev/null | head -200\"
--bind 'ctrl-a:select-all'
--bind 'ctrl-b:execute(bat --paging=always -f {+})'
--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
--bind 'ctrl-e:execute(echo {+} | xargs -o nvim)'
"
# ]]]

# == sourcing === [[[

zt 0b light-mode null id-as for \
  multisrc="$ZDOTDIR/zsh.d/{aliases,keybindings,lficons,git-token}.zsh" \
    zdharma-continuum/null \
  atinit'
  export PERLBREW_ROOT="${XDG_DATA_HOME}/perl5/perlbrew";
  export PERLBREW_HOME="${XDG_DATA_HOME}/perl5/perlbrew-h";
  export PERL_CPANM_HOME="${XDG_DATA_HOME}/perl5/cpanm"' \
  atload'local x="$PERLBREW_ROOT/etc/bashrc"; [ -f "$x" ] && source "$x"' \
    zdharma-continuum/null \
  atload'export FAST_WORK_DIR=XDG;
  fast-theme XDG:mod-default.ini &>/dev/null' \
    zdharma-continuum/null \
  atload'local x="$XDG_CONFIG_HOME/cdhist/cdhist.rc"; [ -f "$x" ] && source "$x"' \
    zdharma-continuum/null

# nocd atinit"TS_SOCKET=/tmp/ts1 ts -C && ts -l | rg -Fq 'limelight' || TS_SOCKET=/tmp/ts1 ts limelight >/dev/null" \
# nocd atinit"TS_SOCKET=/tmp/ts1 ts -C && ts -l | rg -Fq 'limelight' || chronic ts limelight"
# atload'local x="${XDG_DATA_HOME}/cargo/env"; [ -f "$x" ] && source "$x"'\
# atload"source $XDG_DATA_HOME/fonts/i_all.sh" zdharma/null

# recache keychain if older than GPG cache time or first login
# local first=${${${(M)${(%):-%l}:#*01}:+1}:-0}
[[ -f "$ZINIT[PLUGINS_DIR]/keychain_init"/eval*~*.zwc(#qN.ms+45000) ]] || [[ "$TTY" = /dev/tty1 ]] && {
  zinit recache keychain_init
  print -Pr "%F{13}===========================%f"
  print -Pr "%F{12}===> %BKeychain recached%b <===%f"
  print -Pr "%F{13}===========================%f"
  zle && zle reset-prompt
}
# ]]]

[[ -z ${path[(re)$XDG_BIN_HOME]} && -d "$XDG_BIN_HOME" ]] \
    && path=( "$XDG_BIN_HOME" "${path[@]}")

path=( "${ZPFX}/bin" "${path[@]}" )                # add back to be beginning
path=( "${path[@]:#}" )                            # remove empties
path=( "${(u)path[@]}" )                           # remove duplicates; goenv adds twice?

zflai-msg "[zshrc] File took ${(M)$(( SECONDS * 1000 ))#*.?} ms"

# vim: set sw=0 ts=2 sts=2 et ft=zsh fdm=marker fmr=[[[,]]]:
