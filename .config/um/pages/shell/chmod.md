# chmod --
{:data-section="shell"}
{:data-date="March 26, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Change permissions

## OPTIONS

|-----|-------|---------------------------------------------|
| `0` | `000` | none                                        |
|-----|-------|---------------------------------------------|
| `1` | `001` | execute only                                |
|-----|-------|---------------------------------------------|
| `2` | `010` | write only                                  |
|-----|-------|---------------------------------------------|
| `3` | `011` | write and execute                           |
|-----|-------|---------------------------------------------|
| `4` | `100` | read only                                   |
|-----|-------|---------------------------------------------|
| `5` | `101` | read and execute                            |
|-----|-------|---------------------------------------------|
| `6` | `110` | read and write                              |
|-----|-------|---------------------------------------------|
| `7` | `111` | read, write, and execute (full permissions) |
|-----|-------|---------------------------------------------|

`chmod u=rwx,g=rx,o=r myfile`
: *u* = user; *g* = group; *o* = other; *a* = all
: *+* = add perm; *-* = sub perm; *=* = assign perm

`chmod u+s comphope.txt`
: set 'set user id' bit so anyone who access file does so if they're owner
: same as *chmod 4755*

`chmod u-s comphope.txt`
: opposite of above

`chmod 666 == chmod a=rw`
: are equivalent

`chmod u+x filename`
: change executable for user

`chmod u+r,g+x filename`
: add multiple permissions

`chmod --reference=file1 file2`
: change permission based on another file

`chmod u+X *`
: change execute perm only on directories

`chmod ug+x *`
: assign execute perm to user and group

`chmod go+r`
: assign read to group and others

`chmod u+rwx ,g+rw,o+r  file`
: example
