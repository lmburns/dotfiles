# fclones --
{:data-section="shell"}
{:data-date="May 28, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Fast file finder

## EXAMPLES

### USAGE

`group`
: identifies groups of identical files and prints them to the standard output

`remove`
: removes redundant files earlier identified by group

`link`
: replaces redundant files with links (default: hard links)


### DEMO

`$ fclones group . >dupes.txt`
: identify duplicates

`$ fclones link --soft <dupes.txt`
: replace duplicates with softlinks

### FINDING FILES

`fclones group .`
: all

`fclones group . --unique`
: unique

`fclones group . --rf-under 3`
: replicated under 3

`fclones group . --rf-over 3`
: replicated over 3

`fclones group . --depth 1`
: current dir

### FILTERING

`fclones group . -s 100M`
: at least 100M

`fclones group . --names '*.jpg' '*.png'`
: name or pattern

`find . -name '*.c' | fclones --stdin --depth 0`
: piping

`fclones group . -L --paths '/home/**'`
: follow symlink

`fclones group / --exclude '/dev/**' '/proc/**'`
: exclude

`fclones group . --names '*.jpg' --caseless --transform 'exiv2 -d a $IN' --in-place`
: strip exif before matching duplicate jpg

### REMOVING FILES

* Send `fclones group` to `fclones remove` or `fclones link`

`fclones link <dupes.txt`
: replace with hard links

`fclones link -s <dupes.txt`
: replace with soft links

`fclones remove <dupes.txt`
: remove totally

`fclones group . | fclones link`
: do it in one go

`fclones remove -n 2 <dupes.txt`
: number of files to leave

### ORDER OF FILES

`fclones remove --priority newest <dupes.txt`
: remove the newest replicas

`fclones remove --priority oldest <dupes.txt`
: remove the oldest replicas

### RESTRICT REMOVING TO A PATH OR NAMES

`fclones remove --name '*.jpg' <dupes.txt`
: remove only jpg files

`fclones remove --path '/trash/**' <dupes.txt`
: remove only files in the /trash folder

Easier to specify pattern for files which you do not want to remove

`fclones remove --keep-name '*.mov' <dupes.txt`
: never remove mov files

`fclones remove --keep-path '/important/**' <dupes.txt`
: never remove files in the /important folder

### DRY RUN

`fclones link --soft <dupes.txt --dry-run 2>/dev/null`
: prints commands that would be executed

### PREPROCESSING FILES

`fclones group . --name '*.jpg' --caseless --transform 'exiv2 -d a $IN' --in-place`
: specify external command
