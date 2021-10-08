# desc: nvim like fzf function (similar to bash rgf)

function Rg() {
  rg --column --line-number --no-heading --color=always --smart-case "$1" |
    fzf --ansi \
      --delimiter : \
      --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
      --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} {1}' \
      --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
}

function Sk() {
  sk --ansi \
     --interactive \
     --delimiter : \
     --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
     --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} {1}' \
     --preview-window 'default:right:60%:~1:+{2}+3/2:border-left' \
     --cmd 'rg --column --line-number --no-heading --color=always --smart-case "{}"' \
     --cmd-query "$1"
}

# --skip-to-pattern '[^/]*:'

function RG() {
  local RG_PREFIX INITIAL_QUERY
  local -a selected
  RG_PREFIX="rg --column --hidden --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  selected=("$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY' || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --delimiter : \
        --bind 'ctrl-e:execute($EDITOR "$(echo {} | hck -d: -f1)" >/dev/tty </dev/tty)' \
        --bind='ctrl-y:execute-silent(echo {+} | hck -d: -f1 | pbcopy)' \
        --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} {1}' \
        --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
  )")
  selected=(${(@s.:.)selected})
  [ -n "${selected[1]}" ] && ${EDITOR} "${selected[1]}" "+${selected[2]}"
}

    # --preview-window 'nohidden,up,60%,border-bottom,+{2}+3/3,~3'

# vim: ft=zsh:et:sw=0:ts=2:sts=2:
