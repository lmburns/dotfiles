# git --
{:data-section="shell"}
{:data-date="May 23, 2021"}
{:data-extra="Um Pages"}

## STASH

`g stash list`
: list stashes -- *gss* -- *wfxr*

`g stash pop 0`
: use stash 0 and delete it

`g stash apply 0`
: use stash 0 but keep stash

`g stash show [-p]`
: summary of stash, *-p* to view full diff

`g stash -p`
: asks if you want to stash hunk

`g stash branch bname stash@{1}`
: create branch for stash

`g stash drop stash@{1}`
: no longer need stash delete it

`g stash clear`
: delete all stash

## BRANCH

`g branch bname`
: create branch

`g checkout -b bname`
: create branch and change

`g branch`
: show all branches (*-a* = all; *-r* = remote)

`g branch -m bname new_bname`
: rename branch

`g branch --merged`
: show all completely merged branches with curr branch

`g branch -d bname`
: *delete* merged branch; only possibly if not HEAD

`g branch -D bname`
: delete not merged branch

`g merge bname master`
: *merge* bname with master

`g checkout bname && g rebase master`
: *rebase* re-writes project history

`g checkout bname && g cherry-pick 08342af`
: *merge* only one commit -- *gcp* -- *wfxr*

## MERGE

`git reset --hard origin/master`
: undo local merge that hasn't been pushed yet

### MERGE VS REBASE

*Merge* is merging another branch **TO** your current branch (of course you can name both branches, but the default syntax is merge the branch to your current branch)
* So you should always switch to the main branch and merge others branch
* `git checkout master`
* `git merge their-branch --no-ff` or `git merge their-branch`

*Rebase* is rebasing your current branch **ON** another branch(usually the main branch)
* `git checkout feature-branch`
* `git rebase master`

## CHECKOUT

`g checkout -- filename`
: get file back

`g checkout <file>`
: *gcf* -- *wfxr*

`g checkout <branch`
: *gcb* -- *wfxr*

`g checkout <commit>`
: *gco* -- *wfxr*

`g switch -c <new-brach>`
: move changes to new branch

## FIXUP AND AUTOSQUASH

`g commit -a --fixup 981fffd`
: modify changes in commit and add as fixup commit

`g rebase --autosquash --interactive base.`
: clean up history

`g rebase --autosquash --interactive base`
: *gfu* -- *wfxr*

`g rebase -i`
: *grb* -- *wfxr*

## COMMITS

`g reset --soft HEAD~1`
: revert back a commit

## CLEAN

`g clean`
: remove untracked from repo

## PULL REQUEST

`g checkout -b bname`
: *(1)* create branch

`g remote add upstream original.url`
: *(2)* create remote upstream

`g csm 'message' && g push -u origin bname`
: *(3)* commit and push
