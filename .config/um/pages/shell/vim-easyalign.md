# vim-easyalign --
{:data-section="shell"}
{:data-date="May 18, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
vim

## OPTIONS

|--------------|-------------------------------------|---------------------|
| Keystrokes   | Description                         | Equivalent command  |
|--------------|-------------------------------------|---------------------|
| `<Space>`    | Around 1st whitespaces              | :'<,'>EasyAlign\    |
| --------     | -----------------------             | :'<,'>EasyAlign\    |
| `2<Space>`   | Around 2nd whitespaces              | :'<,'>EasyAlign2\   |
| ---------    | -----------------------             | :'<,'>EasyAlign2\   |
| `-<Space>`   | Around the last whitespaces         | :'<,'>EasyAlign-\   |
| ---------    | ----------------------------        | :'<,'>EasyAlign-\   |
| `-2<Space>`  | Around the 2nd to last whitespaces  | :'<,'>EasyAlign-2\  |
| ----------   | ----------------------------------- | :'<,'>EasyAlign-2\  |
| `:`          | Around 1st colon (key: value)       | :'<,'>EasyAlign:    |
|--------------|-------------------------------------|---------------------|
| `<Right>:`   | Around 1st colon (key : value)      | :'<,'>EasyAlign:>l1 |
|--------------|-------------------------------------|---------------------|
| `=`          | Around 1st operators with =         | :'<,'>EasyAlign=    |
|--------------|-------------------------------------|---------------------|
| `3=`         | Around 3rd operators with =         | :'<,'>EasyAlign3=   |
|--------------|-------------------------------------|---------------------|
| `*=`         | Around all operators with =         | :'<,'>EasyAlign*=   |
|--------------|-------------------------------------|---------------------|
| `**=`        | Left-right alternating around =     | :'<,'>EasyAlign**=  |
|--------------|-------------------------------------|---------------------|
| `<Enter>=`   | Right alignment around 1st =        | :'<,'>EasyAlign!=   |
|--------------|-------------------------------------|---------------------|
| `<Enter>**=` | Right-left alternating around =     | :'<,'>EasyAlign!**= |


`l4`
: lN - left_margin

`r1`
: rN - right_margin -- spaces to the left/right of `|`

`ar`
: *a[lrc]* - align -- align left/right/center

`dr`
: *d[lrc]* - delimiter_align -- alignment of the delimiter itself
