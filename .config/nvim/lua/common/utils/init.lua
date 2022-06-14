-- ========================== Functions ==========================

local M = {}

local Result = require("common.result")
local log = require("common.log")
local debounce = require("common.debounce")

local a = require("plenary.async_lib")
local async = a.async
local await = a.await

local ex = nvim.ex
local api = vim.api

-- require("plenary.strings").align_str(string: any, width: any, right_justify: any)
-- require("plenary.strings").dedent(str: any, leave_indent: any)
-- require("plenary.strings").truncate(str: string, len: any, dots: any, direction: any)
-- require("plenary.strings").strdisplaywidth(string, col)

---Safely check if a plugin is installed
---@param check string Module to check if is installed
---@return table Result<T, E>
M.prequire = function(check)
    opts = opts or {silent = false}
    local ok, ret = pcall(require, check)
    if ok then
        return Result.ok(ret)
    end

    -- R("common.utils").prequire("kimbox"):or_else(function(v) p(v) end)

    local dummy = {}
    setmetatable(
        dummy,
        {
            -- Error has to be unwrapped to be notified
            __call = function()
                M.notify(
                    {
                        message = "Module is not installed",
                        title = ("require('%s')"):format(check),
                        level = log.levels.ERROR
                    }
                )
                return dummy
            end,
            __index = function()
                return dummy
            end
        }
    )
    return Result.err(dummy)
end

---Safely check if a plugin is installed
---@param name string Module to check if is installed
---@param cb function
---@return table Module
M.safe_require = function(name, cb)
    local ok, ret = pcall(require, name)
    if ok then
        if cb and type(cb) == "function" then
            cb(ret)
        end
        return ret
    else
        M.notify(
            {
                message = ("Invalid module %s"):format(name),
                level = log.levels.WARN
            }
        )
        -- Return a dummy item that returns functions, so we can do things like
        -- safe_require("module").setup()
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

---Load a module, returning only one parameter
---@param name string module to check
---@return table|nil
M.load_module = function(name)
    local ok, module = pcall(require, name)
    if not ok then
        return nil
    end
    return module
end

---Execute a command in normal mode. Equivalent to `norm! <cmd>`
---@param mode string
---@param motion string
M.normal = function(mode, motion)
    local sequence = M.t(motion, true, false, false)
    nvim.feedkeys(sequence, mode, true)
end

-- Create an augroup with the lua api
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
---@field description string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string|fun(args: AutocommandOpts)
---@field nested  boolean
---@field once    boolean
---@field buffer  number

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string|table: Augroup name. If a table, `true` can be passed to clear the group
---@param ... Autocommand[]
---@return number Group ID of the autocommand
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
---@param autocmd Autocommand[]
---@param id? number Group id
---@return number Group ID of the autocommand
M.autocmd = function(autocmd, id)
    local is_callback = type(autocmd.command) == "function"
    api.nvim_create_autocmd(
        autocmd.event,
        {
            group = F.if_nil(id, nil),
            pattern = autocmd.pattern,
            desc = autocmd.description or autocmd.desc,
            callback = F.tern(is_callback, autocmd.command, nil),
            command = F.tern(not is_callback, autocmd.command, nil),
            once = autocmd.once,
            nested = autocmd.nested,
            buffer = autocmd.buffer
        }
    )

    return id
end

--- @class MapArgs
--- @field unique boolean
--- @field expr boolean
--- @field script boolean
--- @field nowait boolean
--- @field silent boolean
--- @field buffer boolean|number
--- @field replace_keycodes boolean
--- @field remap boolean
--- @field callback function
--- @field cmd boolean
--- @field desc string

---Create a key mapping
---If the `rhs` is a function, and a `bufnr` is given, the argument is instead moved into the `opts`
---
---@param bufnr? number: Optional buffer id. If not given, the first argument is `modes`
---@param modes string|table: Modes the keymapping should be bound
---@param lhs string: Keybinding that is mapped
---@param rhs string|function: String or Lua function that will be bound to a key
---@param opts MapArgs: Options given to keybindings
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
---
--- - `cmd`: (boolean, default false) Make the mapping a `<Cmd>` mapping (do not use `<Cmd>`..<CR> with this)
--- - `desc`: (string) Describe the keybinding, this hooks to `which-key`
M.map = function(bufnr, modes, lhs, rhs, opts)
    -- If it is not a buffer mapping, then shift all arguments
    if type(bufnr) ~= "number" then
        opts = rhs
        rhs = lhs
        lhs = modes
        modes = bufnr
        bufnr = nil
    end

    vim.validate(
        {
            bufnr = {bufnr, {"n", "nil"}, true},
            mode = {modes, {"s", "t"}},
            lhs = {lhs, "s"},
            rhs = {rhs, {"s", "f"}},
            opts = {opts, "t", true}
        }
    )

    opts = vim.deepcopy(opts) or {}
    modes = type(modes) == "string" and {modes} or modes
    if opts.remap == nil then
        opts.noremap = true
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
        end

        opts.replace_keycodes = nil
        return rhs
    end)()

    bufnr = (function()
        local b = bufnr == nil and opts.buffer or bufnr
        b = b == true and 0 or b
        opts.buffer = nil
        return b
    end)()

    if bufnr ~= nil then
        for _, mode in ipairs(modes) do
            api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end
    else
        for _, mode in ipairs(modes) do
            if opts.desc then
                require("which-key").register({[lhs] = opts.desc}, {mode = mode})
            end

            api.nvim_set_keymap(mode, lhs, rhs, opts)
        end
    end
end

-- Create a buffer key mapping
M.bmap = function(bufnr, mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

-- Replace termcodes; e.g., t'<C-n>'
---@param str string: String to be converted
---@param from_part boolean: Legacy vim parameter. Usually true
---@param do_lt boolean: Also translate `<lt>` (Ignored if special is false)
---@param special boolean: Replace keycodes, e.g., `<CR>` => `\r`
---@return string
M.t = function(str, from_part, do_lt, special)
    return api.nvim_replace_termcodes(str, F.if_nil(from_part, true), F.if_nil(do_lt, true), F.if_nil(special, true))
end

---Debug helper
---@vararg table | string | number: Anything to dump
M.dump = function(...)
    local objects = vim.tbl_map(require("dev").inspect, {...})
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

---@class CommandOpts
---@field nargs number|string 0|1|'*'|'?'|'+'
---@field range number?|string? '%'|N
---@field count number
---@field bar boolean
---@field bang boolean
---@field complete string
---@field desc string description of the command
---@field force boolean override existing definition

---Create an nvim command
---@param name any
---@param rhs string|fun(args: CommandArgs)
---@param opts CommandOpts
M.command = function(name, rhs, opts)
    vim.validate(
        {
            name = {name, "string"},
            cmd = {cmd, {"f", "s"}},
            opts = {opts, "table", true}
        }
    )

    opts = opts or {}
    if opts.buffer then
        local buffer = type(opts.buffer) == "number" and opts.buffer or 0
        opts.buffer = nil
        api.nvim_buf_create_user_command(buffer, name, rhs, opts)
    else
        api.nvim_create_user_command(name, rhs, opts)
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
    vim.validate(
        {
            name = {name, "string"},
            buffer = {
                buffer,
                {"boolean", "number"},
                "a boolean or a number"
            }
        }
    )
    if buffer then
        buffer = type(buffer) == "number" and buffer or 0
        api.nvim_buf_del_user_command(buffer, name)
    else
        api.nvim_del_user_command(name)
    end
end

---Source a lua or vimscript file
---@param path string path relative to the nvim directory
---@param prefix boolean?
M.source = function(path, prefix)
    if not prefix then
        ex.source(path)
    else
        ex.source(("%s/%s"):format(fn.stdpath("config"), path))
    end
end

---Determine whether user in in visual mode
---@return boolean, string
M.is_visual_mode = function()
    local mode = api.nvim_get_mode().mode
    -- return mode == 'v' or mode == 'V' or mode == '', mode
    return mode:match("[vV\x16]"), mode
end

---Get the current visual selection
---@return table
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
        -- exit visual mode
        api.nvim_feedkeys(M.t("<Esc>", true, false, true), "n", true)
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

---Wrapper to send a notification
---@param options table same options as `nvim_notify`
M.notify = function(options)
    if type(options) == "string" then
        api.nvim_notify(options, log.levels.INFO, {icon = ""})
        return
    end

    local forced =
        vim.tbl_extend(
        "force",
        {
            message = "This is a sample notification.",
            icon = "",
            title = "Notification",
            level = log.levels.INFO
        },
        options or {}
    )
    api.nvim_notify(forced.message, forced.level, {title = forced.title, icon = forced.icon})
end

---Preserve cursor position when executing command
M.preserve = function(arguments)
    local arguments = fmt("%q", arguments)
    local line, col = unpack(api.nvim_win_get_cursor(0))
    ex.keepjumps(ex.keeppatterns(ex.execute(arguments)))
    local lastline = fn.line("$")
    if line > lastline then
        line = lastline
    end

    api.nvim_win_set_cursor(0, {line, col})
end

-- vim.cmd([[command! Preserve lua require("utils").preserve('%s/\\s\\+$//ge')]])
-- vim.cmd([[command! Reindent lua preserve("sil keepj normal! gg=G")]])
-- vim.cmd([[command! BufOnly lua preserve("silent! %bd|e#)]])

---Remove duplicate blank lines (2 -> 1)
M.squeeze_blank_lines = function()
    if vim.bo.binary == false and vim.opt.filetype:get() ~= "diff" then
        local old_query = fn.getreg("/") -- save search register
        M.preserve("sil! 1,.s/^\\n\\{2,}/\\r/gn") -- set current search count number
        local result = fn.searchcount({maxcount = 1000, timeout = 500}).current
        local line, col = unpack(api.nvim_win_get_cursor(0))
        M.preserve("sil! keepp keepj %s/^\\n\\{2,}/\\r/ge")
        M.preserve("sil! keepp keepj %s/\\v($\\n\\s*)+%$/\\r/e")
        M.preserve([[sil! keepp keepj 0;/^\%(\n*.\)\@!/,$d]])
        if result > 0 then
            api.nvim_win_set_cursor(0, {(line - result), col})
        end
        fn.setreg("/", old_query) -- restore search register
    end
end

--- Return a string for vim from a lua function.
--- Functions are stored in _G.myluafunc.
--- @param func function
--- @return string VimFunctionString
_G.myluafunc =
    setmetatable(
    {},
    {
        __call = function(self, idx, args, count)
            return self[idx](args, count)
        end
    }
)

---Turn a function into a string
---@param func function
---@param args table
M.func2str = function(func, args)
    local idx = #_G.myluafunc + 1
    _G.myluafunc[idx] = func
    if not args then
        return ("lua myluafunc(%s)"):format(idx)
    else
        return ("lua myluafunc(%s, <q-args>, <count>)"):format(idx)
    end
end

---Return a value based on two values
---@param condition boolean Statement to be tested
---@param is_if any Return if condition is truthy
---@param is_else any Return if condition is not truthy
F.tern = function(condition, is_if, is_else)
    if condition then
        return is_if
    else
        return is_else
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

---Save a window's positions
---@param bufnr number? buffer to save position
---@return function
M.save_win_positions = function(bufnr)
    bufnr = (bufnr == nil or bufnr == 0) and api.nvim_get_current_buf() or bufnr
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

    return function()
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
end

---Check whether or not the location or quickfix list is open
---@return boolean
M.is_vim_list_open = function()
    for _, win in ipairs(api.nvim_list_wins()) do
        local buf = api.nvim_win_get_buf(win)
        local location_list = fn.getloclist(0, {filewinid = 0})
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
        local config = api.nvim_win_get_config(win)
        if config.relative ~= "" then
            api.nvim_win_close(win, false)
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

---Determine if a value of any type is empty
---@param item any
---@return boolean
M.empty = function(item)
    if not item then
        return true
    end

    local item_type = type(item)
    if item_type == "string" then
        return item == ""
    elseif item_type == "table" then
        return vim.tbl_isempty(item)
    end
end

---Table of escaped termcodes
---@param tbl table self
---@param k string termcode to retrieve
---@return string
M.termcodes =
    setmetatable(
    {},
    {
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

nvim.termcodes = M.termcodes

---Escaped ansi sequence
---@param t table
---@param k string
---@return string
M.ansi =
    setmetatable(
    {},
    {
        __index = function(t, k)
            local v = M.render_str("%s", k)
            rawset(t, k, v)
            return v
        end
    }
)

---Render an ANSI escape sequence
---@param str string
---@param group_name string
---@param def_fg string
---@param def_bg string
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

    local color2csi = gui and color2csi24b or color2csi8b

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
            escape_fg = ansi[def_fg]
        end
        if bg and type(bg) == "number" then
            escape_fg = ";" .. color2csi(bg, false)
        elseif def_bg and ansi[def_bg] then
            escape_fg = ansi[def_bg]
        end

        return ("%s%s%sm%s\x1b[m"):format(escape_prefix, escape_fg, escape_bg, str)
    end
end)()

---Render a string in Neovim with the following format:
---   title: message
---Where title is a different highlight group than message
---Usage:     cmd(utils.hl.WarningMsg:format("title", "message"))
M.hl =
    setmetatable(
    {},
    {
        __index = function(t, k)
            local v = M.render_hl_msg("%s", "%s", k, false)
            rawset(t, k, v)
            return v
        end
    }
)
-- FIX: newline doesn't work with vim.cmd for some reason
M.hl2 =
    setmetatable(
    {},
    {
        __index = function(t, k)
            local v = M.render_hl_msg("%s", "%s", k, true)
            rawset(t, k, v)
            return v
        end
    }
)

---Render a string in Neovim with a colored title and uncolored message
---(on the same line)
M.render_hl_msg =
    (function()
    return function(title, str, group_name, newline)
        vim.validate(
            {
                title = {title, "string"},
                str = {str, "string"},
                group_name = {group_name, "string"},
                newline = {newline, "boolean", true}
            }
        )

        local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, true)
        if not ok or not (hl.foreground or hl.background or hl.reverse or hl.bold or hl.italic or hl.underline) then
            return str
        end

        local ret =
            ("echohl %s | echo '%s' | echohl None | echon ': ' | echo%s '%s'"):format(
            group_name,
            title,
            newline and "" or "n",
            str
        )

        return ret
    end
end)()

---Follow a symbolic link
---@param fname string filename to follow
M.follow_symlink = function(fname)
    fname = fname and fn.fnamemodify(fname, ":p") or api.nvim_buf_get_name(0)
    local linked_path = uv.fs_readlink(fname)
    if linked_path then
        cmd(("keepalt file %s"):format(linked_path))
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
        vim.tbl_filter(
        function(winid)
            return vim.wo[winid].diff
        end,
        api.nvim_tabpage_list_wins(0)
    )

    if #winids > 1 then
        for _, winid in ipairs(winids) do
            local ok, msg = pcall(api.nvim_win_close, winid, false)
            if not ok and msg:match("^Vim:E444:") then
                if api.nvim_buf_get_name(0):match("^fugitive://") then
                    ex.Gedit()
                end
            end
        end
    end
end

---API around `nvim_echo`
---@param msg string message to echo
---@param hl string highlight group
---@param history boolean? whether it should be added to history
---@param wait number? time to wait before echoing
M.cool_echo =
    (function()
    local lastmsg
    local debounced
    ---Echo a colored message
    ---@param msg string message to echo
    ---@param hl string highlight group to link
    ---@param history boolean? add message to history
    ---@param wait number? amount of time to wait
    return function(msg, hl, history, wait)
        -- TODO: without schedule wrapper may echo prefix spaces
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

nvim.builtin_echo = nvim.echo
nvim.p = M.cool_echo
nvim.echo = function(chunks, history)
    vim.validate(
        {
            chunks = {chunks, "t"},
            history = {history, "b", true}
        }
    )
    api.nvim_echo(chunks, history or true, {})
end

---Expand a tab in a string
---@param str string
---@param ts string
---@param start number
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

---Wrapper to deal with extmarks
---@param bufnr number
---@param hl_group string
---@param start number
---@param finish number
---@param opt table
---@param delay number
M.highlight =
    (function()
    local ns = api.nvim_create_namespace("l-highlight")

    local function do_unpack(pos)
        vim.validate(
            {
                pos = {
                    pos,
                    {"table", "number"},
                    "must be table or number type"
                }
            }
        )
        local row, col
        if type(pos) == "table" then
            row, col = unpack(pos)
        else
            row = pos
        end
        col = col or 0
        return row, col
    end

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

-- This needs testing
---Write a file asynchronously using plenary
---@param path string
---@param data string
---@param sync boolean
M.write_file_async = function(path, data, sync)
    local path_ = path .. "_"
    if sync then
        local fd = assert(uv.fs_open(path_, "w", 438))
        assert(uv.fs_write(fd, data))
        assert(uv.fs_close(fd))
        uv.fs_rename(path_, path)
    else
        local err_open, fd = a.uv.fs_open(path_, "w", 438)
        assert(not err_open, err_open)

        local err_write = a.uv.fs_write(fd, data, -1)
        assert(not err_write, err_write)

        local err_close, succ = a.uv.fs_close(fd)
        assert(not err_close, err_close)

        if succ then
            a.uv.fs_rename(path_, path)
        end
    end
end

M.readfile =
    async(
    function(path)
        local _, fd = await(a.uv.fs_open(path, "r", 438))
        if fd == nil then
            return nil
        end
        local _, stat = await(a.uv.fs_fstat(fd))
        local _, data = await(a.uv.fs_read(fd, stat.size, 0))
        await(a.uv.fs_close(fd))
        return data
    end
)

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

-- ================= Tips ================== [[[
-- Search global variables:
--    filter <pattern> let g:

-- Patterns
--   http://lua-users.org/wiki/PatternsTutorial
-- ]]] === Tips ===

-- Allows us to use utils globally
_G.utils = M

return M
