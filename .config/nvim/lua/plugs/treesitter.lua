local M = {}

local D = require("dev")
if not D.npcall(require, "nvim-treesitter") then
    return
end

local _ = D.ithunk
local utils = require("common.utils")
local map = utils.map
local hl = require("common.color")

local colors = require("kimbox.colors")
local wk = require("which-key")

local cmd = vim.cmd
local g = vim.g
local fn = vim.fn
local api = vim.api
local F = vim.F

local custom_captures
local ts_hl_disabled
local ft_enabled
local queries
local parsers
local configs

local context_vt_max_lines = 2000

---Check whether there are text-objects available
---@param ft string
---@return boolean
function M.has_textobj(ft)
    return queries.get_query(parsers.ft_to_lang(ft), "textobjects") ~= nil and true or false
end

---Perform an action on a text object (i.e., select or operator pending)
---@param obj string text object to act on
---@param inner boolean act on inner or outer object
---@param visual boolean visual mode or operator pending
---@return boolean
function M.do_textobj(obj, inner, visual)
    local ret = false
    if queries.has_query_files(vim.bo.ft, "textobjects") then
        require("nvim-treesitter.textobjects.select").select_textobject(
            ("@%s.%s"):format(obj, F.tern(inner, "inner", "outer")),
            F.tern(visual, "x", "o")
        )
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
        if ft_enabled[ft] then
            configs.reattach_module("highlight", bufnr)
            vim.defer_fn(
                function()
                    configs.reattach_module("textobjects.move", bufnr)
                end,
                300
            )
        else
            vim.bo.syntax = ft
        end
    end
end

M.setup_gps = function()
    cmd.packadd("nvim-gps")
    local gps = D.npcall(require, "nvim-gps")
    if not gps then
        return
    end

    gps.setup(
        {
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
                ["typedef-name"] = " "
            },
            separator = " » ", --  淪輪‣ »
            depth = 4,
            depth_limit_indicator = ".."
        }
    )
end

M.setup_hlargs = function()
    cmd.packadd("hlargs.nvim")
    local hlargs = D.npcall(require, "hlargs")
    if not hlargs then
        return
    end

    hlargs.setup {
        color = g.colors_name == "kimbox" and colors.salmon or nil,
        excluded_filetypes = BLACKLIST_FT,
        paint_arg_declarations = true,
        paint_arg_usages = true,
        hl_priority = 10000,
        excluded_argnames = {
            declarations = {"use", "use_rocks", "_"},
            usages = {
                python = {"cls", "self"},
                go = {"_"},
                rust = {"_", "self"},
                lua = {"_", "self", "use", "use_rocks"}
            }
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
                slow_parse = 5000
            }
        }
    }
end

M.setup_ssr = function()
    cmd.packadd("ssr.nvim")
    local ssr = D.npcall(require, "ssr")
    if not ssr then
        return
    end

    ssr.setup(
        {
            min_width = 50,
            min_height = 5,
            max_width = 120,
            max_height = 25,
            keymaps = {
                close = "q",
                next_match = "n",
                prev_match = "N",
                replace_confirm = "<CR>",
                replace_all = "<S-CR>"
            }
        }
    )

    map({"n", "x"}, "<Leader>s;", D.ithunk(ssr.open), {desc = "Open SSR"})
end

M.setup_iswap = function()
    cmd.packadd("iswap.nvim")
    local iswap = D.npcall(require, "iswap")
    if not iswap then
        return
    end

    hl.set("ISwapSwap", {bg = colors.oni_violet})

    iswap.setup {
        keys = "asdfghjkl;",
        grey = "disable",
        hl_snipe = "ISwapSwap",
        hl_selection = "WarningMsg",
        flash_style = "simultaneous", -- sequential
        hl_flash = "ModeMsg",
        autoswap = true
    }

    wk.register(
        {
            ["vs"] = {"<Cmd>ISwap<CR>", "Swap parameters (ISwap)"},
            ["sv"] = {"<Cmd>ISwap<CR>", "Swap parameters (ISwap)"}
        }
    )
end

M.setup_autotag = function()
    cmd.packadd("nvim-ts-autotag")
    local autotag = D.npcall(require, "nvim-ts-autotag")
    if not autotag then
        return
    end

    autotag.setup {
        filetypes = {
            "html",
            "xml",
            "xhtml",
            "phtml",
            "javascript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
            "vue"
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
            "menuitem"
        }
    }
end

---Setup `aerial`
M.setup_aerial = function()
    cmd.packadd("aerial.nvim")
    local aerial = D.npcall(require, "aerial")
    if not aerial then
        return
    end

    local update_delay = 450

    aerial.setup(
        {
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
                preserve_equality = false
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
            default_bindings = true,
            -- When true, don't load aerial until a command or function is called
            -- Defaults to true, unless `on_attach` is provided, then it defaults to false
            lazy_load = true,
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
                "Array"
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
                unlisted_buffers = true,
                -- List of filetypes to ignore.
                filetypes = _t(BLACKLIST_FT):merge({"gomod", "help"}),
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
                wintypes = "special"
            },
            -- Use symbol tree for folding. Set to true or false to enable/disable
            -- 'auto' will manage folds if your previous foldmethod was 'manual'
            manage_folds = false,
            -- When you fold code with za, zo, or zc, update the aerial tree as well.
            -- Only works when manage_folds = true
            link_folds_to_tree = false,
            -- Fold code when you open/collapse symbols in the tree.
            -- Only works when manage_folds = true
            link_tree_to_folds = true,
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
                whitespace = "  "
            },
            -- Options for opening aerial in a floating win
            float = {
                -- Controls border appearance. Passed to nvim_open_win
                border = "rounded",
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
                end
            },
            lsp = {
                -- Fetch document symbols when LSP diagnostics update.
                -- If false, will update on buffer changes.
                diagnostics_trigger_update = true,
                -- Set to false to not update the symbols when there are LSP errors
                update_when_errors = true,
                -- How long to wait (in ms) after a buffer change before updating
                -- Only used when diagnostics_trigger_update = false
                update_delay = update_delay
            },
            treesitter = {
                -- How long to wait (in ms) after a buffer change before updating
                update_delay = update_delay
            },
            markdown = {
                -- How long to wait (in ms) after a buffer change before updating
                update_delay = update_delay
            },
            man = {
                -- How long to wait (in ms) after a buffer change before updating
                update_delay = update_delay
            }
        }
    )

    wk.register(
        {
            ["<C-'>"] = {"<Cmd>AerialToggle<CR>", "Toggle Aerial"},
            ["[["] = {aerial.prev_up, "Aerial previous up"},
            ["]]"] = {aerial.next_up, "Aerial next up"},
            ["{"] = {aerial.prev, "Aerial previous (anon)"},
            ["}"] = {aerial.next, "Aerial next (anon)"}
        }
    )

    wk.register(
        {
            ["[["] = {aerial.prev_up, "Aerial previous"},
            ["]]"] = {aerial.next_up, "Aerial next"},
            ["{"] = {aerial.prev, "Aerial previous (anon)"},
            ["}"] = {aerial.next, "Aerial next (anon)"}
        },
        {mode = "x"}
    )

    -- require("telescope").load_extension("aerial")
end

---Setup `nvim_context_vt`
M.setup_context_vt = function()
    cmd.packadd("nvim_context_vt")
    local ctx = D.npcall(require, "nvim_context_vt")
    if not ctx then
        return
    end

    ctx.setup(
        {
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
            end
        }
    )
end

M.setup_context = function()
    cmd.packadd("treesitter-context")
    local tctx = D.npcall(require, "treesitter-context")
    if not tctx then
        return
    end

    tctx.setup {
        enable = true,
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        trim_scope = "outer", -- Choices: 'inner', 'outer'
        patterns = {
            -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
            -- For all filetypes
            -- Note that setting an entry here replaces all other patterns for this entry.
            -- By setting the 'default' entry below, you can control which nodes you want to
            -- appear in the context window.
            default = {
                "class",
                "function",
                "method",
                "for", -- These won't appear in the context
                "field",
                "if"
                -- 'while',
                -- 'if',
                -- 'switch',
                -- 'case',
            }
            -- Example for a specific filetype.
            -- If a pattern is missing, *open a PR* so everyone can benefit.
            --   rust = {
            --       'impl_item',
            --   },
        },
        exact_patterns = {},
        -- [!] The options below are exposed but shouldn't require your attention,
        --     you can safely ignore them.

        zindex = 20, -- The Z-index of the context window
        mode = "cursor" -- Line used to calculate context. Choices: 'cursor', 'topline'
    }
end

M.setup_treesurfer = function()
    cmd.packadd("syntax-tree-surfer")
    local sts = D.npcall(require, "syntax-tree-surfer")
    if not sts then
        return
    end

    local vars = {
        "variable_declaration",
        "let_declaration"
    }

    local default =
        _t(
        {
            "function",
            "arrow_function",
            "function_definition",
            "function_declaration",
            "function_item",
            "method_definition",
            "macro_definition",
            "closure_expression",
            "if_statement",
            "if_expression",
            "if_let_expression",
            "else_clause",
            "else_statement",
            "elseif_statement",
            "for_statement",
            "for_expression",
            "while_statement",
            "switch_statement",
            "match_expression",
            "struct_item",
            "enum_item",
            "interface_declaration",
            "class_declaration",
            "class_name",
            "impl_item",
            "try_statement",
            "catch_clause"
        }
    )

    local filter =
        default:merge(
        {
            -- "function_call",
            "field_declaration", -- rust struct
            "enum_variant" -- rust enum
        }
    )

    sts.setup(
        {
            highlight_group = "STS_highlight", -- HopNextKey
            disable_no_instance_found_report = false,
            default_desired_types = default,
            left_hand_side = "fdsawervcxqtzb",
            right_hand_side = "jkl;oiu.,mpy/n",
            icon_dictionary = {
                ["if_statement"] = "",
                ["if_expression"] = "",
                ["if_let_expression"] = "",
                ["else_clause"] = "",
                ["else_statement"] = "",
                ["elseif_statement"] = "",
                ["for_statement"] = "",
                ["for_expression"] = "",
                ["while_statement"] = "菱",
                ["switch_statement"] = "",
                ["match_expression"] = "",
                ["macro_definition"] = "",
                ["closure_expression"] = "",
                ["function_item"] = "",
                ["function_definition"] = "",
                ["function"] = "",
                ["arrow_function"] = "",
                ["method_definition"] = "",
                ["variable_declaration"] = "",
                ["let_declaration"] = "",
                ["struct_item"] = "פּ",
                ["enum_item"] = "",
                ["enum_variant"] = "",
                ["field_declaration"] = "",
                ["interface_declaration"] = "",
                ["class_declaration"] = "",
                ["class_name"] = "",
                ["impl_item"] = "ﴯ",
                ["try_statement"] = "",
                ["catch_clause"] = ""
            }
        }
    )

    -- map("n", "<C-A-.>", _(sts.targeted_jump, filter), {desc = "Jump to a main node"})
    map("n", "<C-A-,>", _(sts.targeted_jump, filter), {desc = "Jump to any node"})
    map("n", "<C-A-[>", _(sts.filtered_jump, filter, false), {desc = "Prev important node"})
    map("n", "<C-A-]>", _(sts.filtered_jump, filter, true), {desc = "Next important node"})
    map("n", "(", _(sts.filtered_jump, "default", false), {desc = "Prev main node"})
    map("n", ")", _(sts.filtered_jump, "default", true), {desc = "Next main node"})

    map("n", "<Left>", _(sts.filtered_jump, vars, false), {desc = "Prev var declaration"})
    map("n", "<Right>", _(sts.filtered_jump, vars, true), {desc = "Next var declaration"})

    map(
        "n",
        "vu",
        function()
            vim.opt.opfunc = "v:lua.STSSwapUpNormal_Dot"
            return "g@l"
        end,
        {silent = true, expr = true, desc = "Swap node up"}
    )

    map(
        "n",
        "vd",
        function()
            vim.opt.opfunc = "v:lua.STSSwapDownNormal_Dot"
            return "g@l"
        end,
        {silent = true, expr = true, desc = "Swap node down"}
    )

    map(
        "n",
        "vD",
        function()
            vim.opt.opfunc = "v:lua.STSSwapCurrentNodeNextNormal_Dot"
            return "g@l"
        end,
        {silent = true, expr = true, desc = "Swap cursor node w/ next sibling"}
    )

    map(
        "n",
        "vU",
        function()
            vim.opt.opfunc = "v:lua.STSSwapCurrentNodePrevNormal_Dot"
            return "g@l"
        end,
        {silent = true, expr = true, desc = "Swap cursor node w/ prev sibling"}
    )

    -- map("n", "vd", '<cmd>lua require("syntax-tree-surfer").move("n", false)<cr>', {desc = "Swap next node"})
    -- map("n", "vu", '<cmd>lua require("syntax-tree-surfer").move("n", true)<cr>', {desc = "Swap previous node"})

    map("n", "vn", '<cmd>lua require("syntax-tree-surfer").select()<cr>', {desc = "Select node"})
    map("n", "vm", '<cmd>lua require("syntax-tree-surfer").select_current_node()<cr>', {desc = "Select current node"})

    map("x", "<A-]>", '<cmd>lua require("syntax-tree-surfer").surf("next", "visual")<cr>', {desc = "Next node"})
    map("x", "<A-[>", '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual")<cr>', {desc = "Prev node"})
    map("x", "<C-k>", '<cmd>lua require("syntax-tree-surfer").surf("parent", "visual")<cr>', {desc = "Parent node"})
    map("x", "<C-j>", '<cmd>lua require("syntax-tree-surfer").surf("child", "visual")<cr>', {desc = "Child node"})

    map(
        "x",
        "<C-A-]>",
        '<cmd>lua require("syntax-tree-surfer").surf("next", "visual", true)<cr>',
        {desc = "Swap next node"}
    )
    map(
        "x",
        "<C-A-[>",
        '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual", true)<cr>',
        {desc = "Swap previous node"}
    )
end

---Setup treesitter
---@return TSConfig
M.setup = function()
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
            -- "gitconfig",
            "git_rebase",
            "gitattributes",
            "gitcommit",
            "gitignore",
            "go",
            "gomod",
            "gosum",
            "gowork",
            "graphql",
            "help",
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
            "log",
            "lua",
            "luap",
            "make",
            "markdown",
            "markdown_inline",
            -- "norg",
            -- "norg_meta",
            -- "norg_table",
            "ninja",
            -- "perl", -- Syntax isn't parsed the greatest
            "python",
            "query",
            "rasi",
            "regex",
            "ron",
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
            "vim",
            "vue",
            "yaml",
            "zig"
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {}, -- List of parsers to ignore installing
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = function(ft, bufnr)
                if ts_hl_disabled:contains(ft) or api.nvim_buf_line_count(bufnr or 0) > g.treesitter_highlight_maxlines then
                    return true
                end

                return false
            end,
            use_languagetree = true,
            -- additional_vim_regex_highlighting = true,
            additional_vim_regex_highlighting = {"perl", "latex"},
            custom_captures = custom_captures
        },
        autotag = {enable = true},
        autopairs = {
            enable = true,
            disable = {"help", "comment", "log", "gitignore", "git_rebase", "gitattributes", "markdown"}
        },
        indent = {
            enable = true,
            disable = {"comment", "log", "gitignore", "git_rebase", "gitattributes", "markdown"}
        },
        fold = {enable = false},
        endwise = {
            enable = true,
            disable = {"comment", "log", "gitignore", "git_rebase", "gitattributes", "markdown"}
        },
        matchup = {
            enable = true,
            disable_virtual_text = true,
            disable = {"comment", "log", "gitignore", "git_rebase", "gitattributes"},
            include_match_words = true,
            matchparen_offscreen = {method = "popup"}
        },
        playground = {
            enable = true,
            disable = {},
            updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
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
                show_help = "?"
            }
        },
        query_linter = {
            enable = true,
            use_virtual_text = true,
            lint_events = {"BufWrite", "CursorHold"}
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<M-n>", -- maps in normal mode to init the node/scope selection
                scope_incremental = "<M-n>", -- increment to the upper scope (as defined in locals.scm)
                node_incremental = "'", -- increment to the upper named parent
                node_decremental = '"' -- decrement to the previous node
            }
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
            disable = {"help"},
            config = {
                c = "// %s",
                css = "/* %s */",
                go = "// %s",
                html = "<!-- %s -->",
                json = "",
                jsonc = "// %s",
                scss = "/* %s */",
                sql = "-- %s",
                svelte = "<!-- %s -->",
                typescript = "// %s",
                vim = '" %s',
                vue = "<!-- %s -->"
            }
        },
        refactor = {
            highlight_definitions = {enable = false},
            highlight_current_scope = {enable = false},
            smart_rename = {
                enable = true,
                keymaps = {
                    smart_rename = "<A-r>" -- mapping to rename reference under cursor
                }
            },
            navigation = {
                enable = true,
                keymaps = {
                    goto_definition = ";D", -- mapping to go to definition of symbol under cursor
                    list_definitions = "<Leader>fd", -- mapping to list all definitions in current file
                    list_definitions_toc = "<Leader>fo",
                    goto_next_usage = "]x",
                    goto_previous_usage = "[x"
                }
            }
        },
        rainbow = {
            enable = true,
            extended_mode = true,
            max_file_lines = 1500,
            disable = {"html", "help", "comment", "log", "gitignore", "git_rebase", "gitattributes", "markdown"}
        },
        textobjects = {
            lsp_interop = {enable = false},
            lookahead = true,
            select = {
                enable = true,
                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace. Succeeding
                -- whitespace has priority in order to act similarly to eg the built-in
                -- `ap`.
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * selection_mode: eg 'v'
                -- and should return true of false
                include_surrounding_whitespace = true,
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
                disable = {"comment", "log", "gitignore", "git_rebase", "gitattributes"},
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ak"] = "@class.outer",
                    ["ik"] = "@class.inner",
                    ["ac"] = "@call.outer",
                    ["ic"] = "@call.inner",
                    ["ao"] = "@block.outer",
                    ["io"] = "@block.inner",
                    ["ad"] = "@comment.outer",
                    ["id"] = "@comment.inner",
                    ["ag"] = "@conditional.outer",
                    ["ig"] = "@conditional.inner",
                    ["aj"] = "@parameter.outer",
                    ["ij"] = "@parameter.inner",
                    ["aS"] = "@statement.outer",
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner"
                },
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ["@parameter.outer"] = "v", -- charwise
                    ["@function.outer"] = "V", -- linewise
                    ["@class.outer"] = "<c-v>" -- blockwise
                }
            },
            -- @attribute.inner
            -- @attribute.outer
            -- @block.inner
            -- @block.outer
            -- @call.inner
            -- @call.outer
            -- @class.inner
            -- @class.outer
            -- @comment.outer
            -- @conditional.inner
            -- @conditional.outer
            -- @frame.inner
            -- @frame.outer
            -- @function.inner
            -- @function.outer
            -- @loop.inner
            -- @loop.outer
            -- @parameter.inner
            -- @parameter.outer
            -- @scopename.inner
            -- @statement.outer
            move = {
                enable = true,
                set_jumps = true, -- Whether to set jumps in the jumplist
                disable = {"comment", "log", "gitignore", "git_rebase", "gitattributes"},
                goto_next_start = {
                    -- ["]]"] = "@function.outer",
                    ["]f"] = "@function.outer",
                    ["]m"] = "@class.outer",
                    ["]r"] = "@block.outer",
                    ["]C"] = "@comment.outer",
                    ["]j"] = "@parameter.inner",
                    ["]a"] = "@call.inner",
                    ["]l"] = "@loop.inner",
                    ["]d"] = "@conditional.inner"
                },
                goto_next_end = {
                    ["]F"] = "@function.outer",
                    ["]M"] = "@class.outer",
                    ["]R"] = "@block.outer",
                    ["]A"] = "@call.outer"
                },
                goto_previous_start = {
                    -- ["[["] = "@function.outer",
                    ["[f"] = "@function.outer",
                    ["[m"] = "@class.outer",
                    ["[r"] = "@block.outer",
                    ["[C"] = "@comment.outer",
                    ["[j"] = "@parameter.inner",
                    ["[a"] = "@call.inner",
                    ["[l"] = "@loop.inner",
                    ["[d"] = "@conditional.inner"
                },
                goto_previous_end = {
                    ["[F"] = "@function.outer",
                    ["[R"] = "@block.outer",
                    ["[M"] = "@class.outer",
                    ["[A"] = "@call.outer"
                }
            },
            swap = {
                enable = true,
                swap_next = {
                    ["s."] = "@element",
                    ["sp"] = "@parameter.inner",
                    ["sf"] = "@function.outer",
                    ["sc"] = "@class.outer",
                    ["sb"] = "@block.outer"
                },
                swap_previous = {
                    ["s,"] = "@element",
                    ["sP"] = "@parameter.inner",
                    ["sF"] = "@function.outer",
                    ["sC"] = "@class.outer",
                    ["sB"] = "@block.outer"
                }
            }
        }
    }
end

---Install extra Treesitter parsers
function M.install_extra_parsers()
    local parser_config = parsers.get_parser_configs()

    -- SQL
    parser_config.sql = {
        install_info = {
            url = "https://github.com/DerekStride/tree-sitter-sql",
            files = {"src/parser.c"},
            branch = "main"
        },
        filetype = "sql"
    }

    -- Using this parsers own queries does not work
    -- Solidity
    parser_config.solidity = {
        install_info = {
            url = "https://github.com/JoranHonig/tree-sitter-solidity",
            files = {"src/parser.c"},
            requires_generate_from_grammar = true
        },
        filetype = "solidity"
    }

    -- Lua regex
    parser_config.luap = {
        install_info = {
            url = "https://github.com/vhyrro/tree-sitter-luap", -- local path or git repo
            files = {"src/parser.c"},
            -- optional entries:
            branch = "main", -- default branch in case of git repo if different from master
            generate_requires_npm = false -- if stand-alone parser without npm dependencies
        },
        filetype = {"luap", "lua"} -- if filetype does not match the parser name
    }

    -- Log files
    parser_config.log = {
        install_info = {
            url = "https://github.com/lpraneis/tree-sitter-tracing-log",
            files = {"src/parser.c"},
            branch = "main", -- default branch in case of git repo if different from master
            generate_requires_npm = false, -- if stand-alone parser without npm dependencies
            requires_generate_from_grammar = false -- if folder contains pre-generated src/parser.c
        },
        filetype = "log"
    }

    -- parser_config.jq = {
    --     install_info = {
    --         url = "https://github.com/flurie/tree-sitter-jq",
    --         files = {"src/parser.c"},
    --         branch = "main", -- default branch in case of git repo if different from master
    --         generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    --         requires_generate_from_grammar = false -- if folder contains pre-generated src/parser.c
    --     },
    --     filetype = "jq"
    -- }

    -- Norg
    -- parser_config.norg = {
    --     install_info = {
    --         url = "https://github.com/nvim-neorg/tree-sitter-norg",
    --         files = {"src/parser.c", "src/scanner.cc"},
    --         branch = "main"
    --     }
    -- }

    -- Norg Table
    -- parser_config.norg_table = {
    --     install_info = {
    --         url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
    --         files = {"src/parser.c"},
    --         branch = "main"
    --     }
    -- }

    -- Norg Meta
    -- parser_config.norg_meta = {
    --     install_info = {
    --         url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
    --         branch = "main",
    --         files = {"src/parser.c"}
    --     }
    -- }

    -- Git config
    -- parser_config.gitconfig = {
    --     install_info = {
    --         url = "https://github.com/the-mikedavis/tree-sitter-git-config",
    --         files = {"src/parser.c"},
    --         branch = "main",
    --         generate_requires_npm = true, -- if stand-alone parser without npm dependencies
    --         requires_generate_from_grammar = false -- if folder contains pre-generated src/parser.c
    --     },
    --     filetype = "gitconfig"
    -- }
end

-- M.setup_query_secretary = function()
--     map("n", "<Leader>qu", "require('query-secretary').query_window_initiate()", {luacmd = true})
-- end

local function init()
    cmd.packadd("nvim-treesitter")
    cmd.packadd("nvim-treesitter-textobjects")

    custom_captures =
        _t(
        {
            ["todo"] = "Todo",
            ["require_call"] = "RequireCall",
            ["function.bracket"] = "Type",
            ["namespace.type"] = "TSNamespaceType",
            ["function_definition"] = "FunctionDefinition",
            ["quantifier"] = "Special",
            ["utils"] = "Function",
            ["code"] = "Comment",
            ["rust_path"] = "String"
        }
    )

    ts_hl_disabled =
        _t(
        {
            "help",
            "html",
            "comment",
            "markdown",
            "yaml",
            "css",
            "latex",
            "make",
            "cmake",
            "zsh",
            "solidity"
            -- "toml",
        }
    )

    configs = require("nvim-treesitter.configs")
    parsers = require("nvim-treesitter.parsers")

    M.install_extra_parsers()
    local conf = M.setup()

    -- require("nvim-treesitter.highlight").set_custom_captures(custom_captures)
    configs.setup(conf)

    -- M.setup_comment_frame()
    -- M.setup_context()
    -- M.setup_query_secretary()

    M.setup_gps()
    -- M.setup_ssr()
    M.setup_iswap()
    M.setup_hlargs()
    M.setup_aerial()
    M.setup_context_vt()
    M.setup_treesurfer()
    M.setup_autotag()

    map("x", "iu", [[:<C-u>lua require"treesitter-unit".select()<CR>]], {silent = true})
    map("x", "au", [[:<C-u>lua require"treesitter-unit".select(true)<CR>]], {silent = true})
    map("o", "iu", [[<Cmd>lua require"treesitter-unit".select()<CR>]], {silent = true})
    map("o", "au", [[<Cmd>lua require"treesitter-unit".select(true)<CR>]], {silent = true})

    map("x", "iF", [[:<C-u>lua require('common.textobj').select('func', true, true)<CR>]])
    map("x", "aF", [[:<C-u>lua require('common.textobj').select('func', false, true)<CR>]])
    map("o", "iF", [[<Cmd>lua require('common.textobj').select('func', true)<CR>]])
    map("o", "aF", [[<Cmd>lua require('common.textobj').select('func', false)<CR>]])

    map("x", "iK", [[:<C-u>lua require('common.textobj').select('class', true, true)<CR>]])
    map("x", "aK", [[:<C-u>lua require('common.textobj').select('class', false, true)<CR>]])
    map("o", "iK", [[<Cmd>lua require('common.textobj').select('class', true)<CR>]])
    map("o", "aK", [[<Cmd>lua require('common.textobj').select('class', false)<CR>]])

    -- map("o", "ie", [[:<C-u>normal! ggVG"<CR>]])
    map("o", "ie", [[<Cmd>execute "norm! m`"<Bar>keepj norm! ggVG<CR>]])
    map("x", "ie", [[:normal! ggVG"<CR>]])
    map("o", "ae", [[:<C-u>normal! HVL"<CR>]])
    map("x", "ae", [[:normal! HVL"<CR>]])

    map("x", "aL", "$o0")
    map("o", "aL", "<Cmd>norm vaL<CR>")
    map("x", "iL", [[<Esc>^vg_]])
    map("o", "iL", [[<Cmd>norm! ^vg_<CR>]])

    wk.register(
        {
            ["sf"] = "Swap next function",
            ["sF"] = "Swap previous function",
            ["sp"] = "Swap next parameter",
            ["sP"] = "Swap previous parameter",
            ["sb"] = "Swap next block",
            ["sB"] = "Swap previous block",
            ["sc"] = "Swap next class",
            ["sC"] = "Swap previous class",
            ["s."] = "Swap next element",
            ["s,"] = "Swap previous element"
        }
    )

    wk.register(
        {
            ["aL"] = "Line (include newline)",
            ["iL"] = "Line (no newline or spaces)",
            ["ie"] = "Entire buffer",
            ["ae"] = "Entire visible buffer",
            ["ac"] = "Around call",
            ["ic"] = "Inner call",
            ["ao"] = "Around block",
            ["io"] = "Inner block",
            ["ad"] = "Around comment",
            ["id"] = "Inner comment",
            ["ag"] = "Around conditional",
            ["ig"] = "Inner conditional",
            ["aj"] = "Around parameter",
            ["ij"] = "Inner parameter",
            ["al"] = "Around loop",
            ["il"] = "Inner loop",
            ["au"] = "Around unit",
            ["iu"] = "Inner unit",
            ["af"] = "Around function",
            ["if"] = "Inner function",
            ["ak"] = "Around class",
            ["ik"] = "Inner class",
            ["ai"] = "Indentation level and line above",
            ["ii"] = "Inner Indentation level (no line above)",
            ["aI"] = "Indention level and lines above/below",
            ["iI"] = "Inner Indentation level (no lines above/below)",
            ["aS"] = "Around statement"
        },
        {mode = "o"}
    )

    wk.register(
        {
            ["<A-r>"] = "Smart rename",
            [";D"] = "Go to definition under cursor",
            ["<Leader>fd"] = "Quickfix definitions (treesitter)",
            ["<Leader>fo"] = "Quickfix definitions TOC (treesitter)",
            ["[x"] = "Previous usage",
            ["]x"] = "Next usage",
            ["<M-n>"] = "Start scope selection/Increment",
            ["]f"] = "Next function start",
            ["]m"] = "Next class start",
            ["]r"] = "Next block start",
            ["]C"] = "Next comment start",
            ["]j"] = "Next parameter start",
            ["]a"] = "Next call start",
            ["]l"] = "Next loop start",
            ["]d"] = "Next conditional start",
            ["]F"] = "Next function end",
            ["]M"] = "Next class end",
            ["]R"] = "Next block end",
            ["]A"] = "Next call end",
            ["[f"] = "Previous function start",
            ["[m"] = "Previous class start",
            ["[r"] = "Previous block start",
            ["[d"] = "Previous conditional start",
            ["[j"] = "Previous parameter start",
            ["[a"] = "Previous call start",
            ["[l"] = "Previous loop start",
            ["[C"] = "Previous comment start",
            ["[F"] = "Previous function end",
            ["[R"] = "Previous block end",
            ["[M"] = "Previous class end",
            ["[A"] = "Previous call end"
        },
        {mode = "n"}
    )

    require("tsht").config.hint_keys = {"h", "j", "f", "d", "n", "v", "s", "l", "a"}
    map("x", ",", [[:<C-u>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("o", ",", [[require('tsht').nodes()]], {desc = "Treesitter node select", luacmd = true})
    map("n", "vx", [[require('tsht').nodes()]], {desc = "Treesitter node select", luacmd = true})
    -- map("n", '<C-S-">', [[<Cmd>lua require('tsht').jump_nodes()<CR>]], {desc = "Treesiter jump node"})
    -- hl.set("TSNodeUnmatched", {fg = "#666666"})

    map("n", "<Leader>sh", "TSHighlightCapturesUnderCursor", {cmd = true, desc = "Highlight capture group"})

    queries = require("nvim-treesitter.query")
    -- local cfhl = conf.highlight.disable
    -- local hl_disabled = type(cfhl) == "function" and ts_hl_disabled or cfhl
    -- ft_enabled = {telescope = true}
    -- for _, lang in ipairs(conf.ensure_installed) do
    --     if not vim.tbl_contains(hl_disabled, lang) then
    --         local parser = parsers.list[lang]
    --         local filetype = parser.filetype
    --         ft_enabled[filetype or lang] = true
    --     end
    -- end
end

init()

return M
