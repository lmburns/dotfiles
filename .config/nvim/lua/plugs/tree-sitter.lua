local M = {}

local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd
local color = require("common.color")

local wk = require("which-key")

local ft_enabled
local queries
local parsers
local configs

function M.has_textobj(ft)
    return queries.get_query(parsers.ft_to_lang(ft), "textobjects") ~= nil and true or false
end

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

    require("hlargs").setup {
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

    color.set_hl("ISwapSwap", {background = "#957FB8"})

    require("iswap").setup {
        keys = "asdfghjkl;",
        grey = "disable",
        hl_snipe = "ISwapSwap",
        hl_selection = "WarningMsg",
        autoswap = true
    }

    wk.register(
        {
            ["<Leader>sp"] = {"<Cmd>ISwap<CR>", "Swap parameters"}
        }
    )
end

M.setup_aerial = function()
    ex.packadd("aerial.nvim")

    require("aerial").setup(
        {
            -- Priority list of preferred backends for aerial.
            -- This can be a filetype map (see :help aerial-filetype-map)
            backends = {"treesitter", "markdown"},
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
            filter_kind = {
                "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                "Module",
                "Method",
                "Struct",
                "Type"
            },
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
                filetypes = {},
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
            on_attach = nil,
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
            treesitter = {
                update_delay = 300
            },
            markdown = {
                update_delay = 300
            }
            -- on_attach = function(bufnr)
            -- end
        }
    )

    require("telescope").load_extension("aerial")

    -- Use 'o' to open to the function, not <CR>
    local keys = require("aerial.bindings").keys
    local dev = require("dev")

    local cr_idx =
        dev.vec_indexof(
        dev.map(
            keys,
            function(val)
                return val[1]
            end
        ),
        "<CR>"
    )

    local o_idx =
        dev.vec_indexof(
        dev.map(
            keys,
            function(val)
                return F.if_nil(val[1][1], val[1])
            end
        ),
        "o"
    )

    keys[cr_idx][1] = "o"
    keys[o_idx][1][1] = "<CR>"

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
        {mode = "v"}
    )

    -- hi link AerialClass Type
    -- hi link AerialClassIcon Special
    -- hi link AerialFunction Special
    -- hi AerialFunctionIcon guifg=#cb4b16 guibg=NONE guisp=NONE gui=NONE cterm=NONE
    --
    -- hi link AerialLine QuickFixLine
    -- hi AerialLineNC guibg=Gray
    -- hi link AerialGuide Comment
    -- hi AerialGuide1 guifg=Red
    -- hi AerialGuide2 guifg=Blue
end

M.setup_context_vt = function()
    require("nvim_context_vt").setup(
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
            disable_virtual_lines_ft = {"yaml"},
            -- How many lines required after starting position to show virtual text
            min_rows = fn.winheight("%"),
            -- Same as above but only for spesific filetypes
            min_rows_ft = {},
            -- Custom virtual text node parser callback
            custom_parser = function(node, ft, opts)
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
            custom_resolver = function(nodes, ft, opts)
                -- By default the last node is used
                return nodes[#nodes]
            end
        }
    )
end

-- M.setup_comment_frame = function()
--     ex.packadd("nvim-comment-frame")
--
--     require("nvim-comment-frame").setup(
--         {
--             -- if true, <leader>cf keymap will be disabled
--             disable_default_keymap = false,
--             -- adds custom keymap
--             keymap = "<leader>cc",
--             multiline_keymap = "<leader>C",
--             -- start the comment with this string
--             start_str = "//",
--             -- end the comment line with this string
--             end_str = "//",
--             -- fill the comment frame border with this character
--             fill_char = "-",
--             -- width of the comment frame
--             frame_width = 70,
--             -- wrap the line after 'n' characters
--             line_wrap_len = 50,
--             -- automatically indent the comment frame based on the line
--             auto_indent = true,
--             -- add comment above the current line
--             add_comment_above = true,
--             -- configurations for individual language goes here
--             languages = {}
--         }
--     )
-- end

M.setup = function()
    return {
        ensure_installed = {
            "cmake",
            "css",
            "d",
            "dart",
            "dockerfile",
            "go",
            "gomod",
            "html",
            "java",
            "javascript",
            "json",
            "kotlin",
            "lua",
            "make",
            "markdown",
            -- "norg",
            -- Syntax isn't parsed the greatest
            "perl",
            "python",
            "query",
            "rasi",
            -- Injections are sent into various filetypes
            "regex",
            "ruby",
            "rust",
            "scheme",
            "scss",
            "solidity",
            "teal",
            "typescript",
            -- "tsx",
            -- "vue",
            "vim",
            "zig",
            "help"
        },
        sync_install = false,
        ignore_install = {}, -- List of parsers to ignore installing
        highlight = {
            enable = true, -- false will disable the whole extension
            use_languagetree = true,
            disable = {"html", "comment", "zsh"}, -- list of language that will be disabled
            -- I like the additional highlighting; however, when CocAction('highlight') is used
            -- the regular syntax (not treesitter) is used as the foreground some of the time
            additional_vim_regex_highlighting = true,
            custom_captures = {}
        },
        autotag = {enable = true},
        autopairs = {enable = false}, -- there's a plugin for this
        -- yati = {enable = true},
        -- tree_docs = {enable = true},
        indent = {enable = true},
        fold = {enable = false},
        endwise = {enable = true},
        matchup = {enable = false},
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
                node_incremental = "<C-j>", -- increment to the upper named parent
                node_decremental = "<C-k>" -- decrement to the previous node
            }
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
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
                    smart_rename = "'r" -- mapping to rename reference under cursor
                }
            },
            navigation = {
                enable = true,
                keymaps = {
                    goto_definition = ";d", -- mapping to go to definition of symbol under cursor
                    list_definitions = ";D", -- mapping to list all definitions in current file
                    list_definitions_toc = "gO",
                    goto_next_usage = "]x",
                    goto_previous_usage = "[x"
                }
            }
        },
        rainbow = {
            enable = true,
            extended_mode = true
            -- max_file_lines = 300,
            -- disable = {"cpp"},
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
                    -- ["af"] = "@function.outer",
                    -- ["if"] = "@function.inner",
                    -- ["ak"] = "@class.outer",
                    -- ["ik"] = "@class.inner",
                    ["ac"] = "@call.outer",
                    ["ic"] = "@call.inner",
                    ["ao"] = "@block.outer",
                    ["io"] = "@block.inner",
                    ["ad"] = "@comment.outer",
                    ["id"] = "@comment.inner",
                    ["ag"] = "@conditional.outer",
                    ["ig"] = "@conditional.inner",
                    -- targets.nvim does this good (with seeking)
                    -- Though it isn't specifically parameters
                    ["aj"] = "@parameter.outer",
                    ["ij"] = "@parameter.inner",
                    -- ["am"] = "@statement.outer"
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner"

                    -- @conditional.inner
                    -- @conditional.outer
                    -- @loop.inner
                    -- @loop.outer
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
                    ["]d"] = "@comment.outer",
                    ["]a"] = "@parameter.inner",
                    ["]z"] = "@call.inner",
                    ["]l"] = "@statement.inner"
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
                    ["]Z"] = "@call.outer"
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
                    ["[d"] = "@comment.outer",
                    ["[a"] = "@parameter.inner",
                    ["[z"] = "@call.inner",
                    ["[l"] = "@loop.inner"
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
                    ["[Z"] = "@call.outer"
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

local function init()
    local conf = M.setup()

    -- ex.packadd("nvim-treesitter")
    -- ex.packadd("nvim-treesitter-textobjects")

    configs = require("nvim-treesitter.configs")
    parsers = require("nvim-treesitter.parsers")
    configs.setup(conf)

    -- cmd("au! NvimTreesitter FileType *")
    -- M.setup_comment_frame()
    M.setup_iswap()
    M.setup_hlargs()
    M.setup_aerial()
    M.setup_context_vt()

    -- 'r = Smart rename
    -- ;d = Go to definition of symbol under cursor
    -- ;D = List all definitions in file
    -- gO = List definitions TOC
    --
    -- <M-n> = Start scope selection
    -- <M-n> = increment upper scope
    -- <C-j> = increment upper named parent
    -- <C-k> = decrement to previous node
    --
    -- ai = An Indentation level and line above
    -- ii = Inner Indentation level (no line above)
    -- aI = An Indention level and lines above/below
    -- iI = Inner Indentation level (no lines above/below)
    -- if = Inner Function
    -- af = Around Function
    -- ik = Inner Class
    -- ak = Around Class
    --
    -- iu = Inner Unit
    -- au = Around Unit

    map("x", "iu", [[:<C-u>lua require"treesitter-unit".select()<CR>]])
    map("x", "au", [[:<C-u>lua require"treesitter-unit".select(true)<CR>]])
    map("o", "iu", [[<Cmd>lua require"treesitter-unit".select()<CR>]])
    map("o", "au", [[<Cmd>lua require"treesitter-unit".select(true)<CR>]])

    map("x", "if", [[:<C-u>lua require('common.textobj').select('func', true, true)<CR>]])
    map("x", "af", [[:<C-u>lua require('common.textobj').select('func', false, true)<CR>]])
    map("o", "if", [[<Cmd>lua require('common.textobj').select('func', true)<CR>]])
    map("o", "af", [[<Cmd>lua require('common.textobj').select('func', false)<CR>]])

    map("x", "ik", [[:<C-u>lua require('common.textobj').select('class', true, true)<CR>]])
    map("x", "ak", [[:<C-u>lua require('common.textobj').select('class', false, true)<CR>]])
    map("o", "ik", [[<Cmd>lua require('common.textobj').select('class', true)<CR>]])
    map("o", "ak", [[<Cmd>lua require('common.textobj').select('class', false)<CR>]])

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
            ["iI"] = "Inner Indentation level (no lines above/below)"
        },
        {mode = "o"}
    )

    wk.register(
        {
            ["'r"] = "Smart rename",
            [";d"] = "Go to definition under cursor",
            [";D"] = "List all definitions in file",
            ["gO"] = "List all definitions in TOC",
            ["[x"] = "Previous usage",
            ["]x"] = "Next usage",
            ["<M-n>"] = "Start scope selection/Increment",
            ["[["] = "Aerial prevous function",
            ["]]"] = "Aerial next function",
            ["]f"] = "Next function start",
            ["]m"] = "Next class start",
            ["]r"] = "Next block start",
            ["]d"] = "Next comment start",
            ["]a"] = "Next parameter start",
            ["]z"] = "Next call start",
            ["]l"] = "Next loop start",
            ["]F"] = "Next function end",
            ["]M"] = "Next class end",
            ["]R"] = "Next block end",
            ["]Z"] = "Next call end",
            ["[f"] = "Previous function start",
            ["[m"] = "Previous class start",
            ["[r"] = "Previous block start",
            ["[d"] = "Previous comment start",
            ["[a"] = "Previous parameter start",
            ["[z"] = "Previous call start",
            ["[l"] = "Previous loop start",
            ["[F"] = "Previous function end",
            ["[R"] = "Previous block end",
            ["[M"] = "Previous class end",
            ["[Z"] = "Previous call end"
        },
        {mode = "n"}
    )

    require("tsht").config.hint_keys = {"h", "j", "f", "d", "n", "v", "s", "l", "a"}
    map("x", ",", [[:<C-u>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("o", ",", [[<Cmd>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("n", "R", [[<Cmd>lua require('tsht').nodes()<CR>]], {desc = "Treesitter node select"})
    map("n", '<C-S-">', [[<Cmd>lua require('tsht').jump_nodes()<CR>]], {desc = "Treesiter jump node"})

    queries = require("nvim-treesitter.query")
    local hl_disabled = conf.highlight.disable
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
