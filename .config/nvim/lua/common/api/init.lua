---@module 'common.api'
---@description 'Vim API utility functions'
---@class API
local M = {}

local D = require("dev")
local utils = require("common.utils")
local log = require("common.log")
local lazy = require("common.lazy")
local disposable = require("common.disposable")

-- local wk = require("which-key")

local api = vim.api
local fn = vim.fn
local F = vim.F

---Call the function `fn` with autocommands disabled.
---@generic R, V: any
---@generic T: fun()
---@param exec T<fun(v: V):R>|string
---@param ... V
---@return R?
function M.noautocmd(exec, ...)
    local ei = vim.o.eventignore
    vim.o.eventignore = "all"
    local ok, res
    if type(exec) == "string" then
        ok, res = pcall(cmd, exec)
    elseif type(exec) == "function" then
        ok, res = pcall(exec, ...)
    end
    vim.o.eventignore = ei
    return ok and res or nil
end

---Execute all autocommands for `event`
---@param event NvimEvent|NvimEvent[] event(s) to exec
---@param opts AutocmdExec
function M.doautocmd(event, opts)
    api.nvim_exec_autocmds(event, opts)
end

M.noau = M.noautocmd
M.doau = M.doautocmd

---Sets the current buffer in a window, without side effects
---@param win winid
---@param buf bufnr
M.noau_win_set_buf = function(win, buf)
    M.noautocmd(api.nvim_win_set_buf, win, buf)
end

---Call the function `f`, ignoring most window/buffer autocmds
---no_win_event_call
---@generic R
---@param f fun(): R
---@return boolean, R
M.noau_win_call = function(f)
    local ei = vim.o.eventignore

    vim.opt.eventignore:prepend(
        utils.list(
            {
                "WinEnter",
                "WinLeave",
                "WinNew",
                "WinClosed",
                "BufWinEnter",
                "BufWinLeave",
                "BufEnter",
                "BufLeave",
            }
        )
    )
    local ok, err = pcall(f)
    vim.opt.eventignore = ei
    return ok, err
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Autocmd                          │
--  ╰──────────────────────────────────────────────────────────╯

---Create an augroup with the lua api
---@param name string augroup name
---@param clear? boolean should the group be cleared?
---@return number id
M.create_augroup = function(name, clear)
    clear = F.unwrap_or(clear, true)
    return api.nvim_create_augroup(name, {clear = clear})
end

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string|{ [1]: string, [2]: boolean } Augroup name. If a table, `true` can be passed to clear the group
---@param ... Autocmd|Autocmd[]
---@return number, Disposable[]: Group ID of the augroup and table of autocmd ID's
M.augroup = function(name, ...)
    local id
    -- If name is a table, user wants to probably not clear the augroup
    if type(name) == "table" then
        id = M.create_augroup(name[1], name[2])
    else
        id = M.create_augroup(name)
    end

    local cmd_ids = {}
    for _, autocmd in ipairs({...}) do
        table.insert(cmd_ids, M.autocmd(autocmd, id))
    end

    return id, cmd_ids
end

---Create a single autocmd
---@param autocmd Autocmd
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
                callback = F.if_expr(is_callback, autocmd.command, nil),
                command = F.if_expr(not is_callback, autocmd.command, nil),
                once = autocmd.once,
                nested = autocmd.nested,
                buffer = autocmd.buffer,
            }
        )

    return disposable:create(
        function()
            api.nvim_del_autocmd(autocmd_id)
        end,
        {id = autocmd_id}
    )
end

---Delete an augroup. Uses `pcall`
---@param id string|number
---@return boolean
function M.del_augroup(id)
    vim.validate({
        id = {id, {"s", "n"}, "augroup name must be a string or number"},
    })

    local api_call =
        F.if_expr(
            type(id) == "string",
            api.nvim_del_augroup_by_name,
            api.nvim_del_augroup_by_id
        )
    local ok, _ = pcall(api_call, id)
    return ok
end

---Get an autocmd
---@param opts AutocmdReqOpts
---@return Autocmd_t
function M.get_autocmd(opts)
    vim.validate{opts = {opts, "table", true}}
    opts = opts or {}

    local ok, autocmds = pcall(api.nvim_get_autocmds, opts)
    if not ok then
        autocmds = {}
    end
    return autocmds
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           Map                            │
--  ╰──────────────────────────────────────────────────────────╯

-- TODO: Add a throttle option that doesn't check anything and just maps

---Create a key mapping
---
---@see MapArgs
---@see Keymap_t
---@see KeymapDisposable
---@param modes KeymapMode|KeymapMode[] modes the keymapping should be bound
---@param lhs string|string[]  key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts? MapArgs: options given to keybindings
---@return KeymapDiposable?: Returns a table with a two keys `dispose` & `map`. `.dispose()` can be used for temporary keymaps.
M.map = function(modes, lhs, rhs, opts)
    local ok, err =
        pcall(
            vim.validate,
            {
                mode = {modes, {"s", "t"}},
                lhs = {lhs, {"s", "t"}},
                rhs = {rhs, {"s", "f"}},
                opts = {opts, "t", true},
            }
        )

    if not ok then
        log.err(("%s\nlhs: %s\nrhs: %s"):format(err, lhs, rhs), {debug = true})
        return
    end

    opts = vim.deepcopy(opts) or {} --[[@as MapArgs]]
    modes = type(modes) == "string" and {modes} or modes --[==[@as string[]]==]
    local lhs_t = type(lhs) == "string" and {lhs} or lhs --[==[@as string[]]==]

    if opts.cond ~= nil then
        if type(opts.cond) == "function" then
            if not opts.cond() then
                return
            end
        elseif not opts.cond then
            return
        end
        opts.cond = nil
    end

    if opts.ignore or opts.desc == "ignore" then
        opts.desc = "which_key_ignore"
        opts.ignore = nil
    end

    if opts.expr and opts.replace_keycodes ~= false then
        opts.replace_keycodes = true
    end
    if opts.sil then
        opts.silent = opts.sil
        opts.sil = nil
    end

    if opts.remap ~= nil then
        opts.noremap = not opts.remap
        opts.remap = nil
    end
    opts.noremap = opts.noremap ~= false

    if type(rhs) == "function" then
        opts.callback = rhs
        rhs = ""
    else
        if rhs:lower():find("^<plug>") then
            opts.noremap = false
        end

        if opts.cmd then
            rhs = ("<Cmd>%s<CR>"):format(rhs)
            opts.cmd = nil
            opts.luacmd = nil
        end

        if opts.luacmd then
            rhs = ("<Cmd>lua %s<CR>"):format(rhs)
            opts.luacmd = nil
        end

        opts.replace_keycodes = nil
    end

    if opts.buf then
        opts.buffer = opts.buf
        opts.buf = nil
    end

    local bufnr = F.true_or(opts.buffer, 0) --[[@as number]]
    -- local bufnr = F.if_then(opts.buffer == true or opts.buffer == 0, 0)
    opts.buffer = nil

    local mappings = {}
    local bmappings = {}

    if bufnr then
        if opts.unmap then
            opts.unmap = nil
            vim.iter(modes):each(function(mode)
                vim.iter(lhs_t):each(function(lhs)
                    if fn.hasmapto(lhs, mode) > 1 then
                        M.del_keymap(mode, lhs, {notify = true, buffer = bufnr})
                    end
                end)
            end)
        end
        vim.iter(modes):each(function(mode)
            vim.iter(lhs_t):each(function(lhs)
                table.insert(bmappings, {bufnr, mode, lhs, rhs, opts})
            end)
        end)
    else
        if opts.unmap then
            opts.unmap = nil
            vim.iter(modes):each(function(mode)
                vim.iter(lhs_t):each(function(lhs)
                    if fn.hasmapto(lhs, mode) > 1 then
                        M.del_keymap(mode, lhs, {notify = true})
                    end
                end)
            end)
        end
        vim.iter(modes):each(function(mode)
            vim.iter(lhs_t):each(function(lhs)
                table.insert(mappings, {mode, lhs, rhs, opts})
            end)
        end)
    end

    if opts.ft then
        vim.defer_fn(function()
            M.autocmd({
                event = "FileType",
                pattern = opts.ft,
                command = function()
                    for _, map in ipairs(mappings) do
                        api.nvim_set_keymap(unpack(map))
                    end
                    for _, map in ipairs(bmappings) do
                        api.nvim_buf_set_keymap(unpack(map))
                    end
                end,
            })
        end)

        return
    end

    vim.iter(mappings):each(function(m) api.nvim_set_keymap(unpack(m)) end)
    vim.iter(bmappings):each(function(m) api.nvim_buf_set_keymap(unpack(m)) end)

    return disposable:create(
        function()
            M.del_keymap(modes, lhs, {buffer = bufnr})
        end,
        {
            lhs = lhs,
            modes = modes,
            buffer = bufnr,
            map = function()
                local mode = modes[1]
                return M.get_keymap(mode, lhs)
            end,
        }
    )
end

---Create a buffer key mapping
---@param bufnr number buffer ID
---@param modes KeymapMode|KeymapMode[] modes the keymapping should be bound
---@param lhs string|string[]  key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts? MapArgs options given to keybindings
---@return KeymapDiposable?: Returns a table with a single key `dispose` which can be ran to remove
M.bmap = function(bufnr, modes, lhs, rhs, opts)
    opts = opts or {} --[[@as MapArgs]]
    if type(bufnr) ~= "number" then
        modes, lhs, rhs, opts = bufnr, modes, lhs, rhs
        bufnr = 0
    end
    opts.buffer = bufnr
    return M.map(modes, lhs, rhs, opts)
end

---Delete a keymapping
---@param modes KeymapMode|KeymapMode[] modes to be deleted
---@param lhs string|string[]  keybinding that is to be deleted
---@param opts? DelMapArgs  options
M.del_keymap = function(modes, lhs, opts)
    vim.validate({
        mode = {modes, {"s", "t"}},
        lhs = {lhs, "s", "t"},
        opts = {opts, "t", true},
    })

    opts = vim.deepcopy(opts) or {} --[[@as DelMapArgs]]
    modes = F.tern(type(modes) == "string", {modes}, modes) --[==[@as string[]]==]
    local lhs_t = F.tern(type(lhs) == "string", {lhs}, lhs) --[==[@as string[]]==]
    local bufnr = F.if_expr(opts.buffer == true, 0, opts.buffer) --[[@as number]]
    opts.notify = F.nnil_or(opts.notify, true)

    if bufnr then
        for _, mode in ipairs(modes) do
            for _, lhs in ipairs(lhs_t) do
                local ok = pcall(api.nvim_buf_del_keymap, bufnr, mode, lhs)
                if not ok and opts.notify then
                    log.warn(("'%s' is unmapped"):format(lhs), {debug = true})
                end
            end
        end
    else
        for _, mode in ipairs(modes) do
            for _, lhs in ipairs(lhs_t) do
                local ok = pcall(api.nvim_del_keymap, mode, lhs)
                if not ok and opts.notify then
                    log.warn(("'%s' is unmapped"):format(lhs), {debug = true})
                end
            end
        end
    end
end

---Get a given keymapping
---If only a mode is given, this acts the same as `api.nvim_get_keymap()`
---@param mode KeymapMode mode that should be returned
---@param search? string pattern to search
---@param opts? KeymapSearchOpts options to help search
---@return Keymap_t|Keymap_t[]
M.get_keymap = function(mode, search, opts)
    opts = F.unwrap_or(opts, {})
    opts.lhs = F.unwrap_or(opts.lhs, true)
    opts.buffer = F.unwrap_or(opts.buffer, false)
    opts.pcre = F.unwrap_or(opts.pcre, false)
    opts.exact = F.unwrap_or(opts.exact, true)

    local res = {}
    local keymaps = F.if_expr(
        opts.buffer,
        api.nvim_buf_get_keymap(0, mode),
        api.nvim_get_keymap(mode)
    )

    if search == nil then
        return keymaps
    end
    if search:lower():find("<leader>") then
        search = search:lower():gsub("<leader>", g.mapleader)
    end
    if search:lower():find("<localleader>") then
        search = search:lower():gsub("<localleader>", g.maplocalleader)
    end
    if search:find("<C%-") then
        search = search:gsub("(<C%-[%w%p-]+>[%w%p]?)", string.upper)
    end

    ---@param keymap Keymap_t
    ---@param side 'lhs'|'rhs'
    local function find_patt(keymap, side)
        ---@type Keymap_t
        local km
        if keymap[side] then
            if opts.pcre then
                if keymap[side]:rxmatch(search) then
                    km = keymap
                end
            else
                if keymap[side] == search then
                    km = keymap
                end
            end

            if km and side == "lhs" then
                km.lhs = km.lhs:gsub(("^%s"):format(g.mapleader), "<Leader>")
                km.lhs = km.lhs:gsub(("^%s"):format(g.maplocalleader), "<LocalLeader>")
            end

            table.insert(res, km)
        end
    end

    for _, keymap in ipairs(keymaps) do
        if opts.lhs then
            find_patt(keymap, "lhs")
        else
            find_patt(keymap, "rhs")
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

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Command                          │
--  ╰──────────────────────────────────────────────────────────╯

---Create an `nvim` command
---@param name string
---@param rhs string|fun(args: CommandArgs): nil
---@param opts? CommandOpts
M.command = function(name, rhs, opts)
    vim.validate{
        name = {name, "string"},
        rhs = {rhs, {"f", "s"}},
        opts = {opts, "table", true},
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
        utils.mod.prequire("legendary"):thenCall(function(lgnd)
            lgnd.command({
                (":%s"):format(name),
                opts = {
                    desc = opts.desc,
                    buffer = F.if_expr(is_buffer, 0, nil),
                },
            })
        end)
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
    vim.validate{
        name = {name, "string"},
        buffer = {buffer, {"boolean", "number"}, "a boolean or a number"},
    }

    if buffer then
        buffer = type(buffer) == "number" and buffer or 0
        api.nvim_buf_del_user_command(buffer, name)
    else
        api.nvim_del_user_command(name)
    end
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Other                           │
--  ╰──────────────────────────────────────────────────────────╯

--  ╭────────╮
--  │ Cursor │
--  ╰────────╯

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
            math.max(0, column or 0),
        }
    )
end

---Easier cursor retrieval
---@param winnr? integer
---@return {[1]: integer, [2]: integer}
M.get_cursor = function(winnr)
    winnr = F.unwrap_or(winnr, 0)
    return api.nvim_win_get_cursor(winnr)
end

--  ╭────────╮
--  │ Output │
--  ╰────────╯

---Execute an EX command, returning output
---@param exec string command to execute
---@return string[]
M.get_ex_output = function(exec)
    local out = api.nvim_exec2(exec, {output = true})
    return vim.split(out.output, "\n")
end

---Get the output of a vim command in a *table*
---@param cmd string
---@return Vector<string>
M.get_vim_output = function(cmd)
    local out = api.nvim_exec(cmd, true)
    local res = vim.split(out, "\n", {trimempty = true})
    return D.map(
        res,
        function(val)
            return vim.trim(val)
        end
    )
end

---Get the latest messages from `messages` command
---@param count number? of messages to get
---@param str boolean whether to return as a string or table
---@return string|string[]
M.messages = function(count, str)
    local lines = M.get_ex_output("messages")
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

--  ╭───────╮
--  │ Other │
--  ╰───────╯

---Get a Vim option. Will return in the order of: local > global > default
---@param option string option to get
---@param default? Option_t fallback option
---@param opts? GetOptionOpts
---@return Option_t
M.get_option = function(option, default, opts)
    local ok, opt = pcall(api.nvim_get_option_value, option, F.unwrap_or(opts, {}))
    if not ok then
        opt = default
    end
    return opt
end

---Get a Vim option information. If no option given, return all
---@param option? string option to get
---@param opts? GetOptionOpts
---@return GetOptionInfo
M.get_option_info = function(option, opts)
    opts = F.unwrap_or(opts, {})
    local ok, info
    if option then
        ok, info = pcall(api.nvim_get_option_info2, option, opts)
        if not ok then
            return {}
        end
    else
        info = api.nvim_get_all_options_info()
    end
    return info
end

---Toggle a boolean option
---@param option string
---@param values? Option_t[] values to toggle between (default: booleans)
---@param opts? GetOptionOpts
---@param title? string
M.toggle_option = function(option, values, opts, title)
    M.option:set()
    local value
    if opts == nil then
        value = M.option:get(option).value
    else
        value = M.get_option(option, nil, opts)
    end

    if type(values) == "table" and #values >= 2 then
        local v1, v2 = values[1], values[2]
        if type(v1) == type(v2) and type(v1) == type(value) then
            value = F.if_expr(value == v1, v2, v1)
            vim.opt[option] = value
            log.info(("state: %s"):format(value), {title = F.unwrap_or(title, option)})
            M.option.cache[option].value = value
        end
    elseif value ~= nil then
        vim.opt[option] = not value
        log.info(("state: %s"):format(not value), {title = F.unwrap_or(title, option)})
        M.option.cache[option].value = not value
    end
end

---Check that the current version is greater than or equal to the given version
---@param major number
---@param minor number
---@param _ number? patch
---@return boolean
M.version = function(major, minor, _)
    vim.validate({
        major = {major, "n", false},
        minor = {minor, "n", false},
    })
    local v = vim.version()
    return major >= v.major and minor >= v.minor
end

--  ══════════════════════════════════════════════════════════════════════

---Cache to track all information about all options
---@class OptionCache
M.option = {cache = {}}

---Setup the option cache
---@return OptionCache
function M.option:set()
    setmetatable({}, self)
    self.__index = self
    if vim.tbl_isempty(self.cache) then
        local info = api.nvim_get_all_options_info()
        for opt, _ in pairs(info) do
            info[opt].value = M.get_option(opt, nil, {})
        end
        self.cache = info
    end
    return self
end

---Get an option value
---@param opt string
---@return GetOptionInfo|Dict<GetOptionInfo>
function M.option:get(opt)
    if opt then
        return self.cache[opt]
    end
    return self.cache
end

local function init()
    ---@module "common.api.buf"
    M.buf = lazy.require_on_exported_call("common.api.buf")
    ---@module "common.api.win"
    M.win = lazy.require_on_exported_call("common.api.win")
    ---@module "common.api.tab"
    M.tab = lazy.require_on_exported_call("common.api.tab")

    vim.defer_fn(
        function()
            M.option:set()
        end,
        500
    )
end

init()

return M
