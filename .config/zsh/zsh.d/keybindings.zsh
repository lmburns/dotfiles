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

autoload -Uz incarg
# autoload -Uz insert-unicode-char; zle -N insert-unicode-char

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround    surround
zle -N change-surround surround

# =========================== zle Functions ==========================
# ====================================================================

# autoload -Uz edit-command-line; zle -N edit-command-line

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
  fzf-history-widget
  # skim-history-widget
}
zle -N per-dir-fzf       # fzf history

# RG with $BUFFER
function RG_buff() {
  zmodload -Fa zsh/parameter p:functions
  eval "() { $functions[RG] } $BUFFER"
  zle reset-prompt
}
zle -N RG_buff

# Copy $BUFFER
function copyx() {
  print -rn $BUFFER | xsel -ib --trim
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
zle -N macho-zle
zle -N __unicode_translate # translate unicode to symbol

# zle -N fcd-zle
# zle -N bow2

autoload up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "$terminfo[kpp]"   ]] && bindkey "$terminfo[kpp]"   up-line-or-beginning-search   # PAGE UP
[[ -n "$terminfo[knp]"   ]] && bindkey "$terminfo[knp]"   down-line-or-beginning-search # PAGE DOWN
[[ -n "$terminfo[khome]" ]] && bindkey "$terminfo[khome]" beginning-of-line             # HOME
[[ -n "$terminfo[kend]"  ]] && bindkey "$terminfo[kend]"  end-of-line                   # END
[[ -n "$terminfo[kdch1]" ]] && bindkey "$terminfo[kdch1]" delete-char                   # DELETE
[[ -n "$terminfo[kbs]"   ]] && bindkey "$terminfo[kbs]"   backward-delete-char          # BACKSPACE

# =============================== zaw ===============================
# ====================================================================
autoload -U read-from-minibuffer

# ??
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
  buf=$(locate ${(Q@)${(z)REPLY}})
  (( $? )) && return 1
  : ${(A)candidates::=${(f)buf}}
  BUFFER="$start"
}
zle -N src-locate

function fzf-locate-widget() {
  local selected
  if selected=$(locate / | fzf -q "$LBUFFER"); then
    LBUFFER=$selected
  fi
  zle redisplay
}
zle -N fzf-locate-widget

# TODO: Set this to history file that is similar to per-dir-history
function stash_buffer() {
  [[ -z $BUFFER ]] && return
  fc -R =(print -r -- ${BUFFER//$'\n'/$'\\\n'})
  BUFFER=
}
zle -N stash_buffer

# ============================= BINDINGS =============================
# ====================================================================
if [[ $TMUX ]]; then
  zle -N tmux::attach-create
  vbindkey 'M-t' tmt                 # alt-t
  zle -N tmux::select-window
  vbindkey 'M-w' tmux::select-window # alt-w
fi

# bindkey '^I' expand-or-complete-prefix # Fix autopair completion within brackets
# bindkey '^T' backward-kill-word


# Available modes: all normal modes, str, @, -, + (see marlonrichert/zsh-edit)
declare -gA keybindings; keybindings=(
# ========================== Bindings ==========================
  # 'M-q'             push-line-or-edit     # zsh-edit
  # 'F1'                    dotbare-fstat
  # 'F2'                    db-faddf
  # 'ga'                    what-cursor-position
  # 'Home'                  beginning-of-line
  # 'End'                   end-of-line
  # 'Delete'                delete-char
  ';z'                    zbrowse
  'Esc-f'                 wfxr::fzf-file-edit-widget
  'Esc-i'                 fe
  'M-\'                   list-keys             # list keybindings in mode
  'M-r'                   per-dir-fzf
  'M-v'                   describe-key-briefly  # describe what key does
  'M-S-R'                 fzf-history-widget
  'C-o'                   clipboard-fzf         # greenclip fzf
  'M-p'                   pw                    # fzf pueue
  'M-u'                   __unicode_translate   # translate 0000 to unicode
  'M-x'                   cd-fzf-ghqlist-widget # cd ghq fzf
  'M-S-P'                 toggle-right-prompt
  'C-]'                   macho-zle
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
  'mode=vicmd :'          execute-named-cmd
  'mode=vicmd 0'          vi-digit-or-beginning-of-line
  'mode=vicmd u'          vi-undo-change
  'mode=vicmd R'          replace-pattern
  'mode=vicmd U'          redo
  'mode=vicmd S'          backward-kill-line
  # 'mode=vicmd L'    end-of-line # Move to end of line, even on another line
  # 'mode=vicmd H'    beginning-of-line # Moves to very beginning, even on another line
  'mode=vicmd L'          vi-end-of-line
  'mode=vicmd H'          vi-beginning-of-line
  'mode=vicmd Q'          src-locate # search for something placing results in $candidates[@]
  'mode=vicmd ?'          which-command
  'mode=vicmd K'          run-help
  'mode=vicmd yy'         copyx                    # copy text, display message
  'mode=vicmd ;v'         clipboard-fzf            # greenclip fzf
  'mode=vicmd ;e'         edit-command-line-as-zsh # edit command in editor
  'mode=vicmd ;x'         vi-backward-kill-word    # kill word backwards
  'mode=vicmd cc'         vi-change-whole-line     # change all text to start over
  'mode=vicmd ds'         delete-surround          # delete 'surrounders'
  'mode=vicmd cs'         change-surround          # change 'surrounders'
  'mode=visual S'         add-surround             # add 'surrounders'
  'mode=vicmd M-\'        list-keys                # list keybindings in mode
  'mode=vicmd /'          history-incremental-pattern-search-backward
  'mode=vicmd \$'         expand-all               # expand alias etc under keyboard
  'mode=vicmd \-'         zvm_switch_keyword       # decrement item under keyboard
  'mode=vicmd \+'         zvm_switch_keyword       # increment item under keyboard
  'mode=vicmd ,.'         get-line                 # get line from buffer-stack
  'mode=vicmd ..'         push-line                # push line to buffer-stack
  'mode=viins jk'         vi-cmd-mode              # switch to vi-cmd mode
  'mode=viins kj'         vi-cmd-mode              # switch to vi-cmd mode
  'mode=str M-o'          lc                       # lf change dir
  'mode=str M-S-O'        lfub                     # lf ueberzug
  'mode=str C-u'          lf                       # regular lf
  'mode=str ;o'           noptions                 # edit zsh options
  'mode=+ M-.'            kf                       # a formarks like thing in rust
  'mode=+ M-,'            frd                      # cd interactively recent dir
  'mode=+ M-;'            fcd                      # cd interactively
  # 'mode=@ M-;'          skim-cd-widget
  'mode=+ M-/'            __zoxide_zi
  'mode=@ C-b'            bow2                     # surfraw open w3m
  'mode=@ M-['            fstat
  'mode=@ M-]'            fadd

  'mode=menuselect Space' .accept-line
  'mode=menuselect C-r'   history-incremental-search-backward
  'mode=menuselect C-f'   history-incremental-search-forward

# ========================== Testing ==========================
# 'mode=vicmd Q'  save-alias
# 'mode=vicmd u'  undo
# 'mode=vicmd Z'  where-is

  'mode=vicmd ;d'   dirstack-plus  # show the directory stack
  'C-x o'           stash_buffer
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

function callback-edit-file() {
    local -a args
    args=("${(@q)@}")
    BUFFER="${EDITOR} ${args}"
    zle accept-line
}

# ========================== Unused ==========================

# Add command to history without executing it
function commit-to-history() {
  print -rs ${(z)BUFFER}
  zle send-break
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

# ============================= Zle Help =============================
# ====================================================================

# TODO:

# declare -g HELP_LINES_PER_PAGE=20
# declare -g HELP_ZLE_CACHE_FILE=${XDG_CACHE_HOME}/zle_help_lines.zsh
# # Generates the help text
# help_zle_parse_keybindings()
# {
#     emulate -L zsh
#     setopt extendedglob
#     unsetopt ksharrays  #indexing starts at 1
#
#     #v1# choose files that help-zle will parse for keybindings
#     ((${+HELPZLE_KEYBINDING_FILES})) || HELPZLE_KEYBINDING_FILES=( /etc/zsh/zshrc ~/.zshrc.pre ~/.zshrc ~/.zshrc.local )
#
#     if [[ -r $HELP_ZLE_CACHE_FILE ]]; then
#         local load_cache=0
#         for f ($HELPZLE_KEYBINDING_FILES) [[ $f -nt $HELP_ZLE_CACHE_FILE ]] && load_cache=1
#         [[ $load_cache -eq 0 ]] && . $HELP_ZLE_CACHE_FILE && return
#     fi
#
#     #fill with default keybindings, possibly to be overwriten in a file later
#     #Note that due to zsh inconsistency on escaping assoc array keys, we encase the key in '' which we will remove later
#     local -A help_zle_keybindings
#     help_zle_keybindings['<Ctrl>@']="set MARK"
#     help_zle_keybindings['<Ctrl>x<Ctrl>j']="vi-join lines"
#     help_zle_keybindings['<Ctrl>x<Ctrl>b']="jump to matching brace"
#     help_zle_keybindings['<Ctrl>x<Ctrl>u']="undo"
#     help_zle_keybindings['<Ctrl>_']="undo"
#     help_zle_keybindings['<Ctrl>x<Ctrl>f<c>']="find <c> in cmdline"
#     help_zle_keybindings['<Ctrl>a']="goto beginning of line"
#     help_zle_keybindings['<Ctrl>e']="goto end of line"
#     help_zle_keybindings['<Ctrl>t']="transpose charaters"
#     help_zle_keybindings['<Alt>t']="transpose words"
#     help_zle_keybindings['<Alt>s']="spellcheck word"
#     help_zle_keybindings['<Ctrl>k']="backward kill buffer"
#     help_zle_keybindings['<Ctrl>u']="forward kill buffer"
#     help_zle_keybindings['<Ctrl>y']="insert previously killed word/string"
#     help_zle_keybindings["<Alt>'"]="quote line"
#     help_zle_keybindings['<Alt>"']="quote from mark to cursor"
#     help_zle_keybindings['<Alt><arg>']="repeat next cmd/char <arg> times (<Alt>-<Alt>1<Alt>0a -> -10 times 'a')"
#     help_zle_keybindings['<Alt>u']="make next word Uppercase"
#     help_zle_keybindings['<Alt>l']="make next word lowercase"
#     help_zle_keybindings['<Ctrl>xd']="preview expansion under cursor"
#     help_zle_keybindings['<Alt>q']="push current CL into background, freeing it. Restore on next CL"
#     help_zle_keybindings['<Alt>.']="insert (and interate through) last word from prev CLs"
#     help_zle_keybindings['<Alt>,']="complete word from newer history (consecutive hits)"
#     help_zle_keybindings['<Alt>m']="repeat last typed word on current CL"
#     help_zle_keybindings['<Ctrl>v']="insert next keypress symbol literally (e.g. for bindkey)"
#     help_zle_keybindings['!!:n*<Tab>']="insert last n arguments of last command"
#     help_zle_keybindings['!!:n-<Tab>']="insert arguments n..N-2 of last command (e.g. mv s s d)"
#     help_zle_keybindings['<Alt>h']="show help/manpage for current command"
#
#     #init global variables
#     unset help_zle_lines help_zle_sln
#     typeset -g -a help_zle_lines
#     typeset -g help_zle_sln=1
#
#     local k v
#     local lastkeybind_desc contents     #last description starting with #k# that we found
#     local num_lines_elapsed=0            #number of lines between last description and keybinding
#     #search config files in the order they a called (and thus the order in which they overwrite keybindings)
#     for f in $HELPZLE_KEYBINDING_FILES; do
#         [[ -r "$f" ]] || continue   #not readable ? skip it
#         contents="$(<$f)"
#         for cline in "${(f)contents}"; do
#             #zsh pattern: matches lines like: #k# ..............
#             if [[ "$cline" == (#s)[[:space:]]#\#k\#[[:space:]]##(#b)(*)[[:space:]]#(#e) ]]; then
#                 lastkeybind_desc="$match[*]"
#                 num_lines_elapsed=0
#             #zsh pattern: matches lines that set a keybinding using bindkey or compdef -k
#             #             ignores lines that are commentend out
#             #             grabs first in '' or "" enclosed string with length between 1 and 6 characters
#             elif [[ "$cline" == [^#]#(bindkey|compdef -k)[[:space:]](*)(#b)(\"((?)(#c1,6))\"|\'((?)(#c1,6))\')(#B)(*)  ]]; then
#                 #description prevously found ? description not more than 2 lines away ? keybinding not empty ?
#                 if [[ -n $lastkeybind_desc && $num_lines_elapsed -lt 2 && -n $match[1] ]]; then
#                     #substitute keybinding string with something readable
#                     k=${${${${${${${match[1]/\\e\^h/<Alt><BS>}/\\e\^\?/<Alt><BS>}/\\e\[5~/<PageUp>}/\\e\[6~/<PageDown>}//(\\e|\^\[)/<Alt>}//\^/<Ctrl>}/3~/<Alt><Del>}
#                     #put keybinding in assoc array, possibly overwriting defaults or stuff found in earlier files
#                     #Note that we are extracting the keybinding-string including the quotes (see Note at beginning)
#                     help_zle_keybindings[${k}]=$lastkeybind_desc
#                 fi
#                 lastkeybind_desc=""
#             else
#               ((num_lines_elapsed++))
#             fi
#         done
#     done
#     unset contents
#     #calculate length of keybinding column
#     local kstrlen=0
#     for k (${(k)help_zle_keybindings[@]}) ((kstrlen < ${#k})) && kstrlen=${#k}
#     #convert the assoc array into preformated lines, which we are able to sort
#     for k v in ${(kv)help_zle_keybindings[@]}; do
#         #pad keybinding-string to kstrlen chars and remove outermost characters (i.e. the quotes)
#         help_zle_lines+=("${(r:kstrlen:)k[2,-2]}${v}")
#     done
#     #sort lines alphabetically
#     help_zle_lines=("${(i)help_zle_lines[@]}")
#     [[ -d ${HELP_ZLE_CACHE_FILE:h} ]] || mkdir -p "${HELP_ZLE_CACHE_FILE:h}"
#     echo "help_zle_lines=(${(q)help_zle_lines[@]})" >| $HELP_ZLE_CACHE_FILE
#     zcompile $HELP_ZLE_CACHE_FILE
# }
# typeset -g help_zle_sln
# typeset -g -a help_zle_lines
#
# #f1# Provides (partially autogenerated) help on keybindings and the zsh line editor
# help-zle()
# {
#     emulate -L zsh
#     unsetopt ksharrays  #indexing starts at 1
#     #help lines already generated ? no ? then do it
#     [[ ${+functions[help_zle_parse_keybindings]} -eq 1 ]] && {help_zle_parse_keybindings && unfunction help_zle_parse_keybindings}
#     #already displayed all lines ? go back to the start
#     [[ $help_zle_sln -gt ${#help_zle_lines} ]] && help_zle_sln=1
#     local sln=$help_zle_sln
#     #note that help_zle_sln is a global var, meaning we remember the last page we viewed
#     help_zle_sln=$((help_zle_sln + HELP_LINES_PER_PAGE))
#     zle -M "${(F)help_zle_lines[sln,help_zle_sln-1]}"
# }
#
# # display help for keybindings and ZLE (cycle pages with consecutive use)
# zle -N help-zle && bindkey '^xz' help-zle

# ======================== From Valodim/github =======================
# ======================== Run Norm Commands =========================

# applies $1 exnorm string to BUFFER
# function ex-norm-run() {
#
#     # this is a widget!
#     zle || return
#
#     # this might be possible using only stdin/stdout like this
#     # $(ex +ponyswag +%p - <<< $BUFFER)
#     # but we play it safe using a temp file here.
#
#     # use anonymous scope for a tempfile
#     () {
#
#         local -a posparams
#         (( CURSOR > 0 )) && posparams=( +'set ww+=l ve=onemore' +"normal! gg${CURSOR}l" +'set ww-=l ve=' )
#
#         # call ex in silent mode, move $CURSOR chars to the right with proper
#         # wrapping, run the specified command in normal mode, prepend position
#         # of the new cursor, write and exit.
#         ex -s $posparams \
#             +"normal! $1" \
#             +"let @a=col('.')" \
#             +'normal! ggi ' \
#             +'normal! "aP' \
#             +wq "$2"
#
#         result="$(<$2)"
#         # new buffer
#         BUFFER=${result#* }
#         # and new cursor position
#         CURSOR=$(( ${(M)result#* } -1 ))
#
#     } "$1" =(<<<"$BUFFER")
#
# }

# ZSH_HIST_DIR from localhist, or just use $ZSH or just use $HOME
# typeset -H ZSH_EXN_HIST=${ZSH_HIST_DIR:-${ZSH:-$HOME}}/.zsh_exnhist
#
# function ex-norm () {
#     # push exnorm history on stack, but only for the scope of this function
#     fc -p -a $ZSH_EXN_HIST
#     HISTNO=$HISTCMD
#
#     # anonymous scope for recursive-edit foo
#     () {
#
#         local pos=$[ $#PREDISPLAY + $#LBUFFER ]
#         # regular buffer is uninteresting for now.
#         # show a space if RBUFFER is empty, otherwise there will be nothing to underline
#         local pretext="$PREDISPLAY$LBUFFER${RBUFFER:- }$POSTDISPLAY
# "
#         local +h LBUFFER=""
#         local +h RBUFFER=""
#         local +h PREDISPLAY="${pretext}:normal! "
#         local +h POSTDISPLAY=
#
#         # underline the cursor position position, and highlight some stuff
#         local +h -a region_highlight
#         region_highlight=( "P$pos $[pos+1] underline" "P${#pretext} ${#PREDISPLAY} bold")
#
#         # prevent zsh_syntax_highlighting from screwing up our region_highlight
#         # not sure if this works with vanilla zsh_syntax_highlight...
#         local ZSH_HIGHLIGHT_MAXLENGTH=0
#
#         # let the user edit
#         zle recursive-edit -K exnorm
#
#         # everything ok? put BUFFER in REPLY then (and return accordingly)
#         (( $? )) || REPLY=$BUFFER
#
#     }
#
#     # positive status and REPLY set?
#     if (( $? == 0 )) && [[ -n $REPLY ]]; then
#         # append to exnorm history
#         print -sr -- ${REPLY%%$'\n'}
#         # if we have a non-empty $REPLY, process with ex
#         ex-norm-run $REPLY
#     fi
#
# }
# zle -N ex-norm

# runs last exnorm command, or n'th last if there is a NUMERIC argument
# ex-norm-repeat () {
#     fc -p -a $ZSH_EXN_HIST
#
#     # bail out if there is no such command in history
#     [[ -n $history[$[HISTCMD-${NUMERIC:-1}]] ]] || return 1
#
#     # run the ex command
#     ex-norm-run $history[$[HISTCMD-${NUMERIC:-1}]]
# }
# zle -N ex-norm-repeat
#
# # set up exnorm keymap
# bindkey -N exnorm main
#
# # might be nice to have some of the ^X as literals so they are passed to ex.
# # not sure about this though, and there is always ^V...
# # () {
# #     setopt localoptions braceccl
# #     # delete all prefix bindings
# #     for x in {A-Z}; bindkey -M exnorm -r -p "^$x"
# #     # delete all regular bindings
# #     bindkey -M exnorm -R '^A-^L' self-insert
# #     bindkey -M exnorm -R '^N-^Z' self-insert
# # }
#
# # these bindings may not be for everyone. I like them like this. jk is similar
# # to jj for normal mode, q and @ are similar to the macro commands in vim.
# bindkey -M main qq ex-norm
# bindkey -M main @@ ex-norm-repeat
# bindkey -M vicmd q ex-norm
# bindkey -M vicmd @ ex-norm-repeat

# ========================== Better Search ===========================
# ====================================================================

#### This messes up syntax highlighting

# bindkey -N visearch viins
# bindkey -M visearch ' ' self-insert
#
# typeset -g  vs_buffer      vs_keys
# typeset -gi vs_backward_p; (( vs_backward_p = 0 ))
# typeset -gi vs_repeat_p;   (( vs_repeat_p   = 0 ))
#
# function  with-visearch() {
#   local -a vs_region_highlight; vs_region_highlight=()
#   local -i vs_cursor; (( vs_cursor = CURSOR ))
#   {
#     emulate -L zsh
#     setopt localoptions extendedglob no_ksharrays no_kshzerosubscript
#     local nl=$'\n'
#     local old_predisplay="$PREDISPLAY"
#     local PREDISPLAY="${old_predisplay}$BUFFER${nl}"
#     local POSTDISPLAY=
#     local -a rh; rh=( ${region_highlight[@]} )
#     local -a region_highlight tmp
#     local hi
#     for hi (${rh[@]}) {
#       if [[ "${hi}" == P* ]]; then
#         vs_region_highlight+="${hi}"
#       else
#         : ${(A)tmp::=${=hi}}
#         vs_region_highlight+="P$(( $tmp[1]+$#old_predisplay )) $(( $tmp[2]+$#old_predisplay )) $tmp[3]"
#       fi
#     }
#     region_highlight=( ${vs_region_highlight} )
#     PREDISPLAY+=' '
#     with-visearch-dir "$@"
#   } always {
#     (( CURSOR = vs_cursor ))
#   }
# }
#
# function with-visearch-dir() {
#   if (( vs_backward_p == 0 )); then
#     PREDISPLAY[-1]='/'
#   else
#     PREDISPLAY[-1]='?'
#   fi
#   "$@"
# }
#
# function visearch-recursive-edit() {
#   local BUFFER="$1"
#   [[ -n "$BUFFER" ]] && {
#     visearch-maybe visearch-movecursor
#     (( vs_repeat_p = 1 ))
#   }
#   zle recursive-edit -K visearch && { vs_buffer="$BUFFER" } || { true }
# }
# zle -N visearch-recursive-edit
#
# # { { autoload -Uz keymap+widget && keymap+widget } &>/dev/null } || {
#
# function visearch+self-insert() {
#   region_highlight=( ${vs_region_highlight[@]} )
#   (( vs_repeat_p == 0 )) && zle .self-insert
#   (( vs_repeat_p == 0 )) && { visearch-maybe ; return $? }
#   (( vs_repeat_p == 1 )) && {
#     if [[ "$KEYS" == "$vs_keys" ]]; then
#       with-visearch-dir visearch-maybe visearch-movecursor ; return $?
#     elif [[ "${(L)KEYS}" == "$vs_keys" ]]; then
#       (( vs_repeat_p = 1 ))
#       local -i b; (( b = vs_backward_p ))
#       local -i vs_backward_p;
#       (( vs_backward_p = (( b == 1 ? 0 : 1 )) ))
#       with-visearch-dir visearch-maybe visearch-movecursor ; return $?
#     else
#       zle -U "$KEYS" ; zle .accept-line ; return $?
#     fi
#   }
# }
# zle -N visearch+self-insert
# zle -N self-insert visearch+self-insert
#
# function visearch+backward-delete-char() {
#   region_highlight=( ${vs_region_highlight[@]} )
#   zle .backward-delete-char && visearch-maybe
# }
# zle -N visearch+backward-delete-char
# zle -N backward-delete-char visearch+backward-delete-char
#
# function visearch-maybe () {
#   emulate -L zsh
#   [[ -n "${BUFFER}" ]] || return -1
#   setopt localoptions no_ksharrays no_kshzerosubscript
#   local kont="${1-}"
#   local -a match mbegin mend rh
#   local null=$'\0' nl=$'\n'
#   rh=(
#     ${${(0)${(S)PREDISPLAY//*(#b)(${~BUFFER})/P$((mbegin[1]-1)) $(($mend[1])) fg=black,bg=white,standout,bold${null}}}:#*$nl*}
#   )
#   if (( $#rh == (0|1) )) && [[ -z "$rh" ]]; then
#     return -1
#   fi
#   local -a param
#   if (( vs_backward_p == 0 )); then
#     param=('>=' 0 $#rh '++' '<' 1)
#   else
#     param=('<' $(($#rh+1)) 1 '--' '>' $#rh)
#   fi
#   () {
#     emulate -L zsh
#     local -a tmp
#     local cmp="$1" succ="$4" till="$5"
#     local -i i=$2 to=$3 n=0 wrapped=$6 tmp_cur=$vs_cursor
#     while :; do
#       while (( i$succ $till to )); do
#         (( n=${${rh[i]%% *}[2,-1]}-1 ))
#         if (( n $cmp vs_cursor )); then
#           : ${(A)tmp::=${=rh[i]}}
#           (( tmp_cur = $vs_cursor ))
#           [[ -n "${kont-}" ]] && { "$kont" $(( n + 1 )) }
#           (( vs_repeat_p == 0 )) || \
#           { (( vs_repeat_p == 1 )) && (( vs_cursor != tmp_cur )) } && {
#             rh[i]="$tmp[1] $tmp[2] fg=black,bg=255"
#             break 2
#           }
#         fi
#       done
#       : ${(A)tmp::=${=rh[$wrapped]}}
#       rh[wrapped]="$tmp[1] $tmp[2] fg=black,bg=255"
#       [[ -n "${kont-}" ]] && { "$kont" $(( ${${tmp[1]}[2,-1]} )) }
#       break
#     done
#   } $param[@]
#   region_highlight+=( ${rh[@]} )
# }
#
# function visearch+accept-line() {
#   (( vs_repeat_p == 0 )) && visearch-maybe visearch-movecursor
#   zle .accept-line
# }
#
# function visearch-movecursor() { (( vs_cursor = $1 )); }
#
# zle -N visearch+accept-line
# zle -N accept-line visearch+accept-line
# bindkey -M visearch "^M" visearch+accept-line
# bindkey -M visearch "^[" send-break
# bindkey -M visearch "^[^[" send-break
#
# function visearch() { visearch-aux; }
#
# function visearch-aux() {
#   (( vs_repeat_p = 0 ))
#   vs_keys="$KEYS"
#   case "$vs_keys" in
#     (N)
#       (( vs_repeat_p = 1 ))
#       (( vs_backward_p = (( vs_backward_p == 1 ? 0 : 1 )) ))
#       with-visearch visearch-recursive-edit "$vs_buffer"
#     ;;
#     (n)
#       (( vs_repeat_p = 1 ))
#       with-visearch visearch-recursive-edit "$vs_buffer"
#     ;;
#     ('?')
#       (( vs_backward_p = 1 ))
#     ;|
#     ('/')
#       (( vs_backward_p = 0 ))
#     ;|
#     (*)
#       with-visearch visearch-recursive-edit ""
#     ;;
#   esac
# }
# zle -N visearch
#
# bindkey -M vicmd '/' visearch
# bindkey -M vicmd '?' visearch
# bindkey -M vicmd 'n' visearch
# bindkey -M vicmd 'N' visearch
