#!/usr/bin/env bash

# Desc: Log dunst messages

crunch_appname=$(echo "$1" | sed  '/^$/d')
crunch_summary=$(echo "$2" | sed  '/^$/d' | xargs)
crunch_body=$(echo "$3" | sed  '/^$/d' | xargs)
crunch_icon=$(echo "$4" | sed  '/^$/d')
crunch_urgency=$(echo "$5" | sed  '/^$/d')
timestamp=$(date +"%I:%M %p")

# if [[ "$crunch_appname" == "Spotify" ]]; then
#     random_name=$(mktemp --suffix ".png")
#     artlink=$(playerctl metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')
#     curl -s "$artlink" -o "$random_name"
#     crunch_icon=$random_name
# elif [[ "$crunch_appname" == "AN2Linux" ]]; then
#     crunch_icon="${XDG_CONFIG_HOME}/dunst/icons/GruvboxIcon.png"
# fi


echo -en "$timestamp\n$crunch_urgency\n$crunch_icon\n$crunch_body\n$crunch_summary\n$crunch_appname\n" >> /tmp/dunstlog
