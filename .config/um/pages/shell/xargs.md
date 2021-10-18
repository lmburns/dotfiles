# xargs --
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## OPTIONS

`-n`
: limit args per line; eg `-n2`

`seq 6 | xargs -n3`
: same as `paste -d' ' - - -'` or `pr -3ats`

`-a`
: specify input file instead of stdin

`-L`
: limit max number of lines per command line; eg `-L2`

`-t`
: verbose
