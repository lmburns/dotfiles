# task -- taskwarrior, task manager
{:data-section="shell"}
{:data-date="April 01, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Add tasks on command line

## TOOLS

https://taskwarrior.org/tools/

## OPTIONS

`$ task next`
: list upcoming

`$ task add priority:H Pay bills`
: add task with priority

### CREATING TASKS

`$ task add Pay the rent due:eom`
: add reminder with due date

`$ task 12 modify due:eom`
: add due date later

`$ task 12 modify due:`
: remove due date

### FILTERS

`$ task entry.after:today-4days list`
: tasks added within 4 days

`$ task entry:yesterday list`
: tasks added yesterday

`$ task entry.after:now-1hour list`
: tasks added last hour

`$ task end.after:today-1wk completed`
: tasks completed in last week

`$ task project:This or project:That list`
: tasks in this or that project

`$ task project: list`
: search for tasks with no projects

`$ task rc.search.case.sensitive:yes /pattern/ list`
: search for pattern in description and annotation

### PROJECTS

`$ task add Rake the leaves project:'Home & Garden'`
: assign to long project name

`$ task project:OLDNAME modify project:NEWNAME`
: move to new project

`$ task project:OLDNAME and status:pending modify project:NEWNAME`
: move all pending tasks to new project

`$ task add project:Home.Kitchen Clean the floor`
: project hierarchy

`$ task projects | $ task _projects`
: show projects being used

`$ task rc.list.all.projects=1 projects`

`$ task rc.list.all.projects=1 _projects`

`$ task _unique projects`
: all tasks ever used

### TAGS

`$ task +home list`
: list tasks w/ specific tag

`$ task -home list`
: all tasks that don't have tag

`$ task tags.any: list | $ task +TAGGED list`
: tasks with any tag

`$ task tags.none: list`
: tasks with no tags

`$ task +this or +that list`
: either tag can use `xor`

`$ task tags`
: list tags

`$ task rc.list.all.tags=1 tags $ task _tags`
: all tasks ever used

### VIRTUAL TAGS

`$ task due.after:yesterday and due.before:tomorrow list | $ task +DUETODAY list`
: all tasks due today

`$ task +DUE -DUETODAY list`
: due but not today

`$ task +WEEK list`
: due this week

`$ task +OVERDUE list`
: overdue tasks

`$ task 1 info`
: virutal tags present for specific tag

### RECURRING TASKS

`$ task add Do the thing due:2015-06-08T09:00 recur:weekly`
: every monday starting monday at 9am

`$ task add Pay rent due:28th recur:monthly until:now+1yr`
: only for a year

### PRIORITY

`$ task config -- uda.priority.values H,M,,L`
: make priority `L` sort lower than no priority

`$ task config -- uda.priority.values OMG,DoIt,Meh,Phfh,Nope,`
: add priorities

`$ task 1 modify priority:`
: remove priority from task

### COLORS

`$ task color | $ task color legend`
: show colors

`$ task rc._forcecolor:on rc.defaultwidth:120 rc.detection:off ...`
: force color

### DOM

Addressing mechanism to provide access to all stored data, used in scripts.

`$ task _get 12.description`
: get description for task 12

`$ task _get 12.entry 12.modification`
: show creation timestamp and last modification for task 12

`$ task _get context.width context.height`
: dimensions of terminal window

`$ task add Pay the rent due:eom wait:due-4days`
: add task and set wait date to 4 days before due date

`$ task add Pay the rent due:eom wait:due-4days`
: add task and use same due data as task 12

`$ task _get 12.due.week`
: week number on which task 12 is due

### WAIT

`$ task add Send Alice a birthday card \`
: `due:2016-11-08 \`
: `scheduled:2016-11-04 \`
: `wait:november`
: only shows up wat wait day

`$ task waiting`
: shows the hidden tasks

### UNTIL

`$ task add Send Alice a birthday card \`
: `due:2016-11-08 \`
: `scheduled:due-4d \`
: `wait:due-7d \`
: `until:due+2d`
: task self descripts on until

### START

`$ task start`
: makes it *active*

### MISCELLANEOUS

`$ task newest rc.verbose=nothing limit:1 | cut -f1 -d' '`

`$ task rc.verbose=nothing rc.report.foo.columns:id rc.report.foo.sort:id- foo limit:1`
: most recent task id

`$ echo '{"description":"A new task"}' | task import -`
: minimu require

`$ task add A new task`
: same

### HELP

`$ tag _zshcommands`
: list all available commmands
