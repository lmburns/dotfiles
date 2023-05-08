local M = {}

local D = require("dev")
local gs = D.npcall(require, "gitsigns")
if not gs then
    return
end

local style = require("style")
local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup

local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn
local env = vim.env
local F = vim.F

local event = require("common.event")

-- Don't know why having an empty augroup allows the cursor
-- to come out of insert mode and immediately update the blame on the line.
-- The default doesn't update until CursorMoved
local function setup_events()
    augroup("lmb__GitSignsBlameToggle", {
        event = {"InsertEnter", "InsertLeave"},
        command = function(a) event:emit({a.event, "GitSigns"}) end,
    })
end

---Echo a message to `:messages`
---@param status string
---@param toggled string
local function echo(status, toggled)
    nvim.echo({
        {"Gitsigns [", "SpellCap"},
        {status, "MoreMsg"},
        {("] %s"):format(toggled), "SpellCap"},
    })
end

---@param func fun()
---@param value string
---@return "enable"|"disable"
local function toggle(func, value)
    func()
    local status = F.if_expr(config[value], "enable", "disable")
    echo(status, value)
    return status
end

M.toggle_deleted = D.ithunk(toggle, gs.toggle_deleted, "show_deleted")
M.toggle_word_diff = D.ithunk(toggle, gs.toggle_word_diff, "word_diff")
M.toggle_signs = D.ithunk(toggle, gs.toggle_signs, "signcolumn")
M.toggle_linehl = D.ithunk(toggle, gs.toggle_linehl, "linehl")
M.toggle_numhl = D.ithunk(toggle, gs.toggle_numhl, "numhl")
M.toggle_blame = D.ithunk(toggle, gs.toggle_current_line_blame, "current_line_blame")

-- function M.toggle_blame()
--     local status = toggle(gs.toggle_current_line_blame, "current_line_blame")
-- end

local function mappings(bufnr)
    wk.register(
        {
            ["<Leader>hp"] = {"<Cmd>Gitsigns preview_hunk<CR>", "Preview hunk (git)"},
            ["<Leader>hi"] = {"<Cmd>Gitsigns preview_hunk_inline<CR>", "Preview hunk inline (git)"},
            ["<Leader>hs"] = {"<Cmd>Gitsigns stage_hunk<CR>", "Stage hunk (git)"},
            ["<Leader>hS"] = {"<Cmd>Gitsigns stage_buffer<CR>", "Stage buffer (git)"},
            ["<Leader>hu"] = {"<Cmd>Gitsigns undo_stage_hunk<CR>", "Undo stage hunk (git)"},
            ["<Leader>hr"] = {"<Cmd>Gitsigns reset_hunk<CR>", "Reset hunk (git)"},
            ["<Leader>hR"] = {"<Cmd>Gitsigns reset_buffer<CR>", "Reset buffer (git)"},
            ["<Leader>hD"] = {D.ithunk(gs.diffthis, "~"), "Diff this last commit (git)"},
            ["<Leader>gd"] = {D.ithunk(gs.diffthis, "~"), "Diff this last commit (git)"},
            ["<Leader>hd"] = {"<Cmd>Gitsigns diffthis<CR>", "Diff this now (git)"},
            ["<Leader>gu"] = {"<Cmd>Gitsigns diffthis<CR>", "Diff this now (git)"},
            ["<Leader>hq"] = {D.ithunk(gs.setqflist), "Set qflist (git)"},
            ["<Leader>hQ"] = {D.ithunk(gs.setqflist, "all"), "Set qflist all (git)"},
            ["<Leader>hv"] = {M.toggle_deleted, "Toggle deleted hunks (git)"},
            ["<Leader>hl"] = {M.toggle_linehl, "Toggle line highlight (git)"},
            ["<Leader>hw"] = {M.toggle_word_diff, "Toggle word diff (git)"},
            ["<Leader>hB"] = {M.toggle_blame, "Toggle blame line virt (git)"},
            ["<Leader>hc"] = {M.toggle_signs, "Toggle sign column (git)"},
            ["<Leader>hn"] = {M.toggle_numhl, "Toggle number highlight (git)"},
            ["<Leader>hb"] = {D.ithunk(gs.blame_line, {full = true}), "Blame line virt (git)"},
        },
        {buffer = bufnr}
    )

    map("n", "]c", [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']],
        {expr = true, desc = "Next hunk"})
    map("n", "[c", [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']],
        {expr = true, desc = "Prev hunk"})

    map(
        "x",
        "<Leader>hs",
        function()
            gs.stage_hunk({fn.line("."), fn.line("v")})
        end,
        {buffer = bufnr, desc = "Stage hunk (git)"}
    )
    map(
        "x",
        "<Leader>hr",
        function()
            gs.reset_hunk({fn.line("."), fn.line("v")})
        end,
        {buffer = bufnr, desc = "Reset hunk (git)"}
    )

    map("o", "ih", "<Cmd>Gitsigns select_hunk<CR>", {buffer = bufnr, desc = "Git hunk"})
    map("x", "ih", ":<C-u>Gitsigns select_hunk<CR>", {buffer = bufnr, desc = "Git hunk"})
end

function M.setup()
    gs.setup(
        {
            -- Enables debug logging and makes the following functions
            -- available: `dump_cache`, `debug_messages`, `clear_debug`.
            debug_mode = false,
            -- More verbose debug message. Requires debug_mode=true.
            _verbose = false,
            -- Use extmarks for placing signs
            _extmark_signs = false,
            -- Run diffs on a separate thread
            _threaded_diff = true,
            -- Cache blame results for current_line_blame
            _blame_cache = true,
            -- Always refresh the staged file on each update.
            -- Disabling will cause staged file to be refreshed when an update to the index is detected
            _refresh_staged_on_update = true,
            _signs_staged_enable = true,
            signs = {
                add = {
                    hl = "GitSignsAdd",
                    text = "▍",
                    numhl = "Type",
                    linehl = "GitSignsAddLn",
                    show_count = false,
                },
                change = {
                    hl = "GitSignsChange",
                    text = "▍",
                    numhl = "Constant",
                    linehl = "GitSignsChangeLn",
                    show_count = false,
                },
                changedelete = {
                    hl = "GitSignsChange",
                    text = "~",
                    numhl = "Character",
                    linehl = "GitSignsChangeLn",
                    show_count = true,
                },
                delete = {
                    hl = "GitSignsDelete",
                    -- text = "↗",
                    text = "▁",
                    numhl = "ErrorMsg",
                    linehl = "GitSignsDeleteLn",
                    show_count = true,
                },
                topdelete = {
                    hl = "GitSignsDelete",
                    -- text = "↘",
                    text = "▔",
                    numhl = "ErrorMsg",
                    linehl = "GitSignsDeleteLn",
                    show_count = true,
                },
                untracked = {
                    hl = "GitSignsUntracked",
                    text = "┆",
                    numhl = "Tag",
                    linehl = "GitSignsUntrackedLn",
                    show_count = true,
                },
            },
            count_chars = {
                [1] = "",
                [2] = "₂",
                [3] = "₃",
                [4] = "₄",
                [5] = "₅",
                [6] = "₆",
                [7] = "₇",
                [8] = "₈",
                [9] = "₉",
                ["+"] = "₊",
            },
            worktrees = {
                {
                    toplevel = env.DOTBARE_TREE,
                    gitdir = env.DOTBARE_DIR,
                },
            },
            watch_gitdir = {
                enable = true,
                -- Interval the watcher waits between polls of the gitdir in milliseconds.
                interval = 1000,
                -- If a file is moved with `git mv`, switch the buffer to the new location.
                follow_files = true,
            },
            on_attach = function(bufnr)
                mappings(bufnr)
            end,
            sign_priority = 8,
            signcolumn = false,
            numhl = true,
            linehl = false,
            word_diff = false,
            show_deleted = false,
            -- diff_opts = {
            --     -- Diff algorithm to use. Values:
            --     -- • "myers"      the default algorithm
            --     -- • "minimal"    spend extra time to generate the smallest possible diff
            --     -- • "patience"   patience diff algorithm
            --     -- • "histogram"  histogram diff algorithm
            --     algorithm = "patience",
            --     -- Use Neovim's built in xdiff library for running diffs
            --     internal = true,
            --     -- Use the indent heuristic for the internal diff library.
            --     indent_heuristic = true,
            --     -- Start diff mode with vertical splits.
            --     vertical = true,
            --     -- Enable second-stage diff on hunks to align lines.
            --     -- Requires `internal=true`.
            --     linematch = false
            -- },
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                virt_text_priority = 100,
                delay = 1000,
                ignore_whitespace = false,
            },
            -- When a string, accepts the following format specifiers:
            --
            --     • `<abbrev_sha>`
            --     • `<orig_lnum>`
            --     • `<final_lnum>`
            --     • `<author>`
            --     • `<author_mail>`
            --     • `<author_time>` or `<author_time:FORMAT>`
            --     • `<author_tz>`
            --     • `<committer>`
            --     • `<committer_mail>`
            --     • `<committer_time>` or `<committer_time:FORMAT>`
            --     • `<committer_tz>`
            --     • `<summary>`
            --     • `<previous>`
            --     • `<filename>`
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - " ..
                "[<abbrev_sha>]: <summary>",
            current_line_blame_formatter_opts = {relative_time = true},
            current_line_blame_formatter_nc = " <author>",
            attach_to_untracked = true,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 40000,
            preview_config = {
                -- Options passed to nvim_open_win
                border = style.current.border,
                style = "minimal",
                relative = "cursor",
                noautocmd = true,
                row = 0,
                col = 1,
            },
            trouble = false,
            yadm = {enable = false},
        }
    )
    config = require("gitsigns.config").config
end

local function init()
    cmd.packadd("plenary.nvim")

    M.setup()
    -- setup_events()
end

init()

return M
