#!/bin/zsh

# Network manager
nm-applet &

# Bluetooth manager
blueman-applet &

# Pulseaudio applet
pasystray &

# Auto mount USB
udiskie --tray & #

# clipit &
# greenclip daemon &
copyq &
ulauncher --hide-window &

xset s on
xset s 900 180
# xset dpms 0 0 0
# xset s 1200

# numlockx &

# Auto lock screen
# xscreensaver &
# xss-lock slock &
# xss-lock -- xscreensaver-command -lock &
# xss-lock -n /usr/share/doc/xss-lock/dim-screen.sh -- screenlock &

# 'xrandr --output "DP-1" --brightness .1' \
# 'xrandr --output "DP-1" --brightness 1' \

# shifts back and forth
    # --timer 120 \
    #     'redshift -b 0.1:0.1' \
    #     'redshift -b 1.0:1.0' \

xidlehook \
    --not-when-fullscreen \
    --not-when-audio \
    --timer 500 \
        'screensaver' '' \
    --timer 240 \
        'xset dpms force off; \
        if [ ! $(pidof i3lock) ]; then screenlock; fi' '' \
    --socket "/tmp/xidlehook.sock" &

# flashfocus &
mpd &
transmission-daemon &
transmission-rss -f &

# xrdb ~/.Xresources &

# Night mode
redshift -c "$HOME/.config/redshift/redshift.conf" &
# redshift -l 38.95:-92.32 &
# redshift-gtk &

# Compositor
# picom -b --experimental-backends &
picom-rounded -b --experimental-backends &

# Sync copy paste buffers
# autocutsel -fork &
# autocutsel -selection CLIPBOARD -fork &

# Wallpaper
# nitrogen --restore
# hsetroot -cover ${${(@f)"$(fd --search-path ~/Pictures -e jpg | shuf)"}[1]} &
hsetroot -cover ~/Pictures/wallpapers/LakeSideDark.jpg &

# Task daemon
pueued -dc "$XDG_CONFIG_HOME/pueue/pueue.yml" &

# Screenshot
flameshot &
# Input handler
# fcitx -d &

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
#     exec bspwm
#     ;;
#   bswpm-plasma)
#     export DESKTOP_SESSION=plasma
#     exec KDEWM=/usr/bin/bspwm /usr/bin/startplasma-x11
#     ;;
#   xfce)
#     exec startxfce4
#     ;;
# esac

exec bspwm