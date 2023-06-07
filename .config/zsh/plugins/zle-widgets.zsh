function :expand-aliases() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]=$BUFFER
  (($+functions[_expand-aliases])) &&
    BUFFER=${functions[_expand-aliases]#$'\t'} &&
    CURSOR=$#BUFFER
}; zle -N :expand-aliases

# Execute ZLE command
function :execute-command() {
  zmodload -Fa zsh/zleparameter p:widgets
  local selected=$(printf "%s\n" ${(k)widgets} \
    | ftb-tmux-popup --reverse --prompt="cmd> " --height=10 --border=none)
  zle redisplay
  [[ $selected ]] && zle $selected
}; zle -N :execute-command
# Zkeymaps+=('C-x C-x' :execute-command)

# Desc: translate unicode to symbol
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

# Desc: write date beside command
function :accept-line-rdate() {
  local old=$RPROMPT
  RPROMPT=$(date +%T 2>/dev/null)
  zle reset-prompt
  RPROMPT=$old
  zle accept-line
}; zle -N :accept-line-rdate
Zkeymaps[M-a]=:accept-line-rdate

function :add-bracket() {
  local -A keys=('(' ')' '{' '}' '[' ']')
  BUFFER[$CURSOR+1]=${KEYS[-1]}${BUFFER[$CURSOR+1]}
  BUFFER+=$keys[$KEYS[-1]]
}; zle -N :add-bracket
Zkeymaps[M-\(]=:add-bracket
Zkeymaps[M-\{]=:add-bracket

# Desc: edit command in editor
autoload -U edit-command-line
function :edit-command-line-as-zsh {
  TMPSUFFIX=.zsh
  edit-command-line
  unset TMPSUFFIX
}; zle -N :edit-command-line-as-zsh
Zkeymaps+=('C-x C-e'       :edit-command-line-as-zsh)
Zkeymaps+=('mode=vicmd ;e' :edit-command-line-as-zsh)

function _call_navi() {
   local -r buff="$BUFFER"
   local -r r="$(printf "$(navi --print </dev/tty)")"
   zle kill-whole-line
   zle -U "${buff}${r}"
}; zle -N _call_navi

function _navi_next_pos() {
    local -i pos=$BUFFER[(ri)\(*\)]-1
    BUFFER=${BUFFER/${BUFFER[(wr)\(*\)]}/}
    CURSOR=$pos
}; zle -N _navi_next_pos

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
