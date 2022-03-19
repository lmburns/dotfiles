function execute-command() {
  zmodload -Fa zsh/zleparameter p:widgets
  local selected=$(printf "%s\n" ${(k)widgets} \
    | ftb-tmux-popup --reverse --prompt="cmd> " --height=10 --border=none)
  zle redisplay
  [[ $selected ]] && zle $selected
}
zle -N execute-command


function fz-history-widget() {
  local query="
SELECT commands.argv
FROM   history
  LEFT JOIN commands
    ON history.command_id = commands.rowid
  LEFT JOIN places
    ON history.place_id = places.rowid
GROUP BY commands.argv
ORDER BY places.dir != '${PWD//'/''}',
    commands.argv LIKE '${BUFFER//'/''}%' DESC,
    Count(*) DESC
"
  local selected=$(_histdb_query "$query" | ftb-tmux-popup -n "2.." --tiebreak=index --prompt="cmd> " ${BUFFER:+-q$BUFFER})

  # local selected=$(fc -rl 1 | ftb-tmux-popup -n "2.." --tiebreak=index --prompt="cmd> " ${BUFFER:+-q$BUFFER})
  # if [[ "$selected" != "" ]] {
  #   zle vi-fetch-history -n $selected
  # }

  BUFFER=${selected}
  CURSOR=${#BUFFER}
}
zle -N fz-history-widget

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
_call_navi() {
   local -r buff="$BUFFER"
   local -r r="$(printf "$(navi --print </dev/tty)")"
   zle kill-whole-line
   zle -U "${buff}${r}"
}

_navi_next_pos() {
    local -i pos=$BUFFER[(ri)\(*\)]-1
    BUFFER=${BUFFER/${BUFFER[(wr)\(*\)]}/}
    CURSOR=$pos
}

zle -N _call_navi
zle -N _navi_next_pos

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
