local M = {}

require("common.utils")

-- Define bg color
-- @param group Group
-- @param color Color
function M.bg(group, col) cmd("hi " .. group .. " guibg=" .. col) end

-- Define fg color
-- @param group Group
-- @param color Color
function M.fg(group, col) cmd("hi " .. group .. " guifg=" .. col) end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
function M.fg_bg(group, fgcol, bgcol)
  cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

return M
