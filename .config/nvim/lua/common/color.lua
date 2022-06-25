local M = {}

-- local D = require("dev")
local utils = require("common.utils")
local log = require("common.log")

-- local fn = vim.fn
local cmd = vim.cmd
local api = {
    set = vim.api.nvim_set_hl,
    get = vim.api.nvim_get_hl_by_name,
    defs = vim.api.nvim__get_hl_defs
}

---@alias Group string
---@alias Color string
---@alias HighlightAttribute
---| '"foreground"'
---| '"background"'
---| '"fg"'
---| '"bg"'

---@class ColorFormat
---@field default boolean Don't override existing definition
---@field background string
---@field foreground string
---@field special string
---@field fg string|fun():string
---@field bg string|fun():string
---@field sp string
---@field blend number 0 to 100
---@field bold boolean
---@field standout boolean
---@field underline boolean
---@field underlineline boolean
---@field undercurl boolean
---@field underdot boolean
---@field underdash boolean
---@field strikethrough boolean
---@field italic boolean
---@field reverse boolean
---@field nocombine boolean
---@field link boolean|string
---@field inherit string
---@field from string Not here by default
---@field gui string  Not here by default
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
---@param group Group
---@param gui string
function M.gui(group, gui)
    cmd(("hi %s gui=%s"):format(group, gui))
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
function M.link(from, to)
    -- bang = bang ~= false and "!" or " default"
    -- cmd(("hi%s link %s %s"):format(bang, from, to))
    M.set_hl(from, {link = to})
end

---Convert a hex color (#RRGGBB) to (#RRGGBB) RGB
---@param color Color
---@return table<number, number, number>
local function hex_to_rgb(color)
    local hex = color:gsub("#", ""):gsub("0x", "")
    return {
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    }
end

---Convert RGB decimal to hexadecimal (#RRGGBB)
---@param dec number|string
---@return string color @#RRGGBB
local function hex(dec)
    -- return ("#%06x"):format(dec)
    return ("#%s"):format(bit.tohex(dec, 6))
end

local function alter(attr, percent)
    return math.floor(attr * (100 + percent) / 100)
end

---Turn the `foreground` and `background` fields into hex-strings
---@param group ColorFormat
---@return ColorFormat
local function stringify_attrs(group)
    group.foreground = group.foreground and hex(group.foreground)
    group.background = group.background and hex(group.background)
    group[true] = nil -- BUG: API returns a true key which errors
    return group
end

---Return a highlight group as a fallback
---@param groups table<Color>|Color @highlight group list
---@return ColorFormat
local function fallback(groups)
    groups = type(groups) == "string" and {groups} or groups
    groups = groups == nil and {} or groups

    for _, group in ipairs(groups) do
        local ok, hl = pcall(api.get, group, true)
        if ok then
            return stringify_attrs(hl)
        end
    end

    return {}
end

---Get a highlight group
---@param group Color @highlight group to try and get
---@param fallbacks? table<Color>|Color @highlight group list
---@return ColorFormat
local function get_hl(group, fallbacks)
    local ok, hl = pcall(api.get, group, true)
    if ok then
        return stringify_attrs(hl)
    end

    -- fn.synIDtrans()
    -- fn.synIDattr()

    return fallback(fallbacks)
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

local keys = {guisp = "sp", guibg = "background", guifg = "foreground"}

---This helper takes a table of highlights and converts any highlights
---specified as `highlight_prop = { from = 'group'}` into the underlying
---color by querying the highlight property of the `from` group so it can
---be used when specifying highlights as a shorthand to derive the right color.
---i
---For example:
---```lua
---  M.set_hl("MatchParen", {fg = {from = 'ErrorMsg'}})
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

---@source https://stackoverflow.com/q/5560248
---@see: https://stackoverflow.com/a/37797380
---
---Darken a specified hex color
---@param color string
---@param percent number
---@return string
function M.alter_color(color, percent)
    local r, g, b = unpack(hex_to_rgb(color))
    if not r or not g or not b then
        return "NONE"
    end
    r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
    r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
    return ("#%02x%02x%02x"):format(r, g, b)
end

---Parse ColorFormat into highlight definition map to be used by `nvim_set_hl`
---
---### Special `from` field
---Accepts a table of highlights, and converts them to `property = { from = 'group' }`
---by querying the property of the `from` group.
---
---For example:
---```lua
--- -- This will take the fg from ErrorMsg and set it to the fg of MatchParen
---  M.set_hl({ MatchParen = {foreground = {from = 'ErrorMsg'}}})
---```
---
---### Legacy
---Also accepts legacy keys (i.e., `guisp`, `guibg`, `guibg`).
---
---@param hl ColorFormat
function M.parse(hl)
    local def = {}

    for _, attribute in pairs({"default", "nocombine"}) do
        if hl[attribute] ~= nil then
            def[attribute] = hl[attribute]
        end
    end

    if hl.link and type(hl.link) == "string" and pcall(api.get, hl.link, true) then
        def.link = hl.link
        return def
    end

    local attributes = {
        "blend",
        "italic",
        "bold",
        "underline",
        "underlineline",
        "undercurl",
        "underdot",
        "underdash",
        "strikethrough",
        "reverse",
        "standout"
    }

    local additional_attributes = {
        "ctermfg",
        "ctermbg",
        "cterm"
    }

    local legacy = {
        guisp = "sp",
        guibg = "background",
        guifg = "foreground"
    }

    if hl.gui then
        hl = vim.tbl_extend("force", hl, convert_gui(hl.gui))
        hl.gui = nil
    end

    local inherit = {}

    if hl.inherit then
        local ok, value = pcall(api.get, hl.inherit, true)
        inherit = ok and value
    end

    -- Allow both attributes, but only use one
    -- Foreground
    if hl.fg ~= nil and hl.foreground ~= nil then
        hl.foreground = nil
    end

    if type(hl.fg) == "function" then
        hl.fg = hl.fg()
    end

    if type(hl.foreground) == "function" then
        hl.foreground = hl.fg()
    end

    -- Background
    if hl.bg ~= nil and hl.background ~= nil then
        hl.background = nil
    end

    if type(hl.bg) == "function" then
        hl.bg = hl.bg()
    end

    if type(hl.background) == "function" then
        hl.background = hl.fg()
    end

    def.foreground = hl.fg or inherit.foreground or "NONE"
    def.background = hl.bg or inherit.background or "NONE"
    def.special = F.if_nil(hl.special, inherit.special) or "NONE"
    def.italic = F.if_nil(hl.italic, inherit.italic) or false
    def.bold = F.if_nil(hl.bold, inherit.bold) or false
    def.underline = F.if_nil(hl.underline, inherit.underline) or false
    def.underlineline = F.if_nil(hl.underlineline, inherit.underlineline) or false
    def.undercurl = F.if_nil(hl.undercurl, inherit.undercurl) or false
    def.underdot = F.if_nil(hl.underdot, inherit.underdot) or false
    def.underdash = F.if_nil(hl.underdash, inherit.underdash) or false
    def.strikethrough = F.if_nil(hl.strikethrough, inherit.strikethrough) or false
    def.reverse = F.if_nil(hl.reverse, inherit.reverse) or false
    def.standout = F.if_nil(hl.standout, inherit.standout) or false

    -- `blend` field is not set by default
    -- set it only if the inherited group is set
    if inherit.blend then
        def.blend = inherit.blend
    end

    for _, attribute in pairs(attributes) do
        if hl[attribute] ~= nil then
            def[attribute] = hl[attribute]
        end
    end

    for _, attribute in pairs(additional_attributes) do
        if hl[attribute] ~= nil then
            def[attribute] = hl[attribute]
        end
    end

    -- Legacy values have the highest priority
    for old, attribute in pairs(legacy) do
        if hl[old] ~= nil then
            def[attribute] = hl[old]
            hl[old] = nil
        end
    end

    -- Special `from` field
    -- WinSeparator = { bg = 'NONE', fg = { from = 'NonText' } }
    for name, value in pairs(hl) do
        if type(value) == "table" and value.from then
            def[name] = M.get_hl(value.from, F.if_nil(value.attr, name))
        end
    end

    return def
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

    -- if opts.gui then
    --     opts = vim.tbl_extend("force", opts, convert_gui(opts.gui))
    --     opts.gui = nil
    -- end
    --
    -- local hl = get_hl(opts.inherit or name)
    -- convert_hl_to_val(opts)
    -- opts.inherit = nil

    -- local ok, msg = pcall(api.set, 0, name, vim.tbl_deep_extend("force", hl, opts))

    local ok, msg = pcall(api.set, 0, name, M.parse(opts))

    if not ok then
        log.err(("Failed to set %s: %s"):format(name, msg))
    end
end

---Get the value a highlight group whilst handling errors, fallbacks as well as returning a gui value
---in the right format
---@param group Group
---@param attribute string
---@param fallback Color?
---@return string
function M.get_hl(group, attribute, fallback)
    if not group then
        log.err("Need a group to get a highlight")
        return "NONE"
    end

    local hl = get_hl(group, fallback)
    attribute = ({fg = "foreground", bg = "background"})[attribute] or attribute
    local color = hl[attribute] or fallback

    if not color then
        vim.schedule(
            function()
                log.warn(("%s %s does not exist"):format(group, attribute))
            end
        )
        return "NONE"
    end
    -- convert the decimal RGBA value from the hl by name to a 6 character hex + padding if needed
    return color
end

---Get the foreground string of a highlight group
---@param group Group
---@param fallback Color?
---@return string
function M.get_fg(group, fallback)
    M.get_hl(group, "foreground", fallback)
end

---Get the background string of a highlight group
---@param group Group
---@param fallback Color?
---@return string
function M.get_bg(group, fallback)
    M.get_hl(group, "background", fallback)
end

---Clear a highlight group
---@param name string
function M.clear_hl(name)
    assert(name, "name is required to clear a highlight")
    M.set_hl(name, {})
end

---Apply a list of highlights
---@param hls table<string, table<string, boolean|string>>
function M.all(hls)
    for name, hl in pairs(hls) do
        M.set_hl(name, hl)
    end
end

---TODO: Add a field `cond`
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

---List all highlight groups, or ones matching `filter`
---@param filter string
---@param exact boolean whether filter should be exact
M.colors = function(filter, exact)
    local defs = {}
    local hl_defs = api.defs(0)
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
                        local hex = hex(hl[key])
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
    -- utils.dump(defs)
    return defs
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           ANSI                           │
-- ╰──────────────────────────────────────────────────────────╯

M.ansi = {}
M.ansi.codes = {}

---List of ansi escape sequences
M.ansi.colors = {
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

---Remove escape sequences of the following formats:
---1. ^[[34m
---2. ^[[0;34m
---@param str string
---@return string
M.ansi.strip = function(str)
    if not str then
        return str
    end
    return str:gsub("%[[%d;]+m", "")
end

---Add ansi functions
---Can be called line color.ansi_codes.yellow("string")
---
---@param name string: Color
---@param escseq string: Escape sequence
---@return string
M.ansi.add_code = function(name, escseq)
    M.ansi.codes[name] = function(string)
        if string == nil or #string == 0 then
            return ""
        end
        return escseq .. string .. M.ansi.colors.clear
    end
end

for color, escseq in pairs(M.ansi.colors) do
    M.ansi.add_code(color, escseq)
end

utils.command(
    "Color",
    function(tbl)
        require("common.color").colors(tbl.args)
    end,
    {nargs = "?", desc = "Search for a color"}
)

setmetatable(
    M,
    {
        ---Syntactic sugar to set a highlight group
        ---@param hlgroup Group
        ---@param opts ColorFormat
        __newindex = function(_, hlgroup, opts)
            if type(opts) == "string" then
                M.set_hl(hlgroup, {link = opts})
                return
            end

            M.set_hl(hlgroup, opts)
        end,
        ---Syntactic sugar retrieve a highlight group
        ---@param k ColorFormat
        __index = function(self, k)
            local color = rawget(self, k)
            local group = get_hl(color or k)
            if group then
                for long, short in pairs({foreground = "fg", background = "bg"}) do
                    if group[long] then
                        group[short] = group[long]
                        group[long] = nil
                    end
                end
            end
            return group
        end,
        ---Search for a color.
        ---@param self table
        ---@param k Group
        ---@return table
        __call = function(self, k)
            return self.colors(k)
        end
    }
)

return M
