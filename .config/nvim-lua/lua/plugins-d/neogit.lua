local M = {}

function M.config()
  require("neogit").setup(
      {
        disable_commit_confirmation = true,
        integrations = { diffview = true },
        sections = { stashes = { folded = false }, recent = { folded = false } },
      }
  )
end

return M
