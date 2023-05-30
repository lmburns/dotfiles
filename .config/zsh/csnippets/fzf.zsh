# ALT-E - Edit selected file
function fzf-file-edit-widget() {
  setopt localoptions pipefail
  local files
  files=$(eval "$FZF_ALT_E_COMMAND" |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_E_OPTS" fzf -m |
      sed 's/^\s\+.\s//')
  local ret=$?

  [[ $ret -eq 0 ]] && echo $files | xargs sh -c "$EDITOR \$@ </dev/tty" $EDITOR

  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N    fzf-file-edit-widget


function fe() {
  local -a sel
  sel=("$(
    command fd -Hi -tf ${1:+-d${1}} --strip-cwd-prefix --color=always | \
      fzf \
        --ansi \
        --multi \
        --select-1 \
        --exit-0 \
        --bind=ctrl-x:toggle-sort \
        --preview-window=':nohidden,right:65%:wrap' \
        --preview='([[ -f {} ]] && (bat --style=numbers --color=always {})) || ([[ -d {} ]] && (exa -TL 3 --color=always --icons {} | less)) || echo {} 2> /dev/null | head -200'
    )"
  )
  [[ -n "$sel" ]] && ${EDITOR:-vim} "${sel[@]}"
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}
zle -N fe


# Desc: Use FZF and histdb
function fzf-histdb-widget() {
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
zle -N fzf-histdb-widget

  # local REPO
  # REPO=$(ghq list -p | xargs ls -dt1 | sed -e 's;'${GHQ_ROOT}/';;g' | $(__fzfcmd) +m --prompt 'GHQ> ' --height 40% --reverse --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  # if [ -n "${REPO}" ]; then
  #   cd ${GHQ_ROOT}/${REPO}
  # fi


function fzf-ghq() {
  local repo
  repo=$(\
    command ghq list -p \
      | xargs ls -dt1 \
      | lscolors \
      | fzf --ansi \
            --no-multi \
            --prompt='GHQ> ' \
            --reverse \
            --height 50% \
            --preview="\
            bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*" \
            --preview-window="right:50%" \
            --delimiter / \
            --with-nth 5..
  )
  # f={}; bkt -- exa -T --color=always -L3 -- $(sed "s#.*→  ##" <<<"$f")' \
  [[ -d "$repo" ]] && builtin cd "$repo"
}


function fzf-ghq-widget() {
  local repo
  repo=$(\
    command ghq list -p \
      | xargs ls -dt1 \
      | lscolors \
      | fzf --ansi \
            --no-multi \
            --prompt='GHQ> ' \
            --reverse \
            --height 50% \
            --preview="\
            bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*" \
            --preview-window="right:50%" \
            --delimiter / \
            --with-nth 5..
  )
  [[ -d "$repo" ]] && {
    BUFFER="cd $repo"
  }
  zle accept-line
}
zle -N fzf-ghq-widget


function fg-fzf() {
  job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job;
}


function fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER=" fg-fzf"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z

# vim:ft=zsh:et
