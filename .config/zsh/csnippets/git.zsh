compdef _rg nrg
function nrg() {
  if (( $* )); then
     nvim +'pa nvim-treesitter' \
          +"Grepper -noprompt -dir cwd -grepprg rg $* --max-columns=200 -H --no-heading --vimgrep -C0 --color=never"
  else
     rg
  fi
}

function ng() {
  git rev-parse >/dev/null 2>&1 && nvim +"lua require('plugs.fugitive').index()"
}

compdef __ngl_compdef ngl
function ngl() {
  git rev-parse >/dev/null 2>&1 && nvim +"Flog -raw-args=${*:+${(q)*}}" +'bw 1'
}
__ngl_compdef() {
  (( $+functions[_git-log] )) || _git
  _git-log
}
