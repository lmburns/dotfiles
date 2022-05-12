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

-- ╭──────────────────────────────────────────────────────────╮
-- │                       From akinsho                       │
-- ╰──────────────────────────────────────────────────────────╯

---Convert a hex color to RGB
---@param color string
---@return number
---@return number
---@return number
local function hex_to_rgb(color)
    local hex = color:gsub("#", "")
    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5), 16)
end

local function alter(attr, percent)
    return math.floor(attr * (100 + percent) / 100)
end

---@source https://stackoverflow.com/q/5560248
---@see: https://stackoverflow.com/a/37797380
---Darken a specified hex color
---@param color string
---@param percent number
---@return string
function M.alter_color(color, percent)
    local r, g, b = hex_to_rgb(color)
    if not r or not g or not b then
        return "NONE"
    end
    r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
    r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
    return fmt("#%02x%02x%02x", r, g, b)
end

local function get_hl(group_name)
    local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, true)
    if ok then
        hl.foreground = F.if_nil(hl.foreground, hl.fg) and "#" .. bit.tohex(F.if_nil(hl.foreground, hl.fg), 6)
        hl.background = F.if_nil(hl.background, hl.bg) and "#" .. bit.tohex(F.if_nil(hl.background, hl.bg), 6)
        hl[true] = nil -- BUG: API returns a true key which errors during the merge
        return hl
    end
    return {}
end

---Create a highlight group
---
---Valid table keys:
---   - background
---   - foreground
---   - inherit
---   - link
---   - sp
---   - bold
---   - underline
---   - undercurl
---   - italic
---   - gui
---
---@param name string
---@param opts table
function M.hl_set(name, opts)
    vim.validate {
        name = {name, "string", false},
        opts = {opts, "table", false}
    }
    assert(name and opts, "Both 'name' and 'opts' must be specified")

    if opts.gui then
        opts.gui = opts.gui:gsub(".*", string.lower)

        if opts.gui:match("italic") then
            opts.italic = true
        end
        if opts.gui:match("bold") then
            opts.bold = true
        end
        if opts.gui:match("underline") then
            opts.underline = true
        end
        if opts.gui:match("undercurl") then
            opts.undercurl = true
        end

        if opts.gui:match("none") then
            opts.italic = false
            opts.bold = false
            opts.underline = false
            opts.undercurl = false
        end

        opts.gui = nil
    end

    local hl = get_hl(opts.inherit or name)
    opts.inherit = nil
    local ok, msg = pcall(api.nvim_set_hl, 0, name, vim.tbl_deep_extend("force", hl, opts))
    if not ok then
        vim.notify(fmt("Failed to set %s: %s", name, msg))
    end
end

---Get the value a highlight group whilst handling errors, fallbacks as well as returning a gui value
---in the right format
---@param group string
---@param attribute string
---@param fallback string?
---@return string
function M.get_hl(group, attribute, fallback)
    if not group then
        vim.notify("Cannot get a highlight without specifying a group", log.levels.ERROR)
        return "NONE"
    end
    local hl = get_hl(group)
    attribute = ({fg = "foreground", bg = "background"})[attribute] or attribute
    local color = hl[attribute] or fallback
    if not color then
        vim.schedule(
            function()
                vim.notify(fmt("%s %s does not exist", group, attribute), log.levels.INFO)
            end
        )
        return "NONE"
    end
    -- convert the decimal RGBA value from the hl by name to a 6 character hex + padding if needed
    return color
end

---Clear a highlight group
---@param name string
function M.clear_hl(name)
    assert(name, "name is required to clear a highlight")
    nvim.set_hl(0, name, {})
end

---Apply a list of highlights
---@param hls table<string, table<string, boolean|string>>
function M.all(hls)
    for name, hl in pairs(hls) do
        M.hl_set(name, hl)
    end
end

---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@vararg table list of highlights
function M.plugin(name, hls)
    name = name:gsub("^%l", string.upper) -- capitalise the name for autocommand convention sake
    M.all(hls)
    utils.augroup(
        ("%sHighlightOverrides"):format(name),
        {
            event = "ColorScheme",
            command = function()
                M.all(hls)
            end
        }
    )
end

return M
