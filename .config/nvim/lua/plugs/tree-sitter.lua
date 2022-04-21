local M = {}

local utils = require("common.utils")
local map = utils.map

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

function M.setup_iswap()
    ex.packadd("iswap.nvim")

    require("iswap").setup {
        grey = "disable",
        hl_snipe = "IncSearch",
        hl_selection = "MatchParen",
        autoswap = true
    }

    map("n", "<Leader>sp", ":ISwap<CR>")
end

local function init()
    -- M.setup()

    local conf = {
        ensure_installed = {
            "cmake",
            "css",
            "d",
            -- "dart",
            "dockerfile",
            "go",
            "gomod",
            "html",
            "java",
            -- "json",
            -- "kotlin",
            "lua",
            "make",
            "norg",
            "python",
            "query",
            "ruby",
            "rust",
            "scss",
            "teal",
            "typescript",
            -- "tsx",
            -- "vue",
            "zig"
        },
        sync_install = false,
        ignore_install = {}, -- List of parsers to ignore installing
        highlight = {
            enable = true, -- false will disable the whole extension
            use_languagetree = false,
            disable = {"html", "comment", "zsh"}, -- list of language that will be disabled
            -- I like the additional highlighting; however, when CocAction('highlight') is used
            -- the regular syntax (not treesitter) is used as the foreground
            additional_vim_regex_highlighting = true,
            custom_captures = {
                ["function.call"] = "TSFunction",
                ["function.bracket"] = "Type",
                ["namespace.type"] = "Namespace",
                ["require_call"] = "RequireCall",
                ["function_definition"] = "FunctionDefinition",
                ["quantifier"] = "Special",
                ["utils"] = "Function"
            }
        },
        autotag = {enable = true},
        autopairs = {enable = false}, -- there's a plugin for this
        fold = {enable = false},
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
                node_incremental = "<tab>", -- increment to the upper named parent
                node_decremental = "<s-tab>" -- decrement to the previous node
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
        indent = {enable = true},
        endwise = {enable = true},
        matchup = {enable = true},
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
                    goto_definition = "'d", -- mapping to go to definition of symbol under cursor
                    list_definitions = "'D", -- mapping to list all definitions in current file
                    -- goto_definition = "gnd",
                    -- list_definitions = "gnD",
                    list_definitions_toc = "gO"
                    -- goto_next_usage = "<a-*>",
                    -- goto_previous_usage = "<a-#>"
                }
            }
        },
        textobjects = {
            select = {
                enable = true,
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,
                -- disable = {"comment"},
                -- ["af"] = "@function.outer",
                -- ["if"] = "@function.inner",
                -- ["ak"] = "@class.outer",
                -- ["ik"] = "@class.inner",
                -- FIX: Get these to work
                ["ic"] = "@call.inner",
                ["ac"] = "@call.outer",
                ["ao"] = "@block.outer",
                ["io"] = "@block.inner",
                ["aM"] = "@comment.outer",
                ["am"] = "@call.outer",
                ["im"] = "@call.inner",
                -- ["ab"] = "@block.outer",
                -- ["ib"] = "@block.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["as"] = "@statement.outer"
                -- @conditional.inner
                -- @conditional.outer
                -- @loop.inner
                -- @loop.outer
            },
            move = {
                enable = true,
                set_jumps = true, -- Whether to set jumps in the jumplist
                disable = {"comment", "luapad"},
                goto_next_start = {
                    ["]f"] = "@function.outer",
                    ["]]"] = "@function.outer",
                    ["]m"] = "@class.outer",
                    ["]r"] = "@block.outer",
                    ["]c"] = "@comment.outer",
                    ["]a"] = "@parameter.inner"
                    -- ["gnf"] = "@function.outer",
                    -- ["gnif"] = "@function.inner",
                    -- ["gnp"] = "@parameter.inner",
                    -- ["gnc"] = "@call.outer",
                    -- ["gnic"] = "@call.inner"
                },
                goto_next_end = {
                    ["]["] = "@function.outer",
                    ["]F"] = "@function.outer",
                    ["]M"] = "@class.outer",
                    ["]R"] = "@block.outer",
                    -- ["gnF"] = "@function.outer",
                    -- ["gniF"] = "@function.inner",
                    -- ["gnP"] = "@parameter.inner",
                    -- ["gnC"] = "@call.outer",
                    -- ["gniC"] = "@call.inner",
                },
                goto_previous_start = {
                    ["[["] = "@function.outer",
                    ["[f"] = "@function.outer",
                    ["[m"] = "@class.outer",
                    ["[r"] = "@block.outer",
                    ["[c"] = "@comment.outer",
                    ["[a"] = "@parameter.inner"
                    -- ["gpf"] = "@function.outer",
                    -- ["gpif"] = "@function.inner",
                    -- ["gpp"] = "@parameter.inner",
                    -- ["gpc"] = "@call.outer",
                    -- ["gpic"] = "@call.inner",
                },
                goto_previous_end = {
                    ["[]"] = "@function.outer",
                    ["[F"] = "@function.outer",
                    ["[R"] = "@block.outer",
                    ["[M"] = "@class.outer"
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
                },
                swap_previous = {
                    ["<Leader>,f"] = "@function.outer",
                    ["<Leader>,e"] = "@element"
                }
            }
        }
    }

    ex.packadd("nvim-treesitter")
    ex.packadd("nvim-treesitter-textobjects")

    configs = require("nvim-treesitter.configs")
    parsers = require("nvim-treesitter.parsers")
    configs.setup(conf)

    -- cmd("au! NvimTreesitter FileType *")
    M.setup_iswap()

    -- 'r = Smart rename
    -- 'd = Go to definition of symbol under cursor
    -- 'D = List all definitions in file
    -- gO = List definitions TOC
    --
    -- <M-n> = Start scope selection
    -- <M-n> = increment upper scope
    -- <Tab> = increment upper named parent
    -- <S-Tab> = decrement to previous node
    --
    -- ai = An Indentation level and line above
    -- ii = Inner Indentation level (no line above)
    -- aI = An Indention level and lines above/below
    -- iI = Inner Indentation level (no lines above/below)
    -- if = Inner Function
    -- af = Around Function
    -- ik = Inner Class
    -- ak = Around Class

    map("x", "if", [[:<C-u>lua require('common.textobj').select('func', true, true)<CR>]])
    map("x", "af", [[:<C-u>lua require('common.textobj').select('func', false, true)<CR>]])
    map("o", "if", [[<Cmd>lua require('common.textobj').select('func', true)<CR>]])
    map("o", "af", [[<Cmd>lua require('common.textobj').select('func', false)<CR>]])

    map("x", "ik", [[:<C-u>lua require('common.textobj').select('class', true, true)<CR>]])
    map("x", "ak", [[:<C-u>lua require('common.textobj').select('class', false, true)<CR>]])
    map("o", "ik", [[<Cmd>lua require('common.textobj').select('class', true)<CR>]])
    map("o", "ak", [[<Cmd>lua require('common.textobj').select('class', false)<CR>]])

    -- map("x", "ik", [[:<C-u>lua require('common.textobj').select('class', true, true)<CR>]])
    -- map("x", "ak", [[:<C-u>lua require('common.textobj').select('class', false, true)<CR>]])
    -- map("o", "ik", [[<Cmd>lua require('common.textobj').select('class', true)<CR>]])
    -- map("o", "ao", [[<Cmd>lua require('common.textobj').select('block', false)<CR>]])

    queries = require("nvim-treesitter.query")
    local hl_disabled = conf.highlight.disable
    ft_enabled = {}
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

init()

return M
