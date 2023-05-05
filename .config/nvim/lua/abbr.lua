local M = {}

local log = require("common.log")
local fn = vim.fn
local cmd = vim.cmd

M.modes = {insert = "i", command = "c"}

---Only execute the given command if the abbreviation is in `command` mode
---and the command is at the start.
---`"<C-r>=(getcmdtype() == ':' && getcmdpos() == 1 ? 'Cdos' : 'cdos')<CR>"`
---@param cmd string
---@param match string
---@return string
function M.command(cmd, match)
    if fn.getcmdtype() == ":" and fn.getcmdline():match("^" .. cmd) then
        return match
    end
    return cmd
end

---Create an abbreviation, until an API command is created
---@param mode string mode commands is to be mapped
---@param lhs string text that is converted
---@param rhs string? what the abbreviation stands for
---@param args AbbrOpts?
function M.abbr(mode, lhs, rhs, args)
    args          = args or {}
    local command = _t({})
    local mods    = _t({})
    local mode    = M.modes[mode] or mode

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
                rhs = ("v:lua.require'abbr'.command('%s', '%s')"):format(
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

    cmd(command:concat(" "))
end

M = setmetatable(
    M, {
        __index = function(super, k)
            local mode = rawget(super.modes, k)
            mode = mode or k
            return setmetatable(
                {mode = mode}, {
                    __call = function(self, lhs, rhs, opts)
                        super.abbr(self.mode, lhs, rhs, opts)
                    end,
                }
            )
        end,
        __newindex = function(_, k, _)
            log.err(
                ("invalid mode given: %s"):format(k), {title = "Abbrs"}
            )
        end,
        ---Can be used like so: `require("abbr").c(lhs, rhs, opts)`
        ---Can be used like so: `require("abbr")(mode, lhs, rhs, opts)`
        ---@param self table
        ---@param mode string
        ---@param lhs string
        ---@param rhs string?
        ---@param opts AbbrOpts?
        __call = function(self, mode, lhs, rhs, opts)
            self.abbr(mode, lhs, rhs, opts)
        end,
    }
)

local function init()
    -- FIX: insert mode abbrs don't work
    M.abbr("i", "funciton", "function")

    M.abbr("c", "Qall!", "qll!")
    M.abbr("c", "Qall", "qll")
    M.abbr("c", "Wq", "wq")
    M.abbr("c", "Wa", "wa")
    M.abbr("c", "wQ", "wq")
    M.abbr("c", "WQ", "wq")
    M.abbr("c", "W", "w")
    M.abbr("c", "W!", "w!")

    M.abbr("c", "tel", "Telescope")
    M.abbr("c", "Review", "DiffviewOpen")
    M.abbr("c", "ld", "Linediff")
    M.abbr("c", "noice", "Noice")

    M.abbr("c", "PI", "PackerInstall")
    M.abbr("c", "PU", "PackerUpdate")
    M.abbr("c", "PS", "PackerSync")
    M.abbr("c", "PC", "PackerCompile")

    M.abbr("c", "man", "Man")
    M.abbr("c", "gg", "Ggrep", {only_start = false})
    M.abbr("c", "ggrep", "Ggrep", {only_start = false})
    M.abbr("c", "vg", "vimgrep", {only_start = false})
    M.abbr("c", "grep", "Grep", {only_start = false})
    M.abbr("c", "lgrep", "LGrep", {only_start = false})
    M.abbr("c", "hg", "helpgrep", {only_start = false})
    M.abbr("c", "buf", "Bufferize")
    M.abbr("c", "req", "lua require('")
    M.abbr("c", "cfilter", "Cfilter")
    M.abbr("c", "cfi", "Cfilter")
    M.abbr("c", "lfilter", "Lfilter")
    M.abbr("c", "lfi", "Lfilter")
end

init()

return M
