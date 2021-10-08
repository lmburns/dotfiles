#!/usr/bin/env zsh

loginfo()  { printf "%b[info]%b %s\n"  '\e[0;32m\033[1m' '\e[0m' "$@" >&2; }
logwarn()  { printf "%b[warn]%b %s\n"  '\e[0;33m\033[1m' '\e[0m' "$@" >&2; }
logerror() { printf "%b[error]%b %s\n" '\e[0;31m\033[1m' '\e[0m' "$@" >&2; }

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

command mkdir -pv "${HOME}/.config/zsh"
export ZDOTDIR="${HOME}/.config/zsh"

command cp -f "${0:h}/.zshrc" "$ZDOTDIR/.zshrc"
command cp -f "${0:h}/lficons" "$ZDOTDIR/lficons"
command cp -f "${0:h}/zsh-aliases" "$ZDOTDIR/zsh-aliases"
command cp -f "../../.zshenv" "$HOME/.zshenv"

# could symlink insteaad

(){
  command mkdir -p "${ZDOTDIR}/patches"
  cd -q ${0:h}/patches &&
    for p (*) { command cp -f $p "${ZDOTDIR}/patches/${p}"; }
  loginfo "Patches finished"

  command mkdir -p "${ZDOTDIR}/functions"
  cd -q ${0:h}/functions &&
    for f (*) { command cp -f $f "${ZDOTDIR}/functions/${f}"; }
  loginfo "Functions finished"

  command mkdir -p "${ZDOTDIR}/themes"
  cd -q ${0:h}/themes &&
    for t (*) { command cp -f $t "${ZDOTDIR}/themes/${t}"; }
  loginfo "Themes finished"

  command mkdir -p "${ZDOTDIR}/completions"
  cd -q ${0:h}/completions &&
    for c (*) { command cp -f $t "${ZDOTDIR}/completions/${t}"; }
  loginfo "Completions finished"
}

[[ "$SHELL" =~ "zsh" ]] || chsh -s "$(command -v zsh)"
