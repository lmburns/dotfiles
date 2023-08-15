# Version 1: Use ripgrep to find files
function Rg() {
  rg --column --line-number --no-heading --color=always --smart-case "$1" |
    fzf --ansi \
      --delimiter : \
      --bind 'ctrl-e:become($EDITOR "$(echo {} | hck -d: -f1)")' \
      --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1}' \
      --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
}

# Version 1: Use skim to find files
function Sk() {
  sk --ansi \
     --prompt '❱ ' \
     --cmd-prompt '❱ ' \
     --interactive \
     --delimiter : \
     --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
     --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1}' \
     --preview-window 'default:right:60%:~1:+{2}+3/2:border-left' \
     --cmd 'rg --column --line-number --no-heading --color=always --smart-case "{}"' \
     --cmd-query "$1"
}

# --skip-to-pattern '[^/]*:'

# Version 2: Use ripgrep to find files (much better)
# Has ability to parse glob and use pcre regex
function RG() { rgu "$@" }

# --preview-window 'nohidden,up,60%,border-bottom,+{2}+3/3,~3'

# Find todo comments
function TODOS() {
  local RG_PREFIX
  local -a selected
  RG_PREFIX="rg --column --hidden --line-number --no-heading --color=always --smart-case \
    '\bFIXME\b|\bFIX\b|\bDISCOVER\b|\bNOTE\b|\bNOTES\b|\bINFO\b|\bOPTIMIZE\b|\bXXX\b|\bEXPLAIN\b|\bTODO\b|\bHACK\b|\bBUG\b|\bBUGS\b'"
  selected=("$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled \
        --delimiter : \
        --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
        --bind='ctrl-y:execute-silent(echo {+} | hck -d: -f1 | xsel -b)' \
        --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1}' \
        --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
  )")
  selected=(${(@s.:.)selected})
  [ -n "${selected[1]}" ] && ${EDITOR} "+${selected[2]}" -- "${selected[1]}"
}

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
