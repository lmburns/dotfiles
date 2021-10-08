if [[ "$(tty)" = "/dev/tty1" ]]; then
  pgrep bspwm || startx "$HOME/.xinitrc"
fi
