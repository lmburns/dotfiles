local utils = require("common.utils")
local map = utils.map

g.NERDCreateDefaultMappings = 0
g.NERDSpaceDelims = 1
g.NERDTrimTrailingWhitespace = 1
g.NERDToggleCheckAllLines = 1
g.NERDCompactSexyComs = 1
g.NERDCommentEmptyLines = 1
g.NERDDefaultAlign = "left"
g.NERDCustomDelimiters = {
  just = { left = "#" },
  lua = { left = "--", leftAlt = "", rightAlt = "" },
}
g.NERDAltDelims_c = 1
g.NERDAltDelims_cpp = 1

map("", "<C-_>", ":call nerdcommenter#Comment(0, 'toggle')<CR>j")

-- Copy & comment
map("n", "<Leader>yc", "yyP<C-_>")
map("v", "<Leader>yc", "yPgp<C-_>")
map({ "n", "v" }, "gc", ":call nerdcommenter#Comment(0, 'toggle')<CR>")
map("n", "gcy", ":call nerdcommenter#Comment(0, 'yank')<CR>")
