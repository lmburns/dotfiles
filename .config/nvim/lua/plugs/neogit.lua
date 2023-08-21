---@module 'plugs.neogit'
local M = {}

local F = Rc.F
local ng = F.npcall(require, "neogit")
if not ng then
    return
end

local wk = require("which-key")
local fn = vim.fn

function M.setup()
    ng.setup({
        disable_hint = false,
        disable_context_highlighting = false,
        disable_signs = false,
        disable_commit_confirmation = true,
        disable_builtin_notifications = false,
        disable_insert_on_commit = true,
        use_per_project_settings = true,
        remember_settings = true,
        use_magit_keybindings = false,
        auto_refresh = true,
        sort_branches = "-committerdate",
        -- Change the default way of opening neogit
        kind = "tab",
        -- The time after which an output console is shown for slow running commands
        console_timeout = 2000,
        -- Automatically show console if a command takes more than console_timeout milliseconds
        auto_show_console = true,
        status = {recent_commit_count = 10},
        commit_popup = {kind = "split"},
        preview_buffer = {kind = "split"},
        popup = {kind = "split"},
        -- customize displayed signs
        signs = {
            section = {"", ""},
            item = {"", ""},
            hunk = {"樂", ""},
        },
        integrations = {diffview = true},
        -- Setting any section to `false` will make the section not render at all
        section = {
            untracked = {folded = false},
            unstaged = {folded = false},
            staged = {folded = false},
            stashes = {folded = false},
            unpulled = {folded = true},
            unmerged = {folded = false},
            recent = {folded = false},
            rebase = {folded = true},
        },
        ignored_settings = {},
        -- override/add mappings
        mappings = {
            status = {
                ["q"] = "Close",
                ["I"] = "InitRepo",
                ["1"] = "Depth1",
                ["2"] = "Depth2",
                ["3"] = "Depth3",
                ["4"] = "Depth4",
                ["<tab>"] = "Toggle",
                ["x"] = "Discard",
                ["s"] = "Stage",
                ["S"] = "StageUnstaged",
                ["<c-s>"] = "StageAll",
                ["u"] = "Unstage",
                ["U"] = "UnstageStaged",
                ["d"] = "DiffAtFile",
                ["$"] = "CommandHistory",
                ["#"] = "Console",
                ["<c-r>"] = "RefreshBuffer",
                ["<enter>"] = "GoToFile",
                ["<c-v>"] = "VSplitOpen",
                ["<c-x>"] = "SplitOpen",
                ["<c-t>"] = "TabOpen",
                ["?"] = "HelpPopup",
                ["D"] = "DiffPopup",
                ["p"] = "PullPopup",
                ["r"] = "RebasePopup",
                ["m"] = "MergePopup",
                ["P"] = "PushPopup",
                ["c"] = "CommitPopup",
                ["L"] = "LogPopup",
                ["_"] = "RevertPopup",
                ["Z"] = "StashPopup",
                ["A"] = "CherryPickPopup",
                ["b"] = "BranchPopup",
                ["f"] = "FetchPopup",
                ["X"] = "ResetPopup",
                ["M"] = "RemotePopup",
                ["{"] = "GoToPreviousHunkHeader",
                ["}"] = "GoToNextHunkHeader",
            },
            finder = {
                ["<cr>"] = "Select",
                ["<c-c>"] = "Close",
                ["<esc>"] = "Close",
                ["<c-n>"] = "Next",
                ["<c-p>"] = "Previous",
                ["<down>"] = "Next",
                ["<up>"] = "Previous",
                ["<tab>"] = "MultiselectToggleNext",
                ["<s-tab>"] = "MultiselectTogglePrevious",
                ["<c-j>"] = "NOP",
            },
        },
    })
end

---
---@param dir string directory to open
---@param panel? string panel to open
function M.open(dir, panel)
    ng.open({panel, cwd = fn.expand(dir)})
end

local function init()
    M.setup()
    -- ng.get_repo()

    wk.register({
        ["<Leader>g,"] = {F.ithunk(M.open, "%:p:h"), "Neogit: open"},
        ["<Leader>gp"] = {F.ithunk(M.open, "%:p:h", "pull"), "Neogit: open pull"},
        ["<Leader>gP"] = {F.ithunk(M.open, "%:p:h", "push"), "Neogit: open push"},
        ["<Leader>gc"] = {F.ithunk(M.open, "%:p:h", "commit"), "Neogit: open commit"},
    })
end

init()

return M
