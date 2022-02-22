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

autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz replace-string
autoload -Uz replace-string-again
zle -N replace-regex replace-string
zle -N replace-pattern replace-string
zle -N replace-string-again
zstyle ':zle:replace-pattern' edit-previous false

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround

# Expand everything under cursor
function expand-all() {
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
  if [[ $_per_directory_history_is_global ]]; then
    per-directory-history-toggle-history; fzf-history-widget
  else
    fzf-history-widget
  fi
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
function toggle-right-prompt() { p10k display '*/right'=hide,show; }
zle -N toggle-right-prompt

zle -N fcq
zle -N pw
zle -N fe

# zle -N fcd-zle
# zle -N bow2

zle -N expand-aliases
zle -N __unicode_translate # translate unicode to symbol

# zle -N _complete_debug_generic _complete_help_generic
# 'C-x C-m'         _complete_debug_generic
# 'C-x C-t'         _complete_tag

# =============================== ZAW ===============================
# ====================================================================
# TODO: Maybe use something like this?

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

# ============================= BINDINGS =============================
# ====================================================================
if [[ $TMUX ]]; then
  zle -N t
  vbindkey 'M-t' t                       # alt-t
  zle -N wfxr::tmux-select-window
  vbindkey 'M-w' wfxr::tmux-select-window # alt-w
fi

# Available modes: all normal modes, str, @, -, + (see marlonrichert/zsh-edit)
typeset -gA keybindings; keybindings=(
# ========================== Bindings ==========================
  'Home'           beginning-of-line
  'End'            end-of-line
  'Delete'         delete-char
  'F1'             dotbare-fstat
  'F2'             db-faddf
  'F3'             _wbmux
  'Esc-e'          wfxr::fzf-file-edit-widget
  'Esc-i'          fe
  'Esc-d'          expand-aliases
  'M-r'            per-dir-fzf
  'M-p'            pw                    # fzf pueue
  # 'M-q'             push-line-or-edit     # zsh-edit
  'M-u'            __unicode_translate   # translate unicode
  'M-x'            cd-fzf-ghqlist-widget # cd ghq fzf
  'M-f'            list-keys             # list keybindings in mode
  'M-1'            toggle-right-prompt
  'C-a'            autosuggest-execute
  'C-y'            yank
  'C-z'            fancy-ctrl-z
  'C-x r'          fz-history-widget
  'C-x t'          pick_torrent          # fzf torrent
  'M-b'            fcq-zle               # copyq zle
  'C-x C-b'        fcq                   # copyq fzf
  'C-x C-g'        clipboard-fzf         # greenclip fzf
  'C-x C-e'        edit-command-line-as-zsh
  'C-x C-f'        fz-find
  'C-x C-u'        RG_buff # RG with $BUFFER
  'C-x C-x'        execute-command
  'mode=vicmd u'   undo
  'mode=vicmd R'   replace-pattern
  'mode=vicmd U'   redo
  'mode=vicmd E'   backward-kill-line
  # 'mode=vicmd L'    end-of-line # Move to end of line, even on another line
  # 'mode=vicmd H'    beginning-of-line # Moves to very beginning, even on another line
  'mode=vicmd L'   vi-end-of-line
  'mode=vicmd H'   vi-beginning-of-line
  'mode=vicmd ?'   which-command
  'mode=vicmd yy'  copyx
  'mode=vicmd ;e'  edit-command-line-as-zsh
  'mode=vicmd c.'  vi-change-whole-line
  'mode=vicmd ds'  delete-surround
  'mode=vicmd cs'  change-surround
  'mode=vicmd K'   run-help
  'mode=vicmd M-f' list-keys             # list keybindings in mode
  'mode=vicmd \$'  expand-all
  'mode=vicmd \-'  zvm_switch_keyword
  'mode=vicmd \+'  zvm_switch_keyword
  'mode=viins jk'  vi-cmd-mode
  'mode=viins kj'  vi-cmd-mode
  'mode=visual S'  add-surround
  'mode=str M-t'   t                     # tmux wfxr
  'mode=str C-o'   lc                    # lf change dir
  'mode=str C-u'   lf
  'mode=@ C-b'     bow2                  # surfraw open w3m
  'mode=+ M-.'     kf                    # a formarks like thing in rust
  'mode=@ M-/'     frd                   # cd interactively recent dir
  'mode=@ M-;'     fcd                   # cd interactively
  # 'mode=@ M-;'     skim-cd-widget
  'mode=@ M-,'     __zoxide_zi
  'mode=@ M-['     fstat
  'mode=@ M-]'     fadd
# ========================== Testing ==========================
# 'mode=vicmd Q'    save-alias
  'mode=vicmd Q'    src-locate
)

vbindkey -A keybindings

# Surround text under cursor with quotes
builtin bindkey -M vicmd -s ' o' 'viwS"'

# 'mod=vicmd ZZ'  accept-line
# 'mode=vicmd M-a' yank-pop
# 'mode=vicmd M-s' reverse-yank-pop
# 'M-c'     _call_navi
# 'M-n'     _navi_next_pos

# bindkey '^[!' expand-history
# bindkey '^[$' spell-word
# bindkey '^["' exchange-point-and-mark
# bindkey '^[,' _history-complete-newer
# bindkey '^[-' neg-argument
# bindkey '^Xa' _expand_alias
# bindkey '^Xe' _expand_word
# bindkey '^Xc' _correct_word
# bindkey '^Xd' _list_expansions
# bindkey '^Xg' list-expand
# bindkey '^Xm' _most_recent_file
# bindkey '^Xn' _next_tags
# bindkey '^Xh' _complete_help
# bindkey '^Xt' _complete_tag

# # ci", ci', ci`, di", etc
# autoload -U select-quoted
# zle -N select-quoted
# for m in visual viopp; do
#   for c in {a,i}{\',\",\`}; do
#     bindkey -M $m $c select-quoted
#   done
# done
#
# # ci{, ci(, ci<, di{, etc
# autoload -U select-bracketed
# zle -N select-bracketed
# for m in visual viopp; do
#   for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
#     bindkey -M $m $c select-bracketed
#   done
# done

# View keybindings
function lskb() {
  local -A keyb=(); for k v in ${(kv)keybindings}; do
    k="%F{1}%B$k%f%b" v="%F{3}$v%f" keyb[${(%)k}]=${(%)v}
  done
  print -raC 2 -- ${(Oakv)keyb[@]}
  # print -rC 2 -- ${(nkv)keyb}
  # print -ac -- ${(Oa)${(kv)keyb[@]}}
}

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


# The 'undo' doesn't undo like read-minibuffer does
# =============================== TODO ===============================
# ====================================================================
function read-ss() {
  emulate -L zsh
  setopt extendedglob

  autoload -Uz read-from-minibuffer replace-string-again

  local p1  p2
  integer savelim=$UNDO_LIMIT_NO changeno=$UNDO_CHANGE_NO

  {

  if [[ -n $_replace_string_src ]]; then
    p1="[$_replace_string_src -> $_replace_string_rep]"$'\n'
  fi

  p1+="Replace: "
  p2="   with: "

  # Saving curwidget is necessary to avoid the widget name being overwritten.
  local REPLY previous curwidget=$WIDGET
  notify-send "WIDGET: $WIDGET"

  if (( ${+NUMERIC} )); then
    (( $NUMERIC > 0 )) && previous=1
  else
    zstyle -t ":zle:$WIDGET" edit-previous && previous=1
  fi

  read-from-minibuffer $p1 ${previous:+$_replace_string_src} || return 1
  if [[ -n $REPLY ]]; then
    typeset -g _replace_string_src=$REPLY

    read-from-minibuffer "$p1$_replace_string_src$p2" \
      ${previous:+$_replace_string_rep} || return 1
    typeset -g _replace_string_rep=$REPLY
  fi

  } always {
    zle undo $changeno
    UNDO_LIMIT_NO=savelim
  }

  replace-ss $curwidget
}

zle -N replace-pattern read-ss

function replace-ss() {
  local MATCH MBEGIN MEND curwidget=${1:-$WIDGET}
  local -a match mbegin mend

  if [[ -z $_replace_string_src ]]; then
    zle -M "No string to replace."
    return 1
  fi

  if [[ $curwidget = *(pattern|regex)* ]]; then
      local rep2
      # The following horror is so that an & preceded by an even
      # number of backslashes is active, without stripping backslashes,
      # while preceded by an odd number of backslashes is inactive,
      # with one backslash being stripped.  A similar logic applies
      # to \digit.
      local rep=$_replace_string_rep
      while [[ $rep = (#b)([^\\]#)(\\\\)#(\\|)(\&|\\<->|\\\{<->\})(*) ]]; do
    if [[ -n $match[3] ]]; then
        # Expression is quoted, strip quotes
        rep2="${match[1]}${match[2]}${match[4]}"
    else
        rep2+="${match[1]}${match[2]}"
        if [[ $match[4] = \& ]]; then
      rep2+='${MATCH}'
        elif [[ $match[4] = \\\{* ]]; then
      rep2+='${match['${match[4][3,-2]}']}'
        else
      rep2+='${match['${match[4][2,-1]}']}'
        fi
    fi
    rep=${match[5]}
      done
      rep2+=$rep
      if [[ $curwidget = *regex* ]]; then
        autoload -Uz regexp-replace
        integer ret=1
        regexp-replace LBUFFER $_replace_string_src $rep2 && ret=0
        regexp-replace RBUFFER $_replace_string_src $rep2 && ret=0
        return ret
      else
        LBUFFER=${LBUFFER//(#bm)$~_replace_string_src/${(e)rep2}}
        RBUFFER=${RBUFFER//(#bm)$~_replace_string_src/${(e)rep2}}
      fi
  else
      LBUFFER=${LBUFFER//$_replace_string_src/$_replace_string_rep}
      RBUFFER=${RBUFFER//$_replace_string_src/$_replace_string_rep}
  fi
}
zle -N replace-ss
