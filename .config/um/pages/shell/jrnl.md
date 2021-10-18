# jrnl --
{:data-section="shell"}
{:data-date="June 15, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
CLI journal

## EXAMPLES

`jrnl yesterday: Called in sick. Used the time to clean, and spent...`
: on cli

`jrnl today at 3am: I just met Steve`
: on cli

`jrnl < my_entry.txt`
: from file

### TIME FORMAT

* `at 6am`
* `yesterday`
* `last monday`
* `sunday at noon`
* `1 march 2012`
* `6 apr`
* `3/20/1998 at 23:42`
* `4-05-22T15:55-04:00`


`@tag`
: tag inline

`jrnl last sunday *: Best day of my life.`
: star an entry

## VIEWING AND SEARCHING

`jrnl -to today`
: until today

`jrnl -n 10`
: 10 most recent

`jrnl -from "last year" -to march`
: filter

`jrnl -contains "dogs" --edit`
: text search

`jrnl @pinkie @WorldDomination`
: filter by tag

`jrnl -n 5 @pinkie -and @WorldDomination`
: display all entries which have either or tag

`jrnl @pinkie @WorldDomination`
: display if both

`jrnl -starred`
: view starred

## EDITING ENTRIES

`jrnl -to 1950 @texas -and @history --edit`
: open editor display all entries tagged written before 1950

`jrnl work -n 1 --edit`
: multiple journals (work)

## DELETE ENTRIES

`jrnl -to 2004 @book --delete`
: filter delete

`jrnl -to 2004 @book --edit`
: open in editor

## LIST ENTRIES

`jrnl --list`

## ENCRYPTION

`jrnl --encrypt [FILENAME]`
: already existing

`jrnl --decrypt [FILENAME]`
: already existing

## FORMATS

`jrnl --format pretty, jrnl -1 # any search`
: default fmt

`jrnl --format short, jrnl --short`
: short

`jrnl --format fancy, jrnl --format boxed`
: boxed

`jrnl --format json`
: json

`$ j -3 --format json | jq '.entries[].date'`
: parse

`jrnl --format markdown, jrnl --format md`
: markdown

`jrnl --format text, jrnl --format txt`
: plain

`jrnl --format xml / yaml`
: xml, yaml

`jrnl --format tags, jrnl --tags`
: tag summary

`jrnl --format json --file myjournal.json`
: export 1

`jrnl --format json > myjournal.json`
: export 2

`jrnl --format json --file my_entries/`
: export to dir
