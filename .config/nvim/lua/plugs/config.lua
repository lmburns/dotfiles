---Contains configuration items for plugins that don't deserve their own file
--@module config
--@author lmburns

local M = {}

local kutils = require("common.kutils")
local utils = require("common.utils")
local K = require("common.keymap")

local wk = require("which-key")
local map = utils.map
local bmap = utils.bmap
local command = utils.command
local color = require("common.color")

local autocmd = utils.autocmd
local create_augroup = utils.create_augroup

-- ================================ bqf ===============================
function M.bqf()
    color.link("BqfPreviewBorder", "Parameter")

    require("bqf").setup(
        {
            auto_enable = true,
            auto_resize_height = true,
            preview = {auto_preview = true, delay_syntax = 50},
            func_map = {
                split = "<C-s>",
                drop = "o",
                openc = "O",
                tabdrop = "<C-t>",
                pscrollup = "<C-u>",
                pscrolldown = "<C-d>",
                fzffilter = "zf",
                ptogglemode = "z,"
            },
            filter = {
                fzf = {
                    action_for = {
                        ["enter"] = "drop",
                        ["ctrl-s"] = "split",
                        ["ctrl-t"] = "tab drop",
                        ["ctrl-x"] = ""
                    },
                    extra_opts = {"--delimiter", "│"}
                }
            }
        }
    )
end

-- =========================== QFReflector ============================
function M.qf_reflector()
    g.qf_modifiable = 1
    g.qf_write_changes = 1
end

-- ============================= Listish ==============================
function M.listish()
    require("listish").config(
        {
            theme_list = true,
            clearqflist = "Clearquickfix", -- command
            clearloclist = "Clearloclist", -- command
            clear_notes = "ClearListNotes", -- command
            lists_close = "<leader>cc", -- closes both qf/local lists
            in_list_dd = "dd", -- delete current item in the list
            quickfix = {
                open = "qo",
                on_cursor = "qa", -- add current position to the list
                add_note = "qn", -- add current position with your note to the list
                clear = "<leader>qd", -- clear all items
                close = "<leader>qc",
                next = "]q",
                prev = "[q"
            },
            locallist = {
                open = "<leader>wo",
                on_cursor = "<leader>ww",
                add_note = "<leader>wn",
                clear = "<leader>wd",
                close = "<leader>wc",
                next = "]w",
                prev = "[w"
            }
        }
    )
    cmd([[pa cfilter]])
end

-- =========================== PackageInfo ============================
function M.package_info()
    require("package-info").setup(
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

    command(
        "PackageInfo",
        function()
            require("package-info").show()
        end
    )
end

-- =========================== regexplainer ===========================
function M.regexplainer()
    require("regexplainer").setup {
        -- 'narrative'
        mode = "narrative", -- TODO: 'ascii', 'graphical'
        -- automatically show the explainer when the cursor enters a regexp
        auto = false,
        -- filetypes (i.e. extensions) in which to run the autocommand
        filetypes = {
            "html",
            "js",
            "cjs",
            "mjs",
            "ts",
            "jsx",
            "tsx",
            "cjsx",
            "mjsx"
        },
        debug = false, -- Whether to log debug messages
        display = "popup", -- 'split', 'popup', 'pasteboard'
        mappings = {
            toggle = "gR",
            show = "gS"
            -- hide = 'gH',
            -- show_split = 'gP',
            -- show_popup = 'gU',
        },
        narrative = {
            separator = "\n"
        }
    }
end

-- =========================== open-browser ===========================
function M.open_browser()
    map("n", "<LocalLeader>o", "<Plug>(openbrowser-open)")
end

-- =============================== Suda ===============================
function M.suda()
    map("n", "<Leader>W", ":SudaWrite<CR>")
end

-- =============================== Suda ===============================
-- ============================== GHLine ==============================
function M.ghline()
    map("", "<Leader>gO", "<Plug>(gh-repo)")
    map("", "<Leader>gL", "<Plug>(gh-line)")
end

-- ============================== Flaoterm ============================
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

    -- Stackoverflow helper
    map("n", "<Leader>so", ":FloatermNew --autoclose=0 so<space>")
end

-- ============================== targets =============================
function M.targets()
    -- Cheatsheet: https://github.com/wellle/targets.vim/blob/master/cheatsheet.md
    -- vI) = contents inside pair
    -- in( an( In( An( il( al( Il( Al( ... next and last pair
    -- {a,I}{,.;+=...} = a/inside separator
    -- ia = in argument
    -- aa = an argument
    -- inb anb Inb Anb ilb alb Ilb Alb = any block
    -- inq anq Inq Anq ilq alq Ilq Alq == any quote

    cmd [[
   augroup define_object
     autocmd User targets#mappings#user call targets#mappings#extend({
           \ 'a': {'argument': [{'o':'(', 'c':')', 's': ','}]}
           \ })
   augroup END
  ]]

    -- g.targets_aiAI = "aIAi"
    -- g.targets_seekRanges =
    --     "cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA"
    -- g.targets_jumpRanges = g.targets_seekRanges
    --
    -- -- Seeking next/last objects
    -- g.targets_nl = "nm"

    -- map("o", "I", [[targets#e('o', 'i', 'I')]], { expr = true })
    -- map("x", "I", [[targets#e('o', 'i', 'I')]], { expr = true })
    -- map("o", "a", [[targets#e('o', 'a', 'a')]], { expr = true })
    -- map("x", "a", [[targets#e('o', 'a', 'a')]], { expr = true })
    -- map("o", "i", [[targets#e('o', 'I', 'i')]], { expr = true })
    -- map("x", "i", [[targets#e('o', 'I', 'i')]], { expr = true })
    -- map("o", "A", [[targets#e('o', 'A', 'A')]], { expr = true })
    -- map("x", "A", [[targets#e('o', 'A', 'A')]], { expr = true })
end

-- =============================== pandoc =============================
function M.pandoc()
    g["pandoc#filetypes#handled"] = {"pandoc", "markdown"}
    g["pandoc#after#modules#enabled"] = {"vim-table-mode"}
    g["pandoc#syntax#codeblocks#embeds#langs"] = {
        "c",
        "python",
        "sh",
        "html",
        "css"
    }
    g["pandoc#formatting#mode"] = "h"
    g["pandoc#modules#disabled"] = {"folding", "formatting"}
    g["pandoc#syntax#conceal#cchar_overrides"] = {codelang = " "}
end

-- ============================== markdown ============================
function M.markdown()
    g.markdown_fenced_languages = {
        "vim",
        "html",
        "c",
        "py=python",
        "python",
        "go",
        "rust",
        "rs=rust",
        "sh",
        "shell=sh",
        "bash=sh",
        "json",
        "yaml",
        "toml",
        "help"
    }
    -- use `ge`
    g.vim_markdown_follow_anchor = 1
    -- g.vim_markdown_folding_disabled = 1

    g.vim_markdown_conceal = 0
    g.vim_markdown_conceal_code_blocks = 0
end

-- ============================= TableMode ============================
function M.table_mode()
    api.nvim_create_autocmd(
        "FileType",
        {
            callback = function()
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
            end,
            pattern = {"markdown", "vimwiki"},
            group = create_augroup("TableMode")
        }
    )
end

-- ============================== VimWiki =============================
function M.vimwiki()
    -- g.vimwiki_ext2syntax = {
    --   [".Rmd"] = "markdown",
    --   [".rmd"] = "markdown",
    --   [".md"] = "markdown",
    --   [".markdown"] = "markdown",
    --   [".mdown"] = "markdown",
    -- }
    -- g.vimwiki_list = { { path = "~/vimwiki", syntax = "markdown", ext = ".md" } }
    -- g.vimwiki_table_mappings = 0

    cmd [[
    hi VimwikiBold    guifg=#a25bc4 gui=bold
    hi VimwikiCode    guifg=#d3869b
    hi VimwikiItalic  guifg=#83a598 gui=italic

    hi VimwikiHeader1 guifg=#F14A68 gui=bold
    hi VimwikiHeader2 guifg=#F06431 gui=bold
    hi VimwikiHeader3 guifg=#689d6a gui=bold
    hi VimwikiHeader4 guifg=#819C3B gui=bold
    hi VimwikiHeader5 guifg=#98676A gui=bold
    hi VimwikiHeader6 guifg=#458588 gui=bold
  ]]
    -- highlight TabLineSel guifg=#37662b guibg=NONE

    map("n", "<Leader>vw", ":VimwikiIndex<CR>")
end

-- ============================= UltiSnips ============================
function M.ultisnips()
    g.UltiSnipsExpandTrigger = "<Leader><tab>"
    g.UltiSnipsJumpForwardTrigger = "<C-j>"
    g.UltiSnipsJumpBackwardTrigger = "<C-k>"
    g.UltiSnipsListSnippets = "<C-u>"
    g.UltiSnipsEditSplit = "horizontal"
end

-- =============================== Info ===============================
function M.info()
    cmd [[
    if &buftype =~? 'info'
        nmap <buffer> gu <Plug>(InfoUp)
        nmap <buffer> gn <Plug>(InfoNext)
        nmap <buffer> gp <Plug>(InfoPrev)
        nmap <buffer> gm <Plug>(InfoMenu)
        nmap <buffer> gf <Plug>(InfoFollow)
    endif
  ]]
end

-- ============================== Minimap =============================
function M.minimap()
    map("n", "<Leader>mi", ":MinimapToggle<CR>")

    g.minimap_width = 10
    g.minimap_auto_start = 0
    g.minimap_auto_start_win_enter = 1
    g.minimap_highlight_range = 1
    g.minimap_block_filetypes = {"fugitive", "nerdtree", "help", "vista"}
    g.minimap_close_filetypes = {"startify", "netrw", "vim-plug", "floaterm"}
    g.minimap_block_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt"
    }
end

-- =============================== Slime ==============================
function M.slime()
    g.slime_target = "neovim"
    g.syntastic_python_pylint_post_args = "--max-line-length=120"

    cmd [[
    if !empty(glob('$XDG_DATA_HOME/pyenv/shims/python3'))
      let g:python3_host_prog = glob('$XDG_DATA_HOME/pyenv/shims/python')
    endif

    augroup repl
      autocmd!
      autocmd FileType python
        \ xmap <buffer> ,l <Plug>SlimeRegionSend|
        \ nmap <buffer> ,l <Plug>SlimeLineSend|
        \ nmap <buffer> ,p <Plug>SlimeParagraphSend|
        \ nnoremap <silent> <S-CR> :TREPLSendLine<CR><Esc><Home><Down>|
        \ inoremap <silent> <S-CR> <Esc>:TREPLSendLine<CR><Esc>A|
        \ xnoremap <silent> <S-CR> :TREPLSendSelection<CR><Esc><Esc>
        \ nnoremap <Leader>rF :T ptpython<CR>|
        \ nnoremap <Leader>rf :T ipython --no-autoindent --colors=Linux --matplotlib<CR>|
        \ nmap <buffer> <Leader>r<CR> :VT python %<CR>|
        \ nnoremap ,rp :SlimeSend1 <C-r><C-w><CR>|
        \ nnoremap ,rP :SlimeSend1 print(<C-r><C-w>)<CR>|
        \ nnoremap ,rs :SlimeSend1 print(len(<C-r><C-w>), type(<C-r><C-w>))<CR>|
        \ nnoremap ,rt :SlimeSend1 <C-r><C-w>.dtype<CR>|
        \ nnoremap 223 ::%s/^\(\s*print\)\s\+\(.*\)/\1(\2)<CR>|
        \ nnoremap ,rr :FloatermNew --autoclose=0 python %<space>

      autocmd FileType perl nmap <buffer> ,l <Plug>SlimeLineSend
    augroup END
  ]]
end

-- =============================== Notify =============================
function M.notify()
    cmd [[
    hi NotifyERRORBorder guifg=#8A1F1F
    hi NotifyWARNBorder guifg=#79491D
    hi NotifyINFOBorder guifg=#4F6752
    hi NotifyDEBUGBorder guifg=#8B8B8B
    hi NotifyTRACEBorder guifg=#4F3552
    hi NotifyERRORIcon guifg=#F70067
    hi NotifyWARNIcon guifg=#fe8019
    hi NotifyINFOIcon guifg=#a3b95a
    hi NotifyDEBUGIcon guifg=#8B8B8B
    hi NotifyTRACEIcon guifg=#D484FF
    hi NotifyERRORTitle  guifg=#F70067
    hi NotifyWARNTitle guifg=#fe8019
    hi NotifyINFOTitle guifg=#a3b95a
    hi NotifyDEBUGTitle  guifg=#8B8B8B
    hi NotifyTRACETitle  guifg=#D484FF
    hi link NotifyERRORBody Normal
    hi link NotifyWARNBody Normal
    hi link NotifyINFOBody Normal
    hi link NotifyDEBUGBody Normal
    hi link NotifyTRACEBody Normal
  ]]

    ---@type table<string, fun(bufnr: number, notif: table, highlights: table)>
    local renderer = require("notify.render")
    local notify = require("notify")

    notify.setup(
        {
            stages = "slide",
            timeout = 2000,
            minimum_width = 30,
            -- on_close = function()
            -- -- Could create something to write to a file
            -- end,
            render = function(bufnr, notif, highlights)
                local style = notif.title[1] == "" and "minimal" or "default"
                renderer[style](bufnr, notif, highlights)
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
            ["<Leader>nd"] = {notify.dismiss, "Dismiss notification"}
        }
    )

    require("telescope").load_extension("notify")
end

-- =============================== Neogen =============================
function M.neogen()
    local neogen = require("neogen")
    neogen.setup(
        {
            enabled = true,
            input_after_comment = true,
            languages = {lua = {template = {annotation_convention = "emmylua"}}}
        }
    )
    map("i", "<C-.>", [[<Cmd>lua require('neogen').jump_next()<CR>]])
    map("i", "<C-,>", [[<Cmd>lua require('neogen').jump_prev()<CR>]])
    map("n", "<Leader>dg", [[:Neogen<Space>]])
    map("n", "<Leader>df", [[<Cmd>lua require('neogen').generate({ type = 'func' })<CR>]])
    map("n", "<Leader>dc", [[<cmd>lua require("neogen").generate({ type = "class" })<CR>]])
end

-- ============================== VCooler =============================
function M.vcoolor()
    map("n", "<Leader>pc", ":VCoolor<CR>")
    map("n", "<Leader>yb", ":VCoolIns b<CR>")
    map("n", "<Leader>yr", ":VCoolIns r<CR>")
end

-- ============================== HlsLens =============================
function M.hlslens()
    require("hlslens").setup(
        {
            auto_enable = true,
            enable_incsearch = true,
            calm_down = false,
            nearest_only = false,
            nearest_float_when = "auto",
            float_shadow_blend = 50,
            virt_priority = 100
        }
    )
    cmd([[com! HlSearchLensToggle lua require('hlslens').toggle()]])

    map("n", "n", [[<Cmd>execute('norm! ' . v:count1 . 'nzv')<CR><Cmd>lua require('hlslens').start()<CR>]])
    map("n", "N", [[<Cmd>execute('norm! ' . v:count1 . 'Nzv')<CR><Cmd>lua require('hlslens').start()<CR>]])
    map("n", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    -- map(
    --     "n", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]],
    --     {}
    -- )
    map("n", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("n", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})

    map("x", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("x", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {noremap = false})
    map("x", "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {})
    map("x", "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {})

    g["asterisk#keeppos"] = 1
end

-- ============================= Surround =============================
function M.surround()
    map("n", "ds", "<Plug>Dsurround", {noremap = false})
    map("n", "cs", "<Plug>Csurround", {noremap = false})
    map("n", "cS", "<Plug>CSurround", {noremap = false})
    map("n", "ys", "<Plug>Ysurround", {noremap = false})
    map("n", "yS", "<Plug>YSurround", {noremap = false})
    map("n", "yss", "<Plug>Yssurround", {noremap = false})
    map("n", "ygs", "<Plug>YSsurround", {noremap = false})
    map("x", "S", "<Plug>VSurround", {noremap = false})
    map("x", "gS", "<Plug>VgSurround", {noremap = false})
end

-- ============================== LazyGit =============================
function M.lazygit()
    g.lazygit_floating_window_winblend = 0 -- transparency of floating window
    g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    g.lazygit_floating_window_corner_chars = {"╭", "╮", "╰", "╯"} -- customize lazygit popup window corner characters
    g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
    g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

    map("n", "<Leader>lg", ":LazyGit<CR>", {silent = true})
end

-- ============================ ScratchPad ============================
function M.scratchpad()
    g.scratchpad_autostart = 0
    g.scratchpad_autosize = 0
    g.scratchpad_textwidth = 80
    g.scratchpad_minwidth = 12
    g.scratchpad_location = "~/.cache/scratchpad"
    -- g.scratchpad_daily = 0
    -- g.scratchpad_daily_location = '~/.cache/scratchpad_daily.md'
    -- g.scratchpad_daily_format = '%Y-%m-%d'

    map("n", "<Leader>sc", "<cmd>lua R'scratchpad'.invoke()<CR>")
end

-- ============================ Sandwhich =============================
function M.sandwhich()
    -- Sandwhich
    -- sdb = surrounding automatic
    -- saiw( == ysiw(
    -- sd( == ds(
    -- sr(" == cs("

    -- runtime macros/sandwich/keymap/surround.vim

    map({"x", "o"}, "is", "<Plug>(textobj-sandwich-query-i)", {noremap = false})
    map({"x", "o"}, "as", "<Plug>(textobj-sandwich-query-a)", {noremap = false})
    map({"x", "o"}, "iss", "<Plug>(textobj-sandwich-auto-i)", {noremap = false})
    map({"x", "o"}, "ass", "<Plug>(textobj-sandwich-auto-a)", {noremap = false})
    map({"x", "o"}, "im", "<Plug>(textobj-sandwich-literal-query-i)", {noremap = false})
    map({"x", "o"}, "am", "<Plug>(textobj-sandwich-literal-query-a)", {noremap = false})

    -- Why does noremap need to be used here?
    map("n", "<Leader>ci", "cs`*", {noremap = false})
    map("n", "<Leader>o", "ysiw", {noremap = false})
    map("n", "mlw", "yss`", {noremap = false})
end

-- =========================== BetterEscape ===========================
function M.better_esc()
    require("better_escape").setup {
        mapping = {"jk", "kj"}, -- a table with mappings to use
        timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
        clear_empty_lines = false, -- clear line after escaping if there is only whitespace
        keys = "<Esc>" -- keys used for escaping, if it is a function will use the result everytime
        -- keys = function()
        --   return api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
        -- end,
    }
end

-- =========================== SmartSplits ============================
function M.smartsplits()
    require("smart-splits").setup(
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

    local ss = require("smart-splits")

    -- Move between windows
    wk.register(
        {
            ["<C-j>"] = {ss.move_cursor_down, "Move to below window"},
            ["<C-k>"] = {ss.move_cursor_up, "Move to above window"},
            ["<C-h>"] = {ss.move_cursor_left, "Move to left window"},
            ["<C-l>"] = {ss.move_cursor_right, "Move to right window"},
            ["<C-Up>"] = {ss.resize_up, "Resize window up"},
            ["<C-Down>"] = {ss.resize_down, "Resize window down"},
            ["<C-Right>"] = {ss.resize_right, "Resize window right"},
            ["<C-Left>"] = {ss.resize_left, "Resize window left"}
        }
    )
end

-- =============================== Move ===============================
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

    -- https://www.reddit.com/r/neovim/comments/mbj8m5/how_to_setup_ctrlshiftkey_mappings_in_neovim_and/
    -- https://www.eso.org/~ndelmott/ascii.html
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

-- =============================== Hop ================================
function M.hop()
    -- "etovxqpdygfblzhckisuran"
    require("hop").setup({keys = "asdfjklhmnwertzxcvbuiop"})

    -- map("n", "<Leader><Leader>k", ":HopLineBC<CR>")
    -- map("n", "<Leader><Leader>j", ":HopLineAC<CR>")
    map("n", "<Leader><Leader>k", ":HopLineStartBC<CR>")
    map("n", "<Leader><Leader>j", ":HopLineStartAC<CR>")

    map("n", "<Leader><Leader>l", ":HopAnywhereCurrentLineAC<CR>")
    map("n", "<Leader><Leader>h", ":HopAnywhereCurrentLineBC<CR>")
    map("n", "<Leader><Leader>K", ":HopWordBC<CR>")
    map("n", "<Leader><Leader>J", ":HopWordAC<CR>")
    map("n", "<Leader><Leader>/", ":HopPattern<CR>")

    -- ========================== f-Mapping ==========================

    -- Normal
    map(
        "n",
        "f",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true
                }
            )
        end
    )

    -- Normal
    map(
        "n",
        "F",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "f",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "F",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "f",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "F",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
        end
    )

    -- ========================== t-Mapping ==========================

    -- Normal
    map(
        "n",
        "t",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            -- api.nvim_input("h")
            api.nvim_feedkeys(kutils.termcodes["h"], "n", false)
        end
    )

    -- Normal
    map(
        "n",
        "T",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            api.nvim_feedkeys(kutils.termcodes["l"], "n", false)
        end
    )

    -- Motions
    map(
        "o",
        "t",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "T",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "t",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            api.nvim_feedkeys(kutils.termcodes["h"], "v", false)
        end
    )

    -- Visual mode
    map(
        "x",
        "T",
        function()
            require("hop").hint_char1(
                {
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    current_line_only = true,
                    inclusive_jump = false
                }
            )
            api.nvim_feedkeys(kutils.termcodes["l"], "v", false)
        end
    )
end

-- ========================== Window Picker ===========================
function M.window_picker()
    require("nvim-window").setup(
        {
            -- The characters available for hinting windows.
            chars = {
                "a",
                "s",
                "d",
                "f",
                "q",
                "w",
                "e",
                "r",
                "t",
                "z",
                "g",
                ";",
                ","
            },
            -- A group to use for overwriting the Normal highlight group in the floating
            -- window. This can be used to change the background color.
            normal_hl = "Normal",
            -- The highlight group to apply to the line that contains the hint characters.
            -- This is used to make them stand out more.
            hint_hl = "Bold",
            -- The border style to use for the floating window.
            border = "single"
        }
    )

    map("n", "<M-->", "<cmd>lua require('nvim-window').pick()<CR>")
end

-- =============================== nlua ===============================
--- This involves the original mapping in `nlua` to be commented out
function M.nlua()
    map("n", "M", [[<cmd>lua require("nlua").keyword_program()<CR>]])
end

-- ============================ colorizer =============================
function M.colorizer()
    require("colorizer").setup(
        {
            "gitconfig",
            "vim",
            "sh",
            "zsh",
            "markdown",
            "tmux",
            "yaml",
            "xml",
            "css",
            "typescript",
            "javascript",
            lua = {names = false}
        },
        {
            RGB = false,
            RRGGBB = true,
            RRGGBBAA = true,
            names = false,
            mode = "background"
        }
    )
end

-- ============================== cutlass =============================
function M.cutlass()
    require("cutlass").setup({cut_key = nil, override_del = nil, exclude = {"vx"}})
end

-- ============================== grepper =============================
function M.grepper()
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
    map("n", "gs", "<Plug>(GrepperOperator)")
    map("x", "gs", "<Plug>(GrepperOperator)")
    map("n", "<Leader>rg", [[<Cmd>Grepper<CR>]])
    cmd(
        ([[
        aug Grepper
            au!
            au User Grepper ++nested %s
        aug END
    ]]):format(
            [[call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})]]
        )
    )
end

-- =============================== trevj ==============================
function M.trevj()
    require("trevj").setup(
        {
            containers = {
                lua = {
                    table_constructor = {final_separator = ",", final_end_line = true},
                    arguments = {final_separator = false, final_end_line = true},
                    parameters = {final_separator = false, final_end_line = true}
                }
            }
        }
    )
    map("n", "<Leader>k", [[:lua require('trevj').format_at_cursor()<CR>]])
end

-- ============================ registers =============================
function M.registers()
    g.registers_return_symbol = "⏎"
    g.registers_tab_symbol = "\t" -- "·"
    g.registers_show_empty_registers = 0
    -- g.registers_hide_only_whitespace = 1
    g.registers_window_border = "rounded"
    g.registers_insert_modes = false -- removes <C-R> insert mapping
end

-- ================================ lf ================================
function M.lf()
    g.lf_map_keys = 0
    g.lf_replace_netrw = 1

    map("n", "<A-o>", ":Lf<CR>")
end

function M.lfnvim()
    g.lf_replace_netrw = 1

    require("lf").setup(
        {border = "rounded", highlights = {FloatBorder = {guifg = require("kimbox.palette").colors.magenta}}}
    )

    -- map("n", "<A-o>", ":Lf<CR>")
    map("n", "<C-o>", ":Lfnvim<CR>")
    -- map("n", "<A-o>", ":Lfnvim<CR>")
end

-- ============================== Unused ==============================
-- ====================================================================

-- function M.luadev()
--   map("n", "<Leader>x,", "<Plug>(Luadev-RunLine)", { noremap = false })
--   map("n", "<Leader>x<CR>", "<Plug>(Luadev-Run)", { noremap = false })
-- end

-- function M.neoterm()
--   g.neoterm_default_mod = "belowright" -- open terminal in bottom split
--   g.neoterm_size = 14 -- terminal split size
--   g.neoterm_autoscroll = 1 -- scroll to the bottom
--
--   map("n", "<Leader>rr", "<Cmd>execute v:count.'Tclear'<CR>")
--   map("n", "<Leader>rt", ":Ttoggle<CR>")
--   map("n", "<Leader>ro", ":Ttoggle<CR> :Ttoggle<CR>")
-- end

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

-- function M.sneak()
--   g["sneak#label"] = 1
--
--   -- map(
--   --     { "n", "x" }, "f", "sneak#is_sneaking() ? '<Plug>Sneak_s' : 'f'",
--   --     { noremap = false, expr = true }
--   -- )
--   -- map(
--   --     { "n", "x" }, "F", "sneak#is_sneaking() ? '<Plug>Sneak_S' : 'F'",
--   --     { noremap = false, expr = true }
--   -- )
--
--   map("n", "f", "<Plug>Sneak_s", { noremap = false })
--   map("n", "F", "<Plug>Sneak_S", { noremap = false })
--
--   -- Repeat the last Sneak
--   map("n", "gs", "f<CR>", { noremap = false })
--   map("n", "gS", "F<CR>", { noremap = false })
-- end

-- ============================ AbbrevMan =============================
-- function M.abbrevman()
--     require("abbrev-man").setup(
--         {
--             load_natural_dictionaries_at_startup = true,
--             load_programming_dictionaries_at_startup = true,
--             natural_dictionaries = {["nt_en"] = {["adn"] = "and"}},
--             programming_dictionaries = {["pr_py"] = {}}
--         }
--     )
-- end

-- ============================== Spectre =============================
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

return M
