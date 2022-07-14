local M = {}

local D = require("dev")
if not D.npcall(require, "nvim-treesitter") then
    return
end

local utils = require("common.utils")
local map = utils.map
local color = require("common.color")

local wk = require("which-key")

local ex = nvim.ex
local g = vim.g
local fn = vim.fn
local api = vim.api
local F = vim.F

local ft_enabled
local queries
local parsers
local configs
local ts_disabled

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
            ("@%s.%s"):format(obj, inner and "inner" or "outer"),
            visual and "x" or "o"
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

    -- bytes / lcount < 500 LGTM :)
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

M.setup_hlargs = function()
    ex.packadd("hlargs.nvim")
    local hlargs = D.npcall(require, "hlargs")
    if not hlargs then
        return
    end

    hlargs.setup {
        -- color = "#ef9062",
        -- color = "#cc6666",
        -- color = "#5F875F",
        -- color = "#89b482",
        color = "#ea6962",
        excluded_filetypes = BLACKLIST_FT,
        paint_arg_declarations = true,
        paint_arg_usages = true,
        hl_priority = 10000,
        excluded_argnames = {
            declarations = {},
            usages = {
                python = {"self", "cls"},
                lua = {"self"}
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

M.setup_iswap = function()
    ex.packadd("iswap.nvim")
    local iswap = D.npcall(require, "iswap")
    if not iswap then
        return
    end

    color.set_hl("ISwapSwap", {bg = "#957FB8"})

    iswap.setup {
        keys = "asdfghjkl;",
        grey = "disable",
        hl_snipe = "ISwapSwap",
        hl_selection = "WarningMsg",
        autoswap = true
    }

    wk.register(
        {
            ["vs"] = {"<Cmd>ISwap<CR>", "Swap parameters"}
        }
    )
end

M.setup_autotag = function()
    ex.packadd("nvim-ts-autotag")
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
    ex.packadd("aerial.nvim")
    local aerial = D.npcall(require, "aerial")
    if not aerial then
        return
    end

    local update_delay = 450

    aerial.setup(
        {
            -- Priority list of preferred backends for aerial.
            -- This can be a filetype map (see :help aerial-filetype-map)
            backends = {"treesitter", "markdown" --[[ "lsp" ]]},
            -- Enum: persist, close, auto, global
            --   persist - aerial window will stay open until closed
            --   close   - aerial window will close when original file is no longer visible
            --   auto    - aerial window will stay open as long as there is a visible
            --             buffer to attach to
            --   global  - same as 'persist', and will always show symbols for the current buffer
            close_behavior = "auto",
            -- Set to false to remove the default keybindings for the aerial buffer
            default_bindings = true,
            -- Enum: prefer_right, prefer_left, right, left, float
            -- Determines the default direction to open the aerial window. The 'prefer'
            -- options will open the window in the other direction *if* there is a
            -- different buffer in the way of the preferred direction
            default_direction = "prefer_right",
            -- Disable aerial on files with this many lines
            disable_max_lines = 10000,
            -- Disable aerial on files this size or larger (in bytes)
            disable_max_size = 10000000,
            -- A list of all symbols to display. Set to false to display all symbols.
            -- This can be a filetype map (see :help aerial-filetype-map)
            -- To see all available values, see :help SymbolKind
            -- FIX: Why are only functions, classes, and impls shown?
            filter_kind = false,
            -- filter_kind = {
            --     "Class",
            --     "Constructor",
            --     "Enum",
            --     "Function",
            --     "Interface",
            --     "Module",
            --     "Method",
            --     "Struct",
            --     "Type",
            --     "Field",
            --     "Variable",
            --     "Array"
            -- },
            -- Enum: split_width, full_width, last, none
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
            -- Control which windows and buffers aerial should ignore.
            -- If close_behavior is "global", focusing an ignored window/buffer will
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
                filetypes = _t(BLACKLIST_FT):merge({"gomod"}),
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
            -- When you fold code with za, zo, or zc, update the aerial tree as well.
            -- Only works when manage_folds = true
            link_folds_to_tree = false,
            -- Fold code when you open/collapse symbols in the tree.
            -- Only works when manage_folds = true
            link_tree_to_folds = false,
            -- Use symbol tree for folding. Set to true or false to enable/disable
            -- 'auto' will manage folds if your previous foldmethod was 'manual'
            manage_folds = false,
            -- These control the width of the aerial window.
            -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a list of mixed types.
            -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
            max_width = {40, 0.2},
            width = nil,
            min_width = 10,
            -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
            -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
            nerd_font = "auto",
            -- Call this function when aerial attaches to a buffer.
            -- Useful for setting keymaps. Takes a single `bufnr` argument.
            on_attach = function()
            end,
            -- Automatically open aerial when entering supported buffers.
            -- This can be a function (see :help aerial-open-automatic)
            open_automatic = false,
            -- Set to true to only open aerial at the far right/left of the editor
            -- Default behavior opens aerial relative to current window
            placement_editor_edge = false,
            -- Run this command after jumping to a symbol (false will disable)
            post_jump_cmd = "normal! zz",
            -- When true, aerial will automatically close after jumping to a symbol
            close_on_select = false,
            -- Show box drawing characters for the tree hierarchy
            show_guides = false,
            -- The autocmds that trigger symbols update (not used for LSP backend)
            update_events = "TextChanged,InsertLeave",
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
                -- Enum: cursor, editor, win
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
                override = function(conf)
                    -- This is the config that will be passed to nvim_open_win.
                    -- Change values here to customize the layout
                    return conf
                end
            },
            -- lsp = {
            --     update_when_errors = true,
            --     diagnostics_trigger_update = true,
            --     update_delay = update_delay
            -- },
            treesitter = {
                update_delay = update_delay
            },
            markdown = {
                update_delay = update_delay
            }
            -- on_attach = function(bufnr)
            -- end
        }
    )

    -- Use 'o' to open to the function, not <CR>
    -- local keys = require("aerial.bindings").keys
    -- local dev = require("dev")

    -- local cr_idx =
    --     dev.vec_indexof(
    --     dev.map(
    --         keys,
    --         function(val)
    --             return val[1]
    --         end
    --     ),
    --     "<CR>"
    -- )
    --
    -- local o_idx =
    --     dev.vec_indexof(
    --     dev.map(
    --         keys,
    --         function(val)
    --             return F.if_nil(val[1][1], val[1])
    --         end
    --     ),
    --     "o"
    -- )
    --
    -- keys[cr_idx][1] = "o"
    -- keys[o_idx][1][1] = "<CR>"

    local ts_langs = require("aerial.backends.treesitter.language_kind_map")

    -- Would be nice to get this to work
    ts_langs.rust = {
        enum_item = "Enum",
        function_item = "Function",
        ["closure_expression"] = "Function",
        function_signature_item = "Function",
        impl_item = "Class",
        mod_item = "Module",
        struct_item = "Struct",
        trait_item = "Interface"
    }

    -- ts_langs.rescript = {
    --     ["function"] = "Function",
    --     module_declaration = "Module",
    --     type_declaration = "Type",
    --     type_annotation = "Interface",
    --     external_declaration = "Interface"
    -- }

    wk.register(
        {
            ["<C-'>"] = {"<Cmd>AerialToggle<CR>", "Toggle Aerial"},
            ["[["] = {"<Cmd>AerialPrevUp<CR>", "Aerial previous up"},
            ["]]"] = {"<Cmd>AerialNextUp<CR>", "Aerial next up"},
            ["{"] = {"<Cmd>AerialPrev<CR>", "Aerial previous (anon)"},
            ["}"] = {"<Cmd>AerialNext<CR>", "Aerial next (anon)"}
        }
    )

    wk.register(
        {
            ["[["] = {"<Cmd>AerialPrevUp<CR>", "Aerial previous"},
            ["]]"] = {"<Cmd>AerialNextUp<CR>", "Aerial next"},
            ["{"] = {"<Cmd>AerialPrev<CR>", "Aerial previous (anon)"},
            ["}"] = {"<Cmd>AerialNext<CR>", "Aerial next (anon)"}
        },
        {mode = "x"}
    )

    -- require("telescope").load_extension("aerial")
end

---Setup `nvim_context_vt`
M.setup_context_vt = function()
    ex.packadd("nvim_context_vt")
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
            custom_parser = function(node, ft, opts)
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

M.setup_treesurfer = function()
    ex.packadd("syntax-tree-surfer")
    local sts = D.npcall(require, "syntax-tree-surfer")
    if not sts then
        return
    end

    local default =
        _t(
        {
            "function",
            "function_definition",
            "function_declaration",
            "function_item",
            "method_definition", -- Typescript + others
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
            "class_declaration",
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
                ["closure_expression"] = "",
                ["function_item"] = "",
                ["function_definition"] = "",
                ["function"] = "",
                ["method_definition"] = "",
                ["variable_declaration"] = "",
                ["struct_item"] = "פּ",
                ["enum_item"] = "",
                ["field_declaration"] = "",
                ["enum_variant"] = "",
                ["class_declaration"] = "",
                ["try_statement"] = "",
                ["catch_clause"] = ""
            }
        }
    )

    -- map("n", "<C-A-.>", D.ithunk(sts.targeted_jump, filter), {desc = "Jump to a main node"})
    map("n", "<C-A-,>", D.ithunk(sts.targeted_jump, filter), {desc = "Jump to any node"})
    map("n", "<C-A-[>", D.ithunk(sts.filtered_jump, filter, false), {desc = "Jump to previous important node"})
    map("n", "<C-A-]>", D.ithunk(sts.filtered_jump, filter, true), {desc = "Jump to next important node"})
    map("n", "(", D.ithunk(sts.filtered_jump, "default", false), {desc = "Jump previous main node"})
    map("n", ")", D.ithunk(sts.filtered_jump, "default", true), {desc = "Jump next main node"})

    map(
        "n",
        "<Left>",
        D.ithunk(sts.filtered_jump, {"variable_declaration"}, false),
        {desc = "Jump to previous variable dec"}
    )
    map(
        "n",
        "<Right>",
        D.ithunk(sts.filtered_jump, {"variable_declaration"}, true),
        {desc = "Jump to next variable dec"}
    )

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
    map("x", "<A-[>", '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual")<cr>', {desc = "Previous node"})
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
---@return table
M.setup = function()
    return {
        ensure_installed = {
            -- "css",
            "bash",
            "c",
            "cpp",
            "cmake",
            "d",
            "dart",
            "dockerfile",
            "fennel",
            "gitignore",
            "go",
            "gomod",
            "html",
            "java",
            "javascript",
            "jsdoc",
            "json",
            "kotlin",
            "latex",
            "lua",
            "luap",
            "make",
            "markdown",
            "markdown_inline",
            -- "norg",
            -- Syntax isn't parsed the greatest
            -- "perl",
            "python",
            "query",
            "rasi",
            -- Injections are sent into various filetypes
            "regex",
            -- "rescript",
            "ruby",
            "rust",
            "scheme",
            "scss",
            -- "solidity",
            "sql",
            "teal",
            "typescript",
            "tsx",
            "vue",
            "vim",
            -- "yaml",
            "zig",
            "help"
        },
        sync_install = false,
        ignore_install = {}, -- List of parsers to ignore installing
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = function(ft, bufnr)
                if ts_disabled:contains(ft) or api.nvim_buf_line_count(bufnr or 0) > g.treesitter_highlight_maxlines then
                    return true
                end

                return false
            end,
            use_languagetree = true,
            additional_vim_regex_highlighting = false,
            -- custom_captures = {}
            custom_captures = {
                ["function.call"] = "TSFunction",
                ["function.bracket"] = "Type",
                ["namespace.type"] = "Namespace"
            }
        },
        autotag = {enable = true},
        autopairs = {enable = true, disable = {"help"}},
        -- yati = {enable = true},
        -- tree_docs = {enable = true},
        indent = {enable = true},
        fold = {enable = false},
        endwise = {enable = true},
        matchup = {enable = false, disable_virtual_text = true},
        -- matchup = {enable = true},
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
                go = "// %s",
                sql = "-- %s",
                vim = '" %s'
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
                    list_definitions_toc = "gO",
                    goto_next_usage = "]x",
                    goto_previous_usage = "[x"
                }
            }
        },
        rainbow = {
            enable = true,
            extended_mode = true,
            max_file_lines = 1500,
            disable = {"html", "help"}
            -- colors = {}
        },
        textobjects = {
            lsp_interop = {enable = false},
            select = {
                enable = true,
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
                disable = {"comment"},
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
                }
            },
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
                disable = {"comment", "luapad"},
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
                    -- ["]l"] = "@statement.inner"
                    -- ["gnf"] = "@function.outer",
                    -- ["gnif"] = "@function.inner",
                    -- ["gnp"] = "@parameter.inner",
                    -- ["gnc"] = "@call.outer",
                    -- ["gnic"] = "@call.inner"
                },
                goto_next_end = {
                    -- ["]["] = "@function.outer",
                    ["]F"] = "@function.outer",
                    ["]M"] = "@class.outer",
                    ["]R"] = "@block.outer",
                    ["]A"] = "@call.outer"
                    -- ["gnF"] = "@function.outer",
                    -- ["gniF"] = "@function.inner",
                    -- ["gnP"] = "@parameter.inner",
                    -- ["gnC"] = "@call.outer",
                    -- ["gniC"] = "@call.inner",
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
                    -- ["gpf"] = "@function.outer",
                    -- ["gpif"] = "@function.inner",
                    -- ["gpp"] = "@parameter.inner",
                    -- ["gpc"] = "@call.outer",
                    -- ["gpic"] = "@call.inner",
                },
                goto_previous_end = {
                    -- ["[]"] = "@function.outer",
                    ["[F"] = "@function.outer",
                    ["[R"] = "@block.outer",
                    ["[M"] = "@class.outer",
                    ["[A"] = "@call.outer"
                    -- ["gpF"] = "@function.outer",
                    -- ["gpiF"] = "@function.inner",
                    -- ["gpP"] = "@parameter.inner",
                    -- ["gpC"] = "@call.outer",
                    -- ["gpiC"] = "@call.inner",
                }
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<Leader>.f"] = "@function.outer",
                    ["<Leader>.e"] = "@element"
                    -- ["<Leader>a"] = "@parameter.inner", -- iswap
                },
                swap_previous = {
                    ["<Leader>,f"] = "@function.outer",
                    ["<Leader>,e"] = "@element"
                    -- ["<Leader>A"] = "@parameter.inner",
                }
            }
        }
    }
end

---Install extra Treesitter parsers
function M.install_extra_parsers()
    local parser_config = parsers.get_parser_configs()

    -- gitignore
    parser_config.gitignore = {
        install_info = {
            url = "https://github.com/shunsambongi/tree-sitter-gitignore",
            files = {"src/parser.c"},
            branch = "main"
        },
        filetype = "gitignore"
    }

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
            url = "https://github.com/vhyrro/tree-sitter-luap.git", -- local path or git repo
            files = {"src/parser.c"},
            -- optional entries:
            branch = "main", -- default branch in case of git repo if different from master
            generate_requires_npm = false -- if stand-alone parser without npm dependencies
        },
        filetype = "luap" -- if filetype does not match the parser name
    }
end

local function init()
    ex.packadd("nvim-treesitter")
    ex.packadd("nvim-treesitter-textobjects")

    ts_disabled =
        _t(
        {
            "help",
            "html",
            "comment",
            "zsh",
            "markdown"
        }
    )

    configs = require("nvim-treesitter.configs")
    parsers = require("nvim-treesitter.parsers")

    M.install_extra_parsers()
    local conf = M.setup()

    configs.setup(conf)

    -- cmd("au! NvimTreesitter FileType *")
    -- M.setup_comment_frame()

    M.setup_iswap()
    M.setup_hlargs()
    M.setup_aerial()
    M.setup_context_vt()
    M.setup_treesurfer()
    M.setup_autotag()

    map("x", "iu", [[:<C-u>lua require"treesitter-unit".select()<CR>]])
    map("x", "au", [[:<C-u>lua require"treesitter-unit".select(true)<CR>]])
    map("o", "iu", [[<Cmd>lua require"treesitter-unit".select()<CR>]])
    map("o", "au", [[<Cmd>lua require"treesitter-unit".select(true)<CR>]])

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

    -- This doesn't work
    -- map(
    --     {"x", "o"},
    --     "ae",
    --     function()
    --         local scrolloff = opt_local.scrolloff:get()
    --         opt_local.scrolloff = 0
    --         ex.normal_('HVL"')
    --         opt_local.scrolloff = scrolloff
    --     end
    -- )

    wk.register(
        {
            ["<Leader>.f"] = "Swap next function",
            ["<Leader>.e"] = "Swap next element",
            ["<Leader>,f"] = "Swap previous function",
            ["<Leader>,e"] = "Swap previous element"
        }
    )

    wk.register(
        {
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
            ["<Leader>fd"] = "List all definitions in file",
            ["gO"] = "List all definitions in TOC",
            ["[x"] = "Previous usage",
            ["]x"] = "Next usage",
            ["<M-n>"] = "Start scope selection/Increment",
            ["[["] = "Aerial prevous function",
            ["]]"] = "Aerial next function",
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
    map("o", ",", [[<Cmd>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("n", "vx", [[<Cmd>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("n", '<C-S-">', [[<Cmd>lua require('tsht').jump_nodes()<CR>]], {desc = "Treesiter jump node"})

    queries = require("nvim-treesitter.query")
    local cfhl = conf.highlight.disable
    local hl_disabled = F.tern(type(cfhl) == "function", ts_disabled, cfhl)
    ft_enabled = {"telescope"}
    for _, lang in ipairs(conf.ensure_installed) do
        if not vim.tbl_contains(hl_disabled, lang) then
            local parser = parsers.list[lang]
            local used_by, filetype = parser.used_by, parser.filetype
            if used_by then
                for _, ft in ipairs(used_by) do
                    ft_enabled[ft] = true
                end
            end
            ft_enabled[filetype or lang] = true
        end
    end
end

-- function M.init_hl()
--     local ts = vim.treesitter
--     local bufnr = api.nvim_get_current_buf()
--     local ok, parser = pcall(ts.get_parser, bufnr)
--     if not ok then
--         return
--     end
--     local get_query = require("nvim-treesitter.query").get_query
--     local query
--     ok, query = pcall(get_query, parser._lang, "highlights")
--     if ok and query then
--         ts.highlighter.new(parser, query)
--         api.nvim_buf_attach(
--             bufnr,
--             false,
--             {
--                 on_detach = function(_, b)
--                     if ts.highlighter.active[b] then
--                         ts.highlighter.active[b]:destroy()
--                     end
--                 end
--             }
--         )
--     end
-- end

init()

return M
