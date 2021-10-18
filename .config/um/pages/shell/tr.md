# tr -- translate or delete characters
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## DESCRIPTION
Translate, squeeze, and/or delete characters from standard input, writing to standard output.

## OPTIONS

`'abc' '123'`
: 1 to 1 translation

`'a-f' '1-6'`
: ranges

`'a-z' 'A-Z'`
: change case

`'[:lower:]' '[:upper:]'`
: change case again

`'a-zA-Z' 'n-za-mN-ZA-M'`
: rot13

`tr 'a-z' 'A-Z' < marks.txt`
: shell input redirection

`-t 'a-z' '123'`
: truncate argument to be same length otherwise it's repeated

`'/-' '\\_'`
: symbols (\\ = \)

### DELETION

`-d`
: deletion

`-d '[:punct:]'`
: delete punctuation

`-cd '[:alpha:],\n'`
: compliment delete, retain only alphabet comma and newline

### SQUEEZE

`-s`
: compress multiple to one

`-sc '[:alpha:]'`
: squeeze other than alphabets

`-s 'A-Z' 'a-z'`
: only characters in second arg is used for squeeze

`tr -s '[:blank:]' ' '`
: multiple consec horizontal spaces into single space
