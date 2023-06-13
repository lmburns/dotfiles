{:data-date="February 14, 2022"}
{:data-extra="Um Pages"}

## SYNOPSIS
Cheatsheet for quick Zsh flags. Found in completions

## EXPANSION

`%`
: expand prompt sequences OR expand prompts respecting options

`#`
: evaluate as numeric expression

`@`
: prevent double-quoted joining of arrays

`A`
: assign as an array parameter

`a`
: sort in array index order (with `O` to reverse)

`b`
: backslash quote pattern characters only

`c`
: count characters in an array (with `\${(c)#...}`)

`C`
: capitalize words

`D`
: perform directory name abbreviation

`e`
: perform single-word shell expansions

`f`
: split the result on newlines

`F`
: join arrays with newlines

`g`
: process echo array sequences (needs options)

`i`
: sort case-insensitively

`k`
: substitute keys of associative arrays

`L`
: lower case all letters

`n`
: sort decimal integers numerically

`o`
: sort in ascending order (lexically if no other sort option)

`O`
: sort in descending order (lexically if no other sort option)

`P`
: use parameter value as name of parameter for redirected lookup

`t`
: substitute type of parameter

`u`
: substitute first occurrence of each unique word

`U`
: upper case all letters

`v`
: substitute values of associative arrays (with (`k`))

`V`
: visibility enhancements for special characters

`w`
: count words in array or string (with `\${(w)#...}`)

`W`
: count words including empty words (with `\${(W)#...}`)

`X`
: report parsing errors and eXit substitution

`z`
: split words as if zsh command line

`0`
: split words on null bytes

`p`
: handle print escapes or variables in parameter flag arguments

`~`
 :treat strings in parameter flag arguments as patterns

`j`
: join arrays with specified string

`l`
: left-pad resulting words

`r`
: right-pad resulting words

`s`
: split words on specified string

`Z`
: split words as if zsh command line (with options)

# `_`
: extended flags, for future expansion

`S`
: match non-greedy in */*, *//* or search substrings in *%* and *#* expressions

`I`
: search *<argument>th* match in *#,* *%,* */* expressions

`B`
: include index of beginning of match in *#*, *%* expressions

`E`
: include index of one past end of match in *#*, *%* expressions

`M`
: include matched portion in *#*, *%* expressions

`N`
: include length of match in *#*, *%* expressions

`R`
: include rest (unmatched portion) in *#*, *%* expressions

`q`
: quote with backslashes

`qq`
: quote with single quotes

`q-`
: quote minimally for readability

`q+`
: quote like `q-`, plus `\$'...'` for unprintable characters

`qqq`
: quote with double quotes

`qqqq`
: quote with `\$'...'`

`Q`
: remove one level of quoting

`m`
: count multibyte width in padding calculation

`m`
: count number of character code points in padding calculation

## AFTER OPERATOR

`:-`
: substitute alternate value if parameter is null

`:+`
: substitute alternate value if parameter is non-null

`:=`
: substitute and assign alternate value if parameter is null

`::=`
: unconditionally assign value to parameter

`:?`
: print error if parameter is null

`:#`
: filter value matching pattern

`:/`
: replace whole word matching pattern

`:|`
: set difference

`:*`
: set intersection

`:^`
: zip arrays

`:^^`
: zip arrays reusing values from shorter array
