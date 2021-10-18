# pr --
{:data-section="shell"}
{:data-date="March 23, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS

Convert text files for printing.

## OPTIONS

`pr`
: paginate and add header

`-3`
: three columns

`-l1`
: order lines across columns

`-t`
: omit headers and trailers

`-s`
: multi-char output delimiter

`pr -2ts, == paste -d, - -`
: equivalant

`-3t`
: page width = 72, so 72 / 3 if no `-s` is given

`-3ts`
: 3 columns, tab separated

`-3ts' '`
: space separated

`-3ts' : '`
: can use spaces in between as well

`-a`
: converts columns to rows

`-J -w73`
: changes page width to 73. `-J` turns off truncation, `-w` changes width

`-m`
: combined multiple files

`-mts$'\n'`, `-mts$'\t\t'`
: shell expands, newline interleaves lines

`tr ' ' '\n' < file | pr -$(wc -l < file)t`
: transpose a table
