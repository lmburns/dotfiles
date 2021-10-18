# watchexec --
{:data-section="shell"}
{:data-date="June 02, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Watch files, execute command

## EXAMPLES

`$ watchexec --exts js,css,html make`
: watch all js,csshtml files and run make

`$ watchexec -i target make test`
: run make test when any file except those under target

`$ watchexec -- ls -la`
: when any file changes

`$ watchexec -e py -r python server.py`
: restart python server when any python file changes

`$ watchexec -r -s SIGKILL my_server`
: restart myserver when any file changes sending SIGKILL

`$ watchexec -n -s SIGHUP my_server`
: send SIGHUP (*-n* executes directly instead of wrapping in shell)

`$ watchexec make`
: run make when any file changes (using *.gitignore*)

`$ watchexec -w lib -w src make`
: run make when any file in *lib* or *src* changes

`$ watchexec -w Gemfile bundle install`
: *bundle install* when *Gemfile* changes

`$ watchexec 'date; make'`
: run two commands

`$ watchexec -n -- echo ';' lorem ipsum`
: *-n* or *--shell=none* to not run in shell
