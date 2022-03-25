vim.cmd [[
  highlight TelescopeSelection      guifg=#FF9500 gui=bold
  highlight TelescopeSelectionCaret guifg=#819C3B
  highlight TelescopeMultiSelection guifg=#4C96A8
  highlight TelescopeNormal         guibg=#00000

  highlight TelescopeBorder         guifg=#A06469
  highlight TelescopePromptBorder   guifg=#A06469
  highlight TelescopeResultsBorder  guifg=#A06469
  highlight TelescopePreviewBorder  guifg=#A06469

  highlight TelescopeMatching       guifg=#FF5813

  highlight TelescopePromptPrefix   guifg=#EF1D55

  " ============== background transparent / colors ============== {{{
    highlight DiffAdd      ctermfg=white ctermbg=NONE guifg=#5F875F guibg=NONE
    highlight DiffChange   ctermfg=white ctermbg=NONE guifg=#5F5F87 guibg=NONE
    highlight DiffDelete   ctermfg=white ctermbg=NONE guifg=#cc6666 guibg=NONE
    highlight DiffText     cterm=bold ctermfg=white ctermbg=DarkRed

    exec 'hi! SignifySignAdd    ctermfg=Green  guifg=#50FA7B ' . (has('termguicolors')? 'guibg=none':'ctermbg=') . synIDattr(hlID('SignColumn'),'bg')
    exec 'hi! SignifySignDelete ctermfg=Red    guifg=#FF5555 ' . (has('termguicolors')? 'guibg=none':'ctermbg=') . synIDattr(hlID('SignColumn'),'bg')
    exec 'hi! SignifySignChange ctermfg=Yellow guifg=#FFB86C ' . (has('termguicolors')? 'guibg=none':'ctermbg=') . synIDattr(hlID('SignColumn'),'bg')
    hi HighlightedyankRegion ctermbg=Red   guibg=#fb4934
    hi GitBlameVirtualText   cterm=italic  ctermfg=245   gui=italic guifg=#665c54

    " hi VimwikiHeader1 guifg=#cc241d gui=bold
    " hi VimwikiHeader2 guifg=#fe8019 gui=bold
    " hi VimwikiHeader3 guifg=#689d6a gui=bold
    " hi VimwikiHeader4 guifg=#b8ba25 gui=bold
    " hi VimwikiHeader5 guifg=#b16286 gui=bold
    " hi VimwikiHeader6 guifg=#458588 gui=bold

    hi VimwikiBold    guifg=#a25bc4 gui=bold
    " hi VimwikiBold    guifg=#e9b143 gui=bold
    hi VimwikiCode    guifg=#d3869b
    hi VimwikiItalic  guifg=#83a598 gui=italic

    hi VimwikiHeader1 guifg=#F14A68 gui=bold
    hi VimwikiHeader2 guifg=#F06431 gui=bold
    hi VimwikiHeader3 guifg=#689d6a gui=bold
    hi VimwikiHeader4 guifg=#819C3B gui=bold
    hi VimwikiHeader5 guifg=#98676A gui=bold
    hi VimwikiHeader6 guifg=#458588 gui=bold

    " hi MatchParen guifg=#088649
    " hi vimOperParen guifg=#088649
    " hi vimSep guifg=#088649
    " hi Delimiter guifg=#088649
    " hi Operator guifg=#088649
]]
