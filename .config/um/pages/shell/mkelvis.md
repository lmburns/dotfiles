# mkelvis --
{:data-section="shell"}
{:data-date="June 07, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Create elvi for surfraw

## OPTIONS

`mkelvis yourelvisname example.com 'example.com/search?q='`
: these two are equivalent: https is the default url scheme

`mkelvis yourelvisname https://example.com 'https://example.com/search?q='`
: these two are equivalent: https is the default url scheme

`mkelvis yourelvisname --insecure example.com 'example.com/search?q='`
: use http for insecure websites

`mkelvis yourelvisname http://example.com 'http://example.com/search?q='`
: use http for insecure websites

`mkelvis yourelvisname --description='Search Example for bliks' https://example.com 'https://example.com/search?q='`
: with a description

`mkelvis yourelvisname --num-tabs=NUM https://example.com 'https://example.com/search?q='`
: to align in `sr-elvi`
