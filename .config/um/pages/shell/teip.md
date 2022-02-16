# teip --
{:data-section="shell"}
{:data-date="November 14, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Cut / choose / hwk

## OPTIONS

```
Usage:
  teip -g <pattern> [-oGsvz] [--] [<command>...]
  teip -f <list> [-d <delimiter> | -D <pattern>] [-svz] [--] [<command>...]
  teip -c <list> [-svz] [--] [<command>...]
  teip -l <list> [-svz] [--] [<command>...]
  teip --help | --version

Options:
  --help          Display this help and exit
  --version       Show version and exit
  -g <pattern>    Select lines that match the regular expression <pattern>
  -o              -g selects only matched parts.
  -G              -g adopts Oniguruma regular expressions
  -f <list>       Select only these white-space separated fields
  -d <delimiter>  Use <delimiter> for field delimiter of -f
  -D <pattern>    Use regular expression <pattern> for field delimiter of -f
  -c <list>       Select only these characters
  -l <list>       Select only these lines
  -s              Execute command for each selected part
  -v              Invert the sense of selecting
  -z              Line delimiter is NUL instead of newline
```


`$ echo "100 200 300 400" | teip -f 3`
: 100 200 [300] 400

`$ echo "100 200 300 400" | teip -f 3 sed 's/./@/g'`
: 100 200 @@@ 400

`$ echo "100 200 300 400" | teip -f 3 -- cut -c 1`
: 100 200 3 400

`$ echo "100 200 300 400" | teip -f 3 -- awk '{print $1*2}'`
: 100 200 600 400

`$ echo "100 200 300 400" | teip -f 3,4 -- awk '{print $1*2}'`
: 100 200 600 800

`$ echo "100 200 300 400" | teip -f -3 -- sed 's/./@/g'`
: @@@ @@@ @@@ 400

`$ echo "100 200 300 400" | teip -f 2-4 -- sed 's/./@/g'`
: 100 @@@ @@@ @@@

`$ echo "100 200 300 400" | teip -f 1- -- sed 's/./@/g'`
: @@@ @@@ @@@ @@@

### SELECT RANGE BY CHARACTER

`$ echo ABCDEFG | teip -c 1,3,5,7`
: [A]B[C]D[E]F[G]

`$ echo ABCDEFG | teip -c 1,3,5,7 -- sed 's/./@/'`
: @B@D@F@

`$ echo "100,200,300,400" | teip -f 3 -d , -- sed 's/./@/g'`
: 100,200,@@@,400

`$ printf "100\t200\t300\t400\n" | teip -f 3 -d $'\t' -- sed 's/./@/g'`
: 100     200     @@@     400
