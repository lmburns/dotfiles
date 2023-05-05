---Contains configuration items for plugins that don't deserve their own file
--@module config
--@author lmburns

local M = {}

local D = require("dev")
local utils = require("common.utils")
local style = require("style")
local lazy = require("common.lazy")
local log = require("common.log")
local hl = require("common.color")
-- local coc = require("plugs.coc")

local wk = require("which-key")

local mpi = require("common.api")
local bmap = mpi.bmap
local map = mpi.map
local command = mpi.command
local augroup = mpi.augroup
-- local autocmd = mpi.autocmd

local fs = vim.fs
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

--  ╭──────────────────────────────────────────────────────────╮
--  │                          FSRead                          │
--  ╰──────────────────────────────────────────────────────────╯
function M.fsread()
    g.flow_strength = 0.7         -- low: 0.3, middle: 0.5, high: 0.7 (default)
    g.skip_flow_default_hl = true -- If you want to override default highlights

    hl.plugin(
        "FSRead",
        {
            FSPrefix = {fg = "#cdd6f4"},
            FSSuffix = {fg = "#6C7086"},
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Listish                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.listish()
    local listish = D.npcall(require, "listish")
    if not listish then
        return
    end

    listish.config(
        {
            theme_list = false,
            clearqflist = "ClearQuickfix",  -- command
            clearloclist = "ClearLoclist",  -- command
            clear_notes = "ClearListNotes", -- command
            lists_close = "<Nop>",          -- closes both qf/local lists
            in_list_dd = "dd",              -- delete current item in the list
            quickfix = {
                open = "qo",
                on_cursor = "qa", -- add current position to the list
                add_note = "qA",  -- add current position with your note to the list
                clear = "qe",     -- clear all items
                close = "<Nop>",
                next = "<Nop>",
                prev = "<Nop>",
            },
            locallist = {
                open = "<Leader>wo",
                on_cursor = "<Leader>wa",
                add_note = "<Leader>wn",
                clear = "<Leader>wi",
                close = "<Nop>",
                next = "<Nop>",
                prev = "<Nop>",
            },
        }
    )

    require("legendary").commands(
        {
            {":ClearQuickfix", description = "Clear quickfix list"},
            {":ClearLoclist", description = "Clear location list"},
            {":ClearListNotes", description = "Clear quickfix notes"},
        }
    )

    wk.register(
        {
            q = {
                name = "+quickfix",
                o = "Quickfix open",
                a = "Quickfix add current line",
                A = "Quickfix add note",
                e = "Quickfix clear items (empty)",
            },
            ["<Leader>wo"] = "Loclist open",
            ["<Leader>wa"] = "Loclist add current line",
            ["<Leader>wn"] = "Loclist add note",
            ["<Leader>wi"] = "Loclist clear items",
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          eregex                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.eregex()
    g.eregex_forward_delim = "/"
    g.eregex_backward_delim = "?"

    map("n", "<Leader>es", "<Cmd>call eregex#toggle()<CR>", {desc = "Toggle eregex"})
    map("n", ",/", "<Cmd>call eregex#toggle()<CR>", {desc = "Toggle eregex"})
    map("n", "<Leader>S", ":%S//g<Left><Left>", {desc = "Global replace (E2v)"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           Suda                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.suda()
    -- map("c", "w!!", ":SudaWrite<CR>")
    map("n", "<Leader>W", ":SudaWrite<CR>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         LineDiff                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.linediff()
    map("n", "<Leader>ld", "Linediff", {cmd = true})
    map("x", "<Leader>ld", ":Linediff<CR>")

    require("abbr")("c", "ldr", "LinediffReset")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         VCooler                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.vcoolor()
    map("n", "<Leader>pc", ":VCoolor<CR>", {desc = "Insert hex color"})
    map("n", "<Leader>yb", ":VCoolIns h<CR>", {desc = "Insert HSL color"})
    map("n", "<Leader>yr", ":VCoolIns r<CR>", {desc = "Insert RGB color"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        UltiSnips                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.ultisnips()
    -- This works on snippets like #! where a popup menu doesn't appear
    g.UltiSnipsExpandTrigger = "<NUL>"
    g.UltiSnipsListSnippets = "<NUL>"

    -- g.UltiSnipsJumpForwardTrigger = "<C-j>"
    -- g.UltiSnipsJumpBackwardTrigger = "<C-k>"
    -- g.UltiSnipsListSnippets = "<C-u>"
    g.UltiSnipsEditSplit = "horizontal"
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           Sort                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.sort()
    local sort = D.npcall(require, "sort")
    if not sort then
        return
    end

    sort.setup({delimiters = {",", "|", ";", ":", "s", "t"}})

    map("n", "gz", "Sort", {cmd = true, desc = "Sort operator"})
    map("x", "gz", ":Sort<CR>", {desc = "Sort selection"})
    -- map("v", "gW", "<Esc><Cmd>Sort<CR>", {desc = "Sort selection"})

    -- [delimiter] = Manually set delimiter ([s]: space, [t]: tab, [!, ?, &, ... (Lua %p)])
    -- [!]         = Sort order is reversed
    -- [n]         = First decimal number
    -- [b]         = First binary number
    -- [o]         = First octal number
    -- [x]         = First hexadecimal number
    -- [i]         = Case is ignored
    -- [u]         = Keep the first instance of words within selection
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Neogen                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.neogen()
    local neogen = D.npcall(require, "neogen")
    if not neogen then
        return
    end

    neogen.setup(
        {
            enabled = true,
            input_after_comment = true,
            languages = {
                lua = {
                    template = {
                        annotation_convention = "emmylua",
                        emmylua = {
                            {nil, "- $1", {type = {"class", "func"}}},
                            {nil, "- $1", {no_results = true, type = {"class", "func"}}},
                            {nil, "-@module $1", {no_results = true, type = {"file"}}},
                            {nil, "-@author $1", {no_results = true, type = {"file"}}},
                            {nil, "-@license $1", {no_results = true, type = {"file"}}},
                            {nil, "", {no_results = true, type = {"file"}}},
                            {"parameters", "-@param %s $1|any"},
                            {"varargs", "-@param ... $1|any"},
                            {"return_statement", "-@return $1|any"},
                            {"class_name", "-@class $1|any"},
                            {"type", "-@type $1"},
                        },
                    },
                },
                python = {
                    template = {annotation_convention = "numpydoc"},
                },
                c = {
                    template = {annotation_convention = "doxygen"},
                },
            },
        }
    )
    map("i", "<C-S-j>", [[<Cmd>lua require('neogen').jump_next()<CR>]])
    map("i", "<C-S-k>", [[<Cmd>lua require('neogen').jump_prev()<CR>]])
    map("n", "<Leader>dg", [[:Neogen<Space>]], {desc = "Neogen <text>"})
    map("n", "<Leader>dn", [[<Cmd>Neogen<CR>]], {desc = "Neogen default"})
    map("n", "<Leader>df", D.ithunk(neogen.generate, {type = "func"}), {desc = "Neogen: func"})
    map("n", "<Leader>dc", D.ithunk(neogen.generate, {type = "class"}), {desc = "Neogen: class"})
    map("n", "<Leader>dt", D.ithunk(neogen.generate, {type = "type"}), {desc = "Neogen: type"})
    map("n", "<Leader>dF", D.ithunk(neogen.generate, {type = "file"}), {desc = "Neogen: file"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          LuaPad                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.luapad()
    local luapad = D.npcall(require, "luapad")
    if not luapad then
        return
    end

    luapad.setup(
        {
            count_limit = 150000,
            preview = true,
            error_indicator = true,
            print_highlight = "Comment",
            error_highlight = "ErrorMsg",
            eval_on_move = false,
            eval_on_change = true,
            split_orientation = "vertical",
            on_init = function()
                if utils.mod.plugin_loaded("noice.nvim") then
                    cmd("sil! Noice disable")
                end
            end,
            -- Global variables provided on startup
            context = {
                D = require("dev"),
                U = require("common.utils"),
                arr = {"abc", "def", "ghi", "jkl"},
                narr = {1, 2, 3, 4, 5},
                tt = _t({abc = 123, def = 456, ghi = 789, jkl = 1011}),
                t = {abc = 123, def = 456, ghi = 789, jkl = 1011},
                mix = {["34"] = 123, def = "str", [5] = 789, ["-0-"] = 1011},
                shout = function(str)
                    return ((str):upper() .. "!")
                end,
            },
        }
    )

    nvim.autocmd.lmb__Luapad = {
        event = "BufLeave",
        pattern = "*Luapad.lua",
        command = function()
            if utils.mod.plugin_loaded("noice.nvim") then
                cmd("sil! Noice enable")
            end
        end,
        desc = "Enable noice when leaving Luapad",
    }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         HlsLens                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.hlslens()
    local hlslens = D.npcall(require, "hlslens")
    if not hlslens then
        return
    end

    hlslens.setup(
        {
            auto_enable = true,
            enable_incsearch = true,
            -- Clear all lens & hl when cursor is out of the range of the matched instance
            -- I had this on my own, but removed it due to this being added here
            calm_down = true,
            nearest_only = false,
            nearest_float_when = "auto",
            float_shadow_blend = 50,
            virt_priority = 100,
            build_position_cb = function(plist, _, _, _)
                require("scrollbar.handlers.search").handler.show(plist.start_pos)
            end,
        }
    )

    command("HlSearchLensToggle", D.ithunk(hlslens.toggle), {desc = "Togggle HLSLens"})

    map(
        "n",
        "n",
        ("%s%s%s"):format(
            [[<Cmd>execute('norm! ' . v:count1 . 'nzv')<CR>]],
            [[<Cmd>lua require('hlslens').start()<CR>]],
            [[<Cmd>lua require("specs").show_specs()<CR>]]
        )
    )
    map(
        "n",
        "N",
        ("%s%s%s"):format(
            [[<Cmd>execute('norm! ' . v:count1 . 'Nzv')<CR>]],
            [[<Cmd>lua require('hlslens').start()<CR>]],
            [[<Cmd>lua require("specs").show_specs()<CR>]]
        )
    )

    g["asterisk#keeppos"] = 1

    map(
        "n",
        "*",
        [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]],
        {desc = "Search forward <word>"}
    )
    map(
        "n",
        "#",
        [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]],
        {desc = "Search forward <word>"}
    )
    map(
        "n",
        "g*",
        [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]],
        {desc = "Search forward word"}
    )
    map(
        "n",
        "g#",
        [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]],
        {desc = "Search backward word"}
    )

    map("x", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]])
    map("x", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]])
    map("x", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]])
    map("x", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]])

    map(
        {"n", "x"},
        "gL",
        function()
            vim.schedule(
                function()
                    if hlslens.exportLastSearchToQuickfix() then
                        cmd("cw")
                    end
                end
            )
            return ":noh<CR>"
        end,
        {silent = true, expr = true, desc = "Export last search to QF"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Caser                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.caser()
    g.caser_prefix = "cr"

    wk.register(
        {
            ["crm"] = "Caser: PascalCase (MixedCase)",
            ["crp"] = "Caser: PascalCase (MixedCase)",
            ["crc"] = "Caser: camelCase",
            ["crt"] = "Caser: Title case",
            ["cr<Space>"] = "Caser: space case",
            ["cr-"] = "Caser: kebab-case (dash-case)",
            ["crk"] = "Caser: kebab-case (dash-case)",
            ["crK"] = "Caser: Title-Kebab-Case",
            ["cr."] = "Caser: dot.case",
            ["cr_"] = "Caser: snake_case",
            ["crU"] = "Caser: UPPER_SNAKE_CASE",
            ["cru"] = {"gU", "Caser: UPPER CASE"},
            ["crl"] = {"gu", "Caser: lower case"},
            ["crs"] = {"<Plug>CaserSnakeCase", "Caser: snake_case"},
            ["crd"] = {"<Plug>CaserDotCase", "Caser: dot.case"},
            ["crS"] = {"<Plug>CaserSentenceCase", "Caser: Sentence case"},
        },
        {mode = {"n", "x"}}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         MatchUp                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.matchup()
    -- g.loaded_matchit = 1
    -- g.matchup_enabled = 1

    g.matchup_mappings_enabled = 0
    g.matchup_matchparen_enabled = 1
    g.matchup_motion_enabled = 1
    g.matchup_text_obj_enabled = 1
    g.matchup_mouse_enabled = 1
    g.matchup_surround_enabled = 1
    g.matchup_transmute_enabled = 0

    g.matchup_motion_override_Npercent = 0
    g.matchup_motion_cursor_end = 0

    -- g.matchup_matchparen_stopline = 400
    g.matchup_matchparen_timeout = 100
    g.matchup_matchparen_deferred = 1
    g.matchup_matchparen_deferred_show_delay = 50
    g.matchup_matchparen_deferred_hide_delay = 300
    g.matchup_matchparen_hi_surround_always = 1

    -- g.matchup_delim_stopline = 500
    g.matchup_delim_start_plaintext = 1 -- loaded for all buffers
    g.matchup_delim_noskips = 2         -- in comments -- 0: All, 1: Brackets
    -- FIX: This isn't working
    g.matchup_delim_nomids = 0          -- match func return end

    -- This window opens and closes automatically really quickly in Lua
    --   status_manual -- MatchupStatusOffscreen
    -- g.matchup_matchparen_offscreen = {}
    -- g.matchup_matchparen_offscreen = {method = "popup", highlight = "MatchParenCur", border = true}
    g.matchup_matchparen_offscreen = {method = "status_manual"}

    hl.plugin(
        "Matchup",
        {
            MatchWord = {link = "Underlined"},
            MatchParen = {bg = "#5e452b", underline = true},
            -- MatchParen = {
            --     fg = require("kimbox.colors").bg_red,
            --     -- bg = "#5e452b",
            --     bold = true,
            --     underline = true
            -- }
        }
    )

    map({"n", "x", "o"}, "%", "<Plug>(matchup-%)")
    map({"n", "x", "o"}, "g%", "<Plug>(matchup-g%)")
    map("o", "g5", "<Plug>(matchup-g%)")

    map({"n", "x", "o"}, "[%", "<Plug>(matchup-[%)")
    map({"n", "x", "o"}, "]%", "<Plug>(matchup-]%)")
    map({"n", "x", "o"}, "[4", "<Plug>(matchup-[%)")
    map({"n", "x", "o"}, "]4", "<Plug>(matchup-]%)")

    map({"n", "x", "o"}, "[5", "<Plug>(matchup-Z%)")
    map({"n", "x", "o"}, "]5", "<Plug>(matchup-z%)")
    map({"n", "x", "o"}, "z{", "<Plug>(matchup-Z%)", {desc = "Inside prev matchup"})
    map({"n", "x", "o"}, "z}", "<Plug>(matchup-z%)", {desc = "Inside next matchup"})

    map({"x", "o"}, "a5", "<Plug>(matchup-a%)")
    map({"x", "o"}, "i5", "<Plug>(matchup-i%)")

    -- FIX: This isn't working
    map("n", "ds%", "<Plug>(matchup-ds%)")
    map("n", "cs%", "<Plug>(matchup-cs%)")

    augroup(
        "lmb__Matchup",
        {
            event = "TermOpen",
            pattern = "*",
            command = function(args)
                local bufnr = args.buf
                vim.b[bufnr].matchup_matchparen_enabled = 0
                vim.b[bufnr].matchup_matchparen_fallback = 0
            end,
        },
        {
            event = "FileType",
            pattern = "qf",
            command = function(args)
                local bufnr = args.buf
                vim.b[bufnr].matchup_matchparen_enabled = 0
                vim.b[bufnr].matchup_matchparen_fallback = 0
            end,
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       BetterEscape                       │
-- ╰──────────────────────────────────────────────────────────╯
function M.better_esc()
    local esc = D.npcall(require, "better_escape")
    if not esc then
        return
    end

    esc.setup(
        {
            mapping = {"jk", "kj"}, -- a table with mappings to use
            -- timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. default = timeoutlen
            timeout = 375,
            clear_empty_lines = false, -- clear line after escaping if there is only whitespace
            keys =
            "<Esc>",                   -- keys used for escaping, if it is a function will use the result everytime
            -- keys = function()
            --   return api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
            -- end,
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       SmartSplits                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.smartsplits()
    -- local ss = D.npcall(require, "smart-splits")
    local ss = D.npcall(lazy.require_on_exported_call, "smart-splits")
    if not ss then
        return
    end

    ss.setup(
        {
            -- Ignored filetypes (only while resizing)
            ignored_filetypes = {"nofile", "quickfix", "prompt"},
            -- Ignored buffer types (only while resizing)
            ignored_buftypes = {"NvimTree"},
            -- when moving cursor between splits left or right,
            -- place the cursor on the same row of the *screen*
            -- regardless of line numbers. False by default.
            -- Can be overridden via function parameter, see Usage.
            move_cursor_same_row = false,
        }
    )

    -- Can be achieved with custom function, but this has more functionality

    -- Move between windows
    wk.register(
        {
            -- ["<C-j>"] = {D.ithunk(ss.move_cursor_down), "Move to below window"},
            -- ["<C-k>"] = {D.ithunk(ss.move_cursor_up), "Move to above window"},
            -- ["<C-h>"] = {D.ithunk(ss.move_cursor_left), "Move to left window"},
            -- ["<C-l>"] = {D.ithunk(ss.move_cursor_right), "Move to right window"},
            ["<C-Up>"] = {D.ithunk(ss.resize_up), "Resize window up"},
            ["<C-Down>"] = {D.ithunk(ss.resize_down), "Resize window down"},
            ["<C-Right>"] = {D.ithunk(ss.resize_right), "Resize window right"},
            ["<C-Left>"] = {D.ithunk(ss.resize_left), "Resize window left"},
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           tmux                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.tmux()
    local tmux = D.npcall(lazy.require_on_exported_call, "tmux")
    if not tmux then
        return
    end

    tmux.setup(
        {
            copy_sync = {
                -- enables copy sync and overwrites all register actions to
                -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
                enable = false,
                -- ignore specific tmux buffers e.g. buffer0 = true to ignore the
                -- first buffer or named_buffer_name = true to ignore a named tmux
                -- buffer with name named_buffer_name :)
                ignore_buffers = {empty = false},
                -- TMUX >= 3.2: yanks (and deletes) will get redirected to system
                -- clipboard by tmux
                redirect_to_clipboard = true,
                -- offset controls where register sync starts
                -- e.g. offset 2 lets registers 0 and 1 untouched
                register_offset = 0,
                -- sync clipboard overwrites vim.g.clipboard to handle * and +
                -- registers. If you sync your system clipboard without tmux, disable
                -- this option!
                sync_clipboard = false,
                -- synchronizes registers *, +, unnamed, and 0 till 9 with tmux buffers.
                sync_registers = false,
                -- syncs deletes with tmux clipboard as well, it is adviced to
                -- do so. Nvim does not allow syncing registers 0 and 1 without
                -- overwriting the unnamed register. Thus, ddp would not be possible.
                sync_deletes = false,
                -- syncs the unnamed register with the first buffer entry from tmux.
                sync_unnamed = true,
            },
            navigation = {
                -- cycles to opposite pane while navigating into the border
                cycle_navigation = true,
                -- enables default keybindings (C-hjkl) for normal mode
                enable_default_keybindings = false,
                -- prevents unzoom tmux when navigating beyond vim border
                persist_zoom = true,
            },
            resize = {
                -- enables default keybindings (A-hjkl) for normal mode
                enable_default_keybindings = false,
                -- sets resize steps for x axis
                resize_step_x = 1,
                -- sets resize steps for y axis
                resize_step_y = 1,
            },
        }
    )

    wk.register(
        {
            ["<C-j>"] = {D.ithunk(tmux.move_bottom), "Move to below window/pane"},
            ["<C-k>"] = {D.ithunk(tmux.move_top), "Move to above window/pane"},
            ["<C-h>"] = {D.ithunk(tmux.move_left), "Move to left window/pane"},
            ["<C-l>"] = {D.ithunk(tmux.move_right), "Move to right window/pane"},
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           Move                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.move()
    -- Move selected text up down

    wk.register(
        {
            ["J"] = {":MoveBlock(1)<CR>", "Move selected text down"},
            ["K"] = {":MoveBlock(-1)<CR>", "Move selected text up"},
        },
        {mode = "x"}
    )

    wk.register(
        {
            ["<C-j>"] = {"<C-o><Cmd>MoveLine(1)<CR>", "Move line down"},
            ["<C-k>"] = {"<C-o><Cmd>MoveLine(-1)<CR>", "Move line up"},
        },
        {mode = "i"}
    )

    wk.register(
        {
            ["<C-S-l>"] = {":MoveHChar(1)<CR>", "Move character one left"},
            ["<C-S-h>"] = {":MoveHChar(-1)<CR>", "Move character one right"},
            ["<C-S-j>"] = {":MoveLine(1)<CR>", "Move line down"},
            ["<C-S-k>"] = {":MoveLine(-1)<CR>", "Move line up"},
        },
        {mode = "n"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Specs                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.specs()
    local specs = D.npcall(require, "specs")
    if not specs then
        return
    end

    specs.setup(
        {
            show_jumps = true,
            ---@diagnostic disable-next-line: param-type-mismatch
            min_jump = fn.winheight("%"),
            popup = {
                delay_ms = 0, -- delay before popup displays
                inc_ms = 20,  -- time increments used for fade/resize effects
                blend = 20,   -- starting blend, between 0-100 (fully transparent), see :h winblend
                width = 20,
                winhl = "PMenu",
                fader = specs.linear_fader,
                resizer = specs.shrink_resizer,
            },
            ignore_filetypes = {D.vec2tbl(BLACKLIST_FT)},
            ignore_buftypes = {nofile = true},
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        ScratchPad                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.scratchpad()
    g.scratchpad_autostart = 0
    g.scratchpad_autosize = 0
    g.scratchpad_autofocus = 1
    g.scratchpad_textwidth = 80
    g.scratchpad_minwidth = 12
    g.scratchpad_location = "~/.cache/scratchpad"
    -- g.scratchpad_daily = 0
    -- g.scratchpad_daily_location = '~/.cache/scratchpad_daily.md'
    -- g.scratchpad_daily_format = '%Y-%m-%d'

    map("n", "<Leader>sc", "<cmd>lua require'scratchpad'.invoke()<CR>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Paperplanes                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.paperplanes()
    -- paste.rs
    -- post_string(string, meta, cb)
    -- post_range(buffer, start, end, cb)
    -- post_selection(cb)
    -- post_buffer(buffer, cb)

    -- Command: PP

    local paperplanes = D.npcall(require, "paperplanes")
    if not paperplanes then
        return
    end

    paperplanes.setup(
        {
            register = "+",
            provider = "paste.rs",
            provider_options = {},
            notifier = vim.notify,
            cmd = "curl",
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Colorizer                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.colorizer()
    local colorizer = D.npcall(require, "colorizer")
    if not colorizer then
        return
    end

    colorizer.setup(
        {
            filetypes = {
                "conf",
                "css",
                "dosini",
                "gitconfig",
                "ini",
                "javascript",
                "json",
                "lua",
                "markdown",
                "noice",
                "python",
                "ron",
                "sh",
                "tmux",
                "toml",
                "typescript",
                "typescriptreact",
                "vim",
                "vimwiki",
                "xdefaults",
                "xml",
                "yaml",
                "zsh",
            },
            user_default_options = {
                RGB = true,                                -- #RGB hex codes
                RRGGBB = true,                             -- #RRGGBB hex codes
                RRGGBBAA = true,                           -- #RRGGBBAA hex codes
                AARRGGBB = true,                           -- 0xAARRGGBB hex codes
                names = false,                             -- "Name" codes like Blue
                -- rgb_0x = false, -- 0xAARRGGBB hex codes
                rgb_fn = true,                             -- CSS rgb() and rgba() functions
                hsl_fn = true,                             -- CSS hsl() and hsla() functions
                css = false,                               -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn = false,                            -- Enable all CSS *functions*: rgb_fn, hsl_fn
                -- Available modes for `mode`: foreground, background, virtualtext
                mode = "background",                       -- Set the display mode.
                -- Available methods are false / true / "normal" / "lsp" / "both"
                tailwind = true,                           -- Enable tailwind colors
                -- parsers can contain values used in |user_default_options|
                sass = {enable = true, parsers = {"css"}}, -- Enable sass colors
                virtualtext = "■",
                -- update color values even if buffer is not focused
                always_update = true,
            },
            -- all the sub-options of filetypes apply to buftypes
            buftypes = {"nofile"},
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Grepper                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.grepper()
    -- TODO: Figure out a way to change dir for GrepperOperator
    g.grepper = {
        dir = "repo,file",
        simple_prompt = 1,
        searchreg = 1,
        stop = 50000,
        tools = {"rg", "git"},
        rg = {
            grepprg = utils.list(
                {
                    "rg",
                    "--with-filename",
                    "--no-heading",
                    "--max-columns=200",
                    "--vimgrep",
                    "--smart-case",
                    "--color=never",
                    "--follow",
                    "--glob='!.git/**'",
                    "--glob='!target/**'",
                    "--glob='!node_modules/**'",
                    "--glob='!ccache/**'",
                },
                " "
            ),
            grepformat = "%f:%l:%c:%m,%f:%l:%m",
        },
    }

    -- $. = current file
    -- $+ = currently opened files
    map("n", "gs", "<Plug>(GrepperOperator)", {desc = "Grep project: operator"})
    map("x", "gs", "<Plug>(GrepperOperator)", {desc = "Grep project: operator"})
    map("n", "gsw", "<Plug>(GrepperOperator)iw", {desc = "Grep project: word"})
    map("n", "<Leader>rg", [[<Cmd>Grepper<CR>]], {desc = "Grep project: command"})
    -- map("n", "<Leader>rl", [[:GrepperRg ]], {silent = false}) -- This allows scrolling back in history

    augroup(
        "Grepper",
        {
            event = "User",
            pattern = "Grepper",
            nested = true,
            command = function()
                -- \%# = cursor position
                fn.setqflist({}, "r", {context = {bqf = {pattern_hl = [[\%#]] .. nvim.reg["/"]}}})
            end,
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Registers                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.registers()
    local registers = D.npcall(require, "registers")
    if not registers then
        return
    end

    registers.setup(
        {
            show = '*+"-/_=#%.0123456789abcdefghijklmnopqrstuvwxyz:',
            show_empty = true,
            register_user_command = true,
            system_clipboard = true,
            trim_whitespace = true,
            hide_only_whitespace = true,
            show_register_types = true,
            bind_keys = {
                normal = registers.show_window({mode = "motion"}),
                visual = registers.show_window({mode = "motion"}),
                insert = registers.show_window({mode = "insert"}),
                registers = registers.apply_register({delay = 0.1}),
                return_key = registers.apply_register(),
                escape = registers.close_window(),
                ctrl_n = registers.move_cursor_down(),
                ctrl_p = registers.move_cursor_up(),
                ctrl_j = registers.move_cursor_down(),
                ctrl_k = registers.move_cursor_up(),
                -- Clear the register of the highlighted line when pressing <DEL>
                delete = registers.clear_highlighted_register(),
                -- Clear the register of the highlighted line when pressing <BS>
                backspace = registers.clear_highlighted_register(),
            },
            events = {
                -- When a register line is highlighted, show a preview in the main buffer with how
                -- the register will be applied, but only if the register will be inserted or pasted
                on_register_highlighted = registers.preview_highlighted_register(
                    {if_mode = {"insert", "paste"}}
                ),
            },
            symbols = {
                newline = "⏎",
                space = " ",
                tab = "‣",
                register_type_charwise = "ᶜ",
                register_type_linewise = "ˡ",
                register_type_blockwise = "ᵇ",
            },
            window = {
                max_width = 100,
                highlight_cursorline = true,
                border = style.current.border,
                transparency = 10,
            },
            sign_highlights = {
                cursorline = "Visual",
                selection = "Constant",
                default = "Function",
                unnamed = "Statement",
                read_only = "Type",
                expression = "Exception",
                black_hole = "Error",
                alternate_buffer = "Operator",
                last_search = "Tag",
                delete = "Special",
                yank = "Delimiter",
                history = "Number",
                named = "Todo",
            },
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                            LF                            │
-- ╰──────────────────────────────────────────────────────────╯
function M.lf()
    g.lf_map_keys = 0
    g.lf_replace_netrw = 1

    map("n", "<C-A-u>", ":Lf<CR>")
end

function M.lfnvim()
    local lf = D.npcall(require, "lf")
    if not lf then
        return
    end

    g.lf_netrw = 1

    lf.setup(
        {
            escape_quit = true,
            focus_on_open = true,
            border = style.current.border,
            highlights = {
                NormalFloat = {link = "Normal"},
                FloatBorder = {guifg = require("kimbox.colors").magenta},
            },
        }
    )

    map("n", "<A-o>", ":Lfnvim<CR>")
    -- map("n", "<A-y>", ":Lf<CR>")
    -- map("n", "<A-o>", ":Lfnvim<CR>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       open-browser                       │
-- ╰──────────────────────────────────────────────────────────╯
function M.open_browser()
    wk.register(
        {
            -- ["gx"] = {":lua require('functions').open_link()<CR>", "Open link or file under cursor"},
            ["<Leader>oo"] = {"<Plug>(openbrowser-open)", "Open link under cursor"},
            ["<Leader>os"] = {"<Plug>(openbrowser-search)", "Search under cursor"},
            ["gf"] = {":lua require('functions').open_path()<CR>", "Open path under cursor"},
        }
    )

    wk.register(
        {
            ["<LocalLeader>?"] = {"<Plug>(openbrowser-search)", "Search under cursor"},
        },
        {mode = "x"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       LinkVisitor                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.link_visitor()
    local lv = D.npcall(require, "link-visitor")
    if not lv then
        return
    end

    lv.setup(
        {
            open_cmd = "handlr open",
            silent = true,             -- disable all prints
            skip_confirmation = false, -- Skip the confirmation step, default: false
        }
    )

    map("n", "gx", D.ithunk(lv.link_under_cursor), {desc = "Link under cursor"})
    map("n", "gw", D.ithunk(lv.link_nearest), {desc = "Link nearest"})
    -- map("n", "gw", D.ithunk(lv.link_near_cursor), {desc = "Link near cursor"})

    local function link_visitor_map(bufnr)
        bmap(bufnr, "n", "K", D.ithunk(lv.link_under_cursor), {desc = "Link under cursor"})
        bmap(bufnr, "n", "M", D.ithunk(lv.link_near_cursor), {desc = "Link near cursor"})
    end

    augroup(
        "lmb__LinkVisitor",
        {
            event = "User",
            pattern = "CocOpenFloat",
            command = function()
                local winid = g.coc_last_float_win
                if winid and api.nvim_win_is_valid(winid) then
                    local bufnr = api.nvim_win_get_buf(winid)
                    api.nvim_buf_call(
                        bufnr,
                        function()
                            link_visitor_map(bufnr)
                        end
                    )
                end
            end,
        },
        {
            event = "WinEnter",
            pattern = "*",
            command = function(args)
                local bufnr = args.buf
                if vim.bo[bufnr].ft == "crates.nvim" then
                    api.nvim_buf_call(
                        bufnr,
                        function()
                            link_visitor_map(bufnr)
                        end
                    )
                end
            end,
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         urlview                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.urlview()
    local urlview = D.npcall(require, "urlview")
    if not urlview then
        return
    end

    local actions = require("urlview.actions")
    actions["handlr"] = function(raw_url)
        fn.system(("handlr open %q"):format(raw_url))
    end

    urlview.setup(
        {
            -- Prompt title (`<context> <default_title>`, e.g. `Buffer Links:`)
            default_title = "Links:",
            -- Default picker to display links with
            -- Options: "native" (vim.ui.select) or "telescope"
            default_picker = "native",
            -- Set the default protocol for us to prefix URLs with if they don't start with http/https
            default_prefix = "https://",
            -- Command or method to open links with
            -- Options: "netrw", "system" (default OS browser); or "firefox", "chromium" etc.
            -- By default, this is "netrw", or "system" if netrw is disabled
            default_action = "handlr", -- "clipboard",
            -- Ensure links shown in the picker are unique (no duplicates)
            unique = true,
            -- Ensure links shown in the picker are sorted alphabetically
            sorted = true,
            -- Minimum log level (recommended at least `vim.log.levels.WARN` for error detection warnings)
            log_level_min = log.levels.INFO,
            -- Keymaps for jumping to previous / next URL in buffer
            jump = {
                prev = "[u",
                next = "]u",
            },
        }
    )

    wk.register(
        {
            ["[u"] = "Previous URL",
            ["]u"] = "Next URL",
        }
    )

    -- Examples:
    -- :UrlView buffer bufnr=1
    -- :UrlView file filepath=/etc/hosts picker=telescope
    -- :UrlView packer sorted=false
    map("n", "<LocalLeader>x", "UrlView", {cmd = true})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         DevIcons                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.devicons()
    local devicons = D.npcall(require, "nvim-web-devicons")
    if not devicons then
        return
    end

    devicons.set_icon(
        {
            scratchpad = {
                icon = "",
                color = "#6d8086",
                name = "Scratchpad",
            },
            NeogitStatus = {
                icon = "",
                color = "#F14C28",
                name = "BranchCycle",
            },
            org = {
                icon = "◉",
                color = "#75A899",
                name = "Org",
            },
            sol = {
                icon = "♦",
                color = "#a074c4",
                name = "Sol",
            },
            sh = {
                icon = "",
                color = "#89e051",
                cterm_color = "113",
                name = "Sh",
            },
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                        NerdIcons                         │
--  ╰──────────────────────────────────────────────────────────╯
function M.nerdicons()
    local nerd = D.npcall(require, "nerdicons")
    if not nerd then
        return
    end

    nerd.setup(
        {
            border = style.current.border, -- Border
            prompt = " ",               -- Prompt Icon
            preview_prompt = " ",       -- Preview Prompt Icon
            up = "<C-k>",                  -- Move up in preview
            down = "<C-j>",                -- Move down in preview
            copy = "<C-y>",                -- Copy to the clipboard
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          GHLine                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.ghline()
    wk.register(
        {
            ["<Leader>go"] = {"<Plug>(gh-repo)", "Open git repo"},
            ["<Leader>gL"] = {"<Plug>(gh-line)", "Open git line"},
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         LazyGit                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.lazygit()
    g.lazygit_floating_window_winblend = 0                        -- transparency of floating window
    -- g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    g.lazygit_floating_window_corner_chars = {"╭", "╮", "╰", "╯"} -- customize lazygit popup window corner
    -- g.lazygit_floating_window_use_plenary = 1 -- use plenary.nvim to manage floating window if available
    -- g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

    -- autocmd(
    --     {
    --         event = "BufEnter",
    --         pattern = "*",
    --         command = function()
    --             require("lazygit.utils").project_root_dir()
    --         end
    --     }
    -- )

    require("telescope").load_extension("lazygit")
    map("n", "<Leader>lg", ":LazyGit<CR>", {silent = true})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Git Conflict                       │
-- ╰──────────────────────────────────────────────────────────╯
function M.git_conflict()
    local conflict = D.npcall(require, "git-conflict")
    if not conflict then
        return
    end

    conflict.setup(
        {
            {
                default_mappings = false,
                disable_diagnostics = false, -- will disable diagnostics while conflicted
                highlights = {
                    incoming = "DiffText",
                    current = "DiffAdd",
                },
            },
        }
    )

    -- hl.plugin(
    --     "GitConflict",
    --     {
    --         GitConflictCurrent = {link = "DiffAdd"},
    --         GitConflictIncoming = {link = "DiffText"},
    --         GitConflictAncestor = {link = "DiffChange"}
    --     }
    -- )

    augroup(
        "lmb__GitConflict",
        {
            event = "User",
            pattern = "GitConflictDetected",
            command = function()
                local bufnr = api.nvim_get_current_buf()
                local bufname = api.nvim_buf_get_name(bufnr)

                -- Why does this need to be deferred? There is an error otherwise
                vim.defer_fn(
                    function()
                        log.warn(
                            ("Conflict detected in %s"):format(fs.basename(bufname)),
                            {title = "GitConflict"}
                        )
                    end,
                    100
                )

                bmap(bufnr, "n", "co", "<Plug>(git-conflict-ours)", {desc = "Conflict: ours"})
                bmap(bufnr, "n", "cb", "<Plug>(git-conflict-both)", {desc = "Conflict: both"})
                bmap(bufnr, "n", "ct", "<Plug>(git-conflict-theirs)", {desc = "Conflict: theirs"})
                bmap(bufnr, "n", "c0", "<Plug>(git-conflict-none)", {desc = "Conflict: none"})
                bmap(
                    bufnr,
                    "n",
                    "[n",
                    "<Plug>(git-conflict-next-conflict)",
                    {desc = "Next conflict"}
                )
                bmap(
                    bufnr,
                    "n",
                    "]n",
                    "<Plug>(git-conflict-prev-conflict)",
                    {desc = "Previous conflict"}
                )
            end,
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Projects                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.project()
    -- require("project_nvim").get_recent_projects()

    -- Detection Methods
    -- =src                => Specify root
    -- plain name          => Has a certain directory or file (may be glob
    -- ^fixtures           => Has certain directory as ancestory
    -- >Latex              => Has a certain directory as direct ancestor
    -- !=extras !^fixtures => Exclude pattern

    local project = D.npcall(require, "project_nvim")
    if not project then
        return
    end

    project.setup(
        {
            -- Manual mode doesn't automatically change your root directory, so you have
            -- the option to manually do so using `:ProjectRoot` command.
            manual_mode = false,
            -- Methods of detecting the root directory. **"lsp"** uses the native neovim
            -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
            -- order matters: if one is not detected, the other is used as fallback. You
            -- can also delete or rearangne the detection methods.
            detection_methods = {"lsp", "pattern"},
            -- All the patterns used to detect root dir, when **"pattern"** is in
            -- detection_methods
            patterns = {".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json"},
            -- Table of lsp clients to ignore by name
            -- eg: { "efm", ... }
            ignore_lsp = {},
            -- Don't calculate root dir on specific directories
            -- Ex: { "~/.cargo/*", ... }
            exclude_dirs = {},
            -- Show hidden files in telescope
            show_hidden = false,
            -- When set to false, you will get a message when project.nvim changes your
            -- directory.
            silent_chdir = true,
            -- What scope to change the directory, valid options are
            -- * global (default)
            -- * tab
            -- * win
            scope_chdir = "global",
            -- Path where project.nvim will store the project history for use in
            -- telescope
            datapath = lb.dirs.data,
        }
    )

    require("telescope").load_extension("projects")
    map("n", "<LocalLeader>p", "Telescope projects", {cmd = true})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       VisualMulti                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.visualmulti()
    g.VM_highlight_matches = ""
    g.VM_show_warnings = 0
    g.VM_silent_exit = 1
    g.VM_default_mappings = 0
    g.VM_set_statusline = 0 -- 3 if you want to use this STL
    g.VM_case_setting = "smart"
    g.VM_recursive_operations_at_cursors = true

    g.VM_Mono_hl = "DiffText"  -- ErrorMsg DiffText
    g.VM_Extend_hl = "DiffAdd" -- PmenuSel DiffAdd
    g.VM_Cursor_hl = "Visual"
    g.VM_Insert_hl = "DiffChange"

    -- g.VM_plugins_compatibilty = {
    --     plugin_name = {
    --         test = function()
    --         end,
    --         enable = ":PluginEnableCommand",
    --         disable = ":PluginDisableCommand"
    --     }
    -- }

    g.VM_custom_motions = {
        ["L"] = "$",
        ["H"] = "^",
    }

    g.VM_custom_noremaps = {
        ["=="] = "==",
        ["<<"] = "<<",
        [">>"] = ">>",
    }

    -- g.VM_custom_commands = {}

    g.VM_user_operators = {
        "dss",           -- delete surround automatic detection
        {css = 1},       -- change surround automatic detection
        {yss = 1},       -- surround line
        {cs = 2},        -- change surround
        {ds = 1},        -- delete surround
        "gc",            -- comment
        {ys = 3},
        {cr = 3},        -- FIX: change case
        {["<C-s>"] = 2}, -- FIX: substitute (replaces with second letter or only last line)
    }

    -- g.VM_custom_remaps = {
    --   -- ["<C-c>"] = "<Esc>"
    -- }

    -- https://github.com/mg979/vim-visual-multi/wiki/Special-commands
    -- https://github.com/mg979/vim-visual-multi/wiki/Mappings
    g.VM_maps = {
        Delete = "d",
        Yank = "y",
        ["Select Operator"] = "s",
        ["Find Operator"] = "m",
        Undo = "u",
        Redo = "U",
        ["Switch Mode"] = ",",
        i = "i",
        I = "I",
        ["Add Cursor At Pos"] = [[<Leader>\]],
        -- ["Add Cursor Up"] = "<A-S-i>",
        -- ["Add Cursor Down"] = "<A-S-o>",
        -- ["Select Cursor Up"] = "<C-S-Up>",
        -- ["Select Cursor Down"] = "<C-S-Down>",
        ["Slash Search"] = "g/",              -- Extend/move cursors with /
        ["Move Left"] = "<C-S-i>",            -- Move region left
        ["Move Right"] = "<C-S-o>",           -- Move region right
        -- Region cycling and removal
        ["Find Next"] = "]",                  -- Same as "n"
        ["Find Prev"] = "[",                  -- Same as "N"
        ["Goto Next"] = "}",                  -- Go to next selected region
        ["Goto Prev"] = "{",                  -- Go to prev selected region
        ["Seek Next"] = "<C-f>",              -- Fast go to next (from next page)
        ["Seek Prev"] = "<C-b>",              -- Fast go to previous (from previous page)
        ["Skip Region"] = "q",                -- Skip and find to next
        ["Remove Region"] = "Q",              -- Remove region under cursor
        ["Remove Last Region"] = "<Leader>q", -- Remove last added region
        ["Remove Every n Regions"] = "<Leader>R",
        -- Special Commands
        ["Surround"] = "S",
        ["Replace Pattern"] = "R",
        ["Increase"] = "<C-A-i>", -- Increase numbers
        ["Decrease"] = "<C-A-o>", -- Decrease numbers
        -- ["gIncrease"] = "<C-S-i>", -- Progressively increase numbers
        -- ["gDecrease"] = "<C-S-o>", -- Progressively decrease numbers
        -- ["Alpha-Increase"] = "<C-S-i>",
        -- ["Alpha-Decrease"] = "<C-S-o>",

        -- Commands
        ["Invert Direction"] = "o",             -- Change direction cursor is within region
        ["Shrink"] = "<",                       -- Reduce regions from the sides
        ["Enlarge"] = ">",                      -- Enlarge regions from the sides
        ["Transpose"] = "<Leader>t",            -- Transpose selected regions
        ["Align"] = "<Leader>a",                -- Align regions
        ["Align Char"] = "<Leader><",           -- Align by character
        ["Align Regex"] = "<Leader>>",          -- Align by regex
        ["Split Regions"] = "<Leader>s",        -- Subtract pattern from regions
        ["Filter Regions"] = "<Leader>f",       -- Filter regions by pattern/expression
        ["Merge Regions"] = "<Leader>m",        -- Merge overlapping regions
        ["Transform Regions"] = "<Leader>e",    -- Transform regions with expression
        ["Rewrite Last Search"] = "<Leader>r",  -- Rewrite last pattern to match current region
        ["Duplicate"] = "<Leader>d",            -- Duplicate regions
        ["One Per Line"] = "<Leader>L",         -- Keep at most one region per line
        ["Numbers"] = "<Leader>n",              -- Insert numbers before cursor
        ["Numbers Append"] = "<Leader>N",       -- Insert numbers after cursor
        ["Zero Numbers"] = "<Leader>0n",        -- Insert numbers before cursor
        ["Zero Numbers Append"] = "<Leader>0N", -- Insert numbers after cursor
        --
        ["Run Normal"] = "<Leader>z",
        ["Run Last Normal"] = "<Leader>Z",
        ["Run Visual"] = "<Leader>v",
        ["Run Last Visual"] = "<Leader>V",
        ["Run Ex"] = "<Leader>x",
        ["Run Last Ex"] = "<Leader>X",
        ["Run Macro"] = "<Leader>@",
        ["Run Dot"] = "<Leader>.",
        --
        ["Tools Menu"] = "<Leader>`",           -- Filter lines to buffer, etc
        ["Case Setting"] = "<Leader>c",         -- Cycle case setting ('scs' -> 'noic' -> 'ic')
        ["Case Conversion Menu"] = "<Leader>C", -- Works better in extend mode
        ["Search Menu"] = "<Leader>S",
        ["Show Registers"] = '<Leader>"',       -- Show VM registers in the command line
        ["Show Infoline"] = "<Leader>l",        -- Shows information about current regions and patterns and modes
        --
        ["Toggle Whole Word"] = "<Leader>w",    -- Toggle whole word search
        ["Toggle Block"] = "<Leader><BS>",
        ["Toggle Multiline"] = "<Leader>M",
        ["Toggle Single Region"] = "<Leader><CR>", -- Toggle single region mode
        ["Toggle Mappings"] = "<Leader><Leader>",  -- Toggle VM buffer mappings
        -- Visual
        ["Visual Subtract"] = "<Leader>s",         -- Remove visual from region
        ["Visual Find"] = "<Leader>f",             -- Find from visually selection region
        ["Visual Add"] = "<Leader>a",
        ["Visual All"] = "<Leader>A",
        -- Insert Mode
        ["I Arrow w"] = "<C-Right>",
        ["I Arrow b"] = "<C-Left>",
        ["I Arrow W"] = "<C-S-Right>",
        ["I Arrow B"] = "<C-S-Left>",
        ["I Arrow ge"] = "<C-Up>",
        ["I Arrow e"] = "<C-Down>",
        ["I Arrow gE"] = "<C-S-Up>",
        ["I Arrow E"] = "<C-S-Down>",
        -- ["I Prev"] = "<C-k>", -- Insert mode to go prev cursor
        -- ["I Next"] = "<C-j>", -- Insert mode to go next cursor
    }

    map("n", "<M-S-i>", "<Plug>(VM-Add-Cursor-Up)")
    map("n", "<M-S-o>", "<Plug>(VM-Add-Cursor-Down)")
    map("n", "<C-S-Up>", "<Plug>(VM-Select-Cursor-Up)")
    map("n", "<C-S-Down>", "<Plug>(VM-Select-Cursor-Down)")
    map("n", "<C-A-S-Right>", "<Plug>(VM-Select-l)")
    map("n", "<C-A-S-Left>", "<Plug>(VM-Select-h)")
    map("n", [[<Leader>\]], "<Plug>(VM-Add-Cursor-At-Pos)")

    map("n", "<Leader>/", "<Plug>(VM-Start-Regex-Search)")
    map("x", "<Leader>/", "<Plug>(VM-Visual-Regex)")
    map("n", "<C-n>", "<Plug>(VM-Find-Under)")
    map("x", "<C-n>", "<Plug>(VM-Find-Subword-Under)")

    map("n", "<Leader>A", "<Plug>(VM-Select-All)")
    map("x", "<Leader>A", "<Plug>(VM-Visual-All)")
    map("x", ";A", "<Plug>(VM-Visual-All)")
    map("x", ";a", "<Plug>(VM-Visual-Add)")
    map("x", ";F", "<Plug>(VM-Visual-Find)")
    map("x", ";C", "<Plug>(VM-Visual-Cursors)")

    map("n", "<Leader>gs", "<Plug>(VM-Reselect-Last)", {desc = "VM: Select last"})
    map("n", "g/", "<Cmd>VMSearch<CR>", {desc = "Start VM with last search"})

    command(
        "VMFixStl",
        function()
            cmd.VMClear()
            vim.o.statusline = "%{%v:lua.require'lualine'.statusline()%}"
        end
    )

    local vm = require("common.vm")

    augroup(
        "VisualMulti",
        {
            event = "User",
            pattern = "visual_multi_start",
            command = D.ithunk(vm.start),
        },
        {
            event = "User",
            pattern = "visual_multi_exit",
            command = D.ithunk(vm.exit),
        },
        {
            event = "User",
            pattern = "visual_multi_mappings",
            command = D.ithunk(vm.mappings),
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Neodev                          │
--  ╰──────────────────────────────────────────────────────────╯
function M.neodev()
    local neodev = D.npcall(require, "neodev")
    if not neodev then
        return
    end

    neodev.setup(
        {
            library = {
                enabled = false, -- when not enabled, neodev will not change any settings to the LSP server
                -- these settings will be used for your Neovim config directory
                runtime = false, -- runtime path
                types = true,    -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
                plugins = true,  -- installed opt or start plugins in packpath
                -- you can also specify the list of plugins to make available as a workspace library
                -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
            },
            setup_jsonls = false, -- configures jsonls to provide completion for project specific .luarc.json files
            -- for your Neovim config directory, the config.library settings will be used as is
            -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
            -- for any other directory, config.library.enabled will be set to false
            --
            ---@diagnostic disable-next-line: unused-local
            override = function(root_dir, options)
            end,
            -- With lspconfig, Neodev will automatically setup your lua-language-server
            -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
            -- in your lsp start options
            lspconfig = false,
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Fundo                           │
--  ╰──────────────────────────────────────────────────────────╯
function M.fundo()
    local fundo = D.npcall(require, "fundo")
    if not fundo then
        return
    end

    fundo.setup(
        {
            archives_dir = ("%s/%s"):format(lb.dirs.cache, "fundo"),
            limit_archives_size = 512,
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           CCLS                           │
--  ╰──────────────────────────────────────────────────────────╯
function M.ccls()
    g.ccls_close_on_jump = true
    g.ccls_levels = 1
    g.ccls_size = 50
    g.ccls_position = "botright"
    g.ccls_orientation = "horizontal"
    g.ccls_float_width = 50
    g.ccls_float_height = 20
    g.yggdrasil_no_default_maps = 1

    nvim.autocmd.lmb__Ccls = {
        event = "FileType",
        pattern = "yggdrasil",
        command = function(args)
            local bmap = function(...)
                bmap(0, ...)
            end
            bmap("n", "o", "<Plug>(yggdrasil-toggle-node)", {desc = "Toggle CCLS tree"})
            bmap("n", "O", "<Plug>(yggdrasil-open-node)", {desc = "Open CCLS tree"})
            bmap("n", "Q", "<Plug>(yggdrasil-close-node)", {desc = "Close CCLS tree"})
            bmap("n", "<CR>", "<Plug>(yggdrasil-execute-node)", {desc = "Execute CCLS node"})
            bmap("n", "qq", ":q<CR>", {desc = "Close CCLS window"})
        end,
    }
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                       SmartColumn                        │
--  ╰──────────────────────────────────────────────────────────╯
function M.smartcolumn()
    local sc = D.npcall(require, "smartcolumn")
    if not sc then
        return
    end

    sc.setup(
        {
            colorcolumn = 100,
            disabled_filetypes = BLACKLIST_FT,
            custom_colorcolumn = {},
            limit_to_window = false,
        }
    )
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           vve                            │
--  ╰──────────────────────────────────────────────────────────╯
-- function M.vve()
--     wk.register({
--         ["<Leader>e"] = {
--             a = "Encode: ASCII (op)",
--             b = "Encode: binary (op)",
--             B = "Encode: base64 (op)",
--             e = "Encode: HTML (op)",
--         }
--     })
-- end

return M
