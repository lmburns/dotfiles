---@module 'plugs.neogit'
local M = {}

local F = Rc.F
vim.cmd.packadd("neogit")
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
        disable_commit_confirmation = false,
        disable_builtin_notifications = false,
        disable_insert_on_commit = true,
        telescope_sorter = function()
            return require("telescope").extensions.fzf.native_fzf_sorter()
        end,
        remember_settings = true,
        use_per_project_settings = true,
        -- Table of settings to never persist. Uses format "Filetype--cli-value"
        ignored_settings = {
            "NeogitPushPopup--force-with-lease",
            "NeogitPushPopup--force",
            "NeogitPullPopup--rebase",
            "NeogitCommitPopup--allow-empty",
            "NeogitRevertPopup--no-edit",
        },
        auto_refresh = true,
        sort_branches = "-committerdate",
        kind = "tab",             -- Change the default way of opening neogit
        console_timeout = 2000,   -- time output console is shown for slow commands
        auto_show_console = true, -- auto show console if longer than console_timeout
        status = {recent_commit_count = 10},
        commit_editor = {kind = "split"},
        commit_select_view = {kind = "tab"},
        commit_view = {kind = "vsplit"},
        log_view = {kind = "tab"},
        rebase_editor = {kind = "split"},
        reflog_view = {kind = "tab"},
        merge_editor = {kind = "split"},
        preview_buffer = {kind = "split"},
        popup = {kind = "split"},
        -- customize displayed signs
        signs = {
            section = {"", ""},
            item = {"", ""},
            hunk = {"樂", ""},
        },
        integrations = {diffview = true, telescope = true},
        sections = {
            -- Reverting/Cherry Picking
            sequencer = {folded = false, hidden = false},
            untracked = {folded = false, hidden = false},
            unstaged = {folded = false, hidden = false},
            staged = {folded = false, hidden = false},
            stashes = {folded = true, hidden = false},
            unpulled_upstream = {folded = true, hidden = false},
            unmerged_upstream = {folded = false, hidden = false},
            unpulled_pushRemote = {folded = true, hidden = false},
            unmerged_pushRemote = {folded = false, hidden = false},
            recent = {folded = true, hidden = false},
            rebase = {folded = true, hidden = false},
        },
        use_magit_keybindings = false,
        mappings = {
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
                ["v"] = false,
                ["Z"] = "StashPopup",
                ["A"] = "CherryPickPopup",
                ["b"] = "BranchPopup",
                ["f"] = "FetchPopup",
                ["X"] = "ResetPopup",
                ["M"] = "RemotePopup",
                ["{"] = "GoToPreviousHunkHeader",
                ["}"] = "GoToNextHunkHeader",
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
        ["<Leader>gj"] = {F.ithunk(M.open, "%:p:h", "log"), "Neogit: open log"},
    })
end

init()

return M
