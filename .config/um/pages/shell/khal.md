# khal --
{:data-section="shell"}
{:data-date="June 11, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS

Calendar

## EXAMPLES

### NEW

`khal new [-a CALENDAR] [OPTIONS] [START [END | DELTA] [TIMEZONE] SUMMARY [:: DESCRIPTION]]`
: create new

`khal new 18:00 Awesome Event`
: add event starting today

`khal new tomorrow 16:30 Coffee Break`
: starting tomorrow

`khal new 25.10. 18:00 24:00 Another Event :: with Alice and Bob`
: lasting from 18-24 with description

`khal new -a work 26.07. Great Event -g meeting -r weekly`
: all day on 26th to work call in meeting category recurring weekly

### CALENDAR

`khal calendar [-a CALENDAR ... | -d CALENDAR ...] [START DATETIME] [END DATETIME]`
: show calendar

### EDIT

`khal edit [--show-past] event_search_string`
: edit interactively

### SEARCH

`khal search party`
: search all matching party

### IMPORT

`khal import [-a CALENDAR] [--batch] [--random-uid|-r] ICSFILE`

`configure`

`printformats`
: print fixed dates

`printcalendars`
: print all cals
