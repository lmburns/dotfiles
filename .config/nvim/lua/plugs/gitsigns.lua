local M = {}

local D = require("dev")
local gs = D.npcall(require, "gitsigns")
if not gs then
    return
end

local style = require("style")
local utils = require("common.utils")
local map = utils.map
local bmap = utils.bmap
local augroup = utils.augroup

local log = require("common.log")
local wk = require("which-key")

local cmd = vim.cmd
local fn = vim.fn
local env = vim.env
local F = vim.F

local config
local autocmd_id

---Echo a message to `:messages`
---@param status string
---@param toggled string
local function echo(status, toggled)
    nvim.echo(
        {
            {"Gitsigns [", "SpellCap"},
            {status, "MoreMsg"},
            {("] %s"):format(toggled), "SpellCap"}
        }
    )
end

function M.toggle_deleted()
    gs.toggle_deleted()
    local status = F.tern(config.show_deleted, "enable", "disable")
    echo(status, "show_deleted")
end

function M.toggle_word_diff()
    gs.toggle_word_diff()
    local status = F.tern(config.word_diff, "enable", "disable")
    echo(status, "word_diff")
end

function M.toggle_blame()
    gs.toggle_current_line_blame()
    local status = F.tern(config.current_line_blame, "enable", "disable")
    echo(status, "current_line_blame")

    if status == "enable" then
        if not autocmd_id then
            autocmd_id = M.setup_autocmd()
        end
    else
        local ok = utils.del_augroup(autocmd_id)
        if not ok then
            log.err("Gitsigns: failed to delete autocommand")
        end
    end
end

function M.toggle_signs()
    gs.toggle_signs()
    local status = F.tern(config.sign_column, "enable", "disable")
    echo(status, "sign_column")
end

function M.toggle_linehl()
    gs.toggle_linehl()
    local status = F.tern(config.linehl, "enable", "disable")
    echo(status, "linehl")
end

function M.toggle_numhl()
    gs.toggle_numhl()
    local status = F.tern(config.numhl, "enable", "disable")
    echo(status, "numhl")
end

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
            ["<Leader>hd"] = {"<Cmd>Gitsigns diffthis<CR>", "Diff this now (git)"},
            ["<Leader>hD"] = {D.ithunk(gs.diffthis, "~"), "Diff this last commit (git)"},
            ["<Leader>hq"] = {D.ithunk(gs.setqflist), "Set qflist (git)"},
            ["<Leader>hQ"] = {D.ithunk(gs.setqflist, "all"), "Set qflist all (git)"},
            ["<Leader>hv"] = {
                [[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]],
                "Toggle deleted hunks (git)"
            },
            ["<Leader>hl"] = {
                "<Cmd>lua require('plugs.gitsigns').toggle_linehl()<CR>",
                "Toggle line highlight (git)"
            },
            ["<Leader>hw"] = {
                "<Cmd>lua require('plugs.gitsigns').toggle_word_diff()<CR>",
                "Toggle word diff (git)"
            },
            ["<Leader>hB"] = {
                "<Cmd>lua require('plugs.gitsigns').toggle_blame()<CR>",
                "Toggle blame line virt (git)"
            },
            ["<Leader>hc"] = {
                "<Cmd>lua require('plugs.gitsigns').toggle_signs()<CR>",
                "Toggle sign column (git)"
            },
            ["<Leader>hn"] = {
                "<Cmd>lua require('plugs.gitsigns').toggle_numhl()<CR>",
                "Toggle number highlight (git)"
            },
            ["<Leader>hb"] = {D.ithunk(gs.blame_line, {full = true}), "Blame line virt (git)"}
        },
        {buffer = bufnr}
    )

    map("n", "]c", [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']], {expr = true})
    map("n", "[c", [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']], {expr = true})

    -- map("x", "<Leader>he", ":Gitsigns stage_hunk<CR>")

    map(
        "x",
        "<Leader>hs",
        function()
            gs.stage_hunk {fn.line("."), fn.line("v")}
        end,
        {buffer = bufnr, desc = "Stage hunk (g)"}
    )

    map(
        "x",
        "<Leader>hr",
        function()
            gs.reset_hunk {fn.line("."), fn.line("v")}
        end,
        {buffer = bufnr, desc = "Reset hunk (git)"}
    )

    bmap(bufnr, "o", "ih", "<Cmd>Gitsigns select_hunk<CR>", {desc = "Git hunk"})
    bmap(bufnr, "x", "ih", ":<C-u>Gitsigns select_hunk<CR>", {desc = "Git hunk"})
end

function M.setup_autocmd()
    local id =
        augroup(
        "lmb__GitSignsBlameToggle",
        {
            event = {"InsertEnter"},
            command = function()
                gs.toggle_current_line_blame(false)
            end
        },
        {
            event = {"InsertLeave"},
            command = function()
                gs.toggle_current_line_blame(true)
            end
        }
    )
    return id
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
            _refresh_staged_on_update = false,
            -- _signs_staged_enable = true,
            signs = {
                add = {
                    hl = "GitSignsAdd",
                    text = "▍",
                    numhl = "Type",
                    linehl = "GitSignsAddLn",
                    show_count = false
                },
                change = {
                    hl = "GitSignsChange",
                    text = "▍",
                    numhl = "Constant",
                    linehl = "GitSignsChangeLn",
                    show_count = false
                },
                changedelete = {
                    hl = "GitSignsChange",
                    text = "~",
                    numhl = "Character",
                    linehl = "GitSignsChangeLn",
                    show_count = true
                },
                delete = {
                    hl = "GitSignsDelete",
                    -- text = "↗",
                    text = "▁",
                    numhl = "ErrorMsg",
                    linehl = "GitSignsDeleteLn",
                    show_count = true
                },
                topdelete = {
                    hl = "GitSignsDelete",
                    -- text = "↘",
                    text = "▔",
                    numhl = "ErrorMsg",
                    linehl = "GitSignsDeleteLn",
                    show_count = true
                },
                untracked = {
                    hl = "GitSignsUntracked",
                    text = "┆",
                    numhl = "Tag",
                    linehl = "GitSignsUntrackedLn",
                    show_count = true
                }
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
                ["+"] = "₊"
            },
            worktrees = {
                {
                    toplevel = env.DOTBARE_TREE,
                    gitdir = env.DOTBARE_DIR
                }
            },
            -- on_attach_pre = function(bufnr, cb)
            --     cb {
            --         toplevel = env.DOTBARE_TREE,
            --         gitdir = env.DOTBARE_DIR
            --     }
            -- end,
            watch_gitdir = {
                enable = true,
                -- Interval the watcher waits between polls of the gitdir in milliseconds.
                interval = 1000,
                -- If a file is moved with `git mv`, switch the buffer to the new location.
                follow_files = true
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
            diff_opts = {
                -- Diff algorithm to use. Values:
                -- • "myers"      the default algorithm
                -- • "minimal"    spend extra time to generate the smallest possible diff
                -- • "patience"   patience diff algorithm
                -- • "histogram"  histogram diff algorithm
                algorithm = "patience",
                -- Use Neovim's built in xdiff library for running diffs
                internal = true,
                -- Use the indent heuristic for the internal diff library.
                indent_heuristic = true,
                -- Start diff mode with vertical splits.
                vertical = true,
                -- Enable second-stage diff on hunks to align lines.
                -- Requires `internal=true`.
                linematch = 60
            },
            current_line_blame = false,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                virt_text_priority = 100,
                delay = 1000,
                ignore_whitespace = false
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
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - [<abbrev_sha>]: <summary>",
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
                col = 1
            },
            trouble = false,
            yadm = {enable = false}
        }
    )
    config = require("gitsigns.config").config
end

local function init()
    cmd.packadd("plenary.nvim")

    M.setup()

    if config.current_line_blame then
        autocmd_id = M.setup_autocmd()
    end
end

init()

return M
