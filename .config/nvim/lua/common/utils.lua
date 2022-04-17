-- ========================== Globals ==========================

o = vim.opt -- vim options: behaves like `:set`
opt_local = vim.opt_local
opt_global = vim.opt_global
-- o           --  behaves like `:set` (global)
-- opt         --  behaves like `:set` (global and local)
-- opt_global  --  behaves like `:setglobal`
-- opt_local   --  behaves like `:setlocal`

g = vim.g -- vim global variables:
go = vim.go -- vim global options
w = vim.wo -- vim window options: behaves like `:setlocal`
b = vim.bo -- vim buffer options: behaves like `:setlocal`

fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
env = vim.env -- environment variable access
api = vim.api
exec = api.nvim_exec
uv = vim.loop
F = vim.F

fmt = string.format

dev = require("dev")
List = require("plenary.collections.py_list")

-- ========================== Functions ==========================

local M = {}

---Safely check if a plugin is installed
---@param check string Module to check if is installed
---@return table Module
M.prequire = function(check)
    local ok, ret = pcall(require, check)
    if not ok then
        M.notify(("%s was sourced but not installed"):format(check))
        return nil
    end
    return ret
end

-- Create an augroup with the lua api
function M.create_augroup(name, clear)
    clear = clear == nil and true or clear
    return api.nvim_create_augroup(name, {clear = clear})
end

---Create an autocmd with vim commands
---
---This allows very easy transition from vim commands
function M.autocmd(group, cmds, clear)
    clear = clear == nil and false or clear
    if type(cmds) == "string" then
        cmds = {cmds}
    end
    cmd("augroup " .. group)
    if clear then
        cmd [[au!]]
    end
    for _, c in ipairs(cmds) do
        cmd("autocmd " .. c)
    end
    cmd [[augroup END]]
end

---Create an autocmd; returns the group ID
---
---Used when all that is needed is the name, pattern, and command/callback
-- @param name: augroup name
-- @param commands: autocmd to execute
M.au = function(name, commands)
    local group = M.create_augroup(name)

    for _, command in ipairs(commands) do
        local event = command[1]
        local patt = command[2]
        local action = command[3]
        local desc = command[4] or ""

        if type(action) == "string" then
            api.nvim_create_autocmd(event, {pattern = patt, command = action, group = group, desc = desc})
        else
            api.nvim_create_autocmd(event, {pattern = patt, callback = action, group = group, desc = desc})
        end
    end

    return group
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
---@param name string
---@param commands Autocommand[]
---@return number
M.augroup = function(name, commands)
    local id = M.create_augroup(name)
    for _, autocmd in ipairs(commands) do
        local is_callback = type(autocmd.command) == "function"
        api.nvim_create_autocmd(
            autocmd.event,
            {
                group = id,
                pattern = autocmd.pattern,
                desc = autocmd.description,
                callback = is_callback and autocmd.command or nil,
                command = not is_callback and autocmd.command or nil,
                once = autocmd.once,
                nested = autocmd.nested,
                buffer = autocmd.buffer
            }
        )
    end
    return id
end

-- Create a key mapping
M.map = function(modes, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap

    if type(modes) == "string" then
        modes = {modes}
    end

    if type(rhs) == "function" then
        for _, mode in ipairs(modes) do
            vim.keymap.set(mode, lhs, rhs, opts)
        end
    else
        if rhs:lower():sub(1, #"<plug>") == "<plug>" then
            opts.noremap = false
        end

        for _, mode in ipairs(modes) do
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

-- This allows for lua function mapping
M.fmap = function(tbl)
    opts = tbl[4] or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    vim.keymap.set(tbl[1], tbl[2], tbl[3], opts)
end

-- Replace termcodes; e.g., t'<C-n>'
M.t = function(str)
    return api.nvim_replace_termcodes(str, true, true, true)
end

---Debug helper
---@vararg table | string | number: Anything to dump
M.dump = function(...)
    local objects = vim.tbl_map(M.inspect, {...})
    print(table.unpack(objects))
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
    opts = opts or {}
    api.nvim_create_user_command(name, rhs, opts)
end

-- Check whether the current buffer is empty
function M.is_buffer_empty()
    return fn.empty(fn.expand("%:t")) == 1
end

-- Check if the windows width is greater than a given number of columns
function M.has_width_gt(cols)
    return fn.winwidth(0) / 2 > cols
end

function M.get_visual_selection()
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

--- Wrapper to send a notification
--- This may not be that useful
---@param  options same options as `nvim_notify`
M.notify = function(options)
    if type(options) == "string" then
        api.nvim_notify(options, vim.log.levels.INFO, {icon = "", title = "Notification"})
        return
    end

    local forced =
        vim.tbl_extend(
        "force",
        {
            message = "This is a sample notification.",
            icon = "",
            title = "Notification",
            level = vim.log.levels.INFO
        },
        options or {}
    )
    api.nvim_notify(forced.message, forced.level, {title = forced.title, icon = forced.icon})
end

M.preserve = function(arguments)
    local arguments = fmt("keepjumps keeppatterns execute %q", arguments)
    local line, col = unpack(api.nvim_win_get_cursor(0))
    api.nvim_command(arguments)
    local lastline = fn.line("$")
    if line > lastline then
        line = lastline
    end

    api.nvim_win_set_cursor(0, {line, col})
end

-- vim.cmd([[cnoreab cls Preserve]])
-- vim.cmd([[command! Preserve lua preserve('%s/\\s\\+$//ge')]])
-- vim.cmd([[command! Reindent lua preserve("sil keepj normal! gg=G")]])
-- vim.cmd([[command! BufOnly lua preserve("silent! %bd|e#

---Remove duplicate blank lines (2 -> 1)
M.squeeze_blank_lines = function()
    if vim.bo.binary == false and vim.opt.filetype:get() ~= "diff" then
        local old_query = vim.fn.getreg("/") -- save search register
        M.preserve("sil! 1,.s/^\\n\\{2,}/\\r/gn") -- set current search count number
        local result = fn.searchcount({maxcount = 1000, timeout = 500}).current
        local line, col = unpack(api.nvim_win_get_cursor(0))
        M.preserve("sil! keepp keepj %s/^\\n\\{2,}/\\r/ge")
        M.preserve("sil! keepp keepj %s/\\v($\\n\\s*)+%$/\\r/e")
        -- M.preserve([[sil! keepp keepj 0;/^\%(\n*.\)\@!/,$d]])
        if result > 0 then
            api.nvim_win_set_cursor(0, {(line - result), col})
        end
        fn.setreg("/", old_query) -- restore search register
    end
end

M.colors = function(filter)
    local defs = {}
    local hl_defs = api.nvim__get_hl_defs(0)
    for hl_name, hl in pairs(hl_defs) do
        if filter then
            if hl_name:find(filter) then
                local def = {}
                if hl.link then
                    def.link = hl.link
                end
                for key, def_key in pairs({foreground = "fg", background = "bg", special = "sp"}) do
                    if type(hl[key]) == "number" then
                        local hex = string.format("#%06x", hl[key])
                        def[def_key] = hex
                    end
                end
                for _, style in pairs({"bold", "italic", "underline", "undercurl", "reverse"}) do
                    if hl[style] then
                        def.style = (def.style and (def.style .. ",") or "") .. style
                    end
                end
                defs[hl_name] = def
            end
        else
            defs = hl_defs
        end
    end
    M.dump(defs)
end

M.open_url_under_cursor = function()
    if vim.fn.has("mac") == 1 then
        vim.cmd('call jobstart(["open", expand("<cfile>")], {"detach": v:true})')
    elseif vim.fn.has("unix") == 1 then
        vim.cmd('call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})')
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

---API for command mappings
-- Supports lua function args
---@param args string|table
-- function M.cmd(args)
--     if type(args) == "table" then
--         for i = 2, #args do
--             if fn.exists(":" .. args[2]) == 2 then
--                 cmd("delcommand " .. args[2])
--             end
--             if type(args[i]) == "function" then
--                 args[i] = func2str(args[i], true)
--             end
--         end
--         args = table.concat(args, " ")
--     end
--     cmd("command! " .. args)
-- end

-- ================= Tips ================== [[[
-- Search global variables:
--    filter <pattern> let g:
-- ]]] === Tips ===

-- Allows us to use utils globally
_G.utils = M

return M
