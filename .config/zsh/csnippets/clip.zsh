function detect-clip() {
  emulate -L zsh
  function ccopy() { xsel -bi --trim < "${1:-/dev/stdin}"; }
  function cpaste() { xsel -b; }
}

detect-clip || true

# vim:ft=zsh:
