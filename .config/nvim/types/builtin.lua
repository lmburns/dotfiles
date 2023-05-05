---@meta
---@diagnostic disable:duplicate-doc-field

--  ╭─────────╮
--  │ Command │
--  ╰─────────╯

---@class CommandOpts
---@field addr? CommandAddr -range helper
---@field bang boolean cmd can take a "!" modifier
---@field bar boolean cmd can be followed by "|" and another cmd
---@field complete? CommandComplete|fun(a, c, p) completion for cmd
---@field count? number count supplied to cmd (conflicts: range)
---@field nargs CommandNargs number of arguments to cmd
---@field preview boolean|fun(opts: CommandArgs, ns: string, buf: bufnr): CommandPreviewRet preview callback for 'inccomand'
---@field range? number|'%' @ items in cmd range (conflicts: count)
---@field register boolean first arg can be an optional register name
---@field keepscript boolean use location of invocation for verbose
---@field desc string description of the cmd
---@field force boolean override existing definition
local CommandOpts = {}

---@class CommandArgs
---@field name string command name
---@field args string args passed to command (<args>)
---@field fargs string[] args split by whitespace (<fargs>)
---@field mods CommandMods command modifiers (<mods>)
---@field smods CommandSMods command mods in structured format
---@field bang boolean if executed with `!` (<bang>)
---@field line1 number starting line of command range (<line1>)
---@field line2 number final line of command range (<line2>)
---@field range? number|'%' num of items in command range (<range>)
---@field count? number any count supplied (<count>)
---@field register boolean|string optional register (<reg>)
---@field definition string (may not exist) command definition
---@field complete? CommandComplete (may not exist) completion for cmd
---@field complete_arg? string|fun(a, c, p) (MNE) fn name; argument to complete='custom'
---@field nargs CommandNargs (MNE) number of arguments to cmd
---@field preview boolean|fun(opts: CommandArgs, ns: string, buf: bufnr): CommandPreviewRet preview callback for 'inccomand'
---@field keepscript boolean use location of invocation for verbose
local CommandArgs = {}

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
---| 'lines'           range of lines (default: -range)
---| 'arguments'       range for arguments
---| 'buffers'         range for buffers (also not loaded buffers)
---| 'loaded_buffers'  range for loaded buffers
---| 'windows'         range for windows
---| 'tabs'            range for tab pages
---| 'quickfix'        range for quickfix entries
---| 'other'           others (".", "$", "%") (default: -count)
---| 'arg'             range for arguments
---| 'buf'             range for buffers (also not loaded buffers)
---| 'load'            range for loaded buffers
---| 'win'             range for windows
---| 'tab'             range for tab pages
---| 'qf'              range for quickfix entries
---| '?'               others (".", "$", "%") (default: -count)

---@alias CommandComplete
---| 'arglist'       file names in argument list
---| 'augroup'       autocmd groups
---| 'buffer'        buffer names
---| 'behave'        :behave suboptions
---| 'color'         color schemes
---| 'command'       Ex command (and arguments)
---| 'compiler'      compilers
---| 'dir'           directory names
---| 'environment'   environment variable names
---| 'event'         autocommand events
---| 'expression'    Vim expression
---| 'file'          file and directory names
---| 'file_in_path'  file and directory names in 'path'
---| 'filetype'      filetype names 'filetype'
---| 'function'      function name
---| 'help'          help subjects
---| 'highlight'     highlight groups
---| 'history'       :history suboptions
---| 'locale'        locale names (as output of locale -a)
---| 'lua'           Lua expression
---| 'mapclear'      buffer argument
---| 'mapping'       mapping name
---| 'menu'          menus
---| 'messages'      ':messages' suboptions
---| 'option'        options
---| 'packadd'       optional package |pack-add| names
---| 'shellcmd'      Shell command
---| 'sign'          ':sign' suboptions
---| 'syntax'        syntax file names |'syntax'|
---| 'syntime'       ':syntime' suboptions
---| 'tag'           tags
---| 'tag_listfiles' tags, fnames are shown with CTRL-D
---| 'user'          user names
---| 'var'           user variables
---| 'custom,fun(a:ArgLead, c:CmdLine, p:CursorPos)'     custom completion
---| 'customlist,fun(a:ArgLead, c:CmdLine, p:CursorPos)' custom completion

---@alias CommandPreviewRet
---| 0  no preview shown
---| 1  preview shown without window (even w/ "inccommand=split")
---| 2  preview shown & window is opened (if "inccommand=split").

--  ╭─────╮
--  │ Map │
--  ╰─────╯

---@class KeymapDiposable
---@field map fun(): Keymap_t
---@field dispose fun()
---@field lhs string[]
---@field buffer? boolean|integer
---@field modes KeymapMode[]

---@class Keymap_t
---@field buffer boolean|bufnr buffer local
---@field expr boolean an expression
---@field lhs string lhs as it would be typed
---@field lhsraw string lhs as raw bytes
---@field lhsrawalt string lhs as raw bytes alternate
---@field lnum number line number in "sid", 0 if unknown
---@field mode KeymapMode[] mode(s) for which mapping is defined
---@field noremap boolean is not remappable
---@field nowait boolean don't wait for longer mappings
---@field rhs string rhs as it would be typed
---@field script boolean if defined with <script>
---@field sid number script local ID, used for <sid>
---@field silent boolean if silent
---@field callback fun()
local Keymap_t = {}

---@alias KeymapMode
---| "n" normal
---| "v" visual and select
---| "o" operator-pending
---| "i" insert
---| "c" cmd-line
---| "s" select
---| "x" visual
---| "l" langmap
---| "t" terminal
---| " " normal, visual, and operator-pending
---| "!" insert and cmd-line

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
---@field cmd boolean make a `<Cmd>` mapping (don't use `<Cmd>..<CR>` with this)
---@field luacmd boolean make a `<Cmd>lua` mapping (do not use `<Cmd>..<CR>` with this)
---@field desc? string describe the map; hooks to `which-key`
---@field unmap boolean unmap before the creating new map
---@field ignore boolean pass `which_key_ignore` to `which-key`; overrides `desc`
---@field cond any|fun(): boolean condition must be met to have mapping set
---@field ft? string|string[] filetype/list of filetypes where mapping will be created
---@field buf? boolean|bufnr alias for buffer
---@field sil boolean alias for silent
local MapArgs = {
    unique = false,
    expr = false,
    script = false,
    nowait = false,
    silent = false,
    buffer = nil,
    replace = true,
    remap = false,
    unmap = false,
    callback = nil,
    cmd = false,
    luacmd = false,
    desc = nil,
    ignore = false,
    cond = nil,
    ft = nil,
    buf = nil,
    sil = false,
}

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
---@field id number autocommand id
---@field event NvimEvent name of event that triggered the autocommand
---@field group number|nil autocommand group id if exists
---@field match string expanded value of `<amatch>`
---@field buf bufnr expanded value of `<abuf>`
---@field file string expanded value of `<afile>`
---@field data any any arbitrary data passed to `nvim_exec_autocmds`
local AutocmdOpts = {}

---@class Autocmd
---@field desc?   string          description of the `autocmd`
---@field event   NvimEvent|NvimEvent[] list of autocommand events
---@field pattern string|string[] list of autocommand patterns
---@field command string|fun(args: AutocmdOpts) command to exec
---@field nested  boolean
---@field once    boolean
---@field buffer  bufnr         buffer number. Conflicts with `pattern`
---@field group   string|number group name or ID to match against
---@field description string?   alternative to `self.desc`
local Autocmd = {}

---@class AutocmdExec
---@field group string|integer autocmd group name or id
---@field pattern string|string[] pattern to match against
---@field buffer bufnr buffer number
---@field modeline boolean process the modedeline after autocmds
---@field data any data to send to autocmd callback
local AutocmdExec = {}

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
---| '"BufAdd"' after creating/adding/renaming buffer which is added/in to buflist. Before `BufEnter`.
---| '"BufDelete"' before deleting buffer from buflist
---| '"BufEnter"' after entering buffer. After BufAdd and BufReadPost
---| '"BufFilePost"' after changing name of curbuf with ":file" or ":saveas"
---| '"BufFilePre"' before changing name of curbuf with ":file" or ":saveas"
---| '"BufHidden"' before buf becomes hidden: no longer wins that show buffer, but buf is not unloaded or deleted
---| '"BufLeave"' before leaving to another buf; when leaving/closing curwin and new curwin is not for same buf
---| '"BufModifiedSet"' after `modified` value of buf has been changed
---| '"BufNew"' just after creating new buffer / renaming buffer
---| '"BufNewFile"' starting to edit file that doesn't exist
---| '"BufRead"' starting to edit new buffer, after reading file into buffer, before processing modelines
---| '"BufReadPost"' starting to edit new buffer, after reading file into buffer, before processing modelines
---| '"BufReadCmd"' before editing new buffer. should read file into buffer
---| '"BufReadPre"' starting to edit new buffer, before reading file into buf. not used if file doesn't exist
---| '"BufUnload"' before unloading buf, when text in buffer is going to be freed. After BufWritePost. Before BufDelete
---| '"BufWinEnter"' after buf is displayed in window
---| '"BufWinLeave"' before buf is removed from window, not when still visible in another window
---| '"BufWipeout"' before completely deleting buffer
---| '"BufWrite"' before writing whole buffer to file
---| '"BufWritePre"' before writing whole buffer to file
---| '"BufWriteCmd"' Before writing whole buffer to file
---| '"BufWritePost"' after writing whole buffer to file (should undo commands for `BufWritePre`)
---| '"ChanInfo"' state of channel changed (sets `v.event`: info)
---| '"ChanOpen"' just after channel was opened (sets `v.event`: keys: info)
---| '"CmdUndefined"' user command is used but it isn't defined. patt matched against cmd name
---| '"CmdlineChanged"' after change made to text inside command line
---| '"CmdlineEnter"' after entering cli (include ":" in map: use `<Cmd>` instead) (sets `v.event`: cmdlevel, cmdtype)
---| '"CmdlineLeave"' before leaving cli (include ":" in map: use `<Cmd>` instead) (sets `v.event`: abort, cmdlevel, cmdtype)
---| '"CmdwinEnter"' after entering cli-win.
---| '"CmdwinLeave"' before leaving cli-win. clean up global setting done with `CmdwinEnter`
---| '"ColorScheme"' after loading colorscheme (patt is matched against the colorscheme name)
---| '"ColorSchemePre"' before loading colorscheme
---| '"CompleteChanged"' after each time Insert mode compl menu changed (sets `v.event`: completed_item, height, width, row, col, size, scrollbar?)
---| '"CompleteDonePre"' after Insert mode compl is done. either something was completed or abandoned
---| '"CompleteDone"' after Insert mode compl is done. either something was completed or abandoned
---| '"CursorHold"' user doesn't press key for time specified with 'updatetime'. (only triggered in Normal mode)
---| '"CursorHoldI"' CursorHold, but in Insert mode
---| '"CursorMoved"' after cursor moved in Normal or Visual mode or to another win. also text of cursor line changes (e.g. "x", "rx", "p")
---| '"CursorMovedI"' after cursor was moved in Insert mode. not triggered when popup menu is visible
---| '"DiffUpdated"' after diffs have been updated.
---| '"DirChanged"' after cwd changed. (patt: "window:`:lcd`, "tabpage":`:tcd`, "global":`:cd`, "auto":'autochdir') (sets `v.event`: cwd, scope, changed_window)
---| '"DirChangedPre"' when cwd is going to be changed, as with `DirChanged` (sets `v.event`: directory, scope, changed_window)
---| '"ExitPre"' using `:quit`, `:wq` in way it makes Vim exit, or using `:qall`, just after `QuitPre`
---| '"FileAppendCmd"' before append to file. should do the appending to file.  use '[ and '] marks for range of lines
---| '"FileAppendPost"' after appending to file
---| '"FileAppendPre"' before appending to file.  use '[ and '] marks for range of lines
---| '"FileChangedRO"' before making first change to read-only file
---| '"FileChangedShell"' Vim notices that modification time of file has changed since editing started
---| '"FileChangedShellPost"' after handling file that was changed outside of Vim.  can be used to update statusline
---| '"FileReadCmd"' before reading file with `:read`. should do reading of file
---| '"FileReadPost"' after reading file with `:read`. Vim sets '[ and '] marks to the first and last line of read. can be used to operate on lines just read
---| '"FileReadPre"' before reading file with `:read`
---| '"FileType"' 'filetype' option has been set. patt is matched against filetype
---| '"FileWriteCmd"' before writing to file, when not writing the whole buffer. should do writing to the file, and should not change buf
---| '"FileWritePost"' after writing to file, when not writing the whole buffer
---| '"FileWritePre"' before writing to file, when not writing the whole buffer
---| '"FilterReadPost"' after reading file from filter command.
---| '"FilterReadPre"' before reading file from filter command.
---| '"FilterWritePost"' after writing file for filter command or making diff with an external diff
---| '"FilterWritePre"' before writing file for filter command or making diff with an external diff
---| '"FocusGained"' nvim got focus
---| '"FocusLost"' nvim lost focus. also when GUI dialog pops up
---| '"FuncUndefined"' user function is used but it isn't defined
---| '"UIEnter"' after UI connects via `nvim_ui_attach()`, or after builtin TUI is started, after `VimEnter` (sets `v.event`: chan)
---| '"UILeave"' after UI disconnects from Nvim, or after builtin TUI is stopped, after `VimLeave` (sets `v.event`: chan)
---| '"InsertChange"' typing `<Insert>` while in Insert or Replace mode
---| '"InsertCharPre"' when char is typed in Insert mode, before inserting char.
---| '"InsertEnter"' just before starting Insert mode. also for Replace mode and Virtual Replace mode
---| '"InsertLeavePre"' just before leaving Insert mode. also when using CTRL-O
---| '"InsertLeave"' just after leaving Insert mode. also when using CTRL-O
---| '"MenuPopup"' just before showing popup menu (under the right mouse button) (patt: n, v, o, i, c, tl)
---| '"ModeChanged"' after changing mode (patt: matched against `'old_mode:new_mode'`) (sets `v.event`: old_mode, new_mode)
---| '"OptionSet"' after setting an option (except during startup)
---| '"QuickFixCmdPre"' before quickfix command is run (patt: command being run)
---| '"QuickFixCmdPost"' like QuickFixCmdPre, but after quickfix command is run, before jumping to first location
---| '"QuitPre"' using `:quit`, `:wq` or `:qall`, before deciding whether it closes curwin or quits Vim
---| '"RemoteReply"' reply from Vim that functions as server was received `server2client()`
---| '"SearchWrapped"' after making search with `n`/`N` if the search wraps around document
---| '"RecordingEnter"' macro starts recording
---| '"RecordingLeave"' macro stops recording (sets `v.event`: regcontents, regname)
---| '"SessionLoadPost"' after loading session file created using `:mksession`
---| '"ShellCmdPost"' after exec shell command with `:!cmd`, `:make`, `:grep`
---| '"Signal"' after Nvim receives signal (patt: signal name)
---| '"ShellFilterPost"' after exec shell command with `:{range}!cmd`, `:w !cmd`, `:r !cmd`
---| '"SourcePre"' before sourcing vim/lua file.
---| '"SourcePost"' after sourcing vim/lua file
---| '"SourceCmd"' when sourcing vim/lua file
---| '"SpellFileMissing"' when trying to load spellfile and it can't be found (patt: language)
---| '"StdinReadPost"' during startup, after reading from stdin into buffer, before executing modelines
---| '"StdinReadPre"' during startup, before reading from stdin into buffer
---| '"SwapExists"' detected an existing swap file when starting to edit file
---| '"Syntax"' when 'syntax' option has been set (patt: syntax name)
---| '"TabEnter"' just after entering tab page. After WinEnter. Before BufEnter.
---| '"TabLeave"' just before leaving tab page. After WinLeave.
---| '"TabNew"' when creating new tab page. After WinEnter. Before TabEnter.
---| '"TabNewEntered"' after entering new tab page. After BufEnter.
---| '"TabClosed"' after closing tab page.
---| '"TermOpen"' when `terminal` job is starting
---| '"TermEnter"' after entering `Terminal-mode`. After TermOpen
---| '"TermLeave"' after leaving `Terminal-mode`. After TermClose
---| '"TermClose"' when |terminal| job ends (sets `v.event`: status)
---| '"TermResponse"' after response to t_RV is received from terminal
---| '"TextChanged"' after change was made to text in the curbuf in Normal mode
---| '"TextChangedI"' after change was made to text in the curbuf in Insert mode
---| '"TextChangedP"' after change was made to text in the curbuf in Insert mode, only when the popup menu is visible
---| '"TextChangedT"' after change was made to text in the curbuf in `Terminal-mode`
---| '"TextYankPost"' just after `yank`/`delete`, not if blackhole reg or `setreg()` (sets `v.event`: inclusive, operator, regcontents, regname, regtype, visual)
---| '"User"' not executed automatically. use `:doautocmd` to trigger this
---| '"UserGettingBored"' when user presses same key 42 times
---| '"VimEnter"' after doing all startup stuff, including loading vimrc files
---| '"VimLeave"' before exiting Vim, just after writing the .shada file. executed only once
---| '"VimLeavePre"' before exiting Vim, just before writing the .shada file. executed only once
---| '"VimResized"' after Vim window was resized, thus 'lines' and/or 'columns' changed
---| '"VimResume"' after Nvim resumes from `suspend` state
---| '"VimSuspend"' before Nvim enters `suspend` state
---| '"WinClosed"' when closing window, just before it is removed from window layout (patt: `winid`). After WinLeave
---| '"WinEnter"' after entering another window. not done for first window, when Vim has just started.
---| '"WinLeave"' before leaving window. Before WinClosed
---| '"WinNew"' when new window was created. not done for first window. Before WinEnter
---| '"WinScrolled"' after any window in current tab page scrolled text or changed width or height
---| '"WinResized"' after window in current tab page changed width or height
