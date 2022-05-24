local M = {}

local utils = require("common.utils")

---@alias Group string
---@alias Color string

---@class ColorFormat
---@field default boolean Don't override existing definition
---@field background string
---@field foreground string
---@field special string
---@field bg string
---@field fg string
---@field sp string
---@field blend number 0 to 100
---@field bold boolean
---@field standout boolean
---@field underline boolean
---@field undercurl boolean
---@field underdot boolean
---@field underdash boolean
---@field strikethrough boolean
---@field italic boolean
---@field reverse boolean
---@field nocombine boolean
---@field link string
---@field inherit string
---@field from string
---@field gui string
---@deprecated @field guifg string
---@deprecated @field guibg string
---@deprecated @field guisp string

---Define bg color
---@param group Group
---@param color Color
---@param fmt ColorFormat
function M.bg(group, color, fmt)
    -- cmd(("hi %s guibg=%s"):format(group, col))
    local opts = {}
    if fmt then
        vim.tbl_extend("keep", opts, fmt)
    end
    opts.bg = color
    M.set_hl(group, opts)
end

---Define fg color
---@param group Group
---@param color Color
---@param fmt ColorFormat
function M.fg(group, color, fmt)
    -- local g = gui == nil and "" or (" gui=%s"):format(gui)
    -- cmd(("hi %s guifg=%s %s"):format(group, color, g))
    local opts = {}
    if fmt then
        vim.tbl_extend("keep", opts, fmt)
    end
    opts.fg = color
    M.set_hl(group, opts)
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
---@param fmt ColorFormat
function M.fg_bg(group, fgcol, bgcol, fmt)
    -- cmd(("hi %s guifg=%s guibg=%s"):format(group, fgcol, bgcol))
    local opts = {}
    if fmt then
        vim.tbl_extend("keep", opts, fmt)
    end
    opts.fg = fgcol
    opts.bg = bgcol
    M.set_hl(group, opts)
end

---Highlight link one group to another
---@param from string group that is going to be linked
---@param to string group that is linked to
---@param bang boolean? whether or not to force highlight (default is true)
function M.link(from, to, bang)
    -- I think force is more preferred
    bang = bang ~= false and "!" or " default"
    cmd(("hi%s link %s %s"):format(bang, from, to))
end

---@deprecated
---Create a highlight group
---@param higroup string: Group that is being defined
---@param hi_info table: Table of options
---@param default? boolean: Whether `default` should be used
function M.hl_set(higroup, hi_info, default)
    local options = {}
    for k, v in pairs(hi_info) do
        table.insert(options, string.format("%s=%s", k, v))
    end
    cmd(("hi %s %s %s"):format(default and "default" or "", higroup, table.concat(options, " ")))
end

---Define a highilght group in pure lua
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
---@param exact boolean whether filter should be exact
M.colors = function(filter, exact)
    local defs = {}
    local hl_defs = api.nvim__get_hl_defs(0)
    for hl_name, hl in pairs(hl_defs) do
        if filter then
            if hl_name:find(filter) then
                if exact and hl_name ~= filter then
                    goto continue
                end
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
                for _, style in pairs(
                    {
                        "bold",
                        "standout",
                        "italic",
                        "underline",
                        "undercurl",
                        "underdot",
                        "underdash",
                        "reverse",
                        "strikethrough"
                    }
                ) do
                    if hl[style] then
                        def.style = (def.style and (def.style .. ",") or "") .. style
                    end
                end
                defs[hl_name] = def
            end
        else
            defs = hl_defs
        end
        ::continue::
    end
    utils.dump(defs)
end

utils.command(
    "Color",
    function(tbl)
        require("common.color").colors(tbl.args)
    end,
    {nargs = "?"}
)

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

---Convert a `gui=...` into valid arguments for `api.nvim_set_hl`
---@param guistr string
---@return table
local function convert_gui(guistr)
    local gui = {}
    guistr = guistr:gsub(".*", string.lower)
    local parts = vim.split(guistr, ",")

    for _, part in ipairs(parts) do
        if part:match("none") then
            gui.italic = false
            gui.bold = false
            gui.underline = false
            gui.undercurl = false
        else
            gui[part] = true
        end
    end
    return gui
end

local keys = {guisp = "sp", guibg = "background", guifg = "foreground", default = "default"}

---This helper takes a table of highlights and converts any highlights
---specified as `highlight_prop = { from = 'group'}` into the underlying
---color by querying the highlight property of the `from` group so it can
---be used when specifying highlights as a shorthand to derive the right color.
---i
---For example:
---```lua
---  M.set_hl({ MatchParen = {foreground = {from = 'ErrorMsg'}}})
---```
---This will take the foreground color from ErrorMsg and set it to the foreground of MatchParen.
---
---This function will also convert legacy keys (i.e., `guisp`, `guibg`, `guibg`, and `default`)
---into keys that `api.nvim_set_hl` will accept.
---
---@param opts table<string, string|boolean|table<string,string>>
local function convert_hl_to_val(opts)
    for name, value in pairs(opts) do
        if type(value) == "table" and value.from then
            opts[name] = M.get_hl(value.from, F.if_nil(value.attr, name))
        elseif keys[name] then
            opts[keys[name]] = value
            opts[name] = nil
        end
    end
end

---Create a highlight group
---
---@param name string
---@param opts ColorFormat
function M.set_hl(name, opts)
    vim.validate {
        name = {name, "string", false},
        opts = {opts, "table", false}
    }

    if opts.gui then
        opts = vim.tbl_extend("force", opts, convert_gui(opts.gui))
        opts.gui = nil
    end

    local hl = get_hl(opts.inherit or name)
    convert_hl_to_val(opts)
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
        M.set_hl(name, hl)
    end
end

---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param hls table<ColorFormat, string|boolean|number> list of highlights
function M.plugin(name, hls)
    name = name:gsub("^%l", string.upper) -- capitalize the name for autocommand convention sake
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
