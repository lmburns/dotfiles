local M = {}

local D = require("dev")
local ng = D.npcall(require, "neogit")
if not ng then
    return
end

local wk = require("which-key")
local C = require("common.color")

local fn = vim.fn

function M.setup()
    ng.setup(
        {
            disable_signs = false,
            disable_hint = false,
            disable_context_highlighting = false,
            disable_commit_confirmation = true,
            auto_refresh = true,
            disable_builtin_notifications = false,
            use_magit_keybindings = false,
            commit_popup = {
                kind = "split"
            },
            -- Change the default way of opening neogit
            kind = "tab",
            -- customize displayed signs
            signs = {
                -- { CLOSED, OPENED }
                section = {"", ""},
                item = {"", ""},
                hunk = {"", ""}
            },
            integrations = {
                diffview = true
            },
            -- Setting any section to `false` will make the section not render at all
            sections = {
                untracked = {
                    folded = false
                },
                unstaged = {
                    folded = false
                },
                staged = {
                    folded = false
                },
                stashes = {
                    folded = false
                },
                unpulled = {
                    folded = true
                },
                unmerged = {
                    folded = false
                },
                recent = {
                    folded = false
                }
            },
            -- override/add mappings
            mappings = {
                -- modify status buffer mappings
                status = {}
            }
        }
    )
end

local function init()
    C.plugin(
        "Neogit",
        {
            NeogitNotificationInfo = {fg = "#4C96A8"},
            NeogitNotificationWarning = {fg = "#FF9500"},
            NeogitNotificationError = {fg = "#c44323"},
            NeogitDiffAddHighlight = {fg = "#819C3B"},
            NeogitDiffDeleteHighlight = {fg = "#DC3958"},
            NeogitDiffContextHighlight = {fg = "#b2b2b2"},
            NeogitHunkHeader = {fg = "#A06469"},
            NeogitHunkHeaderHighlight = {fg = "#FF5813"}
        }
    )

    M.setup()

    wk.register(
        {
            ["<Leader>g,"] = {
                function()
                    ng.open({cwd = fn.expand("%:p:h")})
                end,
                "Open Neogit"
            },
            ["<Leader>gp"] = {
                function()
                    ng.open({"pull", cwd = fn.expand("%:p:h")})
                end,
                "Open Neogit pull"
            },
            ["<Leader>gP"] = {
                function()
                    ng.open({"push", cwd = fn.expand("%:p:h")})
                end,
                "Open Neogit push"
            },
            ["<Leader>gc"] = {
                function()
                    ng.open({"commit", cwd = fn.expand("%:p:h")})
                end,
                "Open Neogit commit"
            }
        }
    )
end

init()

return M
