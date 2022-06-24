local M = {}

local D = require("dev")
local gitsigns = D.npcall(require, "gitsigns")
if not gitsigns then
    return
end

local log = require("common.log")
local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup

local C = require("common.color")
local wk = require("which-key")

local ex = nvim.ex
local fn = vim.fn

local config

function M.toggle_deleted()
    require("gitsigns").toggle_deleted()
    log.info(("Gitsigns %s show_deleted"):format(config.show_deleted and "enable" or "disable"))
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
            ["<Leader>hD"] = {
                function()
                    gs.diffthis("~")
                end,
                "Diff this last commit (git)"
            },
            ["<Leader>hq"] = {"<Cmd>Gitsigns setqflist<CR>", "Set qflist (git)"},
            ["<Leader>hQ"] = {"<Cmd>Gitsigns setqflist all<CR>", "Set qflist all (git)"},
            ["<Leader>hv"] = {[[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]], "Toggle deleted hunks (git)"},
            ["<Leader>hl"] = {"<Cmd>Gitsigns toggle_linehl<CR>", "Toggle line highlight (git)"},
            ["<Leader>hw"] = {"<Cmd>Gitsigns toggle_word_diff<CR>", "Toggle word diff (git)"},
            ["<Leader>hB"] = {"<cmd>Gitsigns toggle_current_line_blame<CR>", "Toggle blame line virt (git)"},
            ["<Leader>hb"] = {
                function()
                    gs.blame_line({full = true})
                end,
                "Blame line virt (git)"
            }
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

    -- map(bufnr, "n", "<Leader>he", "<Cmd>Gitsigns stage_hunk<CR>")
    -- map(bufnr, "x", "<Leader>he", ":Gitsigns stage_hunk<CR>")
    -- map(bufnr, "n", "<Leader>hS", "<Cmd>Gitsigns undo_stage_hunk<CR>")
    -- map(bufnr, "n", "<Leader>hu", "<Cmd>Gitsigns reset_hunk<CR>")

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

    -- bmap(bufnr, "x", "<Leader>hu", ":Gitsigns reset_hunk<CR>")
    -- map(bufnr, "n", "<Leader>hp", "<Cmd>Gitsigns preview_hunk<CR>")
    -- map(bufnr, "n", "<Leader>hv", [[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]])
    -- map(bufnr, "n", "<Leader>hQ", "<Cmd>Gitsigns setqflist all<CR>")
    -- map(bufnr, "n", "<Leader>hq", "<Cmd>Gitsigns setqflist<CR>")

    map(bufnr, "o", "ih", "<Cmd>Gitsigns select_hunk<CR>", {desc = "Git hunk"})
    map(bufnr, "x", "ih", ":<C-u>Gitsigns select_hunk<CR>", {desc = "Git hunk"})
end

function M.setup()
    gitsigns.setup(
        {
            signs = {
                add = {
                    hl = "GitSignsAdd",
                    text = "▍",
                    numhl = "Constant",
                    linehl = "GitSignsAddLn"
                },
                change = {
                    hl = "GitSignsChange",
                    text = "▍",
                    numhl = "Type",
                    linehl = "GitSignsChangeLn"
                },
                delete = {
                    hl = "GitSignsDelete",
                    -- text = "↗",
                    text = "_",
                    show_count = true,
                    numhl = "Identifier",
                    linehl = "GitSignsDeleteLn"
                },
                topdelete = {
                    hl = "GitSignsDelete",
                    -- text = "↘",
                    text = "‾",
                    show_count = true,
                    numhl = "ErrorMsg",
                    linehl = "GitSignsDeleteLn"
                },
                changedelete = {
                    hl = "GitSignsChange",
                    text = "~",
                    show_count = true,
                    numhl = "Number",
                    linehl = "GitSignsChangeLn"
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
            trouble = true,
            yadm = {enable = false}

            -- keymaps = {
            --   -- Default keymap options
            --   noremap = true,
            --   buffer = true,
            --
            --   ["n ]c"] = {
            --     expr = true,
            --     "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
            --   },
            --   ["n [c"] = {
            --     expr = true,
            --     "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
            --   },
            --
            --   ["n <leader>hs"] = "<cmd>lua require\"gitsigns\".stage_hunk()<CR>",
            --   ["v <leader>hs"] = "<cmd>lua require\"gitsigns\".stage_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>",
            --   ["n <leader>hu"] = "<cmd>lua require\"gitsigns\".undo_stage_hunk()<CR>",
            --   ["n <leader>hr"] = "<cmd>lua require\"gitsigns\".reset_hunk()<CR>",
            --   ["v <leader>hr"] = "<cmd>lua require\"gitsigns\".reset_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>",
            --   ["n <leader>hR"] = "<cmd>lua require\"gitsigns\".reset_buffer()<CR>",
            --   ["n <leader>hp"] = "<cmd>lua require\"gitsigns\".preview_hunk()<CR>",
            --   ["n <leader>hb"] = "<cmd>lua require\"gitsigns\".blame_line()<CR>",
            --   ["n <leader>hS"] = "<cmd>lua require\"gitsigns\".stage_buffer()<CR>",
            --   ["n <leader>hU"] = "<cmd>lua require\"gitsigns\".reset_buffer_index()<CR>",
            --
            --   -- Text objects
            --   ["o ih"] = ":<C-U>lua require\"gitsigns.actions\".select_hunk()<CR>",
            --   ["x ih"] = ":<C-U>lua require\"gitsigns.actions\".select_hunk()<CR>",
            -- },
        }
    )
    config = require("gitsigns.config").config
end

local function init()
    M.setup()
    ex.packadd("plenary.nvim")

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
