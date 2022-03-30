local M = {}

require("common.utils")

local function init()
  cmd("packadd kimbox")
  g.kimbox_allow_bold = 1
  cmd [[colorscheme kimbox]]

-- g.kimbox_background = 'deep'
-- g.kimbox_background = 'medium' " brown
-- g.kimbox_background = 'darker' " dark dark purple
-- g.kimbox_background = 'ocean' " dark purple
end

init()

return M
