local M = {}

local kutils = require("common.kutils")
local utils = require("common.utils")
local K = require("common.keymap")
local map = utils.map
local bmap = utils.bmap
local fmap = utils.fmap

local autocmd = utils.autocmd
local create_augroup = utils.create_augroup

function M.bqf()
  cmd("hi! link BqfPreviewBorder Parameter")

  require("bqf").setup(
      {
        auto_enable = true,
        auto_resize_height = true,
        preview = { auto_preview = true, delay_syntax = 50 },
        func_map = {
          split = "<C-s>",
          drop = "o",
          openc = "O",
          tabdrop = "<C-t>",
          pscrollup = "<C-u>",
          pscrolldown = "<C-d>",
          fzffilter = "zf",
          ptogglemode = "z,",
        },
        filter = {
          fzf = {
            action_for = {
              ["enter"] = "drop",
              ["ctrl-s"] = "split",
              ["ctrl-t"] = "tab drop",
              ["ctrl-x"] = "",
            },
            extra_opts = { "--delimiter", "│" },
          },
        },
      }
  )
end

function M.open_browser()
  map(
      "n", "<Leader>gb", "<Plug>(openbrowser-open)",
      { noremap = true, silent = true }
  )
end

function M.suda()
  map("n", "<Leader>W", ":SudaWrite<CR>")
end

function M.floaterm()
  map("n", "<Leader>fll", ":Floaterms<CR>")
  map("n", ";fl", ":FloatermToggle<CR>")

  g.fzf_floaterm_newentries = {
    ["+lazygit"] = {
      title = "lazygit",
      height = 0.9,
      width = 0.9,
      cmd = "lazygit",
    },
    ["+gitui"] = { title = "gitui", height = 0.9, width = 0.9, cmd = "gitui" },
    ["+taskwarrior-tui"] = {
      title = "taskwarrior-tui",
      height = 0.99,
      width = 0.99,
      cmd = "taskwarrior-tui",
    },
    ["+flf"] = { title = "full screen lf", height = 0.9, width = 0.9,
                 cmd = "lf" },
    ["+slf"] = {
      title = "split screen lf",
      wintype = "split",
      height = 0.5,
      cmd = "lf",
    },
    ["+xplr"] = { title = "xplr", cmd = "xplr" },
    ["+gpg-tui"] = {
      title = "gpg-tui",
      height = 0.9,
      width = 0.9,
      cmd = "gpg-tui",
    },
    ["+tokei"] = { title = "tokei", height = 0.9, width = 0.9, cmd = "tokei" },
    ["+dust"] = { title = "dust", height = 0.9, width = 0.9, cmd = "dust" },
    ["+zsh"] = { title = "zsh", height = 0.9, width = 0.9, cmd = "zsh" },
  }

  g.floaterm_shell = "zsh"
  g.floaterm_wintype = "float"
  g.floaterm_height = 0.85
  g.floaterm_width = 0.9
  g.floaterm_borderchars = "─│─│╭╮╯╰"

  -- TODO: Resize floaterm
  -- Floaterm needs keys to expect and not act within
  -- fmap {
  --   "n",
  --   "<Leader>xi",
  --   function()
  --     g.floaterm_height = (g.floaterm_height + 0.1) % 1
  --     g.floaterm_width = (g.floaterm_width + 0.1) % 1
  --     cmd((":FloatermUpdate --height=%d --width=%d"):format(g.floaterm_height, g.floaterm_width))
  --   end,
  -- }

  -- Stackoverflow helper
  map("n", "<Leader>so", ":FloatermNew --autoclose=0 so<space>")
end

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

function M.pandoc()
  g["pandoc#filetypes#handled"] = { "pandoc", "markdown" }
  g["pandoc#after#modules#enabled"] = { "vim-table-mode" }
  g["pandoc#syntax#codeblocks#embeds#langs"] = {
    "c",
    "python",
    "sh",
    "html",
    "css",
  }
  g["pandoc#formatting#mode"] = "h"
  g["pandoc#modules#disabled"] = { "folding", "formatting" }
  g["pandoc#syntax#conceal#cchar_overrides"] = { codelang = " " }
end

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
    "help",
  }
  -- use `ge`
  g.vim_markdown_follow_anchor = 1
  -- g.vim_markdown_folding_disabled = 1

  g.vim_markdown_conceal = 0
  g.vim_markdown_conceal_code_blocks = 0
end

function M.table_mode()
  -- api.nvim_create_autocmd(
  --     "FileType", {
  --       callback = function()
  --         g.table_mode_map_prefix = "<Leader>t"
  --         g.table_mode_realign_map = "<Leader>tr"
  --         g.table_mode_delete_row_map = "<Leader>tdd"
  --         g.table_mode_delete_column_map = "<Leader>tdc"
  --         g.table_mode_insert_column_after_map = "<Leader>tic"
  --         g.table_mode_echo_cell_map = "<Leader>t?"
  --         g.table_mode_sort_map = "<Leader>ts"
  --         g.table_mode_tableize_map = "<Leader>tt"
  --         g.table_mode_tableize_d_map = "<Leader>T"
  --         g.table_mode_tableize_auto_border = 1
  --         g.table_mode_corner = "|"
  --         g.table_mode_fillchar = "-"
  --         g.table_mode_separator = "|"
  --       end,
  --       pattern = { "markdown", "vimwiki" },
  --       group = api.nvim_create_augroup("TableMode", { clear = true }),
  --     }
  -- )
end

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

function M.ultisnips()
  g.UltiSnipsExpandTrigger = "<Leader><tab>"
  g.UltiSnipsJumpForwardTrigger = "<C-j>"
  g.UltiSnipsJumpBackwardTrigger = "<C-k>"
  g.UltiSnipsListSnippets = "<C-u>"
  g.UltiSnipsEditSplit = "horizontal"
end

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

function M.minimap()
  map("n", "<Leader>mi", ":MinimapToggle<CR>")

  g.minimap_width = 10
  g.minimap_auto_start = 0
  g.minimap_auto_start_win_enter = 1
  g.minimap_highlight_range = 1
  g.minimap_block_filetypes = { "fugitive", "nerdtree", "help", "vista" }
  g.minimap_close_filetypes = { "startify", "netrw", "vim-plug", "floaterm" }
  g.minimap_block_buftypes = {
    "nofile",
    "nowrite",
    "quickfix",
    "terminal",
    "prompt",
  }
end

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

function M.notify()
  cmd [[
    highlight NotifyERRORBorder guifg=#8A1F1F
    highlight NotifyWARNBorder guifg=#79491D
    highlight NotifyINFOBorder guifg=#4F6752
    highlight NotifyDEBUGBorder guifg=#8B8B8B
    highlight NotifyTRACEBorder guifg=#4F3552
    highlight NotifyERRORIcon guifg=#F70067
    highlight NotifyWARNIcon guifg=#fe8019
    highlight NotifyINFOIcon guifg=#a3b95a
    highlight NotifyDEBUGIcon guifg=#8B8B8B
    highlight NotifyTRACEIcon guifg=#D484FF
    highlight NotifyERRORTitle  guifg=#F70067
    highlight NotifyWARNTitle guifg=#fe8019
    highlight NotifyINFOTitle guifg=#a3b95a
    highlight NotifyDEBUGTitle  guifg=#8B8B8B
    highlight NotifyTRACETitle  guifg=#D484FF
    highlight link NotifyERRORBody Normal
    highlight link NotifyWARNBody Normal
    highlight link NotifyINFOBody Normal
    highlight link NotifyDEBUGBody Normal
    highlight link NotifyTRACEBody Normal
  ]]

  require("notify").setup(
      {
        stages = "slide",
        timeout = 2000,
        minimum_width = 30,
        -- on_close = function()
        -- -- Could create something to write to a file
        -- end,
        render = "minimal",
        icons = {
          ERROR = " ",
          WARN = " ",
          INFO = " ",
          DEBUG = " ",
          TRACE = " ",
        },
      }
  )
end

function M.neogen()
  local neogen = require("neogen")
  neogen.setup(
      {
        enabled = true,
        input_after_comment = true,
        languages = { lua = { template = { annotation_convention = "emmylua" } } },
      }
  )
  K.i("<C-j>", [[<Cmd>lua require('neogen').jump_next()<CR>]])
  K.i("<C-k>", [[<Cmd>lua require('neogen').jump_prev()<CR>]])
  K.n("<Leader>dg", [[:Neogen<Space>]])
  K.n(
      "<Leader>df",
      [[<Cmd>lua require('neogen').generate({ type = 'func' })<CR>]]
  )
  K.n(
      "<Leader>dc",
      [[<cmd>lua require("neogen").generate({ type = "class" })<CR>]]
  )
end

function M.vcoolor()
  map("n", "<Leader>pc", ":VCoolor<CR>")
  map("n", "<Leader>yb", ":VCoolIns b<CR>")
  map("n", "<Leader>yr", ":VCoolIns r<CR>")
end

function M.hlslens()
  require("hlslens").setup(
      {
        auto_enable = true,
        enable_incsearch = true,
        calm_down = false,
        nearest_only = false,
        nearest_float_when = "auto",
        float_shadow_blend = 50,
        virt_priority = 100,
      }
  )
  cmd([[com! HlSearchLensToggle lua require('hlslens').toggle()]])

  map(
      "n", "n",
      [[<Cmd>execute('norm! ' . v:count1 . 'nzv')<CR><Cmd>lua require('hlslens').start()<CR>]]
  )
  map(
      "n", "N",
      [[<Cmd>execute('norm! ' . v:count1 . 'Nzv')<CR><Cmd>lua require('hlslens').start()<CR>]]
  )
  map(
      "n", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]],
      { noremap = false }
  )
  -- map(
  --     "n", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]],
  --     {}
  -- )
  map(
      "n", "g*",
      [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]],
      { noremap = false }
  )
  map(
      "n", "g#",
      [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]],
      { noremap = false }
  )

  map(
      "x", "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]],
      { noremap = false }
  )
  map(
      "x", "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]],
      { noremap = false }
  )
  map(
      "x", "g*",
      [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {}
  )
  map(
      "x", "g#",
      [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {}
  )

  g["asterisk#keeppos"] = 1
end

function M.surround()
  map("n", "ds", "<Plug>Dsurround", { noremap = false })
  map("n", "cs", "<Plug>Csurround", { noremap = false })
  map("n", "cS", "<Plug>CSurround", { noremap = false })
  map("n", "ys", "<Plug>Ysurround", { noremap = false })
  map("n", "yS", "<Plug>YSurround", { noremap = false })
  map("n", "yss", "<Plug>Yssurround", { noremap = false })
  map("n", "ygs", "<Plug>YSsurround", { noremap = false })
  map("x", "S", "<Plug>VSurround", { noremap = false })
  map("x", "gS", "<Plug>VgSurround", { noremap = false })
end

function M.lazygit()
  g.lazygit_floating_window_winblend = 0 -- transparency of floating window
  g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
  g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" } -- customize lazygit popup window corner characters
  g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
  g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

  map("n", "<Leader>lg", ":LazyGit<CR>", { silent = true })
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

  map(
      { "x", "o" }, "is", "<Plug>(textobj-sandwich-query-i)",
      { noremap = false }
  )
  map(
      { "x", "o" }, "as", "<Plug>(textobj-sandwich-query-a)",
      { noremap = false }
  )
  map(
      { "x", "o" }, "iss", "<Plug>(textobj-sandwich-auto-i)",
      { noremap = false }
  )
  map(
      { "x", "o" }, "ass", "<Plug>(textobj-sandwich-auto-a)",
      { noremap = false }
  )
  map(
      { "x", "o" }, "im", "<Plug>(textobj-sandwich-literal-query-i)",
      { noremap = false }
  )
  map(
      { "x", "o" }, "am", "<Plug>(textobj-sandwich-literal-query-a)",
      { noremap = false }
  )

  K.o(";", "ib", { noremap = false })
  K.o(":", "ab", { noremap = false })

  -- Why does noremap need to be used here?
  K.n("<Leader>ci", "cs`*", { noremap = false })
  K.n("<Leader>o", "ysiw", { noremap = false })
  K.n("mlw", "yss`", { noremap = false })
end

function M.dial()
  local augend = require("dial.augend")
  local dmap = require("dial.map")

  require("dial.config").augends:register_group(
      {
        -- default augends used when no group name is specified
        default = {
          augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
          augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
          augend.constant.alias.bool, -- boolean value (true <-> false)
        },
      }
  )

  map("n", "+", dmap.inc_normal(), { silent = true })
  map("n", "_", dmap.dec_normal(), { silent = true })
  map("v", "+", dmap.inc_visual(), { silent = true })
  map("v", "_", dmap.dec_visual(), { silent = true })
  map("v", "g+", dmap.inc_gvisual(), { silent = true })
  map("v", "g_", dmap.dec_gvisual(), { silent = true })
end

-- =============================== Hop ================================
function M.hop()
  -- "etovxqpdygfblzhckisuran"
  require("hop").setup({ keys = "asdfqwertzxcvbuiop" })

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
  fmap {
    "n",
    "f",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = true,
          }
      )
    end,
  }

  -- Normal
  fmap {
    "n",
    "F",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = true,
          }
      )
    end,
  }

  -- Motions
  fmap {
    "o",
    "f",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = true,
            inclusive_jump = true,
          }
      )
    end,
  }

  -- Motions
  fmap {
    "o",
    "F",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = true,
            inclusive_jump = true,
          }
      )
    end,
  }

  -- Visual mode
  fmap {
    { "x" },
    "f",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
    end,
  }

  -- Visual mode
  fmap {
    { "x" },
    "F",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
    end,
  }

  -- ========================== t-Mapping ==========================

  -- Normal
  fmap {
    { "n" },
    "t",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
      -- api.nvim_input("h")
      api.nvim_feedkeys(kutils.termcodes["h"], "n", false)
    end,
  }

  -- Normal
  fmap {
    { "n" },
    "T",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
      api.nvim_feedkeys(kutils.termcodes["l"], "n", false)
    end,
  }

  -- Motions
  fmap {
    { "o" },
    "t",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
    end,
  }

  -- Motions
  fmap {
    { "o" },
    "T",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
    end,
  }

  -- Visual mode
  fmap {
    { "x" },
    "t",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
      api.nvim_feedkeys(kutils.termcodes["h"], "v", false)
    end,
  }

  -- Visual mode
  fmap {
    { "x" },
    "T",
    function()
      require("hop").hint_char1(
          {
            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
            current_line_only = true,
            inclusive_jump = false,
          }
      )
      api.nvim_feedkeys(kutils.termcodes["l"], "v", false)
    end,
  }
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
          ",",
        },

        -- A group to use for overwriting the Normal highlight group in the floating
        -- window. This can be used to change the background color.
        normal_hl = "Normal",

        -- The highlight group to apply to the line that contains the hint characters.
        -- This is used to make them stand out more.
        hint_hl = "Bold",

        -- The border style to use for the floating window.
        border = "single",
      }
  )

  map("n", "<Leader>wp", "<cmd>lua require('nvim-window').pick()<CR>")
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
        "vim",
        "sh",
        "zsh",
        "markdown",
        "tmux",
        "yaml",
        "xml",
        lua = { names = false },
      }, {
        RGB = false,
        RRGGBB = true,
        RRGGBBAA = true,
        names = false,
        mode = "background",
      }
  )
end

-- ============================== cutlass =============================
function M.cutlass()
  require("cutlass").setup({ cut_key = nil, override_del = nil, exclude = { "vx" } })
end

-- ================================ lf ================================
function M.lf()
  g.lf_map_keys = 0
  g.lf_replace_netrw = 1

  map("n", "<A-o>", ":Lf<CR>")

end

function M.lfnvim()
  g.lf_map_keys = 0
  g.lf_replace_netrw = 1

  require("lf").setup({ border = "double" })

  -- map("n", "<A-o>", ":Lf<CR>")
  map("n", "<C-o>", ":Lfnvim<CR>")

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

return M
