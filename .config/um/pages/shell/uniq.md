# uniq --
{:data-section="shell"}
{:data-date="March 24, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
report or omit repeated lines

## OPTIONS

With no arguments it removes duplicated words that are adjacent, so must sort first

`-d`
: show duplicated lines that are next to one another uniquely

`-D`
: returns duplicated lines next to each other, though returns the duplication

`--all-repeated=separate`
: add new line to separte groups (are\nare\n\nbad\nbad)

`-u`
: lines with no adjacent duplicates

`-c`
: prefix count of words

`-cd`
: prefix count on only duplicated

`-i`
: ignore case

`-f1`
: skips uniquely uniq on first column

`-s2`
: skip first two charaters of first column

`-w2`
: consider only first two characters

`-s3 -w2`
: skip first 3 chars, then use next 2
