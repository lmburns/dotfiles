# if [[ "$(tty)" = "/dev/tty1" ]]; then
#   pgrep bspwm || startx "$HOME/.xinitrc"
# fi

if [ -z "${DISPLAY}" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec startx
fi
