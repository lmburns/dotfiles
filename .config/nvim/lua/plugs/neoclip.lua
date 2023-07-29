---@module 'plugs.neoclip'
local M = {}

local F = Rc.F
local neoclip = F.npcall(require, "neoclip")
if not neoclip then
    return
end

local C = Rc.shared.C
local hl = Rc.shared.hl
local map = Rc.api.map
local yank = Rc.lib.yank
local render = Rc.lib.render
local lazy = require("usr.lazy")
local telescope = lazy.require_on.call_rec("telescope")

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local v = vim.v
local cmd = vim.cmd

local hlopts = {
    puts = {ns = nil, timeout = 165},
    undo = {ns = nil, timer = nil, timeout = 300, should_detach = true},
}

local topts = {
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

function M.dropdown_clip()
    local dropdown = require("telescope.themes").get_dropdown(topts)
    telescope.extensions.neoclip.default(dropdown)
end

function M.dropdown_macroclip()
    local dropdown = require("telescope.themes").get_dropdown(topts)
    telescope.extensions.macroscope.default(dropdown)
end

---@param line string
---@return bool
local function is_whitespace(line)
    return line:find("^%s*$") ~= nil
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
---@param opts Neoclip.Entry
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
---@param opts Neoclip.Entry
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
---@param opts Neoclip.Entry
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

-- === Highlighting ======================================================= [[[

function M.setup_hl_put()
    hlopts.puts.ns = api.nvim_create_namespace("hl.put.region")
    hl.set("HighlightedPutRegion", {bg = "#cc6666"})
end

function M.highlight_put(register)
    render.clear_highlight(hlopts.puts.ns)

    local region = Rc.lib.op.get_region_c()

    -- vim.highlight.range(
    --     0,
    --     hlopts.puts.ns,
    --     "HighlightedPutRegion",
    --     {region.start.row, region.start.col},
    --     {region.finish.row, region.finish.col},
    --     {regtype = fn.getregtype(register), inclusive = true}
    -- )

    Rc.lib.render.highlight(
        0,
        "HighlightedPutRegion",
        {region.start.row, region.start.col},
        {region.finish.row, region.finish.col},
        {},
        hlopts.puts.timeout,
        hlopts.puts.ns
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

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function M.setup_hl_undo()
    hlopts.undo.ns = api.nvim_create_namespace("hl.undo.region")
    hlopts.undo.timer = uv.new_timer()
    hl.set("HighlightedUndoRegion", {link = "DiffviewStatusAdded"})
end

---Callback given to `nvim_buf_attach`
---@diagnostic disable:unused-local
function M.on_bytes_cb(
    ignored, bufnr, changedtick,
    srow, scol, sbyte,
    o_erow, o_ecol, o_ebyte,
    n_erow, n_ecol, n_ebyte
)
    if hlopts.undo.should_detach then
        return true
    end

    vim.schedule(function()
        vim.highlight.range(
            bufnr,
            hlopts.undo.ns,
            "HighlightedUndoRegion",
            {srow, scol},
            {srow + n_erow, scol + n_ecol}
        )

        M.hl_undo_clear()

        -- Rc.lib.render.highlight(
        --     bufnr,
        --     "HighlightedUndoRegion",
        --     {srow, scol},
        --     {srow + n_erow, scol + n_ecol},
        --     {},
        --     hlopts.undo.timeout,
        --     hlopts.undo.ns
        -- )
    end)
    ---@diagnostic enable:unused-local
end

---Clear the namespace of undo highlights
function M.hl_undo_clear()
    hlopts.undo.timer:stop()
    -- render.clear_highlight(hlopts.undo.ns)

    hlopts.undo.timer:start(
        hlopts.undo.timeout,
        0,
        F.sithunk(render.clear_highlight, hlopts.undo.ns)
    )
end

---Function that executes the highlight undo
---@param bufnr bufnr
---@param command fun()
function M.highlight_undo(bufnr, command)
    api.nvim_buf_attach(bufnr, false, {on_bytes = M.on_bytes_cb})

    hlopts.undo.should_detach = false
    command()
    hlopts.undo.should_detach = true
end

---Wrapper around undoing
---@generic A : any
---@param binding string|fun(...: A) Undo command to run
---@param ... A arguments to pass to `binding` if it is a function
function M.do_undo(binding, ...)
    local args = {...}
    M.highlight_undo(0, function()
        utils.wrap_fn_call(
            F.ifis_str(binding, ([[exec "norm %d%s"]]):format(v.count1, binding), binding),
            unpack(args)
        )
    end)
end

-- ]]]

function M.setup_yanky()
    local yanky = F.npcall(require, "yanky")
    if not yanky then
        return
    end

    local ymap = require("yanky.telescope.mapping")

    yanky.setup({
        ring = {
            history_length = 100,
            storage = "sqlite", -- "shada" "sqlite"
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

function M.setup()
    neoclip.setup({
        history = 100,
        enable_persistent_history = true,
        length_limit = 1048576,
        continious_sync = true,
        db_path = ("%s/%s"):format(Rc.dirs.data, "databases/neoclip.sqlite3"),
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
                    contents = fn.getreg("+"):split("\n"),
                }
            end,
            desc = "Sync clipboard when unfocusing",
        },
        {
            event = {"VimEnter", "FocusGained"},
            pattern = "*",
            command = function(args)
                local sysclip = {
                    regtype = fn.getregtype("+"),
                    contents = fn.getreg("+"):split("\n"),
                }

                if args.event == "VimEnter"
                    or vim.g.system_clipboard ~= nil
                    and not vim.deep_equal(vim.g.system_clipboard, sysclip)
                then
                    require("neoclip")
                    require("neoclip.storage").insert(sysclip, "yanks")
                end

                vim.g.system_clipboard = nil
            end,
            desc = "Sync clipboard when unfocusing",
        },
    }

    map("n", "p", "<Cmd>lua require('plugs.neoclip').do_put('p')<CR>", {silent = true})
    map("n", "P", "<Cmd>lua require('plugs.neoclip').do_put('P')<CR>", {silent = true})
    map("n", "gp", "<Cmd>lua require('plugs.neoclip').do_put('gp')<CR>", {silent = true})
    map("n", "gP", "<Cmd>lua require('plugs.neoclip').do_put('gP')<CR>", {silent = true})

    telescope.load_extension("neoclip")
end

local function init()
    M.setup()
    M.setup_hl_put()
    M.setup_hl_undo()
    -- M.setup_yanky()
    -- M.setup_composer()

    map("n", "u", F.ithunk(M.do_undo, [[\<Plug>(RepeatUndo)]]), {desc = "Undo action"})
    map("n", "U", F.ithunk(M.do_undo, [[\<Plug>(RepeatRedo)]]), {desc = "Redo action"})
    map("n", "<C-S-u>", F.ithunk(M.do_undo, [[\<Plug>(RepeatUndoLine)]]), {desc = "Redo action"})
    -- [[<Cmd>lua require('plugs.neoclip').do_undo("<Plug>(RepeatUndo)")<CR>]],
    -- [[<Cmd>lua require('plugs.neoclip').do_undo("<Plug>(RepeatRedo)")<CR>]],
    -- [[<Cmd>lua require('plugs.neoclip').do_undo("<Plug>(RepeatUndoLine)")<CR>]],

    -- map("n", "u", "<Plug>(RepeatUndo)", {desc = "Undo action"})
    -- map("n", "U", "<Plug>(RepeatRedo)", {desc = "Redo action"})
    -- map("n", "<C-S-u>", "<Plug>(RepeatUndoLine)", {desc = "Undo entire line"})
    -- map("n", ";U", "<Cmd>execute('later ' . v:count1 . 'f')<CR>", {desc = "Go to newer text state"})
    -- map("n", ";u", "<Cmd>execute('earlier ' . v:count1 . 'f')<CR>", {desc = "Go to older state"})
    -- g+ g-

    -- Paste
    -- xnoremap p "_c<Esc>p
    map(
        "n",
        "gZ",
        "<Cmd>lua require('plugs.neoclip').do_put('p', nil, 'norm gV')<CR>",
        {desc = "Paste and reselect text", silent = true}
    )

    nvim.autocmd.lmb__HighlightYankClip = {
        event = "TextYankPost",
        pattern = "*",
        desc = "Highlight a selection on yank",
        command = function()
            if not vim.b.visual_multi then
                pcall(vim.highlight.on_yank, {
                    higroup = "IncSearch",
                    timeout = hlopts.puts.timeout,
                    on_visual = true,
                })
            end
        end,
    }

    -- telescope.load_extension("yank_history")
end

init()

return M
