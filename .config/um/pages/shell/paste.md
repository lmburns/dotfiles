# paste --
{:data-section="shell"}
{:data-date="March 23, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Concat files column wise

## OPTIONS

`-d`
: delimiter (`-d,`)

`-d ''`
: no separator

`-d'\n'`
: interleave lines

`-d, - -`
: number of `-` determines output cols

`paste -d, $(printf -- "- %.s" {1..5})`
: use printf trick

`-d',-`
: specify more than one column separator

### MULTICHARACTER SEPARATION

`pr -mts' : ' <(seq 3) <(seq 4 6)`
: 1 \: 2 \: 3

`-d' : ' <(seq 3) /dev/null /dev/null <(seq 4 6)`

`paste -d' :  - ' <(seq 3) /dev/null /dev/null <(seq 4 6)...`
: 1 \: 4 - 7; FOR MORE THAN ONE TYPE OF CHAR

`pr -mts' : ' <(seq 3) <(seq 4 6) | pr -mts' - ' - <(seq 7 9)`
: same as above

`-d ': -' <(seq 3) e e <(seq 4 6)...`
: same as /dev/null; CAN USE EMPTY FILE / NON EXISTENT INSTEAD

### MULTIPLE LINES AS SINGLE ROW

`-sd,`
: turns into one row

`-sd, <(seq 3) <(seq 5 9)`
: don't need same number of lines
