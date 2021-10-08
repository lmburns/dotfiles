[[ -f $HOME/.config/zsh/.zshrc ]] && source $HOME/.config/zsh/.zshrc

if [[ "$(tty)" = "/dev/tty1" ]]; then
  pgrep bspwm || startx "$HOME/.xinitrc"
fi
