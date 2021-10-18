# choose --
{:data-section="shell"}
{:data-date="May 28, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Rust alternative to cut

## OPTIONS

`choose 5`
: print the 5th item from a line (zero indexed)

`choose -f ':' 0 3 5`
: print the 0th, 3rd, and 5th item from a line, where items are separated by ':' instead of whitespace

`choose 2:5`
: print everything from the 2nd to 5th item on the line, inclusive of the 5th

`choose -x 2:5`
: print everything from the 2nd to 5th item on the line, exclusive of the 5th

`choose :3`
: print the beginning of the line to the 3rd item

`choose -x :3`
: print the beginning of the line to the 3rd item, exclusive

`choose 3:`
: print the third item to the end of the line

`choose -1`
: print the last item from a line

`choose -3:-1`
: print the last three items from a line
