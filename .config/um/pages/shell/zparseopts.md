# zparseopts --
{:data-section="shell"}
{:data-date="May 04, 2021"}
{:data-extra="Um Pages"}

## OPTIONS

`-D`
: remove matched options from param list

`-E`
: expect options and params to be mixed in -- don't stop when unkown options encounter

`-F`
: error on incorrect flag

`-a`
: store options in array `zparseopts -a myopts a b c -long`

`-A`
: store options in AA `zparseopts -A myopts a b c -long:`

`-v`
: be verbose

`-q`
: be quiet

`opt[=array]`
: called specs -- format

`opt:[=array]`
: mandatory

`opt::[=array]`
: optional args

`name+[=array]`
: pass flag more than once

`zparseopts -D -E -- f+:=files -files+:=files`
: first = `-f` switch, second = `--files` (denoted by single prefix)

`f+:=files`
: short params

`-files+:=files`
: long options

`+`
: have option repeatedly used, if not used, only last provided `-f` or `--file` is stored

`storage=("${(@)storage:#-f}")`
: drop every flag
