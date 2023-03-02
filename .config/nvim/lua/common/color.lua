---@diagnostic disable:duplicate-doc-alias

local M = {}

local D = require("dev")
local utils = require("common.utils")
local log = require("common.log")

local F = vim.F
local cmd = vim.cmd
local api = {
    set = vim.api.nvim_set_hl,
    get = vim.api.nvim_get_hl_by_name,
    defs = vim.api.nvim__get_hl_defs
}

---@alias Group string
---@alias Color string

---@class HighlightAttribute
---@field from string
---@field attr 'foreground' | 'fg' | 'background' | 'bg'
---@field alter integer

---@class ColorFormat
---@field default boolean Don't override existing definition
---@field background string|HighlightAttribute
---@field foreground string|HighlightAttribute
---@field special string
---@field fg string|HighlightAttribute | fun(): string|HighlightAttribute
---@field bg string|HighlightAttribute | fun(): string|HighlightAttribute
---@field sp string|HighlightAttribute
---@field blend number 0 to 100
---@field bold boolean
---@field standout boolean
---@field underline boolean
---@field undercurl boolean Curly underline
---@field underdouble boolean Double underline
---@field underdotted boolean Dotted underline
---@field underdashed boolean Dashed underline
---@field strikethrough boolean
---@field italic boolean
---@field reverse boolean
---@field nocombine boolean Override attributes instead of combining them
---@field link boolean|string
---@field ctermfg string Sets foreground of cterm color
---@field ctermbg string Sets background of cterm color
---@field cterm CtermMap cterm attribute map
---@field inherit string Not here by default
---@field from string    Not here by default
---@field gui string     Not here by default
---@field cond string    Not here by default. Conditional colorscheme name
--                       i.e., do not execute highlight command if colorscheme differs from 'cond'
---@deprecated @field guifg string
---@deprecated @field guibg string
---@deprecated @field guisp string

---@alias CtermMap
---| '"bold"'
---| '"underline"'
---| '"undercurl"' # Curly underline
---| '"underdouble"' # Double underline
---| '"underdotted"' # Dotted underline
---| '"underdashed"' # Dashed underline
---| '"strikethrough"'
---| '"reverse"'
---| '"inverse"' # Same as revers
---| '"italic"'
---| '"standout"'
---| '"altfont"'
---| '"nocombine"' # Override attributes instead of combining them
---| '"none"' # No attributes used (used to reset it)

---@class GuiAttrs
---@field bold boolean
---@field italic boolean
---@field underline boolean
---@field undercurl boolean
---@field underdouble boolean
---@field underdotted boolean
---@field underdashed boolean
---@field strikethrough boolean

---Convert a hexidecimal color (#RRGGBB) to RGB
---@param color Color
---@return {[1]: number, [2]: number, [3]: number}
local function hex2rgb(color)
    local hex = color:gsub("#", ""):gsub("0x", "")
    return {
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    }
end

---Convert RGB decimal (RGB) to hexadecimal (#RRGGBB)
---@param dec integer
---@return string color @#RRGGBB
local function rgb2hex(dec)
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
    group.foreground = group.foreground and rgb2hex(group.foreground)
    group.background = group.background and rgb2hex(group.background)
    group[true] = nil -- BUG: API returns a true key which errors
    return group
end

---Return a highlight group as a fallback
---@param groups Color[]|Color @highlight group list
---@return ColorFormat
local function fallback(groups)
    groups = type(groups) == "string" and {groups} or groups --[[@as Color[]]
    groups = groups == nil and {} or groups --[[@as Color[]]

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
---@param fallbacks Color[]|Color @highlight group list
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
---@return GuiAttrs
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

local keys = {guisp = "special", guibg = "background", guifg = "foreground"}

---This helper takes a table of highlights and converts any highlights
---specified as `highlight_prop = { from = 'group'}` into the underlying
---color by querying the highlight property of the `from` group so it can
---be used when specifying highlights as a shorthand to derive the right color.
---i
---For example:
---```lua
---  M.set("MatchParen", {fg = {from = 'ErrorMsg'}})
---```
---This will take the foreground color from ErrorMsg and set it to the foreground of MatchParen.
---
---This function will also convert legacy keys (i.e., `guisp`, `guibg`, `guibg`, and `default`)
---into keys that `api.nvim_set_hl` will accept.
---
---@param opts HighlightAttribute[]|string[]
---@diagnostic disable-next-line:unused-function, unused-local
local function convert_hl_to_val(opts)
    for attr, value in pairs(opts) do
        if type(value) == "table" and value.from then
            opts[attr] = M.get(value.from, value.attr or attr)
            if value.alter then
                opts[attr] = M.alter_color(opts[attr], value.alter)
            end
        elseif keys[attr] then
            opts[keys[attr]] = value
            opts[attr] = nil
        end
    end
end

---@source https://stackoverflow.com/q/5560248
---@see Stack: https://stackoverflow.com/a/37797380
---
---Darken a specified hex color
---@param color string
---@param percent number
---@return string
function M.alter_color(color, percent)
    local r, g, b = unpack(hex2rgb(color))
    if not r or not g or not b then
        return "NONE"
    end
    r, g, b = alter(r, percent), alter(g, percent), alter(b, percent)
    r, g, b = math.min(r, 255), math.min(g, 255), math.min(b, 255)
    return ("#%02x%02x%02x"):format(r, g, b)
end

---Parse `ColorFormat` into highlight definition map to be used by `api.nvim_set_hl`
---
---### Special `from` field
---Accepts a table of highlights, and converts them to `property = { from = 'group' }`
---by querying the property of the `from` group.
---
---For example:
---```lua
--- -- This will take the fg from ErrorMsg and set it to the fg of MatchParen
--- M.set({MatchParen = {foreground = {from = 'ErrorMsg'}}})
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
        "underdouble",
        "undercurl",
        "underdotted",
        "underdashed",
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
        hl = vim.tbl_extend("force", hl, convert_gui(hl.gui)) --[[@as ColorFormat]]
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
        hl.foreground = hl.foreground()
    end

    -- Background
    if hl.bg ~= nil and hl.background ~= nil then
        hl.background = nil
    end

    if type(hl.bg) == "function" then
        hl.bg = hl.bg()
    end

    if type(hl.background) == "function" then
        hl.background = hl.background()
    end

    def.foreground = hl.fg or inherit.foreground or "NONE"
    def.background = hl.bg or inherit.background or "NONE"
    def.special = F.if_nil(hl.special, inherit.special) or "NONE"
    def.italic = F.if_nil(hl.italic, inherit.italic) or false
    def.bold = F.if_nil(hl.bold, inherit.bold) or false
    def.underline = F.if_nil(hl.underline, inherit.underline) or false
    def.underdouble = F.if_nil(hl.underdouble, inherit.underdouble) or false
    def.undercurl = F.if_nil(hl.undercurl, inherit.undercurl) or false
    def.underdotted = F.if_nil(hl.underdotted, inherit.underdotted) or false
    def.underdashed = F.if_nil(hl.underdashed, inherit.underdashed) or false
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
    -- WinSeparator = { bg = 'NONE', fg = { from = 'NonText', attr = 'fg', alter = -3 } }
    for name, value in pairs(hl) do
        if type(value) == "table" and value.from then
            def[name] = M.get(value.from, value.attr or name)
            if value.alter then
                def[name] = M.alter_color(def[name], value.alter)
            end
        end
    end

    return def
end

---Create a highlight group
---See `ColorFormat` for more information on the highlight keys.
---For example, to set bold on a highlight group, there are two ways.
---```lua
---local hl = require("common.color")
---
--- -- Method 1
---hl.set("TSFunction", {bold = true})
---
--- -- Method 2
---hl.set("TSFunction", {gui = "bold"})
---```
---
---@param name string
---@param opts ColorFormat
function M.set(name, opts)
    vim.validate {
        name = {name, "s", false},
        opts = {opts, "t", false}
    }

    -- local ok, msg = pcall(api.set, 0, name, M.parse(opts))
    --
    -- if not ok then
    --     log.err(("Failed to set %s: %s"):format(name, msg), {print = true})
    -- end

    D.wrap_err(("Failed to set %s"):format(name), api.set, 0, name, M.parse(opts))
end

---Get the value a highlight group whilst handling errors
---Fallbacks are returned as well as the gui value in the right format
---@param group Group
---@param attribute string
---@param fallback? Color
---@return string
function M.get(group, attribute, fallback)
    if not group then
        log.err("Need a group to get a highlight", {print = true})
        return "NONE"
    end

    local hl = get_hl(group, fallback)
    attribute = ({fg = "foreground", bg = "background"})[attribute] or attribute
    local color = hl[attribute] or fallback

    if not color then
        vim.schedule(
            function()
                log.warn(("%s %s does not exist"):format(group, attribute), {print = true})
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
    return M.get(group, "foreground", fallback)
end

---Get the background string of a highlight group
---@param group Group
---@param fallback Color?
---@return string
function M.get_bg(group, fallback)
    return M.get(group, "background", fallback)
end

---Clear a highlight group
---@param name string
function M.clear(name)
    vim.validate({name = {name, "s", false}})
    M.set(name, {})
end

---Apply a list of highlights
---@param hls { [string]: { [string]: boolean|string } }
function M.all(hls)
    for name, hl in pairs(hls) do
        M.set(name, hl)
    end
end

---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param hls table<ColorFormat, string|boolean|number> list of highlights
function M.plugin(name, hls)
    name = name:gsub("^%l", string.upper)
    M.all(hls)
    utils.augroup(
        ("%sHighlightOverrides"):format(name),
        {
            event = "ColorScheme",
            command = function()
                vim.defer_fn(
                    function()
                        M.all(hls)
                    end,
                    1
                )
            end
        }
    )
end

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
    M.set(group, opts)
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
    M.set(group, opts)
end

---Group to modify gui
---@param group Group
---@param gui string
function M.gui(group, gui)
    cmd.hi(("%s gui=%s"):format(group, gui))
end

---Define bg and fg color
---@param group Group
---@param fg Color
---@param bg Color
---@param fmt ColorFormat
function M.fg_bg(group, fg, bg, fmt)
    -- cmd(("hi %s guifg=%s guibg=%s"):format(group, fg, bg))

    local opts = {}
    if fmt then
        vim.tbl_extend("keep", opts, fmt)
    end
    opts.fg = fg
    opts.bg = bg
    M.set(group, opts)
end

---Highlight link one group to another
---@param from string group that is going to be linked
---@param to string group that is linked to
function M.link(from, to)
    -- bang = bang ~= false and "!" or " default"
    -- cmd(("hi%s link %s %s"):format(bang, from, to))
    M.set(from, {link = to})
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
                        local hex = rgb2hex(hl[key])
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
                M.set(hlgroup, {link = opts})
                return
            end

            M.set(hlgroup, opts)
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
