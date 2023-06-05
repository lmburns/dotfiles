func! usr#theme#gruvbox() abort
  " let g:gruvbox_material_background = 'medium'
  " let g:gruvbox_material_palette = 'material'
  let g:gruvbox_material_palette = 'mix'
  let g:gruvbox_material_background = 'hard'
  let g:gruvbox_material_enable_bold = 1
  let g:gruvbox_material_disable_italic_comment = 1
  let g:gruvbox_material_current_word = 'grey background'
  let g:gruvbox_material_visual = 'grey background'
  let g:gruvbox_material_cursor = 'green'
  let g:gruvbox_material_sign_column_background = 'none'
  let g:gruvbox_material_statusline_style = 'mix'
  let g:gruvbox_material_better_performance = 1
  let g:gruvbox_material_diagnostic_text_highlight = 0
  let g:gruvbox_material_diagnostic_line_highlight = 0
  let g:gruvbox_material_diagnostic_virtual_text = 'colored'
endf

func! usr#theme#oceanic() abort
  " let g:oceanic_material_background = "deep"
  " let g:oceanic_material_background = "medium"
  " let g:oceanic_material_background = "darker"
  let g:oceanic_material_background = "ocean"
  let g:oceanic_material_allow_bold = 1
  let g:oceanic_material_allow_italic = 1
  let g:oceanic_material_allow_underline = 1
endfunc

func! usr#theme#everforest() abort
  let g:everforest_disable_italic_comment = 1
  let g:everforest_background = 'hard'
  let g:everforest_enable_italic = 0
  let g:everforest_sign_column_background = 'none'
  let g:everforest_better_performance = 1
endfunc

func! usr#theme#edge() abort
  let g:edge_style = 'aura'
  let g:edge_cursor = 'blue'
  let g:edge_sign_column_background = 'none'
  let g:edge_better_performance = 1
endfunc

func! usr#theme#sonokai() abort
  " maia atlantis era
  " let g:sonokai_style = 'andromeda'
  let g:sonokai_style = 'shusia'
  let g:sonokai_enable_italic = 1
  let g:sonokai_disable_italic_comment = 1
  let g:sonokai_cursor = 'blue'
  let g:sonokai_sign_column_background = 'none'
  let g:sonokai_better_performance = 1
  let g:sonokai_diagnostic_text_highlight = 0
endfunc

func! usr#theme#miramare() abort
  " let g:miramare_enable_italic = 1
  let g:miramare_enable_bold = 1
  let g:miramare_disable_italic_comment = 1
  let g:miramare_cursor = 'purple'
  let g:miramare_current_word = 'grey background'
endfunc

func! usr#theme#material() abort
  " let g:material_theme_style = 'darker-community'
  let g:material_theme_style = 'ocean-community'
  let g:material_terminal_italics = 1
endfunc

func! usr#theme#setup() abort
  " if has('syntax') && !exists('g:syntax_on')
  "   syntax enable
  " endif

  call usr#theme#gruvbox()
  call usr#theme#everforest()
  call usr#theme#edge()

  syntax enable
  colorscheme gruvbox-material

  " colorscheme serenade
  " colorscheme everforest
  " colorscheme gruvbox-material
  " colorscheme sonokai
  " colorscheme oceanic_material
  " colorscheme spaceduck
  " colorscheme bogster
  " colorscheme material
  " colorscheme miramare
  " colorscheme night-owl
  " colorscheme jellybeans
  " colorscheme deep-space
  " colorscheme melange
  " colorscheme iceberg
  " coloscheme OceanicNext
  " colorscheme deus
  " colorscheme onedark
  " colorscheme neodark
  " colorscheme spaceway    " needs work
  " colorscheme alduin      " needs work
  " colorscheme spacegray
  " colorscheme tokyonight
  " colorscheme material
  " edge daycula srcery dogrun palenight
endf
