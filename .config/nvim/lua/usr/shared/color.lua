---@module 'usr.shared.color'
---@description Operations on colors and highlight groups
---@class Usr.Shared.Color
local M = {}

local lazy = require("usr.lazy")
local F = lazy.require("usr.shared.F") ---@module 'usr.shared.F'
local C = lazy.require("usr.shared.collection") ---@module 'usr.shared.collection'
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'

local api = vim.api

local attrs = {}
attrs.std = {
    blend = true,
    bold = true,
    standout = true,
    underline = true,
    undercurl = true,
    underdouble = true,
    underdotted = true,
    underdashed = true,
    strikethrough = true,
    italic = true,
    reverse = true,
}
attrs.ctermt = {cterm = true, ctermfg = true, ctermbg = true}
attrs.legacy = {guisp = "sp", guibg = "bg", guifg = "fg"}
attrs.translate = {foreground = "fg", background = "bg", special = "sp"}
attrs.valid = {
    fg = true, -- foreground = true,
    bg = true, -- background = true,
    sp = true, -- special = true,
    default = true,
    nocombine = true,
    link = true,
    unpack(attrs.std),
    unpack(attrs.ctermt),
    -- unpack(attrs.legacy),
}

-- inherit = true,
-- build = true,
-- from = true,
-- cond = true,
-- gui = true,

---Convert a hexidecimal color (#RRGGBB) to RGB
---@param color Color.S_t
---@return Color.RGB_t
local function hex2rgb(color)
    local pat = "^(%x%x)(%x%x)(%x%x)$"
    local hex = color:gsub("#", ""):gsub("0x", ""):lower()
    assert(hex:match(pat) ~= nil, ("hex2rgb: invalid string: %s"):format(hex))
    local r, g, b = hex:match(pat)
    return {
        r = tonumber(r, 16),
        g = tonumber(g, 16),
        b = tonumber(b, 16),
    }
end

---Convert RGB decimal (RGB) to hexadecimal (#RRGGBB)
---@param dec Color.N_t color as an integer
---@return Color.S_t color color as a string (#RRGGBB)
local function rgb2hex(dec)
    return ("#%s"):format(bit.tohex(dec, 6))
end

---Translate `foreground`, `background`, and `special` attributes
---@param attr Highlight.Kind
---@return string|integer
local function translate_attr(attr)
    return attrs.translate[attr] or attr
end

---Translate between
---   - `foreground` and `fg`
---   - `background` and `bg`
---   - `special` and `sp`
---@param hl Highlight_t
---@return Highlight_t
local function translate_hl(hl)
    for long, short in pairs(attrs.translate) do
        if hl[long] then
            hl[short] = hl[long]
            hl[long] = nil
        end
        if F.is.fn(hl[short]) then
            hl[short] = hl[short]()
        end
    end
    return hl
end

---Convert a `gui=...` into valid arguments for `api.nvim_set_hl`
---@param guistr string
---@return Highlight.Gui.Attr
local function translate_gui(guistr)
    local gui = {}
    guistr = guistr:gsub(".*", string.lower)
    local parts = guistr:split(",")

    for _, part in ipairs(parts) do
        if part:match("none") then
            gui.italic = false
            gui.bold = false
            gui.underline = false
            gui.undercurl = false
            gui.standout = false
            gui.undercurl = false
            gui.underdouble = false
            gui.underdotted = false
            gui.underdashed = false
            gui.strikethrough = false
            gui.reverse = false
        else
            gui[part] = true
        end
    end
    return gui
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Wrapper around `nvim_get_hl`.
---Turn the `fg`, `bg`, and `sp` fields into hex-strings
---@param opts? {name?: Highlight.Group, link?: boolean}
---@param ns? namespace
---@return Highlight_t
local function api_get(opts, ns)
    ns, opts = ns or 0, opts or {}
    opts.link = F.unwrap_or(opts.link, false)
    local hl = api.nvim_get_hl(ns, opts)
    hl.fg = hl.fg and rgb2hex(hl.fg)
    hl.bg = hl.bg and rgb2hex(hl.bg)
    hl.sp = hl.sp and rgb2hex(hl.sp)
    return hl
end
---Wrapper around `nvim_set_hl`.
---@param name Highlight.Group
---@param color Highlight_t
---@param ns? namespace
---@return nil
local function api_set(name, color, ns)
    return api.nvim_set_hl(ns or 0, name, color)
end
---@private
---Return a list of all highlight definitions
---@return Highlight_t[]
local api_defs = (function()
    local defs
    return function()
        if defs == nil then
            defs = api_get()
        end
        return defs
    end
end)()

M.api = {
    get = api_get,
    set = api_set,
    defs = api_defs,
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Alter a color's brightness
---@param color Color.S_t|fun():Color.S_t color as a string
---@param percent float a negative number darkens and a positive one brightens
---@return Color.S_t
function M.alter_color(color, percent)
    assert(color and percent, "cannot alter a color without specifying a color and percentage")
    color = F.is.fn(color) and color() or color
    local c = hex2rgb(color)
    if not c.r or not c.g or not c.b then
        return "NONE"
    end
    local function blend(comp)
        comp = math.floor(comp * (1 + percent))
        return math.min(math.max(comp, 0), 255)
    end
    return ("#%02x%02x%02x"):format(blend(c.r), blend(c.g), blend(c.b))
end

---@param hl Highlight.Kind|Highlight.Attr
---@param attr Highlight_t
---@return Color.S_t|Highlight_t
local function resolve_from_attr(hl, attr)
    if not F.is.tbl(hl) or not hl.from then
        return hl
    end
    local color = M.get(hl.from, hl.attr or attr)
    if hl.alter then
        color = M.alter_color(color, hl.alter)
    end
    return color
end

---Get the value a highlight group whilst handling errors
---Fallbacks are returned as well as the gui value in the right format
---@param group Highlight.Group
---@param attribute? Highlight.Kind
---@param fallback? Color.S_t
---@return Color.S_t|Highlight_t
function M.get(group, attribute, fallback)
    if not group then
        log.err("Need a group to get a highlight", {debug = true})
        return "NONE"
    end
    local ok, hl = pcall(M.api.get, {name = group})
    if not ok then
        log.err(("Failed to get color: %s"):format(group), {debug = true})
        return "NONE"
    end

    attribute = translate_attr(attribute)
    if not attribute then
        return hl
    end
    local color = hl[attribute] or fallback
    if not color then
        local errmsg = F.ithunk(
            log.warn,
            ("%s %s does not exist"):format(group, attribute),
            {dprint = true}
        )

        if vim.v.vim_did_enter == 0 then
            Rc.api.autocmd({
                event = "VimEnter",
                -- pattern = "CocNvimInit",
                once = true,
                command = errmsg,
            })
        else
            vim.schedule(errmsg)
        end

        return "NONE"
    end
    return color
end

---## Create a highlight group
---For example, to set bold on a highlight group, there are two ways.
---```lua
---  hl.set("TSFunction", {bold = true})  -- Method 1
---  hl.set("TSFunction", {gui = "bold"}) -- Method 2
---```
---### Special `from` field
---Accepts a table of highlights, and converts them to `property = { from = 'group' }`
---by querying the property of the `from` group.
---```lua
---  -- Gets fg from Normal and set it to fg of Visual
---  M.set({Visual = {fg = {from = 'Normal'}}})
---```
---### Legacy
---Also accepts legacy keys (i.e., `guisp`, `guibg`, `guifg`).
---@see Highlight_t
---***
---@param name Highlight.Group
---@param hl Highlight_t
---@param ns? namespace
function M.set(name, hl, ns)
    ns = ns or 0
    vim.validate({name = {name, "s", false}, hl = {hl, "t", false}, ns = {ns, "n", true}})

    if hl.build then
        hl.inherit = name
    end

    F.xpcall(
        ("Failed to set %s with:\n%s"):format(name, I(hl)),
        M.api.set,
        name,
        M.parse(hl.clear and {} or hl),
        ns
    )
end

---Parse `Highlight_t` into highlight definition map to be used by `api.nvim_set_hl`
---@param hl Highlight_t
---@return Highlight_t|"NONE"
function M.parse(hl)
    local def = {}
    if F.is.fn(hl.cond) and not hl.cond() then
        return "NONE"
    end

    for _, attr in pairs({"default", "nocombine"}) do
        if hl[attr] then
            def[attr] = hl[attr]
        end
    end

    if
        hl.link
        and F.is.str(hl.link)
        and pcall(M.api.get, {name = hl.link})
    then
        def.link = hl.link
        return def
    end

    if hl.gui then
        hl = vim.tbl_extend("force", hl, translate_gui(hl.gui)) --[[@as Highlight_t]]
        hl.gui = nil
    end

    ---@type boolean|table
    local inherit = {}

    if hl.inherit then
        local ok, value = pcall(M.api.get, {name = hl.inherit})
        inherit = (ok and value) and value or inherit
    end

    hl = translate_hl(hl)

    def.fg = F.if_nil(hl.fg, inherit.fg, "NONE")
    def.bg = F.if_nil(hl.bg, inherit.bg, "NONE")
    def.sp = F.if_nil(hl.sp, inherit.sp, "NONE")
    def.bold = F.if_nil(hl.bold, inherit.bold, false)
    def.standout = F.if_nil(hl.standout, inherit.standout, false)
    def.underline = F.if_nil(hl.underline, inherit.underline, false)
    def.undercurl = F.if_nil(hl.undercurl, inherit.undercurl, false)
    def.underdouble = F.if_nil(hl.underdouble, inherit.underdouble, false)
    def.underdotted = F.if_nil(hl.underdotted, inherit.underdotted, false)
    def.underdashed = F.if_nil(hl.underdashed, inherit.underdashed, false)
    def.strikethrough = F.if_nil(hl.strikethrough, inherit.strikethrough, false)
    def.italic = F.if_nil(hl.italic, inherit.italic, false)
    def.reverse = F.if_nil(hl.reverse, inherit.reverse, false)

    -- `blend` field is not set by default
    -- set it only if the inherited group is set
    if inherit.blend then
        def.blend = inherit.blend
    end

    for attr, _ in pairs(attrs.std) do
        if hl[attr] then
            def[attr] = hl[attr]
        end
    end

    for attr, _ in pairs(attrs.ctermt) do
        if hl[attr] then
            def[attr] = hl[attr]
        end
    end

    -- Legacy values have the highest priority
    for old, attr in pairs(attrs.legacy) do
        if hl[old] then
            def[attr] = hl[old]
            hl[old] = nil
        end
    end

    -- Special `from` field
    -- WinSeparator = { bg = 'NONE', fg = { from = 'NonText', attr = 'fg', alter = -3 } }
    for attr, value in pairs(hl) do
        local new_data = resolve_from_attr(value, attr)
        if attrs.valid[attr] then
            def[attr] = new_data
        end
    end

    return def
end

---Clear a highlight group
---@param name Highlight.Group
function M.clear(name)
    vim.validate({name = {name, "s", false}})
    M.set(name, {})
end

---Apply a list of highlights
---@param hls Highlight.Map
---@param ns? integer namespace
function M.all(hls, ns)
    C.foreach(hls, function(hl, name)
        M.set(name, hl, ns)
    end)
end

---Set window local highlights
---@param name string namespace name
---@param winid winid window ID
---@param hls Highlight_t[]
function M.set_winhl(name, winid, hls)
    local namespace = api.nvim_create_namespace(name) --[[@as integer]]
    M.all(hls, namespace)
    api.nvim_win_set_hl_ns(winid, namespace)
end

--- Takes the overrides for each theme and merges the lists, avoiding duplicates and ensuring
--- priority is given to specific themes rather than the fallback
---@param theme {[string]: Highlight.Map[]}
---@return Highlight_t[]
local function add_theme_overrides(theme)
    local res, seen = {}, {}
    local list = vim.list_extend(theme[vim.g.colors_name] or {}, theme["*"] or {})
    for _, hl in ipairs(list) do
        local n = next(hl)
        if not seen[n] then res[#res+1] = hl end
        seen[n] = true
    end
    return res
end

---Apply highlights for a plugin and refresh on colorscheme change
---@param name string plugin name
---@param opts Highlight.Map|{theme: Highlight.Map}
function M.plugin(name, opts)
    if opts.theme then
        opts = add_theme_overrides(opts.theme)
        if not next(opts) then return end
    end
    M.all(opts)
    name = name:gsub("^%l", string.upper)
    Rc.api.augroup(
        ("%sHighlightOverrides"):format(name),
        {
            event = "ColorScheme",
            command = function()
                vim.defer_fn(function() M.all(opts) end, 1)
            end,
        }
    )
end

---Highlight link one group to another
---@param from Highlight.Group group that is going to be linked
---@param to Highlight.Group group that is linked to
function M.link(from, to)
    M.set(from, {link = to})
end

---List all highlight groups, or ones matching `filter`
---@param filter string
---@param exact boolean whether filter should be exact
function M.colors(filter, exact)
    local defs = {}
    local hl_defs = M.api.defs()
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
                    if F.is.num(hl[key]) then
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
                        "strikethrough",
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
    return defs
end

local function init()
    Rc.api.command(
        "Color",
        function(tbl)
            require("usr.shared.color").colors(tbl.args)
        end,
        {nargs = "?", desc = "Search for a color"}
    )

    setmetatable(M, {
        ---Syntactic sugar to set a highlight group
        ---@param _ Usr.Shared.Color
        ---@param hlgroup Highlight.Group
        ---@param opts Highlight_t
        __newindex = function(_, hlgroup, opts)
            if F.is.str(opts) then
                M.set(hlgroup, {link = opts})
                return
            end
            M.set(hlgroup, opts)
        end,
        ---Syntactic sugar retrieve a highlight group
        ---@param self Usr.Shared.Color
        ---@param k Color.S_t
        ---@return Highlight_t
        __index = function(self, k)
            local color = rawget(self, k)
            if color ~= nil then
                return color
            end
            return M.get(k) --[[@as Highlight_t]]
        end,
        ---Search for a color.
        ---@param self Usr.Shared.Color
        ---@param k Highlight.Group
        ---@return table
        __call = function(self, k)
            return self.colors(k, false)
        end,
    })
end

init()

return M
