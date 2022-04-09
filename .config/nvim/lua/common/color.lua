local M = {}

require("common.utils")

-- Define bg color
-- @param group Group
-- @param color Color
function M.bg(group, col)
  cmd("hi " .. group .. " guibg=" .. col)
end

-- Define fg color
-- @param group Group
-- @param color Color
function M.fg(group, col, gui)
  local g = gui == nil and "" or (" gui=%s"):format(gui)
  cmd("hi " .. group .. " guifg=" .. col .. g)
end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
function M.fg_bg(group, fgcol, bgcol)
  cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

--- Define complete highlight group
-- @param  group Group
-- @param  options  Fg/Bg/Gui colors
function M.set_hl(group, options)
  local bg = options.bg == nil and "" or "guibg=" .. options.bg
  local fg = options.fg == nil and "" or "guifg=" .. options.fg
  local gui = options.gui == nil and "" or "gui=" .. options.gui

  vim.cmd(string.format("hi %s %s %s %s", group, bg, fg, gui))
end

return M
