local M = {}

require("common.utils")

local function cabbrev(input, replace)
  local cmd = [[cnoreabbrev <expr> %s v:lua.require'abbr'.command("%s", "%s")]]

  vim.cmd(cmd:format(input, input, replace))
end

function M.command(cmd, match)
  if fn.getcmdtype() == ':' and fn.getcmdline():match('^' .. cmd) then
    return match
  else
    return cmd
  end
end

cabbrev("W!", "w!")
cabbrev("Q!", "q!")
cabbrev("Qall!", "qll!")
cabbrev("Qall", "qll")
cabbrev("Wq", "wq")
cabbrev("Wa", "wa")
cabbrev("wQ", "wq")
cabbrev("WQ", "wq")
cabbrev("W", "w")

cabbrev("tel", "Telescope")
cabbrev('Review', 'DiffviewOpen')

cabbrev("PI", "PackerInstall")
cabbrev("PU", "PackerUpdate")
cabbrev("PS", "PackerSync")
cabbrev("PC", "PackerCompile")

g.no_man_maps = 1
cabbrev("man", "Man")
cabbrev("vg", "vimgrep")

return M
