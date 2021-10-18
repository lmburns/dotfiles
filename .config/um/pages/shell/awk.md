# awk --
{:data-section="shell"}
{:data-date="March 10, 2021"}
{:data-extra="Um Pages"}

## PARAMS

+-----------------|------------------------------------------------------+
| Main Params     | What it is                                           |
+=================|======================================================+
| **$0**          | entire input record                                  |
| **NF**          | num of fields                                        |
| **$NF**         | last field                                           |
| **NR**          | contains record number (tot num lines seen)          |
| **-F**          | input field separator (command line)                 |
| **FS**          | input field separator (defualt whitespace)           |
| **RS**          | how awk breaks input into records (default newline)  |
| **RT**          | contain string matched by `RS` if regex is used      |
| **OFS**         | output field separator (default space)               |
| **ORS**         | output record separator (default newline)            |
| **NR**          | total num of records being processed or line number  |
| **NF**          | number of fields in a record                         |
| **FNR**         | line number per file (resets)                        |
| **FIELDWIDTHS** | set character number on output field width           |
| **FPAT**        | field pattern (define what fields should be made of) |
| **NR == FNR**   | only true while reading first file                   |
+-----------------|------------------------------------------------------+

+--------------------------------|--------------------------------------------------+
| Other Params                   | What it Does                                     |
+================================|==================================================+
| **ARGC**                       | num of pass parameters                           |
| **ARGV**                       | retrieves command line parameters                |
| **ENVIRON**                    | array of shell env variables                     |
| **FNR**                        | record which is processed                        |
| **IGNORECASE**                 | ignore character case                            |
| **INPLACE underscoere SUFFIX** | backup ininplace (**inplace::suffix**)           |
| **BEGINFILE**                  | beginning of file                                |
| **ENDFILE**                    | end of file                                      |
| **FILENAME**                   | filename                                         |
| **next**                       | skip rest lines & process next line of curr      |
| **nextfile**                   | skip remain lines of curr file & move on to next |
+--------------------------------|--------------------------------------------------+


+----------|--------------------------------------------------------------+
| Operator | What                                                         |
+==========|==============================================================+
| **@**    | save regex to variable                                       |
| **?**    | ternary operator select b/w 2 expressions based on condition |
+----------|--------------------------------------------------------------+
| Example  | `awk '{ORS = NR%3 ? "-" : "\n"} 1'`                          |
+----------|--------------------------------------------------------------+

## FUNCTIONS

+---------------------|----------------------------------------------------------------------+
| Commands            | Action                                                               |
+=====================|======================================================================+
| print()             | printing                                                             |
| printf()            | printing format                                                      |
| index(s,t)          | Position in string s where string t occurs, 0 if not found           |
| length(s)           | Length of string s (or $0 if no arg)                                 |
| rand                | Random number between 0 and 1                                        |
| substr(s,index,len) | Return len-char substring of s that begins at index (counted from 1) |
| srand               | Set seed for rand and return previous seed                           |
| int(x)              | Truncate x to integer value                                          |
+---------------------|----------------------------------------------------------------------+
| split(s,a,fs)       | Split string s into array a split by fs, returning length of a       |
| match(s,r)          | Position in string s where regex r occurs, or 0 if not found         |
| ~                   | match regex without typing out                                       |
| sub(r,t,s)          | sub t for 1st occurr of regex r in string s (or $0 if s not given)   |
| gsub(r,t,s)         | sub t for all occurr of regex r in string s                          |
+---------------------|----------------------------------------------------------------------+
| tolower(s)          | String s to lowercase                                                |
| toupper(s)          | String s to uppercase                                                |
| **system(cmd)**     | run system command                                                   |
| **getline**         | set $0 to next input record from curr input file                     |
+---------------------|----------------------------------------------------------------------+

## PRINTF FORMAT

+---------|-----------------------------+
| format | $1 printf(format, $1) |
+---------|------------|--------------+
| %c      | 97         | a            |
| %d      | 84.23      | 84           |
| %5d     | 84.23      | ___84        |
| %e      | 45.363     | 4.536300e+01 |
| %f      | 36.22      | 36.220000    |
| %7.2f   | 30.238     | __30.24      |
| %g      | 97.5       | 97.5         |
| %.6g    | 6.23972482 | 6.239725     |
| %o      | 97         | 141          |
| %06o    | 97         | 000141       |
| %x      | 97         | 61           |
| %s      | January    | January      |
| %10s    | January    | ___January   |
| %-10s   | January    | January___   |
| %.3s    | January    | Jan          |
| %10.3s  | January    | _______Jan   |
| %-10.3s | January    | Jan_______   |
| %%      | January    | %            |



## REGEX

|-------|-----------------------------------------|
| Set   |                                         |
|-------|-----------------------------------------|
| {m,n} | match m to n times                      |
| {m,}  | match at least m times                  |
| {,n}  | match up to n times (including 0 times) |
| {n}   | match exactly n times                   |
|-------|-----------------------------------------|

+------------|-----------------------------------+
| Named set  | Description                       |
+============|===================================+
| [:digit:]  | [0-9]                             |
| [:lower:]  | [a-z]                             |
| [:upper:]  | [A-Z]                             |
| [:alpha:]  | [a-zA-Z]                          |
| [:alnum:]  | [0-9a-zA-Z]                       |
| [:xdigit:] | [0-9a-fA-F]                       |
| [:cntrl:]  | control characters (DEL)          |
| [:punct:]  | all the punctuation characters    |
| [:graph:]  | [:alnum:] and [:punct:]           |
| [:print:]  | [:alnum:], [:punct:] and space    |
| [:blank:]  | space and tab characters          |
| [:space:]  | whitespace characters, same as \s |
+------------|-----------------------------------+

## ONE LINE EXERCISES


+----------------------------------------------|-------------------------------------------------+
| Command                                      | What it does                                    |
+==============================================|=================================================+
| awk 'NR!=1{print $1}' file                   | Print 1st field each record in file exclude 1st |
| awk 'END{print NR}' file                     | Count lines in file                             |
| awk '/foo/{n++}; END {print n+0}' file       | Print tot num lines contain foo                 |
| awk '{total=total+NF};END{print total}' file | Print tot num fields in all lines               |
| awk '/regex/{getline;print}' file            | line immed aft reg, not line contain regex      |
| awk 'length > 32' file                       | Print lines w/ more than 32 characters in file  |
| awk 'NR==12' file↵                           | Print line number 12 of file                    |
+----------------------------------------------|-------------------------------------------------+
