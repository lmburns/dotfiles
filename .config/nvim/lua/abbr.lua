local M = {}

local log = require("common.log")
local fn = vim.fn
local cmd = vim.cmd

M.modes = {
    insert = "i",
    command = "c"
}

---This is just to show that this is possible
function M.abbr_test(lhs, rhs)
    -- cmd({cmd = "abbrev", args = {lhs, rhs}})
    cmd.abbr(lhs, rhs)
end

---Only execute the given command if the abbreviation is in `command` mode
---and the command is at the start.
---@param cmd string
---@param match string
function M.command(cmd, match)
    if fn.getcmdtype() == ":" and fn.getcmdline():match("^" .. cmd) then
        return match
    else
        return cmd
    end
end

---@class AbbrOpts
---@field expr boolean
---@field buffer boolean
---@field silent boolean
---@field only_start boolean

---Create an abbreviation, until an API command is created
---@param mode string mode commands is to be mapped
---@param lhs string text that is converted
---@param rhs string? what the abbreviation stands for
---@param args AbbrOpts?
function M.abbr(mode, lhs, rhs, args)
    args = args or {}
    local command = {}
    local mods = {}
    local mode = M.modes[mode] or mode

    if args.buffer ~= nil then
        table.insert(mods, "<buffer>")
    end

    if (args.expr ~= nil and rhs ~= nil) or ((mode == "c" or mode == "command") and args.only_start ~= false) then
        table.insert(mods, "<expr>")
    end

    for _, v in pairs(mods) do
        table.insert(command, v)
    end

    if mode == "i" or mode == "insert" then
        if rhs == nil then
            table.insert(command, 1, "iunabbrev")
            table.insert(command, lhs)
        else
            table.insert(command, 1, "iabbrev")
            table.insert(command, lhs)
            table.insert(command, rhs)
        end
    elseif mode == "c" or mode == "command" then
        if rhs == nil then
            table.insert(command, 1, "cunabbrev")
            table.insert(command, lhs)
        else
            table.insert(command, 1, "cabbrev")
            table.insert(command, lhs)

            -- ((if_statement)
            if args.only_start ~= false then
                rhs = ("v:lua.require'abbr'.command('%s', '%s')"):format(lhs, rhs)
            end

            table.insert(command, rhs)
        end
    else
        log.err(("Invalid mode: %s"):format(vim.inspect(mode)), true, {title = "Abbrs"})
        return false
    end

    if args.silent ~= nil then
        table.insert(command, 1, "silent!")
    end

    cmd(table.concat(command, " "))
end

M =
    setmetatable(
    M,
    {
        __index = function(super, k)
            local mode = rawget(super.modes, k)
            mode = mode or k
            return setmetatable(
                {
                    mode = mode
                },
                {
                    __call = function(self, lhs, rhs, opts)
                        super.abbr(self.mode, lhs, rhs, opts)
                    end
                }
            )
        end,
        __newindex = function(_, k, _)
            log.err(("invalid mode given: %s"):format(k), true, {title = "Abbrs"})
        end,
        ---Can be used like so: `require("abbr").c(lhs, rhs, opts)`
        ---@param self table
        ---@param mode string
        ---@param lhs string
        ---@param rhs string?
        ---@param opts AbbrOpts?
        __call = function(self, mode, lhs, rhs, opts)
            self.abbr(mode, lhs, rhs, opts)
        end
    }
)

-- I can't get insert mode to work
M.i("funciton", "function")

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

M.abbr("c", "PI", "PackerInstall")
M.abbr("c", "PU", "PackerUpdate")
M.abbr("c", "PS", "PackerSync")
M.abbr("c", "PC", "PackerCompile")

M.abbr("c", "man", "Man")
M.abbr("c", "vg", "vimgrep", {only_start = false})
M.abbr("c", "grep", "Grep", {only_start = false})
M.abbr("c", "lgrep", "LGrep", {only_start = false})
M.abbr("c", "buf", "Bufferize")
M.abbr("c", "req", "lua require('")
M.abbr("c", "cfilter", "Cfilter")
M.abbr("c", "cfi", "Cfilter")
M.abbr("c", "lfilter", "Lfilter")
M.abbr("c", "lfi", "Cfilter")

return M
