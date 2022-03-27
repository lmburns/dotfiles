local utils = require("common.utils")
local map = utils.map

map("n", "<Leader>ut", ":UndotreeToggle<CR>")

g.undotree_RelativeTimestamp = 1
g.undotree_ShortIndicators = 1
g.undotree_HelpLine = 0
g.undotree_WindowLayout = 2
