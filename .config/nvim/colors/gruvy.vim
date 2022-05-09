if !(exists('g:colors_name') && g:colors_name ==# 'gruvy')
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'gruvy'
highlight TabLine guifg=#E0D2AE guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight StatusLineMode guifg=#1D2020 guibg=#7D6F64 guisp=NONE gui=bold blend=NONE
highlight StatusLineDeco guifg=#EFB839 guibg=#4F4945 guisp=NONE gui=NONE blend=NONE
highlight StatusLineLCol guifg=#E0D2AE guibg=#4F4945 guisp=NONE gui=NONE blend=NONE
highlight Type guifg=#EFB839 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineFT guifg=#E0D2AE guibg=#4F4945 guisp=NONE gui=NONE blend=NONE
highlight Repeat guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Conditional guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Substitute Search
highlight Statement guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Ignore guifg=#E0D2AE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Underlined guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight Debug guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link lCursor Cursor
highlight! link TabLineHint LspDiagnosticsSignHint
highlight Delimiter guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Tag guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link PreCondit PreProc
highlight! link Typedef Type
highlight! link Macro PreProc
highlight! link Define PreProc
highlight! link Include PreProc
highlight PreProc guifg=#78BA7D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Exception guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Label guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Float guifg=#D4879C guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Directory guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight EndOfBuffer guifg=#4F4945 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight VertSplit guifg=#4F4945 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NormalNC Normal
highlight! link CursorColumn CursorLine
highlight! link WildMenu PmenuSel
highlight! link Whitespace Comment
highlight VisualNOS guifg=NONE guibg=NONE guisp=NONE gui=reverse blend=NONE
highlight Visual guifg=NONE guibg=#4F4945 guisp=NONE gui=NONE blend=NONE
highlight TabLineFill guifg=#E0D2AE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineNC guifg=#918273 guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight StatusLine guifg=#E0D2AE guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight SpellRare guifg=#E0D2AE guibg=NONE guisp=#7EA9A7 gui=underline blend=NONE
highlight SpellLocal guifg=#E0D2AE guibg=NONE guisp=#A3BA5E gui=underline blend=NONE
highlight SpellBad guifg=#E0D2AE guibg=NONE guisp=#EC5241 gui=underline blend=NONE
highlight SpecialKey guifg=#7EA9A7 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight! link IncSearch Search
highlight! link QuickFixLine CursorLine
highlight PmenuSel guifg=#F2C65F guibg=#463F39 guisp=NONE gui=NONE blend=NONE
highlight Pmenu guifg=#A79C90 guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight MoreMsg guifg=#EFB839 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link ModeMsg Normal
highlight CursorLineNr guifg=#EFB839 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LineNr guifg=#918273 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link FoldColumn Folded
highlight Folded guifg=NONE guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight DiffText guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link CursorIM Cursor
highlight Conceal guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link ColorColumn CursorLine
highlight TSVariable guifg=#E0D2AE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSTypeBuiltin Type
highlight! link TSType Type
highlight Bold guifg=NONE guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Normal guifg=#E0D2AE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Special guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSURI guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight Number guifg=#D4879C guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSTitle guifg=#7EA9A7 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TSUnderline guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight! link TermCursor Cursor
highlight TSText guifg=#E0D2AE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSTagDelimiter Delimiter
highlight! link TSTag Tag
highlight DiffChange guifg=NONE guibg=#402C11 guisp=NONE gui=NONE blend=NONE
highlight! link TSStringEscape Character
highlight! link TSStringRegex TSString
highlight! link TSString String
highlight! link TSRepeat Repeat
highlight! link TSPunctBracket Delimiter
highlight! link TSPunctDelimiter Delimiter
highlight! link TSParameterReference TSParameter
highlight! link SpecialChar Character
highlight! link TSNumber Number
highlight TSNamespace guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSLabel Label
highlight! link TSKeywordFunction Keyword
highlight! link TSKeyword Keyword
highlight! link TSInclude Include
highlight! link TSFuncMacro Macro
highlight! link TSFuncBuiltin Function
highlight! link TSFloat Float
highlight! link TSException Exception
highlight TSError guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSConstructor guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSConstMacro Macro
highlight! link TSConstBuiltin Constant
highlight! link TSConditional Conditional
highlight! link TSComment Comment
highlight MatchParen guifg=NONE guibg=#4F4945 guisp=NONE gui=underline blend=NONE
highlight! link TSBoolean Boolean
highlight TSAttribute guifg=#78BA7D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsSignHint guifg=#A3BA5E guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsFloatingHint guifg=#A3BA5E guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineHint guifg=NONE guibg=NONE guisp=#A3BA5E gui=underline blend=NONE
highlight! link LspDiagnosticsVirtualTextHint LspDiagnosticsDefaultHint
highlight LspDiagnosticsSignInformation guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsFloatingInformation guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineInformation guifg=NONE guibg=NONE guisp=#7EA9A7 gui=underline blend=NONE
highlight! link LspDiagnosticsVirtualTextInformation LspDiagnosticsDefaultInformation
highlight! link Character Constant
highlight LspDiagnosticsFloatingError guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineError guifg=NONE guibg=NONE guisp=#EC5241 gui=underline blend=NONE
highlight! link LspDiagnosticsVirtualTextError LspDiagnosticsDefaultError
highlight LspDiagnosticsSignWarning guifg=#EFB839 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsFloatingWarning guifg=#EFB839 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineWarning guifg=NONE guibg=NONE guisp=#EFB839 gui=underline blend=NONE
highlight! link LspDiagnosticsVirtualTextWarning LspDiagnosticsDefaultWarning
highlight LspDiagnosticsDefaultHint guifg=#A3BA5E guibg=#28340E guisp=NONE gui=NONE blend=NONE
highlight WarningMsg guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Title guifg=#78BA7D guibg=NONE guisp=NONE gui=bold blend=NONE
highlight DiffDelete guifg=#913127 guibg=#38130F guisp=NONE gui=NONE blend=NONE
highlight DiffAdd guifg=NONE guibg=#28340E guisp=NONE gui=NONE blend=NONE
highlight String guifg=#A3BA5E guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Boolean guifg=#D4879C guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link illuminatedWord Visual
highlight! link TabLineInformation LspDiagnosticsSignInformation
highlight! link TabLineWarning LspDiagnosticsSignWarning
highlight Function guifg=#78BA7D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TabLineError LspDiagnosticsSignError
highlight LspTroubleIndent guifg=#8E7F71 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineFileName guifg=#E0D2AE guibg=#3B3735 guisp=NONE gui=bold blend=NONE
highlight StatusLineLSP guifg=#ACA195 guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight StatusLineGitAlt guifg=#1D2020 guibg=#7D6F64 guisp=NONE gui=NONE blend=NONE
highlight FloatBorder guifg=#918273 guibg=#35373B guisp=NONE gui=NONE blend=NONE
highlight Operator guifg=#78BA7D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineGit guifg=#1D2020 guibg=#7D6F64 guisp=NONE gui=NONE blend=NONE
highlight StatusLineFTAlt guifg=#E0D2AE guibg=#4F4945 guisp=NONE gui=NONE blend=NONE
highlight Constant guifg=#D4879C guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineLColAlt guifg=#E0D2AE guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight FlutterWidgetGuides guifg=#8E7F71 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link mkdInlineURL mkdLink
highlight! link TSCharacter Character
highlight Search guifg=#1D2020 guibg=#918273 guisp=NONE gui=NONE blend=NONE
highlight CursorLine guifg=NONE guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
highlight Cursor guifg=NONE guibg=NONE guisp=NONE gui=reverse blend=NONE
highlight Comment guifg=#918273 guibg=NONE guisp=NONE gui=italic blend=NONE
highlight LspDiagnosticsSignError guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Error guifg=#EC5241 guibg=#38130F guisp=NONE gui=NONE blend=NONE
highlight Keyword guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link htmlH1 Title
highlight NvimTreeRootFolder guifg=#D99D12 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSStrike guifg=NONE guibg=NONE guisp=NONE gui=strikethrough blend=NONE
highlight NvimTreeExecFile guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeFolderIcon guifg=#EFB839 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeFolderName guifg=#EFB839 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight NvimTreeNormal guifg=#DBCA9F guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TelescopeBorder guifg=#655B53 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight NvimTreeIndentMarker guifg=#918273 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeOpenedFolderName guifg=#F0BF4C guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TelescopeMatching guifg=#EC5241 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TSAnnotation guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspReferenceWrite guifg=NONE guibg=#3B3735 guisp=NONE gui=underline blend=NONE
highlight LspReferenceRead guifg=NONE guibg=#3B3735 guisp=NONE gui=underline blend=NONE
highlight TelescopeSelection guifg=#EFB839 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TSField guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SignDelete guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSProperty TSField
highlight! link TSMethod Function
highlight! link TSFunction Function
highlight TSVariableBuiltin guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultInformation guifg=#7EA9A7 guibg=#133434 guisp=NONE gui=NONE blend=NONE
highlight! link TSConstant Constant
highlight LspDiagnosticsDefaultWarning guifg=#EFB839 guibg=#3B2D0C guisp=NONE gui=NONE blend=NONE
highlight! link TSParameter TSField
highlight! link TSLiteral String
highlight TSEmphasis guifg=NONE guibg=NONE guisp=NONE gui=italic blend=NONE
highlight! link TSSymbol Identifier
highlight! link TSOperator Operator
highlight! link SignColumn Normal
highlight ErrorMsg guifg=#EC5241 guibg=#38130F guisp=NONE gui=NONE blend=NONE
highlight SpellCap guifg=#E0D2AE guibg=NONE guisp=#EFB839 gui=underline blend=NONE
highlight PmenuThumb guifg=NONE guibg=#655B53 guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultError guifg=#EC5241 guibg=#38130F guisp=NONE gui=NONE blend=NONE
highlight LspReferenceText guifg=NONE guibg=#3B3735 guisp=NONE gui=underline blend=NONE
highlight! link MsgArea Normal
highlight! link Question MoreMsg
highlight NormalFloat guifg=NONE guibg=#35373B guisp=NONE gui=NONE blend=NONE
highlight PmenuSbar guifg=NONE guibg=#4F4945 guisp=NONE gui=NONE blend=NONE
highlight StorageClass guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Structure guifg=#78BA7D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NonText EndOfBuffer
highlight SpecialComment guifg=#EC5241 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Identifier guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Todo guifg=#EC5241 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight! link TermCursorNC Cursor
highlight! link MsgSeparator Normal
highlight SignAdd guifg=#7EA9A7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SignChange guifg=#EE822B guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Italic guifg=NONE guibg=NONE guisp=NONE gui=italic blend=NONE
highlight mkdLink guifg=#7EA9A7 guibg=NONE guisp=NONE gui=underline blend=NONE
highlight mkdLineBreak guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight mkdHeading guifg=#E0D2AE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TabLineSel guifg=#EFB839 guibg=#3B3735 guisp=NONE gui=NONE blend=NONE
