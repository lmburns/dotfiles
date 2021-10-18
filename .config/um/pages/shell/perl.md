# perl --
{:data-section="shell"}
{:data-date="March 10, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Command line options.

## CLI OPTIONS

|-------------------|---------------------------------------------------------------|
| `-0[octal]`       | specify record separator (`\0`, if no argument)               |
| `-a`              | autosplit mode with `-n` or `-p` (splits `$_` into `@F`)      |
| `-C[number/list]` | enables the listed Unicode features                           |
| `-c`              | check syntax only (runs `BEGIN` and `CHECK` blocks)           |
| `-d[:debugger]`   | run program under debugger                                    |
| `-D[number/list]` | set debugging flags (argument is a bit mask or alphabets)     |
| `-e` program      | one line of program (several -e's allowed, omit programfile)  |
| `-E` program      | like `-e`, but enables all optional features                  |
| `-f`              | don't do $sitelib/sitecustomize.pl at startup                 |
| `-F/pattern/`     | `split()` pattern for `-a` switch (`//`'s are optional)       |
| `-i[extension]`   | edit `<>` files in place (makes backup if extension supplied) |
| `-Idirectory`     | specify `@INC`/#include directory (several -I's allowed)      |
| `-l[octal]`       | enable line ending processing, specifies line terminator      |
| `-[mM]`[-]module  | execute use/no module... before executing program             |
| `-n`              | assume while (`<>`) { ... } loop around program               |
| `-p`              | assume loop like `-n` but print line also, like sed           |
| `-s`              | enable rudimentary parsing for switches after programfile     |
| `-S`              | look for programfile using PATH environment variable          |
| `-t`              | enable tainting warnings                                      |
| `-T`              | enable tainting checks                                        |
| `-u`              | dump core after parsing program                               |
| `-U`              | allow unsafe operations                                       |
| `-v`              | print version, patchlevel and license                         |
| `-V[:variable]`   | print configuration summary (or a single Config.pm variable)  |
| `-w`              | enable many useful warnings                                   |
| `-W`              | enable all warnings                                           |
| `-x[directory]`   | ignore text before #!perl line (optionally cd to directory)   |
| `-X`              | disable all warnings                                          |

## OPERATORS

### QUOTE LIKE OPERATORS

|-----------------------------------------|----------------------------------------------|
| `//`                                    | Empty or last successful matched regex       |
| `qr/STRING/msixpodualn`                 | Quote & compile regex                        |
| `m/PATTERN/msixpodualngc`               | Match pattern / scalar return T/F            |
| `/PATTERN/msixpodualngc`                | Match pattern / scalar return T/F            |
| `s/PATTERN/REPLACEMENT/msixpodualngcer` | Search and replace                           |
| `q/STRING/`                             | Single quote literal string                  |
| `qq/STRING/`                            | Double quote literal string                  |
| `qx/STRING/`                            | Interpolate, execute as `system`             |
| `qw/STRING`                             | Eval to list of words extracted (whitespace) |
| `tr/SEARCHLIST/REPLACEMENTLIST/cdsr`    | Transliterate                                |
| `y/SEARCHLIST/REPLACEMENTLIST/cdsr`     | Transliterate                                |

### MODIFIER OPTIONS

|------|------------------------------------------------------------------------------------|
| `m`  | Treat string as multiple lines.                                                    |
| `s`  | Treat string as single line. (Make . match a newline)                              |
| `i`  | Do case-insensitive pattern matching.                                              |
|------|------------------------------------------------------------------------------------|
| `x`  | Use extended regular expressions; specifying two                                   |
|      | x's means `\t` and the SPACE character are ignored within                          |
|      | square-bracketed character classes                                                 |
|------|------------------------------------------------------------------------------------|
| `p`  | When matching preserve a copy of the matched string so                             |
|      | that `${^PREMATCH}`, `${^MATCH}`, `${^POSTMATCH}` will be                          |
|      | defined (ignored starting in v5.20) as these are always                            |
|      | defined starting in that release                                                   |
|------|------------------------------------------------------------------------------------|
| `o`  | Compile pattern only once.                                                         |
|------|------------------------------------------------------------------------------------|
| `a`  | ASCII-restrict: Use ASCII for `\d`, `\s`, `\w` and `[[:posix:]]`                   |
|      | character classes; specifying two a's adds the further                             |
|      | restriction that no ASCII character will match a                                   |
|      | non-ASCII one under `/i`                                                           |
|------|------------------------------------------------------------------------------------|
| `l`  | Use the current run-time locale's rules.                                           |
| `u`  | Use Unicode rules.                                                                 |
| `d`  | Use Unicode or native charset, as in 5.12 and earlier.                             |
| `n`  | Non-capture mode. Don't let `()` fill in `$1`, `$2`, etc...                        |
|------|------------------------------------------------------------------------------------|
| `g`  | `m/PATT/` - Match globally, i.e., find all occurrences.                            |
| `c`  | `m/PATT/` - Do not reset search position on a failed match when `/g` is in effect. |
|------|------------------------------------------------------------------------------------|
| `e`  | `s//` - Evaluate the right side as an expression.                                  |
| `ee` | `s//` - Evaluate the right side as a string then eval the result                   |
| `r`  | `s//` - Return substitution and leave the original string untouched                |
|------|------------------------------------------------------------------------------------|
| `c`  | `tr//` - Complement the SEARCHLIST                                                 |
| `d`  | `tr//` - Delete found but unreplaced characters                                    |
| `r`  | `tr//` - Return the modified string and leave the original string untouched        |
| `s`  | `tr//` - Squash duplicate replaced characters.                                     |

## REGEX FLAGS

### ESCAPE SEQUENCES

|----------------|----------------------------------------------------------|-------------------------------|
| `\t`           | tab                                                      | (HT, TAB)                     |
| `\n`           | newline                                                  | (LF, NL)                      |
| `\r`           | return                                                   | (CR)                          |
| `\f`           | form feed                                                | (FF)                          |
| `\a`           | alarm (bell)                                             | (BEL)                         |
| `\e`           | escape (think troff)                                     | (ESC)                         |
| `\cK`          | control char                                             | (example: VT)                 |
| `\x{}`, `\x00` | character whose ordinal is the given hexadecimal number  |                               |
| `\N{name}`     | named Unicode character or character sequence            |                               |
| `\N{U+263D}`   | Unicode character                                        | (example: FIRST QUARTER MOON) |
| `\o{}`, `\000` | character whose ordinal is the given octal number        |                               |
| `\l`           | lowercase next char (think vi)                           |                               |
| `\u`           | uppercase next char (think vi)                           |                               |
| `\L`           | lowercase until \E (think vi)                            |                               |
| `\U`           | uppercase until \E (think vi)                            |                               |
| `\Q`           | quote (disable) pattern metacharacters until \E          |                               |
| `\E`           | end either case modification or quoted section, think vi |                               |

### CHARACTER CLASSES AND OTHER ESCAPES

|-------------|---------------------------------------------------------|
| Sequence    | Description                                             |
|-------------|---------------------------------------------------------|
| `[...]`     | Match a character according to the rules of the         |
|             | bracketed character class defined by the "...".         |
|             | Example: [a-z] matches "a" or "b" or "c" ... or "z"     |
|-------------|---------------------------------------------------------|
| `[[:...:]]` | Match a character according to the rules of the POSIX   |
|             | character class "..." within the outer bracketed        |
|             | character class.  Example: [[:upper:]] matches any      |
|             | uppercase character.                                    |
|-------------|---------------------------------------------------------|
| `(?[...])`  | Extended bracketed character class                      |
| `\w`        | Match a "word" character (alphanumeric plus "_", plus   |
|             | other connector punctuation chars plus Unicode          |
|-------------|---------------------------------------------------------|
| `\W`        | Match a non-"word" character                            |
| `\s`        | Match a whitespace character                            |
| `\S`        | Match a non-whitespace character                        |
| `\d`        | Match a decimal digit character                         |
| `\D`        | Match a non-digit character                             |
| `\pP`       | Match P, named property.  Use \p{Prop} for longer names |
| `\PP`       | Match non-P                                             |
| `\X`        | Match Unicode "eXtended grapheme cluster"               |
| `\1`        | Backreference to a specific capture group or buffer.    |
| `\g1`       | Backreference to a specific or previous group,          |
| `\g{-1}`    | The number may be negative indicating a relative        |
| `\g{name}`  | Named backreference                                     |
| `\k<name>`  | Named backreference                                     |
| `\K`        | Keep the stuff left of the \K, don't include it in $&   |
| `\N`        | Any character but \n.  Not affected by /s modifier      |
| `\v`        | Vertical whitespace                                     |
| `\V`        | Not vertical whitespace                                 |
| `\h`        | Horizontal whitespace                                   |
| `\H`        | Not horizontal whitespace                               |
| `\R`        | Linebreak                                               |

### ASSERTIONS

|--------|-----------------------------------------------------------|
| `\b{}` | Match at Unicode boundary of specified type               |
| `\B{}` | Match where corresponding `\b{}` doesn't match            |
| `\b`   | Match a `\w\W` or `\W\w` boundary                         |
| `\B`   | Match except at a `\w\W` or `\W\w` boundary               |
| `\A`   | Match only at beginning of string                         |
| `\Z`   | Match only at end of string, or before newline at the end |
| `\z`   | Match only at end of string                               |
| `\G`   | Match only at pos() (e.g. at the end-of-match position    |
|        | of prior `m//g`)                                          |

|---------|--------------------------------------------|
| `*`     | Match 0 or more times                      |
| `+`     | Match 1 or more times                      |
| `?`     | Match 1 or 0 times                         |
| `{n}`   | Match exactly n times                      |
| `{n,}`  | Match at least n times                     |
| `{n,m}` | Match at least n but not more than m times |

|----------|----------------------------------------------------------|
| `*?`     | Match 0 or more times, not greedily                      |
| `+?`     | Match 1 or more times, not greedily                      |
| `??`     | Match 0 or 1 time, not greedily                          |
| `{n}?`   | Match exactly n times, not greedily (redundant)          |
| `{n,}?`  | Match at least n times, not greedily                     |
| `{n,m}?` | Match at least n but not more than m times, not greedily |

|----------|------------------------------------------------------------------|
| `*+`     | Match 0 or more times and give nothing back                      |
| `++`     | Match 1 or more times and give nothing back                      |
| `?+`     | Match 0 or 1 time and give nothing back                          |
| `{n}+`   | Match exactly n times and give nothing back (redundant)          |
| `{n,}+`  | Match at least n times and give nothing back                     |
| `{n,m}+` | Match at least n but not more than m times and give nothing back |


## SPECIAL VARIABLES

`$^V`
: print version

`$_`
: contents of current input line (**input record**)

`$.`
: line number (records so far, same as **awk NR**)

`$&`
: entire matched string

`$\``
: (literal backtick) everything prior to matched string

`$'`
: everything after matched string

`$[`
: scalar containing first index of all arrays

`@_`
: `$@` in bash, first arg
: `$_[0]` - flattened list combining all args passed to subroutine in order

### USEFUL AND MOST COMMON
`@F`
: contain all elements, indexing from 0

`$#F`
: last index of item (**awk NF**)

`$,`
: change **output field separator**

`$"`
: change outut field separator when array is interpolated (Default space)

`$/`
: specify different **input record separator** - also `-0OCTAL` (single char)

`$\`
: specify different **output record separator** (default: none) - also `-lOCTAL`

`$-[0]`
: offset of the start of last successful match

`$+[0]`
: offset into the string of the end of the entire match
: `$+[1] - $-[1]` = length of `$1`

`0777`
: **slurp**

`-00`
: **Paragraph mode**

`$0`
: program name

`$/`
: input separator

`$\`
: output separator

`$|`
: autoflush

`$!`
: sys/libcall error

`$@`
: eval error

`$$`
: process ID

`$<`
: user id

`@ARGV`
: command line args

`@INC`
: include paths

`@_`
: subroutine args

`%ENV`
: environment


### AWK SIMILARITIES
`BEGIN`
: if same separator to be used for all lines

`close ARGV` and `$.==`
: `awk` **FNR** (resets `$.` to 0)
: `$. == 2 close ARGV if eof;` == `FNR==2`

`close ARGV`
: `awk` **nextfile**
: `close ARGV if $.>=1`

`if(!$#ARGV)`
: `awk NR==FNR` == only true for first file

`<=>`
: return -1 = less than, 0 = equal to, 1 = greater than

`{$a <=> $b}`
: sort ascending

`{$b <=> $a}`
: sort descending


### GLOBAL SCALAR SPECIAL VARIABLES
To use English, need **use English;**

`$_`, `$ARG`
: default input and pattern-searching space

`$.`, `$NR`
: current input line num of last FH that was read

`$/`, `$RS`
: input record separator; newline by default

`$,`, `$OFS`
: output field separator for the print operator

`$\`, `$ORS`
: output record separator for the print operator

`$"`, `$LIST_SEPARATOR`
: like `$,` except for interplated; space by default

`$;`, `$SUBSCRIPT_SEPARATOR`
: subscript separator for multidim array

`$^L`, `$FORMAT_FORMFEED`
: format outputs to perform a formfeed

`$:`, `$FORMAT_LINE_BREAK_CHARACTERS`
: asdf

`$^A`, `$ACCUMULATOR`
: current value of the write accumulator for format lines

`$#`, `$OFMT`
: output format for printed numbers (deprecated)

`$?`, `$CHILD_ERROR`
: status returned by the last pipe close, backtick (``)

`$!`, `$OS_ERROR`, `$ERRNO`
: numeric context = errno variable, string = syserror

`$@`, `$EVAL_ERROR`
: syntax error message from the last eval command

`$$`, `$PROCESS_ID`, `$PID`
: pid of the Perl process running this script

`$<`, `$REAL_USER_ID`, `$UID`
: real user ID (uid) of this process

`$>`, `$EFFECTIVE_USER_ID`, `$EUID`
: effective user ID of this process

`$(`, `$REAL_GROUP_ID`, `$GID`
: real group ID (gid) of this process

`$)`, `$EFFECTIVE_GROUP_ID`, `$EGID`
: effective gid of this process

`$0`, `$PROGRAM_NAME`
: name of the file containing script

`$[`
: index of first element in an array; default is 0

`$]`, `$PERL_VERSION`
: version plus patchlevel divided by 1000

`$^D`, `$DEBUGGING`
: current value of the debugging flags

`$^E`, `$EXTENDED_OS_ERROR`
: extended error message on some platforms

`$^F`, `$SYSTEM_FD_MAX`
: maximum system file descriptor, ordinarily 2

`$^H`
: internal compiler hints enabled by certain pragmatic modules

`$^I`, `$INPLACE_EDIT`
: value of the inplace-edit extension (undef=disable)

`$^M`
: `$M` can be used as an emergency memory pool in case Perl dies

`$^O`, `$OSNAME`
: operating system that the Perl binary was compiled for

`$^P`, `$PERLDB`
: flag that the debugger clears so that it doesn't debug itself

`$^T`, `$BASETIME`
: time at which the script began running

`$^W`, `$WARNING`
: value of the warning switch, either true or false

`$^X`, `$EXECUTABLE_NAME`
: name that the Perl binary itself was executed as

`$ARGV`
: name of the current file when reading from `<ARGV>`


### GLOBAL ARRAY SPECIAL VARIABLES
`@ARGV`
: contain CLI arguments

`@INC`
: list of place to learn for perl scripts

`@F`
: input lines are split when -a switch is given


### GLOBAL HASH SPECIAL VARIABLES
`%INC`
: contain entries for filename of each file included via do or require

`%ENV`
: current environment

`%SIG`
: set signal handlers


### GLOBAL SPECIAL CONSTANTS
`__END__`
: logical end of program (any text after = ignored)

`__FILE__`
: filename at point in program where it's used

`__LINE__`
: current line number

`__PACKAGE__`
: current package name

### REGEX SPECIAL VARIABLES
`$digit`
: e.g., `$1`  -- represents capture group (in replacement)

`\digit`
: e.g., `\1`  -- represetns capture group (in search)

`^{@CAPTURE}`
: capture groups in `say`

`$&`
: string matched by last successful capture group

`$``
: string preceding match

`$'`
: string after match

`$+`
: last bracket matched by last search pattern

### GLOBAL SPECIAL FILEHANDLES
`<<>>`
: all arguments treated as file names

`ARGV`
: iterates over CLI filenames in `@ARGV`, written as null FH in `<>`

`STDERR` `STDIN` `STDOUT`
: what it says

`DATA`
: refer to anything following `__END__` or `__DATA__`

`_`
: cache info from last stat

### FILEHANDLE SPECIAL VARIABLES
`$~`
: `$FORMAT_NAME`

`$^`
: `$FORMAT_TOP_NAME`

`$%`
: `$FORMAT_PAGE_NUMBER`

`$=`
: `$FORMAT_LINES_PER_PAGE` - default 60

`$-`
: `$FORMAT_LINES_LEFT`


### SEARCH AND REPLACE EXAMPLES

`s/\bgreen\b/mauve/g;`
: don't change wintergreen

`$path =~ s|/usr/bin|/usr/local/bin|;`

`s/Login: $foo/Login: $bar/;`
: run-time pattern

`($foo = $bar) =~ s/this/that/;`
:  copy first, then change

`($foo = "$bar") =~ s/this/that/;`
:  convert to string, copy, then change

`$foo = $bar =~ s/this/that/r;`
:  Same as above using `/r`

`$foo = $bar =~ s/this/that/r`
: `=~ s/that/the other/r;`  -- Chained substitutes using `/r`

`@foo = map { s/this/that/r } @bar`
: `/r` is very useful in maps

`$count = ($paragraph =~ s/Mister\b/Mr./g);`
:  get change-cnt

`$_ = 'abc123xyz';`

`s/\d+/$&*2/e;`
: yields 'abc246xyz'

`s/\d+/sprintf("%5d",$&)/e;`
: yields 'abc  246xyz'

`s/\w/$& x 2/eg;`
: yields 'aabbcc  224466xxyyzz'

`s/%(.)/$percent{$1}/g;`
:  change percent escapes; no `/e`

`s/%(.)/$percent{$1} || $&/ge;`
:  expr now, so `/e`

`s/^=(\w+)/pod($1)/ge;`
:  use function call

`$_ = 'abc123xyz';`

`$x = s/abc/def/r;`
: `$x` is 'def123xyz' and `$_` remains 'abc123xyz'.

`s/\$(\w+)/${$1}/g;`
: expand variables in $_, but dynamics only, using symbolic dereferencing

`s/(\d+)/1 + $1/eg;`
: Add one to the value of any numbers in the string

`substr($str, -30) =~ s/\b(\p{Alpha}+)\b/\u\L$1/g;`
: Titlecase words in the last 30 characters only

`s/(\$\w+)/$1/eeg;`
: This will expand any embedded scalar variable (including lexicals) in `$_` : First `$1` is interpolated
: to the variable name, and then evaluated

# Delete (most) C comments.
`$program =~ s {`
: `/\*`     # Match the opening delimiter.
: `.*?`     # Match a minimal number of characters.
: `\*/`     # Match the closing delimiter.
: `} []gsx;`

`s/^\s*(.*?)\s*$/$1/;`
: trim whitespace in `$_,` expensively

`for ($variable) {`
: trim whitespace in $variable, cheap
: `s/^\s+//;`
: `s/\s+$//; }
`
`s/([^ ]*) *([^ ]*)/$2 $1/;`
: reverse 1st two fields

`$foo !~ s/A/a/g;`
: Lowercase all A's in `$foo`; return 0 if any were found and changed; otherwise return 1


### TRANSLITERATE EXAMPLES

`$ARGV[1] =~ tr/A-Z/a-z/;`
:  canonicalize to lower case ASCII

`$cnt = tr/*/*/;`
:  count the stars in $_

`$cnt = tr/*//;`
:  same thing

`$cnt = $sky =~ tr/*/*/;`
: count the stars in $sky

`$cnt = $sky =~ tr/*//;`
:  same thing

`$cnt = $sky =~ tr/*//c;`
:  count all the non-stars in $sky

`$cnt = $sky =~ tr/*/*/c;`
: same, but transliterate each non-string into a star, leaving the already-stars
: alone.  Afterwards, everything in $sky is a star.

`$cnt = tr/0-9//;`
:  count the ASCII digits in $_

`tr/a-zA-Z//s;`
:  bookkeeper -> bokeper

`tr/o/o/s;`
:  bookkeeper -> bokkeeper

`tr/oe/oe/s;`
:  bookkeeper -> bokkeper

`tr/oe//s;`
:  bookkeeper -> bokkeper

`tr/oe/o/s;`
:  bookkeeper -> bokkopor

`($HOST = $host) =~ tr/a-z/A-Z/;`
: `$HOST = $host  =~ tr/a-z/A-Z/r;`  same thing

`$HOST = $host =~ tr/a-z/A-Z/r`
: chained with `s///r` --- `=~ s/:/ -p/r;`

`tr/a-zA-Z/ /cs;`
:  change non-alphas to single space

`@stripped = map tr/a-zA-Z/ /csr, @original;`
: /r with map

`tr [\200-\377]`
: `[\000-\177];` -- wickedly delete 8th bit

`$foo !~ tr/A/a/`
: transliterate all the A's in $foo to 'a', return 0 if any were found and changed.
: Otherwise return 1
