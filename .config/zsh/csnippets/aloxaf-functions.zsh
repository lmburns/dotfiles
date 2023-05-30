function execute-command() {
  zmodload -Fa zsh/zleparameter p:widgets
  local selected=$(printf "%s\n" ${(k)widgets} \
    | ftb-tmux-popup --reverse --prompt="cmd> " --height=10 --border=none)
  zle redisplay
  [[ $selected ]] && zle $selected
}
zle -N execute-command

function fz-find() {
  local selected dir cut
  cut=$(grep -oP '[^* ]+(?=\*{1,2}$)' <<< $BUFFER)
  eval "dir=${cut:-.}"
  if [[ $BUFFER == *"**"* ]] {
    selected=$(fd -H . $dir \
      | ftb-tmux-popup --tiebreak=end,length --prompt="cd> " --border=none)
  } elif [[ $BUFFER == *"*"* ]] {
    selected=$(fd -d 1 . $dir \
      | ftb-tmux-popup --tiebreak=end --prompt="cd> " --border=none)
  }
  BUFFER=${BUFFER/%'*'*/}
  BUFFER=${BUFFER/%$cut/$selected}
  zle end-of-line
}
zle -N fz-find


autoload -U edit-command-line
function edit-command-line-as-zsh {
  TMPSUFFIX=.zsh
  edit-command-line
  unset TMPSUFFIX
}
zle -N edit-command-line-as-zsh

##################
function _call_navi() {
   local -r buff="$BUFFER"
   local -r r="$(printf "$(navi --print </dev/tty)")"
   zle kill-whole-line
   zle -U "${buff}${r}"
}

function _navi_next_pos() {
    local -i pos=$BUFFER[(ri)\(*\)]-1
    BUFFER=${BUFFER/${BUFFER[(wr)\(*\)]}/}
    CURSOR=$pos
}

zle -N _call_navi
zle -N _navi_next_pos

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
