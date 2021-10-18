# zsh_completions --
{:data-section="shell"}
{:data-date="July 01, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
ZSH Completions

## ACTIONS

`( )`
: Argument is required but no matches are generated for it.

`(ITEM1 ITEM2)`
: List of possible matches

`((ITEM1\:’DESC1’ ITEM2\:’DESC2’))`
: List of possible matches, with descriptions. Make sure to use different quotes than those around the whole specification.

`->STRING`
: Set *$state* to STRING and continue (*$state* can be checked in a case statement after the utility function call)

`FUNCTION`
: Name of a function to call for generating matches or performing some other action, e.g. `_files` or `_message`

`{EVAL-STRING}`
: Evaluate string as shell code to generate matches. This can be used to call a utility function with arguments, e.g. `_values` or `_describe`

`=ACTION`
: Inserts a dummy word into completion command line without changing the point at which completion takes place.
