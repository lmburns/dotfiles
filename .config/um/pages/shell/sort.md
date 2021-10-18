# sort --
{:data-section="shell"}
{:data-date="March 22, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS

Sort data

## OPTIONS

`default`
: sorts alphabetically

`-f`
: ignore case

`-r`
: reverse sort

`-n`
: sort numerically (can handle negative)

`-g`
: if number prefixed by + or in scientific notation

`-h`
: human readable (file sizes)

`-V`
: mixed of letters and numbers (foo_v1.2)

`-R`
: random - duplicate lines are by each other (use **shuf** instead)

`-u`
: unique sort

`-nu`
: removes even if line e.g., (12 carrots 12 bananas)

-o output
: specify output

## KEY SORTING

Default = space and tab

sort -k2,2n fruits.txt
: sort on second column numbers

sort -t: -k2,4 pets.txt
: would mean second column to fourth column

sort -t: -k2,2 pets.txt
: sort from second column to second column

sort -t: -k2 pets.txt
: sort on separator ':' from 2nd column to end of line (3 columns)

sort -t: -k2,2 -k3,3n pets.txt
: default sort for 2nd col, numeric sort on 3rd col to resolve ties

sort -s -t: -k2,2 pets.txt
: use `-s` to retain og order of lines in case of tie

-u -k1.1,1.2
: sort uniqely based on first two characters of line
