local M = {}

local D = require("dev")
local neoclip = D.npcall(require, "neoclip")
if not neoclip then
    return
end

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup
local hl = require("common.color")
local yank = require("common.yank")
local telescope = require("telescope")

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local v = vim.v
local cmd = vim.cmd

M.timeout = 165

local function is_whitespace(line)
    return fn.match(line, [[^\s*$]]) ~= -1
end

local opts = {
    winblend = 10,
    layout_strategy = "flex",
    layout_config = {
        prompt_position = "top",
        width = 0.8,
        height = 0.7,
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
            history = 500,
            enable_persistent_history = true,
            length_limit = 1048576,
            continious_sync = false,
            db_path = fn.stdpath("data") .. "/databases/neoclip.sqlite3",
            -- filter = nil,
            filter = function(data)
                return not D.all(data.event.regcontents, is_whitespace)
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

function M.setup_hl()
    M.ns = api.nvim_create_namespace("put.region")
    M.timer = uv.new_timer()
    hl.set("HighlightedPutRegion", {bg = "#cc6666"})
end

local function get_region()
    -- Previously yanked/changed text extmark
    local start = api.nvim_buf_get_mark(0, "[")
    local finish = api.nvim_buf_get_mark(0, "]")

    return {
        start_row = start[1] - 1,
        start_col = start[2],
        end_row = finish[1] - 1,
        end_col = finish[2]
    }
end

function M.highlight_put(register)
    M.timer:stop()
    api.nvim_buf_clear_namespace(0, M.ns, 0, -1)

    local region = get_region()

    vim.highlight.range(
        0,
        M.ns,
        "HighlightedPutRegion",
        {region.start_row, region.start_col},
        {region.end_row, region.end_col},
        {regtype = fn.getregtype(register), inclusive = true}
    )

    M.timer:start(
        M.timeout,
        0,
        vim.schedule_wrap(
            function()
                api.nvim_buf_clear_namespace(0, M.ns, 0, -1)
            end
        )
    )
end

function M.do_put(binding, reg)
    reg = utils.get_default(reg, v.register)
    local cnt = v.count1
    -- local is_visual = fn.visualmode():match("[vV]")
    -- local ok = pcall(cmd, ('norm! %s"%s%s%s'):format(F.tern(is_visual, "gv", ""), reg, cnt, binding))
    local ok = pcall(cmd, ('norm! "%s%d%s'):format(reg, cnt, binding))

    if ok then
        M.highlight_put(reg)
    end
end

local function init()
    M.setup()
    M.setup_hl()

    -- require('neoclip.fzf')({'a', 'star', 'plus', 'b'})

    map("n", "p", ":lua require('plugs.neoclip').do_put('p')<CR>")
    map("n", "P", ":lua require('plugs.neoclip').do_put('P')<CR>")
    map("n", "gp", ":lua require('plugs.neoclip').do_put('gp')<CR>")
    map("n", "gP", ":lua require('plugs.neoclip').do_put('gP')<CR>")

    augroup(
        "lmb__Highlight",
        {
            event = "TextYankPost",
            pattern = "*",
            command = function()
                hl.set("HighlightedYankRegion", {bg = "#cc6666"})
                if not vim.b.visual_multi then
                    pcall(
                        vim.highlight.on_yank,
                        {higroup = "HighlightedYankRegion", timeout = M.timeout, on_visual = true}
                    )
                end
            end,
            desc = "Highlight a selection on yank"
        }
    )

    telescope.load_extension("neoclip")
end

init()

return M
