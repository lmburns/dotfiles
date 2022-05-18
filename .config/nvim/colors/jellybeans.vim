if !(exists('g:colors_name') && g:colors_name ==# 'jellybeans')
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'jellybeans'
highlight CocInfoHighlight guifg=NONE guibg=NONE guisp=#D1EBBD gui=NONE blend=NONE
highlight CocWarningHighlight guifg=NONE guibg=NONE guisp=#FFBA66 gui=none blend=NONE
highlight MatchParen guifg=#F09EBF guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TSField guifg=#9AAE6B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Bold guifg=NONE guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Normal guifg=#E8E8D4 guibg=#141414 guisp=NONE gui=NONE blend=NONE
highlight TSConstant guifg=#8297C0 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight LspDiagnosticsUnderlineHint guifg=NONE guibg=NONE guisp=#D1EBBD gui=undercurl blend=NONE
highlight LspDiagnosticsVirtualTextHint guifg=#D1EBBD guibg=#131F0A guisp=NONE gui=NONE blend=NONE
highlight CocUnusedHighlight guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TabLineSel guifg=#70B950 guibg=#000000 guisp=NONE gui=NONE blend=NONE
highlight CursorLineNr guifg=#CBC4C3 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Directory guifg=#DAD086 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight htmlLink guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Identifier guifg=#C5B5EE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsVirtualTextError guifg=#C92C2C guibg=#2A0909 guisp=NONE gui=NONE blend=NONE
highlight Search guifg=#F09EBF guibg=#312129 guisp=NONE gui=NONE blend=NONE
highlight Folded guifg=#A0A8B0 guibg=#374048 guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineWarning guifg=NONE guibg=NONE guisp=#FFBA66 gui=undercurl blend=NONE
highlight Underlined guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight CocHintVirtualText guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultHint guifg=#D1EBBD guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StringDelimiter guifg=#556633 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultInformation guifg=#B2D1F0 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CocWarningVirtualText guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultWarning guifg=#FFBA66 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CocErrorVirtualText guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultError guifg=#C92C2C guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CocHintHighlight guifg=NONE guibg=NONE guisp=#B2D1F0 gui=NONE blend=NONE
highlight LspReferenceWrite guifg=NONE guibg=#262626 guisp=NONE gui=NONE blend=NONE
highlight LspReferenceRead guifg=NONE guibg=#262626 guisp=NONE gui=NONE blend=NONE
highlight LspReferenceText guifg=NONE guibg=#262626 guisp=NONE gui=NONE blend=NONE
highlight CocErrorHighlight guifg=NONE guibg=NONE guisp=#CF694A gui=NONE blend=NONE
highlight! link NvimTreeGitDeleted GitSignsDelete
highlight Statement guifg=#B2D1F0 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NvimTreeGitNew GitSignsAdd
highlight TSPunctDelimiter guifg=#2D7168 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight VertSplit guifg=#413D42 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SignColumn guifg=#787878 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NvimTreeGitMerge GitSignsChange
highlight NvimTreeGitStaged guifg=#D1EBBD guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Title guifg=#70B950 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeRootFolder guifg=#DAD086 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TSNumber guifg=#FFA27A guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineError guifg=NONE guibg=NONE guisp=#C92C2C gui=undercurl blend=NONE
highlight PreProc guifg=#8297C0 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSMethod guifg=#C5B5EE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSKeywordFunction guifg=#F09EBF guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Structure guifg=#8FBEDC guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Comment guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight GitSignsDelete guifg=#C92C2C guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight ErrorMsg guifg=NONE guibg=#922020 guisp=NONE gui=NONE blend=NONE
highlight TelescopeBorder guifg=#8297C0 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CursorColumn guifg=NONE guibg=#1C1C1C guisp=NONE gui=NONE blend=NONE
highlight WildMenu guifg=#F09EBF guibg=#312129 guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsVirtualTextWarning guifg=#FFBA66 guibg=#291600 guisp=NONE gui=NONE blend=NONE
highlight! link Sneak Search
highlight Visual guifg=NONE guibg=#404040 guisp=NONE gui=NONE blend=NONE
highlight Cursor guifg=#141414 guibg=#B2D1F0 guisp=NONE gui=NONE blend=NONE
highlight Special guifg=#8BC1AA guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TabLineFill guifg=#9199A1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight DiffAdd guifg=#D1EBBD guibg=#437119 guisp=NONE gui=NONE blend=NONE
highlight! link Include PreProc
highlight StatusLineNC guifg=#C7C7C7 guibg=#1C1C1C guisp=NONE gui=NONE blend=NONE
highlight SpellRare guifg=NONE guibg=#520061 guisp=NONE gui=NONE blend=NONE
highlight Type guifg=#FFBA66 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SpellLocal guifg=NONE guibg=#2D7168 guisp=NONE gui=NONE blend=NONE
highlight SpellBad guifg=NONE guibg=#922020 guisp=NONE gui=NONE blend=NONE
highlight SpecialKey guifg=#404040 guibg=#1C1C1C guisp=NONE gui=NONE blend=NONE
highlight TSPunctBracket guifg=#2D7168 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight QuickFixLine guifg=NONE guibg=#374048 guisp=NONE gui=NONE blend=NONE
highlight PmenuSel guifg=#000000 guibg=#8297C0 guisp=NONE gui=bold blend=NONE
highlight Pmenu guifg=#FFFFFF guibg=#1F1F1F guisp=NONE gui=NONE blend=NONE
highlight Italic guifg=NONE guibg=NONE guisp=NONE gui=italic blend=NONE
highlight MoreMsg guifg=#7A9E6B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NvimTreeGitRenamed GitSignsChange
highlight FoldColumn guifg=#535C65 guibg=#1F1F1F guisp=NONE gui=NONE blend=NONE
highlight NonText guifg=#616161 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NvimTreeGitDirty GitSignsChange
highlight TSStrike guifg=NONE guibg=NONE guisp=NONE gui=strikethrough blend=NONE
highlight DiffDelete guifg=#42000A guibg=#70008A guisp=NONE gui=NONE blend=NONE
highlight Delimiter guifg=#668799 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SpellCap guifg=NONE guibg=#0000E0 guisp=NONE gui=NONE blend=NONE
highlight Conceal guifg=#8FBEDC guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight ColorColumn guifg=NONE guibg=#000000 guisp=NONE gui=NONE blend=NONE
highlight TabLine guifg=#B0B8BF guibg=#000000 guisp=NONE gui=NONE blend=NONE
highlight! link TelescopeMatching Search
highlight TelescopeSelection guifg=#BBC7DD guibg=#1B2536 guisp=NONE gui=NONE blend=NONE
highlight TelescopeSelectionCaret guifg=#FFBA66 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight GitSignsChange guifg=#FFBA66 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CursorLine guifg=NONE guibg=#1C1C1C guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineInformation guifg=NONE guibg=NONE guisp=#B2D1F0 gui=undercurl blend=NONE
highlight TelescopePromptPrefix guifg=#FFBA66 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsVirtualTextInformation guifg=#B2D1F0 guibg=#091C2F guisp=NONE gui=NONE blend=NONE
highlight TSURI guifg=#8FBEDC guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Function guifg=#FACF7A guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Question guifg=#70B950 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight DiffText guifg=#8FBEDC guibg=#000000 guisp=NONE gui=NONE blend=NONE
highlight! link TSEmphasis Italic
highlight StatusLine guifg=#FFFFFF guibg=#1C1C1C guisp=NONE gui=NONE blend=NONE
highlight GitSignsAdd guifg=#70B950 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSTagDelimiter guifg=#556677 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CocCodeLens guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight DiffChange guifg=NONE guibg=#2B5C78 guisp=NONE gui=NONE blend=NONE
highlight Todo guifg=#C7C7C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CocInfoVirtualText guifg=#878787 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSFunction guifg=#FACF7A guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Error guifg=NONE guibg=#922020 guisp=NONE gui=NONE blend=NONE
highlight TSPunctSpecial guifg=#2D7168 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight String guifg=#9AAE6B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSKeyword guifg=#F09EBF guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSVariable Normal
highlight TSOperator guifg=#CF694A guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Operator guifg=#8FBEDC guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSNamespace guifg=#F09EBF guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LineNr guifg=#5F5958 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Constant guifg=#CF694A guibg=NONE guisp=NONE gui=NONE blend=NONE
