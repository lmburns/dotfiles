#===========================================================================
#       Author: Lucas Burns
#        Email: burnsac@me.com
#      Created: 2021-06-27 21:50
#  Description: Bindkeys for zsh using custom 'vbindkey'
#===========================================================================

# zshexpn -- zsh -o SOURCE_TRACE -lic ''
# sed -n l -- infocmp -L1 -- zle -L

# typeset -gx WORDCHARS=' *?_-.~\'
# typeset -g WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# This keeps prompt from moving to the right with p10k
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )) {
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
}

builtin bindkey -v
builtin bindkey -r '^[,'
builtin bindkey -r '^[/'
builtin bindkey -M vicmd -r 'R'

# bindkey -M vicmd 'ys' add-surround
# bindkey '^I' expand-or-complete-prefix
# bindkey '^a' autosuggest-accept

# autoload -Uz incarg

# autoload -Uz insert-unicode-char
# zle -N insert-unicode-char

autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround

# =========================== zle Functions ==========================
# ====================================================================

# ========================== Unused ==========================

# Add command to history without executing it
function commit-to-history() {
  print -rs ${(z)BUFFER}
  zle send-break
}
zle -N commit-to-history

# Only slash should be considered as a word separator:
function slash-backward-kill-word() {
  local WORDCHARS="${WORDCHARS:s@/@}"
  zle backward-kill-word
}
zle -N slash-backward-kill-word

# =========================== Used ===========================

# Expand everything under cursor
function expand-all() {
  # zle -N expand-aliases
  zle _expand_alias
  zle expand-word
}
zle -N expand-all

# List keybindings in current mode
function list-keys() {
  zmodload -Fa zsh/parameter p:functions
  (( $+functions[bindkey::help] )) || return 0
  bindkey::help -M $KEYMAP -b
  zle reset-prompt
}
zle -N list-keys

# Show per-directory-history with fzf
function per-dir-fzf() {
  per-directory-history-toggle-history
  skim-history-widget
}
zle -N per-dir-fzf       # fzf history

# RG with $BUFFER
function RG_buff() {
  zmodload -Fa zsh/parameter p:functions
  eval "() {
    $functions[RG]
  }" "$BUFFER"
  zle reset-prompt
}
zle -N RG_buff

# Copy $BUFFER
function copyx() {
  print -rn $BUFFER | tr -d '\n' | xsel -ib
  zle -M "copied: ${BUFFER}"
}
zle -N copyx

# Toggle p10k right side widgets
function toggle-right-prompt() {
  p10k display '*/right'=hide,show
}
zle -N toggle-right-prompt

zle -N fcq
zle -N pw
zle -N fe

# zle -N fcd-zle
# zle -N bow2

zle -N __unicode_translate # translate unicode to symbol

# zle -N _complete_debug_generic _complete_help_generic
# 'C-x C-m'         _complete_debug_generic
# 'C-x C-t'         _complete_tag

# =============================== zaw ===============================
# ====================================================================
autoload -U read-from-minibuffer

function save-alias() {
  local REPLY FILE
  read-from-minibuffer "alias as: "
  FILE="$ZDOTDIR/aliases/$REPLY"
  path+=( "$ZDOTDIR/aliases" )
  if [ -n "$REPLY" -a ! -f $FILE ]; then
    echo "#!/usr/bin/env zsh\n\n. $ZDOTDIR/.zshrc\n" > $FILE
    echo "$BUFFER \$*" >> $FILE
    chmod +x $FILE
    BUFFER="$REPLY"
  fi
  rehash
}
zle -N save-alias

function src-locate() {
  typeset -ga candidates
  local buf start
  start="$BUFFER"
  read-from-minibuffer "locate: "
  buf=$(lolcate ${(Q@)${(z)REPLY}})
  [[ $? != 0 ]] && return 1
  : ${(A)candidates::=${(f)buf}}
  # LBUFFER="${BUFFER}${(j:; :)@}"
  BUFFER="$start"
}
zle -N src-locate

# ============================= BINDINGS =============================
# ====================================================================
if [[ $TMUX ]]; then
  zle -N tmt
  vbindkey 'M-t' tmt                       # alt-t
  zle -N wfxr::tmux-select-window
  vbindkey 'M-w' wfxr::tmux-select-window # alt-w
fi

# if [[ -n "$terminfo[kcbt]" ]]; then
#     bindkey "$terminfo[kcbt]" reverse-menu-complete
# elif [[ -n "$terminfo[cbt]" ]]; then # required for GNU screen
#     bindkey "$terminfo[cbt]"  reverse-menu-complete
# fi

# Available modes: all normal modes, str, @, -, + (see marlonrichert/zsh-edit)
typeset -gA keybindings; keybindings=(
# ========================== Bindings ==========================
# 'M-q'             push-line-or-edit     # zsh-edit
  'Home'                  beginning-of-line
  'End'                   end-of-line
  'Delete'                delete-char
  'F1'                    dotbare-fstat
  'F2'                    db-faddf
  'F3'                    _wbmux
  ';z'                    zbrowse
  'Esc-e'                 wfxr::fzf-file-edit-widget
  'Esc-i'                 fe
  'Esc-f'                 list-keys             # list keybindings in mode
  'M-r'                   per-dir-fzf
  'M-o'                   clipboard-fzf            # greenclip fzf
  'M-p'                   pw                    # fzf pueue
  'M-u'                   __unicode_translate   # translate 0000 to unicode
  'M-x'                   cd-fzf-ghqlist-widget # cd ghq fzf
  'M-S-P'                 toggle-right-prompt
  'C-a'                   autosuggest-execute
  'C-y'                   yank
  'C-z'                   fancy-ctrl-z
  'C-x r'                 fz-history-widget
  'C-x t'                 pick_torrent             # fzf torrent
  'C-x C-b'               fcq                      # copyq fzf
  'C-x C-g'               fcq-zle                  # copyq zle
  'C-x C-e'               edit-command-line-as-zsh # Edit command in editor
  'C-x C-f'               fz-find
  'C-x C-u'               RG_buff                  # RG with $BUFFER
  'C-x C-x'               execute-command          # Execute ZLE command
  'mode=vicmd u'          undo
  'mode=vicmd R'          replace-pattern
  'mode=vicmd U'          redo
  'mode=vicmd E'          backward-kill-line
  # 'mode=vicmd L'    end-of-line # Move to end of line, even on another line
  # 'mode=vicmd H'    beginning-of-line # Moves to very beginning, even on another line
  'mode=vicmd L'          vi-end-of-line
  'mode=vicmd H'          vi-beginning-of-line
  'mode=vicmd ?'          which-command
  'mode=vicmd yy'         copyx
  'mode=vicmd ;v'         clipboard-fzf         # greenclip fzf
  'mode=vicmd ;e'         edit-command-line-as-zsh
  'mode=vicmd ;o'         noptions             # edit zsh options
  'mode=vicmd ;x'         vi-backward-kill-word
  'mode=vicmd c.'         vi-change-whole-line
  'mode=vicmd ds'         delete-surround
  'mode=vicmd cs'         change-surround
  'mode=vicmd K'          run-help
  'mode=vicmd M-f'        list-keys          # list keybindings in mode
  'mode=vicmd \$'         expand-all         # expand alias etc under keyboard
  'mode=vicmd \-'         zvm_switch_keyword # decrement item under keyboard
  'mode=vicmd \+'         zvm_switch_keyword # inccrement item under keyboard
  'mode=viins jk'         vi-cmd-mode
  'mode=viins kj'         vi-cmd-mode
  'mode=visual S'         add-surround
  'mode=str M-t'          t                  # tmux wfxr
  'mode=str C-o'          lc                 # lf change dir
  'mode=str C-u'          lf                 # regular lf
  'mode=@ C-b'            bow2               # surfraw open w3m
  'mode=+ M-.'            kf                 # a formarks like thing in rust
  'mode=@ M-/'            frd                # cd interactively recent dir
  'mode=@ M-;'            fcd                # cd interactively
  # 'mode=@ M-;'          skim-cd-widget
  'mode=@ M-,'            __zoxide_zi
  'mode=@ M-['            fstat
  'mode=@ M-]'            fadd
  'mode=menuselect Space' .accept-line
  'mode=menuselect C-r'   history-incremental-search-backward
  'mode=menuselect C-f'   history-incremental-search-forward

# ========================== Testing ==========================
# 'mode=vicmd Q'    save-alias
  'mode=vicmd Q'    src-locate
  'mode=vicmd ;d'   dirstack-plus
)

vbindkey -A keybindings

# Surround text under cursor with quotes
builtin bindkey -M vicmd -s ' o' 'viwS"'
builtin bindkey -s "^[\'" 'ncd\n'

builtin bindkey -s '\e1' "!:0 \t"        # last command
# bindkey -s '\e2' "!:0-1 \t"      # last command + 1st argument
# bindkey -s '\e3' "!:0-2 \t"      # last command + 1st-2nd argument
# bindkey -s '\e4' "!:0-3 \t"      # last command + 1st-3rd argument
# bindkey -s '\e5' "!:0-4 \t"      # last command + 1st-4th argument
# bindkey -s '\e`' "!:0- \t"       # all but the last argument
# bindkey -s '\e9' "!:0 !:2* \t"   # all but the 1st argument (aka 2nd word)

# 'mod=vicmd ZZ'  accept-line
# 'mode=vicmd M-a' yank-pop
# 'mode=vicmd M-s' reverse-yank-pop
# 'M-c'     _call_navi
# 'M-n'     _navi_next_pos

# expand-history
# _expand_alias
# _expand_word
# spell-word
# exchange-point-and-mark
# _history-complete-newer
# neg-argument
# _correct_word
# _list_expansions
# list-expand
# _most_recent_file
# _next_tags
# _complete_help
# _complete_tag

local m c
# ci", ci', ci`, di", etc
autoload -U select-quoted; zle -N select-quoted
foreach m (visual viopp) {
  foreach c ({a,i}{\',\",\`}) {
    bindkey -M $m $c select-quoted
  }
}

# ci{, ci(, ci<, di{, etc
autoload -U select-bracketed; zle -N select-bracketed
foreach m (visual viopp) {
  foreach c ({a,i}${(s..)^:-'()[]{}<>bB'}) {
    bindkey -M $m $c select-bracketed
  }
}

# ================================ LF ================================
# ====================================================================
function _zlf() {
  emulate -L zsh
  local d=$(mktemp -d) || return 1
  {
    mkfifo -m 600 $d/fifo || return 1
    tmux split -bf zsh -c "exec {ZLE_FIFO}>$d/fifo; export ZLE_FIFO; exec lf" || return 1
    local fd
    exec {fd}<$d/fifo
    zle -Fw $fd _zlf_handler
  } always {
    command rm -rf $d
  }
}
zle -N _zlf

function _zlf_handler() {
  emulate -L zsh
  local line
  if ! read -r line <&$1; then
    zle -F $1
    exec {1}<&-
    return 1
  fi
  eval $line
  zle -R
}
zle -N _zlf_handler

vbindkey 'C-x C-o' _zlf

# ============================== Extra ===============================
# ====================================================================

# ============================= Callbacks =============================
function callback-execute() {
    BUFFER="${(j:; :)@}"
    zle accept-line
}

function callback-replace-buffer() {
    LBUFFER="${(j:; :)@}"
    RBUFFER=""
}

function callback-append-to-buffer() {
    LBUFFER="${BUFFER}${(j:; :)@}"
}
zle -N zaw-append-to-buffer

function callback-edit-file() {
    local -a args
    args=("${(@q)@}")
    BUFFER="${EDITOR} ${args}"
    zle accept-line
}

# ============================ Other Func ============================
# View keybindings
function lskb() {
  local -A keyb=(); for k v in ${(kv)keybindings}; do
    k="%F{1}%B$k%f%b" v="%F{3}$v%f" keyb[${(%)k}]=${(%)v}
  done
  print -raC 2 -- ${(Oakv)keyb[@]}
  # print -rC 2 -- ${(nkv)keyb}
  # print -ac -- ${(Oa)${(kv)keyb[@]}}
}
