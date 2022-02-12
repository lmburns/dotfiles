# Other random functions

function expand-aliases() {
  unset 'functions[_expand-aliases]'
  functions[_expand-aliases]=$BUFFER
  (($+functions[_expand-aliases])) &&
    BUFFER=${functions[_expand-aliases]#$'\t'} &&
    CURSOR=$#BUFFER
}

function minenv() {
  cd "$(mktemp -d)"
  ZDOTDIR=$PWD HOME=$PWD zsh -df
}
