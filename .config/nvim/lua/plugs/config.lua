local M = {}

local kutils = require("common.kutils")
local utils = require("common.utils")
local K = require("common.keymap")
local map = utils.map
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

function M.delimitmate()
  g.delimitMate_jump_expansion = 1
  g.delimitMate_expand_cr = 2
  map(
      "i", "<CR>", ("pumvisible() ? %s : %s . \"<Plug>delimitMateCR\""):format(
          [["\<C-y>"]], [[(getline('.') =~ '^\s*$' ? '' : "\<C-g>u")]]
      ), { noremap = false, expr = true }
  )
end

function M.open_browser()
  map(
      "n", "o<CR>", "<Plug>(openbrowser-open)",
      { noremap = false, buffer = true, silent = true }
  )
end

function M.suda() map("n", "<Leader>W", ":SudaWrite<CR>") end

function M.lf()
  g.lf_map_keys = 0
  g.lf_replace_netrw = 1

  map("n", "<Leader>lf", ":Lf<CR>")
  map("n", "<C-o>", ":Lf<CR>")

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
  g.floaterm_height = 0.8
  g.floaterm_width = 0.8

  -- Stackoverflow helper
  map("n", "<Leader>so", ":FloatermNew --autoclose=0 so<space>")

end

function M.neoterm()
  g.neoterm_default_mod = "belowright" -- open terminal in bottom split
  g.neoterm_size = 14 -- terminal split size
  g.neoterm_autoscroll = 1 -- scroll to the bottom

  map("n", "<Leader>rr", "<Cmd>execute v:count.'Tclear'<CR>")
  map("n", "<Leader>rt", ":Ttoggle<CR>")
  map("n", "<Leader>ro", ":Ttoggle<CR> :Ttoggle<CR>")
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
  g.vim_markdown_follow_anchor = 1
end

function M.table_mode()
  api.nvim_create_autocmd(
      "FileType", {
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
        pattern = { "markdown", "vimwiki" },
        group = api.nvim_create_augroup("TableMode", { clear = true }),
      }
  )
end

function M.vimwiki()
  g.vimwiki_ext2syntax = {
    [".Rmd"] = "markdown",
    [".rmd"] = "markdown",
    [".md"] = "markdown",
    [".markdown"] = "markdown",
    [".mdown"] = "markdown",
  }
  g.vimwiki_list = { { path = "~/vimwiki", syntax = "markdown", ext = ".md" } }
  g.vimwiki_table_mappings = 0

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
  require("notify").setup(
      {
        stages = "slide",
        timeout = 2000,
        minimum_width = 30,
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
        languages = { lua = { template = { annotation_convention = "ldoc" } } },
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
  map("o", ";", "ib")
  map("o", ":", "ab")

  map("n", "<Leader>ci", "cs`*")
  map("n", "<Leader>o", "ysiw")
  map("n", "mlw", "yss`")
end

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

-- Unused

function M.sneak()
  g["sneak#label"] = 1

  -- map(
  --     { "n", "x" }, "f", "sneak#is_sneaking() ? '<Plug>Sneak_s' : 'f'",
  --     { noremap = false, expr = true }
  -- )
  -- map(
  --     { "n", "x" }, "F", "sneak#is_sneaking() ? '<Plug>Sneak_S' : 'F'",
  --     { noremap = false, expr = true }
  -- )

  map("n", "f", "<Plug>Sneak_s", { noremap = false })
  map("n", "F", "<Plug>Sneak_S", { noremap = false })

  -- Repeat the last Sneak
  map("n", "gs", "f<CR>", { noremap = false })
  map("n", "gS", "F<CR>", { noremap = false })
end

return M
