#!/usr/bin/env zsh

# This script is used on my Linux machine

# It is used to add a tag that is the same name of the project,
# which syncs to my server with a crontab. My macOS machine all runs
# a crontab, which pulls the added task from the server. Then a `launchctl`
# service is ran that tags the file and syncs it with macOS/iOS reminders

task \
  rc.bulk=0 \
  rc.confirmation=off \
  rc.dependency.confirmation=off \
  rc.recurrence.confirmation=off \
  "$@" \
  modify \
  +"$(task \
        rc.bulk=0 \
        rc.confirmation=off \
        rc.dependency.confirmation=off \
        rc.recurrence.confirmation=off \
        "$@" \
        _projects
  )"
