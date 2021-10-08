" A file that contains old/extra stuff for vim

" Function Keys: {{{
" Maybe update this?
  " <F1> = run shell script
  " <F2> = toggle wrap on and off
  " <F3> = turn on/off relative line numbers
  " <F4> = compile markdown file using pandoc
  " <F5> = compile rmarkdown based on `output`
  " <F6> = compile rmarkdown (only pdf) using `RMarkdown`

  " g; / g, = previous/next insertion
  " ysiw' = add quotes around word
  " S' = in visual mode add quotes around
  " ds' = delete quotes

  " viwU = change to upper case
" }}} Function Keys

  " Plug 'itchyny/vim-highlighturl'
  " Plug 'vim-airline/vim-airline'

" === Airline === {{{
  set laststatus=2
  let g:airline_powerline_fonts = 1
  let g:airline_section_b = ' %{strftime("%I:%M")}'
  " let g:airline_section_z = '☰ %3l/%L:%3v'
  let g:airline_skip_empty_sections=1
  let g:airline_highlighting_cache = 1
  let g:airline_detect_spell=0
  " let g:airline_section_warning = ''
  " let g:airline_section_error = ''
  let g:airline#extensions#tabline#enabled = 2
  let g:airline#extensions#tabline#fnamemod = ':t'
  let g:airline#extensions#tabline#show_tab_nr = 0
  let g:airline#extensions#tabline#tab_nr_type = 0
  let g:airline#extensions#tabline#show_tab_type = 0 " shows buffer etc
  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

  let g:airline_extensions = ['branch', 'tabline', 'fzf']
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
  let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
  " let g:airline#extensions#tabline#show_tabs = 0
  " let g:airline#extensions#hunks#enabled = 0
  let g:airline_theme='srcery'
  " let g:airline_theme='gruvbox_material'
  " let g:airline_theme='everforest'
  let g:gruvbox_material_statusline_style='mix'
  " " let g:airline_theme='oceanic_material'
" }}} === Airline ===

" =========================

highlight Normal guibg=none ctermbg=NONE
highlight NonText guibg=none ctermbg=NONE
highlight LineNr guibg=none ctermbg=NONE
highlight SignColumn guibg=none ctermbg=NONE
highlight TrailingWhitespace ctermfg=0 guifg=Black ctermbg=8 guibg=#41535B
highlight EndOfBuffer guibg=NONE ctermbg=NONE guifg=Black ctermfg=0
highlight! default link CocErrorHighlight WarningMsg
highlight! default link CocErrorSign CocErrorHighlight
highlight! CocWarningSign  ctermfg=Brown guifg=#ff922b
highlight! default link CocInfoSign Title
highlight! default link CocHintSign Question
highlight clear SignColumn

hi DiffAdd      gui=none guifg=#819C3B guibg=NONE
hi DiffChange   gui=none    guifg=NONE          guibg=#FF9500
hi DiffDelete   gui=bold guifg=#DC3958 guibg=NONE
hi DiffText     gui=none guifg=#4C96A8 guibg=NONE

" =========================

" === treesitter === {{{
" bash bibtex c python r regex rust
" comment css gomod json lua yaml toml
" python ?? why not work
lua <<EOF
require'nvim-treesitter.configs'.setup {
ensure_installed = { "go" },
  highlight = {
    enable = true,
    disable = { "python" },
  }
}
EOF

  ensure_installed = "maintained",
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = { "bash", "python", "sh" },
  }

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
   textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      }
    }
  }

" }}} === treesitter ===

" =========================

" === vifm === {{{
  let g:vifm_replace_netrw = 1
  let g:vifm_replace_netrw_cmd = "Vifm"
  let g:vifm_embed_term = 1
  let g:vifm_embed_split = 1

  let g:vifm_exec_args =
" }}} === vifm ===

" =========================

" === Hack to make CocExplorer hijack Netwr === {{{
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'CocCommand explorer' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
" }}} === CocExplorer hack ===

" =========================

" === Vim Commentary === {{{
  autocmd FileType hjson setlocal commentstring=#\ %s
"}}} === Vim Commentary ===

" =========================

" === Bracey === {{{
  Plug 'turbio/bracey.vim', {'do': 'npm install --prefix server'}
  nmap <Leader>br :Bracey<CR>
  nmap <Leader>bR :BraceyReload<CR>
" }}} === Bracey ===

  " === Vim-Livedown === {{{
  Plug 'shime/vim-livedown'
  nmap gm :LivedownToggle<CR>
  " should markdown preview get shown automatically upon opening markdown buffer
  let g:livedown_autorun = 0
  " should the browser window pop-up upon previewing
  let g:livedown_open = 1
  " the port on which Livedown server will run
  let g:livedown_port = 1337
  " the browser to use, can also be firefox, chrome or other, depending on your executable
  let g:livedown_browser = "firefox"
" }}} === Vim-Livedown ===

" ============== Folding ============== {{{
Plug 'tmhedberg/SimpylFold'
Plug 'Konfekt/FastFold'
let g:SimpylFold_docstring_preview = 1

nmap zuz <Plug>(FastFoldUpdate)
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']

let g:markdown_folding = 1
let g:tex_fold_enabled = 1
let g:vimsyn_folding = 'af'
let g:xml_syntax_folding = 1
let g:sh_fold_enabled= 7
let g:ruby_fold = 1
let g:perl_fold = 1
let g:perl_fold_blocks = 1
let g:r_syntax_folding = 1
let g:rust_fold = 1
" }}} === Folding ===
