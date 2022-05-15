local M = {}

local utils = require("common.utils")
local map = utils.map
local color = require("common.color")
local augroup = utils.augroup

local wk = require("which-key")
local mapping = require("yanky.telescope.mapping")

function M.setup()
    require("yanky").setup(
        {
            ring = {
                history_length = 50,
                storage = "shada",
                sync_with_numbered_registers = true
            },
            picker = {
                telescope = {
                    mappings = {
                        default = mapping.put("p"),
                        i = {
                            ["<C-j>"] = mapping.put("p"),
                            ["<C-k>"] = mapping.put("P")
                        },
                        n = {
                            ["p"] = mapping.put("p"),
                            ["P"] = mapping.put("P")
                        }
                    }
                }
            },
            system_clipboard = {
                sync_with_ring = true
            },
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 300
            },
            preserve_cursor_position = {
                enabled = true
            }
        }
    )
end

local function init()
    M.setup()

    augroup(
        "lmb__Highlight",
        {
            event = "TextYankPost",
            pattern = "*",
            command = function()
                color.set_hl("HighlightedyankRegion", {bg = "#cc6666"})
                if not vim.b.visual_multi then
                    pcall(vim.highlight.on_yank, {higroup = "HighlightedyankRegion", timeout = 165})
                end
            end,
            description = "Highlight a selection on yank"
        }
    )

    -- color.set_hl("YankyYanked", {background = "#cc6666"})
    color.set_hl("YankyPut", {background = "#cc6666"})

    -- map({"n", "x"}, "y", "<Plug>(YankyYank)")

    map({"n", "x"}, "p", "<Plug>(YankyPutAfter)")
    map({"n", "x"}, "P", "<Plug>(YankyPutBefore)")
    map({"n", "x"}, "gp", "<Plug>(YankyGPutAfter)")
    map({"n", "x"}, "gP", "<Plug>(YankyGPutBefore)")
    map("n", "<M-p>", "<Plug>(YankyCycleForward)")
    map("n", "<M-P>", "<Plug>(YankyCycleBackward)")

    require("telescope").load_extension("yank_history")
end

init()

return M
