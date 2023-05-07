local M = {}

local D = require("dev")
local diffview = D.npcall(require, "diffview")
if not diffview then
    return
end

local act = require("diffview.actions")

local mpi = require("common.api")
local map = mpi.map

local cmd = vim.cmd
local api = vim.api

M.setup = function()
    ---@type DiffviewConfig
    diffview.setup(
        {
            diff_binaries = false,    -- Show diffs for binaries
            enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
            use_icons = true,         -- Requires nvim-web-devicons
            show_help_hints = true,
            icons = {
                -- Only applies when use_icons is true.
                folder_closed = "",
                folder_open = "",
            },
            signs = {fold_closed = "", fold_open = "", done = "✓"},
            view = {
                default = {
                    -- layout = "diff1_inline",
                    layout = "diff2_horizontal",
                    winbar_info = false,
                },
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                    winbar_info = true,
                },
                file_history = {
                    -- layout = "diff1_inline",
                    layout = "diff2_horizontal",
                    winbar_info = false,
                },
            },
            file_panel = {
                listing_style = "tree", -- One of 'list' or 'tree'
                tree_options = {
                    -- Only applies when listing_style is 'tree'
                    flatten_dirs = true,            -- Flatten dirs that only contain one single dir
                    folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
                },
                win_config = {
                    position = "left", -- One of 'left', 'right', 'top', 'bottom'
                    width = 35,        -- Only applies when position is 'left' or 'right'
                    height = 10,       -- Only applies when position is 'top' or 'bottom'
                },
            },
            file_history_panel = {
                log_options = {
                    ---@type ConfigLogOptions
                    git = {
                        single_file = {diff_merges = "combined", follow = true},
                        multi_file = {diff_merges = "first-parent"},
                    },
                },
                win_config = {
                    position = "bottom", -- One of 'left', 'right', 'top', 'bottom'
                    width = 35,          -- Only applies when position is 'left' or 'right'
                    height = 16,         -- Only applies when position is 'top' or 'bottom'
                },
            },
            commit_log_panel = {
                win_config = {win_opts = {}, -- See |diffview-config-win_config|
                },
            },
            default_args = {
                -- Default args prepended to the arg-list for the listed commands
                DiffviewOpen = {},
                DiffviewFileHistory = {},
                -- DiffviewFileHistory = { "%" }
            },
            hooks = {},                   -- See ':h diffview-config-hooks'
            keymaps = {
                disable_defaults = false, -- Disable the default key bindings
                -- The `view` bindings are active in the diff buffers,
                -- only when the current tabpage is a Diffview.
                view = {
                    ---@format disable
                    {"n", "co", act.conflict_choose("ours"), {desc = "Choose OURS of conflict"}},
                    {"n", "ct", act.conflict_choose("theirs"), {desc = "Choose THEIRS of conflict"}},
                    {"n", "cb", act.conflict_choose("base"), {desc = "Choose BASE of conflict"}},
                    {
                        "n",
                        "<leader>co",
                        act.conflict_choose("ours"),
                        {desc = "Choose OURS of conflict"},
                    },
                    {
                        "n",
                        "<leader>ct",
                        act.conflict_choose("theirs"),
                        {desc = "Choose THEIRS of conflict"},
                    },
                    {
                        "n",
                        "<leader>cb",
                        act.conflict_choose("base"),
                        {desc = "Choose BASE of conflict"},
                    },
                    {
                        "n",
                        "<leader>ca",
                        act.conflict_choose("all"),
                        {desc = "Choose all versions of conflict"},
                    },
                    {"n", "dx", act.conflict_choose("none"), {desc = "Delete conflict region"}},
                    {"n", "<tab>", act.select_next_entry, {desc = "Open diff for next file"}},
                    {"n", "<s-tab>", act.select_prev_entry, {desc = "Open diff for prev file"}},
                    {"n", "gf", act.goto_file_edit, {desc = "Open in prev tabpage"}},
                    {"n", "<C-w><C-f>", act.goto_file_split, {desc = "Open in split"}},
                    {"n", "<C-w>gf", act.goto_file_tab, {desc = "Open in tabpage"}},
                    {"n", "<leader>e", act.focus_files, {desc = "Focus file panel"}},
                    {"n", "g<C-x>", act.cycle_layout, {desc = "Cycle available layouts"}},
                    {"n", "[x", act.prev_conflict, {desc = "Jump prev conflict"}},
                    {"n", "]x", act.next_conflict, {desc = "Jump next conflict"}},
                    {"n", "<leader>b", act.toggle_files, {desc = "Toggle the file panel"}},
                    {"n", "?", "<Cmd>h diffview-maps-view<CR>", {desc = "Open help page"}},
                    {"n", "Q", act.close, {desc = "Close panel"}},
                    {"n", "qq", "<Cmd>DiffviewClose<CR>", {desc = "Close Diffview"}},
                    unpack(act.compat.fold_cmds),
                },
                -- Mappings in single window diff layouts
                diff1 = {{"n", "?", act.help({"view", "diff1"}), {desc = "Open help panel"}}},
                -- Mappings in 2-way diff layouts
                diff2 = {{"n", "?", act.help({"view", "diff2"}), {desc = "Open help panel"}}},
                -- Mappings in 3-way diff layouts
                diff3 = {
                    {{"n", "x"}, "2do", act.diffget("ours"), {desc = "Get diff hunk from OURS"}},
                    {{"n", "x"}, "3do", act.diffget("theirs"), {desc = "Get diff hunk from THEIRS"}},
                    {"n", "?", act.help({"view", "diff3"}), {desc = "Open help panel"}},
                },
                diff4 = {
                    -- Mappings in 4-way diff layouts
                    {{"n", "x"}, "1do", act.diffget("base"), {desc = "Get diff hunk from BASE"}},
                    {{"n", "x"}, "2do", act.diffget("ours"), {desc = "Get diff hunk from OURS"}},
                    {{"n", "x"}, "3do", act.diffget("theirs"), {desc = "Get diff hunk from THEIRS"}},
                    {"n", "?", act.help({"view", "diff4"}), {desc = "Open help panel"}},
                },
                file_panel = {
                    {"n", "j", act.next_entry, {desc = "Move cursor to next file entry"}},
                    {"n", "<down>", act.next_entry, {desc = "Move cursor to next file entry"}},
                    {"n", "k", act.prev_entry, {desc = "Move cursor to prev file entry"}},
                    {"n", "<up>", act.prev_entry, {desc = "Move  cursor to prev file entry"}},
                    {"n", "<cr>", act.select_entry, {desc = "Open the diff for the selected entry"}},
                    {"n", "o", act.select_entry, {desc = "Open the diff for the selected entry"}},
                    {"n", "l", act.select_entry, {desc = "Open the diff for the selected entry"}},
                    {"n", "<2-LeftMouse>", act.select_entry, {desc = "Open diff for selected entry"}},
                    {"n", "-", act.toggle_stage_entry, {desc = "(un)Stage selected entry"}},
                    {"n", "S", act.stage_all, {desc = "Stage all entries"}},
                    {"n", "U", act.unstage_all, {desc = "Unstage all entries"}},
                    {"n", "X", act.restore_entry, {desc = "Restore entry to state on left"}},
                    {"n", "L", act.open_commit_log, {desc = "Open commit log panel"}},
                    {"n", "zo", act.open_fold, {desc = "Expand fold"}},
                    {"n", "h", act.close_fold, {desc = "Collapse fold"}},
                    {"n", "zc", act.close_fold, {desc = "Collapse fold"}},
                    {"n", "za", act.toggle_fold, {desc = "Toggle fold"}},
                    {"n", "zR", act.open_all_folds, {desc = "Expand all folds"}},
                    {"n", "zM", act.close_all_folds, {desc = "Collapse all folds"}},
                    {"n", "<c-b>", act.scroll_view(-0.25), {desc = "Scroll the view up"}},
                    {"n", "<c-f>", act.scroll_view(0.25), {desc = "Scroll the view down"}},
                    {"n", "<tab>", act.select_next_entry, {desc = "Open diff for next file"}},
                    {"n", "<s-tab>", act.select_prev_entry, {desc = "Open diff for prev file"}},
                    {"n", "gf", act.goto_file, {desc = "Open file"}},
                    {"n", "gF", act.goto_file_edit, {desc = "Open file in prev tabpage"}},
                    {"n", "<C-w><C-f>", act.goto_file_split, {desc = "Open file in a new split"}},
                    {"n", "<C-w>gf", act.goto_file_tab, {desc = "Open file in a new tabpage"}},
                    {"n", "i", act.listing_style, {desc = "Toggle between 'list' & 'tree' views"}},
                    {"n", "R", act.refresh_files, {desc = "Update stats & entries in file list"}},
                    {"n", "<leader>e", act.focus_files, {desc = "Bring focus to file panel"}},
                    {"n", "<leader>b", act.toggle_files, {desc = "Toggle file panel"}},
                    {"n", "g<C-x>", act.cycle_layout, {desc = "Cycle available layouts"}},
                    {"n", "[x", act.prev_conflict, {desc = "Go to prev conflict"}},
                    {"n", "]x", act.next_conflict, {desc = "Go to next conflict"}},
                    {"n", "?", act.help("file_panel"), {desc = "Open help panel"}},
                    {"n", "Q", act.close, {desc = "Close panel"}},
                    {"n", "qq", "<Cmd>DiffviewClose<CR>", {desc = "Close Diffview"}},
                    {
                        "n",
                        "f",
                        act.toggle_flatten_dirs,
                        {desc = "Flatten empty subdirs tree list style"},
                    },
                },
                file_history_panel = {
                    {"n", "g!", act.options, {desc = "Open option panel"}},
                    {"n", "<C-A-d>", act.open_in_diffview, {desc = "Open under cursor in diffview"}},
                    {"n", "y", act.copy_hash, {desc = "Copy commit hash of entry"}},
                    {"n", "L", act.open_commit_log, {desc = "Show commit details"}},
                    {"n", "X", act.restore_entry, {desc = "Restore file to that of selected entry"}},
                    {"n", "zo", act.open_fold, {desc = "Expand fold"}},
                    {"n", "zc", act.close_fold, {desc = "Collapse fold"}},
                    {"n", "h", act.close_fold, {desc = "Collapse fold"}},
                    {"n", "za", act.toggle_fold, {desc = "Toggle fold"}},
                    {"n", "zR", act.open_all_folds, {desc = "Expand all folds"}},
                    {"n", "zM", act.close_all_folds, {desc = "Collapse all folds"}},
                    {"n", "j", act.next_entry, {desc = "Move cursor to next file entry"}},
                    {"n", "<down>", act.next_entry, {desc = "Move cursor to next file entry"}},
                    {"n", "k", act.prev_entry, {desc = "Move cursor to prev file entry"}},
                    {"n", "<up>", act.prev_entry, {desc = "Move cursor to prev file entry"}},
                    {"n", "<cr>", act.select_entry, {desc = "Open diff for selected entry"}},
                    {"n", "o", act.select_entry, {desc = "Open diff for selected entry"}},
                    {"n", "l", act.select_entry, {desc = "Open diff for selected entry"}},
                    {"n", "<2-LeftMouse>", act.select_entry, {desc = "Open diff for selected entry"}},
                    {"n", "<c-b>", act.scroll_view(-0.25), {desc = "Scroll view up"}},
                    {"n", "<c-f>", act.scroll_view(0.25), {desc = "Scroll view down"}},
                    {"n", "<tab>", act.select_next_entry, {desc = "Open diff for next file"}},
                    {"n", "<s-tab>", act.select_prev_entry, {desc = "Open diff for prev file"}},
                    {"n", "gf", act.goto_file_edit, {desc = "Open file in prev tabpage"}},
                    {"n", "<C-w><C-f>", act.goto_file_split, {desc = "Open file in a new split"}},
                    {"n", "<C-w>gf", act.goto_file_tab, {desc = "Open file in a new tabpage"}},
                    {"n", "<leader>e", act.focus_files, {desc = "Bring focus to file panel"}},
                    {"n", "<leader>b", act.toggle_files, {desc = "Toggle file panel"}},
                    {"n", "g<C-x>", act.cycle_layout, {desc = "Cycle available layouts"}},
                    {"n", "?", act.help("file_history_panel"), {desc = "Open help panel"}},
                    {"n", "Q", act.close, {desc = "Close panel"}},
                    {"n", "qq", "<Cmd>DiffviewClose<CR>", {desc = "Close Diffview"}},
                },
                option_panel = {
                    {"n", "<tab>", act.select_entry, {desc = "Change current option"}},
                    {"n", "qq", act.close, {desc = "Close panel"}},
                    {"n", "?", act.help("option_panel"), {desc = "Open help panel"}},
                },
                help_panel = {
                    {"n", "q", act.close, {desc = "Close help menu"}},
                    {"n", "<esc>", act.close, {desc = "Close help menu"}},
                },
            },
        }
    )
end

local function init()
    M.setup()

    map("n", "<Leader>g;", "DiffviewFileHistory %", {cmd = true, desc = "Diffview: '%' file hist"})
    map("n", "<Leader>gh", "DiffviewFileHistory", {cmd = true, desc = "Diffview: all file hist"})
    map("n", "<Leader>g.", "DiffviewOpen", {cmd = true, desc = "Diffview: open"})

    -- nvim.autocmd.DiffViewMappings = {
    --     event = "FileType",
    --     pattern = {"DiffviewFiles", "DiffviewFileHistory"},
    --     command = function()
    --         local bufnr = nvim.buf.nr()
    --         map("n", "qq", "DiffviewClose", {cmd = true, buffer = bufnr})
    --     end
    -- }
end

init()

return M
