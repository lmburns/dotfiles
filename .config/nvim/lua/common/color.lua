local M = {}

local utils = require("common.utils")

---@alias Group string
---@alias Color string

---Define bg color
---@param group Group
---@param color Color
function M.bg(group, col)
    cmd(("hi %s guibg=%s"):format(group, col))
end

---Define fg color
---@param group Group
---@param color Color
function M.fg(group, color, gui)
    local g = gui == nil and "" or (" gui=%s"):format(gui)
    cmd(("hi %s guifg=%s %s"):format(group, color, g))
end

---Group to modify gui
---@param group string
---@param gui string
function M.gui(group, gui)
    cmd(("hi %s gui=%s"):format(group, g))
end

---Define bg and fg color
---@param group Group
---@param fgcol Color
---@param bgcol Color
function M.fg_bg(group, fgcol, bgcol)
    cmd(("hi %s guifg=%s guibg=%s"):format(group, fgcol, bgcol))
end

---Highlight link one group to another
---@param from string group that is going to be linked
---@param to string group that is linked to
---@param bang boolean whether or not to force highlight (default is true)
function M.link(from, to, bang)
    -- I think force is more preferred
    bang = bang ~= false and "!" or " default"
    cmd(("hi%s link %s %s"):format(bang, from, to))
end

---Create a highlight group
---@param higroup string: Group that is being defined
---@param hi_info table: Table of options
---@param default? boolean: Whether `default` should be used
function M.set_hl(higroup, hi_info, default)
    local options = {}
    for k, v in pairs(hi_info) do
        table.insert(options, string.format("%s=%s", k, v))
    end
    cmd(("hi %s %s %s"):format(default and "default" or "", higroup, table.concat(options, " ")))
end

---Define a highilght group in pure lua
---Parameters accepted are ctermfg, ctermbg, cterm, default
---
---@param group string: Global highlight group
---@param opts table: Options for the highlight
---@param ns_id? number: Optional namespace ID
function M.hl(group, opts, ns_id)
    vim.validate {
        opts = {opts, "table", true}
    }
    api.nvim_set_hl(F.if_nil(ns_id, 0), group, opts)
end

---List all highlight groups, or ones matching `filter`
---@param filter string
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
    utils.dump(defs)
end   

---Remove escape sequences of the following formats:
---1. ^[[34m
---2. ^[[0;34m
---@param str string
---@return string
M.strip_ansi = function(str)
    if not str then
        return str
    end
    return str:gsub("%[[%d;]+m", "")
end

M.ansi_codes = {}

---List of ansi escape sequences
M.ansi_colors = {
    clear = "\x1b[0m",
    bold = "\x1b[1m",
    italic = "\x1b[3m",
    underline = "\x1b[4m",
    black = "\x1b[0;30m",
    red = "\x1b[0;31m",
    green = "\x1b[0;32m",
    yellow = "\x1b[0;33m",
    blue = "\x1b[0;34m",
    magenta = "\x1b[0;35m",
    cyan = "\x1b[0;36m",
    white = "\x1b[0;37m",
    grey = "\x1b[0;90m",
    dark_grey = "\x1b[0;97m"
}

---Add ansi functions
---Can be called line color.ansi_codes.yellow("string")
---
---@param name string: Color
---@param escseq string: Escape sequence
---@return string
M.add_ansi_code = function(name, escseq)
    M.ansi_codes[name] = function(string)
        if string == nil or #string == 0 then
            return ""
        end
        return escseq .. string .. M.ansi_colors.clear
    end
end

for color, escseq in pairs(M.ansi_colors) do
    M.add_ansi_code(color, escseq)
end

return M
