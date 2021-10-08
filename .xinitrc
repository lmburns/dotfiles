#!/bin/zsh

# https://superuser.com/questions/96299/mapping-superhjkl-to-arrow-keys-under-x

# if [ -d /etc/X11/xinit/xinitrc.d ]; then
#   for f in /etc/X11/xinit/xinitrc.d/*; do
#     [ -x "$f" ] && . "$f"
#   done
#   unset f
# fi

# setbg &     # set the background with the `setbg` script
# xcompmgr &    # xcompmgr for transparency

# Network manager
nm-applet &

# Bluetooth manager
blueman-applet &

# Pulseaudio applet
pasystray &

# Auto mount USB
udiskie --tray & #

clipit &
# clipmenud &

# Auto lock screen
xss-lock slock &
xscreensaver &
numlockx &

# eval "$(ssh-agent)"

mpd &
transmission-daemon &
transmission-rss -f &

# xrdb ~/.Xresources &

# Night mode
redshift -l 38.95:-92.32 &

# Compositor
picom -b --experimental-backends &

# Sync copy paste buffers
autocutsel -fork &
autocutsel -selection CLIPBOARD -fork &

# Wallpaper
# nitrogen --restore
hsetroot -cover ${${(@f)"$(fd --search-path ~/Pictures -e jpg | shuf)"}[1]} &

# Screenshot
flameshot &
# Input handler
fcitx -d &
# Notifications
dunst &
# Hide mouse
xbanish &
# Keybindings
sxhkd &
xsetroot -cursor_name left_ptr &
xrdb -merge ~/.Xresources &
xmodmap ~/.Xmodmap &

# thunar --daemon &

# xset r rate 300 50 &

# ! pidof -s pulseaudio >/dev/null 2>&1 &&
# setsid -f pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1

# MANAGER="xfce"
#
# case "${MANAGER}" in
#   plasma)
#     export DESKTOP_SESSION=plasma
#     exec startplasma-x11
#     ;;
#   bspwm)
    exec bspwm
#     ;;
#   bswpm-plasma)
#     export DESKTOP_SESSION=plasma
#     exec KDEWM=/usr/bin/bspwm /usr/bin/startplasma-x11
#     ;;
#   xfce)
    # exec startxfce4
#     ;;
# esac
