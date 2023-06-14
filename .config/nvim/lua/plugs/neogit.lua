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
            -- { CLOSED, OPENED }
            section = {"", ""},
            item = {"", ""},
            hunk = {"樂", ""},
        },
        integrations = {diffview = true},
        -- Setting any section to `false` will make the section not render at all
        sections = {
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
                ["Z"] = "StashPopup",
                ["b"] = "BranchPopup",
                ["f"] = "FetchPopup",
            },
        },
    })
end

local function init()
    M.setup()

    wk.register({
        ["<Leader>g,"] = {
            function()
                ng.open({cwd = fn.expand("%:p:h")})
            end,
            "Open Neogit",
        },
        ["<Leader>gp"] = {
            function()
                ng.open({"pull", cwd = fn.expand("%:p:h")})
            end,
            "Open Neogit pull",
        },
        ["<Leader>gP"] = {
            function()
                ng.open({"push", cwd = fn.expand("%:p:h")})
            end,
            "Open Neogit push",
        },
        ["<Leader>gc"] = {
            function()
                ng.open({"commit", cwd = fn.expand("%:p:h")})
            end,
            "Open Neogit commit",
        },
    })
end

init()

return M
