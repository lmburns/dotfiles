# cut -- remove sections from each line of files
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## OPTIONS

`-f`
: specify field selection

`-f2, -f2,4, -f1-3, -f3-`
: examples

`-s`
: supress lines without delimiter

`-d`
: specify delimiter, can only use one char

`-d:, -d';'`
: examples

`--output-delimiter=`
: specify output delimiter

`--compliment`
: return all but, so `-f1,3` and `--compliment -f2` are equal

`-c`
: character selection, like field selection (`-f`)
