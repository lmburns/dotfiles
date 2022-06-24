# perl:getopts --
{:data-section="shell"}
{:data-date="May 08, 2021"}
{:data-extra="Um Pages"}

## OPTIONS

`verbose!`
: negatable options - can use *--verbose* or *--noverbose*

`verbose+`
: increments value

`tag=s`
: *=* = requires value; *s* = arbitrary string

`tag:s`
: value is optional

`library=s => \@libfiles`
: can have multiple options

`library=s@ => \$libfiles`
: alternate

`'fulltext' => \ my $fulltext,`
: boolean

`'year=i'   => \(my $year = year_now()),`
: functions

`GetOptions ("library=s" => \@libfiles);`
`@libfiles = split(/,/,join(',',@libfiles));`
: allows for comma separates

`'quiet'   => sub { $verbose = 0 });`
: use a subroutine

`optional values`
: *s*, *i*, *f*, none = *boolean*
