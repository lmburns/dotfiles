local M = {}

local wk = require("which-key")
local map = require("common.utils").map

local ng = require("neogit")

function M.setup()
    ng.setup(
        {
            disable_commit_confirmation = true,
            integrations = {diffview = true},
            sections = {stashes = {folded = false}, recent = {folded = false}},
            -- override/add mappings
            mappings = {
                -- modify status buffer mappings
                status = {}
            }
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

    wk.register(
        {
            ["<Leader>g,"] = {
                function()
                    ng.open({cwd = fn.expand("%:h")})
                end,
                "Open Neogit"
            },
            ["<Leader>gp"] = {
                function()
                    ng.open({"pull", cwd = fn.expand("%:h")})
                end,
                "Open Neogit pull"
            }
        }
    )
end

init()

return M
