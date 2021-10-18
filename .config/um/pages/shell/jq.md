# jq -- json processor
{:data-section="shell"}
{:data-date="April 01, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Process json files

## EXAMPLES

`jq '.'`
: format file piped into it

`echo '{"economists": [{"id": 1, "name": "menger"}, {"id": 2, "name": "mises"}, {"name": "hayek", "id": 3}]}' | jiq`
: example

Now try writing `.economists | "\(.[0].name), \(.[1].name) and \(.[2].name) are economists."` or `[.economists.[].id], or even .economists | map({key: "\(.id)", value: .name}) | from_entries`
