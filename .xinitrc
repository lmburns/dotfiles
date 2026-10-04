#!/bin/zsh

XLOGDIR="$HOME/.local/state/xlogs/$(date +%F_%H-%M-%S)"
mkdir -p "$XLOGDIR"

exec >> "$XLOGDIR/xinit.log" 2>&1

#  ╭──────────────────────╮
#  │ Kill hanging process │
#  ╰──────────────────────╯
# bustd &

# earlyoom \
#     -n \
#     --avoid '(^|/)(init|systemd|Xorg|sshd|brave|librewolf)$' \
#     --prefer '^(lua-language-se|rust-analyzer|nvim)$' &

#     -r 10 \

systembus-notify &

#  ╔══════════════════════════════════════════════════════════╗
#  ║                         Applets                          ║
#  ╚══════════════════════════════════════════════════════════╝

#  ╭─────────────────╮
#  │ Network manager │
#  ╰─────────────────╯
nm-applet &

#  ╭───────────────────╮
#  │ Bluetooth manager │
#  ╰───────────────────╯
blueman-applet &

#  ╭────────────────╮
#  │ Auto-mount USB │
#  ╰────────────────╯
# udiskie -A -n -s --appindicator --file-manager="$TERMINAL" &
udiskie --tray -n --file-manager="$TERMINAL" &

#  ╭───────────────────╮
#  │ Reverse scrolling │
#  ╰───────────────────╯
# xinput set-prop 21 314 1
# gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

#  ╭──────╮
#  │ Font │
#  ╰──────╯
# xset +fp ~/.local/share/fonts
# xset fp rehash
# fc-cache -fv &

#  ╭────────╮
#  │ Cursor │
#  ╰────────╯
# xsetroot -cursor_name left_ptr &
# xsetroot -xcf ~/.icons/Capitaine-Cursors-Gruvbox-White/cursors/left_ptr 32

#  ╭───────────╮
#  │ Resources │
#  ╰───────────╯
# xrdb -merge ~/.Xresources &
xrdb -I $HOME -merge ${HOME}/.Xresources

#  ╭──────────╮
#  │ Keyboard │
#  ╰──────────╯
xmodmap ~/.Xmodmap 2>&1 | ts '[%F %T]' >> "$XLOGDIR/xmodmap.log"
# xmodmap ~/.Xmodmap

#  ╭───────────────────────╮
#  │ Screensaver & display │
#  ╰───────────────────────╯
xrandr --dpi 96
xset s on
xset s 900 180
# xset dpms 0 0 0
# xset s 1200
# xset r rate 300 50 &

#  ╭──────────────────╮
#  │ Auto lock screen │
#  ╰──────────────────╯
# xscreensaver &
# xss-lock slock &
# xss-lock -- xscreensaver-command -lock &
# xss-lock -n /usr/share/doc/xss-lock/dim-screen.sh -- screenlock &

#  ╭───────────╮
#  │ xidlehook │
#  ╰───────────╯
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
        'xset dpms force off; pidof i3lock || screenlock' '' \
    --socket "/tmp/xidlehook.sock" 2>&1 | ts '[%F %T]' >> "$XLOGDIR/xidlehook.log" &

#  ╭──────────╮
#  │ Redshift │
#  ╰──────────╯
# NOTE: now used as a systemd service
# redshift -c "$HOME/.config/redshift/redshift.conf" &
# redshift-gtk &

#  ╭────────────╮
#  │ Compositor │
#  ╰────────────╯
# picom-rounded -b --experimental-backends &
# /usr/bin/picom -b 2>&1 | ts '[%F %T]' >> "$XLOGDIR/picom.log" &
/usr/bin/picom -b &

# use x11 compositor (transparent windows, blur background, ...) if not inside a VM
# if ! grep -q "^flags.* hypervisor" /proc/cpuinfo ; then
#     if ! pgrep picom; then
#         picom -b --experimental-backends --vsync || picom -b --experimental-backends
#     fi
# fi

#  ╭────────────╮
#  │ Screenshot │
#  ╰────────────╯
# flashfocus &

#  ╭─────────────────╮
#  │ Numlock enabled │
#  ╰─────────────────╯
numlockx on

#  ╭────────────╮
#  │ Hide mouse │
#  ╰────────────╯
xbanish &

#  ╭───────────╮
#  │ Clipboard │
#  ╰───────────╯
# greenclip daemon &
# setsid -f greenclip daemon > /dev/null 2>&1 &!

#  ╭─────────────────────────╮
#  │ Sync copy/paste buffers │
#  ╰─────────────────────────╯
# autocutsel -fork &
# autocutsel -selection CLIPBOARD -fork &

#  ╭───────╮
#  │ Music │
#  ╰───────╯
# spotifyd &
mpd &
mpd-mpris &

#  ╭─────────╮
#  │ Torrent │
#  ╰─────────╯
# transmission-daemon &
# transmission-rss -f &

#  ╭─────────────╮
#  │ Task daemon │
#  ╰─────────────╯
pueued -dc "$XDG_CONFIG_HOME/pueue/pueue.yml" &

#  ╭───────────╮
#  │ Wallpaper │
#  ╰───────────╯
# nitrogen --restore
# hsetroot -cover ${${(@f)"$(fd --search-path ~/Pictures -e jpg | shuf)"}[1]} &
hsetroot -cover ~/Pictures/wallpapers/LakeSideDark.jpg

#  ╭────────────╮
#  │ Screenshot │
#  ╰────────────╯
# flameshot &

#  ╭───────────────╮
#  │ Input handler │
#  ╰───────────────╯
# fcitx -d &

#  ╭───────────────╮
#  │ Notifications │
#  ╰───────────────╯
# dunst 2>&1 | ts '[%F %T]' >> "$XLOGDIR/dunst.log" &
dunst &

#  ╭─────────────╮
#  │ Keybindings │
#  ╰─────────────╯
# sxhkd 2>&1 | ts '[%F %T]' >> "$XLOGDIR/sxhkd.log" &
sxhkd &

# To be able to use gnome-keyring
f="/etc/X11/xinit/xinitrc.d/50-systemd-user.sh"; [[ -f "$f" ]] && source "$f"
# systemctl --user import-environment DISPLAY XAUTHORITY
# dbus-update-activation-environment  DISPLAY XAUTHORITY

#  ╭──────────────╮
#  │ File manager │
#  ╰──────────────╯
# thunar --daemon &

# ! pidof -s pulseaudio >/dev/null 2>&1 &&
# setsid -f pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1

# MANAGER="xfce"
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

exec bspwm 2>&1 | ts '[%F %T]' >> "$XLOGDIR/bspwm.log"
