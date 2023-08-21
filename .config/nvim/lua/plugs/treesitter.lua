---@module 'plugs.treesitter'
local M = {}

local F = Rc.F
if not F.npcall(require, "nvim-treesitter") then
    return
end

local it = F.ithunk
local hl = Rc.shared.hl
local map = Rc.api.map
local bmap = Rc.api.bmap
local command = Rc.api.command
local op = Rc.lib.op
local I = Rc.icons

local wk = require("which-key")

local cmd = vim.cmd
local g = vim.g
local fn = vim.fn
local api = vim.api

---@type TSPlugin
local ts
local queries, parsers, configs

---Check whether there are text-objects available
---@param ft string
---@return boolean
function M.has_textobj(ft)
    return queries.get_query(parsers.ft_to_lang(ft), "textobjects") ~= nil and true or false
end

---Perform an action on a textobject
---@param obj string textobject to act on
---@param mode '"x"'|'"o"' visual/operator pending mode
---@param inner? boolean act on inner or outer object
function M.textobj(obj, mode, inner)
    require("nvim-treesitter.textobjects.select").select_textobject(
        ("@%s.%s"):format(obj, F.if_expr(inner, "inner", "outer")),
        mode
    )
end

---Perform an action on a textobject (i.e., select or operator pending)
---@param obj string textobject to act on
---@param inner boolean act on inner or outer object
---@param visual boolean visual mode or operator pending
---@return boolean
function M.do_textobj(obj, inner, visual)
    local ret = false
    if queries.has_query_files(vim.bo.ft, "textobjects") then
        M.textobj(obj, F.if_expr(visual, "x", "o"), inner)
        ret = true
    end
    return ret
end

function M.hijack_synset()
    local ft = fn.expand("<amatch>")
    local bufnr = tonumber(fn.expand("<abuf>"))
    local lcount = api.nvim_buf_line_count(bufnr)
    local bytes = api.nvim_buf_get_offset(bufnr, lcount)

    if bytes / lcount < 500 then
        if ts.enable.ft[ft] then
            configs.reattach_module("highlight", bufnr)
            vim.defer_fn(function()
                pcall(configs.reattach_module, "textobjects.move", bufnr)
            end, 300)
        else
            vim.bo.syntax = ft
        end
    end
end

function M.ft_to_lang(ft)
    local result = vim.treesitter.language.get_lang(ft)
    if result then
        return result
    end

    ft = vim.split(ft, ".", {plain = true})[1]
    return vim.treesitter.language.get_lang(ft) or ft
end

local function gen_disable(field)
    return function(ft, bufnr)
        if
            ts.disable[field]:contains(ft)
            or api.nvim_buf_line_count(bufnr or 0) > (ts.max[field] or ts.max.hl)
            or Rc.api.buf.buf_get_size() > ts.max.fsize
        then
            return true
        end

        return false
    end
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Setup `nvim-gps`
function M.setup_gps()
    cmd.packadd("nvim-gps")
    local gps = F.npcall(require, "nvim-gps")
    if not gps then
        return
    end

    gps.setup({
        enabled = ts.state.gps,
        disable_icons = false,
        icons = {
            ["action-name"] = " ",
            ["array-name"] = " ",
            ["augment-path"] = " ",
            ["boolean-name"] = "ﰰﰴ ",
            ["class-name"] = " ",
            ["container-name"] = "ﮅ ", -- 
            ["date-name"] = " ",
            ["date-time-name"] = " ",
            ["float-name"] = " ",
            ["function-name"] = " ",
            ["grouping-name"] = " ",
            ["hook-name"] = "ﯠ ",
            ["identity-name"] = " ",
            ["inline-table-name"] = " ",
            ["integer-name"] = "# ", -- 
            ["label-name"] = " ",
            ["leaf-list-name"] = " ",
            ["leaf-name"] = " ",
            ["list-name"] = " ",
            ["mapping-name"] = " ",
            ["method-name"] = " ",
            ["module-name"] = " ", -- 
            ["null-name"] = "[] ",
            ["number-name"] = "# ",
            ["object-name"] = " ",
            ["sequence-name"] = " ",
            ["string-name"] = " ",
            ["table-name"] = " ",
            ["tag-name"] = "炙",
            ["time-name"] = " ",
            ["title-name"] = "# ",
            ["typedef-name"] = " ",
        },
        separator = " » ", --  淪輪‣ »
        depth = 4,
        depth_limit_indicator = "..",
    })
end

---Setup `hlargs.nvim`
function M.setup_hlargs()
    cmd.packadd("hlargs.nvim")
    -- cmd.packadd("kimbox")
    local hlargs = F.npcall(require, "hlargs")
    if not hlargs then
        return
    end

    hlargs.setup({
        excluded_filetypes = ts.disable.hlargs,
        color = g.colors_name == "kimbox" and require("kimbox.colors").salmon or "#DE9A4E",
        hl_priority = 10000,
        paint_arg_declarations = true,
        paint_arg_usages = true,
        paint_catch_blocks = {declarations = true, usages = true},
        extras = {named_parameters = true},
        excluded_argnames = {
            declarations = {
                "use",
                "use_rocks",
                "_",
                "self",
                "super",
                "__attribute__",
                "noreturn",
                "maybe_unused",
                "deprecated",
                "nodiscard",
            },
            usages = {
                python = {"cls", "self"},
                go = {"_"},
                rust = {"_", "self"},
                zig = {"_", "self"},
                vim = {"self"},
                lua = {"_", "self", "use", "use_rocks", "super"},
                c = {
                    "__attribute__",
                    "noreturn",
                    "maybe_unused",
                    "deprecated",
                    "nodiscard",
                },
            },
        },
        performance = {
            parse_delay = 1,
            slow_parse_delay = 50,
            max_iterations = 400,
            max_concurrent_partial_parses = 30,
            debounce = {
                partial_parse = 3,
                partial_insert_mode = 100,
                total_parse = 700,
                slow_parse = 5000,
            },
        },
    })
end

---Setup `nvim-ts-autotag`
function M.setup_autotag()
    cmd.packadd("nvim-ts-autotag")
    local autotag = F.npcall(require, "nvim-ts-autotag")
    if not autotag then
        return
    end

    autotag.setup({
        filetypes = ts.enable.autotag,
        skip_tags = {
            "area",
            "base",
            "br",
            "col",
            "command",
            "embed",
            "hr",
            "img",
            "slot",
            "input",
            "keygen",
            "link",
            "meta",
            "param",
            "source",
            "track",
            "wbr",
            "menuitem",
        },
    })
end

---Setup `aerial`
function M.setup_aerial()
    -- cmd.packadd("aerial.nvim")
    local aerial = F.npcall(require, "aerial")
    if not aerial then
        return
    end

    local update_delay = 450

    aerial.setup({
        -- Priority list of preferred backends for aerial.
        -- This can be a filetype map (see :help aerial-filetype-map)
        backends = {"treesitter", "markdown", "man" --[[ "lsp" ]]},
        layout = {
            -- These control the width of the aerial window.
            -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a list of mixed types.
            -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
            max_width = {40, 0.2},
            width = nil,
            min_width = 10,
            -- key-value pairs of window-local options for aerial window (e.g. winhl)
            win_opts = {},
            -- Determines the default direction to open the aerial window. The 'prefer'
            -- options will open the window in the other direction *if* there is a
            -- different buffer in the way of the preferred direction
            -- Enum: prefer_right, prefer_left, right, left, float
            default_direction = "prefer_right",
            -- Determines where the aerial window will be opened
            --   edge   - open aerial at the far right/left of the editor
            --   window - open aerial to the right/left of the current window
            placement = "window",
            -- Preserve window size equality with (:help CTRL-W_=)
            preserve_equality = false,
        },
        -- Determines how the aerial window decides which buffer to display symbols for
        --   window - aerial window will display symbols for the buffer in the window from which it was opened
        --   global - aerial window will display symbols for the current window
        attach_mode = "window",
        -- List of enum values that configure when to auto-close the aerial window
        --   unfocus       - close aerial when you leave the original source window
        --   switch_buffer - close aerial when you change buffers in the source window
        --   unsupported   - close aerial when attaching to a buffer that has no symbol source
        close_automatic_events = {},
        -- Set to false to remove the default keybindings for the aerial buffer
        -- default_bindings = true,

        -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
        -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
        -- Additionally, if it is a string that matches "actions.<name>",
        -- it will use the mapping at require("aerial.actions").<name>
        keymaps = {
            ["<"] = "actions.tree_decrease_fold_level",
            [">"] = "actions.tree_increase_fold_level",
        },
        -- When true, don't load aerial until a command or function is called
        -- Defaults to true, unless `on_attach` is provided, then it defaults to false
        lazy_load = false,
        -- Disable aerial on files with this many lines
        disable_max_lines = ts.max.aerial,
        -- Disable aerial on files this size or larger (in bytes)
        disable_max_size = 1000000, -- Default 2MB
        -- A list of all symbols to display. Set to false to display all symbols.
        -- This can be a filetype map (see :help aerial-filetype-map)
        -- To see all available values, see :help SymbolKind
        -- filter_kind = false,
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
            "Type",
            --
            "Field",
            "Array",
        },
        -- Determines line highlighting mode when multiple splits are visible.
        -- split_width   Each open window will have its cursor location marked in the
        --               aerial buffer. Each line will only be partially highlighted
        --               to indicate which window is at that location.
        -- full_width    Each open window will have its cursor location marked as a
        --               full-width highlight in the aerial buffer.
        -- last          Only the most-recently focused window will have its location
        --               marked in the aerial buffer.
        -- none          Do not show the cursor locations in the aerial window.
        highlight_mode = "split_width",
        -- Highlight the closest symbol if the cursor is not exactly on one.
        highlight_closest = true,
        -- Highlight the symbol in the source buffer when cursor is in the aerial win
        highlight_on_hover = true,
        -- When jumping to a symbol, highlight the line for this many ms.
        -- Set to false to disable
        highlight_on_jump = 300,
        -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
        -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
        -- default collapsed icon. The default icon set is determined by the
        -- "nerd_font" option below.
        -- If you have lspkind-nvim installed, it will be the default icon set.
        -- This can be a filetype map (see :help aerial-filetype-map)
        icons = {},
        -- Control which windows and buffers aerial should ignore.
        -- If attach_mode is "global", focusing an ignored window/buffer will
        -- not cause the aerial window to update.
        -- If open_automatic is true, focusing an ignored window/buffer will not
        -- cause an aerial window to open.
        -- If open_automatic is a function, ignore rules have no effect on aerial
        -- window opening behavior; it's entirely handled by the open_automatic
        -- function.
        ignore = {
            -- Ignore unlisted buffers. See :help buflisted
            unlisted_buffers = false,
            -- List of filetypes to ignore.
            filetypes = ts.disable.aerial,
            -- Ignored buftypes.
            -- Can be one of the following:
            -- false or nil - No buftypes are ignored.
            -- "special"    - All buffers other than normal buffers are ignored.
            -- table        - A list of buftypes to ignore. See :help buftype for the
            --                possible values.
            -- function     - A function that returns true if the buffer should be
            --                ignored or false if it should not be ignored.
            --                Takes two arguments, `bufnr` and `buftype`.
            buftypes = "special",
            -- Ignored wintypes.
            -- Can be one of the following:
            -- false or nil - No wintypes are ignored.
            -- "special"    - All windows other than normal windows are ignored.
            -- table        - A list of wintypes to ignore. See :help win_gettype() for the
            --                possible values.
            -- function     - A function that returns true if the window should be
            --                ignored or false if it should not be ignored.
            --                Takes two arguments, `winid` and `wintype`.
            wintypes = "special",
        },
        -- Use symbol tree for folding. Set to true or false to enable/disable
        -- 'auto' will manage folds if your previous foldmethod was 'manual'
        -- manage_folds = true,
        -- manage_folds = { ["_"] = true },
        manage_folds = false,
        -- When you fold code with za, zo, or zc, update the aerial tree as well.
        -- Only works when manage_folds = true
        link_folds_to_tree = true,
        -- Fold code when you open/collapse symbols in the tree.
        -- Only works when manage_folds = true
        link_tree_to_folds = false,
        -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
        -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
        nerd_font = "auto",
        -- Call this function when aerial attaches to a buffer.
        -- Useful for setting keymaps. Takes a single `bufnr` argument.
        on_attach = nil,
        -- Call this function when aerial first sets symbols on a buffer.
        -- Takes a single `bufnr` argument.
        on_first_symbols = nil,
        -- Automatically open aerial when entering supported buffers.
        -- This can be a function (see :help aerial-open-automatic)
        open_automatic = false,
        -- Run this command after jumping to a symbol (false will disable)
        post_jump_cmd = "normal! zz",
        -- When true, aerial will automatically close after jumping to a symbol
        close_on_select = false,
        -- The autocmds that trigger symbols update (not used for LSP backend)
        update_events = "TextChanged,InsertLeave",
        -- Show box drawing characters for the tree hierarchy
        show_guides = true,
        -- Customize the characters used when show_guides = true
        guides = {
            -- When the child item has a sibling below it
            mid_item = "├─",
            -- When the child item is the last in the list
            last_item = "└─",
            -- When there are nested child guides to the right
            nested_top = "│ ",
            -- Raw indentation
            whitespace = "  ",
        },
        -- Options for opening aerial in a floating win
        float = {
            -- Controls border appearance. Passed to nvim_open_win
            border = Rc.style.border,
            -- Determines location of floating window
            --   cursor - Opens float on top of the cursor
            --   editor - Opens float centered in the editor
            --   win    - Opens float centered in the window
            relative = "cursor",
            -- These control the height of the floating window.
            -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_height and max_height can be a list of mixed types.
            -- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
            max_height = 0.9,
            height = nil,
            min_height = {8, 0.1},
            ---@diagnostic disable-next-line:unused-local
            override = function(conf, source_winid)
                -- This is the config that will be passed to nvim_open_win.
                -- Change values here to customize the layout
                return conf
            end,
        },
        -- Options for the floating nav windows
        nav = {
            border = Rc.style.border,
            max_height = 0.9,
            min_height = {10, 0.1},
            max_width = 0.5,
            min_width = {0.2, 20},
            win_opts = {
                cursorline = true,
                winblend = 10,
            },
            -- Jump to symbol in source window when the cursor moves
            autojump = false,
            -- Show a preview of the code in the right column, when there are no child symbols
            preview = false,
            -- Keymaps in the nav window
            keymaps = {
                ["<CR>"] = "actions.jump",
                ["<2-LeftMouse>"] = "actions.jump",
                ["<C-v>"] = "actions.jump_vsplit",
                ["<C-s>"] = "actions.jump_split",
                ["h"] = "actions.left",
                ["l"] = "actions.right",
                ["<C-c>"] = "actions.close",
            },
        },
        lsp = {
            -- Fetch document symbols when LSP diagnostics update.
            -- If false, will update on buffer changes.
            diagnostics_trigger_update = true,
            -- Set to false to not update the symbols when there are LSP errors
            update_when_errors = true,
            -- How long to wait (in ms) after a buffer change before updating
            -- Only used when diagnostics_trigger_update = false
            update_delay = update_delay,
        },
        -- How long to wait (in ms) after a buffer change before updating
        treesitter = {update_delay = update_delay},
        markdown = {update_delay = update_delay},
        man = {update_delay = update_delay},
    })

    wk.register({
        ["<C-'>"] = {"<Cmd>AerialToggle<CR>", "Toggle Aerial"},
        ["<A-'>"] = {"<Cmd>AerialNavToggle<CR>", "Toggle AerialNav"},
        ["[["] = {aerial.prev_up, "Prev main func (aerial)"},
        ["]]"] = {aerial.next_up, "Next main func (aerial)"},
        ["{"] = {aerial.prev, "Prev anon (aerial)"},
        ["}"] = {aerial.next, "Next anon (aerial)"},
    })

    wk.register({
        ["[["] = {aerial.prev_up, "Prev main func (aerial)"},
        ["]]"] = {aerial.next_up, "Next main func (aerial)"},
        ["{"] = {aerial.prev, "Prev anon (aerial)"},
        ["}"] = {aerial.next, "Next anon (aerial)"},
    }, {mode = "x"})

    -- require("telescope").load_extension("aerial")
end

---Setup `nvim_context_vt`
---Shows `-->` at the end of a block
function M.setup_context_vt()
    cmd.packadd("nvim_context_vt")
    local ctx = F.npcall(require, "nvim_context_vt")
    if not ctx then
        return
    end

    -- NvimContextVtToggle
    ctx.setup({
        enabled = ts.state.context_vt,
        prefix = "",
        highlight = "ContextVt",
        -- Disable virtual text for given filetypes
        disable_ft = ts.disable.context_vt,
        -- Disable display of virtual text below blocks for indentation based langs
        disable_virtual_lines = false,
        disable_virtual_lines_ft = {"yaml", "python"},
        -- How many lines required after starting position to show virtual text
        ---@diagnostic disable-next-line: param-type-mismatch
        min_rows = fn.winheight("%") / 3,
        -- Same as above but only for spesific filetypes
        min_rows_ft = {},
        -- Custom virtual text node parser callback
        custom_parser = function(node, ft, _opts)
            if
                ts.disable.context_vt:contains(ft)
                or api.nvim_buf_line_count(0) > ts.max.context_vt
                or Rc.api.buf.buf_get_size() > ts.max.fsize
            then
                return nil
            end

            local nvim_utils = require("nvim_context_vt.utils")

            -- If you return `nil`, no virtual text will be displayed.
            if node:type() == "function" then
                return nil
            end

            -- This is the standard text
            return "--> " .. nvim_utils.get_node_text(node)[1]
        end,
        -- Custom node validator callback
        -- Default: nil
        -- custom_validator = function(node, ft, opts)
        --     -- Internally a node is matched against min_rows and configured targets
        --     local default_validator = require("nvim_context_vt.utils").default_validator
        --     if default_validator(node, ft) then
        --         -- Custom behaviour after using the internal validator
        --         if node:type() == "function" then
        --             return false
        --         end
        --     end
        --
        --     return true
        -- end,
        -- Custom node virtual text resolver callback
        -- Default: nil
        ---@diagnostic disable-next-line: unused-local
        custom_resolver = function(nodes, ft, opts)
            -- By default the last node is used
            return nodes[#nodes]
        end,
    })
end

--  ══════════════════════════════════════════════════════════════════════

function M.setup_rainbow()
    cmd.packadd("rainbow-delimiters.nvim")
    local delim = F.npcall(require, "rainbow-delimiters")
    if not delim then
        return
    end

    vim.g.rainbow_delimiters = {
        strategy = {
            [""] = function()
                if
                    api.nvim_buf_line_count(0) > ts.max.rainbow
                    or Rc.api.buf.buf_get_size() > ts.max.fsize
                then
                    return nil
                end
                return delim.strategy["global"]
            end,
            -- lua = delim.strategy["local"],
            -- vim = delim.strategy["local"],
        },
        query = {
            [""] = "rainbow-delimiters",
            latex = "rainbow-blocks",
            javascript = "rainbow-delimiters-react",
            -- javascript = "rainbow-parens",
            tsx = "rainbow-parens",
            -- lua = 'rainbow-blocks',
        },
        highlight = {
            "TSRainbowRed",
            "TSRainbowYellow",
            "TSRainbowBlue",
            "TSRainbowOrange",
            "TSRainbowGreen",
            "TSRainbowViolet",
            "TSRainbowCyan",
        },
        blacklist = ts.disable.rainbow,
        log = {
            file = Rc.dirs.state .. "/rainbow-delim.log",
            level = vim.log.levels.WARN,
        },
    }
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Setup a swapping plugin for non-treesitter filetypes
function M.setup_swap()
    -- nvim.autocmd.lmb__NonTreesitterSwap = {
    --     event = "FileType",
    --     pattern = ([[*\(%s\)\@<!]]):format(table.concat(vim.tbl_keys(ts.enable.ft), [[\|]])),
    --     command = function(a)
    --         local map = function(...)
    --             Rc.api.bmap(a.buf, ...)
    --         end
    --
    --         map({"n", "x"}, "vs", "<Plug>(swap-interactive)", {desc = "Swap: interactive"})
    --         map({"n", "x"}, "sv", "<Plug>(swap-interactive)", {desc = "Swap: interactive"})
    --         map("n", "s,", "<Plug>(swap-prev)", {desc = "Swap: previous"})
    --         map("n", "s.", "<Plug>(swap-next)", {desc = "Swap: next"})
    --         map("n", "sh", "<Plug>(swap-textobject-i)", {desc = "Swap: inner textobj"})
    --         map("n", "sl", "<Plug>(swap-textobject-a)", {desc = "Swap: outer textobj"})
    --     end,
    -- }

    bmap(0, {"n", "x"}, "vs", "<Plug>(swap-interactive)", {desc = "Swap: interactive"})
    bmap(0, {"n", "x"}, "sv", "<Plug>(swap-interactive)", {desc = "Swap: interactive"})
    bmap(0, "n", "s,", "<Plug>(swap-prev)", {desc = "Swap: previous"})
    bmap(0, "n", "s.", "<Plug>(swap-next)", {desc = "Swap: next"})
    bmap(0, "n", "sh", "<Plug>(swap-textobject-i)", {desc = "Swap: inner textobj"})
    bmap(0, "n", "sl", "<Plug>(swap-textobject-a)", {desc = "Swap: outer textobj"})
end

---Setup `iswap.nvim`
function M.setup_iswap()
    cmd.packadd("iswap.nvim")
    local iswap = F.npcall(require, "iswap")
    if not iswap then
        return
    end

    local colors = require("kimbox.colors")
    hl.set("ISwapSwap", {bg = colors.oni_violet})

    iswap.setup({
        keys = "asdfghjklqwert;",
        grey = "disable",
        hl_snipe = "ISwapSwap",
        hl_selection = "WarningMsg",
        flash_style = "simultaneous", -- sequential
        hl_flash = "ModeMsg",
        autoswap = true,
    })

    wk.register({
        ["vs"] = {"<Cmd>ISwap<CR>", "ISwap parameters"},
        ["sv"] = {"<Cmd>ISwap<CR>", "ISwap parameters"},
        ["so"] = {"<Cmd>ISwapNodeWith<CR>", "ISwap current node"},
        ["sc"] = {"<Cmd>ISwapNode<CR>", "ISwap picked nodes"},
        ["s,"] = {"<Cmd>ISwapNodeWithLeft<CR>", "ISwap left node"},
        ["s."] = {"<Cmd>ISwapNodeWithRight<CR>", "ISwap right node"},
        ["sh"] = {"<Cmd>ISwapWithLeft<CR>", "ISwap left"},
        ["sl"] = {"<Cmd>ISwapWithRight<CR>", "ISwap right"},
    })
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Setup a split-join plugin for non-treesitter filetypes
function M.setup_splitjoin()
    g.splitjoin_split_mapping            = ""
    g.splitjoin_join_mapping             = ""

    nvim.autocmd.lmb__NonTreesitterSplit = {
        event = "FileType",
        pattern = ([[*\(%s\)\@<!]]):format(table.concat(vim.tbl_keys(ts.enable.ft), [[\|]])),
        command = function(a)
            local map = function(...)
                Rc.api.bmap(a.buf, ...)
            end

            map("n", "gJ", "<Cmd>SplitjoinSplit<CR>", {desc = "Split: split"})
            map("n", "gS", "<Cmd>SplitjoinJoin<CR>", {desc = "Split: join"})
        end,
    }
end

---Setup `treesj`
function M.setup_treesj()
    cmd.packadd("treesj")
    local tsj = F.npcall(require, "treesj")
    if not tsj then
        return
    end

    local langs = require("treesj.langs")
    local lu = require("treesj.langs.utils")

    -- lu.merge_preset(langs.lua, {})
    langs.presets["lua"] = nil

    local langs_t = {
        -- unpack(langs.presets),
        lua = {
            table_constructor = lu.set_preset_for_dict({join = {space_in_brackets = false}}),
            arguments = lu.set_preset_for_args({
                split = {
                    recursive_ignore = {"arguments", "parameters", "table_constructor"},
                    recursive = true,
                },
            }),
            parameters = lu.set_preset_for_args(),
            block = lu.set_preset_for_non_bracket({
                split = {
                    recursive_ignore = {"arguments", "parameters"},
                },
            }),
            variable_declaration = {target_nodes = {"table_constructor", "block"}},
            assignment_statement = {target_nodes = {"table_constructor", "block"}},
            if_statement = {target_nodes = {"block"}},
            else_statement = {target_nodes = {"block"}},
            function_definition = {target_nodes = {"block"}},
            function_declaration = {
                target_nodes = {"block"},
                -- both = {non_bracket_node = true, recursive_ignore = {"arguments", "parameters"}},
                -- join = {
                --     space_in_brackets = true,
                --     force_insert = ";",
                --     no_insert_if = {lu.helpers.if_penultimate},
                -- },
            },
            function_call = {target_nodes = {"arguments"}},
            field = {target_nodes = {"table_constructor"}},
        },
        teal = {
            table_constructor = lu.set_preset_for_dict({join = {space_in_brackets = false}}),
            arguments = lu.set_preset_for_args({
                split = {
                    recursive_ignore = {"arguments", "table_constructor"},
                    recursive = true,
                },
            }),
            block = lu.set_preset_for_non_bracket({
                split = {
                    recursive_ignore = {"arguments"},
                },
            }),
            var_declaration = {target_nodes = {"table_constructor", "block"}},
            -- assignment_statement = {target_nodes = {"table_constructor", "block"}},
            if_statement = {target_nodes = {"block"}},
            else_block = {target_nodes = {"block"}},
            -- function_definition = {target_nodes = {"block"}},
            function_statement = {target_nodes = {"block"}},
            function_call = {target_nodes = {"arguments"}},
            field = {target_nodes = {"table_constructor"}},

        },
        zig = {
            InitList = lu.set_preset_for_dict(),
        },
        perl = {
            arguments = lu.set_preset_for_args({split = {last_separator = true}}),
            block = lu.set_preset_for_statement({
                split = {omit = {"semi_colon"}},
                join = {space_in_brackets = true, force_insert = ";"},
            }),
            call_expression = {target_nodes = {"arguments"}},
            function_definition = {target_nodes = {"block"}},
            if_statement = {target_nodes = {"block"}},
            elsif_clause = {target_nodes = {"block"}},
            else_clause = {target_nodes = {"block"}},
        },
    }

    tsj.setup({
        use_default_keymaps = false,
        check_syntax_error = true,
        max_join_length = 100,
        -- hold  = cursor follows the node/place on which it was called
        -- start = cursor jumps to the first symbol of the node being formatted
        -- end   = cursor jumps to the last symbol of the node being formatted
        cursor_behavior = "hold",
        notify = true,     -- notify about possible problems or not
        dot_repeat = true, -- use `dot` for repeat action
        langs = langs_t,
        -- langs = lu._prepare_presets(langs_t),
    })

    -- map("n", "gK", F.ithunk(tsj.split, {recursive = true}), {desc = "Spread: out"})
    map("n", "gJ", F.ithunk(tsj.split), {desc = "Spread: out"})
    map("n", "gK", F.ithunk(tsj.join), {desc = "Spread: combine"})
    map("n", [[g\]], F.ithunk(tsj.toggle), {desc = "Spread: toggle"})
end

--  ══════════════════════════════════════════════════════════════════════

---Setup `syntax-tree-surfer`
function M.setup_treesurfer()
    cmd.packadd("syntax-tree-surfer")
    local sts = F.npcall(require, "syntax-tree-surfer")
    if not sts then
        return
    end

    local vars = {
        "variable_declaration",
        "let_declaration",
        "declaration", -- c
        "VarDecl",     -- zig
    }

    local default = _t({
        "function",
        "arrow_function",
        "closure_expression",
        "function_definition",
        "function_declaration",
        "function_item",
        "FnProto", -- zig Function
        "method_definition",
        "macro_definition",
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        "IfPrefix", -- zig If
        "if_statement",
        "if_expression",
        "if_let_expression",
        "else_clause",
        "else_statement",
        "elseif_statement",
        "elsif_clause",    -- perl
        "else_clause",     -- perl
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        "ForPrefix",       -- zig For
        "for_statement",
        "for_statement_2", -- perl foreach
        "for_expression",
        "while_statement",
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        "SwitchExpr", -- zig Switch
        "SwitchCase", -- zig Switch else
        "switch_statement",
        "match_expression",
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        "struct_item",
        "enum_item",
        "interface_declaration",
        "class_declaration",
        "class_name",
        "impl_item",
        "try_statement",
        "catch_clause",
        "ContainerDecl", -- zig
        --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        "return_statement",
    })

    local filter = default:merge({
        -- "function_call",
        "field_declaration", -- rust struct
        "enum_variant",      -- rust enum
    })

    sts.setup({
        highlight_group = "STS_highlight", -- HopNextKey
        disable_no_instance_found_report = false,
        default_desired_types = default,
        left_hand_side = "fdsawervcxqtzb",
        right_hand_side = "jkl;oiu.,mpy/n",
        icon_dictionary = {
            ["if_statement"] = "",
            ["if_expression"] = "",
            ["if_let_expression"] = "",
            ["IfPrefix"] = "", -- zig If
            ["else_clause"] = "",
            ["else_statement"] = "",
            ["elseif_statement"] = "",
            ["ForPrefix"] = "", -- zig For
            ["for_statement"] = "",
            ["for_expression"] = "",
            ["while_statement"] = "菱",
            ["SwitchExpr"] = "", -- zig Switch
            ["SwitchCase"] = "", -- zig Switch else
            ["switch_statement"] = "",
            ["match_expression"] = "",
            ["macro_definition"] = I.type.macro,
            ["closure_expression"] = I.type.func,
            ["function_item"] = I.type.funcdef,
            ["function_definition"] = I.type.funcdef,
            ["function"] = I.type.func,
            ["FnProto"] = I.type.func, -- zig Function
            ["arrow_function"] = I.type.func,
            ["method_definition"] = "",
            ["variable_declaration"] = I.type.variable,
            ["let_declaration"] = I.type.variable,
            ["VarDecl"] = I.type.variable, -- zig Variable Declaration
            ["ContainerDecl"] = "פּ", -- zig Enum/Struct
            ["struct_item"] = "פּ",
            ["enum_item"] = "",
            ["enum_variant"] = "",
            ["field_declaration"] = "",
            ["interface_declaration"] = "",
            ["class_declaration"] = "",
            ["class_name"] = "",
            ["impl_item"] = "ﴯ",
            ["try_statement"] = "",
            ["catch_clause"] = "",
        },
    })

    map(
        "n",
        "vu",
        it(op.operator, {cb = "v:lua.STSSwapUpNormal_Dot", motion = "l"}),
        {silent = true, desc = "Swap node up"}
    )
    map(
        "n",
        "vd",
        it(op.operator, {cb = "v:lua.STSSwapDownNormal_Dot", motion = "l"}),
        {silent = true, desc = "Swap node down"}
    )
    map(
        "n",
        "su",
        it(op.operator, {cb = "v:lua.STSSwapUpNormal_Dot", motion = "l"}),
        {silent = true, desc = "Swap node up"}
    )
    map(
        "n",
        "sd",
        it(op.operator, {cb = "v:lua.STSSwapDownNormal_Dot", motion = "l"}),
        {silent = true, desc = "Swap node down"}
    )

    map(
        "n",
        "vD",
        it(op.operator, {cb = "v:lua.STSSwapCurrentNodeNextNormal_Dot", motion = "l"}),
        {silent = true, desc = "Swap cursor node w/ next sibling"}
    )
    map(
        "n",
        "vU",
        it(op.operator, {cb = "v:lua.STSSwapCurrentNodePrevNormal_Dot", motion = "l"}),
        {silent = true, desc = "Swap cursor node w/ prev sibling"}
    )

    -- map("n", "vd", it(sts.move, "n", false), {desc = "Swap next node"})
    -- map("n", "vu", it(sts.move, "n", true), {desc = "Swap prev node"})

    map("n", "vn", sts.select, {desc = "Select node"})
    map("n", "vm", sts.select_current_node, {desc = "Select current node"})
    map("n", "v;", sts.select, {desc = "Select master node"})
    -- map("n", "v,", sts.select_current_node, {desc = "Select current node"})

    map("x", "<A-]>", it(sts.surf, "next", "visual"), {desc = "Next node"})
    map("x", "<A-[>", it(sts.surf, "prev", "visual"), {desc = "Prev node"})
    map("x", "<C-k>", it(sts.surf, "parent", "visual"), {desc = "Parent node"})
    map("x", "<C-j>", it(sts.surf, "child", "visual"), {desc = "Child node"})

    map("x", "<C-A-]>", it(sts.surf, "next", "visual", true), {desc = "Swap next node"})
    map("x", "<C-A-[>", it(sts.surf, "prev", "visual", true), {desc = "Swap prev node"})

    -- map("n", "<C-A-.>", it(sts.targeted_jump, filter), {desc = "Jump to a main node"})
    map("n", "<C-M-,>", it(sts.targeted_jump, filter), {desc = "Jump to any node"})

    map("n", "<C-M-[>", it(sts.filtered_jump, filter, false), {desc = "Prev important node"})
    map("n", "<C-M-]>", it(sts.filtered_jump, filter, true), {desc = "Next important node"})
    map("n", "(", it(sts.filtered_jump, "default", false), {desc = "Prev main node"})
    map("n", ")", it(sts.filtered_jump, "default", true), {desc = "Next main node"})
    map("n", "<M-S-y>", it(sts.filtered_jump, vars, false), {desc = "Prev var declaration"})
    map("n", "<M-S-u>", it(sts.filtered_jump, vars, true), {desc = "Next var declaration"})
end

--  ══════════════════════════════════════════════════════════════════════

function M.setup_textobj()
    local config = {
        lsp_interop = {
            enable = ts.state.textobj.lsp,
            disable = ts.disable.textobj.lsp,
            border = Rc.style.border,
            floating_preview_opts = {},
            peek_definition_code = {},
        },
        select = {
            enable = ts.state.textobj.select,
            disable = ts.disable.textobj.select,
            lookahead = true,
            lookbehind = true,
            keymaps = {
                -- ["aF"] = "@custom-capture",
                ["aP"] = {query = "@scope", query_group = "locals", desc = "Around scope"},
                ["af"] = {query = "@function.outer", desc = "Around function"},
                ["if"] = {query = "@function.inner", desc = "Inner function"},
                ["ak"] = {query = "@class.outer", desc = "Around class"},
                ["ik"] = {query = "@class.inner", desc = "Inner class"},
                ["ac"] = {query = "@call.outer", desc = "Around call"},
                ["ic"] = {query = "@call.inner", desc = "Inner call"},
                ["ao"] = {query = "@block.outer", desc = "Around block"},
                ["io"] = {query = "@block.inner", desc = "Inner block"},
                ["ag"] = {query = "@comment.outer", desc = "Around comment"},
                -- ["ig"] = "@comment.inner",
                ["ad"] = {query = "@conditional.outer", desc = "Around conditional"},
                ["id"] = {query = "@conditional.inner", desc = "Inner conditional"},
                ["aj"] = {query = "@parameter.outer", desc = "Around parameter"},
                ["ij"] = {query = "@parameter.inner", desc = "Inner parameter"},
                ["aS"] = {query = "@statement.outer", desc = "Around statement"},
                ["ix"] = {query = "@assignment.lhs", desc = "Assignment LHS"},
                ["ax"] = {query = "@assignment.rhs", desc = "Assignment RHS"},
                ["al"] = {query = "@loop.outer", desc = "Around loop"},
                ["il"] = {query = "@loop.inner", desc = "Inner loop"},
                -- i: , . ; g k v y C E G H K M N P-W X Y Z
                -- a: , . ;   k v y C E G H K M N P-W X Y Z
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            --   * query_string: eg '@function.inner'
            --   * method: eg 'v' or 'o'
            -- should return mode ('v', 'V', or '<c-v>') or table mapping query_strings to modes.
            selection_modes = {
                ["@parameter.inner"] = "v",
                ["@parameter.outer"] = "v",
                ["@class.inner"] = "V",
                ["@class.outer"] = "V",
                ["@function.inner"] = "V",
                ["@function.outer"] = "v",
                ["@conditional.inner"] = "v",
                ["@conditional.outer"] = "V",
                ["@loop.inner"] = "V",
                ["@loop.outer"] = "v",
                ["@comment.outer"] = "v",
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            --   * query_string: eg '@function.inner'
            --   * selection_mode: eg 'v'
            include_surrounding_whitespace = function(q)
                if q.query_string == "@function.outer" or
                    q.query_string == "@class.outer" or
                    q.query_string == "@class.inner" then
                    return true
                else
                    return false
                end
            end,
        },
        -- p(require("nvim-treesitter.textobjects.shared").available_textobjects('lua'))

        -- @attribute.inner   @attribute.outer
        -- @assignment.inner  @assignment.outer
        -- @assignment.lhs    @assignment.rhs
        -- @block.inner       @block.outer
        -- @call.inner        @call.outer
        -- @class.inner       @class.outer
        --                    @comment.outer
        -- @conditional.inner @conditional.outer
        -- @frame.inner       @frame.outer
        -- @function.inner    @function.outer
        -- @loop.inner        @loop.outer
        -- @number.inner      @number.outer
        -- @parameter.inner   @parameter.outer
        -- @return.inner      @return.outer
        -- @scopename.inner   @statement.outer
        move = {
            enable = ts.state.textobj.move,
            disable = ts.disable.textobj.move,
            set_jumps = true, -- Whether to set jumps in the jumplist
            goto_next_start = {
                -- . , ; 1 f h A J L N O p P R U X Y
                -- [] ][
                --
                -- ["]o"] = "@loop.*",
                -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                --
                -- Pass query group to use query from `queries/<lang>/<query_group>.scm
                ["]o"] = {query = "@scope", query_group = "locals", desc = "Next scope"},
                ["<M-S-n>"] = {query = "@scope", query_group = "locals", desc = "Next scope"},
                ["<C-M-o>"] = {query = "@fold", query_group = "folds", desc = "Next TS fold"},
                ["]k"] = {query = "@class.outer", desc = "Next class start"},
                ["]b"] = {query = "@block.outer", desc = "Next block start"},
                ["]C"] = {query = "@comment.outer", desc = "Next comment start"},
                ["]2"] = {query = "@comment.outer", desc = "Next comment start"},
                ["]j"] = {query = "@parameter.inner", desc = "Next parameter start"},
                ["]a"] = {query = "@call.inner", desc = "Next call start"},
                ["]l"] = {query = "@loop.inner", desc = "Next loop start"},
                ["]d"] = {query = "@conditional.inner", desc = "Next conditional start"},
                ["]r"] = {query = "@return.inner", desc = "Next return"},
                --
                -- aerial does this '{'
                ["]f"] = {query = "@function.outer", desc = "Next function start"},
            },
            goto_previous_start = {
                ["[o"] = {query = "@scope", query_group = "locals", desc = "Prev scope"},
                ["<M-S-m>"] = {query = "@scope", query_group = "locals", desc = "Prev scope"},
                ["<C-M-i>"] = {query = "@fold", query_group = "folds", desc = "Prev TS fold"},
                ["[k"] = {query = "@class.outer", desc = "Prev class start"},
                ["[b"] = {query = "@block.outer", desc = "Prev block start"},
                ["[C"] = {query = "@comment.outer", desc = "Prev comment start"},
                ["[2"] = {query = "@comment.outer", desc = "Prev comment start"},
                ["[j"] = {query = "@parameter.inner", desc = "Prev parameter start"},
                ["[a"] = {query = "@call.inner", desc = "Prev call start"},
                ["[l"] = {query = "@loop.inner", desc = "Prev loop start"},
                ["[d"] = {query = "@conditional.inner", desc = "Prev conditional start"},
                ["[r"] = {query = "@return.inner", desc = "Prev return"},
                --
                -- aerial does this '}'
                ["[f"] = {query = "@function.outer", desc = "Prev function start"},
            },
            goto_next_end = {
                ["]F"] = {query = "@function.outer", desc = "Next function end"},
                ["]K"] = {query = "@class.outer", desc = "Next class end"},
                ["]B"] = {query = "@block.outer", desc = "Next block end"},
                -- ["]A"] = {query = "@call.outer", desc = "Next call end"},
            },
            goto_previous_end = {
                ["[F"] = {query = "@function.outer", desc = "Prev function end"},
                ["[B"] = {query = "@block.outer", desc = "Prev block end"},
                ["[K"] = {query = "@class.outer", desc = "Prev class end"},
                -- ["[A"] = {query = "@call.outer", desc = "Prev call end"},
            },
            goto_next = {},
            goto_previous = {},
        },
        swap = {
            enable = ts.state.textobj.swap,
            disable = ts.disable.textobj.swap,
            swap_next = {
                ["s{"] = {query = "@assignment.outer", desc = "Swap next assignment"}, -- swap assignment statements
                -- ["sj"] = {query = "@assignment.rhs", desc = "Swap prev assignment"},
                -- ["s="] = {query = "@assignment.inner", desc = "Swap prev assignment"}, -- swap each side of '='
                -- ["sp"] = {query = "@parameter.inner", desc = "Swap next parameter"},
                ["snf"] = {query = "@function.outer", desc = "Swap next function"},
                ["snb"] = {query = "@block.outer", desc = "Swap next block"},
                ["snk"] = {query = "@class.outer", desc = "Swap next class"},
                ["snc"] = {query = "@call.outer", desc = "Swap next call"},
            },
            swap_previous = {
                ["s}"] = {query = "@assignment.outer", desc = "Swap prev assignment"},
                -- ["s="] = {query = "@assignment.inner", desc = "Swap assignment = sides"},
                -- ["sP"] = {query = "@parameter.inner", desc = "Swap prev parameter"},
                ["spf"] = {query = "@function.outer", desc = "Swap prev function"},
                ["spb"] = {query = "@block.outer", desc = "Swap prev block"},
                ["spk"] = {query = "@class.outer", desc = "Swap prev class"},
                ["spc"] = {query = "@call.outer", desc = "Swap prev call"},
            },
        },
    }
    return config
end

--  ══════════════════════════════════════════════════════════════════════

---Setup `nvim-treesitter`
---@return TSSetupConfig
M.setup = function()
    -- TODO: create a tree-sitter-zsh

    ---@class TSSetupConfig
    return {
        ensure_installed = {
            -- "dart",
            -- "devicetree",
            -- "ungrammar",
            -- "log",
            -- "norg",
            -- "norg_meta",
            -- "norg_table",
            "proto",
            "query",
            "scheme",
            "llvm",
            -- ━━━━━━━━━
            -- "hurl",
            "http",
            "html",
            -- "htmldjango",
            "graphql",
            "css",
            "scss",
            "svelte",
            "vue",
            -- ━━━━━━━━━
            "comment",
            "regex",
            "diff",
            "luap",
            "luau",
            -- ━━━━━━━━━
            "jsdoc",
            "vimdoc",
            "luadoc",
            "markdown",
            "markdown_inline",
            -- "embedded_template", -- ERB, EJS
            "rst",
            "bibtex",
            "latex",
            -- ━━━━━━━━━
            "dockerfile",
            "nix",
            "gosum",
            "gomod",
            "gowork",
            "meson",
            "ninja",
            "cmake",
            "make",
            "just",
            -- ━━━━━━━━━
            "hjson",
            "json",
            "json5",
            "jsonc",
            -- "jsonett",
            "ini",
            "rasi",
            "ron",
            "toml",
            "yaml",
            -- ━━━━━━━━━
            "passwd",
            "sxhkdrc",
            "ledger", -- TODO: use this program
            -- ━━━━━━━━━
            "git_config",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            -- ━━━━━━━━━
            "sql",
            "jq",
            -- ━━━━━━━━━
            -- "d",
            -- "julia",
            -- "kotlin",
            -- "nim",
            "awk",
            "bash",
            "c",
            "cpp",
            "fennel",
            "go",
            "haskell",
            "haskell_persistent",
            "java",
            "javascript",
            "lua",
            "ocaml",
            "perl", -- Syntax isn't parsed the greatest
            "python",
            "ruby",
            "rust",
            "solidity",
            "teal",
            "tsx",
            "typescript",
            "vim",
            "zig",
        },
        sync_install = false,
        auto_install = ts.state.install,
        ignore_install = ts.disable.install, -- List of parsers to ignore installing
        highlight = {
            enable = ts.state.hl,            -- false will disable the whole extension
            disable = ts.disable.hl,
            -- disable = gen_disable("hl"),
            additional_vim_regex_highlighting = ts.enable.additional_hl, -- true
            custom_captures = ts.enable.custom_captures,
        },
        fold = {
            enable = ts.state.fold,
            disable = gen_disable("fold"),
        },
        autotag = {
            enable = ts.state.autotag,
            disable = ts.disable.autotag,
        },
        autopairs = {
            enable = ts.state.autopairs,
            disable = gen_disable("autopairs"),
        },
        indent = {
            enable = ts.state.indent,
            disable = gen_disable("indent"),
        },
        endwise = {
            enable = ts.state.endwise,
            disable = gen_disable("endwise"),
        },
        matchup = {
            enable = ts.state.matchup,
            disable = gen_disable("matchup"),
            include_match_words = true,
            -- disable_virtual_text = {"python"},
            disable_virtual_text = true,
        },
        playground = {
            enable = ts.state.playground,
            disable = gen_disable("playground"),
            updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
            persist_queries = false, -- Whether the query persists across vim sessions
            keybindings = {
                toggle_query_editor = "o",
                toggle_hl_groups = "i",
                toggle_injected_languages = "t",
                toggle_anonymous_nodes = "a",
                toggle_language_display = "I",
                focus_language = "f",
                unfocus_language = "F",
                update = "R",
                goto_node = "<cr>",
                show_help = "?",
            },
        },
        query_linter = {
            enable = ts.state.query_linter,
            disable = gen_disable("query_linter"),
            use_virtual_text = true,
            lint_events = {"BufWrite", "CursorHold"},
        },
        incremental_selection = {
            enable = ts.state.incremental_selection,
            disable = ts.disable.incremental_selection,
            keymaps = {
                init_selection = "<M-n>",    -- maps in normal mode to init the node/scope selection
                scope_incremental = "<M-n>", -- increment to the upper scope (as defined in locals.scm)
                node_incremental = "<Nul>",  -- increment to the upper named parent
                node_decremental = '<Nul>"', -- decrement to the previous node
            },
        },
        context_commentstring = {
            enable = ts.state.context_commentstr,
            disable = gen_disable("context_commentstr"),
            enable_autocmd = false,
            config = {
                c = {__default = "// %s", __multiline = "/* %s */"},
                cpp = {__default = "// %s", __multiline = "/* %s */"},
                go = {__default = "// %s", __multiline = "/* %s */"},
                lua = {__default = "-- %s", __multiline = "--[[ %s ]]"}, -- doc = "---%s"
                python = {__default = "# %s", __multiline = '""" %s """'},
                rust = {__default = "// %s", __multiline = "/* %s */"},  -- doc = "/// %s"
                typescript = {__default = "// %s", __multiline = "/* %s */"},
                vim = '" %s',
                markdown = {__default = "%% %s", __multiline = "<!-- %s -->"},
                vimwiki = {__default = "%% %s", __multiline = "<!-- %s -->"},
                sql = "-- %s",
                css = "/* %s */",
                html = "<!-- %s -->",
                json = "",
                jsonc = {__default = "// %s", __multiline = "/* %s */"},
            },
        },
        refactor = {
            highlight_definitions = {
                enable = ts.state.refactor.hl_defs,
                disable = ts.disable.refactor.hl_defs,
                -- clear_on_cursor_move = true, -- false if you have an `updatetime` of ~100.
            },
            highlight_current_scope = {
                enable = ts.state.refactor.hl_scope,
                disable = ts.disable.refactor.hl_scope,
            },
            smart_rename = {
                enable = ts.state.refactor.rename,
                disable = ts.disable.refactor.rename,
                keymaps = {smart_rename = "<A-r>"},
            },
            navigation = {
                enable = ts.state.refactor.nav,
                disable = ts.disable.refactor.nav,
                keymaps = {
                    goto_definition = ";D",          -- mapping to go to definition of symbol under cursor
                    list_definitions = "<Leader>fd", -- mapping to list all definitions in current file
                    list_definitions_toc = "<Leader>fo",
                    goto_next_usage = "]y",
                    goto_previous_usage = "[y",
                },
            },
        },
        textobjects = M.setup_textobj(),
        -- nvimGPS = {
        --     enable = ts.state.gps,
        --     disable = ts.disable.gps,
        -- },
        -- tree_docs = {
        --     enable = ts.state.docs,
        --     disable = ts.disable.docs,
        --     keymaps = {
        --         doc_all_in_range = "gdd",
        --         doc_node_at_cursor = "gdd",
        --         edit_doc_at_cursor = "gde",
        --     },
        -- },
    }
end

---Install extra Treesitter parsers
function M.install_extra_parsers()
    local parser_config = parsers.get_parser_configs()

    parser_config.just = {
        install_info = {
            url = "https://github.com/IndianBoy42/tree-sitter-just",
            files = {"src/parser.c", "src/scanner.cc"},
            branch = "main",
            -- use_makefile = true,
        },
        maintainers = {"@IndianBoy42"},
    }

    -- Using this parsers own queries does not work
    -- Solidity
    -- parser_config.solidity = {
    --     install_info = {
    --         url = "https://github.com/JoranHonig/tree-sitter-solidity",
    --         files = {"src/parser.c"},
    --         requires_generate_from_grammar = true
    --     },
    --     filetype = "solidity"
    -- }

    -- Log files
    -- parser_config.log = {
    --     install_info = {
    --         url = "https://github.com/lpraneis/tree-sitter-tracing-log",
    --         files = {"src/parser.c"},
    --         branch = "main",                        -- default branch in case of git repo if different from master
    --         generate_requires_npm = false,          -- if stand-alone parser without npm dependencies
    --         requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
    --     },
    --     filetype = "log"
    -- }
end

--  ══════════════════════════════════════════════════════════════════════

---Setup custom commands for Treesitter
function M.setup_commands()
    command("CursorNodes", function()
        local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
        local nodes = {}
        while node do
            table.insert(nodes, node:type())
            node = node:parent()
        end
        utils.echomln(nodes, "WarningMsg")
    end, {nargs = 0, desc = "Show treesitter nodes"})
end

local function init()
    cmd.packadd("nvim-treesitter-textobjects")
    cmd.packadd("nvim-treesitter")

    -- File type based toggling in one place

    ---@class TSPlugin
    ts = {
        ---@type TSPlugin.Disable
        disable = {},
        ---@type TSPlugin.Enable
        enable = {},
        ---@type TSPlugin.State
        state = {},
        ---@type TSPlugin.Max
        max = {},
    }

    -- This all depends, if it is a vim help file, can read one with a very large
    -- size and nothing is slowed down. However, the Lua language server or something
    -- slows Lua down

    ---@class TSPlugin.Max
    ts.max = {
        -- 1000 KiB file size
        fsize = 1000,
        -- 3000 lines in a file
        hl = 3000,
        aerial = 30000,
        autopairs = 2000,
        matchup = 2000,
        fold = 2200,
        indent = 3000,
        endwise = 2500,
        context_vt = 2000,
        context_commentstr = 2000,
        refactor = 3000,
        playground = 3000,
        query_linter = 3000,
        rainbow = 3000,
    }

    ---@class TSPlugin.Enable
    ts.enable = {
        ft = {telescope = true},
        hl = {},
        additional_hl = {
            -- "perl", "cpp", "latex", "teal"
            -- "zsh",
            -- "vimdoc", "ruby", "awk",
            "vim", "jq", "bash", "sh",
            "css", "cmake", "sxhkdrc"
            -- "c",
        },
        indent = {},
        autotag = {
            "html", "xhtml", "phtml", "xml",
            "javascript", "javascriptreact",
            "typescript", "typescriptreact",
            "svelte", "vue",
        },
        autopairs = {},
        fold = {},
        endwise = {},
        matchup = {},
        refactor = {hl_defs = {}, hl_scope = {}, rename = {}, nav = {}},
        textobj = {select = {}, move = {}, swap = {}, lsp = {}},
        playground = {},
        context_commentstr = {},
        query_linter = {},
        incremental_selection = {},
        gps = {},
        custom_captures = {},
        -- docs = {},
        -- rainbow = {},
    }

    ---@class TSPlugin.Disable
    ts.disable = {
        ft = {},
        install = {},
        fold = _j({"comment"}),
        hl = _j({
            -- "vimdoc", "markdown", "css", "PKGBUILD", "toml", "perl",
            "comment", "html", "ini", "yaml",
            "make", "cmake", "latex",
            -- "markdown", "markdown_inline",
            -- "solidity",
        }),
        indent = _j({
            "git_rebase", "gitattributes", "gitignore",
            "comment", "vimdoc", "yaml", "markdown", "markdown_inline",
            "teal",
        }),
        rainbow = _j({
            "git_rebase", "gitattributes", "gitignore",
            "comment", "diff", "yaml",
            "markdown", "html", "vimdoc",
            "teal", "markdown",
        }),
        autopairs = _j({"comment", "gitignore", "git_rebase", "gitattributes", "markdown",
            "markdown_inline"}),
        endwise = _j({"comment", "git_rebase", "gitattributes", "gitignore", "markdown",
            "markdown_inline"}),
        matchup = _j({"comment", "git_rebase", "gitattributes", "gitignore"}),
        textobj = {
            select = {"comment", "gitignore", "git_rebase", "gitattributes"},
            move = {"comment", "gitignore", "git_rebase", "gitattributes"},
            swap = {"comment", "gitignore", "git_rebase", "gitattributes"},
            lsp = {},
        },
        refactor = {
            hl_defs = _j({"comment"}),
            hl_scope = _j({"comment"}),
            rename = _j({"comment"}),
            nav = _j({"comment"}),
        },
        context_commentstr = _j({"comment"}),
        incremental_selection = _j({"comment"}),
        gps = _j({"comment"}),
        playground = _j({}),
        autotag = {},
        query_linter = _j({}),
        aerial = Rc.blacklist.ft:merge({"gomod", "help"}),
        hlargs = Rc.blacklist.ft:filter(utils.lambda("x -> x ~= 'luapad'")),
        context_vt = Rc.blacklist.ft,
        -- docs = {},
    }

    ---@class TSPlugin.State
    ts.state = {
        install = true,
        hl = true,
        indent = true,
        fold = true,
        autotag = true,
        autopairs = true,
        endwise = true,
        matchup = true,
        playground = true,
        context_commentstr = true,
        query_linter = true,
        incremental_selection = true,
        refactor = {hl_defs = false, hl_scope = false, rename = true, nav = true},
        textobj = {select = true, move = true, swap = true, lsp = false},
        gps = true,
        context_vt = true,
        -- docs = true,
        -- rainbow = true,
    }

    M.ts = ts

    configs = require("nvim-treesitter.configs")
    parsers = require("nvim-treesitter.parsers")

    local conf = M.setup()
    M.install_extra_parsers()
    configs.setup(conf --[[@as TSConfig]])

    -- M.setup_treesj()
    -- M.setup_iswap()
    -- M.setup_treesurfer()
    M.setup_gps()
    M.setup_hlargs()
    M.setup_aerial()
    M.setup_context_vt()
    M.setup_autotag()

    -- M.setup_query_secretary()
    -- M.setup_ssr()
    -- M.setup_rainbow()

    M.setup_commands()

    local ts_repeat = require("nvim-treesitter.textobjects.repeatable_move")
    -- map({"n", "x", "o"}, "<M-S-}>", ts_repeat.repeat_last_move_next)
    -- map({"n", "x", "o"}, "<M-S-{>", ts_repeat.repeat_last_move_previous)
    map({"n", "x", "o"}, "<Left>", ts_repeat.repeat_last_move_previous, {desc = "TS move prev"})
    map({"n", "x", "o"}, "<Right>", ts_repeat.repeat_last_move_next, {desc = "TS move next"})

    map("x", "iu", [[:<C-u>lua require"treesitter-unit".select()<CR>]], {silent = true})
    map("x", "au", [[:<C-u>lua require"treesitter-unit".select(true)<CR>]], {silent = true})
    map("o", "iu", [[<Cmd>lua require"treesitter-unit".select()<CR>]], {silent = true})
    map("o", "au", [[<Cmd>lua require"treesitter-unit".select(true)<CR>]], {silent = true})

    wk.register({
        ["aL"] = "Line (include newline)",
        ["iL"] = "Line (no newline or spaces)",
        ["ie"] = "Entire buffer",
        ["ae"] = "Entire visible buffer",
        ["au"] = "Around unit",
        ["iu"] = "Inner unit",
    }, {mode = {"o", "x"}})

    wk.register({
        ["<A-r>"] = "Smart rename",
        [";D"] = "Go to definition under cursor",
        ["<Leader>fd"] = "Quickfix definitions (treesitter)",
        ["<Leader>fo"] = "Quickfix definitions TOC (treesitter)",
        ["[y"] = "Previous usage",
        ["]y"] = "Next usage",
        ["<M-n>"] = "Start scope selection/Increment",
    }, {mode = "n"})

    wk.register({
        ["<Leader>sh"] = {"<Cmd>TSHighlightCapturesUnderCursor<CR>", "TS: hl capture group"},
        ["<Leader>sI"] = {"<Cmd>Inspect<CR>", "TS: inspect highlight"},
        ["<Leader>s,"] = {"<Cmd>TSBufToggle highlight<CR>", "TS: toggle highlight"},
        ["<Leader>sd"] = {"<Cmd>TSPlaygroundToggle<CR>", "Playground: toggle"},
    }, {mode = "n"})

    cmd("au! NvimTreesitter FileType *")
    queries = require("nvim-treesitter.query")
    local cfhl = conf.highlight.disable
    local hl_disabled = type(cfhl) == "function" and ts.disable.hl or cfhl
    for _, lang in ipairs(conf.ensure_installed) do
        local parser = parsers.list[lang]
        local filetype = parser.filetype

        if not vim.tbl_contains(hl_disabled, lang) then
            ts.enable.ft[filetype or lang] = true
        end
    end

    -- Rainbow breaks this
    vim.defer_fn(function()
        cmd.TSEnable("endwise")
    end, 200)

    -- nvim.autocmd.lmb__TreesitterDiff = {
    --     event = {"BufReadPost"},
    --     pattern = "*",
    --     command = function()
    --         if vim.wo.diff then
    --             cmd.TSBufToggle("rainbow")
    --         end
    --     end
    -- }

    -- This doesn't get loaded until the second file is opened
    -- Need to fix lazy loading treesitter
    -- nvim.autocmd.lmb__TreesitterIndent = {
    --     event = "FileType",
    --     pattern = table.concat(vim.tbl_flatten(vim.tbl_keys(ts.enable.indent)), ","),
    --     command = function(args)
    --         local bufnr = args.buf
    --         vim.bo[bufnr].indentexpr = "nvim_treesitter#indent()"
    --     end
    -- }
end

init()

return M
