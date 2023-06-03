---@module 'usr.api.abbr
---@class Abbr
---@field i {[string]: Abbr_t}[] insert mode
---@field c {[string]: Abbr_t}[] command mode
local Abbr = {
    i = {},
    c = {},
}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local fn = vim.fn
local cmd = vim.cmd

Abbr.modes = {insert = "i", command = "c"}

---Only execute the given command if the abbreviation is in `command` mode
---and the command is at the start.
---`"<C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Cdos' : 'cdos')<CR>"`
---@param cmd string
---@param mtch string
---@return string
function Abbr.command(cmd, mtch)
    if fn.getcmdtype() == ":" and fn.getcmdline():match("^" .. cmd) then
        return mtch
    end
    return cmd
end

---Create an abbreviation, until an API command is created
---@param mode string mode commands is to be mapped
---@param lhs string text that is converted
---@param rhs string? what the abbreviation stands for
---@param args AbbrOpts?
function Abbr:new(mode, lhs, rhs, args)
    args          = args or {}
    mode          = self.modes[mode] or mode
    local command = _t({})
    local mods    = _t({})

    if args.buffer ~= nil then
        mods:insert("<buffer>")
    end

    if (args.expr ~= nil and rhs ~= nil)
        or ((mode == "c" or mode == "command") and args.only_start ~= false) then
        mods:insert("<expr>")
    end

    for _, v in pairs(mods) do
        command:insert(v)
    end

    if mode == "i" or mode == "insert" then
        if rhs == nil then
            command:insert(1, "iunabbrev")
            command:insert(lhs)
        else
            command:insert(1, "iabbrev")
            command:insert(lhs)
            command:insert(rhs)
        end
    elseif mode == "c" or mode == "command" then
        if rhs == nil then
            command:insert(1, "cunabbrev")
            command:insert(lhs)
        else
            command:insert(1, "cabbrev")
            command:insert(lhs)

            -- ((if_statement)
            if args.only_start ~= false then
                rhs = ("v:lua.require'usr.api.abbr'.command('%s', '%s')"):format(
                    lhs, rhs
                )
            end

            command:insert(rhs)
        end
    else
        log.err(
            ("Invalid mode: %s"):format(vim.inspect(mode)), {title = "Abbrs"}
        )
        return
    end

    if args.silent ~= nil then
        command:insert(1, "silent!")
    end

    self[mode][lhs] = {rhs = rhs, cmd = command:concat(" ")}
    cmd(self[mode][lhs].cmd)
end

---Retrieve an abbreviation
---@param mode? '"i"'|'"c"'
---@param lhs? string
---@return {[string]: Abbr_t}|{[string]: Abbr_t}[]|{i: {[string]: Abbr_t}, c: {[string]: Abbr_t}}
function Abbr:get(mode, lhs)
    mode = self.modes[mode] or mode
    local m = rawget(self, mode)
    if m then
        if lhs then
            return rawget(self[mode], lhs)
        end
        return rawget(self, mode)
    end
    return {i = self.i, c = self.c}
end

local function init()
    -- FIX: insert mode abbrs don't work
    Abbr:new("i", "funciton", "function")

    Abbr:new("c", "Qall!", "qall!")
    Abbr:new("c", "Qall", "qall")
    Abbr:new("c", "Wq", "wq")
    Abbr:new("c", "Wa", "wa")
    Abbr:new("c", "wQ", "wq")
    Abbr:new("c", "WQ", "wq")
    Abbr:new("c", "W", "w")
    Abbr:new("c", "W!", "w!")

    Abbr:new("c", "PI", "PackerInstall")
    Abbr:new("c", "PU", "PackerUpdate")
    Abbr:new("c", "PS", "PackerSync")
    Abbr:new("c", "PC", "PackerCompile")

    Abbr:new("c", "req", "lua require('")
    Abbr:new("c", "lp", "lua p('")

    Abbr:new("c", "tel", "Telescope")
    Abbr:new("c", "Review", "DiffviewOpen")
    Abbr:new("c", "ld", "Linediff")
    Abbr:new("c", "noice", "Noice")
    Abbr:new("c", "bufr", "Bufferize", {only_start = true})

    Abbr:new("c", "man", "Man")
    Abbr:new("c", "ggr", "Ggrep", {only_start = false})
    Abbr:new("c", "ggrep", "Ggrep", {only_start = false})
    Abbr:new("c", "vgr", "vimgrep", {only_start = false})
    Abbr:new("c", "vgrep", "vimgrep", {only_start = false})
    Abbr:new("c", "gr", "Grep", {only_start = false})
    Abbr:new("c", "lg", "LGrep", {only_start = false})
    Abbr:new("c", "hgr", "helpgrep", {only_start = false})
    Abbr:new("c", "helpg", "helpgrep", {only_start = false})
    Abbr:new("c", "fil", "filter")
    -- Abbr:new("c", "filt", "filter")
    Abbr:new("c", "cfi", "Cfilter")
    Abbr:new("c", "lfilter", "Lfilter")
    Abbr:new("c", "lfi", "Lfilter")
end

init()

---@alias Abbr_t {rhs: string, cmd: string}

return Abbr
