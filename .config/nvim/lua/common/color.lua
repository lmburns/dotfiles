local M = {}

require("common.utils")

-- Define bg color
-- @param group Group
-- @param color Color
function M.bg(group, col)
  cmd(("hi %s guibg=%s"):format(group, col))
end

-- Define fg color
-- @param group Group
-- @param color Color
function M.fg(group, col, gui)
  local g = gui == nil and "" or (" gui=%s"):format(gui)
  cmd(("hi %s guifg=%s %s"):format(group, col, g))
end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
function M.fg_bg(group, fgcol, bgcol)
  cmd(("hi %s guifg=%s guibg=%s"):format(group, fgcol, bgcol))
end

--- Highlight link one group to another
---@param from string group that is going to be linked
---@param to string group that is linked to
---@param bang boolean whether or not to force highilght
function M.link(from, to, bang)
  bang = bang ~= false and "!" or ""
  cmd(("hi%s link %s %s"):format(bang, from, to))
end

--- Define complete highlight group
-- @param  group Group
-- @param  options  Fg/Bg/Gui colors
function M.set_hl(group, options)
  local bg = options.bg == nil and "" or "guibg=" .. options.bg
  local fg = options.fg == nil and "" or "guifg=" .. options.fg
  local gui = options.gui == nil and "" or "gui=" .. options.gui

  cmd(("hi %s %s %s %s"):format(group, bg, fg, gui))
end

return M
