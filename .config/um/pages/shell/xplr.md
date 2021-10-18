# xplr --
{:data-section="shell"}
{:data-date="June 05, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
File manager

## PIPES

`$XPLR_PIPE_MSG_IN`
: read messages from other programs.

`$XPLR_PIPE_FOCUS_OUT`
: write the focused node path for other programs to read.

`$XPLR_PIPE_SELECTION_OUT`
: write the new-line delimited selected paths for other programs to read.

`$XPLR_PIPE_GLOBAL_HELP_MENU_OUT`
: write the global help menu for anyone to read.

`$XPLR_PIPE_LOGS_OUT`
: write the logs for anyone to read.

`$XPLR_PIPE_RESULT_OUT`
: write the currect result (selection or focused path).

`$XPLR_PIPE_DIRECTORY_NODES_OUT`
: write the absolute path of filtered nodes in present working directory.

`$XPLR_PIPE_HISTORY_OUT`
: the dynamic history of last visited directories.

`echo ChangeDirectory: /tmp >> "${XPLR_PIPE_MSG_IN:?}"`
: example 1

`echo FocusNext >> "${XPLR_PIPE_MSG_IN:?}"`
: example 2

## KEYBINDINGS API

### GENERAL

`remaps`
: *type*: dict - Mapping of one key to another key

`on_key`
: *type*: dict - A map of keyboard inputs and actions.

`on_alphabet`
: *type*: nullable action - An action to perform if the keyboard input is an alphabet and is not mapped via the `on_key` field.

`on_number`
:  *type*: nullable action - An action to perform if the keyboard input is a number and is not mapped via the `on_key` field.

`on_special_character`
: *type*: nullable action - An action to perform if the keyboard input is a special character and is not mapped via the `on_key` field.

`default`
: *type*: nullable action - Default action to perform in case of a keyboard input not mapped via any of `on_key`, `on_alphabet`, `on_number` and `on_special_character`.

### ACTION

`help`
: *type*: nullable string - Description of what it does. If unspecified, it will be excluded from the help menu.
`messages`
: *type*: list - A list of message to pass.

### MODE

`help    `
: *type*: nullable str - Help menu to display. If unspecified, it will be auto generated.

`extra_help  `
: *type*: nullable str - Extra help menu to display with the auto generated help menu.

`key_bindings`
: *type*: key bindings - The key bindings for the mode.

## KEYBINDINGS

`key`
: remaps action

`.`
: show hidden

`:`
: action

`?`
: global help menu

`G`
: go to bottom

`ctrl-a / V`
: select/unselect all

`ctrl-c`
: terminate

`ctrl-f / /`
: search

`ctrl-i / tab`
: next visited path

`ctrl-o`
: last visited path

`ctrl-r`
: refresh screen

`ctrl-u`
: clear selection

`ctrl-w`
: switch layout

`d`
: delete

`down / j`
: down

`enter`
: quit with result

`f`
: filter

`g`
: go to

`left / h`
: back

`q`
: quit

`r`
: rename

`right / l`
: enter

`s`
: sort

`space / v`
: toggle selection

`up / k`
: up

`~`
: go home

`[0-9]`
: input

### FILTER

`R`
: relative does not contain

`backspace`
: remove last filter

`ctrl-c`
: terminate

`ctrl-r`
: reset filters

`ctrl-u`
: clear filters

`enter`
: done

`r`
: relative does contain

### NUMBER

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`down / j`
: to down

`enter`
: to index

`esc`
: cancel

`up / k`
: to up

`[0-9]`
: input

### GO TO

`ctrl-c`
: terminate

`esc`
: cancel

`f`
: follow symlink

`g`
: top

`x`
: open in gui

### SEARCH

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`down / j`
: down

`enter`
: focus

`left / h`
: back

`right / l`
: enter

`tab`
: toggle selection

`up / k`
: up

### SELECTION OPTIONS

`c`
: copy here

`ctrl-c`
: terminate

`esc`
: cancel

`m`
: move here

### ACTION TO

`!`
: shell

`c`
: create

`ctrl-c`
: terminate

`e`
: open in editor

`esc`
: cancel

`l`
: logs

`s`
: selection operations

`[0-9]`
: go to index

### CREATE

`ctrl-c`
: terminate

`d`
: create directory

`esc`
: cancel

`f`
: create file

### CREATE FILE

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`enter`
: create file

`esc`
: cancel

### CREATE DIRECTORY

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`enter`
: create directory

`esc`
: cancel

### RENAME

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`esc`
: cancel

`enter`
: rename

### DELETE

`D`
: force delete

`ctrl-c`
: terminate

`d`
: delete

`esc`
: cancels

### SORT

`!`
: reverse sorters

`E`
: by canonical extension reverse

`M`
: by canonical mime essence reverse

`N`
: by node type reverse

`R`
: by relative path reverse

`S`
: by size reverse

`backspace`
: remove last sorter

`ctrl-c`
: terminate

`ctrl-r`
: reset sorters

`ctrl-u`
: clear sorters

`e`
: by canonical extension

`enter`
: done

`m`
: by canonical mime essence

`n`
: by node type

`r`
: by relative path

`s`
: by size

### FILTER

`R`
: relative does not contain

`backspace`
: remove last filter

`ctrl-c`
: terminate

`ctrl-r`
: reset filters

`ctrl-u`
: clear filters

`enter`
: done

`r`
: relative does contain

### RELATIVE PATH DOES CONTAIN

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`enter`
: apply filter

`esc`
: cancel

### RELATIVE PATH DOES NOT CONTAIN

`backspace`
: remove last character

`ctrl-c`
: terminate

`ctrl-u`
: remove line

`ctrl-w`
: remove last word

`enter`
: apply filter

`esc`
: cancel

### SWITCH LAYOUT

`1`
: default

`2`
: no help menu

`3`
: no selection panel

`4`
: no help or selection

`ctrl-c`
: terminate

`esc`
: cancel

### MESSAGES

`ExplorePwd`
: Explore the present working directory and register the filtered nodes. This operation is expensive. So, try to avoid using it too often.

`ExplorePwdAsync`
: Explore the present working directory and register the filtered nodes asynchronously. This operation happens asynchronously. That means, the xplr directory buffers won’t be updated immediately. Hence, it needs to be used with care and probably with special checks in place. To explore $PWD synchronously, use ExplorePwd instead.

`ExploreParentsAsync`
: Explore the present working directory along with its parents and register the filtered nodes. This operation happens asynchronously. That means, the xplr directory buffers won’t be updated immediately. Hence, it needs to be used with care and probably with special checks in place. To explore just the $PWD synchronously, use ExplorePwd instead.

`Refresh`
: Refresh the UI. But it will not re-explore the directory if the working directory is the same. If there is some change in the working directory and you want to re-explore it, use the Explore message instead. Also, it will not clear the screen. Use ClearScreen for that.

`ClearScreen`
: Clears the screen.

`FocusNext`
: Focus next node.

`FocusNextByRelativeIndex(usize)`
: Focus on the nth node relative to the current focus where n is a given value.

`FocusNextByRelativeIndexFromInput`
: Focus on the nth node relative to the current focus where n is read from the input buffer.

`FocusPrevious`
: Focus on the previous item.

`FocusPreviousByRelativeIndex(usize)`
: Focus on the -nth node relative to the current focus where n is a given value.

`FocusPreviousByRelativeIndexFromInput`
: Focus on the -nth node relative to the current focus where n is read from the input buffer.

`FocusFirst`
: Focus on the first node.

`FocusLast`
: Focus on the last node.

`FocusPath(String)`
: Focus on the given path.

`FocusPathFromInput`
: Focus on the path read from input buffer.

`FocusByIndex(usize)`
: Focus on the absolute nth node where n is a given value.

`FocusByIndexFromInput`
: Focus on the absolute nth node where n is read from the input buffer.

`FocusByFileName(String)`
: Focus on the file by name from the present working directory.

`ChangeDirectory(String)`
: Change the present working directory ($PWD)

`Enter`
: Enter into the currently focused path if it’s a directory.

`Back`
: Go back to the parent directory.

`LastVisitedPath`
: Go to the last path visited.

`NextVisitedPath`
: Go to the next path visited.

`FollowSymlink`
: Follow the symlink under focus to its actual location.

`BufferInput(String)`
: Append/buffer the given string into the input buffer.

`BufferInputFromKey`
: Append/buffer the characted read from a keyboard input into the input buffer.

`SetInputBuffer(String)`
: Set/rewrite the input buffer with the given string. When the input buffer is not-null (even if empty string) it will show in the UI.

`RemoveInputBufferLastCharacter`
: Remove input buffer’s last character.

`RemoveInputBufferLastWord`
: Remove input buffer’s last word.

`ResetInputBuffer`
: Reset the input buffer back to null. It will not show in the UI.

`SwitchMode(String)`
: Switch input mode.

`SwitchModeBuiltin(String)`
: Switch to a builtin mode.

`SwitchModeCustom(String)`
: Switch to a custom mode.

`PopMode`
: Pop the last mode from the history and switch to it.

`SwitchLayout(String)`
: Switch layout.

`SwitchLayoutBuiltin(String)`
: Switch to a builtin layout.

`SwitchLayoutCustom(String)`
: Switch to a custom layout.

`Call(Command)`
: Call a shell command with the given arguments. Note that the arguments will be shell-escaped. So to read the variables, the -c option of the shell can be used. You may need to pass ExplorePwd depening on the expectation.

`CallSilently(Command)`
: Like Call but without the flicker. The stdin, stdout stderr will be piped to null. So it’s non-interactive.

`CallLua(String)`
: Call a Lua function. A CallLuaArg object will be passed to the function as argument. The function can optionally return a list of messages for xplr to handle after the executing the function.

`CallLuaSilently(String)`
: Like `CallLua` but without the flicker. The stdin, stdout stderr will be piped to null. So it’s non-interactive.

`BashExec(String)`
: An alias to Call: {command: bash, args: ["-c", "${command}"], silent: false} where ${command} is the given value.
: `Example: BashExec: "read -p test"`

`BashExecSilently(String)`
: Like BashExec but without the flicker. The stdin, stdout stderr will be piped to null. So it’s non-interactive.
: `Example: BashExecSilently: "tput bell"`

`Select`
: Select the focused node.

`SelectAll`
: Select all the visible nodes.

`SelectPath(String)`
: Select the given path.
: Example: `SelectPath: "/tmp"`

`UnSelect`
: Unselect the focused node.

`UnSelectAll`
: Unselect all the visible nodes.

`UnSelectPath(String)`
: UnSelect the given path.
: Example: `UnSelectPath: "/tmp"`

`ToggleSelection`
: Toggle selection on the focused node.

`ToggleSelectAll`
: Toggle between select all and unselect all.

`ToggleSelectionByPath(String)`
: Toggle selection by file path.
: Example: `ToggleSelectionByPath: "/tmp"`

`ClearSelection`
: Clear the selection.

`AddNodeFilter(NodeFilterApplicable)`
: Add a filter to exclude nodes while exploring directories.
: Example: `AddNodeFilter: {filter: RelativePathDoesStartWith, input: foo}`

`RemoveNodeFilter(NodeFilterApplicable)`
: Remove an existing filter.
: Example: `RemoveNodeFilter: {filter: RelativePathDoesStartWith, input: foo}`

`ToggleNodeFilter(NodeFilterApplicable)`
: Remove a filter if it exists, else, add a it.
: Example: `ToggleNodeFilter: {filter: RelativePathDoesStartWith, input: foo}`

`AddNodeFilterFromInput(NodeFilter)`
: Add a node filter reading the input from the buffer.
: Example: `AddNodeFilterFromInput: RelativePathDoesStartWith`

`RemoveNodeFilterFromInput(NodeFilter)`
: Remove a node filter reading the input from the buffer.
: Example: `RemoveNodeFilterFromInput: RelativePathDoesStartWith`

`RemoveLastNodeFilter`
: Remove the last node filter.

`ResetNodeFilters`
: Reset the node filters back to the default configuration.

`ClearNodeFilters`
: Clear all the node filters.

`AddNodeSorter(NodeSorterApplicable)`
: Add a sorter to sort nodes while exploring directories.
: Example: `AddNodeSorter: {sorter: ByRelativePath, reverse: false}`

`RemoveNodeSorter(NodeSorter)`
: Remove an existing sorter.
: Example: `RemoveNodeSorter: ByRelativePath`

`ReverseNodeSorter(NodeSorter)`
: Reverse a node sorter.
: Example: `ReverseNodeSorter: ByRelativePath`

`ToggleNodeSorter(NodeSorterApplicable)`
: Remove a sorter if it exists, else, add a it.
: Example: `ToggleSorterSorter: {sorter: ByRelativePath, reverse: false}`

`ReverseNodeSorters`
: Reverse the node sorters.

`RemoveLastNodeSorter`
: Remove the last node sorter.

`ResetNodeSorters`
: Reset the node sorters back to the default configuration.

`ClearNodeSorters`
: Clear all the node sorters.

`EnableMouse`
: Enable mouse

`DisableMouse`
: Disable mouse

`ToggleMouse`
: Toggle mouse

`LogInfo(String)`
: Log information message.
: Example: `LogInfo: launching satellite`

`LogSuccess(String)`
: Log a success message.
: Example: `LogSuccess: satellite reached destination.`

`LogWarning(String)`
: Log an warning message.
: Example: `LogWarning: satellite is heating`

`LogError(String)`
: Log an error message.
: Example: `LogError: satellite crashed`

`Quit`
: Quit with returncode zero (success).

`PrintResultAndQuit`
: Print selected paths if it’s not empty, else, print the focused node’s path.

`PrintAppStateAndQuit`
: Print the state of application in YAML format. Helpful for debugging or generating the default configuration file.

`Debug(String)`
: Write the application state to a file, without quitting. Also helpful for debugging.

`Terminate`
: Terminate the application with a non-zero return code.

## HACK THE UI

`Note`
: UI config follows the priority: `default_ui` -> `node_type` -> `selection_ui` -> `focus_ui`

### TABLE

`parent`
: String

`relative_path`
: String

`absolute_path`
: String

`extension`
: String

`is_symlink`
: bool

`is_broken`
: bool

`is_dir`
: bool

`is_file`
: bool

`is_readonly`
: bool

`mime_essence`
: String

`size`
: u64

`human_size`
: String

`permissions`
: Permissions

`canonical`
: Option<ResolvedNodeUiMetadata>

`symlink`
: Option<ResolvedNodeUiMetadata>

`index`
: usize

`relative_index`
: usize

`is_before_focus`
: bool

`is_after_focus`
: bool

`tree`
: String

`prefix`
: String

`suffix`
: String

`is_selected`
: bool

`is_focused`
: bool

`total`
: usize

`meta`
: HashMap<String, String>

### MODIFIERS

`Bold`
: bold

`Dim`
: dim

`Italic`
: italic

`Underlined`
: underlined

`SlowBlink`
: slow blink

`RapidBlink`
: rapid blink

`Reversed`
: reversed

`Hidden`
: hidden

`CrossedOut`
: crossed out
