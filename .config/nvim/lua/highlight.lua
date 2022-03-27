require("common.utils")

cmd [[highlight TelescopeSelection      guifg=#FF9500 gui=bold]]
cmd [[highlight TelescopeSelectionCaret guifg=#819C3B]]
cmd [[highlight TelescopeMultiSelection guifg=#4C96A8]]
cmd [[highlight TelescopeMultiIcon      guifg=#7EB2B1]]
cmd [[highlight TelescopeNormal         guibg=#00000]]
cmd [[highlight TelescopeBorder         guifg=#A06469]]
cmd [[highlight TelescopePromptBorder   guifg=#A06469]]
cmd [[highlight TelescopeResultsBorder  guifg=#A06469]]
cmd [[highlight TelescopePreviewBorder  guifg=#A06469]]
cmd [[highlight TelescopeMatching       guifg=#FF5813]]
cmd [[highlight TelescopePromptPrefix   guifg=#EF1D55]]

cmd [[
  hi DiffAdd      ctermfg=white ctermbg=NONE guifg=#5F875F guibg=NONE
  hi DiffChange   ctermfg=white ctermbg=NONE guifg=#5F5F87 guibg=NONE
  hi DiffDelete   ctermfg=white ctermbg=NONE guifg=#cc6666 guibg=NONE
  hi DiffText     cterm=bold ctermfg=white ctermbg=DarkRed

  hi HighlightedyankRegion ctermbg=Red   guibg=#fb4934
  hi GitBlameVirtualText   cterm=italic  ctermfg=245   gui=italic guifg=#665c54


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
