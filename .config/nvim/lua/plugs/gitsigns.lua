local M = {}

local D = require("dev")
local gitsigns = D.npcall(require, "gitsigns")
if not gitsigns then
    return
end

local log = require("common.log")
local utils = require("common.utils")
local map = utils.map
local bmap = utils.bmap
local augroup = utils.augroup

local C = require("common.color")
local wk = require("which-key")

local ex = nvim.ex
local fn = vim.fn
local F = vim.F

local config

---Echo a message to `:messages`
---@param status string
---@param toggled string
local function echo(status, toggled)
    nvim.echo({{"Gitsigns [", "SpellCap"}, {status, "MoreMsg"}, {("] %s"):format(toggled), "SpellCap"}})
end

function M.toggle_deleted()
    require("gitsigns").toggle_deleted()
    local status = F.tern(config.show_deleted, "enable", "disable")
    echo(status, "show_deleted")
end

function M.toggle_linehl()
    require("gitsigns").toggle_linehl()
    local status = F.tern(config.linehl, "enable", "disable")
    echo(status, "linehl")
end

function M.toggle_word_diff()
    require("gitsigns").toggle_word_diff()
    local status = F.tern(config.word_diff, "enable", "disable")
    echo(status, "word_diff")
end

function M.toggle_blame()
    require("gitsigns").toggle_current_line_blame()
    local status = F.tern(config.current_line_blame, "enable", "disable")
    echo(status, "current_line_blame")
end

local function mappings(bufnr)
    local gs = package.loaded.gitsigns

    wk.register(
        {
            ["<Leader>he"] = {"<Cmd>Gitsigns stage_hunk<CR>", "Stage hunk (git)"},
            ["<Leader>hp"] = {"<Cmd>Gitsigns preview_hunk<CR>", "Preview hunk (git)"},
            ["<Leader>hS"] = {"<Cmd>Gitsigns undo_stage_hunk<CR>", "Undo stage hunk (git)"},
            ["<Leader>hu"] = {"<Cmd>Gitsigns reset_hunk<CR>", "Reset hunk (git)"},
            ["<Leader>hr"] = {"<Cmd>Gitsigns reset_buffer<CR>", "Reset buffer (git)"},
            ["<Leader>hd"] = {"<Cmd>Gitsigns diffthis<CR>", "Diff this now (git)"},
            ["<Leader>hD"] = {D.ithunk(gs.diffthis, "~"), "Diff this last commit (git)"},
            ["<Leader>hq"] = {D.ithunk(gs.setqflist), "Set qflist (git)"},
            ["<Leader>hQ"] = {D.ithunk(gs.setqflist, "all"), "Set qflist all (git)"},
            ["<Leader>hv"] = {[[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]], "Toggle deleted hunks (git)"},
            ["<Leader>hl"] = {"<Cmd>lua require('plugs.gitsigns').toggle_linehl()<CR>", "Toggle line highlight (git)"},
            ["<Leader>hw"] = {"<Cmd>lua require('plugs.gitsigns').toggle_word_diff()<CR>", "Toggle word diff (git)"},
            ["<Leader>hB"] = {"<Cmd>lua require('plugs.gitsigns').toggle_blame()<CR>", "Toggle blame line virt (git)"},
            ["<Leader>hb"] = {D.ithunk(gs.blame_line, {full = true}), "Blame line virt (git)"}
        },
        {buffer = bufnr}
    )

    map("n", "]c", [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']], {expr = true})
    map("n", "[c", [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']], {expr = true})

    wk.register(
        {
            ["]c"] = "Next hunk",
            ["[c"] = "Prevous hunk"
        }
    )

    -- map("n", "<Leader>he", "<Cmd>Gitsigns stage_hunk<CR>")
    -- map("x", "<Leader>he", ":Gitsigns stage_hunk<CR>")
    -- map("n", "<Leader>hS", "<Cmd>Gitsigns undo_stage_hunk<CR>")
    -- map("n", "<Leader>hu", "<Cmd>Gitsigns reset_hunk<CR>")

    map(
        "x",
        "<Leader>he",
        function()
            gs.stage_hunk {fn.line("."), fn.line("v")}
        end,
        {buffer = bufnr, desc = "Stage hunk"}
    )

    map(
        "x",
        "<Leader>hu",
        function()
            gs.reset_hunk {fn.line("."), fn.line("v")}
        end,
        {buffer = bufnr, desc = "Reset hunk"}
    )

    -- map("x", "<Leader>hu", ":Gitsigns reset_hunk<CR>")
    -- map("n", "<Leader>hp", "<Cmd>Gitsigns preview_hunk<CR>")
    -- map("n", "<Leader>hv", [[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]])
    -- map("n", "<Leader>hQ", "<Cmd>Gitsigns setqflist all<CR>")
    -- map("n", "<Leader>hq", "<Cmd>Gitsigns setqflist<CR>")

    bmap(bufnr, "o", "ih", "<Cmd>Gitsigns select_hunk<CR>", {desc = "Git hunk"})
    bmap(bufnr, "x", "ih", ":<C-u>Gitsigns select_hunk<CR>", {desc = "Git hunk"})
end

function M.setup()
    gitsigns.setup(
        {
            debug_mode = false,
            _extmark_signs = true,
            _threaded_diff = true,
            signs = {
                add = {
                    hl = "GitSignsAdd",
                    text = "▍",
                    numhl = "Constant",
                    linehl = "GitSignsAddLn",
                    show_count = false
                },
                change = {
                    hl = "GitSignsChange",
                    text = "▍",
                    numhl = "Type",
                    linehl = "GitSignsChangeLn",
                    show_count = false
                },
                delete = {
                    hl = "GitSignsDelete",
                    -- text = "↗",
                    text = "_",
                    numhl = "Identifier",
                    linehl = "GitSignsDeleteLn",
                    show_count = true
                },
                topdelete = {
                    hl = "GitSignsDelete",
                    -- text = "↘",
                    text = "‾",
                    numhl = "ErrorMsg",
                    linehl = "GitSignsDeleteLn",
                    show_count = true
                },
                changedelete = {
                    hl = "GitSignsChange",
                    text = "~",
                    numhl = "Number",
                    linehl = "GitSignsChangeLn",
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
            signcolumn = false,
            numhl = true,
            linehl = false,
            word_diff = false,
            watch_gitdir = {interval = 1000, follow_files = true},
            on_attach = function(bufnr)
                mappings(bufnr)
            end,
            attach_to_untracked = true,
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false
            },
            current_line_blame_formatter_opts = {relative_time = false},
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 40000,
            preview_config = {
                -- Options passed to nvim_open_win
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                noautocmd = true,
                row = 0,
                col = 1
            },
            show_deleted = false,
            trouble = false,
            yadm = {enable = false}
        }
    )
    config = require("gitsigns.config").config
end

local function init()
    ex.packadd("plenary.nvim")

    M.setup()

    local gitsigns_hlights = {
        GitSignsChangeLn = {link = "DiffText"},
        GitSignsAddInline = {link = "GitSignsAddLn"},
        GitSignsDeleteInline = {link = "GitSignsDeleteLn"},
        GitSignsChangeInline = {link = "GitSignsChangeLn"}
    }

    if vim.g.colors_name == "kimbox" then
        local colors = require("kimbox.colors")
        gitsigns_hlights["GitSignsChange"] = {fg = colors.yellow}
    end

    C.plugin("GitSigns", gitsigns_hlights)

    augroup(
        "lmb__GitSignsBlameToggle",
        {
            event = {"InsertEnter"},
            command = function()
                require("gitsigns").toggle_current_line_blame(false)
            end
        },
        {
            event = {"InsertLeave"},
            command = function()
                require("gitsigns").toggle_current_line_blame(true)
            end
        }
    )
end

init()

return M
