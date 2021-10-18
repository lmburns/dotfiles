# vifm --
{:data-section="shell"}
{:data-date="May 06, 2021"}
{:data-extra="Um Pages"}

## COMMAND MACROS

`%a`
: User arguments. When user arguments contain macros, they are expanded before preforming substitution of %a.

`%c %"c`
: The current file under the cursor.

`%C %"C`

: The current file under the cursor in the other directory.

`%f %"f`
: All of the selected files, but see "Selection" section below.

`%F %"F`
: All of the selected files in the other directory list, but see "Selection" section below.

`%b %"b`
: Same as %f %F.

`%d %"d`
: Full path to current directory.

`%D %"D`
: Full path to other file list directory.

`%rx %"rx`
: Full paths to files in the register {x}. In case of invalid symbol in place of {x}, it's processed with the rest of the line and default register is used.

`%m`
: Show command output in a menu.

`%M`
: Same as %m, but l (or Enter) key is handled like for :locate and :find commands.

`%u`
: Process command output as list of paths and compose custom view out of it.

`%U`
: Same as %u, but implies less list updates inside vifm, which is absence of sorting at the moment.

`%Iu`
: same as %u, but gives up terminal before running external command.

`%IU`
: same as %U, but gives up terminal before running external command.

`%S`
: Show command output in the status bar.

`%q`
: redirect command output to quick view, which is activated if disabled.

`%s`
: Execute command in split window of active terminal multiplexer (ignored if not running inside one).

`%n`
: Forbid using of terminal multiplexer to run the command.

`%i`
: Completely ignore command output.


`%pc`
: Marks the end of the main command and the beginning of the clear command for graphical preview, which is invoked on closing preview of a file.


`%pd`
: Marks a preview command as one that directly communicates with the terminal. Beware that this is for things like sixel which are self-contained sequences that depend only on current cursor position, using this with anything else is likely to mangle terminal state.

The following dimensions and coordinates are in characters:


`%px`
: x coordinate of top-left corner of preview area.

`%py`
: y coordinate of top-left corner of preview area.

`%pw`
: width of preview area.

`%ph`
: height of preview area.

Use %% if you need to put a percent sign in your command.

Note that %m, %M, %s, %S, %i, %u and %U macros are mutually exclusive. Only the last one of them on the command will take effect.

You can use file name modifiers after %c, %C, %f, %F, %b, %d and %D macros. Supported modifiers are:

`:p`
: full path

`:u`
: UNC name of path (e.g. "\\server" in "\\server\share"), Windows only. Expands to current computer name for not UNC paths.

`:~`
: relative to the home directory

`:.`
: relative to current directory

`:h`
: head of the file name

`:t`
: tail of the file name

`:r`
: root of the file name (without last extension)

`:e`
: extension of the file name (last one)

`:s?pat?sub?`
: substitute the first occurrence of pat with sub. You can use any character for '?', but it must not occur in pat or sub.

`:gs?pat?sub?`
like :s, but substitutes all occurrences of pat with sub.
