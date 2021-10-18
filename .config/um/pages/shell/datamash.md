# datamash --
{:data-section="shell"}
{:data-date="June 03, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
GNU datamash is command-line program which performs simple calculation (e.g. count, sum, min, max, mean, stdev, string coalescing) on input files.

## OPTIONS

`-W`
: use multiple whitespace as field delimiter

`-t`,`--field-separator`
: specify field sep

## EXAMPLES

`$ datamash -H mean 1 q1 1 median 1 q3 1 iqr 1 sstdev 1 jarque 1 < FILE.TXT`
: *q1* = 1st quartile; *sstdev* = simple std; *jarque* = p-value of Jarque test for norm dist

### TEST SCORES

`$ cat scores.txt`
: Shawn     Arts  65
: Marques   Arts  58
: Fernando  Arts  78
: Paul      Arts  63
: Walter    Arts  75

`$ datamash -g 2 min 3 max 3 < scores.txt`
: Arts            46  88
: Business        79  94
: Health-Medicine 72  100
: Social-Sciences 27  90
: Life-Sciences   14  91
: Engineering     39  99

`$ datamash -g 2 mean 3 sstdev 3 < scores.txt`
: Arts             68.9474  10.4215
: Business         87.3636  5.18214
: Health-Medicine  90.6154  9.22441
: Social-Sciences  60.2667  17.2273
: Life-Sciences    55.3333  20.606
: Engineering      66.5385  19.8814

### HEADER LINES

`--header-out`
: add header line to output (when input doesn't have one)

`$ datamash --header-out -g 2 count 3 mean 3 pstdev 3 < scores.txt`
: GroupBy(field-2)    mean(field-3)  sstdev(field-3)
: Arts                68.9474        10.4215
: Business            87.3636        5.18214
: Health-Medicine     90.6154        9.22441
: Social-Sciences     60.2667        17.2273
: Life-Sciences       55.3333        20.606
: Engineering         66.5385        19.8814

`-H (equivalent to --header-in --header-out)`
: to use input headers and print output headers:

`$ datamash -H -g 2 count 3 mean 3 pstdev 3 < scores_h.txt`
: GroupBy(Major)      mean(Score)    sstdev(Score)
: Arts                68.9474        10.4215
: Business            87.3636        5.18214
: Health-Medicine     90.6154        9.22441
: Social-Sciences     60.2667        17.2273
: Life-Sciences       55.3333        20.606
: Engineering         66.5385        19.8814

### FIND NUMBER OF ISOFORMS PER GENE
