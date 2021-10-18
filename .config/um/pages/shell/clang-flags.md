# clang-flags --
{:data-section="shell"}
{:data-date="May 23, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
List of Clang flags for compilation

## OPTIONS

`-Wall -Wextra -Wshadow`
: *warning flags* = more verbosity

`-Werror`
: turn on any warning to compilation error

`-Wextra or -W`
: enable extra flags not enabled by *-Wall*

`-std=c11`
: set the version

`-o file`
: output executable

`-O3`
: optimiation level

`-Og`
: optimize for debugging

`-l[linalg]`
: link to shared libraries

`-L[/path/to/shared-libraries]`
: add search patch to shared librarys `(*.so *.dll *dll *.dylib)`

`-I[path/to/header-files]`
: add search path to header `(*.h *.hpp)`
