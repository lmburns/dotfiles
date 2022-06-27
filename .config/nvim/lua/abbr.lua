local M = {}

local utils = require("common.utils")
local log = require("common.log")

---Create a `cnoreabbrev`
---@param input string: Thing to be replaced
---@param replace string: The abbreviation
function M.cabbrev(input, replace)
    -- ex.cnoreabbrev(input, M.command(input, replace))

    local cmd = [[cnoreabbrev <expr> %s v:lua.require'abbr'.command("%s", "%s")]]
    vim.cmd(cmd:format(input, input, replace))
end

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
---@param rhs string what the abbreviation stands for
---@param args AbbrOpts
function M.abbr(mode, lhs, rhs, args)
    args = args or {}
    local command = {}
    local mods = {}
    local modes = {insert = "i", command = "c"}
    local mode = modes[mode] or mode

    if args.buffer ~= nil then
        table.insert(mods, "<buffer>")
    end

    if args.expr ~= nil and rhs ~= nil then
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
            table.insert(command, rhs)
        end
    else
        log.err(("Invalid mode: %s"):format(vim.inspect(mode)), true, {title = "Abbrs"})
        return false
    end

    if args.silent ~= nil then
        table.insert(command, 1, "silent!")
    end

    vim.cmd(table.concat(command, " "))
end

M.abbr("c", "ld", "Linediff")
M.abbr("c", "W!", "w!")
-- -- I can't get this to work
-- M.abbr("i", "funciton", "function")

M.cabbrev("Qall!", "qll!")
M.cabbrev("Qall", "qll")
M.cabbrev("Wq", "wq")
M.cabbrev("Wa", "wa")
M.cabbrev("wQ", "wq")
M.cabbrev("WQ", "wq")
M.cabbrev("W", "w")

M.cabbrev("tel", "Telescope")
M.cabbrev("Review", "DiffviewOpen")

M.cabbrev("PI", "PackerInstall")
M.cabbrev("PU", "PackerUpdate")
M.cabbrev("PS", "PackerSync")
M.cabbrev("PC", "PackerCompile")

g.no_man_maps = 1
M.cabbrev("man", "Man")
M.cabbrev("vg", "vimgrep")
M.cabbrev("grep", "Grep")
M.cabbrev("lgrep", "LGrep")
M.cabbrev("buf", "Bufferize")
M.cabbrev("req", "lua require('")
M.cabbrev("cfilter", "Cfilter")
M.cabbrev("cfi", "Cfilter")

return M
