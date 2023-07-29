---@meta
---@description My own documentation of vim/nvim functions

---@alias bufname string  buffer name (full path)
---@alias bufnr   integer unique buffer number
---@alias buffer  integer|bool unique buffer number or true
---@alias tabnr   integer tab number
---@alias tabid   integer unique tab number
---@alias tabpage integer unique tab number
---@alias winnr   integer window number. only applies to current tab
---@alias winid   integer unique window-ID. refers to win in any tab
---@alias window  integer unique window-ID. refers to win in any tab

---@alias namespace integer highlight namespace
---@alias column    integer a column number
---@alias col       integer a column number
---@alias linenr    integer a row; a line number
---@alias line      integer a row; a line number
---@alias lnum      integer a row; a line number
---@alias row       integer a row; a line number

---@alias col_t     integer a column number
---@alias row_t     integer a row; a line number
---@alias line_t    integer a row; a line number

---@alias Cursor_t {[1]: row_t, [2]: col_t}

--  ╭──────────╮
--  │ Quickfix │
--  ╰──────────╯

---What is returned from `getqflist`
---@class Quickfix_t
---@field changedtick? number total number of changes made to list
---@field context? table|""  list context (or "")
---@field id? uuid_t list id (or `0`)
---@field idx? index_t index of quickfix entry in the list (or `0`)
---@field items? BqfQfItem[]|Quickfix.Entry[] quickfix list entries
---@field nr? index_t list number (or `0`)
---@field qfbufnr? bufnr bufnr of display quickfix window
---@field size? size_t number of entries in the list (or `0`)
---@field title? string list title text (or "")
---@field winid? winid quickfix window-ID
---@field filewinid? winid window-ID of the file
---@field quickfixtextfunc? string function name used to get text for entries

---A single quickfix item
---@class Quickfix.Entry
---@field bufnr    bufnr    number of the buffer that has the file name
---@field module   path_t   module's file path (can be "")
---@field lnum     line_t   starting line number in the buffer (starts at 1)
---@field end_lnum line_t   ending line number if multiline
---@field col      col_t    starting column number of buffer (starts at 1)
---@field end_col  col_t    ending column number if item has a range
---@field vcol     Vim.bool `1` if `col` is virtual col-num else `false` (byte index)
---@field nr       index_t  quickfix entry number
---@field pattern  string   search pattern used to location error
---@field text     string   description of the entry
---@field valid    Vim.bool `1` if a recognized error mesage, else `0`
---@field type "'E'"|"'W'"|"'I'"|"'H'"|"'N'"|"'Z'"|"'1'" error, warning, info, hint, note, ...

---`{what}` options passed to `getqflist` or `setqflist`
---@class Quickfix.What
---@field changedtick int|0 total number of changes made to list
---@field context int|table|0 get the quickfix-context
---@field efm string errorformat to use when parsing "lines"
---@field id int|0 info for QF with `id` (0: current; or list `nr`)
---@field idx int|0 info for entry at `idx` in list `id` or `nr`
---@field items int|0 quickfix list entries
---@field lines int|0 parse list of lines using 'efm'; if supplied all else except `efm` ignored
---@field nr int|0|'$' get info for QF `nr`; (0: current; "$": num lists)
---@field qfbufnr int|0 get bufnr of quickfix window (0 if not present)
---@field size int|0 get number of entries in list
---@field title int|0 get list title
---@field winid int|0 get the QF winid
---@field all int|0 all of the above quickfix properties

---`{list}` item given to `setqflist`
---@class Quickfix.Set.List
---@field bufnr string  buffer number; must be the number of a valid
---@field filename string  name of a file; only used when "bufnr" is not
---@field module string  name of a module; if given it will be used in
---@field lnum string  line number in the file
---@field end_lnum string  end of lines, if the item spans multiple lines
---@field pattern string  search pattern used to locate the error
---@field col? string    column number
---@field vcol? string  when non-zero: "col" is visual column
---@field end_col string  end column, if the item spans multiple columns
---@field nr? string    error number
---@field text? string  description of the error
---@field type? string  single-character error type, 'E', 'W', etc.
---@field valid string  recognized error message

---@alias Quickfix.Set.Action
---| "'a'" # items are added to existing list or created
---| "'r'" # items from current list are replaced; can clear
---| "'f'" # all items in list stack are freed
---| "' '" # new list is created; append to stack

--  ╭─────────╮
--  │ Command │
--  ╰─────────╯

---Actual built command type.
---Object that is returned from requesting a command with `nvim_get_commands`
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
---@field complete? Command.Complete_t|fun() completion for cmd
---@field complete_arg? string|fun() argument to complete='custom'
---@field range? "'1'"|"'0'"|"'%'"|"'.'" items in cmd range
---@field count? number count given to command
---@field addr? Command.Addr_t -range helper

---Arguments to building a command
---@class Command.Builder
---@field addr?      Command.Addr_t -range helper
---@field bang?       boolean cmd can take a "!" modifier
---@field bar?        boolean cmd can be followed by "|" and another cmd
---@field nargs?      Command.Nargs number of arguments to cmd
---@field range?     number|"'%'"|boolean items in cmd range (conflicts: count)
---@field count?     number count supplied to cmd (conflicts: range)
---@field register?   Register|bool first arg can be an optional register name
---@field keepscript? boolean use location of invocation for verbose
---@field desc       string description of the cmd
---@field force?      boolean override existing definition
---@field complete? Command.Complete_t|Command.Complete.Fn|Command.Complete.Fn.List completion for cmd
---@field preview? boolean|fun(opts: Command.Fn.Args, ns: string, buf: bufnr): Command.Preview.Ret preview callback for 'inccomand'
---@field notify?    boolean [Custom]: notify of errors
local CommandBuilder = {}

---Arguments passed to the callback in the command builder
---@class Command.Fn.Args
---@field name          string command name
---@field args          string args passed to command (<args>)
---@field fargs         string[] args split by whitespace (<fargs>)
---@field mods          Command.Mods command modifiers (<mods>)
---@field smods         Command.SMods command mods in structured format
---@field bang          boolean if executed with `!` (<bang>)
---@field line1         linenr starting line of command range (<line1>)
---@field line2         linenr final line of command range (<line2>)
---@field range?        Command.range|"'%'" num of items in command range (<range>)
---@field count?        number any count supplied (<count>)
---@field register      Register|bool optional register (<reg>)
---@field definition?   string (may not exist) command definition
---@field nargs         Command.Nargs (MNE) number of arguments to cmd
---@field keepscript    boolean use location of invocation for verbose
---@field complete?     Command.Complete_t (may not exist) completion for cmd
---@field complete_arg? string|fun(a, c, p) (MNE) fn name; argument to complete='custom'
---@field preview       boolean|fun(opts: Command.Fn.Args, ns: string, buf: bufnr): Command.Preview.Ret preview callback for 'inccomand'
local CommandFnArgs = {}

---@alias Command.range            {[1]: line_t, [2]: line_t}
---@alias Command.Complete.Fn      fun(arglead: string, cmdline: string, cursorpos: integer):string
---@alias Command.Complete.Fn.List fun(arglead: string, cmdline: string, cursorpos: integer):string[]

-- -- ---@class CommandComplFn
-- ---Completion function for `-complete=custom`
-- ---Not necessary to filter candidates against `arglead`.
-- ---@param arglead string leading part of arg currently being completed
-- ---@param cmdline string entire command line
-- ---@param cursorpos integer cursor position in it (byte index)
-- ---@return string candidates newline separated
-- function Command.Complete.Fn(arglead, cmdline, cursorpos)
-- end
--
-- -- ---@class CommandComplListFn
-- ---Completion function for `-complete=listcustom`
-- ---Should filter candidates in `arglead`.
-- ---@param arglead string leading part of arg currently being completed
-- ---@param cmdline string entire command line
-- ---@param cursorpos integer cursor position in it (byte index)
-- ---@return string[] candidates
-- function Command.Complete.Fn.List(arglead, cmdline, cursorpos)
-- end

---Command modifiers in structured format
---@class Command.SMods
---@field browse?       bool  display browser
---@field confirm?      bool  confirm each execution of command
---@field hide?         bool  hide buffer?
---@field sandbox?      bool
---@field keepalt?      bool  execute and keep same alt-file
---@field keepjumps?    bool  execute without modifying jumplist/changelist
---@field keepmarks?    bool  only effects filter command
---@field keeppatterns? bool  execute without adding to search history
---@field lockmarks?    bool  execute without adjusting marks
---@field noautocmd?    bool  turn off autocmds for command
---@field noswapfile?   bool  turn off swapfile for command
---@field emsg_silent?  bool  do not display output unless an error
---@field silent?       bool  do not display any output
---@field tab?          tabnr specify a tabnr to act on
---@field unsilent?     bool  remove silent flag
---@field verbose?      int   display extra information
---@field split?        str   split
---@field horizontal?   bool  horizontal split
---@field vertical?     bool  vertical split
local CommandSMods = {}

---Command modifiers
---@class Command.Mods
---@field aboveleft?    bool opened left or above
---@field belowright?   bool opened right or below
---@field botright?     bool opened bottom or right
---@field browse?       bool opened file selection dialog
---@field confirm?      bool opened confirm dialog
---@field hide?         bool buffer is hidden
---@field horizontal?   bool opened horizontally
---@field keepalt?      bool kept alt file name
---@field keepjumps?    bool kept jumps
---@field keepmarks?    bool kept marks
---@field keeppatterns? bool didn't add to search history
---@field leftabove?    bool opened left or above
---@field lockmarks?    bool marks weren't adjusted
---@field noautocmd?    bool no autocmds were fired
---@field noswapfile?   bool didn't create a swapfile
---@field rightbelow?   bool opened right or below
---@field sandbox?      bool executed in a sandbox
---@field silent?       bool no output was diplayed
---@field tab?          bool opened in a new tab
---@field topleft?      bool opened top or left
---@field unsilent?     bool reversed 'silent'
---@field verbose?      bool executed verbosely
---@field vertical?     bool opened vertically
local CommandMods = {}

---Raw command options in the correct order.
---Could be given to the function that creates commands and it would be created.
---@alias Command.Prototype Command.Prototype.named|Command.Prototype.array
---@alias Command.Prototype.array {[1]: string, [2]: string|fun(args: Command.Fn.Args), [3]: Command.Builder|nil}

---@class Command.Prototype.named
---@field name string
---@field rhs string|fun(args: Command.Fn.Args)
---@field opts? Command.Builder

---Number of arguments to a command (`com! -nargs=`)
---@alias Command.Nargs
---| 0      # no arguments are allowed (default)
---| 1      # one arg is required, includes spaces
---| '*'    # any number of args are allowed, sep by space
---| '?'    # 0 or 1 args are allowed
---| '+'    # args are required, any number can be supplied
---| number # number of arguments allowed

---Command `-range` helper (`com! -addr=`)
---@alias Command.Addr_t
---| '"lines"'           # range of lines (default: -range)
---| '"arguments"'       # range for arguments
---| '"buffers"'         # range for buffers (also not loaded buffers)
---| '"loaded_buffers"'  # range for loaded buffers
---| '"windows"'         # range for windows
---| '"tabs"'            # range for tab pages
---| '"quickfix"'        # range for quickfix entries
---| '"other"'           # others (".", "$", "%") (default: -count)
---| '"arg"'             # range for arguments
---| '"buf"'             # range for buffers (also not loaded buffers)
---| '"load"'            # range for loaded buffers
---| '"win"'             # range for windows
---| '"tab"'             # range for tab pages
---| '"qf"'              # range for quickfix entries
---| "'?'"               # others (".", "$", "%") (default: -count)

---Command completion type
---@alias Command.Complete_t
---| '"arglist"'       # file names in argument list
---| '"augroup"'       # autocmd groups
---| '"buffer"'        # buffer names
---| '"behave"'        # :behave suboptions
---| '"color"'         # color schemes
---| '"command"'       # Ex command (and arguments)
---| '"compiler"'      # compilers
---| '"dir"'           # directory names
---| '"environment"'   # environment variable names
---| '"event"'         # autocommand events
---| '"expression"'    # Vim expression
---| '"file"'          # file and directory names
---| '"file_in_path"'  # file and directory names in 'path'
---| '"filetype"'      # filetype names 'filetype'
---| '"function"'      # function name
---| '"help"'          # help subjects
---| '"highlight"'     # highlight groups
---| '"history"'       # :history suboptions
---| '"locale"'        # locale names (as output of locale -a)
---| '"lua"'           # Lua expression
---| '"mapclear"'      # buffer argument
---| '"mapping"'       # mapping name
---| '"menu"'          # menus
---| '"messages"'      # ':messages' suboptions
---| '"option"'        # options
---| '"packadd"'       # optional package |pack-add| names
---| '"shellcmd"'      # Shell command
---| '"sign"'          # ':sign' suboptions
---| '"syntax"'        # syntax file names |'syntax'|
---| '"syntime"'       # ':syntime' suboptions
---| '"tag"'           # tags
---| '"tag_listfiles"' # tags, fnames are shown with CTRL-D
---| '"user"'          # user names
---| '"var"'           # user variables
---| 'custom,fun(a:ArgLead, c:CmdLine, p:CursorPos)'     # custom completion
---| 'customlist,fun(a:ArgLead, c:CmdLine, p:CursorPos)' # custom completion

---@alias Command.Preview.Ret
---| 0  # no preview shown
---| 1  # preview shown without window (even w/ "inccommand=split")
---| 2  # preview shown & window is opened (if "inccommand=split").

--  ╭─────╮
--  │ Map │
--  ╰─────╯

---Actual built keymap type.
---Object that is returned from requesting a keymap with `nvim_buf_get_keymap`
---@class Keymap_t
---@field id        uuid_t      terminal keycodes for lhs
---@field buffer    buffer      buffer-local
---@field expr      Vim.bool    1 if it is an expression
---@field lhs       string      lhs as it would be typed
---@field lhsraw    string      lhs as raw bytes
---@field lhsrawalt string      lhs as raw bytes alt. (only present if diff from 'lhsraw')
---@field lnum      line_t      line number in "sid", 0 if unknown
---@field mode      Keymap.mode mode for which mapping is defined
---@field noremap   Vim.bool    1 if not remappable
---@field nowait    Vim.bool    1 if shouldn't wait for longer mappings
---@field rhs       string      rhs as it would be typed
---@field script    Vim.bool    1 if defined with <script>
---@field sid       uuid_t      script local ID, used for <sid>
---@field silent    Vim.bool    1 if silent
---@field callback  fun()|nil   reference the Lua function bound to the key
---@field desc      string      keymap description
local Keymap_t = {}

---Raw keymap options in the correct order.
---Could be given to the function that creates keymaps and it would be created.
---@alias Keymap.Prototype {[1]: Keymap.mode|Keymap.mode[], [2]: string|string[], [3]: (string|fun(): string?), [4]: Keymap.Builder?}

---Options a user passes to the function that creates key mappings
---@class Keymap.Builder
---@field unique?  bool       will fail if it isn't unique
---@field expr?    bool       inserts expression into the window
---@field script?  bool       is local to a script (`<SID>`)
---@field nowait?  bool       don't wait for keys to be pressed
---@field silent?  bool       don't show output in cmd-line window
---@field buffer? buffer     mapping is specific to a buffer
---@field remap?   bool       make mapping recursive; inverse of `noremap`
---@field cmd?     bool       make a `<Cmd>...<CR>` mapping (don't use `<Cmd>..<CR>` with this)
---@field ccmd?    bool       make a `<Cmd>call ... <CR>` mapping ("call command")
---@field ncmd?    bool       make a `<Cmd>norm ... <CR>` mapping ("normal command")
---@field nncmd?   bool       make a `<Cmd>norm! ... <CR>` mapping ("normal noremap command")
---@field lcmd?    bool       make a `<Cmd>lua ... <CR>` mapping ("Lua command")
---@field vlua?    bool       make a `v:lua. ...` mapping (implies `expr`)
---@field vluar?   bool       make a `v:lua.require ...` mapping (implies `expr`)
---@field cocc?    bool       make a `<Cmd>CocCommand...<CR>` mapping
---@field turbo?   bool       skip most checks to bind the mapping as quickly as possible
---@field desc?   string     describe the map; hooks to `which-key`
---@field unmap?   bool       unmap before the creating new map
---@field ignore?  bool       pass `which_key_ignore` to `which-key`; overrides `desc`
---@field buf?    buffer     alias for buffer
---@field sil?     bool       alias for silent
---@field now?     bool       alias for nowait
---@field replace_keycodes? bool     termcodes are replaced (requires: expr)
---@field cond?      any|fun():bool  condition must be met to have mapping set
---@field ft?       string|string[] filetype/list of filetypes where mapping will be created
---@field callback? fun()           Lua function to bind
local KeymapBuilder = {}

---@class Keymap.Del.Opts
---@field buffer? buffer
---@field notify? boolean
local KeymapDelOpts = {}

---@class Keymap.Search.Opts
---@field lhs?    boolean search left-hand (default: true, i.e., search rhs)
---@field buffer? buffer  only search buffer-local keymaps
---@field pcre?   boolean use pcre regex to find the keymap. if false, exact search is used
local KeymapSearchOpts = {
    lhs = true,
    buffer = false,
    pcre = false,
}

---Return value after creating a mapping.
---Allows the mapping to be disposed of easily after usage.
---@class Keymap.Disposable
---@field map     fun():self       remap key again
---@field maps    fun():Keymap_t[] list of full keymaps
---@field dispose fun()            field to call that disposses the keymap
---@field lhs     string[]         keys to be mapped
---@field buffer? bufnr            buffer local mapping
---@field modes   Keymap.mode[]

---@alias Keymap.mode
---| '"n"'  # normal
---| '"v"'  # visual and select
---| '"o"'  # operator-pending
---| '"i"'  # insert
---| '"c"'  # cmd-line
---| '"s"'  # select
---| '"x"'  # visual
---| '"l"'  # langmap
---| '"t"'  # terminal
---| '"ca"' # command abbreviation
---| '"ia"' # insert abbreviation
---| '"!a"' # command and insert abbreviation
---| '"!"'  # insert and cmd-line
---| '""'   # normal, visual, and operator-pending

--  ╭─────────╮
--  │ Autocmd │
--  ╰─────────╯

---@alias Autocmd.id uuid_t
---@alias Augroup.id uuid_t
---@alias Augroup.create {[1]: string, clear?: bool, del?: bool}

---@class Autocmd.clear
---@field clear? bool clear autocmd
---@field del?   bool delete autocmd

---Actual built autocmd type.
---Object that is returned from requesting an autocmd with `nvim_get_autocmds`
---@class Autocmd_t
---@field id         Autocmd.id       autocmd id (only when defined with the API)
---@field group      Augroup.id       autocmd group id
---@field group_name string           autocmd group name
---@field desc       string           description of autocmd
---@field event      Nvim.Event       autocmd event
---@field command    string|""        autocmd command ("" if a callback is set)
---@field callback   fun()|string|nil name of func that is ran when autocmd is executed
---@field once       boolean          whether the autocmd is only run once
---@field pattern    string           the autocmd pattern
---@field buflocal   boolean          true if the autocmd is buffer local
---@field buffer     bufnr            the buffer number
local Autocmd_t = {}

---Options a user passes to the function that creates an autocmd
---@class Autocmd.Builder
---@field event?   Nvim.Event|Nvim.Event[] list of autocmd events
---@field pattern? string|string[]       list of autocmd patterns
---@field command? string|fun(args: Autocmd.Fn.Args) command to exec (can be Lua)
---@field nested?  boolean is the autocmd nested?
---@field once?    boolean whether the autocmd is only run once
---@field buffer?  bufnr   buffer number. Conflicts with `pattern`
---@field group?   string|Augroup.id|{[1]: string, clear?: bool, del?: bool} group name or ID to match against
---@field clear?   boolean clear the autocmd based on group and event (not augroup only)
---@field del?     boolean delete the augroup before building
---@field desc?    string  description of autocmd
---@field description? string alias for *desc*, if you want to
---@field callback? string|fun(args: Autocmd.Fn.Args) Lua command to exec
local Autocmd = {}

---Options passed to the autocmd callback during autocmd creation
---@class Autocmd.Fn.Args
---@field id     Autocmd.id  autocmd id (only when defined with the API)
---@field event  Nvim.Event  name of event that triggered the autocommand
---@field group? Augroup.id autocommand group id if exists
---@field match  string     expanded value of `<amatch>`
---@field buf    bufnr      expanded value of `<abuf>`
---@field file   path_t     expanded value of `<afile>`
---@field data   any        any arbitrary data passed to `nvim_exec_autocmds`
local AutocmdFnArgs = {}

---Options given the function which executes `doautocmd`
---@class Autocmd.Exec.Opts
---@field group?    string|Augroup.id autocmd group name or id
---@field pattern?  string|string[]   pattern to match against
---@field buffer?   bufnr             buffer number
---@field modeline? boolean           process the modedeline after autocmds
---@field data?     any               data to send to autocmd callback
local AutocmdExecOpts = {}

---Autocmd request (i.e., get) options that are given to `nvim_get_autocmds`
---@class Autocmd.Req.Opts
---@field group?   string|Augroup.id       autocmd group name or id
---@field event?   Nvim.Event|Nvim.Event[] event(s) to match against
---@field pattern? string|string[]         pattern(s) to match against (conflicts: buffer)
---@field buffer?  bufnr|bufnr[]           bufnr(s) for buffer local autocmds
local AutocmdReqOpts = {}

---Options passed to `nvim_clear_autocmds`
---@class Autocmd.Clear.Opts
---@field event?   Nvim.Event|Nvim.Event[] event(s) to match against
---@field pattern? string|string[]         pattern(s) to match against (conflicts: buffer)
---@field group?   string|string[]|Augroup.id|Augroup.id[] autocmd group name or id
---@field buffer?  bufnr                   bufnr for buffer local autocmds
local AutocmdClearOpts = {}

--  ╭────────╮
--  │ Option │
--  ╰────────╯

---Options to `nvim_get_option_info2` and `nvim_get_option_value`
---@class GetOption.Opts
---@field scope    "global"|"local" analogous to `setglobal` or `setlocal`
---@field win      winid            get window-local options
---@field buf      bufnr            get buffer-local options (implies local)
---@field filetype string           get filetype-specific options

---Available scopes returned from `nvim_get_option_info2`
---@alias GetOption.scope "global"|"win"|"buf"
---Available types returned from `nvim_get_option_info2`
---@alias GetOption.type "string"|"number"|"boolean"

---Valid data types of an option
---@alias Option_t     string|number|boolean|table

---A built option type.
---Return value from `nvim_get_option_info2`
---@class GetOptionInfo_t
---@field name              string          name of option (e.g., 'filetype')
---@field shortname         string          shortened name of option (e.g., 'ft')
---@field type              GetOption.type  type of option
---@field default           Option_t        default value for the option
---@field was_set           boolean         whether the option was set
---@field last_set_sid      integer?        last set script id (if any)
---@field last_set_linenr   linenr          line number where option was set
---@field last_set_chan     number          channel where option was set (0 for local)
---@field scope             GetOption.scope one of "global", "win", or "buf"
---@field global_local      boolean         whether win or buf option has a global value
---@field commalist         boolean         list of comma separated values
---@field flaglist          boolean         list of single char flags
---@field allows_duplicates boolean         list of single char flags

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Buffer                          │
--  ╰──────────────────────────────────────────────────────────╯

---@class Extmark.VirtText.Chunk
---@field [1] string text to get highlighted
---@field [2] Highlight.Group|Color.S_t|Color.N_t single/many hl group (many get stacked)

---@alias Extmark.VirtText.Pos
---| "'eol'"        # right after EOL character (**default**)
---| "'overlay'"    # display over specified col, without shifting the underlying text
---| "'inline'"     # display at specified col, and shift the buffer text to the right as needed
---| "'right_align'"# display right aligned in the window.

---@alias Extmark.HlMode
---| "'replace'" # only show the virt_text color (**default**)
---| "'combine'" # combine with background text color
---| "'blend'"   # blend with background text color. Not supported for `inline` virt_text

---Options to `nvim_buf_set_extmark`
---@class Extmark.Set.Opts
---@field id? uuid_t id of the extmark to edit
---@field end_row? row_t ending line of the mark, 0-based **inclusive**
---@field end_col? col_t ending col of the mark, 0-based **exclusive**
---@field hl_group? Highlight.Group name of the highlight group used to highlight this mark
---@field hl_eol? bool continue hl for rest of screenline if it goes past EOL
---@field virt_text? Extmark.VirtText.Chunk[] virtual text to link to this mark
---@field virt_text_pos? Extmark.VirtText.Pos position of virtual text
---@field virt_text_win_col? col_t pos of virt text at a fixed window col instead of `virt_text_pos`
---@field virt_text_hide? bool hide virt text when bg text selected/hidden bc 'nowrap', 'smoothscroll'
---@field hl_mode?    Extmark.HlMode           how hl are combined with hls of text hls
---@field virt_lines? Extmark.VirtText.Chunk[] virtual lines to add next to this mark ([text, highlight] tuples)
---@field virt_lines_above?   bool place virtual lines above instead
---@field virt_lines_leftcol? bool place extmarks in leftmost col, bypassing sign & number columns
---@field right_gravity?      bool dir extmark shifts when new text is inserted (true=right, false=left) (**true**)
---@field end_right_gravity?  bool dir extmark end pos (if it exists) shifts when new text is inserted (**false**)
---@field priority?  int priority value for the highlight group or sign attribute
---@field strict?    bool shouldn't be placed if line/col is past EOB/EOL respectively (**true**)
---@field spell?     bool spell checking should be performed within this extmark
---@field conceal?   string empty or single char; enable concealing similar; `hl_group` used to highlight
---@field sign_text? string length 1-2; display in the signcolumn
---@field sign_hl_group?       Highlight.Group used to highlight the sign column text
---@field number_hl_group?     Highlight.Group used to highlight the number column
---@field line_hl_group?       Highlight.Group used to highlight the whole line
---@field cursorline_hl_group? Highlight.Group when cursor on the same line as mark and 'cursorline' is enabled
---@field ui_watched? bool mark should be drawn by a UI; when set, the UI will receive win_extmark events
---@field ephemeral?  bool for use with |nvim_set_decoration_provider()| callbacks. current redraw cycle

---@alias BufType
---| "''"         # normal buffer
---| "'acwrite'"  # buffer will always be written with `BufWriteCmd`
---| "'help'"     # help buffer
---| "'nofile'"   # buffer is not related to a file, will not be written
---| "'nowrite'"  # buffer will not be written
---| "'quickfix'" # list of errors `cwindow` or locations `lwindow`
---| "'terminal'" # terminal-emulator buffer
---| "'prompt'"   # only the last line can be edit see `prompt-buffer`

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Window                          │
--  ╰──────────────────────────────────────────────────────────╯

---@alias WinType
---| '""'          # normal window
---| '"autocmd"'   # autocommand window. Temp win used to execute autocommands
---| '"command"'   # command-line window
---| '"loclist"'   # location list window
---| '"popup"'     # floating window
---| '"preview"'   # preview window
---| '"quickfix"'  # quickfix window
---| '"unknown"'   # winnr not found

--  ╭──────╮
--  │ Abbr │
--  ╰──────╯

---@class Abbr.Opts
---@field expr?       bool
---@field buffer?     bufnr
---@field silent?     bool
---@field only_start? bool

--  ╭──────────╮
--  │ Feedkeys │
--  ╰──────────╯

---@alias Feedkeys.mode
---| "'m'" # Remap keys
---| "'n'" # Do not remap keys
---| "'t'" # Handle keys as if typed
---| "'i'" # Insert string instead of append
---| "'x'" # Execute command similar to `:normal!`

--  ╭────────╮
--  │ SetReg │
--  ╰────────╯

---Options that can be given to `setreg`
---@alias SetRegOpts
---| '"c"' # charwise
---| '"v"' # charwise
---| '"l"' # linewise
---| '"V"' # linewise
---| '"b"' # blockwise
---| '"u"' # unnamed
---| '"'   # unnamed

---Registers in neovim
---@alias Register
---| '"*"'  # PRIMARY selection register
---| '"+"'  # CLIPBOARD selection register
---| '""'   # unnamed; points to last register
---| '"-"'  # small-delete; deleted text less than 1 line
---| '":"'  # most recent executed command; readonly
---| '"."'  # most recent inserted text; readonly
---| '"/"'  # most recent search pattern
---| '"%"'  # current file name; readonly
---| '"#"'  # alternate file name
---| '"="'  # expression register
---| '"_"'  # blackhole; not recorded
---| '"0"'  # register 0; most recent
---| '"1"'  # register 1
---| '"2"'  # register 2
---| '"3"'  # register 3
---| '"4"'  # register 4
---| '"5"'  # register 5
---| '"6"'  # register 6
---| '"7"'  # register 7
---| '"8"'  # register 8
---| '"9"'  # register 9
-- "a .. "z = 26 named registers
-- "A .. "Z = 26 named registers (append)

--  ╭──────────────────────────────────────────────────────────╮
--  │                      Autocmd Events                      │
--  ╰──────────────────────────────────────────────────────────╯

---@alias Nvim.Event
---| '"BufNewFile"' # starting to edit a file that doesn't exist
---| '"BufReadPre"' # starting to edit new buffer, before reading file. not used if file doesn't exist
---| '"BufRead"' # starting to edit new buffer, after reading file, before processing modelines
---| '"BufReadPost"' # starting to edit new buffer, after reading file, before processing modelines
---| '"BufReadCmd"' # before starting to edit a new buffer. should read file into buffer
---| '"FileReadPre"' # before reading file with `:read`
---| '"FileReadPost"' # after reading file with `:read`; sets `'[` and `']` to first/last line read. can be used to operate on lines just read
---| '"FileReadCmd"' # before reading file with `:read`. should do reading of file
---| '"FilterReadPre"' # before reading file from `:filter`
---| '"FilterReadPost"' # after reading file from `:filter`
---| '"StdinReadPre"' # during startup, before reading from stdin into buffer
---| '"StdinReadPost"' # during startup, after reading from stdin into buffer, before executing modelines
---| '"BufWrite"' # starting to write the whole buffer to a file
---| '"BufWritePre"' # before starting to write whole buffer to file
---| '"BufWritePost"' # after writing whole buffer to file (should undo commands for `BufWritePre`)
---| '"BufWriteCmd"' # Before writing whole buffer to file
---| '"FileWritePre"' # starting to write part of buffer to a file
---| '"FileWritePost"' # after writing part of buffer to a file
---| '"FileWriteCmd"' # before writing part of buffer to a file. should do writing to the file, and should not change buffer
---| '"FilterWritePre"' # starting to write file for `:filter` or making diff with an external diff
---| '"FilterWritePost"' # after writing file for `:filter` or making diff with an external diff
---| '"FileAppendPre"' # starting to append to file. use `'[` and `']` marks for range of lines
---| '"FileAppendPost"' # after appending to file
---| '"FileAppendCmd"' # before appending to file. should do the appending to file.  use `'[` and `']` marks for range of lines
---| '"BufAdd"' # just after creating/adding/renaming buffer which is added to buflist. before `BufEnter`
---| '"BufDelete"' # before deleting buffer from buflist
---| '"BufWipeout"' # before completely deleting buffer from buflist
---| '"BufCreate"' # [VIM] just after adding a buffer to the buffer list
---| '"BufFilePre"' # before changing name of curbuf with `:file` or `:saveas`
---| '"BufFilePost"' # after changing name of curbuf with `:file` or `:saveas`
---| '"BufEnter"' # after entering buffer. after `BufAdd` and `BufReadPost`
---| '"BufLeave"' # before leaving to another buffer; when leaving/closing curwin and new curwin is not for same buf
---| '"BufWinEnter"' # after buffer is displayed in window
---| '"BufWinLeave"' # before buffer is removed from window, not when still visible in another window
---| '"BufUnload"' # before unloading buffer, when text in buffer is going to be freed. after `BufWritePost`; before `BufDelete`
---| '"BufHidden"' # just before buffer becomes hidden: no longer wins that show buffer, but buffer is not unloaded or deleted
---| '"BufNew"' # just after creating new buffer / renaming buffer
---| '"BufModifiedSet"' # after `modified` value of buf has been changed
---| '"SwapExists"' # detected existing swapfile when editing file (`v:swapname`: swapfile name; `v:swapcommand`, `v:swapchoice`) (`<afile>`: file being edited)
---| '"FileType"' # 'filetype' option has been set. pattern is matched against filetype
---| '"Syntax"' # when 'syntax' option has been set (*P*: syntax name) (`<afile>`: filename where set; `<amatch>`: where opt set)
---| '"OptionSet"' # after setting an option (except during startup)
---| '"EncodingChanged"' # [VIM] after the 'encoding' option has been changed
---| '"TermChanged"' # [VIM] after the value of 'term' has changed
---| '"VimEnter"' # after doing all startup stuff, including loading vimrc files (*A*: `v:vim_did_enter)
---| '"TermResponse"' # after response to `t_RV` is received from terminal
---| '"UIEnter"' # [NVIM] after UI connects via `nvim_ui_attach()`, or after TUI is started (*A*: `VimEnter`) (`v.event`: chan)
---| '"UILeave"' # [NVIM] after UI disconnects from Nvim, or after TUI is stopped (*A*: `VimLeave`) (`v.event`: chan)
---| '"GUIEnter"' # [VIM] after starting the GUI successfully
---| '"GUIFailed"' # [VIM] after starting the GUI failed
---| '"QuitPre"' # using `:quit`, `:wq` or `:qall`; before deciding whether it closes curwin or quits Vim
---| '"ExitPre"' # using `:quit`, `:wq` in way it makes Vim exit, or using `:qall`, just after `QuitPre`
---| '"VimLeavePre"' # before exiting Vim, just before writing the .shada file; once (`v:dying`, `v:exiting`)
---| '"VimLeave"' # before exiting Vim, just after writing the .shada file; once (`v:dying`, `v:exiting`)
---| '"VimSuspend"' # before Nvim enters `suspend` state
---| '"VimResume"' # Nvim resumes from `suspend` state
---| '"TermOpen"' # [NVIM] when `terminal` job is starting
---| '"TermEnter"' # [NVIM] after entering `Terminal-mode`. after `TermOpen`
---| '"TermLeave"' # [NVIM] after leaving `Terminal-mode`. after `TermClose`
---| '"TermClose"' # [NVIM] when `terminal` job ends (`v.event`: status)
---| '"TerminalOpen"' # [VIM] after a `terminal` buffer was created
---| '"TerminalWinOpen"' # [VIM] after a `terminal` buffer was created in a new window
---| '"FileChangedShell"' # Vim notices that modification time of file has changed since editing started
---| '"FileChangedShellPost"' # after handling file that was changed outside of Vim.  can be used to update statusline
---| '"FileChangedRO"' # before making first change to read-only file
---| '"DiffUpdated"' # after diffs have been updated.
---| '"DirChangedPre"' # when cwd is going to be changed, as with `DirChanged` (`v.event`: directory, scope, changed_window)
---| '"DirChanged"' # after cwd changed (*P*: "window:`:lcd`, "tabpage":`:tcd`, "global":`:cd`, "auto":'autochdir') (`v.event`: cwd, scope, changed_window)
---| '"ShellCmdPost"' # after exec shell command with `:!cmd`, `:make`, `:grep`
---| '"ShellFilterPost"' # after exec shell command with `:{range}!cmd`, `:w !cmd`, `:r !cmd`
---| '"CmdUndefined"' # user command is used but it isn't defined (*P*: command name)
---| '"FuncUndefined"' # user function is used but it isn't defined (*P*: func name) (`<amatch>,` `<afile>` = func name)
---| '"SpellFileMissing"' # when trying to load spellfile and it can't be found (*P*: language) (`<amatch>` = language)
---| '"SourcePre"' # before sourcing vim/lua file (`<afile>`: filename)
---| '"SourcePost"' # after sourcing vim/lua file (`<afile>`: filename)
---| '"SourceCmd"' # when sourcing vim/lua file (`<afile>`: filename)
---| '"VimResized"' # after Vim window was resized
---| '"FocusGained"' # nvim got focused
---| '"FocusLost"' # nvim lost focus. also when GUI dialog pops up
---| '"CursorHold"' # user doesn't press key for time of `updatetime` (*M*: NV)
---| '"CursorHoldI"' # `CursorHold`, but in Insert mode (*M*: I)
---| '"CursorMoved"' # after cursor moved in Normal/Visual mode or to another win. also text of cursor line changes (e.g. "x", "rx", "p") (*M*: NV)
---| '"CursorMovedI"' # after cursor was moved in Insert mode; not when PUM is visible (*M*: I)
---| '"WinNew"' # when creating new window; not for first window (*B*: `WinEnter`)
---| '"TabNew"' # when creating new tab page (*A*: `WinEnter`, *B*: `TabEnter`)
---| '"WinClosed"' # when closing window, just before removed from win layout (*A*: `WinLeave`, *P*: `winid`) (`<amatch>`, `<afile>`: `winid`)
---| '"TabClosed"' # after closing tab page
---| '"WinEnter"' # after entering another window. not for first window
---| '"WinLeave"' # before leaving window (*B*: `WinClosed`)
---| '"TabEnter"' # just after entering tab page (*A*: `WinEnter`, *B*: `BufEnter`)
---| '"TabLeave"' # just before leaving tab page (*A*: `WinLeave`)
---| '"TabNewEntered"' # [NVIM] after entering new tab page (*A*: `BufEnter`)
---| '"CmdwinEnter"' # after entering cli-win (`<afile>`: type of)
---| '"CmdwinLeave"' # before leaving cli-win (`<afile>`: type of)
---| '"CmdlineChanged"' # after change made to text inside command line
---| '"CmdlineEnter"' # after entering cli (include ":" in map: use `<Cmd>` instead) (`v.event`: cmdlevel, cmdtype)
---| '"CmdlineLeave"' # before leaving cli (include ":" in map: use `<Cmd>` instead) (`v.event`: abort, cmdlevel, cmdtype)
---| '"WinScrolled"' # after any window in current tab page scrolled text or changed width or height
---| '"WinResized"' # after window in current tab page changed width or height
---| '"InsertEnter"' # just before starting Insert mode. also for Replace mode and Virtual Replace mode
---| '"InsertChange"' # typing `<Insert>` while in Insert or Replace mode
---| '"InsertLeave"' # just after leaving Insert mode. also when using `CTRL-O`
---| '"InsertLeavePre"' # just before leaving Insert mode. also when using `CTRL-O`
---| '"InsertCharPre"' # when char is typed in Insert mode, before inserting char.
---| '"ModeChanged"' # after changing mode (*P*: `old_mode:new_mode`) (`{v.event}`: old_mode, new_mode)
---| '"TextChanged"' # after text change made to curbuf (*M*: N) (*A*: `b:changedtick`)
---| '"TextChangedI"' # after text change made to curbuf (*M*: I)
---| '"TextChangedP"' # after text change made to curbuf when PUM is visible (*M*: I)
---| '"TextChangedT"' # after text change made to curbuf (*M*: T)
---| '"TextYankPost"' # just after `yank`/`delete`, not if blackhole reg or `setreg()` (`v.event`: inclusive, operator, regcontents, regname, regtype, visual)
---| '"SafeState"' # [VIM] nothing pending, going to wait for the user to type a character
---| '"SafeStateAgain"' # [VIM] repeated SafeState
---| '"ColorSchemePre"' # before loading colorscheme
---| '"ColorScheme"' # after loading colorscheme (*P*: colorscheme name)
---| '"RemoteReply"' # a reply from a server Vim was received (`<amatch>`: serverid, `<afile>`: reply)
---| '"ChanInfo"' # state of channel changed (`{v.event}`: info)
---| '"ChanOpen"' # just after channel was opened (`{v.event}`: info)
---| '"QuickFixCmdPre"' # before quickfix command is run (*P*: command being run)
---| '"QuickFixCmdPost"' # like `QuickFixCmdPre`, but after quickfix command is run, before jumping to first location
---| '"SessionLoadPost"' # after loading session file created using `:mksession`
---| '"MenuPopup"' # just before showing popup menu (*P*: n, v, o, i, c, tl)
---| '"CompleteChanged"' # after each time I mode compl menu changed (`{v.event}`: completed_item, height, width, row, col, size, scrollbar?)
---| '"CompleteDonePre"' # after I-mode compl is done. before clearing info (`v:completed_item`)
---| '"CompleteDone"' # after I-mode compl is done. after clearing info (`v:completed_item`)
---| '"User"' # to be used in combination with ":doautocmd"
---| '"Signal"' # [NVIM] after Nvim receives signal (*P*: signal name)
---| '"SigUSR1"' # [VIM] after the SIGUSR1 signal has been detected
---| '"SearchWrapped"' # after making search with `n`/`N` if the search wraps around document
---| '"RecordingEnter"' # macro starts recording
---| '"RecordingLeave"' # macro stops recording (`v.event`: regcontents, regname)
---| '"UserGettingBored"' # when user presses same key 42 times
