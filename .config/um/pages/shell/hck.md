# hck --
{:data-section="shell"}
{:data-date="July 11, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Better `cut`

## EXAMPLES

`hck -Ld' ' -f1-3,5- ./README.md`
: splitting with string literal

`ps aux | hck -f1-3,5-`
: splitting with regex

`ps aux | hck -f2,1,3- | head -n4`
: reordering output columns

`ps aux | hck -D'___' -f2,1,3 | head -n4`
: change output record separator

`ps aux | hck -r -F '^ST.*' -F '^USER$' | head -n4`
: select columns with regex

`hck -Ld' ' -f1-3,5- -z ./README.md.gz | head -n4`
: automatic decompression

`hck -Ld'$;$' -f3,4 ./test.txt`
: splitting on multiple chars

`hck -d'\d{3}[-_]+' -f3,4 ./test.txt`
: multiple chars
