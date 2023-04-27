--@module common.api
---@description: Vim API utility functions
local M = {}

local D = require("dev")
local utils = require("common.utils")
local log = require("common.log")
local disposable = require("common.disposable")

local wk = require("which-key")

local api = vim.api
local fn = vim.fn
local F = vim.F

---Call the function `fn` with autocommands disabled.
---@generic T: fun(), V: any
---@param fn T<fun(v: V)>
---@param ... V
M.noautocmd = function(fn, ...)
    local ei = vim.o.eventignore
    vim.o.eventignore = "all"
    fn(...)
    vim.o.eventignore = ei
end

M.noau = M.noautocmd

---Sets the current buffer in a window, without side effects
---@param win integer
---@param buf integer
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
        utils.list({
            "WinEnter",
            "WinLeave",
            "WinNew",
            "WinClosed",
            "BufWinEnter",
            "BufWinLeave",
            "BufEnter",
            "BufLeave",
        })
    )
    local ok, err = pcall(f)
    vim.opt.eventignore = ei

    return ok, err
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Autocmd                          │
--  ╰──────────────────────────────────────────────────────────╯

---Create an augroup with the lua api
---@param name string
---@param clear? boolean
---@return number
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
        {
            id = autocmd_id,
        }
    )
end

---Delete an augroup. Uses `pcall`
---@param name_id string|number
---@return boolean
M.del_augroup = function(name_id)
    vim.validate{
        name_id = {
            name_id,
            {"s", "n"},
            "augroup name must be a string or number",
        },
    }

    local api_call = F.if_expr(
        type(name_id) == "string",
        api.nvim_del_augroup_by_name,
        api.nvim_del_augroup_by_id
    )
    local ok, _ = pcall(api_call, name_id)
    return ok
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           Map                            │
--  ╰──────────────────────────────────────────────────────────╯

-- TODO: implement filetype @field ft string|string[]
-- TODO: implement lhs string[]

---Create a key mapping
---If the `rhs` is a function, and a `bufnr` is given, the argument is instead moved into the `opts`
---
---@param modes KeymapMode|KeymapMode[] modes the keymapping should be bound
---@param lhs string|string[]  key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts? MapArgs: options given to keybindings
---@return { map: fun(): Keymap_t, dispose: fun() }?: Returns a table with a two keys `dispose` & `map`. `.dispose()` can be used for temporary keymaps.
--- See: **:map-arguments**
---@see MapArgs
---@see Keymap_t
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

    if opts.cond ~= nil then
        if type(opts.cond) == "function" then
            if not opts.cond() then
                return
            end
        elseif not opts.cond then
            return
        end
    end

    if opts.ignore or opts.desc == "ignore" then
        opts.desc = "which_key_ignore"
        opts.ignore = nil
    end

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
                        return utils.t(res)
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
                rhs = ("<Cmd>%s<CR>"):format(rhs)
                opts.cmd = nil
            end

            -- This is placed after `cmd`
            -- If `cmd` and `luacmd` are both used, `luacmd` overrules
            if opts.luacmd then
                rhs = ("<Cmd>lua %s<CR>"):format(rhs)
                opts.luacmd = nil
            end
        end

        opts.replace_keycodes = nil
        return rhs
    end)()

    local bufnr = (function()
        local b = F.if_expr(opts.buffer, 0, opts.buffer) --[[@as number]]
        opts.buffer = nil
        return b
    end)()

    if bufnr or type(bufnr) == "number" then
        for _, mode in ipairs(modes) do
            if opts.unmap then
                opts.unmap = nil

                for _, mode in ipairs(modes) do
                    -- local exists = M.get_keymap(mode, lhs, true, F.if_expr(bufnr or type(bufnr) == "number", true, false))
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
                -- local exists = M.get_keymap(mode, lhs, true, F.if_expr(bufnr or type(bufnr) == "number", true, false))
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
                return M.get_keymap(
                    mode,
                    lhs
                -- true,
                -- F.if_expr(bufnr or type(bufnr) == "number", true, false)
                )
            end,
        }
    )
end

---Create a buffer key mapping
---@param bufnr number buffer ID
---@param modes KeymapMode|KeymapMode[] modes the keymapping should be bound
---@param lhs string|string[]  key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts MapArgs options given to keybindings
---@return { map: fun(): Keymap_t, dispose: fun() }?: Returns a table with a single key `dispose` which can be ran to remove
M.bmap = function(bufnr, modes, lhs, rhs, opts)
    opts = opts or {} --[[@as MapArgs]]
    opts.buffer = bufnr
    return M.map(modes, lhs, rhs, opts)
end

---Delete a keymapping
---@param modes KeymapMode|KeymapMode[] modes to be deleted
---@param lhs string  keybinding that is to be deleted
---@param opts DelMapArgs  options
M.del_keymap = function(modes, lhs, opts)
    vim.validate{
        mode = {modes, {"s", "t"}},
        lhs = {lhs, "s"},
        opts = {opts, "t", true},
    }

    opts = vim.deepcopy(opts) or {} --[[@as DelMapArgs]]
    local modes_tbl = F.if_expr(type(modes) == "string", {modes}, modes) --[==[@as string[]]==]
    local bufnr = false
    if opts.buffer ~= nil then
        ---@diagnostic disable-next-line:cast-local-type
        bufnr = opts.buffer == true and 0 or opts.buffer
    end

    if bufnr == false then
        for _, mode in ipairs(modes_tbl) do
            local ok = pcall(api.nvim_del_keymap, mode, lhs)
            if not ok and opts.notify then
                log.warn(
                    ("%s is not mapped"):format(lhs),
                    {title = "Delete Keymap"}
                )
            end
        end
    else
        for _, mode in ipairs(modes_tbl) do
            local ok = pcall(api.nvim_buf_del_keymap, bufnr, mode, lhs)
            if not ok and opts.notify then
                log.warn(
                    ("%s is not mapped"):format(lhs),
                    {title = "Delete Keymap"}
                )
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
    if search:find("<[Ll]eader>") then
        search = search:gsub("<[Ll]eader>", g.mapleader)
    end
    if search:find("<[Ll]ocal[Ll]eader>") then
        search = search:gsub("<[Ll]ocal[Ll]eader>", g.maplocalleader)
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
        utils.mod.prequire(
            "legendary",
            function(lgnd)
                lgnd.command(
                    {
                        (":%s"):format(name),
                        opts = {
                            desc = opts.desc,
                            buffer = F.if_expr(is_buffer, 0, nil),
                        },
                    }
                )
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

---Get a Vim option. If present in buffer, return that, else global
---@generic T: string|number|table
---@param option string option to get
---@param default T fallback option
---@return T
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

---Check that the current version is greater than or equal to the given version
---@param major number
---@param minor number
---@param _ number? patch
---@return boolean
M.version = function(major, minor, _)
    vim.validate{
        major = {major, "n", false},
        minor = {minor, "n", false},
    }
    local v = vim.version()
    return major >= v.major and minor >= v.minor
end

return M
