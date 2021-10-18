# sed --
{:data-section="shell"}
{:data-date="March 10, 2021"}
{:data-extra="Um Pages"}

## OPTIONS

| Option | Description                             | Example                                      |
| ------ |---------------------------------------- | -------------------------------------------- |
| `-n`   | Suppress default pattern space printing | `sed -n '3 p' config.conf`                   |
| `-i`   | Backup and modify input file directly   | `sed -ibak 's/On/Off/' php.ini`              |
| `-f`   | Execute sed script file                 | `sed -f script.sed config.conf`              |
| `-e`   | Execute multiple sed commands           | `sed -e 'command1' -e 'command2' input-file` |

## Sed commands

| Command | Description                  | Example                                   |
| ------- |----------------------------- | ----------------------------------------- |
| `p`     | Print pattern space          | `sed -n '1,4 p' input.txt`                |
| `d`     | Delete lines                 | `sed -n '1,4 d' input.txt`                |
| `w`     | Write pattern space to file  | `sed -n '1,4 w output.txt' input.txt`     |
| `a`     | Append line after            | `sed '2 a new-line' input.txt`            |
| `a`     | Insert line before           | `sed '2 i new-line' input.txt`            |

## Sed substitute command and flags

```
 sed 's/original-string/replacement-string/[flags]' [input-file]
 ```

| Flag             | Description                                 | Example                                                |
| ---------------- |-------------------------------------------- | ------------------------------------------------------ |
| `g`              | Global substitution                         | `sed 's/development/production/g' .env`                |
| `1,2...`         | Substitute the nth occurrence               | `sed 's/latin1/utf8/2' locale.sql`                     |
| `p`              | Print only the substituted line             | `sed -n 's/error_log = 0/error_log = 1/p' php.ini`     |
| `w`              | Write only the substituted line to a file   | `sed -n 's/One/Two/w output.txt' words.txt`            |
| `i`              | Ignore case while searching                 | `sed 's/true/FALSE/i' config.php`                      |
| `e`              | Substitute and execute in the command line  | `sed 's/^/ls -l /e' files.list`                        |
| `/ | ^ @ !`      | Substitution delimiter can be any character | `sed 's|/usr/local/bin|/usr/bin|' paths.list`          |
| `&`              | Gets the matched pattern                    | `sed 's/^.*/<&>/' index.xml`                           |

 `( ) \1 \2 \3` - Group using `(` and `)`.
 : Use `\1`, `\2` in replacement to refer the group
 : `sed 's/([^,]*),([^,]*),([^,]*).*/\1,\3/g' words.txt`


## Loops and multi-line sed commands

| Command    | Description                                                        | Example                                         |
| ---------- |------------------------------------------------------------------- | ----------------------------------------------- |
| `b lablel` | Branch to a label (for looping)                                    |                                                 |
| `t lablel` | Branch to a label only on successful substitution<br>(for looping) |                                                 |
| `:lablel`  | Label for the b and t commands (for looping)                       |                                                 |
| `N`        | Append next line to pattern space                                  | `sed = file.txt | sed "N;s/\n/$(printf '\t')/"` |
| `P`        | Print 1st line in multi-line                                       |                                                 |
| `D`        | Delete 1st line in multi-line                                      |                                                 |

## Sed hold and pattern space commands

| Command | Description                                                  |
| ------- |------------------------------------------------------------- |
| `n`     | Print pattern space, empty pattern space, and read next line |
| `x`     | Swap pattern space with hold space                           |
| `h`     | Copy pattern space to hold space                             |
| `H`     | Append pattern space to hold space                           |
| `g`     | Copy hold space to pattern space                             |
| `G`     | Append hold space to pattern space                           |

## SED CHEATSHEET 2

|-------------------------|----------------------------------------------------------------|
| Note                    | Description                                                    |
|-------------------------|----------------------------------------------------------------|
| **ADDR cmd**            | Execute cmd only if input line satisfies the ADDR condition    |
|                         | ADDR can be REGEXP or line number or a combination of them     |
|-------------------------|----------------------------------------------------------------|
| **/at/d**               | delete all lines based on the given REGEXP                     |
|-------------------------|----------------------------------------------------------------|
| **/at/!d**              | don't delete lines matching the given REGEXP                   |
|-------------------------|----------------------------------------------------------------|
| **/twice/p**            | print all lines based on the given REGEXP                      |
|                         | as print is default action, usually p is paired with -n option |
|-------------------------|----------------------------------------------------------------|
| /not/ s/in/**/gp        | substitute only if line matches given REGEXP                   |
|                         | and print only if substitution succeeds                        |
|-------------------------|----------------------------------------------------------------|
| **/if/q**               | quit immediately after printing current pattern space          |
|                         | further input files, if any, won't be processed                |
|-------------------------|----------------------------------------------------------------|
| **/if/Q**               | quit immediately without printing current pattern space        |
|-------------------------|----------------------------------------------------------------|
| **/at/q2**              | both q and Q can additionally use 0-255 as exit code           |
|-------------------------|----------------------------------------------------------------|
| **-e 'cmd1' -e 'cmd2'** | execute multiple commands one after the other                  |
|-------------------------|----------------------------------------------------------------|
| **cmd1; cmd2**          | execute multiple commands one after the other                  |
|                         | note that not all commands can be constructed this way         |
|                         | commands can also be separated by literal newline character    |
|-------------------------|----------------------------------------------------------------|
| **ADDR {cmds}**         | group one or more commands to be executed for given ADDR       |
|                         | groups can be nested as well                                   |
|                         | ex: /in/{/not/{/you/p}} conditional AND of 3 REGEXPs           |
|-------------------------|----------------------------------------------------------------|
| **2p**                  | line addressing, print only 2nd line                           |
|-------------------------|----------------------------------------------------------------|
| **$**                   | special address to indicate last line of input                 |
|-------------------------|----------------------------------------------------------------|
| **2452{p; q}**          | quit early to avoid processing unnecessary lines               |
|-------------------------|----------------------------------------------------------------|
| **/not/=**              | print line number instead of matching line                     |
|-------------------------|----------------------------------------------------------------|
| **ADDR1,ADDR2**         | start and end addresses to operate upon                        |
|                         | if ADDR2 doesn't match, lines till end of file gets processed  |
|-------------------------|----------------------------------------------------------------|
| **/are/,/by/p**         | print all groups of line matching the REGEXPs                  |
|-------------------------|----------------------------------------------------------------|
| **3,8d**                | delete lines numbered 3 to 8                                   |
|-------------------------|----------------------------------------------------------------|
| **5,/use/p**            | line number and REGEXP can be mixed                            |
|-------------------------|----------------------------------------------------------------|
| **0,/not/p**            | inefficient equivalent of /not/q but works for multiple files  |
|-------------------------|----------------------------------------------------------------|
| **ADDR,+N**             | all lines matching the ADDR and N lines after                  |
|-------------------------|----------------------------------------------------------------|
| **i~j**                 | arithmetic progression with i as start and j as step           |
|-------------------------|----------------------------------------------------------------|
| **ADDR,~j**             | closest multiple of j w.r.t. line matching the ADDR            |
|-------------------------|----------------------------------------------------------------|
| **pattern space**       | active data buffer, commands work on this content              |
|-------------------------|----------------------------------------------------------------|
| **n**                   | if -n option isn't used, pattern space gets printed            |
|                         | and then pattern space is replaced with the next line of input |
|                         | exit without executing other commands if there's no more input |
|-------------------------|----------------------------------------------------------------|
| **N**                   | add newline (or NUL for -z) to the pattern space               |
|                         | and then append next line of input                             |
|                         | exit without executing other commands if there's no more input |
|-------------------------|----------------------------------------------------------------|


## EXAMPLES

### PRINT
Printing is default action if `-n` is not used

|----------------------------|------------------------------|
| `sed -n '/so are/p'`       | same as grep                 |
|----------------------------|------------------------------|
| `sed -n '/are/ s/so/SO/p'` | combine substitution / print |
|----------------------------|------------------------------|
| `sed 'p'`                  | duplicate every line         |
|----------------------------|------------------------------|

### DELETE

|------------------|-----------------------------------------|
| `sed '/are/d'`   | delete (not print lines containing are) |
|------------------|-----------------------------------------|
| `sed '/rose/Id'` | modifier `I` is case insensitive        |
|------------------|-----------------------------------------|

### QUIT

|------------|--------------------------------------------|
| `sed '5q'` | no further processing, 5 is line number    |
|------------|--------------------------------------------|
| `sed '5Q'` | same as `q` but doen't print matching line |
|------------|--------------------------------------------|

### NEGATING

|---------------------|-------------------|
| `sed '/so are/!d'`  | `sed '/so are/p'` |
|---------------------|-------------------|
| `send -n '/are/!p'` | `sed /are/d`      |
|---------------------|-------------------|

### MULTIPLE COMMANDS

|-----------------------------------|----------------------------|
| `sed -n -e '/blue/p' -e '/you/p'` | `sed -n '/blue/p; /you/p'` |
|-----------------------------------|----------------------------|

### LOGICAL AND = {}

|----------------------------|-------------------------|-----------------|
| `sed -n '/are/ {/And/p}'`  | `grep 'are' poem.txt    | grep 'And'`     |
|----------------------------|-------------------------|-----------------|
| `sed -n '/are/ {/so/!p}'`  | `grep 'are' poem.txt    | grep -v 'so'`   |
|----------------------------|-------------------------|-----------------|
| `sed -n '/red/!{/blue/!p}` | `grep -v 'red' poem.txt | grep -v 'blue'` |
|----------------------------|-------------------------|-----------------|
