#!/usr/bin/env bash

EMAIL=${1:-${USER}}

# sync
task sync > ~/.task-mail.log 2>&1
if [[ $? -ne 0 ]]; then
    echo "Task syncing failed"
    tail ~/.task-mail.log
    exit 1
fi

# first, overdue tasks
DUE="$(task overdue 2> /dev/null)"
HAS_DUE=$?

if [[ $HAS_DUE -eq 0 ]]; then
    echo "$DUE" | mail -s "[taskd] Currently open tasks" $EMAIL
fi
