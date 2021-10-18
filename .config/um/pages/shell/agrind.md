# agrind --
{:data-section="shell"}
{:data-date="July 17, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Parse log files

## OPTIONS

`("ERROR" OR WARN*) AND NOT staging | count`
: combined with *AND*, *OR*, *NOT*

## QUERY SYNTAX

* `sum`
* `percentile`
* `average`

## FILTERS

* `*` = all logs
* `filter-me*` = case-insensitive
* `"filter-me"`, `"filter me!"` = case-sensitive

* `AND`, `OR`, `NOT`


## OPERATORS

### JSON

`* | parse "INFO *" as js | json from js`
: example

`* | json`
: example

`{"key": "blah", "nested_key": {"this": "that"}}`
: input

`* | json | count_distinct(nested_key.this)`
: usage


### LOGFMT

`* | logfmt`
: example

### SPLIT
