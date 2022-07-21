---Contains configuration items for plugins that don't deserve their own file
--@module config
--@author lmburns

local M = {}

local D = require("dev")
local abbr = require("abbr")
local lazy = require("common.lazy")
local log = require("common.log")
local wk = require("which-key")
local C = require("common.color")
-- local coc = require("plugs.coc")
local utils = require("common.utils")
local bmap = utils.bmap
local map = utils.map
local command = utils.command
local augroup = utils.augroup
-- local autocmd = utils.autocmd

local fs = vim.fs
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

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
            clearqflist = "ClearQuickfix", -- command
            clearloclist = "ClearLoclist", -- command
            clear_notes = "ClearListNotes", -- command
            lists_close = "<Nop>", -- closes both qf/local lists
            in_list_dd = "dd", -- delete current item in the list
            quickfix = {
                open = "qo",
                on_cursor = "qa", -- add current position to the list
                add_note = "qn", -- add current position with your note to the list
                clear = "qi", -- clear all items
                close = "<Nop>",
                next = "<Nop>",
                prev = "<Nop>"
            },
            locallist = {
                open = "<Leader>wo",
                on_cursor = "<leader>wa",
                add_note = "<leader>wn",
                clear = "<Leader>wi",
                close = "<Nop>",
                next = "]w",
                prev = "[w"
            }
        }
    )

    require("legendary").bind_commands(
        {
            {":ClearQuickfix", description = "Clear quickfix list"},
            {":ClearLoclist", description = "Clear location list"},
            {":ClearListNotes", description = "Clear quickfix notes"}
        }
    )

    wk.register(
        {
            ["]e"] = {":cnewer<CR>", "Next quickfix list"},
            ["[e"] = {":colder<CR>", "Previous quickfix list"},
            ["]w"] = "Next item in loclist",
            ["[w"] = "Previous item in loclist"
        }
    )

    wk.register(
        {
            q = {
                name = "+quickfix",
                o = "Quickfix open",
                a = "Quickfix add current line",
                n = "Quickfix add note",
                i = "Quickfix clear items"
            }
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Crates                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.crates()
    local crates = D.npcall(require, "crates")
    if not crates then
        return
    end

    crates.setup(
        {
            smart_insert = true,
            insert_closing_quote = true,
            avoid_prerelease = true,
            autoload = true,
            autoupdate = true,
            loading_indicator = true,
            date_format = "%Y-%m-%d",
            thousands_separator = ".",
            notification_title = "Crates",
            disable_invalid_feature_diagnostic = false,
            popup = {
                autofocus = false,
                copy_register = '"',
                style = "minimal",
                border = "none",
                show_version_date = false,
                show_dependency_version = true,
                max_height = 30,
                min_width = 20,
                padding = 1,
                keys = {
                    hide = {"q", "<esc>"},
                    open_url = {"<cr>"},
                    select = {"<cr>"},
                    select_alt = {"s"},
                    toggle_feature = {"<cr>"},
                    copy_value = {"yy"},
                    goto_item = {"gd", "K", "<C-LeftMouse>"},
                    jump_forward = {"<c-i>"},
                    jump_back = {"<c-o>", "<C-RightMouse>"}
                }
            }
        }
    )

    augroup(
        "lmb__CratesBindings",
        {
            event = "BufEnter",
            pattern = "Cargo.toml",
            command = function()
                local bufnr = nvim.get_current_buf()
                map("n", "<Leader>ca", crates.upgrade_all_crates, {buffer = bufnr})
                map("n", "<Leader>cu", crates.upgrade_crate, {buffer = bufnr})
                map("n", "<Leader>ch", crates.open_homepage, {buffer = bufnr})
                map("n", "<Leader>cr", crates.open_repository, {buffer = bufnr})
                map("n", "<Leader>cd", crates.open_documentation, {buffer = bufnr})
                map("n", "<Leader>co", crates.open_crates_io, {buffer = bufnr})

                map("n", "vd", crates.show_dependencies_popup, {buffer = bufnr})
                map("n", "vv", crates.show_versions_popup, {buffer = bufnr})
                map("n", "vf", crates.show_features_popup, {buffer = bufnr})

                map("n", "[g", vim.diagnostic.goto_prev, {buffer = bufnr})
                map("n", "]g", vim.diagnostic.goto_next, {buffer = bufnr})

                wk.register(
                    {
                        ["<Leader>ca"] = "Upgrade all crates",
                        ["<Leader>cu"] = "Upgrade crate",
                        ["<Leader>ch"] = "Open homepage",
                        ["<Leader>cr"] = "Open repository",
                        ["<Leader>cd"] = "Open documentation",
                        ["<Leader>co"] = "Open crates.io",
                        ["vd"] = "Dependencies popup",
                        ["vv"] = "Version popup",
                        ["vf"] = "Show features"
                    }
                )
            end
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       PackageInfo                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.package_info()
    local pi = D.npcall(require, "package-info")
    if not pi then
        return
    end

    pi.setup(
        {
            colors = {
                up_to_date = "#3C4048", -- Text color for up to date package virtual text
                outdated = "#d19a66" -- Text color for outdated package virtual text
            },
            icons = {
                enable = true, -- Whether to display icons
                style = {
                    up_to_date = "|  ", -- Icon for up to date packages
                    outdated = "|  " -- Icon for outdated packages
                }
            },
            autostart = true, -- Whether to autostart when `package.json` is opened
            hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
            hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
            -- `npm`, `yarn`
            package_manager = "yarn"
        }
    )

    augroup(
        "lmb__PackageInfoBindings",
        {
            event = "BufEnter",
            pattern = "package.json",
            command = function()
                local bufnr = nvim.get_current_buf()
                map("n", "<Leader>cu", D.ithunk(pi.update), {buffer = bufnr})
                map("n", "<Leader>ci", D.ithunk(pi.install), {buffer = bufnr})
                map("n", "<Leader>ch", D.ithunk(pi.change_version), {buffer = bufnr})
                map("n", "<Leader>cr", D.ithunk(pi.reinstall), {buffer = bufnr})

                wk.register(
                    {
                        ["<Leader>cu"] = "Update package",
                        ["<Leader>ci"] = "Install package",
                        ["<Leader>ch"] = "Change version",
                        ["<Leader>cr"] = "Reinstall package"
                    }
                )
            end
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       open-browser                       │
-- ╰──────────────────────────────────────────────────────────╯
function M.open_browser()
    wk.register(
        {
            -- ["gX"] = {":lua R('functions').go_github()<CR>", "Open link under cursor"},
            ["gX"] = {"<Plug>(openbrowser-open)", "Open link under cursor"},
            ["gx"] = {":lua R('functions').open_link()<CR>", "Open link or file under cursor"},
            ["gf"] = {":lua R('functions').open_path()<CR>", "Open path under cursor"},
            ["<LocalLeader>?"] = {"<Plug>(openbrowser-search)", "Search under cursor"}
        }
    )

    wk.register(
        {
            ["<LocalLeader>?"] = {"<Plug>(openbrowser-search)", "Search under cursor"}
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
            silent = false
        }
    )

    map("n", "gw", D.ithunk(lv.link_under_cursor), {desc = "Link under cursor"})

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
                            bmap(bufnr, "n", "K", D.ithunk(lv.link_under_cursor), {desc = "Link under cursor"})
                            bmap(bufnr, "n", "L", D.ithunk(lv.link_near_cursor), {desc = "Link near cursor"})
                        end
                    )
                end
            end
        }
    )
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

    abbr.abbr({mode = "c", lhs = "ldr", rhs = "LinediffReset"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          GHLine                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.ghline()
    wk.register(
        {
            ["<Leader>go"] = {"<Plug>(gh-repo)", "Open git repo"},
            ["<Leader>gL"] = {"<Plug>(gh-line)", "Open git line"}
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Floaterm                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.floaterm()
    map("n", "<Leader>fll", ":Floaterms<CR>")
    map("n", ";fl", ":FloatermToggle<CR>")

    g.fzf_floaterm_newentries = {
        ["+lazygit"] = {
            title = "lazygit",
            height = 0.9,
            width = 0.9,
            cmd = "lazygit"
        },
        ["+gitui"] = {title = "gitui", height = 0.9, width = 0.9, cmd = "gitui"},
        ["+taskwarrior-tui"] = {
            title = "taskwarrior-tui",
            height = 0.99,
            width = 0.99,
            cmd = "taskwarrior-tui"
        },
        ["+flf"] = {
            title = "full screen lf",
            height = 0.9,
            width = 0.9,
            cmd = "lf"
        },
        ["+slf"] = {
            title = "split screen lf",
            wintype = "split",
            height = 0.5,
            cmd = "lf"
        },
        ["+xplr"] = {title = "xplr", cmd = "xplr"},
        ["+gpg-tui"] = {
            title = "gpg-tui",
            height = 0.9,
            width = 0.9,
            cmd = "gpg-tui"
        },
        ["+tokei"] = {title = "tokei", height = 0.9, width = 0.9, cmd = "tokei"},
        ["+dust"] = {title = "dust", height = 0.9, width = 0.9, cmd = "dust"},
        ["+zsh"] = {title = "zsh", height = 0.9, width = 0.9, cmd = "zsh"}
    }

    g.floaterm_shell = "zsh"
    g.floaterm_wintype = "float"
    g.floaterm_height = 0.85
    g.floaterm_width = 0.9
    g.floaterm_borderchars = "─│─│╭╮╯╰"

    C.plugin(
        "floaterm",
        {
            FloatermBorder = {fg = "#A06469", gui = "none"}
        }
    )

    -- Stackoverflow helper
    map("n", "<Leader>so", ":FloatermNew --autoclose=0 so<space>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Markdown                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.markdown()
    -- g.vim_markdown_folding_disabled = 1
    g.vim_markdown_conceal = 0
    g.vim_markdown_conceal_code_blocks = 0
    g.vim_markdown_fenced_languages = g.markdown_fenced_languages
    g.vim_markdown_folding_level = 10
    g.vim_markdown_folding_style_pythonic = 1
    g.vim_markdown_follow_anchor = 1
    g.vim_markdown_frontmatter = 1
    g.vim_markdown_strikethrough = 1
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        TableMode                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.table_mode()
    augroup(
        "TableMode",
        {
            event = "FileType",
            pattern = {"markdown", "vimwiki"},
            command = function()
                g.table_mode_map_prefix = "<Leader>t"
                g.table_mode_realign_map = "<Leader>tr"
                g.table_mode_delete_row_map = "<Leader>tdd"
                g.table_mode_delete_column_map = "<Leader>tdc"
                g.table_mode_insert_column_after_map = "<Leader>tic"
                g.table_mode_echo_cell_map = "<Leader>t?"
                g.table_mode_sort_map = "<Leader>ts"
                g.table_mode_tableize_map = "<Leader>tt"
                g.table_mode_tableize_d_map = "<Leader>T"
                g.table_mode_tableize_auto_border = 1
                g.table_mode_corner = "|"
                g.table_mode_fillchar = "-"
                g.table_mode_separator = "|"

                -- Expand snippets in VimWiki
                map("i", "<right>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"]], {expr = true})
            end
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         VimWiki                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.vimwiki()
    C.all(
        {
            VimwikiBold = {fg = "#a25bc4", bold = true},
            VimwikiCode = {fg = "#d3869b"},
            VimwikiItalic = {fg = "#83a598", italic = true},
            VimwikiHeader1 = {fg = "#F14A68", bold = true},
            VimwikiHeader2 = {fg = "#F06431", bold = true},
            VimwikiHeader3 = {fg = "#689d6a", bold = true},
            VimwikiHeader4 = {fg = "#819C3B", bold = true},
            VimwikiHeader5 = {fg = "#98676A", bold = true},
            VimwikiHeader6 = {fg = "#458588", bold = true}
        }
    )

    augroup(
        "VimwikiMarkdownFix",
        {
            event = "FileType",
            pattern = {"markdown", "vimwiki"},
            command = function()
                map("i", "<S-CR>", "<Plug>VimwikiFollowLink")
                map("n", "<Leader>vw", ":VimwikiIndex<CR>")
            end
        }
    )
end

function M.vimwiki_setup()
    g.vimwiki_ext2syntax = {
        [".Rmd"] = "markdown",
        [".rmd"] = "markdown",
        [".md"] = "markdown",
        [".markdown"] = "markdown",
        [".mdown"] = "markdown"
    }
    g.vimwiki_list = {{path = "~/vimwiki", syntax = "markdown", ext = ".md"}}
    g.vimwiki_key_mappings = {
        table_mappings = 0
    }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        UltiSnips                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.ultisnips()
    -- This works on snippets like #! where a popup menu doesn't appear
    g.UltiSnipsExpandTrigger = "<C-y>"

    -- g.UltiSnipsJumpForwardTrigger = "<C-j>"
    -- g.UltiSnipsJumpBackwardTrigger = "<C-k>"
    -- g.UltiSnipsListSnippets = "<C-u>"
    g.UltiSnipsEditSplit = "horizontal"
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Slime                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.slime()
    g.slime_target = "neovim"
    g.syntastic_python_pylint_post_args = "--max-line-length=100"

    nvim.autocmd.lmb__SlimeRepl = {
        {
            event = "FileType",
            pattern = "perl",
            command = function()
                map("n", "<LocalLeader>l", "<Plug>SlimeLineSend", {buffer = true, desc = "Slime send"})
            end
        }
    }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Notify                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.notify()
    -- local notify = D.npcall(lazy.require_on_exported_call, "notify")
    local notify = D.npcall(require, "notify")
    if not notify then
        return
    end

    C.plugin(
        "notify",
        {
            NotifyERRORBorder = {bg = {from = "NormalFloat"}},
            NotifyWARNBorder = {bg = {from = "NormalFloat"}},
            NotifyINFOBorder = {bg = {from = "NormalFloat"}},
            NotifyDEBUGBorder = {bg = {from = "NormalFloat"}},
            NotifyTRACEBorder = {bg = {from = "NormalFloat"}},
            NotifyERRORBody = {link = "NormalFloat"},
            NotifyWARNBody = {link = "NormalFloat"},
            NotifyINFOBody = {link = "NormalFloat"},
            NotifyDEBUGBody = {link = "NormalFloat"},
            NotifyTRACEBody = {link = "NormalFloat"}
        }
    )

    ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
    local renderer = require("notify.render")

    notify.setup(
        {
            stages = "fade_in_slide_out", -- slide
            fps = 60,
            timeout = 3000,
            minimum_width = 30,
            max_width = math.floor(vim.o.columns * 0.4),
            background_color = "NormalFloat",
            -- on_close = function()
            -- -- Could create something to write to a file
            -- end,
            on_open = function(winnr)
                api.nvim_win_set_config(winnr, {zindex = 500})
                local bufnr = api.nvim_win_get_buf(winnr)
                bmap(bufnr, "n", "q", "<Cmd>bdelete<CR>", {nowait = true})
                api.nvim_buf_call(
                    bufnr,
                    function()
                        vim.wo[winnr].wrap = true
                        vim.wo[winnr].showbreak = "NONE"
                    end
                )
            end,
            render = function(bufnr, notif, highlights, config)
                local style = notif.title[1] == "" and "minimal" or "default"
                renderer[style](bufnr, notif, highlights, config)
            end,
            icons = {
                ERROR = " ",
                WARN = " ",
                INFO = " ",
                DEBUG = " ",
                TRACE = " "
            }
        }
    )

    wk.register(
        {
            ["<C-S-N>"] = {notify.dismiss, "Dismiss notification"}
        }
    )

    require("telescope").load_extension("notify")
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

    map("n", "gS", "Sort", {cmd = true})

    -- [!]         = Sort order is reversed
    -- [delimiter] = Manually set delimiter ([s]: space, [t]: tab, [!, ?, &, ... (Lua %p)])
    -- [b]         = First binary number in the word
    -- [i]         = Case is ignored
    -- [n]         = First decimal number in the word
    -- [o]         = First octal number in the word
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
            languages = {lua = {template = {annotation_convention = "emmylua"}}}
        }
    )
    map("i", "<C-S-j>", [[<Cmd>lua require('neogen').jump_next()<CR>]])
    map("i", "<C-S-k>", [[<Cmd>lua require('neogen').jump_prev()<CR>]])
    map("n", "<Leader>dg", [[:Neogen<Space>]])
    map("n", "<Leader>df", [[<Cmd>lua require('neogen').generate({ type = 'func' })<CR>]])
    map("n", "<Leader>dc", [[<cmd>lua require("neogen").generate({ type = "class" })<CR>]])
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         VCooler                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.vcoolor()
    map("n", "<Leader>pc", ":VCoolor<CR>")
    map("n", "<Leader>yb", ":VCoolIns b<CR>")
    map("n", "<Leader>yr", ":VCoolIns r<CR>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          LuaPad                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.luapad()
    local luapad = D.npcall(require, "luapad")
    if not luapad then
        return
    end

    luapad.setup {
        count_limit = 150000,
        preview = true,
        error_indicator = true,
        print_highlight = "Comment",
        error_highlight = "ErrorMsg",
        eval_on_move = false,
        eval_on_change = true,
        split_orientation = "vertical",
        on_init = function()
            print("Luapad initialized")
        end,
        -- Global variables provided on startup
        context = {
            arr = {"abc", "def", "ghi", "jkl"},
            tbl = {abc = 123, def = 456, ghi = 789, jkl = 1011},
            shout = function(str)
                return (string.upper(str) .. "!")
            end
        }
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
            calm_down = false,
            nearest_only = false,
            nearest_float_when = "auto",
            float_shadow_blend = 50,
            virt_priority = 100,
            build_position_cb = function(plist, _, _, _)
                require("scrollbar.handlers.search").handler.show(plist.start_pos)
            end
        }
    )

    command(
        "HlSearchLensToggle",
        function()
            require("hlslens").toggle()
        end,
        {desc = "Togggle HLSLens"}
    )

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

    map("n", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("n", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]])
    map("n", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("n", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})

    map("x", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("x", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("x", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]])
    map("x", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]])

    g["asterisk#keeppos"] = 1
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Surround                         │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.surround()
--     map("n", "ds", "<Plug>Dsurround")
--     map("n", "cs", "<Plug>Csurround")
--     map("n", "cS", "<Plug>CSurround")
--     map("n", "ys", "<Plug>Ysurround")
--     map("n", "yS", "<Plug>YSurround")
--     map("n", "yss", "<Plug>Yssurround")
--     map("n", "ygs", "<Plug>YSsurround")
--     map("x", "S", "<Plug>VSurround")
--     map("x", "gS", "<Plug>VgSurround")
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Sandwhich                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.sandwhich()
    -- dss      = automatic deletion
    -- css      = automatic change detection
    -- ySi      = ask head and tail to add
    -- yS       = surround to end of line
    -- yss      = surround whole line (add)
    -- ygs      = surround (\n<line>\n)
    -- ysi      = surround delimiter
    -- ds<CR>   = delete empty line above/below

    -- y{a,i}si = yank head - tail
    -- yiss = yank inside nearest delimiter
    -- yaa  = yank inside <here>
    -- yar  = yank inside [here]

    -- vSi = surround head - tail
    -- vgS = surround (\n<line>\n)

    -- --Old--                   ---Input---        ---Output---
    -- "hello"                   ysiwtkey<cr>       "<key>hello</key>"
    -- "hello"                   ysiwP<cr>          |("hello")
    -- "hello"                   ysiwfprint<cr>     print("hello")
    -- print("hello")            dsf                "hello"

    -- TODO: These
    -- "hello"                   ysWFprint<cr>     print( "hello" )
    -- "hello"                   ysW<C-f>print<cr> (print "hello")

    -- dsf
    g["sandwich#magicchar#f#patterns"] = {
        -- This: func(arg) => arg
        {
            header = [[\<\%(\.\|:\{1,2}\)\@<!\h\k*\%(\.\|:\{1,2}\)\@!]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: macro!(arg) => arg
        {
            header = [[\<\h\k*!]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: func.method.xx(arg) => arg
        {
            header = [[\<\%(\h\k*\.\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: func<T>(generic) => T(generic)
        {
            header = [[\<\h\k*]],
            bra = "<",
            ket = ">",
            footer = ""
        },
        -- This: Lua:method(arg) => arg
        {
            header = [[\<\%(\h\k*:\)\h\k*]],
            bra = "(",
            ket = ")",
            footer = ""
        },
        -- This: func::method(arg) => arg
        {
            header = [[\<\%(\h\k*::\)\+\h\k*]],
            bra = "(",
            ket = ")",
            footer = ""
        }
    }

    ex.runtime("macros/sandwich/keymap/surround.vim")

    -- move the cursor at the start of the surrounded object
    -- "VimEnter * :call operator#sandwich#set('all', 'all', 'cursor', 'inner_head')",
    -- -- keep the same indent level on operator actions
    -- "VimEnter * :call operator#sandwich#set('all', 'all', 'autoindent', 4)",

    cmd [[
      let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)

      let g:sandwich#recipes += [
      \   {
      \     'buns': ['{ ', ' }'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace'],
      \     'action': ['add'],
      \     'input': ['{']
      \   },
      \   {
      \     'buns': ['[ ', ' ]'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace'],
      \     'action': ['add'],
      \     'input': ['[']
      \   },
      \   {
      \     'buns': ['( ', ' )'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace'],
      \     'action': ['add'],
      \     'input': ['(']
      \   },
      \   {
      \     'buns': ['[`', '`]'],
      \     'nesting': 1,
      \     'match_syntax': 1,
      \     'kind': ['add', 'replace', 'delete'],
      \     'action': ['add'],
      \     'input': ['1']
      \   },
      \   {
      \     'buns': ['{\s*', '\s*}'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete', 'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['{']
      \   },
      \   {
      \     'buns': ['\[\s*', '\s*\]'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete', 'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['[']
      \   },
      \   {
      \     'buns': ['(\s*', '\s*)'],
      \     'nesting': 1,
      \     'regex': 1,
      \     'match_syntax': 1,
      \     'kind': ['delete',
      \     'replace', 'textobj'],
      \     'action': ['delete'],
      \     'input': ['(']
      \   },
      \   {
      \     'buns': ['\s\+', '\s\+'],
      \     'regex': 1,
      \     'kind': ['delete', 'replace', 'query'],
      \     'input': [' ']
      \   },
      \   {
      \     'buns'        : ['{', '}'],
      \     'motionwise'  : ['line'],
      \     'kind'        : ['add'],
      \     'linewise'    : 1,
      \     'command'     : ["'[+1,']-1normal! >>"],
      \   },
      \   {
      \     'buns'        : ['{', '}'],
      \     'motionwise'  : ['line'],
      \     'kind'        : ['delete'],
      \     'linewise'    : 1,
      \     'command'     : ["'[,']normal! <<"],
      \   },
      \   {
      \     'buns':         ['', ''],
      \     'action':       ['add'],
      \     'motionwise':   ['line'],
      \     'linewise':     1,
      \     'input':        ["\<CR>"]
      \   },
      \   {
      \     'buns':         ['^$', '^$'],
      \     'regex':        1,
      \     'linewise':     1,
      \     'input':        ["\<CR>"]
      \   },
      \   {
      \     'buns':         ['{', '}'],
      \     'nesting':      1,
      \     'skip_break':   1,
      \     'input':        ['}', 'B'],
      \   },
      \   {
      \     'buns':         ['[', ']'],
      \     'nesting':      1,
      \     'input':        [']', 'r'],
      \   },
      \   {
      \     'buns':         ['(', ')'],
      \     'nesting':      1,
      \     'input':        [')', 'b'],
      \   },
      \   {
      \     'buns':         ['<', '>'],
      \     'expand_range': 0,
      \     'input':        ['>', 'a'],
      \   },
      \   {
      \     'buns': ['(', ')'],
      \     'cursor': 'head',
      \     'command': ['startinsert'],
      \     'kind': ['add', 'replace'],
      \     'action': ['add'],
      \     'input': ['j']
      \   },
      \ ]
    ]]

    -- The last bun is the same as ysiwf, but start in insert mode

    -- TODO
    -- \   {
    -- \     'buns': ['sandwich#magicchar#f#fname()' . '\<Space>', '" )"'],
    -- \     'kind': ['add'],
    -- \     'action': ['add'],
    -- \     'expr': 1,
    -- \     'input': ['J']
    -- \   },
    -- \   {
    -- \     'buns'        : ["'", "'"],
    -- \     'motionwise'  : ['line'],
    -- \     'kind'        : ['add'],
    -- \     'linewise'    : 1,
    -- \     'command'     : ["'[+1,']-1normal! >>"],
    -- \   },

    -- map({"x", "o"}, "im", "<Plug>(textobj-sandwich-literal-query-i)")
    -- map({"x", "o"}, "am", "<Plug>(textobj-sandwich-literal-query-a)")
    map({"x", "o"}, "is", "<Plug>(textobj-sandwich-query-i)", {desc = "Query inner delimiter"})
    map({"x", "o"}, "as", "<Plug>(textobj-sandwich-query-a)", {desc = "Query around delimiter"})
    map({"x", "o"}, "iss", "<Plug>(textobj-sandwich-auto-i)", {desc = "Auto delimiter"})
    map({"x", "o"}, "ass", "<Plug>(textobj-sandwich-auto-a)", {desc = "Auto delimiter"})

    map("n", "ygs", "<Plug>(sandwich-add):normal! V<CR>", {desc = "Surround entire line"})
    map("x", "gS", ":<C-u>normal! V<CR><Plug>(sandwich-add)", {desc = "Surround entire line"})

    -- map("o", "if", "<Plug>(textobj-sandwich-function-ip)")
    -- map("n", "X", "<Plug>(sandwich-delete-auto)")
    -- map("n", "X", "<Plug>(sandwich-replace-auto)")

    wk.register(
        {
            ["<Leader>o"] = {"<Plug>(sandwich-add)iw", "Surround a word"},
            ["y;"] = {"<Plug>(sandwich-add)iw", "Surround a word"},
            ["yf"] = {"<Plug>(sandwich-add)iwf", "Surround a cword with function"},
            ["yF"] = {"<Plug>(sandwich-add)iWf", "Surround a cWORD with function"},
            ["yss"] = "Surround text on line"
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         targets                          │
-- ╰──────────────────────────────────────────────────────────╯
-- http://vimdoc.sourceforge.net/htmldoc/motion.html#operator
function M.targets()
    -- Cheatsheet: https://github.com/wellle/targets.vim/blob/master/cheatsheet.md
    -- vI) = contents inside pair
    -- in( an( In( An( il( al( Il( Al( ... next and last pair
    -- {a,I,A}{,.;+=...} = a/inside/around separator
    -- inb anb Inb Anb ilb alb Ilb Alb = any block
    -- inq anq Inq Anq ilq alq Ilq Alq == any quote

    augroup(
        "lmb__Targets",
        {
            event = "User",
            pattern = "targets#mappings#user",
            command = function()
                fn["targets#mappings#extend"](
                    {
                        -- Parameter
                        J = {argument = {{o = "(", c = ")", s = ","}}},
                        a = {pair = {{o = "<", c = ">"}}},
                        r = {pair = {{o = "[", c = "]"}}},
                        B = {pair = {{o = "{", c = "}"}}},
                        b = {
                            pair = {
                                {o = "(", c = ")"},
                                {o = "{", c = "}"}
                            }
                        },
                        A = {
                            pair = {
                                {o = "(", c = ")"},
                                {o = "{", c = "}"},
                                {o = "[", c = "]"}
                            }
                        },
                        -- Closest delimiter
                        ["2"] = {
                            separator = {
                                {d = ","},
                                {d = "."},
                                {d = ";"},
                                {d = "="},
                                {d = "+"},
                                {d = "-"},
                                {d = "="},
                                {d = "~"},
                                {d = "_"},
                                {d = "*"},
                                {d = "#"},
                                {d = "/"},
                                {d = [[\]]},
                                {d = "|"},
                                {d = "&"},
                                {d = "$"}
                            },
                            pair = {
                                {o = "(", c = ")"},
                                {o = "[", c = "]"},
                                {o = "{", c = "}"},
                                {o = "<", c = ">"}
                            },
                            quote = {{d = "'"}, {d = '"'}, {d = "`"}},
                            tag = {{}}
                        }
                    }
                )
            end
        }
    )

    wk.register(
        {
            ["ir"] = "Inner brace",
            ["ar"] = "Around brace",
            ["ia"] = "Inner angle bracket",
            ["aa"] = "Around angle bracket",
            ["iq"] = "Inner quote",
            ["aq"] = "Around quote",
            ["in"] = "Next object",
            ["im"] = "Previous object",
            ["an"] = "Next object",
            ["am"] = "Previous object",
            ["i2"] = "Inner nearest object",
            ["a2"] = "Around nearest object",
            ["iA"] = "Inner any bracket",
            ["aA"] = "Around any bracket",
            ["iJ"] = "Inner parameter (comma)",
            ["AJ"] = "Around parameter (comma)"
        },
        {mode = "o"}
    )

    -- c: on cursor position
    -- l: left of cursor in current line
    -- r: right of cursor in current line
    -- a: above cursor on screen
    -- b: below cursor on screen
    -- A: above cursor off screen
    -- B: below cursor off screen
    g.targets_seekRanges = "cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA"
    -- g.targets_jumpRanges = g.targets_seekRanges
    -- g.targets_aiAI = "aIAi"
    --
    -- -- Seeking next/last objects
    -- g.targets_nl = "nN"
    g.targets_nl = "nm"

    -- map("o", "I", [[targets#e('o', 'i', 'I')]], { expr = true })
    -- map("x", "I", [[targets#e('o', 'i', 'I')]], { expr = true })
    -- map("o", "a", [[targets#e('o', 'a', 'a')]], { expr = true })
    -- map("x", "a", [[targets#e('o', 'a', 'a')]], { expr = true })
    -- map("o", "i", [[targets#e('o', 'I', 'i')]], { expr = true })
    -- map("x", "i", [[targets#e('o', 'I', 'i')]], { expr = true })
    -- map("o", "A", [[targets#e('o', 'A', 'A')]], { expr = true })
    -- map("x", "A", [[targets#e('o', 'A', 'A')]], { expr = true })
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Caser                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.caser()
    -- crm|crp  => MixedCase, PascalCase
    -- crc      => camelCase
    -- cr_      => snake_case
    -- cru|crU  => UPPER_CASE
    -- crt      => Title case
    -- crs      => Sentence case
    -- cr<spce> => space case
    -- cr-|crk  => dash-case, kebab-case
    -- crK      => Title-Dash-Case, Title-Kebab-Case
    -- cr.      => dot.case

    g.caser_prefix = "cr"
    map("n", "crS", " <Plug>CaserSentenceCase")
    map("n", "crs", "<Plug>CaserSnakeCase")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         MatchUp                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.matchup()
    g.loaded_matchit = 1
    g.matchup_enabled = 1
    g.matchup_mappings_enabled = 0
    g.matchup_motion_enabled = 1
    g.matchup_text_obj_enabled = 1
    g.matchup_matchparen_enabled = 1
    g.matchup_surround_enabled = 0
    g.matchup_motion_cursor_end = 0

    g.matchup_transmute_enabled = 0
    g.matchup_matchparen_timeout = 100
    g.matchup_matchparen_deferred = 1
    g.matchup_matchparen_hi_surround_always = 1
    g.matchup_matchparen_deferred_show_delay = 50
    g.matchup_matchparen_deferred_hide_delay = 300
    g.matchup_matchparen_offscreen = {method = "popup", highlight = "CurrentWord"}
    g.matchup_delim_start_plaintext = 1
    g.matchup_motion_override_Npercent = 0

    C.plugin(
        "Matchup",
        {
            MatchWord = {link = "Underlined"},
            MatchParen = {bg = "#5e452b", underline = true}
        }
    )

    map({"n", "x", "o"}, "%", "<Plug>(matchup-%)")
    map({"n", "x", "o"}, "[5", "<Plug>(matchup-[%)")
    map({"n", "x", "o"}, "]5", "<Plug>(matchup-]%)")
    map({"n", "x", "o"}, "<Leader>5", "<Plug>(matchup-z%)")
    map({"x", "o"}, "a5", "<Plug>(matchup-a%)")
    map({"x", "o"}, "i5", "<Plug>(matchup-i%)")

    augroup(
        "lmb__Matchup",
        {
            event = "TermOpen",
            pattern = "*",
            command = function()
                vim.b.matchup_matchparen_enabled = 0
                vim.b.matchup_matchparen_fallback = 0
            end
        },
        {
            event = "FileType",
            pattern = "qf",
            command = function()
                vim.b.matchup_matchparen_enabled = 0
                vim.b.matchup_matchparen_fallback = 0
            end
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

    esc.setup {
        mapping = {"jk", "kj"}, -- a table with mappings to use
        -- timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
        timeout = 375,
        clear_empty_lines = false, -- clear line after escaping if there is only whitespace
        keys = "<Esc>" -- keys used for escaping, if it is a function will use the result everytime
        -- keys = function()
        --   return api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
        -- end,
    }
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
            move_cursor_same_row = false
        }
    )

    -- Can be achieved with custom function, but this has more functionality

    -- map("n", "<C-Up>", [[:lua require('common.utils').resize(false, -1)<CR>]])
    -- map("n", "<C-Down>", [[:lua require('common.utils').resize(false, 1)<CR>]])
    -- map("n", "<C-Right>", [[:lua require('common.utils').resize(true, 1)<CR>]])
    -- map("n", "<C-Left>", [[:lua require('common.utils').resize(true, -1)<CR>]])

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
            ["<C-Left>"] = {D.ithunk(ss.resize_left), "Resize window left"}
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

    tmux.setup {
        copy_sync = {
            -- enables copy sync and overwrites all register actions to
            -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
            enable = false,
            -- TMUX >= 3.2: yanks (and deletes) will get redirected to system
            -- clipboard by tmux
            redirect_to_clipboard = false,
            -- offset controls where register sync starts
            -- e.g. offset 2 lets registers 0 and 1 untouched
            register_offset = 0,
            -- sync clipboard overwrites vim.g.clipboard to handle * and +
            -- registers. If you sync your system clipboard without tmux, disable
            -- this option!
            sync_clipboard = false,
            -- syncs deletes with tmux clipboard as well, it is adviced to
            -- do so. Nvim does not allow syncing registers 0 and 1 without
            -- overwriting the unnamed register. Thus, ddp would not be possible.
            sync_deletes = false,
            -- syncs the unnamed register with the first buffer entry from tmux.
            sync_unnamed = false
        },
        navigation = {
            -- cycles to opposite pane while navigating into the border
            cycle_navigation = true,
            -- enables default keybindings (C-hjkl) for normal mode
            enable_default_keybindings = false,
            -- prevents unzoom tmux when navigating beyond vim border
            persist_zoom = true
        },
        resize = {
            -- enables default keybindings (A-hjkl) for normal mode
            enable_default_keybindings = false,
            -- sets resize steps for x axis
            resize_step_x = 1,
            -- sets resize steps for y axis
            resize_step_y = 1
        }
    }

    wk.register(
        {
            ["<C-j>"] = {D.ithunk(tmux.move_bottom), "Move to below window/pane"},
            ["<C-k>"] = {D.ithunk(tmux.move_top), "Move to above window/pane"},
            ["<C-h>"] = {D.ithunk(tmux.move_left), "Move to left window/pane"},
            ["<C-l>"] = {D.ithunk(tmux.move_right), "Move to right window/pane"}
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           Move                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.move()
    -- Move selected text up down
    -- map("v", "J", ":m '>+1<CR>gv=gv")
    -- map("v", "K", ":m '<-2<CR>gv=gv")
    -- map("i", "<C-J>", "<C-o><Cmd>m +1<CR>")
    -- map("i", "<C-K>", "<C-o><Cmd>m -2<CR>")
    -- map("n", "<C-,>", "<Cmd>m +1<CR>")
    -- map("n", "<C-.>", "<Cmd>m -2<CR>")

    wk.register(
        {
            ["J"] = {":MoveBlock(1)<CR>", "Move selected text down"},
            ["K"] = {":MoveBlock(-1)<CR>", "Move selected text up"}
        },
        {mode = "v"}
    )

    wk.register(
        {
            ["<C-j>"] = {"<C-o><Cmd>MoveLine(1)<CR>", "Move line down"},
            ["<C-k>"] = {"<C-o><Cmd>MoveLine(-1)<CR>", "Move line up"}
        },
        {mode = "i"}
    )

    wk.register(
        {
            ["<C-S-l>"] = {":MoveHChar(1)<CR>", "Move character one left"},
            ["<C-S-h>"] = {":MoveHChar(-1)<CR>", "Move character one right"},
            ["<C-S-j>"] = {":MoveLine(1)<CR>", "Move line down"},
            ["<C-S-k>"] = {":MoveLine(-1)<CR>", "Move line up"}
        },
        {mode = "n"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         LazyGit                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.lazygit()
    g.lazygit_floating_window_winblend = 0 -- transparency of floating window
    g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    g.lazygit_floating_window_corner_chars = {"╭", "╮", "╰", "╯"} -- customize lazygit popup window corner
    g.lazygit_floating_window_use_plenary = 1 -- use plenary.nvim to manage floating window if available
    g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

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
-- │                          Specs                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.specs()
    local specs = D.npcall(require, "specs")
    if not specs then
        return
    end

    --This is pretty cool, but it causes a BufEnter to happen on each call
    specs.setup(
        {
            show_jumps = true,
            min_jump = fn.winheight("%"),
            popup = {
                delay_ms = 0, -- delay before popup displays
                inc_ms = 20, -- time increments used for fade/resize effects
                blend = 20, -- starting blend, between 0-100 (fully transparent), see :h winblend
                width = 20,
                winhl = "PMenu",
                fader = require("specs").linear_fader,
                resizer = require("specs").shrink_resizer
            },
            ignore_filetypes = {D.vec2tbl(BLACKLIST_FT)},
            ignore_buftypes = {nofile = true}
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

    map("n", "<Leader>sc", "<cmd>lua R'scratchpad'.invoke()<CR>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           NLua                           │
-- ╰──────────────────────────────────────────────────────────╯
--- This involves the original mapping in `nlua` to be commented out
function M.nlua()
    map("n", "M", [[<cmd>lua require("nlua").keyword_program()<CR>]])
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
            cmd = "curl"
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
            "gitconfig",
            "vim",
            "sh",
            "zsh",
            "markdown",
            "tmux",
            "yaml",
            "json",
            "xml",
            "css",
            "typescript",
            "javascript",
            "conf",
            "toml",
            lua = {names = false}
        },
        {
            RGB = true, -- #RGB hex codes
            RRGGBB = true, -- #RRGGBB hex codes
            RRGGBBAA = true, -- #RRGGBBAA hex codes
            names = false, -- "Name" codes like Blue
            rgb_0x = false, -- 0xAARRGGBB hex codes
            rgb_fn = false, -- CSS rgb() and rgba() functions
            hsl_fn = false, -- CSS hsl() and hsla() functions
            css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
            css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
            -- Available modes: foreground, background, virtualtext
            mode = "background", -- Set the display mode.
            virtualtext = "■"
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
            grepprg = "rg -H --no-heading --max-columns=200 --vimgrep --smart-case --color=never",
            grepformat = "%f:%l:%c:%m,%f:%l:%m"
        }
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
            end
        }
    )
end

-- ╓                                                          ╖
-- ║                        CommentBox                        ║
-- ╙                                                          ╜
function M.comment_box()
    local cb = D.npcall(require, "comment-box")
    if not cb then
        return
    end

    cb.setup(
        {
            doc_width = 80, -- width of the document
            box_width = 60, -- width of the boxes
            borders = {
                -- symbols used to draw a box
                top = "─",
                bottom = "─",
                left = "│",
                right = "│",
                top_left = "╭",
                top_right = "╮",
                bottom_left = "╰",
                bottom_right = "╯"
            },
            line_width = 70, -- width of the lines
            line = {
                -- symbols used to draw a line
                line = "─",
                line_start = "─",
                line_end = "─"
            },
            outer_blank_lines = false, -- insert a blank line above and below the box
            inner_blank_lines = false, -- insert a blank line above and below the text
            line_blank_line_above = false, -- insert a blank line above the line
            line_blank_line_below = false -- insert a blank line below the line
        }
    )

    local _ = D.ithunk

    --        Box | Size | Text
    -- lbox    L     F      L
    -- clbox   C     F      L
    -- cbox    L     F      C
    -- ccbox   C     F      C
    -- albox   L     A      L
    -- aclbox  C     A      L
    -- acbox   L     A      C
    -- accbox  C     A      C

    -- 21 20 19 18 7
    map({"n", "v"}, "<Leader>bb", cb.cbox, {desc = "Left fixed box, center text (round)"})
    map({"n", "v"}, "<Leader>bs", _(cb.cbox, 19), {desc = "Left fixed box, center text (sides)"})
    map({"n", "v"}, "<Leader>bd", _(cb.cbox, 7), {desc = "Left fixed box, center text (double)"})
    map({"n", "v"}, "<Leader>bh", _(cb.cbox, 13), {desc = "Left fixed box, center text (side)"})

    map({"n", "v"}, "<Leader>cc", _(cb.cbox, 21), {desc = "Left fixed box, center text (top/bottom)"})
    map({"n", "v"}, "<Leader>cb", _(cb.cbox, 8), {desc = "Left fixed box, center text (thick/single)"})
    map({"n", "v"}, "<Leader>ca", _(cb.acbox, 21), {desc = "Left center box, center text (top/bottom)"})

    map({"n", "v"}, "<Leader>be", cb.lbox, {desc = "Left fixed box, left text (round)"})
    map({"n", "v"}, "<Leader>ba", cb.acbox, {desc = "Left center box, center text (round)"})
    map({"n", "v"}, "<Leader>bc", cb.accbox, {desc = "Center center box, center text (round)"})

    -- cline
    -- 2 6 7
    map({"n", "i"}, "<M-w>", _(cb.cline, 6), {desc = "Insert thick line"})

    map("n", "<Leader>b?", cb.catalog, {desc = "Comment box catalog"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Registers                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.registers()
    g.registers_return_symbol = "⏎"
    g.registers_tab_symbol = "\t" -- "·"
    g.registers_show_empty_registers = 0
    -- g.registers_hide_only_whitespace = 1
    g.registers_window_border = "rounded"
    g.registers_insert_mode = false -- removes <C-R> insert mapping
    g.registers_visual_mode = false -- removes <C-R> insert mapping
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                            LF                            │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.lf()
--     g.lf_map_keys = 0
--     g.lf_replace_netrw = 1
--
--     map("n", "<A-o>", ":Lf<CR>")
-- end

function M.lfnvim()
    local lf = D.npcall(require, "lf")
    if not lf then
        return
    end

    g.lf_netrw = 1

    -- The float border stopped working
    lf.setup(
        {
            escape_quit = true,
            -- open_on = true,
            border = "rounded",
            highlights = {FloatBorder = {guifg = require("kimbox.palette").colors.magenta}}
        }
    )

    map("n", "<A-o>", ":Lf<CR>")
    -- map("n", "<A-y>", ":Lf<CR>")
    -- map("n", "<A-o>", ":Lfnvim<CR>")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         urlview                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.urlview()
    local urlview = D.npcall(require, "urlview")
    if not urlview then
        return
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
            navigate_method = "netrw",
            -- Logs user warnings
            debug = true,
            -- Custom search captures
            custom_searches = {
                -- KEY: search source name
                -- VALUE: custom search function or table (map with keys capture, format)
                jira = {
                    capture = "AXIE%-%d+",
                    format = "https://jira.axieax.com/browse/%s"
                }
            }
        }
    )

    require("telescope").load_extension("urlview")
    map("n", "<LocalLeader>l", "UrlView", {cmd = true})
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
                name = "Scratchpad"
            },
            NeogitStatus = {
                icon = "",
                color = "#F14C28",
                name = "BranchCycle"
            },
            org = {
                icon = "◉",
                color = "#75A899",
                name = "Org"
            }
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          trevj                           │
-- ╰──────────────────────────────────────────────────────────╯
function M.trevj()
    local trevj = D.npcall(require, "trevj")
    if not trevj then
        return
    end

    trevj.setup(
        {
            containers = {
                lua = {
                    table_constructor = {final_separator = ",", final_end_line = true},
                    arguments = {final_separator = false, final_end_line = true},
                    parameters = {final_separator = false, final_end_line = true}
                },
                html = {
                    start_tag = {
                        final_separator = false,
                        final_end_line = true,
                        skip = {tag_name = true}
                    }
                }
            }
        }
    )
    map("n", "gJ", [[:lua require('trevj').format_at_cursor()<CR>]])
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
            -- Path where project.nvim will store the project history for use in
            -- telescope
            datapath = fn.stdpath("data")
        }
    )

    require("telescope").load_extension("projects")
    map("n", "<LocalLeader>p", "Telescope projects", {cmd = true})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       VisualMulti                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.visualmulti()
    -- g.VM_theme = "purplegray"
    g.VM_highlight_matches = ""
    g.VM_show_warnings = 0
    g.VM_silent_exit = 1
    g.VM_default_mappings = 1

    g.VM_Mono_hl = "DiffText" -- ErrorMsg DiffText
    g.VM_Extend_hl = "DiffAdd" -- PmenuSel DiffAdd
    g.VM_Cursor_hl = "Visual"
    g.VM_Insert_hl = "DiffChange"

    -- https://github.com/mg979/vim-visual-multi/wiki/Special-commands
    -- https://github.com/mg979/vim-visual-multi/wiki/Mappings
    g.VM_maps = {
        Delete = "d",
        Undo = "u",
        Redo = "U",
        ["Switch Mode"] = ",",
        ["Select Operator"] = "s",
        ["Find Operator"] = "m",
        ["Surround"] = "S",
        ["Replace Pattern"] = "R",
        ["Select Cursor Up"] = "<M-C-Up>", -- start selecting up
        ["Select Cursor Down"] = "<M-C-Down>", -- start selecting down
        ["Move Left"] = "<M-C-Left>",
        ["Move Right"] = "<M-C-Right>",
        ["Find Next"] = "]",
        ["Find Prev"] = "[",
        ["Goto Next"] = "}", -- already selected
        ["Goto Prev"] = "{", -- already selected
        ["Seek Next"] = "<C-f>",
        ["Seek Prev"] = "<C-b>",
        ["Skip Region"] = "q",
        ["Remove Region"] = "Q",
        ["Remove Last Region"] = "<Leader>q",
        ["Merge Regions"] = "<Leader>m",
        ["Split Regions"] = "<Leader>s",
        ["Tools Menu"] = "<Leader>`",
        ["Search Menu"] = "<Leader>S",
        ["Case Conversion Menu"] = "<Leader>C",
        ["Invert Direction"] = "o",
        ["Show Registers"] = '<Leader>"',
        ["Visual Subtract"] = "<Leader>s",
        ["Case Setting"] = "<Leader>c",
        ["Toggle Whole Word"] = "<Leader>w",
        ["Transpose"] = "<Leader>t",
        ["Align"] = "<Leader>a",
        ["Align Char"] = "<Leader><",
        ["Align Regex"] = "<Leader>>",
        ["Numbers"] = "<Leader>n",
        ["Numbers Append"] = "<Leader>N",
        ["Duplicate"] = "<Leader>d",
        ["Shrink"] = "-",
        ["Enlarge"] = "+",
        ["Run Normal"] = "<Leader>z",
        ["Run Last Normal"] = "<Leader>Z",
        ["Run Visual"] = "<Leader>v",
        ["Run Last Visual"] = "<Leader>V",
        ["Run Ex"] = "<Leader>x",
        ["Run Last Ex"] = "<Leader>X",
        ["Run Macro"] = "<Leader>@",
        ["Toggle Block"] = "<Leader><BS>",
        ["Toggle Single Region"] = "<Leader><CR>",
        ["Toggle Multiline"] = "<Leader>M"
    }

    -- TODO: <C-n> smartcase
    map("n", "<C-Up>", "<Plug>(VM-Add-Cursor-Up)")
    map("n", "<C-Down>", "<Plug>(VM-Add-Cursor-Down)")
    map("n", "<M-S-i>", "<Plug>(VM-Select-Cursor-Up)")
    map("n", "<M-S-o>", "<Plug>(VM-Select-Cursor-Down)")
    map("n", "<C-n>", "<Plug>(VM-Find-Under)")
    map("x", "<C-n>", "<Plug>(VM-Find-Subword-Under)")
    map("n", [[<Leader>\]], "<Plug>(VM-Add-Cursor-At-Pos)")
    map("n", "<Leader>/", "<Plug>(VM-Start-Regex-Search)")
    map("n", "<Leader>A", "<Plug>(VM-Select-All)")
    map("x", "<Leader>A", "<Plug>(VM-Visual-All)")
    map("n", "<Leader>gs", "<Plug>(VM-Reselect-Last)")
    map("n", "g/", "<Cmd>VMSearch<CR>")

    command(
        "VMFixStl",
        function()
            ex.VMClear()
            vim.o.statusline = "%{%v:lua.require'lualine'.statusline()%}"
        end
    )

    augroup(
        "VisualMulti",
        {
            event = "User",
            pattern = "visual_multi_start",
            command = function()
                require("common.vm").start()
            end
        },
        {
            event = "User",
            pattern = "visual_multi_exit",
            command = function()
                require("common.vm").exit()
            end
        },
        {
            event = "User",
            pattern = "visual_multi_mappings",
            command = function()
                require("common.vm").mappings()
            end
        }
    )
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
                    current = "DiffAdd"
                }
            }
        }
    )

    -- C.plugin(
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
                            true,
                            {title = "GitConflict"}
                        )
                    end,
                    100
                )

                bmap(bufnr, "n", "co", "<Plug>(git-conflict-ours)")
                bmap(bufnr, "n", "cb", "<Plug>(git-conflict-both)")
                bmap(bufnr, "n", "c0", "<Plug>(git-conflict-none)")
                bmap(bufnr, "n", "ct", "<Plug>(git-conflict-theirs)")
                bmap(bufnr, "n", "[n", "<Plug>(git-conflict-next-conflict)", {desc = "Next conflict"})
                bmap(bufnr, "n", "]n", "<Plug>(git-conflict-prev-conflict)", {desc = "Previous conflict"})
            end
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          eregex                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.eregex()
    map("n", "<Leader>es", "<cmd>call eregex#toggle()<CR>", {desc = "Toggle eregex"})
end

-- ╒══════════════════════════════════════════════════════════╕
--                         LSP Specific
-- ╘══════════════════════════════════════════════════════════╛

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Outline                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.outline()
    vim.g.symbols_outline = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 25,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = "Pmenu",
        keymaps = {
            -- These keymaps can be a string or a table for multiple keys
            close = {"<Esc>", "q"},
            goto_location = "<Cr>",
            focus_location = "o",
            hover_symbol = "M",
            toggle_preview = "K",
            rename_symbol = "r",
            code_actions = "a"
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
            File = {icon = "", hl = "TSURI"},
            Module = {icon = "", hl = "TSNamespace"},
            Namespace = {icon = "", hl = "TSNamespace"},
            Package = {icon = "", hl = "TSNamespace"},
            Class = {icon = "𝓒", hl = "TSType"},
            Method = {icon = "ƒ", hl = "TSMethod"},
            Property = {icon = "", hl = "TSMethod"},
            Field = {icon = "", hl = "TSField"},
            Constructor = {icon = "", hl = "TSConstructor"},
            Enum = {icon = "ℰ", hl = "TSType"},
            Interface = {icon = "ﰮ", hl = "TSType"},
            Function = {icon = "", hl = "TSFunction"},
            Variable = {icon = "", hl = "TSConstant"},
            Constant = {icon = "", hl = "TSConstant"},
            String = {icon = "𝓐", hl = "TSString"},
            Number = {icon = "#", hl = "TSNumber"},
            Boolean = {icon = "⊨", hl = "TSBoolean"},
            Array = {icon = "", hl = "TSConstant"},
            Object = {icon = "⦿", hl = "TSType"},
            Key = {icon = "🔐", hl = "TSType"},
            Null = {icon = "NULL", hl = "TSType"},
            EnumMember = {icon = "", hl = "TSField"},
            Struct = {icon = "𝓢", hl = "TSType"},
            Event = {icon = "🗲", hl = "TSType"},
            Operator = {icon = "+", hl = "TSOperator"},
            TypeParameter = {icon = "𝙏", hl = "TSParameter"}
        }
    }

    map("n", '<A-S-">', "<Cmd>SymbolsOutline<CR>", {desc = "Open symbols"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Lightbulb                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.lightbulb()
    local lightbulb = D.npcall(require, "nvim-lightbulb")
    if not lightbulb then
        return
    end

    lightbulb.setup(
        {
            ignore = {"null-ls"},
            sign = {enabled = false},
            float = {enabled = true, win_opts = {border = "none"}},
            autocmd = {
                enabled = true
            }
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Semantic Tokens                      │
-- ╰──────────────────────────────────────────────────────────╯
function M.semantic_tokens()
    local semantic = D.npcall(require, "nvim-semantic-tokens")
    if not semantic then
        return
    end

    semantic.setup(
        {
            preset = "default"
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Illuminate                        │
-- ╰──────────────────────────────────────────────────────────╯
function M.illuminate()
    vim.g.Illuminate_delay = 300

    map("n", "]i", "<cmd>lua require'illuminate'.next_reference{wrap=true}<cr>", {desc = "Next word under cursor"})
    map(
        "n",
        "[i",
        "<cmd>lua require'illuminate'.next_reference{reverse=true,wrap=true}<cr>",
        {desc = "Previous word under cursor"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Fidget                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.fidget()
    local fidget = D.npcall(require, "fidget")
    if not fidget then
        return
    end

    fidget.setup(
        {
            text = {
                spinner = {
                    "⏺∙∙∙∙",
                    "∙⏺∙∙∙",
                    "∙∙⏺∙∙",
                    "∙∙∙⏺∙",
                    "∙∙∙∙⏺",
                    "∙∙∙⏺∙",
                    "∙∙⏺∙∙",
                    "∙⏺∙∙∙"
                },
                done = "✔",
                commenced = "Started",
                completed = "Completed"
            },
            window = {
                relative = "editor",
                blend = 0
            },
            fmt = {
                stack_upwards = false,
                fidget = function(fidget_name, spinner)
                    return ("%s %s"):format(spinner, fidget_name)
                end,
                -- function to format each task line
                task = function(task_name, message, percentage)
                    return ("%s%s [%s]"):format(message, percentage and (" (%s%%)"):format(percentage) or "", task_name)
                end
            }
        }
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Coverage                         │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.coverage()
--     local coverage = D.npcall(require, "coverage")
--     if not coverage then
--         return
--     end
--
--     coverage.setup(
--         {
--             commands = true, -- create commands
--             highlights = {
--                 -- customize highlight groups created by the plugin
--                 covered = {fg = "#C3E88D"}, -- supports style, fg, bg, sp (see :h highlight-gui)
--                 uncovered = {fg = "#F07178"}
--             },
--             signs = {
--                 -- use your own highlight groups or text markers
--                 covered = {hl = "CoverageCovered", text = "▎"},
--                 uncovered = {hl = "CoverageUncovered", text = "▎"}
--             },
--             summary = {
--                 -- customize the summary pop-up
--                 min_coverage = 80.0 -- minimum coverage threshold (used for highlighting)
--             },
--             lang = {}
--         }
--     )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       regexplainer                       │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.regexplainer()
--     local regexplainer = D.npcall(require, "regexplainer")
--     if not regexplainer then
--         return
--     end
--
--     regexplainer.setup(
--         {
--             mode = "narrative", -- TODO: 'ascii', 'graphical'
--             -- automatically show the explainer when the cursor enters a regexp
--             auto = false,
--             -- filetypes (i.e. extensions) in which to run the autocommand
--             filetypes = {
--                 "html",
--                 "js",
--                 "cjs",
--                 "mjs",
--                 "ts",
--                 "jsx",
--                 "tsx",
--                 "cjsx",
--                 "mjsx"
--                 -- "rs"
--             },
--             debug = false, -- Whether to log debug messages
--             display = "popup", -- 'split', 'popup', 'pasteboard'
--             popup = {
--                 border = {
--                     padding = {1, 2},
--                     style = "solid"
--                 }
--             },
--             mappings = {
--                 toggle = "gR",
--                 show = "gS"
--                 -- hide = 'gH',
--                 -- show_split = 'gP',
--                 -- show_popup = 'gU',
--             },
--             narrative = {
--                 separator = "\n"
--             }
--         }
--     )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       ColorPicker                        │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.colortils()
--     require("colortils").setup(
--         {
--             register = "+", -- register in which color codes will be copied: any register
--             color_preview = "█ %s",
--             border = "rounded" -- border for the float
--         }
--     )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Window Picker                       │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.window_picker()
--     require("nvim-window").setup(
--         {
--             -- The characters available for hinting windows.
--             chars = {
--                 "a",
--                 "s",
--                 "d",
--                 "f",
--                 "q",
--                 "w",
--                 "e",
--                 "r",
--                 "t",
--                 "z",
--                 "g",
--                 ";",
--                 ","
--             },
--             -- A group to use for overwriting the Normal highlight group in the floating
--             -- window. This can be used to change the background color.
--             normal_hl = "Normal",
--             -- The highlight group to apply to the line that contains the hint characters.
--             -- This is used to make them stand out more.
--             hint_hl = "Bold",
--             -- The border style to use for the floating window.
--             border = "single"
--         }
--     )
--
--     map("n", "<M-->", "<cmd>lua require('nvim-window').pick()<CR>")
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        Neoscroll                         │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.neoscroll()
--     require("neoscroll").setup(
--         {
--             -- All these keys will be mapped to their corresponding default scrolling animation
--             -- mappings = {
--             --     "<C-u>",
--             --     "<C-d>",
--             --     "<C-b>",
--             --     "<C-f>",
--             --     "<C-y>",
--             --     "<C-e>",
--             --     "zt",
--             --     "zz",
--             --     "zb"
--             -- },
--             hide_cursor = true, -- Hide cursor while scrolling
--             stop_eof = true, -- Stop at <EOF> when scrolling downwards
--             use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
--             respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
--             cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
--             easing_function = nil, -- Default easing function
--             pre_hook = nil, -- Function to run before the scrolling animation starts
--             post_hook = nil, -- Function to run after the scrolling animation ends
--             performance_mode = false -- Disable "Performance Mode" on all buffers.
--         }
--     )
--
--     local t = {}
--
--     t["<C-u>"] = {"scroll", {"-vim.wo.scroll", "true", "250"}}
--     t["<C-d>"] = {"scroll", {"vim.wo.scroll", "true", "250"}}
--     -- t["<C-b>"] = {"scroll", {"-vim.api.nvim_win_get_height(0)", "true", "250"}}
--     -- t["<C-f>"] = {"scroll", {"vim.api.nvim_win_get_height(0)", "true", "250"}}
--     t["<C-y>"] = {"scroll", {"-0.10", "false", "80"}}
--     t["<C-e>"] = {"scroll", {"0.10", "false", "80"}}
--     t["zt"] = {"zt", {"150"}}
--     t["zz"] = {"zz", {"150"}}
--     t["zb"] = {"zb", {"150"}}
--     -- t["gg"] = {"scroll", {"-2*vim.api.nvim_buf_line_count(0)", "true", "1", "5", e}}
--     -- t["G"] = {"scroll", {"2*vim.api.nvim_buf_line_count(0)", "true", "1", "5", e}}
--
--     require("neoscroll.config").set_mappings(t)
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Cutlass                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.cutlass()
--     require("cutlass").setup({cut_key = nil, override_del = nil, exclude = {"vx"}})
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Session Manager                      │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.session_manager()
--     require("session_manager").setup(
--         {
--             sessions_dir = Path:new(fn.stdpath("data"), "sessions"),
--             path_replacer = "__",
--             colon_replacer = "++",
--             autoload_mode = require("session_manager.config").AutoloadMode.LastSession,
--             autosave_last_session = true,
--             autosave_ignore_not_normal = true,
--             autosave_ignore_filetypes = {
--                 -- All buffers of these file types will be closed before the session is saved.
--                 "gitcommit"
--             },
--             autosave_only_in_session = false,
--             max_path_length = 80
--         }
--     )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Neoterm                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.neoterm()
--   g.neoterm_default_mod = "belowright" -- open terminal in bottom split
--   g.neoterm_size = 14 -- terminal split size
--   g.neoterm_autoscroll = 1 -- scroll to the bottom
--
--   map("n", "<Leader>rr", "<Cmd>execute v:count.'Tclear'<CR>")
--   map("n", "<Leader>rt", ":Ttoggle<CR>")
--   map("n", "<Leader>ro", ":Ttoggle<CR> :Ttoggle<CR>")
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Delimitmate                        │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.delimitmate()
--   g.delimitMate_jump_expansion = 1
--   g.delimitMate_expand_cr = 2
--
--   cmd("au FileType html let b:delimitMate_matchpairs = '(:),[:],{:}'")
--   cmd("au FileType vue let b:delimitMate_matchpairs = '(:),[:],{:}'")
--
--   map(
--       "i", "<CR>", ("pumvisible() ? %s : %s . \"<Plug>delimitMateCR\""):format(
--           [["\<C-y>"]], [[(getline('.') =~ '^\s*$' ? '' : "\<C-g>u")]]
--       ), { noremap = false, expr = true }
--   )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Spectre                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.spectre()
--     require("spectre").setup()
--
--     -- require("spectre.actions").get_current_entry()
--     -- require("spectre.actions").get_all_entries()
--     -- require("spectre.actions").get_state()
--     -- require("spectre").open(
--     --     {
--     --         is_insert_mode = true,
--     --         cwd = "~/.config/nvim",
--     --         search_text = "test",
--     --         replace_text = "test",
--     --         path = "lua/**/*.lua"
--     --     }
--     -- )
--
--     command(
--         "SpectreOpen",
--         function()
--             require("spectre").open()
--         end
--     )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       QFReflector                        │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.qf_reflector()
--     g.qf_modifiable = 1
--     g.qf_write_changes = 1
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Anywise                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.anywise()
--     require("anywise_reg").setup(
--         {
--             operators = {"y", "d", "c"},
--             textobjects = {
--                 {"i", "a"},
--                 {"w", "W", "f", "c"}
--             },
--             paste_keys = {
--                 ["p"] = "p"
--             },
--             register_print_cmd = true
--         }
--     )
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Minimap                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.minimap()
--     map("n", "<Leader>mi", ":MinimapToggle<CR>")
--
--     g.minimap_width = 10
--     g.minimap_auto_start = 0
--     g.minimap_auto_start_win_enter = 1
--     g.minimap_highlight_range = 1
--     g.minimap_block_filetypes = {"fugitive", "nerdtree", "help", "vista"}
--     g.minimap_close_filetypes = {"startify", "netrw", "vim-plug", "floaterm"}
--     g.minimap_block_buftypes = {
--         "nofile",
--         "nowrite",
--         "quickfix",
--         "terminal",
--         "prompt"
--     }
-- end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Luadev                          │
-- ╰──────────────────────────────────────────────────────────╯
-- function M.luadev()
--     map("n", "<Leader>x<CR>", "<Plug>(Luadev-RunLine)", {noremap = false})
--     map("n", "<Leader>x.", "<Plug>(Luadev-Run)", {noremap = false})
-- end

return M
