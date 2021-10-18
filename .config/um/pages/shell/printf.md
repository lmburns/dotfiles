# printf --
{:data-section="shell"}
{:data-date="March 18, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
print formatted characters

## EXAMPLES

|--------|----------------------------------------------------------------------|
| Format | What it does                                                         |
|--------|----------------------------------------------------------------------|
| %b     | argument while expanding backslash escape sequences                  |
| %q     | shell quoted, reusable as input                                      |
| %d, %i | signed decimal integer                                               |
| %u     | unsigned decimal integer                                             |
| %o     | unsigned octal integer                                               |
| %x, %X | unsigned hexadecimal integer (x=lower, X=upper)                      |
| %e, %E | floating point in exponential notation (e=lowercase, E=upper)        |
| %a, %A | floating point in hexadecimal fractional notation (a=lower, A=upper) |
| %g, %G | floating point in normal or exponential notation (g=lower, G=upper)  |
| %c     | single character                                                     |
| %f     | floating point number                                                |
| %s     | string                                                               |
| %%     | Print a literal % symbol                                             |
|--------|----------------------------------------------------------------------|

## ESCAPED CHARACTERS

|-----|---------------------------------|
| CMD | Escaped                         |
|-----|---------------------------------|
| \\\ | Displays a backslash character. |
| \b  | Displays a backspace character. |
| \n  | Displays a new line.            |
| \r  | Displays a carriage return.     |
| \t  | Displays a horizontal tab.      |
| \v  | Displays a vertical tab.        |
|-----|---------------------------------|
