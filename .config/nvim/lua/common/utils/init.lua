--@module common.utils
---@description: Utility functions that are used in multiple files
---              They are a higher-level set than `dev`

local M = {}

local D = require("dev")
local log = require("common.log")
local debounce = require("common.debounce")
local disposable = require("common.disposable")
local style = require("style")
local dirs = require("common.global").dirs

local wk = require("which-key")
local uva = require("uva")
local async = require("async")

local ex = nvim.ex
local uv = vim.loop
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local F = vim.F

-- require("plenary.strings").align_str(string: any, width: any, right_justify: any)
-- require("plenary.strings").dedent(str: any, leave_indent: any)
-- require("plenary.strings").truncate(str: string, len: any, dots: any, direction: any)
-- require("plenary.strings").strdisplaywidth(string, col)

---Safely check if a plugin is installed
---@param name string Module to check if is installed
---@param cb function
---@return table Module
M.prequire = function(name, cb)
    local ok, ret = pcall(require, name)
    if ok then
        if cb and type(cb) == "function" then
            cb(ret)
        end
        return ret
    else
        M.notify(("Invalid module %s"):format(name), log.levels.WARN)
        -- Return a dummy item that returns functions, so we can do things like
        -- prequire("module").setup()
        local dummy = {}
        setmetatable(
            dummy,
            {
                __call = function()
                    return dummy
                end,
                __index = function()
                    return dummy
                end
            }
        )
        return dummy
    end
end

---Call the given function and use `vim.notify` to notify of any errors
---this function is a wrapper around `xpcall` which allows having a single
---error handler for all errors
---@param msg string|fun()|nil
---@param func function
---@vararg any
---@return boolean, any
---@overload fun(fun: function, ...): boolean, any
M.wrap_err = function(msg, func, ...)
    local args = {...}
    if type(msg) == "function" then
        args, func, msg = {func, unpack(args)}, msg, nil
    end
    return xpcall(
        func,
        function(err)
            msg = msg and ("%s:\n%s"):format(msg, err) or err
            vim.schedule(
                function()
                    vim.notify(msg, log.levels.ERROR, {title = "ERROR"})
                end
            )
        end,
        unpack(args)
    )
end

---Return a value based on two values
---@generic T, V
---@param condition boolean|nil Statement to be tested
---@param is_if T Return if condition is truthy
---@param is_else V Return if condition is not truthy
---@return T|V
F.tern = function(condition, is_if, is_else)
    if condition then
        return is_if
    else
        return is_else
    end
end

---Similar to `vim.F.nil` except that an alternate default value can be given
---@param x any: Value to check if `nil`
---@param is_nil any: Value to return if `x` is `nil`
---@param is_not_nil any: Value to return if `x` is not `nil`
M.ife_nil = function(x, is_nil, is_not_nil)
    return F.tern(x == nil, is_nil, is_not_nil)
end

---Return a default value if `x` is nil
---@generic T, V
---@param x T: Value to check if not `nil`
---@param default V: Default value to return if `x` is `nil`
---@return T|V
M.get_default = function(x, default)
    return M.ife_nil(x, default, x)
end

---Execute a command in normal mode. Equivalent to `norm! <cmd>`
---@param mode string
---@param motion string
M.normal = function(mode, motion)
    -- local sequence = M.t(motion, true, false, false)
    -- nvim.feedkeys(sequence, mode, true)
    api.nvim_feedkeys(M.termcodes[motion], mode, false)
end

---Set the (1,0)-indexed cursor position without having to worry about
---out-of-bounds coordinates. The line number is clamped to the number of lines
---in the target buffer.
---@param winid integer
---@param line? integer
---@param column? integer
M.set_cursor = function(winid, line, column)
    local bufnr = api.nvim_win_get_buf(winid)

    pcall(
        api.nvim_win_set_cursor,
        winid,
        {
            D.clamp(line or 1, 1, api.nvim_buf_line_count(bufnr)),
            math.max(0, column or 0)
        }
    )
end

---Create an augroup with the lua api
---@param name string
---@param clear boolean
---@return number
M.create_augroup = function(name, clear)
    clear = clear == nil and true or clear
    return api.nvim_create_augroup(name, {clear = clear})
end

---@class AutocommandOpts
---@field id number autocommand id
---@field event string name of event that triggered the autocommand
---@field group number|nil autocommand group id if exists
---@field match string expanded value of `<amatch>`
---@field buf number expanded value of `<abuf>`
---@field file string expanded value of `<afile>`
---@field data any any arbitrary data passed to `nvim_exec_autocmds`

---@class Autocommand
---@field desc    string?         Description of the `autocmd`
---@field event   string|string[] List of autocommand events
---@field pattern string|string[] List of autocommand patterns
---@field command string|fun(args: AutocommandOpts)
---@field nested  boolean
---@field once    boolean
---@field buffer  number        Buffer number. Conflicts with `pattern`
---@field group   string|number Group name or ID to match against
---@field description string?   Alternative to `self.desc`

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string|table: Augroup name. If a table, `true` can be passed to clear the group
---@param ... Autocommand[]
---@return number: Group ID of the autocommand
M.augroup = function(name, ...)
    local id
    -- If name is a table, user wants to probably not clear the augroup
    if type(name) == "table" then
        id = M.create_augroup(name[1], name[2])
    else
        id = M.create_augroup(name)
    end

    for _, autocmd in ipairs({...}) do
        M.autocmd(autocmd, id)
    end

    return id
end

---Create a single autocmd
---@param autocmd Autocommand
---@param id? number Group ID of the `autocmd`
---@return Disposable
M.autocmd = function(autocmd, id)
    local is_callback = type(autocmd.command) == "function"
    local autocmd_id =
        api.nvim_create_autocmd(
        autocmd.event,
        {
            group = F.if_nil(id, autocmd.group),
            pattern = autocmd.pattern,
            desc = autocmd.desc or autocmd.description,
            callback = F.tern(is_callback, autocmd.command, nil),
            command = F.tern(not is_callback, autocmd.command, nil),
            once = autocmd.once,
            nested = autocmd.nested,
            buffer = autocmd.buffer
        }
    )

    return disposable:create(
        function()
            api.nvim_del_autocmd(autocmd_id)
        end,
        {
            id = autocmd_id
        }
    )
end

---@class MapArgs
---@field unique boolean
---@field expr boolean
---@field script boolean
---@field nowait boolean
---@field silent boolean
---@field buffer boolean|number
---@field replace_keycodes boolean
---@field remap boolean
---@field callback function
---@field cmd boolean
---@field luacmd boolean
---@field desc string

---@class DelMapArgs
---@field buffer boolean|number
---@field notify boolean

---Create a key mapping
---If the `rhs` is a function, and a `bufnr` is given, the argument is instead moved into the `opts`
---
---@param modes string|string[]: Modes the keymapping should be bound
---@param lhs string: Keybinding that is mapped
---@param rhs string|function: String or Lua function that will be bound to a key
---@param opts MapArgs: Options given to keybindings
---@return { map: fun(), dispose: fun() }: Returns a table with a single key `dispose` which can be ran to remove
---these bindings. This can be used for temporary keymaps
---
--- See: **:map-arguments**
---
--- ## Options
--- - `unique`: (boolean, default false) Mapping will fail if it isn't unique
--- - `expr`: (boolean, default false) Inserts expression into the window
--- - `script`: (boolean, default false) Mapping is local to a script (`<SID>`)
--- - `nowait`: (boolean, default false) Do not wait for keys to be pressed
--- - `silent`: (boolean, default false) Do not echo command output in CmdLine window
--- - `buffer`: (boolean|number, default nil) Make the mapping specific to a buffer
---
--- - `replace_keycodes`: (boolean, default true) When this and `expr` are true, termcodes are replaced
--- - `remap`: (boolean, default false) Make the mapping recursive. Inverse of `noremap`
--- - `callback`: (function, default nil) Use a Lua function to bind to a key
--- - `unmap`: (boolean, default false) Unmap the given default before the new one is set
---
--- - `cmd`: (boolean, default false) Make the mapping a `<Cmd>` mapping (do not use `<Cmd>`..<CR> with this)
--- - `luacmd`: (boolean, default false) Make the mapping a `<Cmd>lua` mapping (do not use `<Cmd>`..<CR> with this)
--- - `desc`: (string) Describe the keybinding, this hooks to `which-key`
M.map = function(modes, lhs, rhs, opts)
    vim.validate {
        mode = {modes, {"s", "t"}},
        lhs = {lhs, "s"},
        rhs = {rhs, {"s", "f"}},
        opts = {opts, "t", true}
    }

    -- TODO: Add an unmap feature

    opts = vim.deepcopy(opts) or {}
    modes = type(modes) == "string" and {modes} or modes

    if opts.remap == nil then
        if opts.noremap ~= false then
            opts.noremap = true
        end
    else
        -- remaps behavior is opposite of noremap option
        opts.noremap = not opts.remap
        opts.remap = nil
    end

    rhs = (function()
        if type(rhs) == "function" then
            if opts.expr then
                local og_rhs = rhs
                rhs = function()
                    local res = og_rhs()
                    if res == nil then
                        return ""
                    elseif opts.replace_keycodes ~= false then
                        return M.t(res)
                    else
                        return res
                    end
                end
            end

            opts.callback = rhs
            rhs = ""
        else
            if rhs:lower():sub(1, #"<plug>") == "<plug>" then
                opts.noremap = false
            end

            if opts.cmd then
                opts.cmd = nil
                rhs = ("<Cmd>%s<CR>"):format(rhs)
            end

            -- This is placed after `cmd`
            -- If `cmd` and `luacmd` are both used, `luacmd` overrules
            if opts.luacmd then
                opts.luacmd = nil
                rhs = ("<Cmd>lua %s<CR>"):format(rhs)
            end
        end

        opts.replace_keycodes = nil
        return rhs
    end)()

    local bufnr = (function()
        local b = F.tern(opts.buffer, 0, opts.buffer)
        opts.buffer = nil
        return b
    end)()

    if bufnr or type(bufnr) == "number" then
        for _, mode in ipairs(modes) do
            if opts.unmap then
                opts.unmap = nil

                for _, mode in ipairs(modes) do
                    -- local exists = M.get_keymap(mode, lhs, true, F.tern(bufnr or type(bufnr) == "number", true, false))
                    if fn.hasmapto(lhs, mode) > 1 then
                        M.del_keymap(mode, lhs, {notify = true, buffer = bufnr})
                    end
                end
            end

            if opts.desc then
                wk.register({[lhs] = opts.desc}, {mode = mode, buffer = bufnr})
            end

            api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end
    else
        if opts.unmap then
            opts.unmap = nil

            for _, mode in ipairs(modes) do
                -- local exists = M.get_keymap(mode, lhs, true, F.tern(bufnr or type(bufnr) == "number", true, false))
                if fn.hasmapto(lhs, mode) > 1 then
                    M.del_keymap(mode, lhs, {notify = true})
                end
            end
        end

        for _, mode in ipairs(modes) do
            if opts.desc then
                wk.register({[lhs] = opts.desc}, {mode = mode})
            end

            api.nvim_set_keymap(mode, lhs, rhs, opts)
        end
    end

    return disposable:create(
        function()
            M.del_keymap(modes, lhs, {buffer = bufnr})
        end,
        {
            map = function()
                local mode = modes[1]
                return M.get_keymap(mode, lhs, true, F.tern(bufnr or type(bufnr) == "number", true, false))
            end
        }
    )
end

---Create a buffer key mapping
---@param bufnr number Buffer ID
---@param modes string|table<string> Modes the keymapping should be bound
---@param lhs string Keybinding that is mapped
---@param rhs string|function String or Lua function that will be bound to a key
---@param opts MapArgs Options given to keybindings
---@return { map: fun(), dispose: fun() }: Returns a table with a single key `dispose` which can be ran to remove
M.bmap = function(bufnr, modes, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = bufnr
    return M.map(modes, lhs, rhs, opts)
end

---Delete a keymapping
---@param modes string|string[]: Modes to be deleted
---@param lhs string: Keybinding that is to be deleted
---@param opts DelMapArgs: Options given to keybindings
M.del_keymap = function(modes, lhs, opts)
    vim.validate {
        mode = {modes, {"s", "t"}},
        lhs = {lhs, "s"},
        opts = {opts, "t", true}
    }

    opts = vim.deepcopy(opts) or {}
    modes = type(modes) == "string" and {modes} or modes

    local bufnr = false
    if opts.buffer ~= nil then
        ---@diagnostic disable-next-line:cast-local-type
        bufnr = opts.buffer == true and 0 or opts.buffer
    end

    if bufnr == false then
        for _, mode in ipairs(modes) do
            local ok = pcall(api.nvim_del_keymap, mode, lhs)
            if not ok and opts.notify then
                log.warn(("%s is not mapped"):format(lhs), true, {title = "Delete Keymap"})
            end
        end
    else
        for _, mode in ipairs(modes) do
            local ok = pcall(api.nvim_buf_del_keymap, bufnr, mode, lhs)
            if not ok and opts.notify then
                log.warn(("%s is not mapped"):format(lhs), true, {title = "Delete Keymap"})
            end
        end
    end
end

---Get a given keymapping
---@param mode string mode to search for keymapping
---@param search? string lhs or rhs to search for
---@param lhs? boolean search left-hand side or not
---@param buffer? boolean buffer-local keymaps
---@return table
M.get_keymap = function(mode, search, lhs, buffer)
    lhs = M.get_default(lhs, true)
    local res = {}
    local keymaps = F.tern(buffer, api.nvim_buf_get_keymap(0, mode), api.nvim_get_keymap(mode))
    if search == nil then
        return keymaps
    end

    for _, keymap in ipairs(keymaps) do
        if lhs and keymap.lhs == search then
            table.insert(res, keymap)
        elseif not lhs and keymap.rhs == search then
            table.insert(res, keymap)
        end
    end

    return #res == 1 and res[1] or res
end

---Reset a keymap by mapping it back to itself
---@param mode string mode to reset the keybinding in
---@param lhs string keybinding to reset
---@param opts MapArgs: Options given to keybindings
M.reset_keymap = function(mode, lhs, opts)
    opts = opts or {}
    opts.desc = ("Reset %s keymap"):format(lhs)
    M.map(mode, lhs, lhs, opts)
end

-- Replace termcodes; e.g., t'<C-n>'
---@param str string: String to be converted
---@param from_part boolean: Legacy vim parameter. Usually true
---@param do_lt boolean: Also translate `<lt>` (Ignored if special is false)
---@param special boolean: Replace keycodes, e.g., `<CR>` => `\r`
---@return string
M.t = function(str, from_part, do_lt, special)
    ---@diagnostic disable-next-line:return-type-mismatch
    return api.nvim_replace_termcodes(str, F.if_nil(from_part, true), F.if_nil(do_lt, true), F.if_nil(special, true))
end

---Debug helper
---@vararg any: Anything to dump
M.dump = function(...)
    local objects = vim.tbl_map(D.inspect, {...})
    print(unpack(objects))
end

---Get a Vim option. If present in buffer, return that, else global
---@param option string option to get
---@param default string|number fallback option
---@return string|number
M.get_option = function(option, default)
    local ok, opt = pcall(nvim.buf.get_option, 0, option)
    if not ok then
        ok, opt = pcall(nvim.get_option, 0, option)
        if not ok then
            opt = default
        end
    end
    return opt
end

---@class CommandArgs
---@field args string args passed to command
---@field fargs table args split by whitespace (more than one arg)
---@field bang boolean true if executed with `!`
---@field line1 number starting line of command range
---@field line2 number final line of command range
---@field range number 0|1|2 of items in command range
---@field count number any count supplied
---@field reg string optional register
---@field mods string command modifiers
---@field smods table command modifiers in structured format

---@class CommandOpts
---@field nargs number|string 0|1|'*'|'?'|'+'
---@field range number|'%'
---@field count number
---@field bar boolean
---@field bang boolean
---@field complete string
---@field desc string description of the command
---@field force boolean override existing definition
---@field preview function perview callback for inccomand

---Create an `nvim` command
---@param name string
---@param rhs string|fun(args: CommandArgs): nil
---@param opts CommandOpts
M.command = function(name, rhs, opts)
    vim.validate {
        name = {name, "string"},
        rhs = {rhs, {"f", "s"}},
        opts = {opts, "table", true}
    }

    local is_buffer = false
    opts = opts or {}
    if opts.buffer then
        local buffer = type(opts.buffer) == "number" and opts.buffer or 0
        opts.buffer = nil
        is_buffer = true
        api.nvim_buf_create_user_command(buffer, name, rhs, opts)
    else
        api.nvim_create_user_command(name, rhs, opts)
    end

    if opts.desc then
        M.prequire(
            "legendary",
            function(lgnd)
                lgnd.command({(":%s"):format(name), opts = {desc = opts.desc, buffer = F.tern(is_buffer, 0, nil)}})
            end
        )
    end
end

---Creates a command for a given buffer
---@param name string
---@param rhs string|function
---@param opts table
M.bcommand = function(name, rhs, opts)
    opts = opts or {}
    opts.buffer = true
    M.command(name, rhs, opts)
end

---Delete a command
---@param name string Command to delete
---@param buffer? boolean|number Whether to delete buffer command
M.del_command = function(name, buffer)
    vim.validate {
        name = {name, "string"},
        buffer = {buffer, {"boolean", "number"}, "a boolean or a number"}
    }

    if buffer then
        buffer = type(buffer) == "number" and buffer or 0
        api.nvim_buf_del_user_command(buffer, name)
    else
        api.nvim_del_user_command(name)
    end
end

---Check that the current version is greater than or equal to the given version
---@param major number
---@param minor number
---@param _ number? patch
---@return boolean
M.version = function(major, minor, _)
    vim.validate {
        major = {major, "n", false},
        minor = {minor, "n", false}
    }
    local v = vim.version()
    return major >= v.major and minor >= v.minor
end

---Source a lua or vimscript file
---@param path string path relative to the nvim directory
---@param prefix boolean?
M.source = function(path, prefix)
    if not prefix then
        cmd.source(path)
    else
        cmd.source(("%s/%s"):format(dirs.config, path))
    end
end

---Get the latest messages from `messages` command
---@param count number? of messages to get
---@param str boolean whether to return as a string or table
---@return string
M.messages = function(count, str)
    -- local messages = api.nvim_exec("messages", true)
    local messages = fn.execute("messages")
    local lines = vim.split(messages, "\n")
    lines =
        D.filter(
        lines,
        function(line)
            return line ~= ""
        end
    )
    count = count and tonumber(count) or nil
    count = (count ~= nil and count >= 0) and count - 1 or #lines
    local slice = vim.list_slice(lines, #lines - count)
    return str and table.concat(slice, "\n") or slice
end

---Wrapper to make getting the current mode easier
---@return string
M.mode = function()
    return api.nvim_get_mode().mode
end

---Determine whether user in in visual mode
---@return boolean, string
M.is_visual_mode = function()
    local mode = M.mode()
    -- return mode == 'v' or mode == 'V' or mode == '', mode
    return mode:match("[vV\x16]"), mode
end

---Get the current visual selection
---@return string
M.get_visual_selection = function()
    -- this will exit visual mode
    -- use 'gv' to reselect the text
    local _, csrow, cscol, cerow, cecol
    local mode = fn.mode()
    if mode == "v" or mode == "V" or mode == "" then
        -- if we are in visual mode use the live position
        _, csrow, cscol, _ = unpack(fn.getpos("."))
        _, cerow, cecol, _ = unpack(fn.getpos("v"))
        if mode == "V" then
            -- visual line doesn't provide columns
            cscol, cecol = 0, 999
        end
        -- Exit visual mode
        -- api.nvim_feedkeys(M.termcodes["<Esc>"], "n", true)
        M.normal("n", "<Esc>")
    else
        -- otherwise, use the last known visual position
        _, csrow, cscol, _ = unpack(fn.getpos("'<"))
        _, cerow, cecol, _ = unpack(fn.getpos("'>"))
    end
    -- swap vars if needed
    if cerow < csrow then
        csrow, cerow = cerow, csrow
    end
    if cecol < cscol then
        cscol, cecol = cecol, cscol
    end
    local lines = fn.getline(csrow, cerow)
    -- local n = cerow-csrow+1
    local n = #lines
    if n <= 0 then
        return ""
    end
    lines[n] = string.sub(lines[n], 1, cecol)
    lines[1] = string.sub(lines[1], cscol)
    return table.concat(lines, "\n")
end

---@alias NotifyLevels
---| '0' # Trace level
---| '1' # Debug level
---| '2' # Info level
---| '3' # Warn level
---| '4' # Error level

-- ---Correctly assign this to be an enum
-- ---@enum NotifyLevels
-- NotifyLevels = {
--     Trace = log.levels.TRACE,
--     Debug = log.levels.DEBUG,
--     Info = log.levels.INFO,
--     Warn = log.levels.WARN,
--     Error = log.levels.ERROR
-- }

---@class NotifyOpts
---@field icon? string Icon to add to notification
---@field title? string Title to add
---@field message? string Notification message
---@field level? NotifyLevels Notification level
---@field hl? string Highlight group
---@field on_open fun(winnr: number): nil
---@field once boolean Only send notification one time

do
    local notifications = {}

    ---Wrapper to send a notification
    ---@param msg string? Message to notify
    ---@param level number
    ---@param opts NotifyOpts
    M.notify = function(msg, level, opts)
        level = F.if_nil(level, log.levels.INFO)
        local keep = function()
            return true
        end

        local _opts =
            ({
            [log.levels.TRACE] = {timeout = 500},
            [log.levels.DEBUG] = {timeout = 500},
            [log.levels.INFO] = {timeout = 1000},
            [log.levels.WARN] = {timeout = 3000},
            [log.levels.ERROR] = {timeout = 5000, keep = keep}
        })[level]

        ---@diagnostic disable-next-line:cast-local-type
        opts = vim.tbl_extend("force", _opts or {}, opts or {})

        local function notify()
            if vim.g.nvim_focused then
                local ok, notify = pcall(require, "notify")
                if not ok then
                    vim.defer_fn(
                        function()
                            vim.notify(msg, level, opts)
                        end,
                        100
                    )
                    return
                end
                return notify.notify(msg, level, opts)
            else
                return require("desktop-notify").notify(msg, level, opts)
            end
        end

        if opts.once then
            if not notifications[msg] then
                notify()
                notifications[msg] = true
            end
        else
            notify()
        end
    end
end

---Global notify function.
---This must be defined here instead of `global.lua` due to loading order.
---@param msg string
---@param level number?
---@param title string?
_G.N = function(msg, level, title)
    M.notify(vim.inspect(msg), M.get_default(level, log.levels.INFO) --[[@as number]], {title = title})
end

---Preserve cursor position when executing command
M.preserve = function(arguments)
    local view = M.save_win_positions(0)
    local arguments = ("%q"):format(arguments)
    local line, col = unpack(api.nvim_win_get_cursor(0))
    cmd(("keepj keepp execute %s"):format(arguments))
    local lastline = fn.line("$")
    if line > lastline then
        line = lastline
    end

    M.set_cursor(0, line, col)
    view.restore()
end

---Remove duplicate blank lines (2 -> 1)
M.squeeze_blank_lines = function()
    if vim.bo.binary == false and vim.o.ft ~= "diff" then
        local old_query = fn.getreg("/") -- save search register
        M.preserve("sil! 1,.s/^\\n\\{2,}/\\r/gn") -- set current search count number
        local result = fn.searchcount({maxcount = 1000, timeout = 500}).current
        local line, col = unpack(api.nvim_win_get_cursor(0))
        M.preserve("sil! keepp keepj %s/^\\n\\{2,}/\\r/ge")
        M.preserve("sil! keepp keepj %s/\\v($\\n\\s*)+%$/\\r/e")
        M.preserve([[sil! keepp keepj 0;/^\%(\n*.\)\@!/,$d]])
        if result > 0 then
            M.set_cursor(0, (line - result), col)
        end
        nvim.reg["/"] = old_query
    end
end

---Get specified builtin marks
---
---This is to be used when formatting a file. When formattinga a file, the last line
---is shown to be the line that was last modified regardless of whether or not keepj,
---keepp, lockmarks, or keepmarks is used.
---However, this does not work! So, perhaps it can be used for something else
---
---@param marks table? builtin marks to be saved
---@param bufnr number? buffer where marks should be saved
---@diagnostic disable-next-line:unused-local
M.get_marks = function(bufnr, marks, tbl)
    -- local all_builtin = {"<", ">", "[", "]", ".", "^", '"', "'"}
    marks = marks or require("marks").mark_state.builtin_marks
    bufnr = bufnr or api.nvim_get_current_buf()
    local saved = {}

    for _, mark in pairs(fn.getmarklist("%")) do
        for _, builtin in pairs(marks) do
            if mark.mark:sub(2, 2) == builtin then
                table.insert(saved, mark)
            end
        end
    end

    return function()
        for _, mark in pairs(marks) do
            local _, lnum, col, _ = unpack(mark.pos)
            api.nvim_buf_set_mark(bufnr, mark.mark:sub(2, 2), lnum, col, {})
        end
    end
end

---Set a list of marks
---@param marks table builtin marks to be set
---@param bufnr number? buffer where marks should be set
M.set_marks = function(marks, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    for _, mark in pairs(marks) do
        local _, lnum, col, _ = unpack(mark.pos)
        api.nvim_buf_set_mark(bufnr, mark.mark:sub(2, 2), lnum, col, {})
    end
end

---@class SaveWinPositionsReturn
---@field restore function

---Save a window's positions
---@param bufnr number? buffer to save position
---@return SaveWinPositionsReturn
M.save_win_positions = function(bufnr)
    bufnr = F.tern(bufnr == nil or bufnr == 0, api.nvim_get_current_buf(), bufnr)
    local win_positions = {}
    for _, winid in pairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(winid) == bufnr then
            api.nvim_win_call(
                winid,
                function()
                    local view = fn.winsaveview()
                    table.insert(win_positions, {winid, view})
                end
            )
        end
    end

    return {
        restore = function()
            for _, pair in pairs(win_positions) do
                local winid, view = unpack(pair)
                api.nvim_win_call(
                    winid,
                    function()
                        pcall(fn.winrestview, view)
                    end
                )
            end
        end
    }
end

---Check whether or not the location or quickfix list is open
---@return boolean
M.is_vim_list_open = function()
    for _, win in ipairs(api.nvim_list_wins()) do
        local buf = api.nvim_win_get_buf(win)
        local location_list = fn.getloclist(0, {filewinid = 0})
        ---@diagnostic disable-next-line:undefined-field
        local is_loc_list = location_list.filewinid > 0
        if vim.bo[buf].filetype == "qf" or is_loc_list then
            return true
        end
    end
    return false
end

---Close all floating windows
M.close_all_floating_wins = function()
    for _, win in ipairs(api.nvim_list_wins()) do
        if D.is_floating_window(win) then
            api.nvim_win_close(win, false)
        end
    end
end

---Focus the floating window
M.focus_floating_win = function()
    if D.is_floating_window(fn.win_getid()) then
        cmd.wincmd("p")
        return
    end
    for _, winnr in ipairs(fn.range(1, fn.winnr("$"))) do
        local winid = fn.win_getid(winnr)
        local conf = api.nvim_win_get_config(winid)
        if conf.focusable and conf.relative ~= "" then
            fn.win_gotoid(winid)
            return
        end
    end
end

---Program to check if executable
---@param exec string
---@return boolean
M.executable = function(exec)
    vim.validate({exec = {exec, "string"}})
    assert(exec ~= "", debug.traceback("Empty executable string"))
    return fn.executable(exec) == 1
end

---Will determine whether a string or table is empty
---A number can be given to this function and it will assume that is it as buffer
---
---@param item string|table|buffer
---@return boolean?
M.empty = function(item)
    local item_t = type(item)

    if item_t == "string" then
        return item == ""
    elseif item_t == "table" then
        return vim.tbl_isempty(item)
    elseif item_t == "number" then
        local lines = api.nvim_buf_get_lines(b, 0, -1, false)
        return #lines == 1 and lines[1] == ""
    ---All values have been covered
    ---@diagnostic disable-next-line:missing-return
    end
end

---@param str string
---@param max_len integer
---@return string
M.truncate = function(str, max_len)
    vim.validate {
        str = {str, "s", false},
        max_len = {max_len, "n", false}
    }

    return api.nvim_strwidth(str) > max_len and str:sub(1, max_len) .. style.icons.misc.ellipsis or str
end

---Escape a string correctly
---@param s string
---@return string
M.escape = function(s)
    return (s:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"))
end

---Table of escaped termcodes
M.termcodes =
    setmetatable(
    {},
    {
        ---@param tbl table self
        ---@param k string termcode to retrieve
        ---@return string
        __index = function(tbl, k)
            local k_upper = k:upper()
            local v_upper = rawget(tbl, k_upper)
            local c = v_upper or utils.t(k, true, false, true)
            rawset(tbl, k, c)
            if not v_upper then
                rawset(tbl, k_upper, c)
            end
            return c
        end
    }
)

---Escaped ansi sequence
M.ansi =
    setmetatable(
    {},
    {
        ---@param t table
        ---@param k string
        ---@return string
        __index = function(t, k)
            local v = M.render_str("%s", k)
            rawset(t, k, v)
            return v
        end
    }
)

---Remove ANSI escape sequences from a string
---@param str string
---@return string, integer
M.remove_ansi = function(str)
    return str:gsub("\x1b%[[%d;]*%d[Km]", "")
end

---Return a 24 byte colored string
local function color2csi24b(color_num, fg)
    local r = math.floor(color_num / 2 ^ 16)
    local g = math.floor(math.floor(color_num / 2 ^ 8) % 2 ^ 8)
    local b = math.floor(color_num % 2 ^ 8)
    return ("%d;2;%d;%d;%d"):format(fg and 38 or 48, r, g, b)
end

---Return a 8 byte colored string
local function color2csi8b(color_num, fg)
    return ("%d;5;%d"):format(fg and 38 or 48, color_num)
end

M.render_str =
    (function()
    local ansi = {
        black = 30,
        red = 31,
        green = 32,
        yellow = 33,
        blue = 34,
        magenta = 35,
        cyan = 36,
        white = 37
    }
    local gui = vim.o.termguicolors
    local color2csi = gui and color2csi24b or color2csi8b

    ---Render an ANSI escape sequence
    ---@param str string
    ---@param group_name string
    ---@param def_fg string?
    ---@param def_bg string?
    return function(str, group_name, def_fg, def_bg)
        vim.validate(
            {
                str = {str, "string"},
                group_name = {group_name, "string"},
                def_fg = {def_fg, "string", true},
                def_bg = {def_bg, "string", true}
            }
        )
        local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, gui)
        if not ok or not (hl.foreground or hl.background or hl.reverse or hl.bold or hl.italic or hl.underline) then
            return str
        end
        local fg, bg
        if hl.reverse then
            fg = hl.background ~= nil and hl.background or nil
            bg = hl.foreground ~= nil and hl.foreground or nil
        else
            fg = hl.foreground
            bg = hl.background
        end
        local escape_prefix =
            ("\x1b[%s%s%s"):format(hl.bold and ";1" or "", hl.italic and ";3" or "", hl.underline and ";4" or "")

        local escape_fg, escape_bg = "", ""
        if fg and type(fg) == "number" then
            escape_fg = ";" .. color2csi(fg, true)
        elseif def_fg and ansi[def_fg] then
            ---@diagnostic disable-next-line:cast-local-type
            escape_fg = ansi[def_fg]
        end
        if bg and type(bg) == "number" then
            escape_fg = ";" .. color2csi(bg, false)
        elseif def_bg and ansi[def_bg] then
            ---@diagnostic disable-next-line:cast-local-type
            escape_fg = ansi[def_bg]
        end

        return ("%s%s%sm%s\x1b[m"):format(escape_prefix, escape_fg, escape_bg, str)
    end
end)()

---Follow a symbolic link
---@param fname string filename to follow
---@param func string|function? action to execute after following symlink
M.follow_symlink = function(fname, func)
    fname = F.tern(not M.empty(fname), fn.fnamemodify(fname, ":p"), api.nvim_buf_get_name(0))
    local linked_path = uv.fs_readlink(fname)
    if linked_path then
        cmd(("keepalt file %s"):format(linked_path))

        if func then
            local f_type = type(func)
            if f_type == "string" then
                cmd(func)
            elseif f_type == "function" then
                f_type()
            end
        end
    end
end

---Bufwipe buffers that aren't modified and haven't been saved (i.e., don't have a titlestring)
M.clean_empty_bufs = function()
    local bufnrs = {}
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if not vim.bo[bufnr].modified and api.nvim_buf_get_name(bufnr) == "" then
            table.insert(bufnrs, bufnr)
        end
    end
    if #bufnrs > 0 then
        cmd("bw " .. table.concat(bufnrs, " "))
    end
end

---Close a diff file
M.close_diff = function()
    local winids =
        D.filter(
        api.nvim_tabpage_list_wins(0),
        function(winid)
            return vim.wo[winid].diff
        end
    )

    if #winids > 1 then
        for _, winid in ipairs(winids) do
            local ok, msg = pcall(api.nvim_win_close, winid, false)
            if not ok and (msg and msg:match("^Vim:E444:")) then
                if api.nvim_buf_get_name(0):match("^fugitive://") then
                    ex.Gedit() -- FIX: cmd ex: Why doesn't cmd.Gedit work?
                end
            end
        end
    end
end

---API around `nvim_echo`
---"Colored echo"
M.cecho =
    (function()
    local lastmsg
    local debounced
    ---Echo a colored message
    ---@param msg string message to echo
    ---@param hl string highlight group to link
    ---@param history boolean? add message to history
    ---@param wait number? amount of time to wait
    return function(msg, hl, history, wait)
        history = history == nil and true or history
        vim.schedule(
            function()
                api.nvim_echo({{msg, hl}}, history, {})
                lastmsg = api.nvim_exec("5message", true)
            end
        )
        if not debounced then
            debounced =
                debounce(
                function()
                    if lastmsg == api.nvim_exec("5message", true) then
                        api.nvim_echo({{"", ""}}, false, {})
                    end
                end,
                wait or 2500
            )
        end
        debounced()
    end
end)()

---Expand a tab in a string
---@param str string
---@param ts integer
---@param start integer
---@return string
M.expandtab = function(str, ts, start)
    start = start or 1
    local new = str:sub(1, start - 1)
    -- without check type to improve performance
    -- if str and type(str) == 'string' then
    local pad = " "
    local ti = start - 1
    local i = start
    while true do
        i = str:find("\t", i, true)
        if not i then
            if ti == 0 then
                new = str
            else
                new = new .. str:sub(ti + 1)
            end
            break
        end
        if ti + 1 == i then
            new = new .. pad:rep(ts)
        else
            local append = str:sub(ti + 1, i - 1)
            new = new .. append .. pad:rep(ts - api.nvim_strwidth(append) % ts)
        end
        ti = i
        i = i + 1
    end
    -- end
    return new
end

M.highlight =
    (function()
    local ns = api.nvim_create_namespace("l-highlight")

    local function do_unpack(pos)
        vim.validate({pos = {pos, {"t", "n"}, "must be table or number type"}})
        local row, col
        if type(pos) == "table" then
            row, col = unpack(pos)
        else
            row = pos
        end
        col = col or 0
        return row, col
    end

    ---Wrapper to deal with extmarks
    ---@param bufnr number
    ---@param hl_group string
    ---@param start number
    ---@param finish number
    ---@param opt table
    ---@param delay number
    return function(bufnr, hl_group, start, finish, opt, delay)
        local row, col = do_unpack(start)
        local end_row, end_col = do_unpack(finish)
        if end_col then
            end_col = math.min(math.max(fn.col({end_row + 1, "$"}) - 1, 0), end_col)
        end
        local o = {hl_group = hl_group, end_row = end_row, end_col = end_col}
        o = opt and vim.tbl_deep_extend("keep", o, opt) or o
        local id = api.nvim_buf_set_extmark(bufnr, ns, row, col, o)
        vim.defer_fn(
            function()
                pcall(api.nvim_buf_del_extmark, bufnr, ns, id)
            end,
            delay or 300
        )
    end
end)()

---Write a file using libuv
---@param path string
---@param data string
---@param sync boolean
M.write_file = function(path, data, sync)
    local path_ = path .. "_"
    if sync then
        local fd = assert(uv.fs_open(path_, "w", 438))
        assert(uv.fs_write(fd, data))
        assert(uv.fs_close(fd))
        uv.fs_rename(path_, path)
    else
        uv.fs_open(
            path_,
            "w",
            438,
            function(err_open, fd)
                assert(not err_open, err_open)
                uv.fs_write(
                    fd,
                    data,
                    -1,
                    function(err_write)
                        assert(not err_write, err_write)
                        uv.fs_close(
                            fd,
                            function(err_close, succ)
                                assert(not err_close, err_close)
                                if succ then
                                    -- may rename by other syn write
                                    uv.fs_rename(
                                        path_,
                                        path,
                                        function()
                                        end
                                    )
                                end
                            end
                        )
                    end
                )
            end
        )
    end
end

---Read a file asynchronously (using Promises)
---@param path string
---@return Promise
M.readFile = function(path)
    return async(
        function()
            local fd = await(uva.open(path, "r", 438))
            local stat = await(uva.fstat(fd))
            local data = await(uva.read(fd, stat.size, 0))
            await(uva.close(fd))
            return data
        end
    )
end

---Write to a file asynchronously (using Promises)
---@param path string
---@param data string
---@return Promise
M.writeFile = function(path, data)
    return async(
        function()
            local path_ = path .. "_"
            local fd = await(uva.open(path_, "w", 438))
            await(uva.write(fd, data))
            await(uva.close(fd))
            await(uva.rename(path_, path))
        end
    )
end

---Only stat a given file.
---This function does not require a file descriptor, instead it takes a string
---@param path string
---@return Promise
M.stat = function(path)
    return async(
        function()
            local fd = await(uva.open(fn.expand(path), "r", 438))
            local stat = await(uva.fstat(fd))
            await(uva.close(fd))
            return stat
        end
    )
end

-- ================= Tips ================== [[[
-- Search global variables:
--    filter <pattern> let g:

-- EmmyLua
--    https://github.com/sumneko/lua-language-server/wiki/Annotations

-- Patterns
--   http://lua-users.org/wiki/PatternsTutorial
--   https://www.lua.org/pil/20.2.html
-- ]]] === Tips ===

-- Allows us to use utils globally
_G.utils = M

return M
