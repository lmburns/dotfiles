local M = {}

local D = require("dev")
local neoclip = D.npcall(require, "neoclip")
if not neoclip then
    return
end

local utils = require("common.utils")
local augroup = utils.augroup
local C = require("common.color")
local yank = require("common.yank")
local telescope = require("telescope")

local fn = vim.fn
local v = vim.v

local function is_whitespace(line)
    return fn.match(line, [[^\s*$]]) ~= -1
end

local function all(tbl, check)
    for _, entry in ipairs(tbl) do
        if not check(entry) then
            return false
        end
    end
    return true
end

local opts = {
    winblend = 10,
    layout_strategy = "flex",
    layout_config = {
        prompt_position = "top",
        width = 0.8,
        height = 0.6,
        horizontal = {width = {padding = 0.15}},
        vertical = {preview_height = 0.70}
    },
    borderchars = {
        prompt = {"─", "│", " ", "│", "╭", "╮", "│", "│"},
        results = {"─", "│", "─", "│", "├", "┤", "╯", "╰"},
        preview = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"}
    },
    border = {},
    shorten_path = false
}

M.dropdown_clip = function()
    local dropdown = require("telescope.themes").get_dropdown(opts)
    telescope.extensions.neoclip.default(dropdown)
end

M.dropdown_macroclip = function()
    local dropdown = require("telescope.themes").get_dropdown(opts)
    telescope.extensions.macroclip.default(dropdown)
end

M.setup = function()
    neoclip.setup(
        {
            history = 10000,
            enable_persistent_history = true,
            length_limit = 1048576,
            continious_sync = false,
            db_path = fn.stdpath("data") .. "/databases/neoclip.sqlite3",
            -- filter = nil,
            filter = function(data)
                return not all(data.event.regcontents, is_whitespace)
            end,
            preview = true,
            default_register = "+",
            default_register_macros = "q",
            enable_macro_history = true,
            content_spec_column = false,
            on_paste = {set_reg = false},
            on_replay = {set_reg = true},
            keys = {
                telescope = {
                    i = {
                        select = "<C-n>",
                        paste = "<C-j>",
                        paste_behind = "<c-k>",
                        delete = "<c-d>", -- delete an entry
                        replay = "<c-q>",
                        custom = {
                            ["<C-y>"] = function(opts)
                                yank.yank_reg(v.register, opts.entry.contents[1])
                            end,
                            ["<CR>"] = function(opts)
                                yank.yank_reg(v.register, table.concat(opts.entry.contents, "\n"))
                                local handlers = require("neoclip.handlers")

                                -- handlers.set_registers(opts.register_names, opts.entry)
                                handlers.paste(opts.entry, "p")
                            end
                        }
                    },
                    n = {
                        select = "<C-n>",
                        paste = "p",
                        paste_behind = "P",
                        replay = "q",
                        delete = "d",
                        custom = {
                            ["<CR>"] = function(opts)
                                yank.yank_reg(v.register, opts.entry.contents[1])
                            end
                        }
                    }
                }
            }
        }
    )
end

local function init()
    M.setup()
    -- require('neoclip.fzf')({'a', 'star', 'plus', 'b'})

    augroup(
        "lmb__Highlight",
        {
            event = "TextYankPost",
            pattern = "*",
            command = function()
                C.set_hl("HighlightedyankRegion", {bg = "#cc6666"})
                if not vim.b.visual_multi then
                    pcall(vim.highlight.on_yank, {higroup = "HighlightedyankRegion", timeout = 165})
                end
            end,
            desc = "Highlight a selection on yank"
        }
    )

    telescope.load_extension("neoclip")
end

init()

return M
