# tig --
{:data-section="shell"}
{:data-date="June 13, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Text mod git interface

## BROWSING STATE VARIABLES

`%(head)`
: The currently viewed head ID. Defaults to HEAD

`%(commit)`
: The currently selected commit ID.

`%(blob)`
: The currently selected blob ID.

`%(branch)`
: The currently selected branch name.

`%(remote)`
: The currently selected remote name. For remote branches %(branch) will contain the branch name.

`%(tag)`
: The currently selected tag name.

`%(stash)`
: The currently selected stash name.

`%(directory)`
: The current directory path in the tree view or "." if undefined.

`%(file)`
: The currently selected file.

`%(lineno)`
: The currently selected line number. Defaults to 0.

`%(ref)`
: The reference given to blame or HEAD if undefined.

`%(revargs)`
: The revision arguments passed on the command line.

`%(fileargs)`
: The file arguments passed on the command line.

`%(cmdlineargs)`
: All other options passed on the command line.

`%(diffargs)`
: Options from diff-options or TIG_DIFF_OPTS used by the diff and stage view.

`%(blameargs)`
: Options from blame-options used by the blame view.

`%(logargs)`
: Options from log-options used by the log view.

`%(mainargs)`
: Options from main-options used by the main view.

`%(prompt)`
: Prompt for the argument value. Optionally specify a custom prompt using "%(prompt Enter branch name: )"

`%(text)`
: The text of the currently selected line.

`%(repo:head)`
: The name of the checked out branch, e.g. master

`%(repo:head-id)`
: The commit ID of the checked out branch.

`%(repo:remote)`
: The remote associated with the checked out branch, e.g. origin/master.

`%(repo:cdup)`
: The path to change directory to the repository root, e.g. ../

`%(repo:prefix)`
: The path prefix of the current work directory, e.g subdir/.

`%(repo:git-dir)`
: The path to the Git directory, e.g. /src/repo/.git.

`%(repo:is-inside-work-tree)`
: Whether Tig is running inside a work tree, either true or false.

### EXAMPLE USER DEFINED COMMANDS

`bind generic + !git commit --amend`
: Allow to amend the last commit:

`bind generic 9 !@sh -c "echo -n %(commit) | xclip -selection c"`
: Copy commit ID to clipboard:

`bind generic T !git notes edit %(commit)`
: Add/edit notes for the current commit used during a review:

`bind generic I !git add -i %(file)`
: Enter Git’s interactive add for fine-grained staging of file content:

`bind refs 3 !git rebase -i %(branch)`
: Rebase current branch on top of the selected branch:
