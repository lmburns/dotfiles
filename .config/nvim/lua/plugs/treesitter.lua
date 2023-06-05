---@module 'plugs.treesitter'
local M = {}

local shared = require("usr.shared")
local F = shared.F
if not F.npcall(require, "nvim-treesitter") then
    return
end

local it = F.ithunk
local hl = shared.color
local mpi = require("usr.api")
local map = mpi.map
local bmap = mpi.bmap
local op = require("usr.lib.op")

local style = require("usr.style")
local wk = require("which-key")

local cmd = vim.cmd
local g = vim.g
local fn = vim.fn
local api = vim.api

---@type TSPlugin
local ts
local queries, parsers, configs

local context_vt_max_lines = 2000

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
        M.textobj(obj, inner, F.if_expr(visual, "x", "o"))
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
            vim.defer_fn(
                function()
                    pcall(configs.reattach_module, "textobjects.move", bufnr)
                end,
                300
            )
        else
            vim.bo.syntax = ft
        end
    end
end

---Setup `nvim-gps`
M.setup_gps = function()
    cmd.packadd("nvim-gps")
    local gps = F.npcall(require, "nvim-gps")
    if not gps then
        return
    end

    gps.setup({
        enabled = true,
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
M.setup_hlargs = function()
    cmd.packadd("hlargs.nvim")
    local hlargs = F.npcall(require, "hlargs")
    if not hlargs then
        return
    end

    hlargs.setup({
        excluded_filetypes = BLACKLIST_FT:filter(utils.lambda("x -> x ~= 'luapad'")),
        -- color = g.colors_name == "kimbox" and colors.salmon or nil,
        color = "#DE9A4E",
        hl_priority = 10000,
        -- use_colorpalette = false,
        -- colorpalette = {
        --   { fg = "#DE9A4E" },
        --   { fg = "#BBEA87" },
        --   { fg = "#EEF06D" },
        --   { fg = "#8FB272" },
        -- },
        paint_arg_declarations = true,
        paint_arg_usages = true,
        paint_catch_blocks = {
            declarations = true,
            usages = true,
        },
        extras = {
            named_parameters = true,
        },
        excluded_argnames = {
            declarations = {"use", "use_rocks", "_"},
            usages = {
                python = {"cls", "self"},
                go = {"_"},
                rust = {"_", "self"},
                lua = {"_", "self", "use", "use_rocks", "super"},
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

---Setup `iswap.nvim`
M.setup_ssr = function()
    cmd.packadd("ssr.nvim")
    local ssr = F.npcall(require, "ssr")
    if not ssr then
        return
    end

    ssr.setup({
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        keymaps = {
            close = "q",
            next_match = "n",
            prev_match = "N",
            replace_confirm = "<CR>",
            replace_all = "<S-CR>",
        },
    })

    map({"n", "x"}, "<Leader>s;", F.ithunk(ssr.open), {desc = "Open SSR"})
end

---Setup `nvim-ts-autotag`
M.setup_autotag = function()
    cmd.packadd("nvim-ts-autotag")
    local autotag = F.npcall(require, "nvim-ts-autotag")
    if not autotag then
        return
    end

    autotag.setup{
        filetypes = {
            "html",
            "xml",
            "xhtml",
            "phtml",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "svelte",
            "vue",
        },
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
    }
end

---Setup `aerial`
M.setup_aerial = function()
    cmd.packadd("aerial.nvim")
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
        disable_max_lines = 10000,
        -- Disable aerial on files this size or larger (in bytes)
        disable_max_size = 2000000, -- Default 2MB
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
            filetypes = BLACKLIST_FT:merge({"gomod", "help"}),
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
            border = style.current.border,
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
            border = style.current.border,
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
        -- How long to wait (in ms) after a buffer change before updating
        markdown = {update_delay = update_delay},
        -- How long to wait (in ms) after a buffer change before updating
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

    wk.register(
        {
            ["[["] = {aerial.prev_up, "Prev main func (aerial)"},
            ["]]"] = {aerial.next_up, "Next main func (aerial)"},
            ["{"] = {aerial.prev, "Prev anon (aerial)"},
            ["}"] = {aerial.next, "Next anon (aerial)"},
        },
        {mode = "x"}
    )

    -- require("telescope").load_extension("aerial")
end

--  ══════════════════════════════════════════════════════════════════════

---Setup `nvim_context_vt`
M.setup_context_vt = function()
    cmd.packadd("nvim_context_vt")
    local ctx = F.npcall(require, "nvim_context_vt")
    if not ctx then
        return
    end

    ctx.setup({
        -- Enable by default. You can disable and use :NvimContextVtToggle to maually enable.
        -- Default: true
        enabled = true,
        -- Override default virtual text prefix
        -- Default: '-->'
        prefix = "",
        -- Override the internal highlight group name
        -- Default: 'ContextVt'
        highlight = "ContextVt",
        -- Disable virtual text for given filetypes
        disable_ft = BLACKLIST_FT,
        -- Disable display of virtual text below blocks for indentation based languages like Python
        -- Default: false
        disable_virtual_lines = false,
        -- Same as above but only for spesific filetypes
        -- Default: {}
        disable_virtual_lines_ft = {"yaml", "python"},
        -- How many lines required after starting position to show virtual text
        min_rows = fn.winheight("%") / 3,
        -- Same as above but only for spesific filetypes
        min_rows_ft = {},
        -- Custom virtual text node parser callback
        custom_parser = function(node, _ft, _opts)
            if api.nvim_buf_line_count(0) >= context_vt_max_lines then
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

---Setup `syntax-tree-surfer`
M.setup_treesurfer = function()
    cmd.packadd("syntax-tree-surfer")
    local sts = F.npcall(require, "syntax-tree-surfer")
    if not sts then
        return
    end

    local vars = {
        "variable_declaration",
        "let_declaration",
        "VarDecl", -- zig Variable declaration
    }

    local default = _t({
        "function",
        "arrow_function",
        "function_definition",
        "function_declaration",
        "function_item",
        "FnProto", -- zig Function
        "method_definition",
        "macro_definition",
        "closure_expression",
        "IfPrefix", -- zig If
        "if_statement",
        "if_expression",
        "if_let_expression",
        "else_clause",
        "else_statement",
        "elseif_statement",
        "ForPrefix", -- zig For
        "for_statement",
        "for_expression",
        "while_statement",
        "SwitchExpr", -- zig Switch
        "SwitchCase", -- zig Switch else
        "switch_statement",
        "match_expression",
        "struct_item",
        "enum_item",
        "interface_declaration",
        "class_declaration",
        "class_name",
        "impl_item",
        "try_statement",
        "catch_clause",
        "ContainerDecl",
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
            ["macro_definition"] = "",
            ["closure_expression"] = "",
            ["function_item"] = "",
            ["function_definition"] = "",
            ["function"] = "",
            ["FnProto"] = "", -- zig Function
            ["arrow_function"] = "",
            ["method_definition"] = "",
            ["variable_declaration"] = "",
            ["let_declaration"] = "",
            ["VarDecl"] = "",     -- zig Variable Declaration
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

    -- map("n", "<C-A-.>", it(sts.targeted_jump, filter), {desc = "Jump to a main node"})
    map("n", "<C-M-,>", it(sts.targeted_jump, filter), {desc = "Jump to any node"})

    map("n", "<C-M-[>", it(sts.filtered_jump, filter, false), {desc = "Prev important node"})
    map("n", "<C-M-]>", it(sts.filtered_jump, filter, true), {desc = "Next important node"})
    map("n", "(", it(sts.filtered_jump, "default", false), {desc = "Prev main node"})
    map("n", ")", it(sts.filtered_jump, "default", true), {desc = "Next main node"})
    map("n", "<M-S-{>", it(sts.filtered_jump, vars, false), {desc = "Prev var declaration"})
    map("n", "<M-S-}>", it(sts.filtered_jump, vars, true), {desc = "Next var declaration"})

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

    map("x", "<A-]>", it(sts.surf, "next", "visual"), {desc = "Next node"})
    map("x", "<A-[>", it(sts.surf, "prev", "visual"), {desc = "Prev node"})
    map("x", "<C-k>", it(sts.surf, "parent", "visual"), {desc = "Parent node"})
    map("x", "<C-j>", it(sts.surf, "child", "visual"), {desc = "Child node"})

    map("x", "<C-A-]>", it(sts.surf, "next", "visual", true), {desc = "Swap next node"})
    map("x", "<C-A-[>", it(sts.surf, "prev", "visual", true), {desc = "Swap prev node"})
end

--  ══════════════════════════════════════════════════════════════════════

M.setup_swap = function()
    -- nvim.autocmd.lmb__NonTreesitterSwap = {
    --     event = "FileType",
    --     pattern = ([[*\(%s\)\@<!]]):format(table.concat(vim.tbl_keys(ts.enable.ft), [[\|]])),
    --     command = function(a)
    --         local map = function(...)
    --             mpi.bmap(a.buf, ...)
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

---Setup `ssr.nvim`
M.setup_iswap = function()
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

--  ══════════════════════════════════════════════════════════════════════

M.setup_splitjoin = function()
    g.splitjoin_split_mapping = ""
    g.splitjoin_join_mapping  = ""

    nvim.autocmd.lmb__NonTreesitterSplit = {
        event = "FileType",
        pattern = ([[*\(%s\)\@<!]]):format(table.concat(vim.tbl_keys(ts.enable.ft), [[\|]])),
        command = function(a)
            local map = function(...)
                mpi.bmap(a.buf, ...)
            end

            map("n", "gJ", "<Cmd>SplitjoinSplit<CR>", {desc = "Split: split"})
            map("n", "gS", "<Cmd>SplitjoinJoin<CR>", {desc = "Split: join"})
        end,
    }
end

---Setup `treesj`
M.setup_treesj = function()
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
    }

    tsj.setup({
        use_default_keymaps = false,
        check_syntax_error = true,
        max_join_length = 100,
        -- hold  = cursor follows the node/place on which it was called
        -- start = cursor jumps to the first symbol of the node being formatted
        -- end   = cursor jumps to the last symbol of the node being formatted
        cursor_behavior = "hold",
        notify = true,         -- notify about possible problems or not
        dot_repeat = true,     -- use `dot` for repeat action
        langs = langs_t,
        -- langs = lu._prepare_presets(langs_t),
    })

    -- map("n", "gK", F.ithunk(tsj.split, {recursive = true}), {desc = "Spread: out"})
    map("n", "gJ", F.ithunk(tsj.split), {desc = "Spread: out"})
    map("n", "gK", F.ithunk(tsj.join), {desc = "Spread: combine"})
    map("n", [[g\]], F.ithunk(tsj.toggle), {desc = "Spread: toggle"})
end

--  ══════════════════════════════════════════════════════════════════════

---Setup `query-secretary`
M.setup_query_secretary = function()
    cmd.packadd("query-secretary")
    local qs = F.npcall(require, "query-secretary")
    if not qs then
        return
    end

    qs.setup({
        open_win_opts = {
            row = 0,
            col = 9999,
            width = 50,
            height = 15,
        },
        buf_set_opts = {
            tabstop = 2,
            softtabstop = 2,
            shiftwidth = 2,
        },
        -- when press "c"
        capture_group_names = {"cap", "second", "third"},
        -- when press "p"
        predicates = {"eq", "any-of", "contains", "match", "lua-match"},
        -- when moving cursor around
        visual_hl_group = "Visual",
        keymaps = {
            close = {"q", "Esc"},
            next_predicate = {"p"},
            previous_predicate = {"P"},
            remove_predicate = {"d"},
            toggle_field_name = {"f"},
            yank_query = {"y"},
            next_capture_group = {"c"},
            previous_capture_group = {"C"},
        },
    })

    map(
        "n",
        "<Leader>qu",
        "require('query-secretary').query_window_initiate()",
        {lcmd = true, desc = "Start query secretary"}
    )
end

--  ══════════════════════════════════════════════════════════════════════

---Setup `nvim-treesitter`
---@return TSSetupConfig
M.setup = function()
    ---@class TSSetupConfig
    return {
        ensure_installed = {
            "awk",
            "bash",
            "bibtex",
            "c",
            "cmake",
            "comment",
            "cpp",
            "css",
            "d",
            "dart",
            "diff",
            "dockerfile",
            "fennel",
            "git_config",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "go",
            "gomod",
            "gosum",
            "gowork",
            "graphql",
            "hjson",
            "html",
            "ini",
            "java",
            "javascript",
            "jq",
            "jsdoc",
            "json",
            "json5",
            "jsonc",
            "julia",
            "kotlin",
            "latex",
            "llvm",
            -- "log",
            "lua",
            "luadoc",
            "luap",
            "luau",
            "make",
            "markdown",
            "markdown_inline",
            -- "norg",
            -- "norg_meta",
            -- "norg_table",
            "meson",
            "ninja",
            "passwd",
            "perl", -- Syntax isn't parsed the greatest
            "proto",
            "python",
            "query",
            "rasi",
            "regex",
            "ron",
            "rst",
            "ruby",
            "rust",
            "scheme",
            "scss",
            "solidity",
            "sql",
            "svelte",
            "sxhkdrc",
            "teal",
            "toml",
            "tsx",
            "typescript",
            "ungrammar",
            "vim",
            "vimdoc",
            "vue",
            "yaml",
            "zig",
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {}, -- List of parsers to ignore installing
        highlight = {
            enable = true,   -- false will disable the whole extension
            disable = function(ft, bufnr)
                if
                    ts.disable.hl:contains(ft) or
                    api.nvim_buf_line_count(bufnr or 0) > g.treesitter_highlight_maxlines
                then
                    return true
                end

                return false
            end,
            use_languagetree = true,
            -- additional_vim_regex_highlighting = true,
            additional_vim_regex_highlighting = {
                "perl",
                "latex",
                "vim",
                "vimdoc",
                "ruby",
                "sh",
                "awk",
                "css",
                "markdown",
                "jq",
                -- "teal"
            },
            custom_captures = ts.enable.custom_captures,
        },
        fold = {enable = false},
        autotag = {enable = true},
        autopairs = {
            enable = true,
            disable = ts.disable.autopairs,
        },
        indent = {
            enable = true,
            disable = ts.disable.indent,
        },
        endwise = {
            enable = true,
            disable = ts.disable.endwise,
        },
        matchup = {
            enable = true,
            include_match_words = true,
            -- disable_virtual_text = {"python"},
            disable_virtual_text = true,
            disable = ts.disable.matchup,
        },
        playground = {
            enable = true,
            disable = ts.disable.playground,
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
            enable = true,
            use_virtual_text = true,
            lint_events = {"BufWrite", "CursorHold"},
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<M-n>",    -- maps in normal mode to init the node/scope selection
                scope_incremental = "<M-n>", -- increment to the upper scope (as defined in locals.scm)
                node_incremental = "'",      -- increment to the upper named parent
                node_decremental = '"',      -- decrement to the previous node
            },
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
            disable = ts.disable.ctx_commentstr,
            config = {
                c = {__default = "// %s", __multiline = "/* %s */"},
                cpp = {__default = "// %s", __multiline = "/* %s */"},
                css = "/* %s */",
                go = {__default = "// %s", __multiline = "/* %s */"},
                html = "<!-- %s -->",
                json = "",
                jsonc = {__default = "// %s", __multiline = "/* %s */"},
                lua = {__default = "-- %s", __multiline = "--[[ %s ]]", doc = "---%s"},
                markdown = "<!-- %s -->", -- %%
                python = {__default = "# %s", __multiline = '""" %s """'},
                rust = {__default = "// %s", __multiline = "/* %s */", doc = "/// %s"},
                sql = "-- %s",
                typescript = {__default = "// %s", __multiline = "/* %s */"},
                vim = '" %s',
                vimwiki = "<!-- %s -->",
            },
        },
        refactor = {
            highlight_definitions = {enable = false},
            highlight_current_scope = {enable = false},
            smart_rename = {
                enable = true,
                keymaps = {smart_rename = "<A-r>"},
            },
            navigation = {
                enable = true,
                keymaps = {
                    goto_definition = ";D",          -- mapping to go to definition of symbol under cursor
                    list_definitions = "<Leader>fd", -- mapping to list all definitions in current file
                    list_definitions_toc = "<Leader>fo",
                    goto_next_usage = "]y",
                    goto_previous_usage = "[y",
                },
            },
        },
        rainbow = {
            enable = true,
            extended_mode = true,
            max_file_lines = context_vt_max_lines,
            disabled = ts.disable.rainbow,
            -- query = {
            --     "rainbow-parens",
            --     html = "rainbow-tags",
            --     latex = "rainbow-blocks",
            --     javascript = "rainbow-tags-react",
            --     tsx = "rainbow-tags"
            -- },
            -- -- strategy = rainbow.strategy.global,
            -- strategy = {
            --     -- Use global strategy by default
            --     -- rainbow.strategy["global"],
            --     function()
            --         -- Disabled for very large files
            --         local c = api.nvim_buf_line_count(0)
            --         if c > g.treesitter_highlight_maxlines then
            --             return nil
            --         elseif c > 1000 then
            --             return rainbow.strategy["global"]
            --         end
            --         return rainbow.strategy["local"]
            --     end
            -- },
            -- hlgroups = {
            --     "TSRainbowRed",
            --     "TSRainbowYellow",
            --     "TSRainbowBlue",
            --     "TSRainbowOrange",
            --     "TSRainbowGreen",
            --     "TSRainbowViolet",
            --     "TSRainbowCyan"
            -- }
        },
        textobjects = {
            lsp_interop = {
                enable = false,
                border = style.current.border,
                floating_preview_opts = {},
                disable = {},
                peek_definition_code = {},
            },
            select = {
                enable = true,
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
                lookbehind = true,
                disable = ts.disable.textobjects.select,
                keymaps = {
                    -- ["aF"] = "@custom-capture",
                    -- ["as"] = {query = "@scope", query_group = "locals", desc = "Select language scope"},
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
                enable = true,
                set_jumps = true, -- Whether to set jumps in the jumplist
                disable = ts.disable.textobjects.move,
                goto_next_start = {
                    -- . , ; 1 f h A J L N O p P R U X Y
                    -- [] ][
                    --
                    -- ["]o"] = "@loop.*",
                    -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                    --
                    -- Pass query group to use query from `queries/<lang>/<query_group>.scm
                    ["]o"] = {query = "@scope", query_group = "locals", desc = "Next scope"},
                    ["<M-S-m>"] = {query = "@fold", query_group = "folds", desc = "Next TS fold"},
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
                    ["[o"] = {query = "@scope", query_group = "locals", desc = "Next scope"},
                    ["<M-S-n>"] = {query = "@fold", query_group = "folds", desc = "Prev TS fold"},
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
                enable = true,
                disable = ts.disable.textobjects.swap,
                swap_next = {
                    ["s{"] = {query = "@assignment.outer", desc = "Swap next assignment"}, -- swap assignment statements
                    -- ["sj"] = {query = "@assignment.rhs", desc = "Swap prev assignment"},
                    -- ["s="] = {query = "@assignment.inner", desc = "Swap prev assignment"}, -- swap each side of '='
                    -- ["sp"] = {query = "@parameter.inner", desc = "Swap next parameter"},
                    ["sf"] = {query = "@function.outer", desc = "Swap next function"},
                    ["snf"] = {query = "@function.outer", desc = "Swap next function"},
                    ["snb"] = {query = "@block.outer", desc = "Swap next block"},
                    ["snk"] = {query = "@class.outer", desc = "Swap next class"},
                    ["snc"] = {query = "@call.outer", desc = "Swap next call"},
                },
                swap_previous = {
                    ["s}"] = {query = "@assignment.outer", desc = "Swap prev assignment"},
                    -- ["s="] = {query = "@assignment.inner", desc = "Swap assignment = sides"},
                    -- ["sP"] = {query = "@parameter.inner", desc = "Swap prev parameter"},
                    ["sF"] = {query = "@function.outer", desc = "Swap prev function"},
                    ["spf"] = {query = "@function.outer", desc = "Swap prev function"},
                    ["spb"] = {query = "@block.outer", desc = "Swap prev block"},
                    ["spk"] = {query = "@class.outer", desc = "Swap prev class"},
                    ["spc"] = {query = "@call.outer", desc = "Swap prev call"},
                },
            },
        },
    }
end

---Install extra Treesitter parsers
function M.install_extra_parsers()
    -- local parser_config = parsers.get_parser_configs()

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

local function init()
    cmd.packadd("nvim-treesitter-textobjects")
    cmd.packadd("nvim-treesitter")

    ---@class TSPlugin
    ts = {disable = {}, enable = {}}

    ---@class TSPlugin.Enable
    ts.enable = {
        ft = {telescope = true},
        hl = {},
        indent = {},
        autopairs = {},
        fold = {},
        endwise = {},
        matchup = {},
        refactor = {},
        rainbow = {},
        textobjects = {
            select = {},
            move = {},
            swap = {},
        },
        playground = {},
        ctx_commentstr = {},
        query_linter = {},
        incremental_selection = {},
        custom_captures = {
            ["require_call"] = "RequireCall",
            ["utils"] = "Function",
        },
    }

    ---@class TSPlugin.Disabled
    ts.disable = {
        ft = {},
        -- "vimdoc", "markdown", "css", "PKGBUILD", "toml", "perl",
        hl = _t({
            "cmake",
            "comment",
            "html",
            "ini",
            "latex",
            "make",
            "solidity",
            "sxhkdrc",
            "yaml",
            "zsh",
        }),
        indent = {"comment", "git_rebase", "gitattributes", "gitignore", "teal", "vimdoc"},
        -- "vimdoc", "log",
        autopairs = {"comment", "gitignore", "git_rebase", "gitattributes", "markdown"},
        fold = {},
        endwise = {"comment", "git_rebase", "gitattributes", "gitignore", "markdown"},
        matchup = {"comment", "git_rebase", "gitattributes", "gitignore"},
        refactor = {},
        rainbow = BLACKLIST_FT:merge({
            "comment",
            "git_rebase",
            "gitattributes",
            "gitignore",
            "html",
            "markdown",
            "vimdoc",
        }),
        textobjects = {
            select = {"comment", "gitignore", "git_rebase", "gitattributes"},
            move = {"comment", "gitignore", "git_rebase", "gitattributes"},
            swap = {"comment", "gitignore", "git_rebase", "gitattributes"},
        },
        playground = {},
        ctx_commentstr = {},
        query_linter = {},
        incremental_selection = {},
    }
    M.ts = ts

    configs = require("nvim-treesitter.configs")
    parsers = require("nvim-treesitter.parsers")

    M.install_extra_parsers()
    local conf = M.setup()
    configs.setup(conf --[[@as TSConfig]])

    -- M.setup_treesj()
    -- M.setup_iswap()
    -- M.setup_treesurfer()
    -- M.setup_query_secretary()
    -- M.setup_ssr()
    M.setup_gps()
    M.setup_hlargs()
    M.setup_aerial()
    M.setup_context_vt()
    M.setup_autotag()

    local ts_repeat = require("nvim-treesitter.textobjects.repeatable_move")
    -- map({"n", "x", "o"}, "<M-S-}>", ts_repeat.repeat_last_move_next)
    -- map({"n", "x", "o"}, "<M-S-{>", ts_repeat.repeat_last_move_previous)
    map({"n", "x", "o"}, "<Left>", ts_repeat.repeat_last_move_previous, {desc = "TS move prev"})
    map({"n", "x", "o"}, "<Right>", ts_repeat.repeat_last_move_next, {desc = "TS move next"})

    map("x", "iu", [[:<C-u>lua require"treesitter-unit".select()<CR>]], {silent = true})
    map("x", "au", [[:<C-u>lua require"treesitter-unit".select(true)<CR>]], {silent = true})
    map("o", "iu", [[<Cmd>lua require"treesitter-unit".select()<CR>]], {silent = true})
    map("o", "au", [[<Cmd>lua require"treesitter-unit".select(true)<CR>]], {silent = true})

    -- map(
    --     "x",
    --     "iF",
    --     [[:<C-u>lua require('usr.lib.textobj').select('func', true, true)<CR>]],
    --     {silent = true}
    -- )
    -- map(
    --     "x",
    --     "aF",
    --     [[:<C-u>lua require('usr.lib.textobj').select('func', false, true)<CR>]],
    --     {silent = true}
    -- )
    -- map("o", "iF", [[<Cmd>lua require('usr.lib.textobj').select('func', true)<CR>]], {sil = true})
    -- map("o", "aF", [[<Cmd>lua require('usr.lib.textobj').select('func', false)<CR>]], {sil = true})

    -- map("x", "iK", [[:<C-u>lua require('usr.lib.textobj').select('class', true, true)<CR>]])
    -- map("x", "aK", [[:<C-u>lua require('usr.lib.textobj').select('class', false, true)<CR>]])
    -- map("o", "iK", [[<Cmd>lua require('usr.lib.textobj').select('class', true)<CR>]])
    -- map("o", "aK", [[<Cmd>lua require('usr.lib.textobj').select('class', false)<CR>]])

    map("o", "ie", [[<Cmd>execute "norm! m`"<Bar>keepj norm! ggVG<CR>]])
    map("x", "ie", [[:normal! ggVG"<CR>]])
    map("o", "ae", [[:<C-u>normal! HVL"<CR>]])
    map("x", "ae", [[:normal! HVL"<CR>]])

    -- map("x", "aL", "$o0")
    -- map("o", "aL", "<Cmd>norm vaL<CR>")
    -- map("x", "iL", [[<Esc>^vg_]])
    -- map("o", "iL", [[<Cmd>norm! ^vg_<CR>]])

    wk.register(
        {
            ["aL"] = "Line (include newline)",
            ["iL"] = "Line (no newline or spaces)",
            ["ie"] = "Entire buffer",
            ["ae"] = "Entire visible buffer",
            ["au"] = "Around unit",
            ["iu"] = "Inner unit",
        },
        {mode = {"o", "x"}}
    )

    wk.register(
        {
            ["<A-r>"] = "Smart rename",
            [";D"] = "Go to definition under cursor",
            ["<Leader>fd"] = "Quickfix definitions (treesitter)",
            ["<Leader>fo"] = "Quickfix definitions TOC (treesitter)",
            ["[y"] = "Previous usage",
            ["]y"] = "Next usage",
            ["<M-n>"] = "Start scope selection/Increment",
        },
        {mode = "n"}
    )

    map(
        "n",
        "<Leader>sh",
        "TSHighlightCapturesUnderCursor", -- "Inspect"
        {cmd = true, desc = "Highlight capture group"}
    )
    map(
        "n",
        "<Leader>sd",
        "TSPlaygroundToggle", -- "Inspect"
        {cmd = true, desc = "Playground: toggle"}
    )
    map(
        "n",
        "<Leader>s,",
        "TSBufToggle highlight", -- "Inspect"
        {cmd = true, desc = "Toggle TS highlight"}
    )

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
