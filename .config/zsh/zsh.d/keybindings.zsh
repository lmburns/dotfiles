#===========================================================================
#       Author: Lucas Burns
#        Email: burnsac@me.com
#      Created: 2021-06-27 21:50
#  Description: ZLE functions and keybindings
#===========================================================================

# zshexpn -- zsh -o SOURCE_TRACE -lic ''
# sed -n l -- infocmp -L1 -- zle -L

# typeset -gx WORDCHARS=' *?_-.~\'
# typeset -g WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

declare -g VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
declare -g VI_MODE_SET_CURSOR=true

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

# Remove specific widgets
function remove_widget() {
  local name=$1
  local cap=$2
  if (( ${+functions[$name]} )) && [[ ${functions[$name]} == *${cap}* ]]; then
    local w=${widgets[$name]}
    zle -D $name
    [[ $w == user:* ]] && unfunction ${w#*:}
  fi
}

# remove_widget zle-line-init smkx
# remove_widget zle-line-finish rmkx
# unfunction remove_widget

builtin bindkey -v
builtin bindkey -r '^[,'
builtin bindkey -r '^[/'
builtin bindkey -M vicmd -r 'R'

# =========================== zle Functions ==========================
# ====================================================================

# Desc: expand everything under cursor
function :expand-all() {
  # zle -N expand-aliases
  zle _expand_alias
  zle expand-word
}; zle -N :expand-all
Zkeymaps+=('mode=vicmd \$' :expand-all)

# Desc: list keybindings in current mode
function :list-keys() {
  zmodload -Fa zsh/parameter p:functions
  (( $+functions[bindkey::help] )) || return 0
  bindkey::help -M $KEYMAP -b
  zle reset-prompt
}; zle -N :list-keys
Zkeymaps+=('M-\' :list-keys)
Zkeymaps+=('mode=vicmd M-\' :list-keys)
Zkeymaps+=('mode=visual M-\' :list-keys)
Zkeymaps+=('mode=viopp M-\' :list-keys)

# Desc:show per-directory-history with fzf
function per-dir-fzf() {
  per-directory-history-toggle-history
  fzf-history-widget
  # skim-history-widget
}; zle -N per-dir-fzf       # fzf history
Zkeymaps[M-S-R]=per-dir-fzf

# Desc: RG with $BUFFER
function :RG-buffer() {
  zmodload -Fa zsh/parameter p:functions
  eval "() { $functions[RG] } $BUFFER"
  zle reset-prompt
}; zle -N :RG-buffer
Zkeymaps+=('C-x C-u' :RG-buffer)

# Desc: copy text, display message
function :copymsg() {
  print -rn $BUFFER | xsel -ib --trim
  zle -M "copied: ${BUFFER}"
}; zle -N :copymsg
Zkeymaps+=('mode=vicmd yy' :copymsg)

# Desc: toggle p10k right side widgets
function toggle-right-prompt() {
  p10k display '*/right'=hide,show
}; zle -N toggle-right-prompt
Zkeymaps[M-S-P]=toggle-right-prompt

# Desc: cut text
function vi-delete-visual() {
  zle .vi-delete
  print -rn "$CUTBUFFER" | xsel -ib --trim
}; zle -N vi-delete-visual
Zkeymaps+=("mode=visual x'" vi-delete-visual)

function zce-jump-char() {
  [[ -z $BUFFER ]] && zle up-history
  zstyle ':zce:*' prompt-char '%B%F{green}Jump to character:%F%b '
  zstyle ':zce:*' prompt-key '%B%F{green}Target key:%F%b '
  with-zce zce-raw zce-searchin-read
  CURSOR+=1
}; zle -N zce-jump-char
Zkeymaps+=(";j" zce-jump-char)

# function zce-delete-to-char() {
#     [[ -z $BUFFER ]] && zle up-history
#     local pbuffer=$BUFFER pcursor=$CURSOR
#     local keys=${(j..)$(print {a..z} {A..Z})}
#     zstyle ':zce:*' prompt-char '%B%F{yellow}Delete to character:%F%b '
#     zstyle ':zce:*' prompt-key '%B%F{yellow}Target key:%F%b '
#     zce-raw zce-searchin-read $keys
#
#     if (( $CURSOR < $pcursor ))  {
#         pbuffer[$CURSOR,$pcursor]=$pbuffer[$CURSOR]
#     } else {
#         pbuffer[$pcursor,$CURSOR]=$pbuffer[$pcursor]
#         CURSOR=$pcursor
#     }
#     BUFFER=$pbuffer
# }
# zle -N zce-delete-to-char
# vbindkey "C-j d" zce-delete-to-char

[[ -n "$terminfo[kpp]"   ]] && bindkey "$terminfo[kpp]"   up-line-or-beginning-search   # PAGE UP
[[ -n "$terminfo[knp]"   ]] && bindkey "$terminfo[knp]"   down-line-or-beginning-search # PAGE DOWN
[[ -n "$terminfo[khome]" ]] && bindkey "$terminfo[khome]" beginning-of-line             # HOME
[[ -n "$terminfo[kend]"  ]] && bindkey "$terminfo[kend]"  end-of-line                   # END
[[ -n "$terminfo[kdch1]" ]] && bindkey "$terminfo[kdch1]" delete-char                   # DELETE
[[ -n "$terminfo[kbs]"   ]] && bindkey "$terminfo[kbs]"   backward-delete-char          # BACKSPACE

#  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Desc: search for something placing results in $candidates[@]
function :src-locate() {
  declare -ga candidates
  local buf start
  start="$BUFFER"
  read-from-minibuffer "locate: "
  (( $+REPLY )) && {
    buf=$(locate ${(Q@)${(z)REPLY}})
    (( $? )) && return 1
    : ${(A)candidates::=${(f)buf}}
    BUFFER="$start"
  }
}; zle -N :src-locate
Zkeymaps+=('mode=vicmd M' :src-locate)

# Desc: fzf with `locate`
function :src-locate-fzf() {
  local selected
  if selected=$(locate / | fzf -q "$LBUFFER"); then
    LBUFFER=$selected
  fi
  zle redisplay
}; zle -N :src-locate-fzf
Zkeymaps+=('mode=vicmd ,lo' :src-locate-fzf)

# TODO: Figure out how to set numeric
function __complete_help_full() {
  # NUMERIC=2
  zle universal-argument 2
  _complete_help
}
zle -C __complete_help_full complete-word _complete_help_full
# zle -N _complete_help_full
# compdef -k _complete_help_full complete-word \C-x\C-h

#  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# autoload -Uz incarg # increment digit
# autoload -Uz insert-unicode-char; zle -N insert-unicode-char
# autoload -Uz edit-command-line; zle -N edit-command-line

zle -N pw                  # pueue
zle -N zle-macho

autoload -U +X read-from-minibuffer

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

zle -N zi-browse-symbol
zle -N zi-browse-symbol-backwards  zi-browse-symbol
zle -N zi-browse-symbol-pbackwards zi-browse-symbol
zle -N zi-browse-symbol-pforwards  zi-browse-symbol
Zkeymaps[C-n]=zi-browse-symbol

function mkzshtags() {
  command git rev-parse >/dev/null 2>&1 \
    && ctags -e -R --languages=zsh --pattern-length-limit=250 . \
    && dunstify 'tags are finished'
}; zle -N mkzshtags
Zkeymaps[M-n]=mkzshtags

autoload -Uz :surround
zle -N delete-surround :surround
zle -N add-surround    :surround
zle -N change-surround :surround

zle -N zvm::switch_keyword
# Decrement item under keyboard
Zkeymaps+=('mode=vicmd _' zvm::switch_keyword)
# Increment item under keyboard
Zkeymaps+=('mode=vicmd \+' zvm::switch_keyword)

zle -N replace-pattern
# Replace text on the command line
Zkeymaps+=('mode=vicmd R' replace-pattern)

# Insert octal/hex key
zle -N :insert-numeric
Zkeymaps+=('mode=viins C-x C-n' :insert-numeric)
# Transpose words on the cursor
zle -N :transpose-words-at-point
Zkeymaps[M-t]=:transpose-words-at-point

# Surfraw open w3m
zle -N :transpose-words-at-point
Zkeymaps+=('mode=@ C-b' :b1fow)

zle -N zmacho
Zkeymaps+=('C-\' zmacho)

autoload -Uz :exchange
zle -N :exchange
zle -N :exchange-line  :exchange
zle -N :exchange-clear :exchange
bindkey -M vicmd -r 's'
Zkeymaps+=('mode=vicmd sx'  :exchange)
Zkeymaps+=('mode=vicmd ss'  :exchange-line)
Zkeymaps+=('mode=vicmd sxc' :exchange-clear)
Zkeymaps+=('mode=visual X'  :exchange)

# ============================= BINDINGS =============================
# ====================================================================
# bindkey '^I' expand-or-complete-prefix # Fix autopair completion within brackets
# bindkey '^T' backward-kill-word

# if [[ $TMUX ]]; then
#   zle -N tmux::attach-create
#   vbindkey 'M-t' tmt                 # alt-t
#   zle -N tmux::select-window
#   vbindkey 'M-w' tmux::select-window # alt-w
# fi

# Available modes: all normal modes, str, @, -, + (see marlonrichert/zsh-edit)
Zkeymaps+=(
# ========================== Bindings ==========================
  # 'F1'                    dotbare-fstat
  # 'F2'                    db-faddf
  # 'Home'                  beginning-of-line
  # 'End'                   end-of-line
  # 'Delete'                delete-char
  ';z'                    zbrowse               # Bring up zbrowse TUI
  'M-c'                   fzf-cd-widget         # Builtin fzf cd widget
  'M-v'                   describe-key-briefly  # Describe what key does
  # 'M-S-R'                 fzf-history-widget  # Builtin fzf history widget
  'M-p'                   pw                    # Fzf pueue
  'M-g'                   get-line              # Get line from buffer-stack
  'M-q'                   push-line-or-edit     # Push line onto buffer stack
  # 'M-S-q'                 push-input          # Push multi-line onto buffer stack
  'C-a'                   autosuggest-execute   # Execute the autosuggestion
  'C-t'                   fzf-file-widget       # Insert file into cli
  'C-y'                   yank                  # Insert the contents of the kill buffer at the cursor position
  'C-w'                   vi-backward-kill-word    # Kill word backwards
  'M-['                   backward-kill-line
  'C-h'                   backward-delete-char  # Execute the autosuggestion
  # 'C-S-h'                 backward-word
  # 'mode=vicmd :'          execute-named-cmd
  'mode=vicmd 0'          vi-digit-or-beginning-of-line
  'mode=vicmd u'          undo
  'mode=vicmd U'          redo
  # 'mode=vicmd L'    end-of-line # Move to end of line, even on another line
  # 'mode=vicmd H'    beginning-of-line # Moves to very beginning, even on another line
  'mode=vicmd L'          vi-end-of-line
  'mode=vicmd H'          vi-beginning-of-line
  'mode=vicmd K'          run-help      # Open man-page

  # 'mode=vicmd ;y'         zvmm-vi-yank
  # 'mode=vicmd ;Y'         vi-yank-whole-line
  # 'mode=vicmd ;ye'        vi-yank-eol
  # 'mode=visual ;y'        vi-yank

  # 'mode=vicmd ;y'         zvmm-vi-yank
  'mode=vicmd Y'         vi-yank-whole-line
  'mode=vicmd ye'        vi-yank-eol

  'mode=vicmd ;x'         vi-backward-kill-word    # Kill word backwards
  'mode=vicmd C'          vi-change-eol        # Kill text to end of line & start in insert
  'mode=vicmd S'          vi-change-whole-line # Change all text to start over
  'mode=vicmd cc'         vi-change-whole-line # Change all text to start over
  'mode=vicmd ds'         delete-surround      # Delete 'surrounders'
  'mode=vicmd cs'         change-surround      # Change 'surrounders'
  'mode=vicmd ys'         add-surround         # Add 'surrounders'
  'mode=vicmd ?'          which-command        # Display info about a command
  'mode=vicmd ='          list-choices         # List choices (i.e., alias, command, vars, etc)
  'mode=vicmd ga'         what-cursor-position
  'mode=vicmd #'          vi-pound-insert
  'mode=vicmd %'          vi-match-bracket
  'mode=vicmd <'          vi-up-line-or-history
  'mode=vicmd >'          vi-down-line-or-history
  # 'mode=vicmd /'          vi-history-search-backward
  'mode=vicmd /'          history-incremental-pattern-search-backward
  'mode=visual S'         add-surround         # Add 'surrounders'
  'mode=viins jk'         vi-cmd-mode        # Switch to vi-cmd mode
  'mode=viins kj'         vi-cmd-mode        # Switch to vi-cmd mode
  # "mode=str M-S-'"          ncd             # Lf change dir
  'mode=str M-o'          lc                 # Lf change dir
  'mode=str M-S-O'        lfub               # Lf ueberzug
  # 'mode=str C-u'          lf                 # Regular lf
  'mode=str ;o'           noptions           # Edit zsh options
  'mode=+ M-.'            kf                 # Formarks like thing in rust
  'mode=+ M-,'            frd                # Cd interactively recent dirs
  'mode=+ M-;'            'fcd 4'            # Cd interactively depth 4
  "mode=+ M-'"            fcd                # Cd interactively depth 1
  # 'mode=@ M-;'          skim-cd-widget
  'mode=+ M-/'            __zoxide_zi        # Cd interactively with zoxide
  # 'mode=@ M-['            fstat
  # 'mode=@ M-]'            fadd

  'mode=menuselect Space' .accept-line
  'mode=menuselect C-r'   history-incremental-search-backward
  'mode=menuselect C-f'   history-incremental-search-forward

# ========================== Testing ==========================
# 'mode=vicmd u'  undo
# 'mode=vicmd Z'  where-is

  'mode=vicmd ;d'   dirstack-plus  # show the directory stack
)

vbindkey -A Zkeymaps

# Surround text under cursor with quotes
builtin bindkey -M vicmd -s 'y;' 'viwS'
# builtin bindkey -s '^[\"' 'ncd\n'

builtin bindkey -s '\e1' "!:0 \t"        # last command
# bindkey -s '\e2' "!:0-1 \t"      # last command + 1st argument
# bindkey -s '\e3' "!:0-2 \t"      # last command + 1st-2nd argument
# bindkey -s '\e4' "!:0-3 \t"      # last command + 1st-3rd argument
# bindkey -s '\e5' "!:0-4 \t"      # last command + 1st-4th argument
# bindkey -s '\e`' "!:0- \t"       # all but the last argument
# bindkey -s '\e9' "!:0 !:2* \t"   # all but the 1st argument (aka 2nd word)

# expand-history     _expand_alias    _expand_word
# spell-word         _correct_word    exchange-point-and-mark
# neg-argument       _list_expansions list-expand
# _most_recent_file  _next_tags       _history-complete-newer
# _complete_help     _complete_tag

# zle -N _complete_debug_generic _complete_help_generic
# 'C-x C-m'         _complete_debug_generic
# 'C-x C-t'         _complete_tag

local m c
# ci", ci', ci`, di", etc
autoload -Uz :select-quoted; zle -N :select-quoted
# ci{, ci(, ci<, di{, etc
autoload -Uz :select-bracketed; zle -N :select-bracketed
foreach m (visual viopp) {
  foreach c ({a,i}{\',\",\`}) {
    bindkey -M $m $c :select-quoted
  }
  foreach c ({a,i}${(s..)^:-'()[]{}<>bBra'}) {
    bindkey -M $m $c :select-bracketed
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
function :@execute() {
  BUFFER="${(j:; :)@}"
  zle accept-line
}

function :@replace-buffer() {
  LBUFFER="${(j:; :)@}"
  RBUFFER=""
}

function :@append-to-buffer() {
  LBUFFER="${BUFFER}${(j:; :)@}"
}

function :@edit-file() {
  local -a args
  args=("${(@q)@}")
  BUFFER="${EDITOR} ${args}"
  zle accept-line
}

# ========================== Unused ==========================

# TODO: Set this to history file that is similar to per-dir-history
function :stash-buffer() {
  [[ -z $BUFFER ]] && return
  fc -R =(print -r -- ${BUFFER//$'\n'/$'\\\n'})
  BUFFER=
}; zle -N :stash-buffer
Zkeymaps+=('C-x o' :stash-buffer)

# Desc:
function :save-alias() {
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
# zle -N :save-alias
# Zkeymaps+=('mode=vicmd Q' :save-alias)

# Add command to history without executing it
function :commit-to-history() {
  print -rs ${(z)BUFFER}
  zle send-break
}
# zle -N :commit-to-history

# ============================ Other Func ============================
# View keybindings
function lskb() {
  local -A keyb=(); for k v in ${(kv)Zkeymaps}; do
    k="%F{1}%B$k%f%b" v="%F{3}$v%f" keyb[${(%)k}]=${(%)v}
  done
  print -raC 2 -- ${(Oakv)keyb[@]}
  # print -rC 2 -- ${(nkv)keyb}
  # print -ac -- ${(Oa)${(kv)keyb[@]}}
}

unalias which-command 2> /dev/null
zle -C  which-command list-choices which-command
function which-command() {
  zle -I
  command whatis      -- $words[@] 2> /dev/null
  builtin whence -aSv -- $words[@] 2> /dev/null
  compstate[insert]=
  compstate[list]=
}

typeset -g HELPDIR='/usr/share/zsh/help'
