#!/usr/bin/env bash

selected=$(SYSTEMD_COLORS=0 \
    systemctl \
        list-unit-files \
            --no-pager \
            --type=service \
            --no-legend \
                | dmenu \
                | awk '{print $1}'
)

selected=$(echo $selected | awk '{print $1}')

action=$(echo -e "start\nstop\nrestart" | dmenu)

case "$action" in
    "start")
        sudo systemctl start $selected
        ;;
    "stop")
        sudo systemctl stop $selected
        ;;
    "restart")
        sudo systemctl restart $selected
        ;;
esac
