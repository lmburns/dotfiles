#!/bin/bash

if pidof mpv >/dev/null; then
	POSITION=$(echo '{ "command": ["get_property_string", "time-pos"] }' \
		| socat - /tmp/mpvsocket | jq .data | tr '"' ' ' | cut -d'.' -f 1)
	REMAINING=$(echo '{ "command": ["get_property_string", "time-remaining"] }' \
		| socat - /tmp/mpvsocket | jq .data | tr '"' ' ' | cut -d'.' -f 1)
	METADATA=$(echo '{ "command": ["get_property", "media-title"] }' \
		| socat - /tmp/mpvsocket | cut -b 10-30)

	printf "$METADATA"
	# printf ' | %d:%02d:%02d' $(($POSITION / 3600)) $(($POSITION % 3600 / 60)) $(($POSITION % 60))
	# printf ' - %d:%02d:%02d\n' $(($REMAINING / 3600)) $(($REMAINING % 3600 / 60)) $(($REMAINING % 60))
else
	exit
fi
