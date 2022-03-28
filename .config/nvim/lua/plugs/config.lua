local M = {}

local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd

function M.bqf()
  if g.colors_name == "one" then
    cmd("hi! link BqfPreviewBorder Parameter")
  end

  require("bqf").setup(
      {
        auto_enable = true,
        auto_resize_height = true,
        preview = { auto_preview = true, delay_syntax = 50 },
        func_map = { split = "<C-s>", drop = "o", openc = "O",
                     tabdrop = "<C-t>" },
        filter = {
          fzf = {
            action_for = {
              ["enter"] = "drop",
              ["ctrl-s"] = "split",
              ["ctrl-t"] = "tab drop",
              ["ctrl-x"] = "",
            },
            extra_opts = { "-d", "│" },
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
      "n", "<CR>", "<Plug>(openbrowser-open)",
      { noremap = false, buffer = true, silent = true }
  )
end

function M.lf()
  g.lf_map_keys = 0
  g.lf_replace_netrw = 1
  map("n", "<Leader>lf", ":Lf<CR>")
  map("n", "<C-o>", ":Lf<CR>")

end

function M.floaterm()
  map("n", "<Leader>fll", ":Floaterms<CR>")
  map("n", "<Leader>flt", ":FloatermToggle<CR>")

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
end

function M.targets()
  -- Cheatsheet: https://github.com/wellle/targets.vim/blob/master/cheatsheet.md
  -- vI) = contents inside pair
  -- vAa = around alignment
  -- in( an( In( An( il( al( Il( Al( ... next and last pair

  -- autocmd(
  --     "define_targets",
  --     "User targets#mappings#user call targets#mappings#extend({ 'a': {'argument': [{'o':'(', 'c':')', 's': ','}]}})]]",
  --     true
  -- )

  cmd [[
   augroup define_object
     autocmd User targets#mappings#user call targets#mappings#extend({
           \ 'a': {'argument': [{'o':'(', 'c':')', 's': ','}]}
           \ })
   augroup END
  ]]
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
  cmd [[
    augroup tablemode
      autocmd!
      autocmd FileType markdown,vimwiki
        \ let g:table_mode_map_prefix = '<Leader>t'|
        \ let g:table_mode_realign_map = '<Leader>tr'|
        \ let g:table_mode_delete_row_map = '<Leader>tdd'|
        \ let g:table_mode_delete_column_map = '<Leader>tdc'|
        \ let g:table_mode_insert_column_after_map = '<Leader>tic'|
        \ let g:table_mode_echo_cell_map = '<Leader>t?'|
        \ let g:table_mode_sort_map = '<Leader>ts'|
        \ let g:table_mode_tableize_map = '<Leader>tt'|
        \ let g:table_mode_tableize_d_map = '<Leader>T' |
        \ let g:table_mode_tableize_auto_border = 1|
        \ let g:table_mode_corner='|'|
        \ let g:table_mode_fillchar = '-'|
        \ let g:table_mode_separator = '|'|
    augroup END
  ]]
end

function M.mkdx()
  g["mkdx#settings"] = {
    restore_visual = 1,
    gf_on_steroids = 1,
    highlight = { enable = 1 },
    enter = { shift = 1 },
    map = { prefix = "m", enable = 1 },
    links = { external = { enable = 1 } },
    checkbox = { toggles = { " ", "x", "-" } },
    tokens = { strike = "~~", list = "*" },
    fold = { enable = 1, components = { "toc", "fence" } },
    toc = {
      text = "Table of Contents",
      update_on_write = 1,
      details = { nesting_level = 0 },
    },
  }

  cmd [[
    function! <SID>MkdxGoToHeader(header)
      call cursor(str2nr(get(matchlist(a:header, ' *\([0-9]\+\)'), 1, '')), 1)
    endfunction

    function! <SID>MkdxFormatHeader(key, val)
      let text = get(a:val, 'text', '')
      let lnum = get(a:val, 'lnum', '')

      if (empty(text) || empty(lnum)) | return text | endif
      return repeat(' ', 4 - strlen(lnum)) . lnum . ': ' . text
    endfunction

    function! <SID>MkdxFzfQuickfixHeaders()
      let headers = filter(
        \ map(mkdx#QuickfixHeaders(0),function('<SID>MkdxFormatHeader')),
        \ 'v:val != ""'
        \ )

      call fzf#run(fzf#wrap({
        \ 'source': headers,
        \ 'sink': function('<SID>MkdxGoToHeader')
        \ }))
    endfunction

    nnoremap <silent> <Leader>I :call <SID>MkdxFzfQuickfixHeaders()<Cr>
   ]]
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

function M.fugitive()
  map("n", "<Leader>gu", ":G<CR>3j")
  map("n", "<Leader>gq", ":G<CR>:q<CR>")
  map("n", "<Leader>gw", ":Gwrite<CR>")
  map("n", "<Leader>gr", ":Gread<CR>")
  map("n", "<Leader>gh", ":diffget //2<CR>")
  map("n", "<Leader>gl", ":diffget //3<CR>")
  map("n", "<Leader>gp", ":Git push<CR>")

  map("n", "<Leader>d", ":Gdiff<CR>")
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

return M
