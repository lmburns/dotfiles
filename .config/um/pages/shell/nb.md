# nb --
{:data-section="shell"}
{:data-date="June 07, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Notebook / note taking

## SUBCOMMANDS

`(default)`
: List notes and notebooks. This is an alias for `nb ls`.; When a <url> is provided, create a new bookmark.

`add`
: Add a note, folder, or file.

`archive`
: Archive the current or specified notebook.

`bookmark`
: Add, open, list, and search bookmarks.

`browse`
: Browse and manage linked items in terminal and GUI browsers.

`completions`
: Install and uninstall completion scripts.

`count`
: Print the number of items in a notebook or folder.

`delete`
: Delete a note.

`edit`
: Edit a note.

`export`
: Export a note to a variety of different formats.

`git`
: Run `git` commands within the current notebook.

`help`
: View help information for the program or a subcommand.

`history`
: View git history for the current notebook or a note.

`import`
: Import a file into the current notebook.

`init`
: Initialize the first notebook.

`list`
: List notes in the current notebook.

`ls`
: List notebooks and notes in the current notebook.

`move`
: Move or rename a note.

`notebooks`
: Manage notebooks.

`open`
: Open a bookmarked web page or notebook folder, or edit a note.

`peek`
: View a note, bookmarked web page, or notebook in the terminal.

`pin`
: Pin an item so it appears first in lists.

`plugins`
: Install and uninstall plugins and themes.

`remote`
: Configure the remote URL and branch for the notebook.

`run`
: Run shell commands within the current notebook.

`search`
: Search notes.

`settings`
: Edit configuration settings.

`shell`
: Start the `nb` interactive shell.

`show`
: Show a note or notebook.

`status`
: Print notebook status information.

`subcommands`
: List, add, alias, and describe subcommands.

`sync`
: Sync local notebook with the remote repository.

`unarchive`
: Unarchive the current or specified notebook.

`unset`
: Return a setting to its default value.

`unpin`
: Unpin a pinned item.

`update`
: Update `nb` to the latest version.

`use`
: Switch to a notebook.

`version`
: Display version information.

## EXAMPLES AND USAGE

## NB ADD

`$ nb a`
: *alias*

`$ nb +`
: *alias*

`$ nb create`
: *alias*

`$ nb new`
: *alias*

`$ nb add`
: create a new note in your text editor

`$ nb add example.md`
: create a new note with the filename "example.md"

`$ nb add "This is a note."`
: create a new note containing "This is a note."

`$ echo "Note content." | nb add`
: create a new note with piped content

`$ nb add --title "Secret Document" --encrypt`
: create a new password-protected, encrypted note titled "Secret Document"

`$ nb example:add "This is a note."`
: create a new note in the notebook named "example"

`$ nb add sample/`
: create a new note in the folder named "sample"

`$ nb add "This is a note."`
: add note with content

`$ nb add --content "Note content."`
: add note with content

`$ nb add example.md`
: add note file

`$ pbpaste | nb add`
: create note with *pbpaste*

`$ nb add --filename "example.md" -t "Example Title" -c "Example content."`
: add with options

`$ nb add "Example content." --title "Tagged Example" --tags tag1,tag2`
: add with options

`$ nb add example.org`
: open a new *Org* file in the editor

`$ nb add --type rst`
: open a new *reStructuredText* file in the editor

`$ nb add .js`
: open a new *JavaScript* file in the editor

`$ nb .. -e`
: encryption with pgp

### SAVE CODE SNIPPETS

`$ pb | nb add .js`
: save the clipboard contents as a JavaScript file in the current notebook

`$ pb | nb a rust: .rs`
: save the clipboard contents as a Rust file in the "rust" notebook
: using the shortcut alias `nb a`

`$ pb | nb + snippets: example.hs`
: save the clipboard contents as a Haskell file named "example.hs" in the
: "snippets" notebook using the shortcut alias `nb +`

### OPTIONS

`--title`,`-t`
: title

`--content`,`-c`
: content

`--tags`
: tags

## ===================================================x

## LISTING AND FILTERING

* Pass an id, filename, or title to view the listing for that note
* No exact match, use "string"
* Can use *regex*

`$ nb list`
: list all files

`$ nb ls`
: *alias* for *nb notebooks* and *nb list*

`$ nb browse`
: browse notes

`$ nb ls example ideas`
: act as *or*

`$ nb ls 3 --excerpt`
: view excerpts of note

`$ nb ls 3 -e 8`
: view excerpts of note

### OPTIONS

`--excerpt`,`-e`
: view excerpts of note

`--reverse`,`-r`
: reverse listing

`--sort`,`-s`
: sort listing

`--limit`,`-l`
: limit number of items in listing

`--all`,`-a`
: show all listing

## ===================================================x

## EDITING

`$ nb edit`
: edit item

`$ nb browse edit`
: edit in browser

`$ nb e`
: *alias*

`$ nb edit 3`
: edit note by *id*

`$ nb edit example.md`
: edit note by *filename*

`$ nb edit "A Document Title"`
: edit note by *title*

`$ nb edit example:12`
: edit note 12 in the notebook named "example"

`$ nb example:12 edit`
: edit note 12 in the notebook named "example", alternative

`$ nb example:edit 12`
: edit note 12 in the notebook named "example", alternative

`$ echo "Content to append." | nb edit 1`
: append to note

`$ nb edit 1 --content "Content to append."`
: same as above

### OPTIONS

`--content`,`-c`
: content to be appended

`--overwrite`
: overwrite file

`--prepend`
: prepend to file

`--edit`
: open in editor before saving

## ===================================================x

## VIEWING

`$ nb show // nb s`
: show with syntax highlighting

`$ nb browse`
: browse files

`$ nb open`
: open file

`$ nb peek`
: peek at file

`$ nb show 3`
: show note by 8id8

`$ nb show example.md`
: show note by *filename*

`$ nb show "A Document Title"`
: show note by *title*

`$ nb 3 show`
: show note by *id*, alternative

`$ nb show example:12`
: show note 12 in the notebook named "example"

`$ nb example:12 show`
: show note 12 in the notebook named "example", alternative

`$ nb example:show 12`
: show note 12 in the notebook named "example", alternative

`$ nb show 123 --print`
: print to stdout

### OPTIONS

`--print`,`-p`
: stdout

`--no-color`
: don't syntax highlight

`--render`,`-r`
: render *html* and open in browser

## ===================================================x

## DELETING

`$ nb delete`
: delete files

`$ nb browse delete`
: browse delete files

`$ nb delete 3`
: delete item by id

`$ nb delete example.md`
: delete item by filename

`$ nb delete "A Document Title"`
: delete item by title

`$ nb 3 delete`
: delete item by id, alternative

`$ nb delete example:12`
: delete item 12 in the notebook named "example"

`$ nb example:12 delete`
: delete item 12 in the notebook named "example", alternative

`$ nb example:delete 12`
: delete item 12 in the notebook named "example", alternative

`$ nb delete example/345`
: delete item 345 in the folder named "example"

`$ nb delete 89 56 21`
: delete items with the ids 89, 56, and 21

## ===================================================x

## FOLDERS

`$ nb add example/`
: add a new note in the *folder* named "example"

`$ nb add example/demo/`
: add a new note in the *folder* named "demo" in "example"

`$ nb add sample --type folder`
: create a new folder named "sample"

`$ nb add example/demo --type folder`
: create a folder named "example" containing a folder named "demo"

`$ nb list`
: list with *ids*

`$ nb list 1/`
: list with *ids*

`$ nb list 1/2/`
: list with *ids*

`$ nb example:sample/`
: list the contents of the "sample" folder in the "example" notebook

`$ nb add example:sample/demo/`
: add an item to the "sample/demo" folder in the "example" notebook

`$ nb edit example:sample/demo/3`
: edit item 3 in the "sample/demo" folder in the "example" notebook

## ===================================================x

## PIN

`$ nb pin / unpin`
: pin / unpin

`export NB_PINNED_PATTERN="#pinned"`
: all tagged with #pinned are pinned

`export NB_INDICATOR_PINNED="💖"`
: icon

## ===================================================x

## SEARCH

`$ nb search`
: search

`$ nb q`
: search alias

`$ nb search "#tag1" "#tag2"`
: search for tagged items

`$ nb search "example query"`
: search current notebook for "example query"

`$ nb search example: "example query"`
: search the notebook "example" for "example query"

`$ nb search demo/ "example query"`
: search the folder named "demo" for "example query"

`$ nb search "example query" --all --list`
: search all unarchived notebooks for "example query" and list matching items

`$ nb search "example" "demo"`
: search for "example" AND "demo" with multiple arguments

`$ nb search "example" --and "demo"`
: search for "example" AND "demo" with option

`$ nb search "example|sample"`
: search for "example" OR "sample" with argument

`$ nb search "example" --or "sample"`
: search for "example" OR "sample" with option

`$ nb search ":example"`
: search items containing the hashtag "#example"

`$ nb search "\d\d\d-\d\d\d\d"`
: search with a regular expression

`$ nb search "example" --type bookmark`
: search bookmarks for "example"

`$ nb bk q "example"`
: search bookmarks for "example", alternative

`$ nb q "example query"`
: search the current notebook for "example query"

`$ nb q example: "example query"`
: search the notebook named "example" for "example query"

`$ nb q -la "example query"`
: search all unarchived notebooks for "example query" and list matching items

`$ nb search "example" --list`
: print only filename

`$ nb q "#example" "#demo" "#sample"`
: multiple query treated as and

`$ nb q "example|sample"`
: with or

`$ nb q "example" --or "sample" --and "demo"`
: or and

`$ nb browse --query "#example"`
: browse query

### OPTIONS

`--utility`
: use *rg* instead

## ===================================================x

## MOVE AND RENAME

`$ nb move / rename / mv`
: aliases

`$ nb move example.md sample.org`
: move "example.md" to "sample.org"

`$ nb rename 2 "New Name"`
: rename note 2 ("example.md") to "New Name.md"

`$ nb move example:12 demo:Sample\ Folder/`
: move note 12 from the "example" notebook into "Sample Folder" in the "demo" notebook

`$ nb rename 5 .org`
: change ext

## ===================================================x

## SETTINGS

`$ nb set editor`
: set editor

`$ nb set default_extension`
: set default ext

`$ nb set limit <number>`
: set number of items to show in *ls*

`$ nb set color_theme blacklight`
: theme

`$ nb settings list --long`
: list all
