local M = {}

local utils = require("common.utils")
local map = utils.map

function M.toggle()
  fn["undotree#UndotreeToggle"]()
  require("plugs.undotree").clean_undo()
end

-- TODO: always clean filename with '%'
function M.clean_undo()
  local u_dir = vim.o.undodir
  local pre_len = u_dir:len(vim.o.undodir) + 2
  for file in vim.gsplit(fn.globpath(u_dir, "*"), "\n") do
    local fp_per = file:sub(pre_len, -1)
    local fp = fp_per:gsub("%%", "/")
    if fn.glob(fp) == "" then
      os.remove(fp)
    end
  end
end

local function init()
  g.undotree_SplitWidth = 45
  g.undotree_SetFocusWhenToggle = 1
  g.undotree_RelativeTimestamp = 1
  g.undotree_ShortIndicators = 1
  g.undotree_HelpLine = 0
  g.undotree_WindowLayout = 3

  cmd(
      [[
        function! Undotree_CustomMap()
            nmap <buffer> <C-u> <Plug>UndotreeUndo
            nunmap <buffer> u
        endfunc

        packadd undotree
    ]]
  )
end

init()

return M
