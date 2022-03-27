local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd

autocmd(
    "indentline", [[Filetype json,markdown let g:indentLine_setConceal = 0]],
    true
)

map("n", "<Leader>il", ":IndentLinesToggle<CR>")

-- g.indentLine_showFirstIndentLevel = 1
-- g.indentLine_fileType = ['javascript', 'c']
-- g.indentLine_bufNameExclude = []
g.indentLine_fileTypeExclude = {
  "vimwiki",
  "coc-explorer",
  "help",
  "undotree",
  "diff",
  "fzf",
  "floaterm",
  "markdown",
}
g.indentLine_bufTypeExclude = { "help", "term:.*", "terminal" }
g.indentLine_indentLevel = 10

--  Conceal settings
g.indentLine_setConceal = 1
g.indentLine_concealcursor = "incv"
g.indentLine_conceallevel = 2

g.indentLine_char = "|"
g.indentLine_char_list = { "|", "¦", "┆", "┊" }

--  Leading Space
-- g.indentLine_leadingSpaceEnabled = 1
g.indentLine_leadingSpaceChar = "•"

--  Use Theme Colors
g.indentLine_setColors = 1
g.indentLine_color_tty_light = 7 --  (default: 4)
g.indentLine_color_dark = 1 --  (default: 2)
g.indentLine_color_term = 239
g.indentLine_color_gui = "#616161"
