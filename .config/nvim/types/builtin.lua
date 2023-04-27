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
---@field preview boolean|fun(opts: CommandArgs, ns: string, buf: number): CommandPreviewRet preview callback for 'inccomand'
---@field range? number|'%' items in cmd range (conflicts: count)
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
---@field preview boolean|fun(opts: CommandArgs, ns: string, buf: number): CommandPreviewRet preview callback for 'inccomand'
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

---@class Keymap_t
---@field buffer boolean|number buffer local
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
---@field buffer? boolean|number mapping is specific to a buffer
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
}

---@class DelMapArgs
---@field buffer? boolean|number
---@field notify? boolean
local DelMapArgs = {}

---@class KeymapSearchOpts
---@field lhs? boolean search left-hand (default: true, i.e., search rhs)
---@field buffer? boolean only search buffer-local keymaps
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
---@field event string name of event that triggered the autocommand
---@field group number|nil autocommand group id if exists
---@field match string expanded value of `<amatch>`
---@field buf number expanded value of `<abuf>`
---@field file string expanded value of `<afile>`
---@field data any any arbitrary data passed to `nvim_exec_autocmds`
local AutocmdOpts = {}

---@class Autocmd
---@field desc?   string          description of the `autocmd`
---@field event   string|string[] list of autocommand events
---@field pattern string|string[] list of autocommand patterns
---@field command string|fun(args: AutocmdOpts) command to exec
---@field nested  boolean
---@field once    boolean
---@field buffer  number        buffer number. Conflicts with `pattern`
---@field group   string|number group name or ID to match against
---@field description string?   alternative to `self.desc`
local Autocmd = {}

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
---@field buffer boolean
---@field silent boolean
---@field only_start boolean
