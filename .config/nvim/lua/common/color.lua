local M = {}

require("common.utils")

---Define bg color
---@param group Group
---@param color Color
function M.bg(group, col)
    cmd(("hi %s guibg=%s"):format(group, col))
end

---Define fg color
---@param group Group
---@param color Color
function M.fg(group, col, gui)
    local g = gui == nil and "" or (" gui=%s"):format(gui)
    cmd(("hi %s guifg=%s %s"):format(group, col, g))
end

---Define bg and fg color
---@param group Group
---@param fgcol Fg Color
---@param bgcol Bg Color
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

-- ---Define complete highlight group
-- ---@param  group string: Group
-- ---@param  options table: Fg/Bg/Gui colors
-- function M.set_hl(group, options)
--     local bg = options.bg == nil and "" or "guibg=" .. options.bg
--     local fg = options.fg == nil and "" or "guifg=" .. options.fg
--     local gui = options.gui == nil and "" or "gui=" .. options.gui
--
--     cmd(("hi %s %s %s %s"):format(group, bg, fg, gui))
-- end

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

return M
