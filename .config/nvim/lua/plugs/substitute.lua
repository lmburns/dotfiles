local M = {}
local K = require("common.keymap")

function M.setup()
  require("substitute").setup()
end

local function init()
  M.setup()

  K.n("s", ":lua require('substitute').operator()<CR>")
  K.n("ss", ":lua require('substitute').line()<CR>")
  K.n("se", ":lua require('substitute').eol()<CR>")
  K.x("s", ":lua require('substitute').visual()<CR>")

  K.n("sx", ":lua require('substitute.exchange').operator()<CR>")
  K.n("sxx", ":lua require('substitute.exchange').line()<CR>")
  K.x("X", ":lua require('substitute.exchange').visual()<CR>")
  K.n("sxc", ":lua require('substitute.exchange').cancel()<CR>")
end

init()

return M
