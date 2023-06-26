---@meta
---@description My own documentation of vim/nvim functions

---@alias tabnr integer unique tab number
---@alias winid integer unique window-ID. refers to win in any tab
---@alias winnr integer window number. only applies to current tab
---@alias bufnr integer unique buffer number
---@alias bufname string buffer name (full path)

---@alias linenr integer line number
---@alias row integer a row
---@alias column integer a column

---@alias tabpage integer unique tab number
---@alias window integer unique window-ID. refers to win in any tab

--  ╭──────────╮
--  │ Quickfix │
--  ╰──────────╯

---@class QuickfixItem
---@field bufnr bufnr buffer number
---@field module string module's file path (can be "")
---@field lnum integer starting line number
---@field col integer starting column number
---@field end_lnum integer ending line number
---@field end_col integer ending column number
---@field vcol integer virtual column number
---@field nr integer quickfix item number
---@field pattern string
---@field text string quickfix item text
---@field type "'E'"|"'W'"|"'I'"|"'H'"|"'N'"|"'Z'" error, warning, info, hint, note
---@field valid Vim.bool `1` if valid, else `0`

---@class QuickfixDict
---@field changedtick? number
---@field context? table
---@field id? number
---@field idx? number
---@field items? BqfQfItem[]
---@field nr? number
---@field size? number
---@field title? string
---@field winid? number
---@field filewinid? number
---@field quickfixtextfunc? string

--  ╭─────────╮
--  │ Command │
--  ╰─────────╯

---Arguments to building a command
---@class CommandOpts
---@field addr? CommandAddr -range helper
---@field bang boolean cmd can take a "!" modifier
---@field bar boolean cmd can be followed by "|" and another cmd
---@field complete? CommandComplete|CommandCompleteFn|CommandCompleteListFn completion for cmd
---@field nargs CommandNargs number of arguments to cmd
---@field preview boolean|fun(opts: CommandArgs, ns: string, buf: bufnr): CommandPreviewRet preview callback for 'inccomand'
---@field range? number|"'%'"|boolean items in cmd range (conflicts: count)
---@field count? number count supplied to cmd (conflicts: range)
---@field register boolean first arg can be an optional register name
---@field keepscript boolean use location of invocation for verbose
---@field desc string description of the cmd
---@field force boolean override existing definition
local CommandOpts = {}

---Arguments passed to the function when the command is built
---@class CommandArgs
---@field name string command name
---@field args string args passed to command (<args>)
---@field fargs string[] args split by whitespace (<fargs>)
---@field mods CommandMods command modifiers (<mods>)
---@field smods CommandSMods command mods in structured format
---@field bang boolean if executed with `!` (<bang>)
---@field line1 number starting line of command range (<line1>)
---@field line2 number final line of command range (<line2>)
---@field range? number|"'%'" num of items in command range (<range>)
---@field count? number any count supplied (<count>)
---@field register boolean|string optional register (<reg>)
---@field definition? string (may not exist) command definition
---@field complete? CommandComplete (may not exist) completion for cmd
---@field complete_arg? string|fun(a, c, p) (MNE) fn name; argument to complete='custom'
---@field nargs CommandNargs (MNE) number of arguments to cmd
---@field preview boolean|fun(opts: CommandArgs, ns: string, buf: bufnr): CommandPreviewRet preview callback for 'inccomand'
---@field keepscript boolean use location of invocation for verbose
local CommandArgs = {}

---@alias CommandCompleteFn fun(arglead: string, cmdline: string, cursorpos: integer):string
---@alias CommandCompleteListFn fun(arglead: string, cmdline: string, cursorpos: integer):string[]

-- -- ---@class CommandComplFn
-- ---Completion function for `-complete=custom`
-- ---Not necessary to filter candidates against `arglead`.
-- ---@param arglead string leading part of arg currently being completed
-- ---@param cmdline string entire command line
-- ---@param cursorpos integer cursor position in it (byte index)
-- ---@return string candidates newline separated
-- function CommandCompleteFn(arglead, cmdline, cursorpos)
-- end
--
-- -- ---@class CommandComplListFn
-- ---Completion function for `-complete=listcustom`
-- ---Should filter candidates in `arglead`.
-- ---@param arglead string leading part of arg currently being completed
-- ---@param cmdline string entire command line
-- ---@param cursorpos integer cursor position in it (byte index)
-- ---@return string[] candidates
-- function CommandCompleteListFn(arglead, cmdline, cursorpos)
-- end

---@class CommandSMods
---@field browse boolean
---@field confirm boolean
---@field emsg_silent boolean
---@field hide boolean
---@field horizontal boolean
---@field keepalt boolean
---@field keepjumps boolean
---@field keepmarks boolean
---@field keeppatterns boolean
---@field lockmarks boolean
---@field noautocmd boolean
---@field noswapfile boolean
---@field sandbox boolean
---@field silent boolean
---@field split string
---@field tab number
---@field unsilent boolean
---@field verbose number
---@field vertical boolean
local CommandSMods = {}

---@class CommandMods
---@field aboveleft boolean opened left or above
---@field belowright boolean opened right or below
---@field botright boolean opened bottom or right
---@field browse boolean opened file selection dialog
---@field confirm boolean opened confirm dialog
---@field hide boolean buffer is hidden
---@field horizontal boolean opened horizontally
---@field keepalt boolean kept alt file name
---@field keepjumps boolean kept jumps
---@field keepmarks boolean kept marks
---@field keeppatterns boolean didn't add to search history
---@field leftabove boolean opened left or above
---@field lockmarks boolean marks weren't adjusted
---@field noautocmd boolean no autocmds were fired
---@field noswapfile boolean didn't create a swapfile
---@field rightbelow boolean opened right or below
---@field sandbox boolean executed in a sandbox
---@field silent boolean no output was diplayed
---@field tab boolean opened in a new tab
---@field topleft boolean opened top or left
---@field unsilent boolean reversed 'silent'
---@field verbose boolean executed verbosely
---@field vertical boolean opened vertically
local CommandMods = {}

---@alias CommandNargs
---| 0      no arguments are allowed (default)
---| 1      one arg is required, includes spaces
---| '*'    any number of args are allowed, sep by space
---| '?'    0 or 1 args are allowed
---| '+'    args are required, any number can be supplied
---| number number of arguments allowed

---@alias CommandAddr
---| '"lines"'           range of lines (default: -range)
---| '"arguments"'       range for arguments
---| '"buffers"'         range for buffers (also not loaded buffers)
---| '"loaded_buffers"'  range for loaded buffers
---| '"windows"'         range for windows
---| '"tabs"'            range for tab pages
---| '"quickfix"'        range for quickfix entries
---| '"other"'           others (".", "$", "%") (default: -count)
---| '"arg"'             range for arguments
---| '"buf"'             range for buffers (also not loaded buffers)
---| '"load"'            range for loaded buffers
---| '"win"'             range for windows
---| '"tab"'             range for tab pages
---| '"qf"'              range for quickfix entries
---| "'?'"               others (".", "$", "%") (default: -count)

---@alias CommandComplete
---| '"arglist"'       file names in argument list
---| '"augroup"'       autocmd groups
---| '"buffer"'        buffer names
---| '"behave"'        :behave suboptions
---| '"color"'         color schemes
---| '"command"'       Ex command (and arguments)
---| '"compiler"'      compilers
---| '"dir"'           directory names
---| '"environment"'   environment variable names
---| '"event"'         autocommand events
---| '"expression"'    Vim expression
---| '"file"'          file and directory names
---| '"file_in_path"'  file and directory names in 'path'
---| '"filetype"'      filetype names 'filetype'
---| '"function"'      function name
---| '"help"'          help subjects
---| '"highlight"'     highlight groups
---| '"history"'       :history suboptions
---| '"locale"'        locale names (as output of locale -a)
---| '"lua"'           Lua expression
---| '"mapclear"'      buffer argument
---| '"mapping"'       mapping name
---| '"menu"'          menus
---| '"messages"'      ':messages' suboptions
---| '"option"'        options
---| '"packadd"'       optional package |pack-add| names
---| '"shellcmd"'      Shell command
---| '"sign"'          ':sign' suboptions
---| '"syntax"'        syntax file names |'syntax'|
---| '"syntime"'       ':syntime' suboptions
---| '"tag"'           tags
---| '"tag_listfiles"' tags, fnames are shown with CTRL-D
---| '"user"'          user names
---| '"var"'           user variables
---| 'custom,fun(a:ArgLead, c:CmdLine, p:CursorPos)'     custom completion
---| 'customlist,fun(a:ArgLead, c:CmdLine, p:CursorPos)' custom completion

---@alias CommandPreviewRet
---| 0  no preview shown
---| 1  preview shown without window (even w/ "inccommand=split")
---| 2  preview shown & window is opened (if "inccommand=split").

---A builtin command
---@class Command_t
---@field name string name of command
---@field definition string command description or definition
---@field bang boolean cmd can take a "!" modifier
---@field bar boolean cmd can be followed by "|" and another cmd
---@field keepscript boolean use location of invocation for verbose
---@field nargs 1|0|"'?'"|"'*'"|"'+'" number of arguments to cmd
---@field preview boolean does command have a preview callback?
---@field register boolean first arg can be an optional register name
---@field script_id number SID, script id
---@field complete? CommandComplete|fun() completion for cmd
---@field complete_arg? string|fun() argument to complete='custom'
---@field range? "'1'"|"'0'"|"'%'"|"'.'" items in cmd range
---@field count? number count given to command
---@field addr? CommandAddr -range helper

--  ╭─────╮
--  │ Map │
--  ╰─────╯

---@alias KeymapBuilt {[1]: KeymapMode|KeymapMode[], [2]: string|string[], [3]: (string|fun(): string?), [4]: MapArgs?}

---@class KeymapDiposable
---@field map fun(): self remap key again
---@field maps fun(): Keymap_t[] list of full keymaps
---@field dispose fun()
---@field lhs string[]
---@field buffer? boolean|integer
---@field modes KeymapMode[]

---@class Keymap_t
---@field id string terminal keycodes for lhs
---@field buffer bufnr buffer-local
---@field expr Vim.bool 1 if it is an expression
---@field lhs string lhs as it would be typed
---@field lhsraw string lhs as raw bytes
---@field lhsrawalt string lhs as raw bytes alt. (only present if diff from 'lhsraw')
---@field lnum number line number in "sid", 0 if unknown
---@field mode KeymapMode mode for which mapping is defined
---@field noremap Vim.bool 1 if not remappable
---@field nowait Vim.bool 1 if shouldn't wait for longer mappings
---@field rhs string rhs as it would be typed
---@field script Vim.bool 1 if defined with <script>
---@field sid number script local ID, used for <sid>
---@field silent Vim.bool 1 if silent
---@field callback fun()|nil reference the Lua function bound to the key
---@field desc string keymap description
local Keymap_t = {}

---@alias KeymapMode
---| '"n"' normal
---| '"v"' visual and select
---| '"o"' operator-pending
---| '"i"' insert
---| '"c"' cmd-line
---| '"s"' select
---| '"x"' visual
---| '"l"' langmap
---| '"t"' terminal
---| '"!"' insert and cmd-line
---| '""'  normal, visual, and operator-pending

---@class MapArgs
---@field unique boolean will fail if it isn't unique
---@field expr boolean inserts expression into the window
---@field script boolean is local to a script (`<SID>`)
---@field nowait boolean don't wait for keys to be pressed
---@field silent boolean don't show output in cmd-line window
---@field buffer? boolean|bufnr mapping is specific to a buffer
---@field replace_keycodes boolean termcodes are replaced (requires: expr)
---@field remap boolean make mapping recursive; inverse of `noremap`
---@field callback? fun() Lua function to bind
---@field cmd boolean make a `<Cmd>...<CR>` mapping (don't use `<Cmd>..<CR>` with this)
---@field ccmd boolean make a `<Cmd>call ... <CR>` mapping ("call command")
---@field ncmd boolean make a `<Cmd>norm ... <CR>` mapping ("normal command")
---@field nncmd boolean make a `<Cmd>norm! ... <CR>` mapping ("normal noremap command")
---@field lcmd boolean make a `<Cmd>lua ... <CR>` mapping ("Lua command")
---@field vlua boolean make a `v:lua. ...` mapping (implies `expr`)
---@field vluar boolean make a `v:lua.require ...` mapping (implies `expr`)
---@field cocc boolean make a `<Cmd>CocCommand...<CR>` mapping
---@field turbo boolean skip most checks to bind the mapping as quickly as possible
---@field desc? string describe the map; hooks to `which-key`
---@field unmap boolean unmap before the creating new map
---@field ignore boolean pass `which_key_ignore` to `which-key`; overrides `desc`
---@field cond any|fun(): boolean condition must be met to have mapping set
---@field ft? string|string[] filetype/list of filetypes where mapping will be created
---@field buf? boolean|bufnr alias for buffer
---@field sil boolean alias for silent
---@field now boolean alias for nowait
local MapArgs = {}

---@class DelMapArgs
---@field buffer? boolean|bufnr
---@field notify? boolean
local DelMapArgs = {}

---@class KeymapSearchOpts
---@field lhs? boolean search left-hand (default: true, i.e., search rhs)
---@field buffer? boolean|bufnr only search buffer-local keymaps
---@field pcre? boolean use pcre regex to find the keymap. if false, exact search is used
local KeymapSearchOpts = {
    lhs = true,
    buffer = false,
    pcre = false,
}

--  ╭─────────╮
--  │ Autocmd │
--  ╰─────────╯

---@class AutocmdOpts
---@field id number autocmd id (only when defined with the API)
---@field event NvimEvent name of event that triggered the autocommand
---@field group number|nil autocommand group id if exists
---@field match string expanded value of `<amatch>`
---@field buf bufnr expanded value of `<abuf>`
---@field file string expanded value of `<afile>`
---@field data any any arbitrary data passed to `nvim_exec_autocmds`
local AutocmdOpts = {}

---@class Autocmd
---@field desc string description of autocmd
---@field event   NvimEvent|NvimEvent[] list of autocommand events
---@field pattern string|string[] list of autocommand patterns
---@field command string|fun(args: AutocmdOpts) command to exec
---@field nested  boolean
---@field once    boolean whether the autocmd is only run once
---@field buffer  bufnr         buffer number. Conflicts with `pattern`
---@field group   string|number|{[1]: string, [2]: boolean} group name or ID to match against
---@field description string alias for *desc*, if you want to
local Autocmd = {}

---@class AutocmdExec
---@field group string|integer autocmd group name or i
---@field pattern string|string[] pattern to match against
---@field buffer bufnr buffer number
---@field modeline boolean process the modedeline after autocmds
---@field data any data to send to autocmd callback
local AutocmdExec = {}

---@class Autocmd_t
---@field id number autocmd id (only when defined with the API)
---@field group integer autocmd group id
---@field group_name string autocmd group name
---@field desc string description of autocmd
---@field event NvimEvent autocmd event
---@field command string autocmd command ("" if a callback is set)
---@field callback fun()|string|nil name of func that is ran when autocmd is executed
---@field once boolean whether the autocmd is only run once
---@field pattern string the autocmd pattern
---@field buflocal boolean true if the autocmd is buffer local
---@field buffer bufnr the buffer number.
local Autocmd_t = {}

---@class AutocmdReqOpts
---@field group string|integer autocmd name or id
---@field event string|string[] event(s) to match against
---@field pattern string|string[] pattern(s) to match against
local AutocmdReqOpts = {}

--  ╭──────────╮
--  │ Feedkeys │
--  ╰──────────╯

---@alias FeedkeysMode
---| "'m'" Remap keys
---| "'n'" Do not remap keys
---| "'t'" Handle keys as if typed
---| "'i'" Insert string instead of append
---| "'x'" Execute command similar to `:normal!`

--  ╭──────╮
--  │ Abbr │
--  ╰──────╯

---@class AbbrOpts
---@field expr boolean
---@field buffer bufnr
---@field silent boolean
---@field only_start boolean

--  ╭────────╮
--  │ SetReg │
--  ╰────────╯
---@alias SetRegOpts
---| '"c"' charwise
---| '"v"' charwise
---| '"l"' linewise
---| '"V"' linewise
---| '"b"' blockwise
---| '"u"' unnamed
---| '"'   unnamed

--  ╭────────╮
--  │ Option │
--  ╰────────╯

---@alias Option_t string|number|boolean

---@class GetOptionOpts
---@field scope "global"|"local" analogous to `setglobal` or `setlocal`
---@field win winid get window-local options
---@field buf bufnr get buffer-local options (implies local)
---@field filetype string get filetype-specific options

---@alias GetOption_t "string"|"number"|"boolean"
---@alias GetOption_scope "global"|"win"|"buf"

---@class GetOptionInfo
---@field name string name of option (e.g., 'filetype')
---@field shortname string shortened name of option (e.g., 'ft')
---@field type GetOption_t type of option
---@field default Option_t default value for the option
---@field was_set boolean whether the option was set
---@field last_set_sid integer? last set script id (if any)
---@field last_set_linenr linenr line number where option was set
---@field last_set_chan number channel where option was set (0 for local)
---@field scope GetOption_scope one of "global", "win", or "buf"
---@field global_local boolean whether win or buf option has a global value
---@field commalist boolean list of comma separated values
---@field flaglist boolean list of single char flags
---@field allows_duplicates boolean list of single char flags

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Buffer                          │
--  ╰──────────────────────────────────────────────────────────╯

---@alias BufType
---| "''"         normal buffer
---| "'acwrite'"  buffer will always be written with `BufWriteCmd`
---| "'help'"     help buffer
---| "'nofile'"   buffer is not related to a file, will not be written
---| "'nowrite'"  buffer will not be written
---| "'quickfix'" list of errors `cwindow` or locations `lwindow`
---| "'terminal'" terminal-emulator buffer
---| "'prompt'"   only the last line can be edit see `prompt-buffer`

--  ╭──────────────────────────────────────────────────────────╮
--  │                      Autocmd Events                      │
--  ╰──────────────────────────────────────────────────────────╯

---@alias NvimEvent
---| '"BufNewFile"' starting to edit a file that doesn't exist
---| '"BufReadPre"' starting to edit new buffer, before reading file. not used if file doesn't exist
---| '"BufRead"' starting to edit new buffer, after reading file, before processing modelines
---| '"BufReadPost"' starting to edit new buffer, after reading file, before processing modelines
---| '"BufReadCmd"' before starting to edit a new buffer. should read file into buffer
---| '"FileReadPre"' before reading file with `:read`
---| '"FileReadPost"' after reading file with `:read`; sets `'[` and `']` to first/last line read. can be used to operate on lines just read
---| '"FileReadCmd"' before reading file with `:read`. should do reading of file
---| '"FilterReadPre"' before reading file from `:filter`
---| '"FilterReadPost"' after reading file from `:filter`
---| '"StdinReadPre"' during startup, before reading from stdin into buffer
---| '"StdinReadPost"' during startup, after reading from stdin into buffer, before executing modelines
---| '"BufWrite"' starting to write the whole buffer to a file
---| '"BufWritePre"' before starting to write whole buffer to file
---| '"BufWritePost"' after writing whole buffer to file (should undo commands for `BufWritePre`)
---| '"BufWriteCmd"' Before writing whole buffer to file
---| '"FileWritePre"' starting to write part of buffer to a file
---| '"FileWritePost"' after writing part of buffer to a file
---| '"FileWriteCmd"' before writing part of buffer to a file. should do writing to the file, and should not change buffer
---| '"FilterWritePre"' starting to write file for `:filter` or making diff with an external diff
---| '"FilterWritePost"' after writing file for `:filter` or making diff with an external diff
---| '"FileAppendPre"' starting to append to file. use `'[` and `']` marks for range of lines
---| '"FileAppendPost"' after appending to file
---| '"FileAppendCmd"' before appending to file. should do the appending to file.  use `'[` and `']` marks for range of lines
---| '"BufAdd"' just after creating/adding/renaming buffer which is added to buflist. before `BufEnter`
---| '"BufDelete"' before deleting buffer from buflist
---| '"BufWipeout"' before completely deleting buffer from buflist
---| '"BufCreate"' [VIM] just after adding a buffer to the buffer list
---| '"BufFilePre"' before changing name of curbuf with `:file` or `:saveas`
---| '"BufFilePost"' after changing name of curbuf with `:file` or `:saveas`
---| '"BufEnter"' after entering buffer. after `BufAdd` and `BufReadPost`
---| '"BufLeave"' before leaving to another buffer; when leaving/closing curwin and new curwin is not for same buf
---| '"BufWinEnter"' after buffer is displayed in window
---| '"BufWinLeave"' before buffer is removed from window, not when still visible in another window
---| '"BufUnload"' before unloading buffer, when text in buffer is going to be freed. after `BufWritePost`; before `BufDelete`
---| '"BufHidden"' just before buffer becomes hidden: no longer wins that show buffer, but buffer is not unloaded or deleted
---| '"BufNew"' just after creating new buffer / renaming buffer
---| '"BufModifiedSet"' after `modified` value of buf has been changed
---| '"SwapExists"' detected existing swapfile when editing file (`v:swapname`: swapfile name; `v:swapcommand`, `v:swapchoice`) (`<afile>`: file being edited)
---| '"FileType"' 'filetype' option has been set. pattern is matched against filetype
---| '"Syntax"' when 'syntax' option has been set (*P*: syntax name) (`<afile>`: filename where set; `<amatch>`: where opt set)
---| '"OptionSet"' after setting an option (except during startup)
---| '"EncodingChanged"' [VIM] after the 'encoding' option has been changed
---| '"TermChanged"' [VIM] after the value of 'term' has changed
---| '"VimEnter"' after doing all startup stuff, including loading vimrc files (*A*: `v:vim_did_enter)
---| '"TermResponse"' after response to `t_RV` is received from terminal
---| '"UIEnter"' [NVIM] after UI connects via `nvim_ui_attach()`, or after TUI is started (*A*: `VimEnter`) (`v.event`: chan)
---| '"UILeave"' [NVIM] after UI disconnects from Nvim, or after TUI is stopped (*A*: `VimLeave`) (`v.event`: chan)
---| '"GUIEnter"' [VIM] after starting the GUI successfully
---| '"GUIFailed"' [VIM] after starting the GUI failed
---| '"QuitPre"' using `:quit`, `:wq` or `:qall`; before deciding whether it closes curwin or quits Vim
---| '"ExitPre"' using `:quit`, `:wq` in way it makes Vim exit, or using `:qall`, just after `QuitPre`
---| '"VimLeavePre"' before exiting Vim, just before writing the .shada file; once (`v:dying`, `v:exiting`)
---| '"VimLeave"' before exiting Vim, just after writing the .shada file; once (`v:dying`, `v:exiting`)
---| '"VimSuspend"' before Nvim enters `suspend` state
---| '"VimResume"' Nvim resumes from `suspend` state
---| '"TermOpen"' [NVIM] when `terminal` job is starting
---| '"TermEnter"' [NVIM] after entering `Terminal-mode`. after `TermOpen`
---| '"TermLeave"' [NVIM] after leaving `Terminal-mode`. after `TermClose`
---| '"TermClose"' [NVIM] when `terminal` job ends (`v.event`: status)
---| '"TerminalOpen"' [VIM] after a `terminal` buffer was created
---| '"TerminalWinOpen"' [VIM] after a `terminal` buffer was created in a new window
---| '"FileChangedShell"' Vim notices that modification time of file has changed since editing started
---| '"FileChangedShellPost"' after handling file that was changed outside of Vim.  can be used to update statusline
---| '"FileChangedRO"' before making first change to read-only file
---| '"DiffUpdated"' after diffs have been updated.
---| '"DirChangedPre"' when cwd is going to be changed, as with `DirChanged` (`v.event`: directory, scope, changed_window)
---| '"DirChanged"' after cwd changed (*P*: "window:`:lcd`, "tabpage":`:tcd`, "global":`:cd`, "auto":'autochdir') (`v.event`: cwd, scope, changed_window)
---| '"ShellCmdPost"' after exec shell command with `:!cmd`, `:make`, `:grep`
---| '"ShellFilterPost"' after exec shell command with `:{range}!cmd`, `:w !cmd`, `:r !cmd`
---| '"CmdUndefined"' user command is used but it isn't defined (*P*: command name)
---| '"FuncUndefined"' user function is used but it isn't defined (*P*: func name) (`<amatch>,` `<afile>` = func name)
---| '"SpellFileMissing"' when trying to load spellfile and it can't be found (*P*: language) (`<amatch>` = language)
---| '"SourcePre"' before sourcing vim/lua file (`<afile>`: filename)
---| '"SourcePost"' after sourcing vim/lua file (`<afile>`: filename)
---| '"SourceCmd"' when sourcing vim/lua file (`<afile>`: filename)
---| '"VimResized"' after Vim window was resized
---| '"FocusGained"' nvim got focused
---| '"FocusLost"' nvim lost focus. also when GUI dialog pops up
---| '"CursorHold"' user doesn't press key for time of `updatetime` (*M*: NV)
---| '"CursorHoldI"' `CursorHold`, but in Insert mode (*M*: I)
---| '"CursorMoved"' after cursor moved in Normal/Visual mode or to another win. also text of cursor line changes (e.g. "x", "rx", "p") (*M*: NV)
---| '"CursorMovedI"' after cursor was moved in Insert mode; not when PUM is visible (*M*: I)
---| '"WinNew"' when creating new window; not for first window (*B*: `WinEnter`)
---| '"TabNew"' when creating new tab page (*A*: `WinEnter`, *B*: `TabEnter`)
---| '"WinClosed"' when closing window, just before removed from win layout (*A*: `WinLeave`, *P*: `winid`) (`<amatch>`, `<afile>`: `winid`)
---| '"TabClosed"' after closing tab page
---| '"WinEnter"' after entering another window. not for first window
---| '"WinLeave"' before leaving window (*B*: `WinClosed`)
---| '"TabEnter"' just after entering tab page (*A*: `WinEnter`, *B*: `BufEnter`)
---| '"TabLeave"' just before leaving tab page (*A*: `WinLeave`)
---| '"TabNewEntered"' [NVIM] after entering new tab page (*A*: `BufEnter`)
---| '"CmdwinEnter"' after entering cli-win (`<afile>`: type of)
---| '"CmdwinLeave"' before leaving cli-win (`<afile>`: type of)
---| '"CmdlineChanged"' after change made to text inside command line
---| '"CmdlineEnter"' after entering cli (include ":" in map: use `<Cmd>` instead) (`v.event`: cmdlevel, cmdtype)
---| '"CmdlineLeave"' before leaving cli (include ":" in map: use `<Cmd>` instead) (`v.event`: abort, cmdlevel, cmdtype)
---| '"WinScrolled"' after any window in current tab page scrolled text or changed width or height
---| '"WinResized"' after window in current tab page changed width or height
---| '"InsertEnter"' just before starting Insert mode. also for Replace mode and Virtual Replace mode
---| '"InsertChange"' typing `<Insert>` while in Insert or Replace mode
---| '"InsertLeave"' just after leaving Insert mode. also when using `CTRL-O`
---| '"InsertLeavePre"' just before leaving Insert mode. also when using `CTRL-O`
---| '"InsertCharPre"' when char is typed in Insert mode, before inserting char.
---| '"ModeChanged"' after changing mode (*P*: `old_mode:new_mode`) (`{v.event}`: old_mode, new_mode)
---| '"TextChanged"' after text change made to curbuf (*M*: N) (*A*: `b:changedtick`)
---| '"TextChangedI"' after text change made to curbuf (*M*: I)
---| '"TextChangedP"' after text change made to curbuf when PUM is visible (*M*: I)
---| '"TextChangedT"' after text change made to curbuf (*M*: T)
---| '"TextYankPost"' just after `yank`/`delete`, not if blackhole reg or `setreg()` (`v.event`: inclusive, operator, regcontents, regname, regtype, visual)
---| '"SafeState"' [VIM] nothing pending, going to wait for the user to type a character
---| '"SafeStateAgain"' [VIM] repeated SafeState
---| '"ColorSchemePre"' before loading colorscheme
---| '"ColorScheme"' after loading colorscheme (*P*: colorscheme name)
---| '"RemoteReply"' a reply from a server Vim was received (`<amatch>`: serverid, `<afile>`: reply)
---| '"ChanInfo"' state of channel changed (`{v.event}`: info)
---| '"ChanOpen"' just after channel was opened (`{v.event}`: info)
---| '"QuickFixCmdPre"' before quickfix command is run (*P*: command being run)
---| '"QuickFixCmdPost"' like `QuickFixCmdPre`, but after quickfix command is run, before jumping to first location
---| '"SessionLoadPost"' after loading session file created using `:mksession`
---| '"MenuPopup"' just before showing popup menu (*P*: n, v, o, i, c, tl)
---| '"CompleteChanged"' after each time I mode compl menu changed (`{v.event}`: completed_item, height, width, row, col, size, scrollbar?)
---| '"CompleteDonePre"' after I-mode compl is done. before clearing info (`v:completed_item`)
---| '"CompleteDone"' after I-mode compl is done. after clearing info (`v:completed_item`)
---| '"User"' to be used in combination with ":doautocmd"
---| '"Signal"' [NVIM] after Nvim receives signal (*P*: signal name)
---| '"SigUSR1"' [VIM] after the SIGUSR1 signal has been detected
---| '"SearchWrapped"' after making search with `n`/`N` if the search wraps around document
---| '"RecordingEnter"' macro starts recording
---| '"RecordingLeave"' macro stops recording (`v.event`: regcontents, regname)
---| '"UserGettingBored"' when user presses same key 42 times
