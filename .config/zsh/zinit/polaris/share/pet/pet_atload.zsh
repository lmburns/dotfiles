function prev() {
  PREV=$(fc -lrn | head -n1)
  pet new $(print "${(q)PREV}")
}

# Color does not work
function pet-select() {
  BUFFER=$(pet search --color --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle redisplay
}

zle -N pet-select
bindkey '^s' pet-select
