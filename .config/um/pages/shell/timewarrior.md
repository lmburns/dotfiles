# timewarrior --
{:data-section="shell"}
{:data-date="May 28, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Track time

## OPTIONS

`start`
: start task

`continue`
: continue task

`start 'Using Tags' Software`
: use two tags

`summary <tag>`
: summary of tags

`tags`
: show all tags

`help continue`
: help with cmd

`track 9:00 - 11:00 'outline tutorial'`
: add time post facto

`track 9am for 2hr 'outline'`
: alt

`track 9am to 11am 'outline'`
: alt

### HINTS

`:quiet`
: suppress

`:yes`
: confirmation

`:yesterday`
: shortcut

`:lastweek`
: tag

### CHARTS

`summary yesterday - now`

`day`
: chart

`week`
: chart

## DESCRIPTION
Example taken from github

* `alias tw=timew`

* `alias tws='timew summary'`
* `alias twsi='timew summary :ids'`
* `alias twsy='timew summary :yesterday'`
* `alias twsw='timew summary :week'`
* `alias twds='timew day summary'`
* `alias twws='timew week summary'`
* `alias twms='timew month summary'`

* `alias twa='timew start'`
* `alias two='timew stop'`
* `alias twc='timew continue'`
* `alias twt='timew track'`
* `alias twl='timew lengthen'`
* `alias twsh='timew shorten'`
* `alias twm='timew modify'`
* `alias twma='timew modify start'`
* `alias twmo='timew modify end'`
* `alias twrs='timew resize'`
* `alias twz='timew undo'`
* `alias twd='timew delete'`

# twct == timewarrior change tag
function twct(){
    ITEMS=()
    TAGS=()
    for a in "$@"; do
        case $a in
            @*)
                ITEMS+=("$a")
                ;;
            *)
                TAGS+=("$a")
                ;;
        esac
    done

    if [ $#TAGS -ne 2 ]; then
        echo 'Too few or too many tags'
        return
    fi
    if [ $#ITEMS -lt 1 ]; then
        echo 'To few ids'
        return
    fi

    for item in "$ITEMS"; do
        timew untag $item $TAGS[1]
        timew tag $item $TAGS[-1]
    done
    timew summary
}
