# ffsend --
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Firefox send

## OPTIONS

`ffsend u -h https://example.com/ my-file.txt`
: upload to own host

`ffsend upload --downloads 1 --expiry-time 5m --password --archive --copy --open my-file.txt`
: complex upload

`ffsend exists https://send.firefox.com/#sample-share-url`
: check if file exists

`ffsend info https://send.firefox.com/#sample-share-url`
: fetch remote file info

`ffsend history`
: check history

`ffsend password https://send.firefox.com/#sample-share-url`
: change password after upload

`ffsend delete <url>`
: delete file
