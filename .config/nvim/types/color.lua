---@meta
---@description Types for my custom API for Neovim color/syntax functions

---@alias Group string

---@class HighlightAttribute
---@field from string
---@field attr 'foreground'|'fg'|'background'|'bg'|'special'|'sp'
---@field alter integer

---@alias ColorType string|HighlightAttribute|integer|"NONE"|fun(): string|HighlightAttribute

---@class ColorFormat
---@field default boolean Don't override existing definition
---@field fg ColorType
---@field bg ColorType
---@field sp ColorType
---@field foreground ColorType
---@field background ColorType
---@field special ColorType
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
---@field inherit string (extra)
---@field build boolean  (extra) Keep color attributes to build upon. Equiv: `Val = {inherit='Val'}`
---@field gui string     (extra) Accept old gui strings
---@field cond string    (extra) Conditional colorscheme name
---@field guifg string deprecated
---@field guibg string deprecated
---@field guisp string deprecated

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
