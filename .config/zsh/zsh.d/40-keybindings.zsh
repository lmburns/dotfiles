#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2021-06-07                                                   #
#    @module: keybindings                                                  #
#      @desc: ZLE functions and keybindings                                #
#===========================================================================

# NOTE: there are still lots more functions in
#         - 'zsh/plugins/zle-utils.zsh'
#         - 'zsh/zsh.d/40-keybindings.zsh'

# TODO: find zsh substitute command
# TODO: get exchange to work by allowing moving cursor

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
builtin bindkey -M vicmd -r ';'

# =========================== zle Functions ==========================
# ====================================================================

#  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Desc: list keybindings in current mode
function :list-keys() {
  zmodload -Fa zsh/parameter p:functions
  (( $+functions[help::bindkey] )) || return 0
  help::bindkey -M $KEYMAP -b
  zle reset-prompt
}; zle -N :list-keys
Zkeymaps+=('M-\' :list-keys)
Zkeymaps+=('mode=vicmd M-\' :list-keys)
Zkeymaps+=('mode=visual M-\' :list-keys)
Zkeymaps+=('mode=viopp M-\' :list-keys)
Zkeymaps[M-v]=describe-key-briefly      # Describe what key does

# Desc: RG with $BUFFER
function :RG-buffer() {
  zmodload -Fa zsh/parameter p:functions
  eval "() { $functions[RG] } $BUFFER"
  zle reset-prompt
}; zle -N :RG-buffer
Zkeymaps+=('C-x C-u' :RG-buffer)

# @desc: toggle p10k right side widgets
function :toggle-right-prompt() {
  p10k display '*/right'=hide,show
}; zle -N :toggle-right-prompt
Zkeymaps[M-S-P]=:toggle-right-prompt

# @desc: show per-directory-history with fzf
function :per-dir-fzf() {
  per-directory-history-toggle-history
  fzf-history-widget
  # skim-history-widget
}; zle -N :per-dir-fzf       # fzf history
Zkeymaps[M-S-R]=:per-dir-fzf

# @desc: copy text, display message
function :copymsg() {
  print -rn $BUFFER | xsel -ib --trim
  zle -M "copied: ${BUFFER}"
}; zle -N :copymsg
Zkeymaps+=('mode=vicmd yy' :copymsg)

# @desc: cut text in visual mode and copy
function :vi-delete-visual() {
  zle .vi-delete
  print -rn "$CUTBUFFER" | xsel -ib --trim
}; zle -N :vi-delete-visual
Zkeymaps+=("mode=visual x'" :vi-delete-visual)

function :vi-kill-eol() {
  local clip="$(xsel -ob)"
  zle .vi-kill-eol
  print -rn "$clip" | xsel -ib --trim
}; zle -N :vi-kill-eol
Zkeymaps+=("mode=vicmd D" :vi-kill-eol)

# === zce ================================================================ [[[
function :zce-char() {
  [[ -z $BUFFER ]] && zle up-history
  zstyle ':zce:*' prompt-char '%B%F{12}Jump to character:%F%b '
  zstyle ':zce:*' prompt-key '%B%F{12}Target key:%F%b '
  with-zce zce-raw zce-searchin-read
}; zle -N :zce-char

function :zce-fchar() {
  zle :zce-char
}; zle -N :zce-fchar
Zkeymaps+=("mode=vicmd f" :zce-fchar)
Zkeymaps+=("mode=vicmd ;f" :zce-fchar)
Zkeymaps+=("mode=viins ;f" :zce-fchar)
Zkeymaps+=("mode=viopp ;f" :zce-fchar)

function :zce-tchar() {
  zle :zce-char
  ((CURSOR--))
}; zle -N :zce-tchar
Zkeymaps+=("mode=vicmd t" :zce-tchar)
Zkeymaps+=("mode=vicmd ;t" :zce-tchar)
Zkeymaps+=("mode=viins ;t" :zce-tchar)
Zkeymaps+=("mode=viopp ;t" :zce-tchar)

function :zce-Fchar() {
  zle :zce-char
}; zle -N :zce-Fchar
Zkeymaps+=("mode=vicmd F" :zce-Fchar)
Zkeymaps+=("mode=vicmd ;F" :zce-Fchar)
Zkeymaps+=("mode=viins ;F" :zce-Fchar)
Zkeymaps+=("mode=viopp ;F" :zce-Fchar)

function :zce-Tchar() {
  zle :zce-char
  ((CURSOR++))
}; zle -N :zce-Tchar
Zkeymaps+=("mode=vicmd T" :zce-Tchar)
Zkeymaps+=("mode=vicmd ;T" :zce-Tchar)
Zkeymaps+=("mode=viins ;T" :zce-Tchar)
Zkeymaps+=("mode=viopp ;T" :zce-Tchar)

function :zce-delete-char() {
  [[ -z $BUFFER ]] && zle up-history
  typeset -gA reply
  reply[pbuffer]=$BUFFER reply[pcursor]=$CURSOR
  local keys=${(j..)$(print {a..z} {A..Z})}
  zstyle ':zce:*' prompt-char '%B%F{13}Delete to character:%F%b '
  zstyle ':zce:*' prompt-key '%B%F{13}Target key:%F%b '
  zce-raw zce-searchin-read $keys
}; zle -N :zce-delete-char

function :zce-delete-fchar() {
  zle :zce-delete-char
  local pcursor=$reply[pcursor] pbuffer=$reply[pbuffer]

  if (( $CURSOR < $pcursor ))  {
    pbuffer[$CURSOR,$pcursor]=$pbuffer[$CURSOR]
  } else {
    pbuffer[$pcursor,((CURSOR+1))]=$pbuffer[$pcursor]
    CURSOR=$pcursor
  }
  BUFFER=$pbuffer
}; zle -N :zce-delete-fchar
Zkeymaps+=("mode=vicmd df" :zce-delete-fchar)
Zkeymaps+=("mode=vicmd dF" :zce-delete-Fchar)

function :zce-delete-tchar() {
  zle :zce-delete-char
  local pcursor=$reply[pcursor] pbuffer=$reply[pbuffer]

  if (( $CURSOR < $pcursor ))  {
    pbuffer[$CURSOR,$pcursor]=$pbuffer[$CURSOR]
  } else {
    pbuffer[$pcursor,$CURSOR]=$pbuffer[$pcursor]
    CURSOR=$pcursor
  }
  BUFFER=$pbuffer
}; zle -N :zce-delete-tchar
Zkeymaps+=("mode=vicmd dt" :zce-delete-tchar)
Zkeymaps+=("mode=vicmd dT" :zce-delete-tchar)
# ]]]

# === Workon ============================================================= [[[
# TODO: Figure out how to set numeric
function __complete_help_full() {
  # NUMERIC=2
  zle universal-argument 2
  zle _complete_help -n $(( ${NUMERIC:-2} ))
}
zle -C __complete_help_full complete-word _complete_help_full
# zle -N _complete_help_full
# compdef -k _complete_help_full complete-word \Cx\Ch

zle -N _complete_debug_generic _complete_help_generic
Zkeymaps+=("mode=viins C-x C-m" _complete_debug_generic)
# ZSH_TRACE_GENERIC_WIDGET
# 'C-x C-t'         _complete_tag
# ]]]

# === External =========================================================== [[[
# autoload -Uz incarg # increment digit
# autoload -Uz insert-unicode-char; zle -N insert-unicode-char
# autoload -Uz edit-command-line; zle -N edit-command-line
# autoload -Uz url-quote-magic
# zle -N self-insert url-quote-magic

autoload -U +X read-from-minibuffer

# === Plugin ======================= [[[
zle -N zi-browse-symbol
zle -N zi-browse-symbol-backwards  zi-browse-symbol
zle -N zi-browse-symbol-pbackwards zi-browse-symbol
zle -N zi-browse-symbol-pforwards  zi-browse-symbol
Zkeymaps[C-n]=zi-browse-symbol # Browse zsh tag files
# ]]]

# === Customized =================== [[[
autoload -Uz :surround
zle -N delete-surround :surround
zle -N add-surround    :surround
zle -N change-surround :surround
Zkeymaps+=('mode=vicmd ds' delete-surround) # Delete 'surrounders'
Zkeymaps+=('mode=vicmd cs' change-surround) # Change 'surrounders'
Zkeymaps+=('mode=vicmd ys' add-surround)    # Add 'surrounders'
Zkeymaps+=('mode=visual S' add-surround)    # Add 'surrounders'

autoload -Uz :exchange
zle -N :exchange
zle -N :exchange-line  :exchange
zle -N :exchange-clear :exchange
bindkey -M vicmd -r 's'
# Zkeymaps+=('mode=vicmd sx'  :exchange)
# Zkeymaps+=('mode=vicmd ss'  :exchange-line)
# Zkeymaps+=('mode=vicmd sxc' :exchange-clear)
# Zkeymaps+=('mode=visual X'  :exchange)

zle -N zvm::switch_keyword
Zkeymaps+=('mode=vicmd _' zvm::switch_keyword)  # Decrement item under keyboard
Zkeymaps+=('mode=vicmd \+' zvm::switch_keyword) # Increment item under keyboard

zle -N replace-pattern @replace-string; Zkeymaps+=('mode=vicmd R' replace-pattern)       # Replace text on the command line
zle -N :insert-numeric;                 Zkeymaps+=('mode=viins C-x C-n' :insert-numeric) # Insert octal/hex key
zle -N :transpose-words-at-point;       Zkeymaps[M-t]=:transpose-words-at-point          # Transpose words on the cursor
zle -N :b1fow;  Zkeymaps+=('mode=@ C-b' :b1fow)         # Surfraw open w3m
zle -N zmacho;  Zkeymaps+=('C-\' zmacho)                # Fzf man pages
zle -N pw;      Zkeymaps[M-p]=pw                        # Pueue
# ]]]

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "$terminfo[kpp]"   ]] && bindkey "$terminfo[kpp]"   up-line-or-beginning-search   # PAGE UP
[[ -n "$terminfo[knp]"   ]] && bindkey "$terminfo[knp]"   down-line-or-beginning-search # PAGE DOWN
[[ -n "$terminfo[khome]" ]] && bindkey "$terminfo[khome]" beginning-of-line             # HOME
[[ -n "$terminfo[kend]"  ]] && bindkey "$terminfo[kend]"  end-of-line                   # END
[[ -n "$terminfo[kdch1]" ]] && bindkey "$terminfo[kdch1]" delete-char                   # DELETE
[[ -n "$terminfo[kbs]"   ]] && bindkey "$terminfo[kbs]"   backward-delete-char          # BACKSPACE
# ]]]

# ============================= BINDINGS =============================
# ====================================================================
# bindkey '^I' expand-or-complete-prefix # Fix autopair completion within brackets
# bindkey '^T' backward-kill-word

# if [[ $TMUX ]]; then
#   zle -N tmux::attach-create
#   vbindkey 'M-t' tmt
#   zle -N tmux::select-window
#   vbindkey 'M-w' tmux::select-window
# fi

# Available modes: all normal modes, str, @, -, + (see marlonrichert/zsh-edit)
Zkeymaps+=(
# ========================== Bindings ==========================
  # 'M-S-R'               fzf-history-widget  # Builtin fzf history widget
  'mode=viins M-c'        fzf-cd-widget         # Builtin fzf cd widget
  'mode=viins C-t'        fzf-file-widget       # Insert file into cli
  'mode=viins C-a'        autosuggest-execute   # Execute the autosuggestion

  'mode=viins M-g'        get-line              # Get line from buffer-stack
  'mode=viins M-q'        push-line-or-edit     # Push line onto buffer stack
  # 'M-S-q'               push-input          # Push multi-line onto buffer stack
  'mode=viins C-y'        yank                  # Insert the contents of the kill buffer at the cursor position
  'mode=viins C-w'        vi-backward-kill-word    # Kill word backwards

  # 'mode=viins M-['        vi-kill-line         # Kill cursorpos to beginning
  # 'mode=viins M-]'        vi-kill-eol          # Kill cursorpos to end
  'mode=viins M-['        backward-kill-line   # Kill cursorpos to beginning
  'mode=viins M-]'        kill-line            # Kill cursorpos to end
  'mode=viins C-h'        backward-delete-char

  'mode=viins jk'         vi-cmd-mode        # Switch to vi-cmd mode
  'mode=viins kj'         vi-cmd-mode        # Switch to vi-cmd mode

  # 'mode=viins C-S-h'      vi-backward-word
  # 'mode=vicmd :'          execute-named-cmd
  'mode=vicmd u'          undo
  'mode=vicmd U'          redo
  'mode=vicmd ;u'         vi-undo-change
  # 'mode=viins M-u'      vi-undo-change
  # 'mode=vicmd L'        end-of-line            # Move to end of line, even on another line
  # 'mode=vicmd H'        beginning-of-line      # Moves to very beginning, even on another line
  'mode=vicmd L'          vi-end-of-line
  'mode=vicmd H'          vi-beginning-of-line
  'mode=vicmd 0'          vi-digit-or-beginning-of-line

  'mode=vicmd Y'          vi-yank-whole-line
  'mode=vicmd ye'         vi-yank-eol

  'mode=vicmd ;x'         vi-backward-kill-word    # Kill word backwards
  'mode=vicmd C'          vi-change-eol        # Kill text to end of line & start in insert
  'mode=vicmd S'          vi-change-whole-line # Change all text to start over
  'mode=vicmd cc'         vi-change-whole-line # Change all text to start over
  'mode=vicmd #'          vi-pound-insert
  'mode=vicmd %'          vi-match-bracket

  'mode=viins C-x C-d'    _complete_debug
  'mode=viins C-x ?'      _complete_debug
  'mode=viins C-x h'      _complete_help
  'mode=viins C-x C-t'    _complete_tag
  'mode=viins C-x C-r'    _read_comp
  'mode=viins C-x .'      fzf-tab-debug

  'mode=viins C-x m'      _most_recent_file  # Insert most recent file
  'mode=viins C-x C'      _correct_filename  # Correct filename under cursor
  'mode=viins C-x c'      _correct_word      # Correct word under cursor
  'mode=viins C-x a'      _expand_alias      # Expand alias
  'mode=viins C-x e'      _expand_word       # Expand word

  'mode=viins C-x d'      _list_expansions   #
  'mode=viins C-x n'      _next_tags         # Don't use tag-order

  # 'mode=viins \e/'       _history_complete_word   #

  # 'mode=viins C-x ~'      _bash_list-choices #

# expand-history spell-word
# neg-argument list-expand
# _most_recent_file  _next_tags _history-complete-newer

  'mode=vicmd gC'         where-is             # Tell you the keys for an editor command
  'mode=vicmd g?'         which-command        # Display info about a command
  'mode=vicmd ga'         what-cursor-position
  'mode=vicmd K'          run-help      # Open man-page
  'mode=vicmd ='          list-choices         # List choices (i.e., alias, command, vars, etc)

  # 'mode=vicmd <'          vi-up-line-or-history
  # 'mode=vicmd >'          vi-down-line-or-history
  # 'mode=vicmd /'        vi-history-search-backward
  'mode=vicmd /'          history-incremental-pattern-search-backward

  ';z'                    zbrowse               # Bring up zbrowse TUI

  # bindkey -M vivis '+'  vi-visual-down-line
  # bindkey -M vivis ','  vi-visual-rev-repeat-find
  # bindkey -M vivis '0'  vi-visual-bol
  # bindkey -M vivis ';'  vi-visual-repeat-find

  # "mode=str M-S-'"      ncd                # Zsh navigation tools change dir
  # 'mode=str M-o'        lf                 # Regular lf
  'mode=str M-o'          lc                 # Lf change dir
  'mode=str M-S-O'        lfub               # Lf ueberzug
  'mode=str ;o'           noptions           # Edit zsh options
  'mode=+ M-.'            kf                 # Formarks like thing in rust
  'mode=+ M-,'            frd                # Cd interactively recent dirs
  'mode=+ M-;'            'fcd 4'            # Cd interactively depth 4
  "mode=+ M-'"            fcd                # Cd interactively depth 1
  'mode=+ M-/'            __zoxide_zi        # Cd interactively with zoxide
  # 'mode=@ M-;'          skim-cd-widget
  # 'mode=@ M-['            fstat
  # 'mode=@ M-]'            fadd

  'mode=menuselect Space' .accept-line
  'mode=menuselect C-r'   history-incremental-search-backward
  'mode=menuselect C-f'   history-incremental-search-forward

# ========================== Testing ==========================

  # 'mode=vicmd ;d'   dirstack-plus  # show the directory stack
)

# copy-prev-word
# universal-argument

vbindkey -A Zkeymaps

# Surround text under cursor
builtin bindkey -M vicmd -s 'y;' "viwS"
# builtin bindkey -s '^[\"' 'ncd\n'

builtin bindkey -s '\e1' "!:0 \t"        # last command
# bindkey -s '\e`' "!:0- \t"       # all but the last argument
# bindkey -s '\e9' "!:0 !:2* \t"   # all but the 1st argument (aka 2nd word)

local m c
# ci", ci', ci`, di", etc
autoload -Uz :select-quoted; zle -N :select-quoted
# ci{, ci(, ci<, di{, etc
autoload -Uz :select-bracketed; zle -N :select-bracketed
  # foreach c ({a,i}{\',\",\`}) {
foreach c ({a,i}${(s..)^:-\'\"\`\|,./:;-=+@}) {
  bindkey -M visual $c :select-quoted
  bindkey -M viopp  $c :select-quoted
}
foreach c ({a,i}${(s..)^:-'()[]{}<>bBra'}) {
  bindkey -M visual $c :select-bracketed
  bindkey -M viopp  $c :select-bracketed
}

# autoload -U select-word-match
# zle -N select-in-camel select-word-match
# bindkey -M viopp ic select-in-camel
# zstyle ':zle:*-camel' word-style normal-subword

# # press "ctrl-x d" to insert the actual date in the form yyyy-mm-dd
# function insert-datestamp () { LBUFFER+=${(%):-'%D{%Y-%m-%d}'}; }
# zle -N insert-datestamp
#
# # press esc-m for inserting last typed word again (thanks to caphuso!)
# function insert-last-typed-word () { zle insert-last-word -- 0 -1 };
# zle -N insert-last-typed-word;

# ============================ Other Func ============================
# @desc: View keybindings
function lskb() {
  # local -A keyb=(); for k v in ${(kv)Zkeymaps}; do
  #   k="%F{1}%B$k%f%b" v="%F{3}$v%f" keyb[${(%)k}]=${(%)v}
  # done
  # print -raC 2 -- ${(Oakv)keyb[@]}

  local -a keys
  local key
  keys=( "${(@kon)${(@k)Zkeymaps}}" )
  for key in "${keys[@]}"; do
    print -Pr -- "%F{52}%B${(r:25:)${key:+${key}%f%b:}}%b   %F{81}${Zkeymaps[$key]}%f"
  done
}

# @desc: List ZLE's current undo number/total
function lsundo() {
  zle -M "Undo:$UNDO_CHANGE_NO/$UNDO_CHANGE_LIMIT"
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
