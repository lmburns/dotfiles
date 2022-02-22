# zsh --
{:data-section="shell"}
{:data-date="April 30, 2021"}
{:data-extra="Um Pages"}

## GLOBBING QUALIFIERS

### WEBSITE

https://zsh.fyi/expansion

## EXTENDED PATTERNS

### EXTENDED_GLOB

|-------------|--------------------------------------------|
| `^pat`      | Anything that doesn’t match *pat*          |
| `pat1^pat2` | Match pat1 then anything other than *pat2* |
| `pat1~pat2` | Anything matching *pat1* but not *pat2*    |
| `X#`        | Zero or more occurrences of element *X*    |
| `X##`       | One or more occurrences of element *X*     |

### KSH_GLOB

|----------|---------------------------------|
| `@(pat)` | Group patterns                  |
| `*(pat)` | Zero or more occurrences of pat |
| `+(pat)` | One or more occurrences of pat  |
| `?(pat)` | Zero or one occurrences of pat  |
| `!(pat)` | Anything but the pattern pat    |

### GLOBBING FLAGS - EXTENDED_GLOB

|------------|----------------------------------------------|
| `(#i)`     | Match case insensitively                     |
| `(#l)`     | Lower case matches upper case                |
| `(#I)`     | Match case sensitively                       |
| `(#b)`     | Parentheses set :`match`, `mbegin`, `mend`    |
| `(#B)`     | Parentheses no longer set arrays             |
| `(#m)`     | Match in `MATCH`, `MBEGIN`, `MEND`           |
| `(#M)`     | Don’t use `MATCH` etc.                       |
| `(#anum)`  | Match with num approximations                |
| `(#s)`     | Match only at start of test string           |
| `(#e)`     | Match only at end of test string             |
| `(#qexpr)` | `expr` is a set of glob qualifiers (below) |

### GLOB QUALIFIERS - PARENTHESIS AFTER FILE NAME PATTERN

|--------|-------------------------------------------|
| `/`    | Directory                                 |
| `F`    | Non­empty directory; for empty us *(/^F)* |
| `.`    | Plain file                                |
| `@`    | Symbolic link                             |
| `=`    | Socket                                    |
| `p`    | Name pipe *(FIFO)*                        |
| `*`    | Executable plain file                     |
| `%`    | Special file                              |
| `%b`   | Block special file                        |
| `%c`   | Character special file                    |
| `r`    | Readable by owner (N.B. not current user) |
| `w`    | Writeable by owner                        |
| `x`    | Executable by owner                       |
| `A`    | Readable by members of file’s group       |
| `I`    | Writeable by members of file’s group      |
| `E`    | Executable by members of file’s group     |
| `R`    | World readable                            |
| `W`    | World writeable                           |
| `X`    | World executablesSetuid                   |
| `(-@)` | Only broken symlinks                      |
| `D`    | Match hidden files                        |

### GLOBBING QUALIFIERS

`(.)`
: regular files only

`(/)`
: directories

`(*)`
: executable files

`(.x)`
: executable by owner

`(@)`
: symlinks

`(=)`
: sockets

`(p)`
: named pipes

`(%)`
: device files

`(%b)`
: block files

`(%c)`
: character files

`ls **/*(.:g-w:)`
: don't have write permissions to group in curr dir & sub

`ls -l **/*(u:tomcat:)`
: files of user tomcat

`ls -l **/*(.G)`
: files that have primary groupy

`ls **/*(.aM-1)`
: accessed last month

### GLOB OPERATORS - LONG

`[^...], [!...]`
: Like *[...]*, except that it matches any character which is not in the given set.

`<[x]-[y]>`
: Matches any number in the range *x* to *y*, inclusive. Either of the numbers may be omitted to make the range open-ended; hence `<->` matches any number. To match individual digits, the `[...]` form is more efficient.

Be careful when using other wildcards adjacent to patterns of this form; for example, `<0-9>*` will actually match any number whatsoever at the start of the string, since the `<0-9>` will match the first digit, and the `*` will match any others. This is a trap for the unwary, but is in fact an inevitable consequence of the rule that the longest possible match always succeeds. Expressions such as `<0-9>[^[:digit:]]*` can be used instead.

`(...)`
: Matches the enclosed pattern. This is used for grouping. If the *KSH_GLOB* option is set, then a `@`, `*`, `+`, `?` or `!` immediately preceding the `(` is treated specially, as detailed below. The option *SH_GLOB* prevents bare parentheses from being used in this way, though the *KSH_GLOB* option is still available.

Note that grouping cannot extend over multiple directories: it is an error to have a `/` within a group (this only applies for patterns used in filename generation). There is one exception: a group of the form *(pat/)#* appearing as a complete path segment can match a sequence of directories. For example, *foo/(a/)#bar* matches `foo/bar`, `foo/any/bar`, `foo/any/anyother/bar`, and so on.

`x|y`
: Matches either *x* or *y*. This operator has lower precedence than any other. The `|` character must be within parentheses, to avoid interpretation as a pipeline. The alternatives are tried in order from left to right.

`^x`
: (Requires *EXTENDED_GLOB* to be set.) Matches anything except the pattern `x`. This has a higher precedence than `/`, so `^foo/bar` will search directories in `.` except `./foo` for a file named `bar`.

`x~y`
: (Requires *EXTENDED_GLOB* to be set.) Match anything that matches the pattern `x` but does not match `y`. This has lower precedence than any operator except `|`, so `*/*~foo/bar` will search for all files in all directories in `.` and then exclude `foo/bar` if there was such a match. Multiple patterns can be excluded by `foo~bar~baz`. In the exclusion pattern (*y*), `/` and `.` are not treated specially the way they usually are in globbing.

`x#`
: (Requires *EXTENDED_GLOB* to be set.) Matches zero or more occurrences of the pattern *x*. This operator has high precedence; `12#` is equivalent to `1(2#)`, rather than `(12)#`. It is an error for an unquoted `#` to follow something which cannot be repeated; this includes an empty string, a pattern already followed by `##`, or parentheses when part of a *KSH_GLOB* pattern (for example, `!(foo)#` is invalid and must be replaced by `*(!(foo))`).

`x##`
: (Requires *EXTENDED_GLOB* to be set.) Matches one or more occurrences of the pattern `x`. This operator has high precedence; `12##` is equivalent to `1(2##)`, rather than `(12)##`. No more than two active `#` characters may appear together. (Note the potential clash with glob qualifiers in the form `1(2##)` which should therefore be avoided.)

### GLOBBING FLAGS - LONG

All take the form *#X* where *X* may have any of the following:

`i`
: Case insensitive: upper or lower case characters in the pattern match upper or lower case characters.

`l`
: Lower case characters in the pattern match upper or lower case characters; upper case characters in the pattern still only match upper case characters.

`I`
: Case sensitive: locally negates the effect of *i* or *l* from that point on.

`b`
: Activate *backreferences* for parenthesised groups in the pattern; this does not work in filename generation. When a pattern with a set of active parentheses is matched, the strings matched by the groups are stored in the array *$match*, the indices of the beginning of the matched parentheses in the array *$mbegin*, and the indices of the end in the array *$mend*, with the **first element of each array corresponding to the first parenthesised group**, and so on. These arrays are not otherwise special to the shell. Elements of *$mend* and *$mbegin* may be used in subscripts. Sets of globbing flags are not considered parenthesised groups; only the first nine active parentheses can be referenced.

For example,

:    `foo="a_string_with_a_message"`
:    `if [[ $foo = (a|an)_(#b)(*) ]]; then`
:      `print ${foo[$mbegin[1],$mend[1]]}`
:    `fi`

Prints `string_with_a_message`. Note that the first set of parentheses is before the *(#b)* and does not create a backreference.

Backreferences work with all forms of pattern matching other than filename generation, but note that when performing matches on an entire array, such as `${array#pattern}`, or a global substitution, such as `${param//pat/repl}`, **only the data for the last match remains available**. Global replacements this may still be useful. See the example for the *m* flag below.

The numbering of backreferences strictly follows the order of the opening parentheses from left to right in the pattern string, although sets of parentheses may be nested. There are special rules for parentheses followed by `#` or `##`. Only the last match of the parenthesis is remembered: for example, in `[[ abab = (#b)([ab])# ]]`, only the final `b` is stored in *match[1]*. Thus extra parentheses may be necessary to match the complete segment: for example, use `X((ab|cd)#)Y` to match a whole string of either `ab` or `cd` between `X` and `Y`, using the value of *$match[1]* rather than *$match[2]*.

If the match *fails* none of the parameters is altered, so in some cases it may be necessary to initialize them beforehand. If some of the backreferences fail to match — which happens if they are in an alternate branch which fails to match, or if they are followed by *#* and matched zero times — then the matched string is set to the empty string, and the start and end indices are set to -1.

`B`
: Deactivate backreferences, negating the effect of the *b* flag from that point on.

`cN,M`
: The flag *(#cN,M)* can be used anywhere that the *#* or *##* operators can be used except in the expressions `(*/)#` and `(*/)##` in filename generation, where `/` has special meaning; it cannot be combined with other globbing flags and a bad pattern error occurs if it is misplaced. It is equivalent to the form *{N,M}* in regular expressions. The previous character or group is required to match between *N* and *M* times, inclusive. The form `(#cN)` requires exactly *N* matches; `(#c,M)` is equivalent to specifying *N* as *0*; `(#cN,)` specifies that there is no maximum limit on the number of matches.

`m`
: Set references to the match data for the **entire string matched**; this is similar to backreferencing and does not work in filename generation. The flag must be in effect at the end of the pattern, i.e. not local to a group. The parameters *$MATCH*, *$MBEGIN* and *$MEND* will be set to the string matched and to the indices of the beginning and end of the string, respectively. This is most useful in parameter substitutions, as otherwise the string matched is obvious.

For example,

: `arr=(veldt jynx grimps waqf zho buck)`
: `print ${arr//(#m)[aeiou]/${(U)MATCH}}`

Forces all the matches (i.e. all vowels) into uppercase, printing `vEldt jynx grImps wAqf zhO bUck`.

Unlike backreferences, there is no speed penalty for using match references, other than the extra substitutions required for the replacement strings in cases such as the example shown.

`M`
: Deactivate the *m* flag, hence no references to match data will be created.

`anum`
: Approximate matching: *num* errors are allowed in the string matched by the pattern. The rules for this are described in the next subsection.

`s, e`
: Unlike the other flags, these have only a *local* effect, and each must appear on its own: `(#s)` and `(#e)` are the only valid forms. The `(#s)` flag succeeds only at the *start* of the test string, and the `(#e)` flag succeeds only at the *end* of the test string; they correspond to `^` and `$` in standard regular expressions. They are useful for matching path segments in patterns other than those in filename generation (where path segments are in any case treated separately). For example, `*((#s)|/)test((#e)|/)*` matches a path segment `test` in any of the following strings: test, test/at/start, at/end/test, in/test/middle.

Another use is in parameter substitution; for example `${array/(#s)A*Z(#e)}` will remove only elements of an array which match the *complete pattern* `A*Z`. There are other ways of performing many operations of this type, however the combination of the substitution operations `/` and `//` with the `(#s)` and `(#e)` flags provides a single simple and memorable method.

**Note** that assertions of the form `(^(#s))` also work, i.e. match anywhere except at the start of the string, although this actually means `anything except a zero-length portion at the start of the string`; you need to use `(""~(#s))` to match a zero-length portion of the string not at the start.

`q`
: A `q` and everything up to the closing parenthesis of the globbing flags are *ignored by the pattern matching code*. This is intended to support the use of glob qualifiers, see below. The result is that the pattern `(#b)(*).c(#q.)` can be used both for globbing and for matching against a string. In the former case, the `(#q.)` will be treated as a glob qualifier and the `(#b)` will not be useful, while in the latter case the `(#b)` is useful for backreferences and the `(#q.)` will be ignored. Note that colon modifiers in the glob qualifiers are also not applied in ordinary pattern matching.

`u`
: Respect the current locale in determining the presence of multibyte characters in a pattern, provided the shell was compiled with *MULTIBYTE_SUPPORT*. This overrides the *MULTIBYTE* option; the default behaviour is taken from the option. Compare U. (Mnemonic: typically multibyte characters are from Unicode in the UTF-8 encoding, although any extension of ASCII supported by the system library may be used.)

`U`
: All characters are considered to be a single byte long. The opposite of u. This overrides the MULTIBYTE option.

For example, the test string `fooxx` can be matched by the pattern *(#i)FOOXX*, but not by *(#l)FOOXX*, *(#i)FOO(#I)XX* or *((#i)FOOX)X*. The string `(#ia2)readme` specifies case-insensitive matching of readme with up to two errors.

When using the ksh syntax for grouping both *KSH_GLOB* and *EXTENDED_GLOB* must be set and the left parenthesis should be preceded by @. Note also that the flags do not affect letters inside [...] groups, in other words *(#i)[a-z]* still matches only lowercase letters. Finally, note that when examining whole paths case-insensitively every directory must be searched for all files which match, so that a pattern of the form *(#i)/foo/bar/...* is potentially slow.

## ==============================================================

## SUBSCRIPT FLAGS

|-------------|-------------------------------------------------------------------------------------|
| `e`         | plain string match instead; `${array[(re)*]}` = array element literal '*'           |
| `w`         | if is a scalar, flag makes subscrip work per-word basis instead of chars            |
| `s:string:` | define string separates words (for use with the `w` flag)                           |
| `p`         | recognize same esc seq as print builtin string arg of a subsequent `s` flag         |
| `f`         | if param subscripted = scalar, makes subscript per-line basis instead of characters |
| `r`         | exp taken as patt & result is 1st matching array element, substring or word         |
| Note:       | this is like giving a number: `$foo[(r)??,3]` & `$foo[(r)??,(r)f*]` work            |
| `R`         | Like `r`, but gives the last match                                                  |
| `i`         | Like `r`, but gives the index of the match instead; no 2nd arg                      |
| `I`         | Like `i`, but gives the index of the last match.                                    |
| `n:expr:`   | If combined with `r`/`R`/`i`/`I`, makes return the n'th or n'th last match          |
| `b:expr:`   | Combined w `r/R/i/I` begin at `nth`/`-nth` element; no associative array            |
| `k`         | Associative array = keys interp as vals; no left-hand side assignment; return match |
| `K`         | Same as `k` but return all keys matching                                            |

## ==============================================================

## EXPANSION

### WORD DESIGNATORS

A word designator indicates which word or words of a given command line are to be included in a history reference. A `:` usually separates the event specification from the word designator. It may be omitted only if the word designator begins with a `^`, `$`, `*`, `-` or `%`. Word designators include:

|-------|-------------------------------------------------------|
| `0`   | The first input word (command).                       |
| `n`   | The nth argument.                                     |
| `^`   | The first argument. That is, 1.                       |
| `$`   | The last argument.                                    |
| `%`   | The word matched by (the most recent) ?str search.    |
| `x-y` | A range of words; x defaults to 0.                    |
| `*`   | All the arguments, or a null value if there are none. |
| `x*`  | Abbreviates `x-$`.                                    |
| `x-`  | Like `x*` but omitting word `$`.                        |

## ==============================================================

### MODIFIERS ON ARGS (CAN OMIT WORD SELECTOR)

|------------------|------------------------------------------------------------|
| `!!:1:h [digit]` | Trailing path component removed                            |
| `!!:1:t`         | Only trailing path component left                          |
| `!!:1:r`         | File extension .ext removed                                |
| `!!:1:e`         | Only extension ext left                                    |
| `!!:1:p`         | Print result but don’t execute                             |
| `!!:1:q`         | Quote from further substitution                            |
| `!!:1:Q`         | Strip one level of quotes                                  |
| `!!:1:x`         | Quote and also break at whitespace                         |
| `!!:1:l`         | Convert to all lower case                                  |
| `!!:1:u`         | Convert to all upper case                                  |
| `!!:1:s/s1/s2/`  | Replace string s1 bys2                                     |
| `!!:1:gs/s2/s2/` | Same but global                                            |
| `!!:1:&`         | Use same s1 and s2 on new targe                            |
| `!!:1:a`         | Turn filename to absolute path                             |
| `!!:1:A`         | Turn filename to absolute path, then pass to `realpath`    |
| `!!:1:c`         | Resolve commnd name to absolute path checking `$PATH`      |
| `!!:1:P`         | Filename abs path; no `.` or `..`; refer same dir as input |

### MODIFIERS - ONLY PARAMETER EXPANSIO

|-----------|-------------------------------------------------------------|
| `f`       | no colon; repeat modifier until word doesn't change anymore |
| `F:expr:` | like `f`; though repeat `n` times                           |
| `w`       | make immediately following modifer work on each word        |
| `W:sep:`  | like `w`; but words separated by `sep`                      |

### MODIFIERS ON VAR/GLOBQUALIFIERS

Most modifiers work on variables (e.g `${var:h}`) or in globqualifiers (e.g. `*(:h)`), the following only work there:

|------------------|---------------------------------------|
| `${var:fm}`      | Repeat modifier m till stops changing |
| `${var:F:N:m}`   | Same but no more than N times         |
| `${var:wm}`      | Apply modifer m to words of string    |
| `${var:W:sep:m}` | Same but words are separated by sep   |

## ==============================================================

### PARAMETER (VARIABLE) EXPANSION
Basic forms: str will also be expanded; most forms work onwords of array separately:

|------------------------|-------------------------------------------------|
| `${var}`               | substitute contents of `$var`, no splitting     |
| `${+var}`              | 1 if `$var` is set, else 0                      |
|------------------------|-------------------------------------------------|
| `${var-str}`           | `$var` if set (even if null) else str           |
| `${var:-str}`          | `$var` if non­null, else str                    |
|------------------------|-------------------------------------------------|
| `${var+str}`           | str if `$var` is set, else nothing              |
| `${var:+str}`          | str if `$var` is set/non-null, else nothing     |
|------------------------|-------------------------------------------------|
| `${var=str}`           | `$var` unset, set to `str`                      |
| `${var:=str}`          | `$var` unset/null, set to `str`                 |
| `${var::=str}`         | Same but always use `str`                       |
|------------------------|-------------------------------------------------|
| `${var?str}`           | `$var` if set else error, abort                 |
| `${var:?str}`          | `$var` if set/non­null else error, abort        |
|------------------------|-------------------------------------------------|
| `${var#pat}`           | min match of `pat` removed from head            |
| `${var##pat}`          | max match of `pat` removed from head            |
|------------------------|-------------------------------------------------|
| `${var%pat}`           | min match of `pat` removed from tail            |
| `${var%%pat}`          | max match of `pat` removed from tail            |
|------------------------|-------------------------------------------------|
| `${var:#pat}`          | `$var` unless pat matches, then empty           |
| `${var:<PIPE>arrname}` | elements in `arrname` are removed from `$var`   |
| `${var:*arrname}`      | elements in `arrname` are reserved if in `$var` |
| `${var:^arrname}`      | zips together arrays twice as long as shortest  |
| `${var:^^arrname}`     | zips together arrays twice as long as longest   |
| `${var:offset}`        | similar to `$name[start]`                       |
| `${var:offset:length}` | similar to `$name[start,end]`                   |
|------------------------|-------------------------------------------------|
| `${var/p/r}`           | One occurrence of `p` replaced by `r`           |
| `${var//p/r}`          | All occurrences of `p` replaced by `r`          |
| `${var:/p/r}`          | Replace only if `p` matches all of `r`          |
|------------------------|-------------------------------------------------|
| `${#var}`              | Length of var in words (array) or bytes         |
| `${^var}`              | Expand elements like brace expansion            |
| `${=var}`              | Split words of result like lesser shells        |
| `${~var}`              | Allow globbing, file expansion on result        |
| `${${var%p}#q}`        | Apply `%p` then `#q` to `$var`                  |

## ==============================================================

### PARAMETER FLAGS IN PARENTEHSIS (IMMEDIATELY AFTER LEFT BRACE)

+ Delimeters  shown as `:str:` may be any pair of chars or matchedparenthses `(str)`, `{str}`, `[str]`, `<str>`.
+ Opening brace directly followed by parenthesis, string up until closing parenthesis = flags
+ `%q%q%q` == `%%qqq`

|----------------|--------------------------------------------------------------|
| `%`            | Expand *%*s in result as in prompts                          |
| `@`            | Array expand even in double quotes; *"${(@)path[1,2]}"*      |
| `A`            | Create array parameter with *${...=...}*                     |
| `a`            | Array index order, so `Oa` is reversed                       |
| `c`            | Count characters for *${#var}*                               |
| `C`            | Capitalize result                                            |
| `e`            | Do parameter, comand, arith expansion *${(e)$(<./file.txt)}* |
| `f`            | Split result to array on newlines                            |
| `F`            | Join arrays with newlines between elements                   |
| `i`            | *oi* or *Oi* sort case independently                         |
| `k`            | For associative array, result is keys                        |
| `L`            | Lower case result                                            |
| `n`            | *on* or *On* sort numerically                                |
| `o`            | Sort into ascending order                                    |
| `O`            | Sort into descending order                                   |
| `P`            | Interpret result as parameter name, get value                |
| `q`            | Quote result with backslashes                                |
| `qq`           | Quote result with single quotes                              |
| `qqq`          | Quote result with double quotes                              |
| `qqqq`         | Quote result with *$'...'*                                   |
| `Q`            | Strip quotes from result                                     |
| `t`            | Output type of variable (see below)                          |
| `u`            | Unique: remove duplicates after first                        |
| `U`            | Upper case result                                            |
| `v`            | Include value in result; may have *(kv)*                     |
| `V`            | Visible representation of special chars                      |
| `w`            | Count words with *${#var}*                                   |
| `W`            | Same but empty words count                                   |
| `X`            | Report parsing errors (normally ignored)                     |
| `z`            | Split to words using shell grammar                           |
| `p`            | Following forms recognize print *\­escpae*                   |
| `j:str:`       | Join words together with *str*                               |
| `sj:str:`      | Join words with *str* between                                |
| `l:x:`         | Pad with spaces on left to width *x*                         |
| `l:x::s1:`     | Same but pad with repeated *s1*                              |
| `l:x::s1::s2:` | Same but *s2* used once before any *s1s*                     |
| `r:x::s1::s2:` | Pad on right, otherwise same as *l* forms                    |
| `s:str:`       | Split to array on occurrences of str                         |
| `S`            | With patterns, search substrings                             |
| `I:exp:`       | With patterns, match expth occurrence                        |
| `B`            | With patterns, include match beginning                       |
| `E`            | With patterns, include match end                             |
| `M`            | With patterns, include matched portion                       |
| `N`            | With patterns, include length of match                       |
| `R`            | With patterns, include unmatched part (rest)                 |

## ==============================================================

### ORDER OF RULES

1. Nested substitution: from inside out
2. Subscripts: `${arr[3]}` extract word;
	+ `${str[2]}`extract character;
	+ `${arr[2,4]}`, `${str[4,8]}` extract range;
	+ `-1` is last word/char, `-2` previous etc.
3. `${(P)var}` replaces name with value
4. ` ̈$array ̈` joins array, may use `(j:str:)`
5. Nested subscript e.g. `${${var[2,4]}[1]}`
6. `#,` `%,` / etc. modifications
7. Join if not joined and `(j:str:)`, `(F)`
8. Split if `(s)`, `(z)`, `(z)`, =
9. Split if `SH_WORD_SPLIT`
10. Apply `(u)`
11. Apply `(o)`, `(O)`
12. Apply `(e)`
13. Apply `(l.str.)`, `(r.str.)`
14. If single word needed for context, join with `$IFS[1]`

## ==============================================================

## TESTS AND NUMERIC EXPRESSION

|------|---------------------------------------------------------|
| `-a` | True if file exists                                     |
| `-b` | True if file is block special                           |
| `-c` | True if file is character special                       |
| `-d` | True if fileis directory                                |
| `-e` | True if file exists                                     |
| `-f` | True if fileis a regular file (not special or directory |
| `-g` | True if filehas setgid bit set (mode includes 02000)    |
| `-h` | True if fileis symbolic link                            |
| `-k` | True if filehas sticky bit set (mode includes 02000)    |
| `-p` | True if fileis named pipe (FIFO)                        |
| `-r` | True if fileis readable by current process              |
| `-s` | True if filehas non­zero size                           |
| `-u` | True if filehas setuid bit set (mode includes 04000)    |
| `-w` | True if fileis writeable by current process             |
| `-x` | True if fileexecutable by current process               |
| `-L` | True if fileis symbolic link                            |
| `-O` | True if fileowned by effective UID of currentprocess    |
| `-G` | True if filehas effective GID of current process        |
| `-S` | True if fileis a socket (special communication file)    |
| `-N` | True if filehas access time no newer than mod time      |

|------|----------------------------------------------|
| `-n` | True if str has non­zero length              |
| `-o` | True if option str is set                    |
| `-t` | True if str (number) is open file descriptor |
| `-z` | True if str has zero length                  |

|-------|------------------------------------------------------|
| `-nt` | True if file a is newer than file b                  |
| `-ot` | True if file a is older than file b                  |
| `-ef` | True if a and b refer to same file (i.e. are linked) |
| `=`   | True if string a matches pattern b                   |
| `==`  | Same but more modern (and still not often used)      |
| `!=`  | True if string a does not match pattern b            |
| `<`   | True if string a sorts before string b               |
| `>`   | True if string a sorts after string b                |
| `-eq` | True if numerical expressions a and b are equal      |
| `-ne` | True if numerical expressions a and b are not equal  |
| `-lt` | True if *a < b* numerically                              |
| `-gt` | True if *a > b* numerically                              |
| `-le` | True if *a≤b* numerically                              |
| `-ge` | True if *a≥b* numerically                              |

### EVENT DESIGNATORS

|------------|-------------------------------------------------------------------------|
| `!`        | Start a history expansion, except follow by  blank, newline, ‘=’ or ‘(’ |
| `!!`       | Refer to the previous command                                           |
| `!n`       | Refer to command-line n.                                                |
| `!-n`      | Refer to the current command-line minus n.                              |
| `!str`     | Refer to the most recent command starting with str.                     |
| `!?str[?]` | Refer to the most recent command containing str                         |
| `!#`       | Refer to the current command line typed in so far                       |
| `!{...}`   | Insulate a history reference from adjacent characters                   |

## USING ARRAY FLAGS

### (P) FLAG

+ *(P)* = further expand variable

`for parameter in XDG_{DATA,CONFIG,CACHE}_HOME; {`
: `print "${parameter} -> ${(P)parameter}" }`
: use of *(P)* flag

### (S) FLAG

+ *(S)* = specify pattern to match substrings

`string='one/two/three/two/one'`
: `print ${(S)string#two}`
: use of *(S)* flag; returns *one//three/two/one*

### (M) FLAG

+ *(M)* = matching flag

`string='one/two/three/two/one'`
: `print ${(MS)string#/t*o/}`
: use of *(M)* flag = *(M)* atching *(S)* ubstring; */two/three/two*

+ *(w)* = index string by word index (start at 1)

`var='You can even get the word that comes last'`
: `print ${var[(w)-1]}`
: use of *(w)* flag = return *last*

## ==============================================================

### CHECK IF VALUE IS IN ARRAY

`if (( ${array[(I)asdf]} )); then`
: checks if *asdf* is in array

`${${(k)map}[(I)foo]}`
: does key exist

`array=(foo bar baz foo)``
: `value=foo`
: `search=("$value")`
: `(){print -r $# occurrence${2+s} of $value in array} "${(@)array:*search}"``
: how many times value found in array `${A:*B}` (elements in *A* also in *B*)

## ==============================================================

### BRACE EXPANSION

`print 'woah' {,}`
: woah woah

`print 'woah' {,,}`
: woah woah woah

`print {01..10}`
: 01 .. 10

`print {a..z..3}`
: a d g j m p s v y

## ==============================================================

### TERNARY OPERATOR

`(( a > b ? yes : no ))`
: has to be used in arith

`[[ 1 -eq 1 ]] && asdf || print "Not true"`
: third statement exec if error in second statement

`[[ 1 == 1 ]] && { asdf ;:; } || print "Not true"`
: workaround for above

## ==============================================================

### READ

`read -rs 'secret?Password:'`
: save results in *secret*

`text=$(<file.txt); lines=(${text// /\\ })`
: read each line into array

`text=$(<&0)`
: fast form read */dev/stdin*

`read -u 0 -d '' text`
: slow form read */dev/stdin*

### DISOWN

`disown %1`
: explicit

`%1&|`
: short syntax

## ==============================================================

## INDEX SLICING

`print ${val:0:3}`
: *first 3* numbers

`print ${val:5} # 56789`
: every number *after 5*

`print ${val:(-3)}`
: *last 3* numbers

`print ${val:2:(-3)}`
: everything but *first 2* and *last 3*

`print ${val:(-6):2}`
: print 2 numbers startng from *6th to last*

`print ${TWILIO_ACCOUNT_SID[-9,$]}`
: *last 9* of scalar type var

## ==============================================================

### SUBSTRING MATCHING

`string='one/two/three/four/five'`
: `print ${string#*/} # two/three/four/five`
: `print ${string##*/} # five`
: `print ${string%/*} # one/two/three/four`
: `print ${string%%/*} # one`
: *%%* = end of string; *##* = begin of string

## ==============================================================

### LENGTH OF A STRING

`checksum=${(s< >)$(shasum -a 256 file.txt)[1]}`
`print ${(N)checksum##*}`
: print length of string

## ==============================================================

### SPLITTING STRINGS

`var='Sentence one. Sentence two.'`
`print ${var[(w)4]}`
: returns *two.*

## ==============================================================

### GLOBAL SUBSTITUTION

`attitude="it is what it is"`
`print ${attitude:s/is/be}`
: use of *s/a/a*

`print ${attitude:gs/is/be}`
: global = use of *gs/a/a*

## ==============================================================

## REMOVING ELEMENT FROM ARRAY

`${array[3]}=()`
: remove index without leaving blank

`array[${array[(i)charlie]}]=()`
: removing it

`excluded=(${array:|filter})`
: newer: remove from array any element contained in filter

`included=(${array:*filter})`
: remove from array any element *not* contained in array filter

`output=(${array:#*w*})`
: remove from array any element that matches pattern

`output=(${(M)array:#*w*})`
: remove from array any element that doesn't match pattern

`print -- ${(M)${(@)${(f)${"$(whois ${ip})"}}}:#CIDR*}`
: remove any line from whos that doesn't start with 'CIDR'

### PRINT ARRAYS

`print ${(k)example:#foo*}`
: print all keys in AA that don't start with foo

`print ${(Mk)example:#foo*}`
: print all keys in AA that do start with foo

`print ${(v)example:#foo*}`
: print all values in AA that don't start with foo

`print ${(Mv)example:#foo*}`
: print all values in AA that do start with foo

`typeset -p1 my_pairs`
: pretty print key=value of AA

## ==============================================================

## GLOBBING QUALIFIERS

`print ./*(:a)`
: *(:a)* = return each glob abs path

`print ./*(:P)`
: *(:P)* = return each glob abs path, resolve symlinks

`print ~/Desktop/example(:A)`
: *(:A)* = return each glob abs path, try resolve sym, fall back abs file if sym not exist

`print ./*(:e)`
: *(:e)* = string all but extension

`print ./*(:r)`
: *(:r)* = string extension suffix

`print "${val} => ${val:t}"`
: *(:t)* = string all leading dir from filepath

`print "${val} => ${val:h}"`
: *(:h)* = string all trailing dir from filepath

`filename=${${(%):-%N}:A}`
: print absolute path of file currently being sourced

`filepath=${${(%):-%N}:A:h}`
: print abs path of dir containing file being sourced

## ==============================================================

## GLOBBING SPECIFIC FILETYPES

`print ./*(.); print ./**/*(.)`
: all plain files

`print ./*(^/); print ./**/*(^/)`
: anything but directories

`print ./*(/^F)`
: only empty directories

`print ./*(/OL:q)`
: all dir decending size, escaped

`print ./*(.DoL[-1])`
: *(L)* = sort by len, ascending order, pick last element

`print ./*(.DOL[1])`
: *(O)* = sort descending order, pick last element

`print ./*(.Lm-2)`
: select files larger 2MB in dir

`print ./*(.om[1])`
: most recent file in

| 'M' | for Months                       |
| 'w' | for weeks                        |
| 'h' | for hours                        |
| 'm' | for minutes                      |
| 's' | for seconds                      |
| '-' | modified less than *#* hours ago |
| '+' | modified more than *#* hours ago |

`print -l ./*(.mh-1)`
: example of above

`open ./path/to/dir/*(.c-2)`
: created in last 2 days

`folders=( /usr(/N) /bin(/N) /asdf(/N) )`
: *(N)* enable null glob; *(/)* only match an existing directory

`print -l ./*(e#'[[ ! -e $REPLY/tmp ]]'#)`
: *#* = delim b/w expansion and string

## ==============================================================

## CHECKING IF COMMAND EXISTS

`if [[ =brew ]]; then`
: *equals expansion* = check path for executable

`if (( ${+commands[brew]} )); then`
: *parameter expansion* = notice parenthesis

## ==============================================================

## COUNT THE NUMBER OF WORDS

`print ${#string} # => 13`
: *sentence="Hello world"*

`print ${(w)#string} # => 2`
: *sentence="Hello world"* - `(w)`

## ==============================================================

## READING WORDS

`words=($(<words.txt))`
: read words into array

`print ${(u)words[@]}`
: *(u)* = print unique words

`for word in ${(u)words}; do`
: `count+=("$(grep -c ${word} <<< "${(F)words}") ${word}")`
: `done`
: add "<#> <word>" to the array

## ==============================================================

## FILE DESCRIPTORS

`<&-`
: Close the standard input.

`1>&-`
: Close the standard output.

`2>&-`
: Close the standard error.

`<&p`
: Move the input from the coprocess to stdin

`>&p`
: Move the output from the coprocess to output

`2>&1`
: Redirect standard error to standard output

`1>&2`
: Redirect standard output to standard error

`&> file.txt`
: Redirect both standard output and standard error to file.txt

`exec 3> ~/three.txt`
: custom FD

## ==============================================================

## TYPESET

### FLAGS TO STATE VARIABLE TYPE

`-F [ name[=value] ... ]`
: declare variable name as floating point (decimal notation)

`-E [ name[=value] ... ]`
: declare variable name as floating point (scientific notation)

`-i [ name[=value] ... ]`
: declare variable name as an integer

`-a [ name[=value] ... ]`
: declare variable name as an array

`-A [ name[=value] ... ]`
: declare variable name as an associative array

### FLAGS TO STATE VARIABLE PROPERTIES

`typeset -r [ name[=value] ... ]`
: mark variable name as read-only

`typeset -x [ name[=value] ... ]`
: mark variable name as exported

`typeset -g [ name[=value] ... ]`
: mark variable name as global

`typeset -U [ name[=value] ... ]`
: convert array-type variable name such that it always contains unique-elements only

### FLAGS TO MODIFY COMMAND OUTPUT

`typeset -l [ name[=value] ... ]`
: print value of name in lower-case whenever expanded

`typeset -u [ name[=value] ... ]`
: print value of name in upper-case whenever expanded

`typeset -H [ name[=value] ... ]`
: suppress output for typeset name if variable name has already been assigned a value

`typeset -p [ name[=value] ... ]: print name in the form of a typeset command with an assignment, regardless of other flags and options. Note`
: the −H flag will still be respected; no value will be shown for these parameters.

`typeset -p1 [ name[=value] ... ]`
: print name in the form of a typeset command with an assignment, regardless of other flags and options.

### MATCHING A CERTAIN TYPE

`typeset +`
: All variables with their types

`typeset -E +`
: All variables that are floating point

`typeset USER`
: View the assignment of a variable

`typeset +m 'foo*'`
: print all env vars who match apttern


## ==============================================================

## ===============================================================

## ZINIT ZSH SCRIPTING GUIDE

### @ IS ABOUT KEEPING ARRAY FORM

Bash: `${array[@]}` -- ZSH: `$array`

`@`
: means *do not join* or *keep in array form*

`"$array"`
: quoting joins all elements into single string, adding *@* is to have elements still quoted (empty elements preserved) but not joined

### EXTENDED_GLOB

*#b* and *#m* require `setopt extended_glob`. Patterns utilizing `~` and `^` also require it.

## CONSTRUCTS

### READING A FILE

`declare -a lines; lines=( "${(@f)"$(<path/file)"}" )`
: Preserves empty lines because *double quoting* (outside one). The *@*-flag is used to obtain array instead of scalar. Not using *@* with not preserve empty lines.

`declare -a lines; lines=( ${(f)"$(<path/file)"} )`
: Note `$(<...)` construct strips trailing empty lines

### READING FROM STDIN

Instead of `"$(<file-path)"`, `$(command arg1 ...)` is used instead

`declare -a lines; lines=( ${(f)"$(command arg1 ...)"} )`
: Reads *command*'s output into array *lines*.

`declare -a lines; lines=( "${(f@)$(command arg1 ...)}" )`
: Instead of four double-quotes, an idiom that is justified that was previously used `... "${(@f)"$(<path/file)"}" ...)`, only *two* double-quotes are being used. Single outside quoting of `${(f@)...}` substitution works as if it as also separately applied to `$(command ...)` or to `$(<file-path)` inner substitution, so the second double quoting isn't needed.

### SKIPPING GREP

`declare -a lines; lines=( "${(@f)"$(<path/file)"}" )`
: ~

`declare -a grepped; grepped=( ${(M)lines:#*query*} )`
: To have `grep -v` affect, skip *M*-flag.

`...:#(#i)*query*}`
: To grep case insensitively, use *#i* glob flag

`${...:#...}`
: Filtering of array, which by default filters-out elements (*(M)* flag induces opposite behavior). When used with *string*, not array, it behaves similarly: returns empty string when `{input_string_var:#pattern}` matches whole input string.

*Side Note*:
: *(M)* flag can be also used with `${(M)var#pattern}` and other substitutions to retain what's matched by pattern, instead of removing it.

### MULTI-LINE MATCHING LIKE GREP

`[[ -n "$(echo "$(svn status)" | grep \^\?)" ]] && echo 'found'`
: bash style

`local svn_status="$(svn status)" nl=$'\n'`
: `[[ "$svn_status" = *((#s)|$nl)\?* ]] && echo 'found'`
: Just check if matched lines is greater than 0. The *(#s)* means **start of string**. So *((#s)|$n1)* means start of string OR **preceded** by new-line.

`local needle="?" required_preceding='[[:space:]]#'`
: `[[ "$(svn status)" = *((#s)|$nl)${~required_preceding}${needle}* ]] && echo found`
: Multi-line matching falls into this idiom. It does a single fork (calls `svn` status). The `${~variable}` means *the variable is holding a pattern, interpret it*. Instead of regex, we are using globs.

### PATTERN MATCHING IN AND-FASHION

`^, ~`
: negations

`${a[(R)*pat*]}`
: search hash

`[[ "abc xyz efg" = *abc*~^*efg* ]] && print Match found`
: The `~` is a negation -- `(match *abc* but not ...)`. Then `^` is also a negation. The effect is: `*abc* but not those that don't have *efg*`, which equals to `*abc* but those that also have *efg*`. This is a pattern that can be used with *:#* above to search arrays, or with *R*-subscript flag to search hashes (`${hsh[(R)*pattern*]}`)

### SKIPPING TR

`declare -A map; map=( a 1 b 2 );`
: `text=( "ab" "ba" )`
: `text=( ${text[@]//(#m)?/${map[$MATCH]}} )`
: `print $text ▶ 12 21`

`#m`
: Enables *$MATCH* parameter. At each `//` substitution, `$map` is queried for char-replacement. Can substitute a text variable too, just skip `[@]` and parenthesis in assignment.

### TERNARY EXPRESSIONS WITH +,-,:+,:- SUBSTITUTIONS

`HELP="yes"; print ${${HELP:+help enabled}:-help disabled} ▶ help enabled`
: `HELP=""; print ${${HELP:+help enabled}:-help disabled} ▶ help disabled`

`(( a = a > 0 ? b : c ))`
: Ternary only found directly in math context.
