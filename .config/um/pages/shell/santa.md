# santa --
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Block apps

## OPTIONS

[https://santa.readthedocs.io/en/latest/](document)

`/var/log/santa.log`
: view log

`santctl fileinfo`
: show file info

`sudo defaults write /var/db/santa/config.plist ClientMode -int 2`
: only allow whitelisted apps / enable lockdown

`sudo defaults delete /var/db/santa/config.plist ClientMode`
: disable lockdown

`sudo santactl rule --whitelist --sha256 4e11da26feb48231d6e90b10c169b0f8ae1080f36c168ffe53b1616f7505baed`
: whitelist apps

`sudo santactl rule --whitelist --certificate --sha256 15b8ce88e10f04c88a5542234fbdfc1487e9c2f64058a05027c7c34fc4201153`
: whitelist a certificate

`sudo santactl rule --blacklist --path /System/Applications/Image\ Capture.app`
: blacklist app on path
