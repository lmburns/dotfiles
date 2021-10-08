function cd-fzf-ghqlist() {
  local REPO
  REPO=$(ghq list -p | xargs ls -dt1 | sed -e 's;'${GHQ_ROOT}/';;g' | $(__fzfcmd) +m --prompt 'GHQ> ' --height 40% --reverse --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "${REPO}" ]; then
    cd ${GHQ_ROOT}/${REPO}
  fi
}

function cd-fzf-ghqlist-widget() {
  local REPO
  REPO=$(ghq list -p | xargs ls -dt1 | sed -e 's;'${GHQ_ROOT}/';;g' | $(__fzfcmd) +m --prompt 'GHQ> ' --height 40% --reverse --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "${REPO}" ]; then
    BUFFER="cd ${GHQ_ROOT}/${REPO}"
  fi
  zle accept-line
}

alias ghq-repos="ghq list -p | fzf --prompt 'GHQ> ' --height 40% --reverse"
alias ghq-repo='cd $(ghq-repos)'

zle -N cd-fzf-ghqlist-widget

alias ghqcd=cd-fzf-ghqlist
