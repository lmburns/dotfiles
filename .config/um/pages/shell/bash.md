# bash scripting
{:data-section="shell"}
{:data-date="March 09, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Bash parameters and arguments to help with scripting.

## ARGUMENTS
- `$#` = number of arguments
- `$*` = all positional arguments (as a single word)
- `$@` = all positional arguments as separate strings
- `$1` = first argument
- `$_` = last argument of previous command

## DEFAULT VALUES
- `${FOO:-val}` = `$FOO` or `val` if unset (or null)
- `${FOO:=val}` = set `$FOO` to `val` if unset (or null)
- `${FOO:+val}` = `val` if `$FOO` is set (and not null)
- `${FOO:?message}` = show error messsage and exit if `$FOO` is unset (or null)

## PARAMETER EXPANSIONS
- `name="John"`
- `echo ${name}`
- `echo ${name/J/j}`    #=> "john" (substitution)
- `echo ${name:0:2}`    #=> "Jo" (slicing)
- `echo ${name::2}`     #=> "Jo" (slicing)
- `echo ${name::-1}`    #=> "Joh" (slicing)
- `echo ${name:(-1)}`   #=> "n" (slicing from right)
- `echo ${name:(-2):1}` #=> "h" (slicing from right)
- `echo ${food:-Cake}`  #=> $food or "Cake"

### MORE
- `STR="/path/to/foo.cpp"`
- `echo ${STR%.cpp}`    #=> /path/to/foo
- `echo ${STR%.cpp}.o`  #=> /path/to/foo.o
- `echo ${STR%/*}`      #=> /path/to

- `echo ${STR##*.}`     #=> cpp (extension)
- `echo ${STR##*/}`     #=> foo.cpp (basepath)

- `echo ${STR#*/}`      #=> path/to/foo.cpp
- `echo ${STR##*/}`     #=> foo.cpp

- `echo ${STR/foo/bar}` #=> /path/to/bar.cpp

### MORE 2
- `STR="Hello world"`
- `echo ${STR:6:5}`   #=> "world"
- `echo ${STR: -5:5}`  #=> "world"

### MORE 3
- `SRC="/path/to/foo.cpp"`
- `BASE=${SRC##*/}`   #=> "foo.cpp" (basepath)
- `DIR=${SRC%$BASE}`  #=> "/path/to/" (dirpath)

### OPERATORS

`${param@U}`
: uppercase

`${param@u}`
: first character uppercase

`${param@L}`
: lowercase

`${param@Q}`
: quoted where can be reused as input

`${param@E}`
: backslash escape sequences expanded like `$'...'`

`${param@P}`
: expand as if it were prompt string

`${param@A}`
: assignment/declare statement, if evaled will recreate param w/ attributes

`${param@K}`
: possibly quoted version, except prints values of index and  associate arrays as sequence of quoted key-value pairs

`${param@a}`
: flag values representing params attributes

## REGEX

`[[ $1 =! $regex ]] ... `
: `$BASH_REMATCH` variable contains match

## CONDITIONALS

|----------------------------|--------------------------|
| Condition                  | Command                  |
|----------------------------|--------------------------|
| \[\[ -z STRING \]\]        | Empty string             |
| \[\[ -n STRING \]\]        | Not empty string         |
| \[\[ STRING == STRING \]\] | Equal                    |
| \[\[ STRING != STRING \]\] | Not Equal                |
| \[\[ NUM -eq NUM \]\]      | Equal                    |
| \[\[ NUM -ne NUM \]\]      | Not equal                |
| \[\[ NUM -lt NUM \]\]      | Less than                |
| \[\[ NUM -le NUM \]\]      | Less than or equal       |
| \[\[ NUM -gt NUM \]\]      | Greater than             |
| \[\[ NUM -ge NUM \]\]      | Greater than or equal    |
| \[\[ STRING =~ STRING \]\] | Regexp                   |
| (( NUM < NUM ))            | Numeric conditions       |
| \[\[ -o noclobber \]\]     | If OPTIONNAME is enabled |
| \[\[ ! EXPR \]\]           | Not                      |
| \[\[ X && Y \]\]           | And                      |
| \[\[ X \|\| Y \]\]         | Or                       |
|----------------------------|--------------------------|

## FILE CONDITIONS

|---------------------------|-------------------------|
| Condition                 | Command                 |
|---------------------------|-------------------------|
| \[\[ -e FILE \]\]         | Exists                  |
| \[\[ -r FILE \]\]         | Readable                |
| \[\[ -h FILE \]\]         | Symlink                 |
| \[\[ -d FILE \]\]         | Directory               |
| \[\[ -w FILE \]\]         | Writable                |
| \[\[ -s FILE \]\]         | Size is > 0 bytes       |
| \[\[ -f FILE \]\]         | File                    |
| \[\[ -x FILE \]\]         | Executable              |
| \[\[ FILE1 -nt FILE2 \]\] | 1 is more recent than 2 |
| \[\[ FILE1 -ot FILE2 \]\] | 2 is more recent than 1 |
| \[\[ FILE1 -ef FILE2 \]\] | Same files              |
|---------------------------|-------------------------|

## REDIRECTION

`exec 1<&-`
: Close STDOUT file descriptor

`exec 2<&-`
: Close STDERR FD

`exec 1<>$LOG_FILE`
: Open STDOUT as $LOG_FILE file for read and write.

`exec 2>&1`
: Redirect STDERR to STDOUT
