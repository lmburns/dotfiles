# pup -- [flags] '[selectors] [display function]'
{:data-section="shell"}
{:data-date="May 07, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Parse HTML

## =====================================================================

## TUTORIAL

### CLEAN AND INDENT

`cat robots.html | pup --color`
: *default fill missing tags and indent*

`cat robots.html | pup 'title'`
: *filter by tag*

### FILTER BY ID

`cat robots.html | pup 'span#See-also'`
: *<span ... id="See-also">*

### FILTER BY ATTRIBUTE

`cat robots.html | pup 'th[scope="row"]'`
: *<th scope="row" class="navbox-group">*

## =====================================================================

## PSUEDO CLASSES

+ CSS selectors have group specifiers called psuedo classes

`cat robots.html | pup 'a[rel]:empty'`
: *<a rel="license"...*

`cat robots.html | pup ':contains("History")'`
: *<span ... id="History">*

`cat robots.html | pup ':parent-of([action="edit"])`
: *<a action="edit"...*

### INTERMEDIATE CHARACTERS

`+ > ,`
: intermediate chars

`cat robots.html | pup 'title, h1 span[dir="auto"]'`
: *comma (,)* - specify multiple group selectors
: `<title> ... <span dir="auto"> ...`

### CHAIN SELECTORS

`cat robots.html | pup 'h1#firstHeading'`
: when chaining, node selected by prev will pass to next

`cat robots.html | pup 'h1#firstHeading span'j`
: *<span dir="auto">*

### MIX AND MATCH SELECTORS

`pup 'element#id[attribute="value"]:first-of-type'`
: mix them

## =====================================================================

## DISPLAY FUNCTIONS

### text{}

`cat robots.html | pup '.mw-headline text{}'`
: print text from selected node and childen in depths

### attr{attrkey}

`cat robots.html | pup '.catlinks div attr{id}'`
: print values of all attributes with given key from selected node

### json{}

`cat robots.html  | pup 'div#p-namespaces a'`
: normal

`cat robots.html | pup 'div#p-namespaces a json{}'`
: print html as json

`cat robots.html | pup -i 4 'div#p-namespaces a json{}'`
: use `-i`, `--indeent` to control indent

`cat robots.html  | pup --indent 4 'title json{}'`
: one element return will be printed as json

### FLAGS

`pup --help`
: for help

## =====================================================================

## IMPLEMENTED SELECTORS

|-------|--------------------------|
| `pup` | *'.class'*               |
| `pup` | *'#id'*                  |
| `pup` | *'element'*              |
| `pup` | *'selector + selector'*  |
| `pup` | *'selector > selector'*  |
| `pup` | *'[attribute]'*          |
| `pup` | *'[attribute="value"]'*  |
| `pup` | *'[attribute*="value"]'* |
| `pup` | *'[attribute~="value"]'* |
| `pup` | *'[attribute^="value"]'* |
| `pup` | *'[attribute$="value"]'* |
| `pup` | *'empty'*                |
| `pup` | *'first-child'*          |
| `pup` | *'first-of-type'*        |
| `pup` | *'last-child'*           |
| `pup` | *'last-of-type'*         |
| `pup` | *'only-child'*           |
| `pup` | *'only-of-type'*         |
| `pup` | *'contains("text")'*     |
| `pup` | *'nth-child(n)'*         |
| `pup` | *'nth-of-type(n)'*       |
| `pup` | *'nth-last-child(n)'*    |
| `pup` | *'nth-last-of-type(n)'*  |
| `pup` | *'not(selector)'*        |
| `pup` | *'parent-of(selector)'*  |

## =====================================================================

## EXAMPLES
`curl –s https://google.com | pup title`
: get title

`pup strong`
: css selectors

`pup div#about`
: grab about section

`pup div#about text{}`
: spit out text

`pup p.title a[href^=http] attr{href}`
: reddit

`pup td.title a[href^=http] attr{href}`
: ycombinator

: Top links on both websites (`p.title` Reddit, `td.title` YComb).  Grab child tags with `a[href^http]`. Spit out attribute itself to print all top links.

`pup td.title a[href^=http] json{}`
: add json

`pup 'table table tr:nth-last-of-type(n+2) td.title a'`
: ycomb

`pup 'table table tr:nth-last-of-type(n+2) td.title a attr{href}'`
: only links

`pup 'table table tr:nth-last-of-type(n+2) td.title a json{}'`
: grab titles too
