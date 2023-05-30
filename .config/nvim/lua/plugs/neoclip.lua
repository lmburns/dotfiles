---@module 'plugs.neoclip'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local neoclip = F.npcall(require, "neoclip")
if not neoclip then
    return
end

local C = shared.collection
local hl = shared.color
local mpi = require("usr.api")
local map = mpi.map
local yank = require("usr.lib.yank")
local lazy = require("usr.lazy")
local telescope = lazy.require_on.call_rec("telescope")

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local v = vim.v
local cmd = vim.cmd

---@class NeoclipEntryInner
---@field contents string[]
---@field filetype string
---@field regtype string

---@class NeoclipEntry
---@field entry NeoclipEntryInner
---@field register_names string[]
---@field typ string

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
        vertical = {preview_height = 0.70},
    },
    borderchars = {
        prompt = {"─", "│", " ", "│", "╭", "╮", "│", "│"},
        results = {"─", "│", "─", "│", "├", "┤", "╯", "╰"},
        preview = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
    },
    border = {},
    shorten_path = false,
}

M.dropdown_clip = function()
    local dropdown = require("telescope.themes").get_dropdown(opts)
    telescope.extensions.neoclip.default(dropdown)
end

M.dropdown_macroclip = function()
    local dropdown = require("telescope.themes").get_dropdown(opts)
    telescope.extensions.macroscope.default(dropdown)
end

---Trim and join lines of text
---@param str string
---@return string, integer
local function trim_lines(str)
    return str:gsub("%s*\r?\n%s*", " "):gsub("^%s*", ""):gsub("%s*$", "")
end

---Paste joined lines in a characterwise fashion
---line1   =>   line1 line2
---line2
---@param opts NeoclipEntry
---@param action "'p'"|"'P'"
---@param joined boolean Whether the lines should be joined
function M.charwise(opts, action, joined)
    local handlers = require("neoclip.handlers")
    local new_entries = {}
    if joined then
        for _, entry in ipairs(opts.entry.contents) do
            local txt = trim_lines(entry)
            table.insert(new_entries, txt)
        end
        opts.entry.contents = {table.concat(new_entries, " ")}
    end
    opts.entry.regtype = "c"
    handlers.paste(opts.entry, action)
end

---Paste text in a linewise fashion
---@param opts NeoclipEntry
---@param action "'p'"|"'P'"
---@param trim boolean Whether space at the beginning should be trimmed
---@param comment? boolean Whether line should be commented
function M.linewise(opts, action, trim, comment)
    local handlers = require("neoclip.handlers")
    local new_entries = {}
    if trim then
        for _, entry in ipairs(opts.entry.contents) do
            local txt = entry:gsub("^%s*", "")
            table.insert(new_entries, txt)
        end
        opts.entry.contents = new_entries
    end
    if comment then
        for _, entry in ipairs(opts.entry.contents) do
            local bufnr = api.nvim_get_current_buf()
            local commentstring = vim.bo[bufnr].cms:split("%s")[1]:trim() or "#"
            local txt = commentstring .. entry
            table.insert(new_entries, txt)
        end
        opts.entry.contents = new_entries
    end
    opts.entry.regtype = "l"
    handlers.paste(opts.entry, action)
end

---Paste text in a blockwise fashion
---@param opts NeoclipEntry
---@param action "'p'"|"'P'"
---@param joined boolean Whether the lines should be joined
function M.blockwise(opts, action, joined)
    local handlers = require("neoclip.handlers")
    local new_entries = {}
    if joined then
        for _, entry in ipairs(opts.entry.contents) do
            local txt = trim_lines(entry)
            table.insert(new_entries, txt)
        end
        opts.entry.contents = new_entries
    end
    opts.entry.regtype = "b"
    handlers.paste(opts.entry, action)
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
        end_col = finish[2],
    }
end

function M.highlight_put(register)
    M.timer:stop()
    api.nvim_buf_clear_namespace(0, M.ns, 0, -1)

    local region = get_region()

    vim.highlight.range(
        0, M.ns, "HighlightedPutRegion", {region.start_row, region.start_col},
        {region.end_row, region.end_col},
        {regtype = fn.getregtype(register), inclusive = true}
    )

    M.timer:start(
        M.timeout,
        0,
        vim.schedule_wrap(function()
            api.nvim_buf_clear_namespace(0, M.ns, 0, -1)
        end)
    )
end

---Wrapper around pasting
---@param binding string Paste command to run
---@param reg string Register to use
---@param command? string Command to run after pasting
function M.do_put(binding, reg, command)
    reg = F.unwrap_or(reg, v.register)
    local cnt = v.count1
    -- local is_visual = fn.visualmode():match("[vV]")
    -- local ok = pcall(cmd, ('norm! %s"%s%s%s'):format(F.if_expr(is_visual, "gv", ""), reg, cnt, binding))
    local ok = pcall(cmd, ("norm! \"%s%d%s"):format(reg, cnt, binding))

    if ok then
        M.highlight_put(reg)
    end

    if command then
        cmd(command)
    end
end

function M.setup()
    neoclip.setup({
        history = 100,
        enable_persistent_history = true,
        length_limit = 1048576,
        continious_sync = true,
        db_path = ("%s/%s"):format(lb.dirs.data, "databases/neoclip.sqlite3"),
        -- filter = nil,
        filter = function(data)
            return not C.all(data.event.regcontents, is_whitespace)
        end,
        preview = true,
        prompt = "Paste: ",
        default_register = "+, extra=star,plus,unnamed",
        default_register_macros = "q",
        enable_macro_history = true,
        content_spec_column = false,

        on_select = {move_to_front = false, close_telescope = true},
        on_paste = {set_reg = false, move_to_front = false, close_telescope = true},
        on_replay = {set_reg = true, move_to_front = false, close_telescope = true},
        on_custom_action = {close_telescope = true},
        keys = {
            telescope = {
                i = {
                    select = "<C-n>",
                    paste = "<C-j>",
                    paste_behind = "<C-k>",
                    delete = "<C-d>", -- delete an entry
                    edit = "<C-e>",   -- edit an entry
                    replay = "<C-q>",
                    custom = {
                        ["<A-[>"] = function(opts)
                            p(opts)
                        end,
                        ["gcp"] = function(opts)
                            M.charwise(opts, "p", true)
                        end,
                        ["gcP"] = function(opts)
                            M.charwise(opts, "P", true)
                        end,
                        ["glp"] = function(opts)
                            M.linewise(opts, "p", true)
                        end,
                        ["glP"] = function(opts)
                            M.linewise(opts, "P", true)
                        end,
                        ["ghp"] = function(opts)
                            M.linewise(opts, "p", false)
                        end,
                        ["ghP"] = function(opts)
                            M.linewise(opts, "P", false)
                        end,
                        ["gbp"] = function(opts)
                            M.blockwise(opts, "p", false)
                        end,
                        ["gbP"] = function(opts)
                            M.blockwise(opts, "P", false)
                        end,
                        ["g2p"] = function(opts)
                            M.linewise(opts, "p", false, true)
                        end,
                        ["g2P"] = function(opts)
                            M.linewise(opts, "P", false, true)
                        end,
                        ["<C-y>"] = function(opts)
                            yank.yank_reg(v.register, opts.entry.contents[1])
                        end,
                        ["<CR>"] = function(opts)
                            -- yank.yank_reg(v.register, table.concat(opts.entry.contents, "\n"))
                            nvim.reg[v.register] = table.concat(opts.entry.contents, "\n")
                            local handlers = require("neoclip.handlers")

                            -- handlers.set_registers(opts.register_names, opts.entry)
                            handlers.paste(opts.entry, "p")
                        end,
                    },
                },
                n = {
                    select = "<C-n>",
                    paste = "p",
                    paste_behind = "P",
                    replay = "q",
                    delete = "d",
                    edit = "e",
                    custom = {
                        ["<CR>"] = function(opts)
                            -- yank.yank_reg(v.register, opts.entry.contents[1])
                            nvim.reg[v.register] = table.concat(opts.entry.contents, "\n")
                        end,
                        ["gcp"] = function(opts)
                            M.charwise(opts, "p", true)
                        end,
                        ["gcP"] = function(opts)
                            M.charwise(opts, "P", true)
                        end,
                        ["glp"] = function(opts)
                            M.linewise(opts, "p", true)
                        end,
                        ["glP"] = function(opts)
                            M.linewise(opts, "P", true)
                        end,
                        ["ghp"] = function(opts)
                            M.linewise(opts, "p", false)
                        end,
                        ["ghP"] = function(opts)
                            M.linewise(opts, "P", false)
                        end,
                        ["gbp"] = function(opts)
                            M.blockwise(opts, "p", false)
                        end,
                        ["gbP"] = function(opts)
                            M.blockwise(opts, "P", false)
                        end,
                        ["g2p"] = function(opts)
                            M.linewise(opts, "p", false, true)
                        end,
                        ["g2P"] = function(opts)
                            M.linewise(opts, "P", false, true)
                        end,
                    },
                },
            },
        },
    })

    nvim.autocmd.lmb__SyncClipboard = {
        {
            event = "FocusLost",
            pattern = "*",
            command = function()
                vim.g.system_clipboard = {
                    regtype = fn.getregtype("+"),
                    contents = vim.split(fn.getreg("+"), "\n"),
                }
            end,
            desc = "Sync clipboard when unfocusing",
        },
        {
            event = {"VimEnter", "FocusGained"},
            pattern = "*",
            command = function(args)
                local system_clipboard = {
                    regtype = fn.getregtype("+"),
                    contents = vim.split(fn.getreg("+"), "\n"),
                }

                if args.event == "VimEnter"
                    or vim.g.system_clipboard ~= nil
                    and not vim.deep_equal(vim.g.system_clipboard, system_clipboard)
                then
                    require("neoclip")
                    require("neoclip.storage").insert(system_clipboard, "yanks")
                end

                vim.g.system_clipboard = nil
            end,
            desc = "Sync clipboard when unfocusing",
        },
    }

    -- map("n", "p", ":lua require('plugs.neoclip').do_put('p')<CR>", {silent = true})
    -- map("n", "P", ":lua require('plugs.neoclip').do_put('P')<CR>", {silent = true})
    -- map("n", "gp", ":lua require('plugs.neoclip').do_put('gp')<CR>", {silent = true})
    -- map("n", "gP", ":lua require('plugs.neoclip').do_put('gP')<CR>", {silent = true})

    telescope.load_extension("neoclip")
end

function M.setup_yanky()
    local yanky = F.npcall(require, "yanky")
    if not yanky then
        return
    end

    local ymap = require("yanky.telescope.mapping")

    yanky.setup({
        ring = {
            history_length = 100,
            storage = "sqlite", -- "shada"
            sync_with_numbered_registers = false,
            cancel_event = "update",
        },
        picker = {
            telescope = {
                mappings = {
                    default = ymap.put("p"),
                    i = {
                        ["<C-j>"] = ymap.put("p"),
                        ["<C-k>"] = ymap.put("P"),
                        ["<C-x>"] = ymap.delete(),
                    },
                    n = {
                        p = ymap.put("p"),
                        P = ymap.put("P"),
                        d = ymap.delete(),
                    },
                },
            },
        },
        system_clipboard = {sync_with_ring = true},
        highlight = {on_put = true, on_yank = false, timer = 300},
        preserve_cursor_position = {enabled = false},
    })

    hl.set("YankyPut", {link = "IncSearch"})
    -- map({"n", "x"}, "y", "<Plug>(YankyYank)")
    map({"n", "x"}, "p", "<Plug>(YankyPutAfter)")
    map({"n", "x"}, "P", "<Plug>(YankyPutBefore)")
    map({"n", "x"}, "gp", "<Plug>(YankyGPutAfter)")
    map({"n", "x"}, "gP", "<Plug>(YankyGPutBefore)")
    map("n", "<M-p>", "<Plug>(YankyCycleForward)")
    map("n", "<M-P>", "<Plug>(YankyCycleBackward)")
end

function M.setup_composer()
    local composer = F.npcall(require, "NeoComposer")
    if not composer then
        return
    end

    composer.setup({
        notify = true,
        delay_timer = 150,
        colors = {
            bg = "#16161e",
            fg = "#ff9e64",
            red = "#ec5f67",
            blue = "#5fb3b3",
            green = "#99c794",
        },
        keymaps = {
            play_macro = "Q",
            yank_macro = "yq",
            stop_macro = "cq",
            toggle_record = "qq",
            cycle_next = "<C-M-n>",
            cycle_prev = "<C-M-p>",
            toggle_macro_menu = "<C-q>",
        },
    })

    telescope.load_extension("macros")
end

local function init()
    M.setup()
    M.setup_hl()
    M.setup_yanky()
    -- M.setup_composer()

    -- xnoremap p "_c<Esc>p
    map(
        "n",
        "gZ",
        ":lua require('plugs.neoclip').do_put('p', nil, 'norm gV')<CR>",
        {desc = "Paste and reselect text", silent = true}
    )

    nvim.autocmd.lmb__HighlightYankClip = {
        event = "TextYankPost",
        pattern = "*",
        command = function()
            if not vim.b.visual_multi then
                pcall(vim.highlight.on_yank, {
                    higroup = "IncSearch",
                    timeout = M.timeout,
                    on_visual = true,
                })
            end
        end,
        desc = "Highlight a selection on yank",
    }

    -- telescope.load_extension("yank_history")
end

init()

return M
