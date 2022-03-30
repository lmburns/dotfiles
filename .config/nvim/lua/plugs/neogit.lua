local M = {}

require("common.utils")

function M.setup()
  require("neogit").setup(
      {
        disable_commit_confirmation = true,
        integrations = { diffview = true },
        sections = { stashes = { folded = false }, recent = { folded = false } },
      }
  )
end

local function init()
  cmd [[
    hi NeogitNotificationInfo guifg=#4C96A8
    hi NeogitNotificationWarning guifg=#FF9500
    hi NeogitNotificationError guifg=#c44323

    hi def NeogitDiffAddHighlight guifg=#819C3B
    hi def NeogitDiffDeleteHighlight guifg=#DC3958
    hi def NeogitDiffContextHighlight guifg=#b2b2b2
    hi def NeogitHunkHeader guifg=#A06469
    hi def NeogitHunkHeaderHighlight guifg=#FF5813
  ]]
  M.setup()
end

init()

return M
