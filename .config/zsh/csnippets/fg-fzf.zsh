# function fzf-fg() {
#     local jobId=$(jobs -l | fzf --exact --exit-0 --select-1 --height=6 | sed "s/^\[\(.*\)\].*$/\1/g")
#     # continue only when a jobId selected
#     [ $jobId ] && fg %$jobId
# }

fg-fzf() { job="$(jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && echo '' && fg %$job; }

fancy-ctrl-z() {
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
