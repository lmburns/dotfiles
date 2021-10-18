# rates --
{:data-section="shell"}
{:data-date="May 03, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Get crypto

## EXAMPLES

`https://github.com/chubin/rate.sx`
: website

`$ curl rate.sx/:help`
: help

`$ curl rate.sx/eth@30d`
: Ethereum to USD rate for the last 30 days

`$ curl eur.rate.sx/btc@february`
: How Bitcoin (BTC) price in EUR changed in February

`$ curl xlm.rate.sx/xrp@01-Feb-2018..`
: Is it true that 1 XRP (Ripple) costs 3 XLM (Stellar) since Feb 1?

`n=NUMBER`
: number of cryptocurrencies to show (10 by default)

`$ curl btc.rate.sx/?n=30`
: usage of `n`

`@=interval`
: get the interval

`s`
: Second

`m`
: Minute

`h`
: Hour

`d`
: Day (24 hours)

`w`
: Week

`M`
: Month (30 days)

`y`
: Year (365 days)

`$ curl rate.sx/eth@4d`
: last 4 days
