---@module 'usr.api'
---@description Vim API utility functions
---@class Api
local M = {}

local lazy = require("usr.lazy")
local lib = require("usr.lib")
local log = lib.log
local disposable = lib.disposable

local shared = require("usr.shared")
local utils = shared.utils
local D = shared.dev
local F = shared.F
local A = require("usr.shared.utils.async")
local tbl = shared.tbl

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Autocmd                          │
--  ╰──────────────────────────────────────────────────────────╯

---Create an augroup with the lua api
---@param name string augroup name
---@param opts? Autocmd.clear should the group be cleared or deleted first?
---@return number id
function M.create_augroup(name, opts)
    opts = F.unwrap_or(opts, {}) --[[@as table]]
    if opts.del == true then
        if not M.del_augroup(name) then
            log.err(("failed to delete augroup: "):format(name))
        end
    end

    return api.nvim_create_augroup(name, {clear = F.unwrap_or(opts.clear, true)})
end

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string|{[1]: string, clear?: bool, del?: bool} augroup name. If table, can clear or delete group
---@param ... Autocmd.Builder|Autocmd.Builder[]
---@return number id Group ID of the augroup and table of autocmd ID's
---@return Disposable[] disposable
function M.augroup(name, ...)
    local id
    if type(name) == "table" then
        id = M.create_augroup(name[1], {clear = name.clear, del = name.del})
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
---@param autocmd Autocmd.Builder
---@param id? Autocmd.id Group ID of the `autocmd`
---@return Disposable|{id: Autocmd.id}
function M.autocmd(autocmd, id)
    local is_callback = F.is.fn(autocmd.command)
    if autocmd.group then
        if type(autocmd.group) == "table" then
            autocmd.group = M.create_augroup(
                autocmd.group[1],
                {clear = autocmd.group.clear, del = autocmd.group.del}
            )
        end
        if autocmd.clear then
            local events = F.ifis_tbl(autocmd.event, autocmd.event, {autocmd.event})
            for _, event in ipairs(events) do
                api.nvim_clear_autocmds({group = autocmd.group, event = event})
            end
        end
    end

    if id and autocmd.del then
        api.nvim_del_autocmd(id)
    end

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

    return disposable:create(function()
        api.nvim_del_autocmd(autocmd_id)
    end, {id = autocmd_id})
end

---Delete an autocmd. Uses `pcall`
---@param id Autocmd.id
---@return boolean, string?
function M.del_autocmd(id)
    vim.validate {id = {id, "number"}}
    return pcall(api.nvim_del_autocmd, id)
end

---Delete an augroup. Uses `pcall`
---@param id string|Augroup.id
---@return boolean, string?
function M.del_augroup(id)
    vim.validate({
        id = {id, {"s", "n"}, "augroup name must be a string or number"},
    })

    local api_call = F.ifis_str(
        id,
        api.nvim_del_augroup_by_name,
        api.nvim_del_augroup_by_id
    )
    return pcall(api_call, id)
end

---Get an autocmd
---@param opts Autocmd.Req.Opts
---@return Autocmd_t
function M.get_autocmd(opts)
    vim.validate({opts = {opts, "table", true}})
    opts = opts or {}
    local ok, autocmds = pcall(api.nvim_get_autocmds, opts)
    if not ok then
        autocmds = {}
    end
    return autocmds
end

---Clear an autocmd.
---API version of `:au!`
---@param group string|string[]|Augroup.id|Augroup.id[] group(s) to clear
---@param event? Nvim.Event|Nvim.Event[] event(s) to clear
---@param pattern? string|string[] pattern to clear
---@overload fun(opts: {})
---@overload fun(opts: Autocmd.Clear.Opts)
---@overload fun(group: string|Augroup.id|string[]|Augroup.id[])
---@overload fun(group: string|Augroup.id|string[]|Augroup.id[], event: Nvim.Event|Nvim.Event[])
---@overload fun(group: string|Augroup.id|string[]|Augroup.id[], event: Nvim.Event|Nvim.Event[], buffer: bufnr)
---@overload fun(group: string|Augroup.id|string[]|Augroup.id[], event: "'*'", pattern: string|string[])
---@overload fun(group: string|Augroup.id|string[]|Augroup.id[], event: Nvim.Event|Nvim.Event[], pattern: string|string[])
function M.clear_autocmd(group, event, pattern)
    vim.validate({
        group = {group, {"s", "n", "t"}, false},
        event = {event, {"s", "t"}, true},
        pattern = {pattern, {"s", "t", "n"}, true},
    })

    local args = {group, event, pattern}
    local nargs = #args

    -- :au[tocmd]! [group] {event} {aupat} [++once] [++nested] {cmd}
    if nargs == 3 then
        if F.is.int(pattern) then
            -- NOTE: pattern = buffer
            -- :au[tocmd]! [group] {event} {buffer}
            api.nvim_clear_autocmds({group = group, event = event, buffer = pattern})
        else
            local groups = F.ifis_tbl(group, group, {group})
            if event == "*" then
                -- :au[tocmd]! [group] * {aupat}
                --    Remove all autocmds matching {aupat} for all events
                for _, g in ipairs(groups) do
                    api.nvim_clear_autocmds({group = g, pattern = pattern})
                end
            else
                -- :au[tocmd]! [group] {event} {aupat}
                --   Remove all autocmds matching {event} and {aupat} (many groups)
                for _, g in ipairs(groups) do
                    api.nvim_clear_autocmds({group = g, event = event, pattern = pattern})
                end
            end
        end
    elseif nargs == 2 then
        local groups = F.ifis_tbl(group, group, {group})
        -- :au[tocmd]! [group] {event}
        --   Remove ALL autocommands for {event}

        _j(groups):each(utils.lambda([[g -> api.nvim_clear_autocmds({group = g, event = event})]]))

        -- for _, g in ipairs(groups) do
        --     api.nvim_clear_autocmds({group = g, event = event})
        -- end
    else
        if F.is.tbl(group) and F.is.empty(group) then
            -- Remove all autocmds not part of any group
            api.nvim_clear_autocmds({})
        elseif F.is.hash(group) then
            -- API format
            local groups = F.ifis_tbl(group.group, group.group, {group.group})
            group.group = nil
            api.nvim_clear_autocmds(group)
            for _, g in ipairs(groups) do
                api.nvim_clear_autocmds({group = g, unpack(group)})
            end
        else
            local groups = F.ifis_tbl(group, group, {group})
            _j(groups):each(utils.lambda([[g -> api.nvim_clear_autocmds({group = g})]]))
        end
    end
end

---Execute autocommands for `event`.
---API version of `:doautocmd`
---@param group? string|string[] group to exec
---@param event Nvim.Event|Nvim.Event[] event(s) to exec
---@param pattern? string|string[] pattern to exec
---@param opts Autocmd.Exec.Opts
---@overload fun(event: Nvim.Event|Nvim.Event[], opts?: Autocmd.Exec.Opts)
---@overload fun(event: Nvim.Event|Nvim.Event[])
---@overload fun(group: string|string[], event: Nvim.Event|Nvim.Event[])
---@overload fun(group: string|string[], event: Nvim.Event|Nvim.Event[], pattern: string|string[])
---@overload fun(group: string|string[], event: Nvim.Event|Nvim.Event[], pattern: string|string[], opts: Autocmd.Exec.Opts)
function M.doautocmd(group, event, pattern, opts)
    vim.validate({
        group = {group, {"s", "t"}, false},
        event = {event, {"s", "t"}, true},
        pattern = {pattern, {"s", "t"}, true},
        opts = {opts, {"t"}, true},
    })

    local args = {group, event, pattern, opts}
    local nargs = #args
    opts = opts or {}

    if nargs == 4 then
        -- :do[autocmd] <nomodeline> [group] {event} [patt]
        opts = vim.tbl_extend("keep", {group = group, pattern = pattern}, opts)
        api.nvim_exec_autocmds(event, opts)
    elseif nargs == 3 then
        -- :do[autocmd] [group] {event} [patt]
        api.nvim_exec_autocmds(event, {group = group, pattern = pattern})
    elseif nargs == 2 then
        -- API format
        if F.is.hash(event) then
            -- NOTE: group = event name; event = opts
            api.nvim_exec_autocmds(group, event)
        else
            -- :do[autocmd] [group] {event}
            api.nvim_exec_autocmds(event, {group = group})
        end

        -- TODO: add support for this variation
        -- :do[autocmd] {event} [patt]
    else
        -- :do[autocmd] {event}
        -- NOTE: group here is actually an event name
        api.nvim_exec_autocmds(group, {})
    end
end

---Call the function `fn` with autocommands disabled.
---@generic R, V: any?
---@param exec fun(v: V)|string
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

---Sets the current buffer in a window, without side effects
---@param win winid
---@param buf bufnr
function M.noau_win_set_buf(win, buf)
    M.noautocmd(api.nvim_win_set_buf, win, buf)
end

M.noau = M.noautocmd
M.doau = M.doautocmd

--  ╭──────────────────────────────────────────────────────────╮
--  │                           Map                            │
--  ╰──────────────────────────────────────────────────────────╯

---Only works if you don't set multiple command opts
---@param opts Keymap.Builder
---@param check? boolean
local function clear_cmds(opts, check)
    A.setTimeout(function()
        opts.cmd = nil
        opts.lcmd = nil
        opts.ccmd = nil
        opts.vlua = nil
        opts.vluar = nil
        opts.ncmd = nil
        opts.nncmd = nil
        opts.turbo = nil
    end, check and 5 or 0)
end

---Create a key mapping
---
---@see Keymap.Builder
---@see Keymap_t
---@see Keymap.Disposable
---@param modes Keymap.mode|Keymap.mode[] modes the keymapping should be bound
---@param lhs string|string[] key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts? Keymap.Builder: options given to keybindings
---@return Keymap.Disposable?: Returns a table with a two keys `dispose` & `map`. `.dispose()` can be used for temporary keymaps.
function M.map(modes, lhs, rhs, opts)
    -- Making local increases performance
    -- since this is the most costly function I have on startup
    local vim = vim

    local ok, err = pcall(vim.validate, {
        mode = {modes, {"s", "t"}},
        lhs = {lhs, {"s", "t"}},
        rhs = {rhs, {"s", "f"}, true},
        opts = {opts, "t", true},
    })

    if not ok then
        log.err(("%s\nlhs: %s\nrhs: %s"):format(err, lhs, rhs), {debug = true})
        return
    end

    -- By checking next on an array you get more consistent results
    --    without checking, times have 100ms variation
    --    with checking, times only have a 40ms variation
    local next, type = next, type
    local A = require("usr.shared.utils.async")

    opts = vim.deepcopy(opts) or {} --[[@as Keymap.Builder]]
    modes = type(modes) == "string" and {modes} or modes --[==[@as string[]]==]
    local lhs_t = type(lhs) == "string" and {lhs} or lhs --[==[@as string[]]==]

    -- Sometimes helps
    local check = not opts.turbo
    opts.turbo = nil
    if not check then
        clear_cmds(opts, check)
    end

    if check then
        local cond_t = type(opts.cond)
        if cond_t ~= "nil" then
            if cond_t == "function" then
                if not opts.cond() then
                    return
                end
            elseif not opts.cond then
                return
            end
            opts.cond = nil
        end

        -- aliases
        -- A.setTimeoutv(function()
        if opts.ignore or opts.desc == "ignore" then
            opts.desc = "which_key_ignore"
            opts.ignore = nil
        end
        if opts.sil then
            opts.silent = opts.sil
            opts.sil = nil
        end
        if opts.now then
            opts.nowait = opts.now
            opts.now = nil
        end
        if opts.buf then
            opts.buffer = opts.buf
            opts.buf = nil
        end
        if opts.expr and opts.replace_keycodes ~= false then
            opts.replace_keycodes = true
        end
        if opts.remap ~= nil then
            opts.noremap = not opts.remap
            opts.remap = nil
        end
        opts.noremap = opts.noremap ~= false
        opts.silent = opts.silent ~= false
        -- end, 0)
    end

    if type(rhs) == "function" then
        opts.callback = rhs
        rhs = ""
    elseif check then
        if rhs:lower():find("^<plug>") then
            opts.noremap = false
        end

        if opts.cmd then
            rhs = ("<Cmd>%s<CR>"):format(rhs)
            opts.cmd = nil
            goto down_there
        end
        if opts.lcmd then
            rhs = ("<Cmd>lua %s<CR>"):format(rhs)
            opts.lcmd = nil
            goto down_there
        end
        if opts.ccmd then
            rhs = ("<Cmd>call %s<CR>"):format(rhs)
            opts.ccmd = nil
            goto down_there
        end
        if opts.vlua then
            rhs = ("v:lua.%s"):format(rhs)
            opts.expr = true
            opts.vlua = nil
            goto down_there
        end
        if opts.vluar then
            rhs = ("v:lua.require%s"):format(rhs)
            opts.expr = true
            opts.vluar = nil
            goto down_there
        end
        if opts.ncmd then
            rhs = ("<Cmd>norm %s<CR>"):format(rhs)
            opts.ncmd = nil
            goto down_there
        end
        if opts.nncmd then
            rhs = ("<Cmd>norm! %s<CR>"):format(rhs)
            opts.nncmd = nil
            goto down_there
        end

        ::down_there::
        clear_cmds(opts)
        opts.replace_keycodes = nil
    end

    local bufnr = F.ift_then(opts.buffer, 0) --[[@as number]]
    opts.buffer = nil

    local mappings = {}
    local bmappings = {}
    local ft = opts.ft
    opts.ft = nil

    if bufnr then
        if check and opts.unmap then
            opts.unmap = nil
            for _, mode in ipairs(modes) do
                for _, lhs in ipairs(lhs_t) do
                    if fn.hasmapto(lhs, mode) > 1 then
                        -- The check above confirming the bufnr is valid shaves off 40-50ms
                        M.del_keymap(mode, lhs, {notify = true, buffer = bufnr})
                    end
                end
            end
        end
        for _, mode in ipairs(modes) do
            for _, lhs in ipairs(lhs_t) do
                table.insert(bmappings, {bufnr, mode, lhs, rhs, opts})
            end
        end
    else
        if check and opts.unmap then
            opts.unmap = nil
            for _, mode in ipairs(modes) do
                for _, lhs in ipairs(lhs_t) do
                    if fn.hasmapto(lhs, mode) > 1 then
                        M.del_keymap(mode, lhs, {notify = true})
                    end
                end
            end
        end
        for _, mode in ipairs(modes) do
            for _, lhs in ipairs(lhs_t) do
                table.insert(mappings, {mode, lhs, rhs, opts})
            end
        end
    end

    A.setTimeoutv(function()
        if ft then
            -- ft = F.is.tbl(ft) and ft or {ft}
            -- vim.iter(ft):each(function(f)
            --     require("usr.lib.ftplugin").extend(f, {
            --         bindings = {
            --             unpack(mappings),
            --             unpack(bmappings),
            --         },
            --     })
            -- end)

            M.autocmd({
                event = "FileType",
                pattern = ft,
                command = function()
                    if next(mappings) then
                        for _, map in ipairs(mappings) do
                            api.nvim_set_keymap(unpack(map))
                        end
                    end
                    if next(bmappings) then
                        for _, map in ipairs(bmappings) do
                            api.nvim_buf_set_keymap(unpack(map))
                        end
                    end
                end,
            })
        end
    end, 10)

    for _, m in ipairs(mappings) do
        api.nvim_set_keymap(unpack(m))
    end
    for _, m in ipairs(bmappings) do
        api.nvim_buf_set_keymap(unpack(m))
    end

    return disposable:create(
        function()
            M.del_keymap(modes, lhs, {buffer = bufnr})
        end,
        {
            lhs = lhs,
            modes = modes,
            buffer = bufnr,
            map = function()
                return M.map(modes, lhs, rhs, opts)
            end,
            maps = function()
                local maps = {}
                for _, m in ipairs(modes) do
                    table.insert(maps, M.get_keymap(m, lhs, {buffer = bufnr}))
                end
                return maps
            end,
        }
    )
end

---Create a buffer key mapping
---@param bufnr bufnr buffer ID
---@param modes Keymap.mode|Keymap.mode[] modes the keymapping should be bound
---@param lhs string|string[]  key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts? Keymap.Builder options given to keybindings
---@return Keymap.Disposable?: Returns a table with a single key `dispose` which can be ran to remove
---@overload fun(modes: Keymap.mode|Keymap.mode[], modes: string|string[], lhs: string|fun():string?, rhs: Keymap.Builder)
function M.bmap(bufnr, modes, lhs, rhs, opts)
    opts = opts or {} --[[@as Keymap.Builder]]
    if type(bufnr) ~= "number" then
        modes, lhs, rhs, opts = bufnr, modes, lhs, rhs
        bufnr = 0
    end
    opts.buffer = bufnr
    return M.map(modes, lhs, rhs, opts)
end

---Create a buffer key mapping for the current buffer only
---@param modes Keymap.mode|Keymap.mode[] modes the keymapping should be bound
---@param lhs string|string[]        key(s) that are mapped
---@param rhs string|fun(): string? string or Lua function that will be bound
---@param opts? Keymap.Builder    options given to keybindings
---@return Keymap.Disposable?: Returns a table with a single key `dispose` which can be ran to remove
function M.bmap0(modes, lhs, rhs, opts)
    opts = opts or {} --[[@as Keymap.Builder]]
    opts.buffer = 0
    return M.map(modes, lhs, rhs, opts)
end

---Delete a keymapping
---@param modes Keymap.mode|Keymap.mode[] modes to be deleted
---@param lhs string|string[]        keybinding that is to be deleted
---@param opts? Keymap.Del.Opts   options
---@return {restore: fun()}
function M.del_keymap(modes, lhs, opts)
    vim.validate({
        mode = {modes, {"s", "t"}},
        lhs = {lhs, "s", "t"},
        opts = {opts, "t", true},
    })

    opts          = F.ife_nnil(opts, vim.deepcopy(opts), {}) --[[@as Keymap.Del.Opts]]
    modes         = F.tern(type(modes) == "string", {modes}, modes) --[==[@as string[]]==]
    local lhs_t   = F.tern(type(lhs) == "string", {lhs}, lhs) --[==[@as string[]]==]
    local bufnr   = F.true_or(opts.buffer, 0)
    opts.notify   = F.unwrap_or(opts.notify, false)

    -- FIX: If this is a callback, it doesn't allow remapping
    local curr_km = {}
    for _, m in ipairs(modes) do
        table.insert(curr_km, M.get_keymap(m, lhs, {buffer = opts.buffer}))
    end

    if bufnr then
        for _, mode in ipairs(modes) do
            for _, lhs in ipairs(lhs_t) do
                local ok = pcall(api.nvim_buf_del_keymap, bufnr, mode, lhs)
                if not ok and opts.notify then
                    log.warn(("'%s' is unmapped (bufnr: %d)"):format(lhs, bufnr), {debug = true})
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

    return {
        restore = function()
            for _, c in ipairs(curr_km) do
                M.map(c.mode, lhs, c.callback or c.rhs, {
                    expr = c.expr == 1,
                    noremap = c.noremap == 1,
                    nowait = c.nowait == 1,
                    silent = c.silent == 1,
                    buffer = c.buffer ~= 0,
                })
            end
        end,
    }
end

---Get a given keymapping
---If only a mode is given, this acts the same as `api.nvim_get_keymap()`
---@param mode Keymap.mode mode that should be returned
---@param search? string pattern to search
---@param opts? Keymap.Search.Opts options to help search
---@return Keymap_t|Keymap_t[]
function M.get_keymap(mode, search, opts)
    opts          = F.unwrap_or(opts, {}) --[[@as Keymap.Search.Opts]]
    opts.lhs      = F.unwrap_or(opts.lhs, true)
    opts.buffer   = F.unwrap_or(opts.buffer, false)
    opts.pcre     = F.unwrap_or(opts.pcre, false)
    opts.exact    = F.unwrap_or(opts.exact, true)

    ---@type Keymap_t
    local res     = {}
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
    ---@param side "'lhs'"|"'rhs'"
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
---@param mode Keymap.mode mode to reset the keybinding in
---@param lhs string keybinding to reset
---@param opts? Keymap.Builder Options given to keybindings
function M.reset_keymap(mode, lhs, opts)
    opts = opts or {}
    opts.desc = ("Reset %s keymap"):format(lhs)
    M.map(mode, lhs, lhs, opts)
end

---Move a keymap
---@param mode Keymap.mode
---@param lhs string
---@param new_mode Keymap.mode
---@param new_lhs string
---@param buffer? bufnr
function M.mv_keymap(mode, lhs, new_mode, new_lhs, buffer)
    local mapinfo
    if buffer then
        mapinfo = api.nvim_buf_get_keymap(buffer, mode)
    else
        mapinfo = api.nvim_get_keymap(mode)
    end

    for _, map in ipairs(mapinfo) do
        if map.mode == mode and map.lhs == lhs then
            local opts = {
                buffer = buffer,
                expr = map.expr == 1,
                remap = map.noremap == 0,
                nowait = map.nowait == 1,
                silent = map.silent == 1,
            }

            M.map(new_mode, new_lhs, map.rhs or map.callback, opts)
            M.del_keymap(mode, lhs, {buffer = buffer})
        end
    end
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                         Command                          │
--  ╰──────────────────────────────────────────────────────────╯

---Create an `nvim` command
---@param name string
---@param rhs string|fun(args: Command.Fn.Args): nil
---@param opts? Command.Builder
function M.command(name, rhs, opts)
    vim.validate({
        name = {name, "string"},
        rhs = {rhs, {"f", "s"}},
        opts = {opts, "table", true},
    })

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
---@param opts? Command.Builder
function M.bcommand(name, rhs, opts)
    opts = opts or {}
    opts.buffer = true
    M.command(name, rhs, opts)
end

---Delete a command
---@param name string Command to delete
---@param buffer? buffer Whether to delete buffer command
function M.del_command(name, buffer)
    vim.validate({
        name = {name, "s"},
        buffer = {buffer, {"b", "n"}, true},
    })

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
---@param winid winid
---@param line? line_t
---@param column? col_t
function M.set_cursor(winid, line, column)
    local bufnr = api.nvim_win_get_buf(winid)

    pcall(api.nvim_win_set_cursor, winid, {
        D.clamp(line or 1, 1, api.nvim_buf_line_count(bufnr)),
        math.max(0, column or 0),
    })
end

---Easier cursor retrieval
---@param winid? winid
---@return Cursor_t
function M.get_cursor(winid)
    winid = F.unwrap_or(winid, 0)
    return api.nvim_win_get_cursor(winid)
end

---Easier cursor row retrieval
---@param winid? winid
---@return row_t row
function M.get_cursor_row(winid)
    winid = F.unwrap_or(winid, 0)
    return api.nvim_win_get_cursor(winid)[1]
end

---Easier cursor column retrieval
---@param winid? winid
---@return col_t column
function M.get_cursor_col(winid)
    winid = F.unwrap_or(winid, 0)
    return api.nvim_win_get_cursor(winid)[2]
end

--  ╭────────╮
--  │ Output │
--  ╰────────╯

---Execute an EX command, returning output
---@param exec string command to execute
---@param str? boolean make output a string
---@return string|string[]
function M.exec_output(exec, str)
    local out = api.nvim_exec2(exec, {output = true})
    return str and out.output or vim.split(out.output, "\n", {trimempty = true})
end

---Get the latest messages from `messages` command
---NOTE: Doesn't seem to work with noice
---@param count size_t? of messages to get
---@param str boolean whether to return as a string or table
---@return string|string[]
function M.messages(count, str)
    local lines = M.exec_output("messages")
    lines = tbl.filter(lines, function(line)
        return line ~= ""
    end)
    count = count and tonumber(count) or nil
    count = (count ~= nil and count >= 0) and count - 1 or #lines
    local slice = vim.list_slice(lines, #lines - count)
    return str and table.concat(slice, "\n") or slice
end

--  ╭───────╮
--  │ Other │
--  ╰───────╯

---Get syntax group of item under cursor.
---Equivalent to:
---```lua
---  fn.synIDattr(fn.synID(fn.line("."), fn.col("."), 1), "name")
---```
---Except treesitter groups can be attained
---@param ts? boolean|1|2|3 @should treesitter be tried?
---@param bufnr? bufnr
---@param row? row_t
---@param col? col_t
---@return string[]
function M.synid(ts, bufnr, row, col)
    local info = vim.inspect_pos(bufnr, row, col)
    ts = F.unwrap_or(ts, true)

    local thl = _j(info.treesitter):map(function(val) return val.hl_group end)
    local vhl = _j(info.syntax):map(function(val) return val.hl_group end)

    if ts == true and not vim.tbl_isempty(thl) then
        return thl:clean()
    elseif ts == false then
        return vhl:clean()
    end

    local ret = Rc.fn.switch(ts) {
        [1] = vhl,
        [2] = thl,
        [3] = thl:merge(vhl),
        [Rc.fn.switch.Default] = vhl,
    }

    return ret:clean()
end

---Check that the current version is greater than or equal to the given version
---@param major number
---@param minor number
---@param _ number? patch
---@return boolean
function M.version(major, minor, _)
    vim.validate({
        major = {major, "n", false},
        minor = {minor, "n", false},
    })
    local v = vim.version()
    return major >= v.major and minor >= v.minor
end

---Call the function `f`, ignoring most window/buffer autocmds
---no_win_event_call
---@generic R
---@param f fun(): R
---@return boolean, R
function M.noau_win_call(f)
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

vim.paste = (function(overridden)
    return function(lines, phase)
        for i, line in ipairs(lines) do
            -- Scrub ANSI color codes from paste input.
            lines[i] = line:gsub("\27%[[0-9;mK]+", "")
        end
        overridden(lines, phase)
    end
end)(vim.paste)

local function init()
    M.buf = lazy.require("usr.api.buf") ---@module 'usr.api.buf'
    M.win = lazy.require("usr.api.win") ---@module 'usr.api.win'
    M.tab = lazy.require("usr.api.tab") ---@module 'usr.api.tab'
    M.opt = lazy.require("usr.api.opt") ---@module 'usr.api.opt'
    M.abbr = lazy.require("usr.api.abbr") ---@module 'usr.api.abbr'
end

init()

return M
