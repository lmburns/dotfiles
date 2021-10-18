#!/usr/bin/env bash

# desc: open buku in w3m

url=$(
  buku -p -f4 \
    | fzf -m --reverse --preview "buku -p {1}" --preview-window=wrap \
    | cut -f2
)

[[ -n "$url" ]] && echo "$url" | xsel -p
