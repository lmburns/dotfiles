#!/bin/sh

tmp_file="/tmp/qr.png"

sel=$(slop -f "-i %i -g %g")
shotgun $sel "-" > "$tmp_file"

scanresult=$(zbarimg --quiet --raw "$tmp_file" | tr -d '\n')

if [ -z "$scanresult" ]; then
    notify-send "Maim" "No scan data found"
else
    echo "$scanresult" | xclip -selection c
    convert $tmp_file -resize 75x75 "$tmp_file"
    notify-send -i "$tmp_file" "Maim" "$scanresult\n(copied to clipboard)"
fi
