---@meta
---@description Types for plugins, without the need to add the whole repo to Lua path

-- ━━━ notify.nvim ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class Notify.PrintHistory.Opts
---@field nl? boolean Concat multiple lines with a `\n`
---@field plain? boolean Print notification messages only
---@field time? boolean Show notification time
---@field title? boolean Show notification title
---@field icon? boolean Show notification icon
---@field level? boolean Show notification level
---@field hidden? boolean Include hidden messages

-- ━━━ paint.nvim ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class PaintHighlight
---@field filter PaintFilter
---@field pattern string
---@field hl string

---@alias PaintFilterFun fun(buf):boolean
---@class PaintFilter: table<string,any>|PaintFilterFun
---@field filetype? string

-- ━━━ dial.nvim ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class Augend
---@field find findmethod
---@field find_stateful? findmethod
---@field add addmethod

---@alias direction "'increment'"|"'decrement'"
---@alias mode "'normal'"|"'gnormal'"|"'visual'"|"'gvisual'"
---@alias textrange {from: integer, to: integer}
---@alias addresult {text?: string, cursor?: integer}

---@alias findfn fun(line: string, cursor?: integer):textrange?
---@alias addfn fun(text: string, addend: integer, cursor?: integer):addresult?

---@alias findmethod fun(self: Augend, line: string, cursor?: integer):textrange?
---@alias addmethod fun(self: Augend, text: string, addend: integer, cursor?: integer):addresult?
