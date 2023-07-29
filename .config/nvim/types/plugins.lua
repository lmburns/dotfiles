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

--  ━━━ neoclip ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class Neoclip.Entry
---@field entry Neoclip.Entry.Inner
---@field register_names string[]
---@field typ string

---@class Neoclip.Entry.Inner
---@field contents string[]
---@field filetype string
---@field regtype string

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

-- ━━━ fzf.vim ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class FzfRunOpts
---@field source string|(string|integer)[] Vim list as input to fzf
---@field sink string|fun() Vim command to handle the selected item
---@field sinklist fun() Similar to `sink`, but takes list of output lines at once
---@field options string|string[] Options to fzf
---@field dir string Working directory
---@field up number|string Window position and size (e.g.`20`, `50%`)
---@field down number|string Window position and size (e.g.`20`, `50%`)
---@field left number|string Window position and size (e.g.`20`, `50%`)
---@field right number|string Window position and size (e.g.`20`, `50%`)
---@field tmux string fzf-tmux options (e.g. `-p90%,60%` )
---@field name string
---@field window string|Dict<string> (Layout) Command to open fzf window (e.g.  `vertical aboveleft 30new`)|Popup window settings (e.g. `{'width': 0.9, 'height': 0.6}`)

---@alias FzfWrapRet table
