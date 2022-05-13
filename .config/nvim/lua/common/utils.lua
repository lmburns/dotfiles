-- ========================== Functions ==========================

local M = {}

---Safely check if a plugin is installed
---@param check string Module to check if is installed
---@return table Module
M.prequire = function(check, opts)
    opts = opts or {silent = false}
    local ok, ret = pcall(require, check)
    if not ok and not opts.silent then
        M.notify({message = ("%s was sourced but not installed"):format(check), level = log.levels.ERROR})
        return nil
    end
    return ret
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

---@class Autocommand
---@field description string
---@field event  string[] list of autocommand events
---@field pattern string[] list of autocommand patterns
---@field command string | function
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

-- FIXME: Why is the `ShowDocumentation` key needed to be pressed multiple times for this function?

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

    vim.validate {
        bufnr = {bufnr, {"n", "nil"}, true},
        mode = {modes, {"s", "t"}},
        lhs = {lhs, "s"},
        rhs = {rhs, {"s", "f"}},
        opts = {opts, "t", true}
    }

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
                opts.desc = nil
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

-- This allows for lua function mapping only
M.fmap = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    vim.keymap.set(mode, lhs, rhs, opts)
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

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean
--- @field count number

---Create an nvim command
---@param name any
---@param rhs string|fun(args: CommandArgs)
---@param opts table
M.command = function(name, rhs, opts)
    vim.validate {
        name = {name, "string"},
        cmd = {
            cmd,
            function(c)
                return type(c) == "string" or vim.is_callable(c)
            end,
            "a string or a lua function"
        },
        opts = {opts, "table", true}
    }

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
M.bcommand = function(name, rhs, opts, bufnr)
    opts = opts or {}
    -- opts.force = true
    api.nvim_buf_create_user_command(bufnr or 0, name, rhs, opts)
end

---Delete a command
---@param name string Command to delete
---@param buffer? boolean|number Whether to delete buffer command
M.del_command = function(name, buffer)
    vim.validate {
        name = {name, "string"},
        buffer = {
            buffer,
            function(b)
                return type(b) == "boolean" or type(b) == "number"
            end,
            "a boolean or a number"
        }
    }
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
        cmd(fmt("source %s", path))
    else
        cmd(("source %s/%s"):format(fn.stdpath("config"), path))
    end
end

-- Check whether the current buffer is empty
M.is_buffer_empty = function()
    return fn.empty(fn.expand("%:t")) == 1
end

-- Check if the windows width is greater than a given number of columns
M.has_width_gt = function(cols)
    return fn.winwidth(0) / 2 > cols
end

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
        api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
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

M.open_url_under_cursor = function()
    if fn.has("mac") == 1 then
        fn.jobstart(("open %s"):format(fn.expand("<cfile>")), {detach = true})
    elseif fn.has("unix") == 1 then
        fn.jobstart(("handlr open %s"):format(fn.expand("<cfile>")), {detach = true})
    else
        vim.notify("Error: gx is not supported on this OS!")
    end
end

-- ========================== Mapping Implentation ==========================
-- ======================== Credit: ibhagwan/nvim-lua =======================
--
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

local func2str = function(func, args)
    local idx = #_G.myluafunc + 1
    _G.myluafunc[idx] = func
    if not args then
        return ("lua myluafunc(%s)"):format(idx)
    else
        -- return ("lua myluafunc(%s, <q-args>)"):format(idx)
        return ("lua myluafunc(%s, <q-args>, <count>)"):format(idx)
    end
end

---Remap keys (create a Vim function with Lua)
M.remap = function(modes, lhs, rhs, opts)
    modes = type(modes) == "string" and {modes} or modes
    opts = opts or {}
    opts = type(opts) == "string" and {opts} or opts

    local fallback = function()
        return api.nvim_feedkeys(M.t(lhs), "n", true)
    end

    local _rhs =
        (function()
        if type(rhs) == "function" then
            opts.noremap = true
            opts.cmd = true
            return func2str(
                function()
                    rhs(fallback)
                end
            )
        else
            if rhs:lower():sub(1, #"<plug>") == "<plug>" then
                opts.noremap = false
            end
            return rhs
        end
    end)()

    for key, opt in ipairs(opts) do
        opts[opt] = true
        opts[key] = nil
    end

    local buffer = (function()
        if opts.buffer then
            opts.buffer = nil
            return true
        end
    end)()

    _rhs = (function()
        if opts.cmd then
            opts.cmd = nil
            return ("<cmd>%s<cr>"):format(_rhs)
        else
            return _rhs
        end
    end)()

    for _, mode in ipairs(modes) do
        if buffer then
            api.nvim_buf_set_keymap(0, mode, lhs, _rhs, opts)
        else
            api.nvim_set_keymap(mode, lhs, _rhs, opts)
        end
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

---Program to check if executable
---@param exec string
---@return boolean
M.executable = function(exec)
    vim.validate {exec = {exec, "string"}}
    assert(exec ~= "", debug.traceback "Empty executable string")
    return fn.executable(exec) == 1
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
