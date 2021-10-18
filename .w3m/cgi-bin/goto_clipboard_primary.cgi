#!/usr/bin/env sh

# printf "%s\r\n" "W3m-control: GOTO $(pbpaste)";
# printf "W3m-control: DELETE_PREVBUF\r\n"

printf "%s\n%s" "Content-Type: text/plain" "W3m-control: GOTO https://google.com"
