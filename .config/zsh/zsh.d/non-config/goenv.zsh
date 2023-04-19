export GOENV_SHELL=zsh
export GOENV_ROOT=/home/lucas/.config/zsh/zinit/polaris/libexec/goenv
if [ "${PATH#*$GOENV_ROOT/shims}" = "${PATH}" ]; then
  export PATH="$PATH:$GOENV_ROOT/shims"
fi

# TODO: Until I write completions for this it will be disabled
# source '/home/lucas/.config/zsh/zinit/polaris/libexec/goenv/completions/goenv.zsh'

command goenv rehash 2>/dev/null
goenv() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval "$(goenv "sh-$command" "$@")";;
  *)
    command goenv "$command" "$@";;
  esac
}
goenv rehash --only-manage-paths
