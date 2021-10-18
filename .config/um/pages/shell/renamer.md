# renamer --
{:data-section="shell"}
{:data-date="June 05, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Rust rename files

## OPTIONS

`$ renamer --verbose '(?P<index>\d{2}\.) (.*)\.(?P<ext>)=${index} Lady Gaga - $2.$ext' *.mp3`
: move parts of files

`$ renamer '^=2020-07-18 ' img*`
: Add a prefix

`$ renamer '$=.bak' file1 file2`
: Add an extension

`$ renamer 'JPEG$=jpg' *.JPEG`
: Change extension

`$ renamer 'JPEG$=jpg' -e '^some_prefix_=' *`
: Multiple patterns. Change extension and remove a prefix.

`$ renamer -v '^=_' --prefix-increment 0201 Westworld01.mkv Westworld.S02E02.mkv Westworld_3.mkv`
: add digits to flatten dir
