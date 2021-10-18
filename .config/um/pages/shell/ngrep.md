# ngrep --
{:data-section="shell"}
{:data-date="March 11, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Grep for packets.

## EXAMPLES

`ngrep '' not port 80`

`ngrep -d any port 25`

`ngrep -wi -d any 'user|pass' port 21`

`ngrep port 80` = debug http

`ngrep -W byline port 80` = make it prettier
