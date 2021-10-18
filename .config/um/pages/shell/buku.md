# buku --
{:data-section="shell"}
{:data-date="June 03, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Bookmark manager

## EXAMPLES

`b --ai`
: auto import

`b -w`
: manually add

`b -p`
: list bookmarks

`buku -w 'gedit -w`
: edit in editor

`$ buku -a https://ddg.gg search engine, privacy -c Search engine with perks`
: add bmark with tags *search engine*, *privacy*, `-c` is comment

`$ buku -a https://ddg.gg search engine, privacy --title 'DDG' --immutable 1`
: tag *search engine*, *privacy*, * immutable custom title

`$ buku -a https://ddg.gg search engine, privacy --title`
: no title

`$ buku -w 15012014`
: edit and upadte

`$ buku -u 15012014 --url http://ddg.gg/ --tag web search, utilities -c Private search engine`
: update existing with new url, tags, comments

`$ buku -u 15012014`
: fetch and update only for bookmark 15012014

`$ buku -u 15012014 -c this is a new comment`
: update only comment, *--url*, *--title*, and *--tag* work

`$ buku -e bookmarks.html --stag tag 1, tag 2`
: export bookmarks tagged *tag 1* or *tag 2* to HTML, markdown

`$ buku -i bookmarks.html`
: import bookmarks (*.md*, *.org*, *.db*)

`$ buku -u 15012014 -c`
: delete only comment for bmark

`$ buku -u`
: update full db

`$ buku -u --tacit (show only failures and exceptions)`
: update full db

`$ buku -d 15012014`
: delete bookmark

`$ buku -d`
: delete all bmark

`$ buku -d 100-200`
: delete range

`$ buku -d 100 15 200`
: delete list

`$ buku kernel debugging`
: search for ANY keyword *kernel* debugging* in URL title or tag

`$ buku -s kernel debugging`
: search for ANY keyword *kernel* debugging* in URL title or tag

`$ buku -S kernel debugging`
: search with ALL keywords *kernel* and *debugging* in URL title or tag

`$ buku --stag general kernel concepts`
: search bmark tagged *general kernel concepts*

`$ buku --stag kernel, debugging, general kernel concepts`
: search for matching ANY of the tags *kernel* and *debugging*, *general kernel concepts*

`$ buku --stag kernel + debugging + general kernel concepts`
: search matching ALL of the tags *kernel* and *debugging*, *general kernel concepts*

`$ buku hello world --exclude real life --stag 'kernel + debugging - general kernel concepts, books'`
: matching any of keywords *hello* or *world*, excluding *real* and *life*, matching both tags *kernel* and *debugging*, but excluding tags *general kernel concepts* and *books*

`$ buku --stag`
: list all unique tags alphabetically

`$ buku -s kernel debugging -u --tag + linux kernel`
: running search and update results

`$ buku -s kernel debugging -d`
: run search and del results

`$ buku -l 15`
: encrypt or decrypt DB with custom num of iterations to gen key

`$ buku -k 15`
: encrypt or decrypt DB with custom num of iterations to gen key, same num must be specified

`$ buku -p 20-30 15012014 40-50`
: show details of bmark at index 15012014, range 40-50

`$ buku -p -10`
: details of last 10 bmarks

`$ buku -p | bat`
: all bmark with real index from db

`$ buku --replace 'old tag' 'new tag'`
: replace old tag with new tag

`$ buku --replace 'old tag'`
: delete tag 'old tag' from db

`$ buku -u 15012014 --tag + tag 1, tag 2`
: append or delete tags 'tag1' 'tag2' existing tag of bmark

`$ buku -u 15012014 --tag - tag 1, tag 2`
: append or delete tags 'tag1' 'tag2' existing tag of bmark

`$ buku -o 15012014`
: open url at index 15012014 in browser

`$ buku -S blank`
: list bmark with no title or tags

`$ buku -S immutable`
: list bmakr with immutable title

`$ buku --shorten www.google.com`
: shorten url

`$ buku --shorten 20`
: shorten url at index 20

`$ buku --colors oKlxm -p`
: list with colors

`firefox $(buku -p -f 10 | fzf)`
: `firefox $(buku -p -f 40 | fzf | cut -f1)`
: ways of opening with firefox

* `url=$(buku -p -f4 | fzf -m --reverse --preview "buku -p {1}" --preview-window=wrap | cut -f2)`

* `if [ -n "$url" ]; then`
    * `echo "$url" | xargs firefox`
* `fi`
