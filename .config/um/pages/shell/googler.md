# googler --
{:data-section="shell"}
{:data-date="March 24, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Search webpages

## OPTIONS
`googler -n 15 -s 3 -t m14 -w imdb.com jungle book`
: 15 results, updated within 14 months, 3rd result, imbdb site

`googler -n 15 -s 3 --from 04/04/2016 --to 12/31/2016 -w imdb.com jungle book`
: specify date explicitly

`googler -N gadget`
: read news on gadgets

`googler -V PyCon 2020`
: search for videos on pycon

`googler instrumental filetype:mp3`
: search for specific filetype

`googler -x googler`
: disable spell correction

`googler -j leather jackets`
: i'm feeling lucky

`googler -w amazon.com -w ebay.com digital camera`
: website specific

`googler --colors bjdxxy google`
: colorscheme

`googler --proxy localhost:8118 google`
: proxy
