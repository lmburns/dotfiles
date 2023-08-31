#===========================================================================
#    @author: Lucas Burns <burnsac@me.com> [lmburns]                       #
#   @created: 2023-06-10                                                   #
#    @module: zle-widgets                                                  #
#      @desc: Widgets for ZLE                                              #
#===========================================================================
# NOTE: there are still lots more functions in
#         - 'zsh/plugins/zle-utils.zsh'
#         - 'zsh/zsh.d/40-keybindings.zsh'

# @esc: search for something placing results in $candidates[@]
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

# FIX: doesn't detach when item is selected
# @desc: fzf with `lolcate` ($HOME)
function :src-lolcate-fzf() {
  local selected
  if selected=$(fzf -q "$LBUFFER" < <( lolcate --color=always "$LBUFFER" )); then
    LBUFFER=$selected
  fi
  zle redisplay
}; zle -N :src-lolcate-fzf
Zkeymaps+=('mode=vicmd ,ll' :src-lolcate-fzf)

# @desc: fzf with `mlocate`
function :src-locate-fzf() {
  local selected
  if selected=$(mlocate / | fzf -q "$LBUFFER"); then
    LBUFFER=$selected
  fi
  zle redisplay
}; zle -N :src-locate-fzf
Zkeymaps+=('mode=vicmd ,lo' :src-locate-fzf)

# @desc: create EMACs style tags for zsh; specifically the `zi-browse-symbol` widget
# NOTE: still compatible with vim
function mkzshtags() {
  # builtin print -rC1 **/.root(#q.N[1]:t)(#qe:'REPLY=1':)
  ( command git rev-parse >/dev/null 2>&1 \
      || [[ -f **/.root(#q.N[1]) ]] ) \
    && mktags -l zsh -u "$@" \
    && dunstify 'tags are finished'
      # && ctags -e -R --languages=zsh --pattern-length-limit=250 . \
}; zle -N mkzshtags
Zkeymaps[M-n]=mkzshtags # Create tags specifically for zsh

# @desc: create tags for C
function mkctags() {
  ( command git rev-parse >/dev/null 2>&1 \
      || [[ -f **/.root(#q.N[1]) ]] ) \
    && ctags -e -R --languages=zsh --pattern-length-limit=250 . \
    && dunstify 'tags are finished'
}; zle -N mkzshtags
Zkeymaps[M-n]=mkzshtags # Create tags specifically for zsh

# @desc: create tags for vim
function mkvimtags() {
  ( command git rev-parse >/dev/null 2>&1 \
      || [[ -f **/.root(#q.N[1]) ]] ) \
    && ctags -R --languages=vim after autoload ftdetect ftplugin indent compiler plugin vimrc \
    && dunstify 'tags are finished'
}; zle -N mkvimtags

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# @desc: expand aliases under the cursor
function :expand-aliases() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]=$BUFFER
  (($+functions[_expand-aliases])) &&
    BUFFER=${functions[_expand-aliases]#$'\t'} &&
    CURSOR=$#BUFFER
}; zle -N :expand-aliases

# @desc: expand everything under cursor
function :expand-all() {
  # zle -N :expand-aliases
  zle _expand_alias
  zle expand-word
}; zle -N :expand-all
Zkeymaps+=('mode=vicmd \$' :expand-all)
# Zkeymaps+=('mode=viins \t' :expand-all)

# @desc: xecute ZLE command
function :execute-command() {
  zmodload -Fa zsh/zleparameter p:widgets
  local selected=$(printf "%s\n" ${(k)widgets} \
    | ftb-tmux-popup --reverse --prompt="cmd> " --height=10 --border=none)
  zle redisplay
  [[ $selected ]] && zle $selected
}; zle -N :execute-command
Zkeymaps+=('C-x C-x' :execute-command)

# @desc: translate unicode to symbol
function :unicode_translate() {
  builtin setopt extendedglob
  local CODE=$BUFFER[-4,-1]
  [[ ! ${(U)CODE} = [0-9A-F](#c4) ]] && return
  CHAR=$(echo -e "\\u$CODE")
  BUFFER=$BUFFER[1,-5]$CHAR
  CURSOR=$#BUFFER
  zle redisplay
}; zle -N :unicode_translate
Zkeymaps[M-u]=:unicode_translate

# @desc: write date beside command
function :accept-line-rdate() {
  local old=$RPROMPT
  RPROMPT=$(date +%T 2>/dev/null)
  zle reset-prompt
  RPROMPT=$old
  zle accept-line
}; zle -N :accept-line-rdate
Zkeymaps[M-a]=:accept-line-rdate

# @desc: insert doas prefix to the command
function :insert-root-prefix() {
  # BUFFER="doas $BUFFER"
  # CURSOR=$(($CURSOR + 4))
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
  if [[ $BUFFER == doas\ * ]]; then
    if [[ ${#LBUFFER} -le 4 ]]; then
      RBUFFER="${BUFFER#doas }"
      LBUFFER=""
    else
      LBUFFER="${LBUFFER#doas }"
    fi
  else
    LBUFFER="doas $LBUFFER"
  fi
}; zle -N :insert-root-prefix
Zkeymaps+=('\e\e' :insert-root-prefix)

# @desc: insert fg prefix
function :job-foreground() {
  if [[ $#jobstates > 0 ]]; then
    zle .push-line
    BUFFER=" fg"
    zle .accept-line
  fi
}; zle -N :job-foreground

# @desc: insert a matching bracket
function :add-bracket() {
  local -A keys=('(' ')' '{' '}' '[' ']')
  BUFFER[$CURSOR+1]=${KEYS[-1]}${BUFFER[$CURSOR+1]}
  BUFFER+=$keys[$KEYS[-1]]
}; zle -N :add-bracket
Zkeymaps[M-\(]=:add-bracket
Zkeymaps[M-\{]=:add-bracket

# @desc: edit command in editor
autoload -U edit-command-line
function :edit-command-line-as-zsh {
  TMPSUFFIX=.zsh
  edit-command-line
  unset TMPSUFFIX
}; zle -N :edit-command-line-as-zsh
Zkeymaps+=('C-x C-e'       :edit-command-line-as-zsh)
Zkeymaps+=('mode=vicmd ;e' :edit-command-line-as-zsh)

# ══════════════════════════════════════════════════════════════════════

typeset -g bufstack_db="$ZDOTDIR/data/bufstack.db"

# @desc: save current buffer
function :stash-buffer() {
  [[ -z $BUFFER ]] && return
  if [[ ! -f "$bufstack_db" ]]; then
    touch "$bufstack_db"
  else
    fc -Rap "$bufstack_db" 20000 100
    print -rs -- "${BUFFER//$'\n'/$'\\\n'}"
    (( HISTNO++ ))
    fc -AIa "$bufstack_db"
  fi
  # print -r -- "${BUFFER//$'\n'/$'\\\n'}" >>! "$bufstack_db"
  # fc -R =(print -r -- ${BUFFER//$'\n'/$'\\\n'})
  BUFFER=
}; zle -N :stash-buffer
Zkeymaps+=('C-x C-s' :stash-buffer)

# @desc: get the buffer
function :get-buffer() {
  if [[ -s "$bufstack_db" ]]; then
    fc -Rap "$bufstack_db" 20000 100
    local sel=${${(@k-)history}[-1]}
    zle up-history
    local -a entries=( ${history[1,$((sel-1))]} )
    print -z ${(Fv)entries}
    fc -Wa "$bufstack_db"
  fi
}; zle -N :get-buffer
Zkeymaps+=('C-x C-g' :get-buffer)

function :show-buffer() {
  POSTDISPLAY="
  stack: $LBUFFER"
  zle push-line-or-edit
}; zle -N :show-buffer
# Zkeymaps+=('C-x C-l' :show-buffer)

# @desc: UNSURE: create a quick script
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
}; # zle -N :save-alias
# Zkeymaps+=('mode=vicmd Q' :save-alias)

function :call_navi() {
   local -r buff="$BUFFER"
   local -r r="$(printf "$(navi --print </dev/tty)")"
   zle kill-whole-line
   zle -U "${buff}${r}"
}; # zle -N :call_navi

function :navi_next_pos() {
  integer pos=$BUFFER[(ri)\(*\)]-1
  BUFFER=${BUFFER/${BUFFER[(wr)\(*\)]}/}
  CURSOR=$pos
}; # zle -N :navi_next_pos

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
