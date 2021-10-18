#!/usr/bin/env bash

task sync

task status:pending tags.hasnt:notified due.before:now+8h export |
jq -r -c ".[]" |
while IFS= read -r object; do
    uuid=$(echo "$object" | jq -r '.uuid')
    description=$(echo "$object" | jq -r '.description')
    due=$(echo "$object" | jq -r '.due')
    human_due="$(date -d "$(echo $due | sed -r 's/(.*)T(..)(..)(..)/\1 \2:\3:\4/')")"
    echo -e "Due task\n\n$description\n\nat: $human_due\nuuid: $uuid" \
        | mail -a 'Content-Type: text/plain; charset=UTF-8' -s "Due task $description" -r burnsac@me.com --
    task rc.recurrence.confirmation=no "$uuid" # modify +notified
done

task sync
