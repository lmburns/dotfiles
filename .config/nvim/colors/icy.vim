if !(exists('g:colors_name') && g:colors_name ==# 'icy')
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'icy'
highlight DiffDelete guifg=NONE guibg=#430E0E guisp=NONE gui=NONE blend=NONE
highlight DiffChange guifg=NONE guibg=#0E323A guisp=NONE gui=NONE blend=NONE
highlight Directory guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link CursorIM Cursor
highlight Cursor guifg=NONE guibg=NONE guisp=NONE gui=reverse blend=NONE
highlight Conceal guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link ColorColumn CursorLine
highlight Special guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSType Type
highlight Number guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSWarning guifg=#E46767 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Operator guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Constant guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSLiteral String
highlight Bold guifg=NONE guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TSUnderline guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight TSEmphasis guifg=NONE guibg=NONE guisp=NONE gui=italic blend=NONE
highlight TSText guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSTagDelimiter Delimiter
highlight Function guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSTag Tag
highlight! link TSSymbol Identifier
highlight! link TSStringEscape Character
highlight! link TSStringRegex TSString
highlight! link TSRepeat Repeat
highlight! link TSPunctSpecial Delimiter
highlight! link TSPunctBracket Delimiter
highlight! link TSPunctDelimiter Delimiter
highlight WarningMsg guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSOperator Operator
highlight! link TSNumber Number
highlight TSNamespace guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSLabel Label
highlight! link TSInclude Include
highlight! link TSFuncMacro Macro
highlight! link TSFloat Float
highlight TSField guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSException Exception
highlight TSError guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSConstructor guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSConstMacro Macro
highlight! link TSConstBuiltin Constant
highlight! link TSConstant Constant
highlight! link TSComment Comment
highlight! link TSCharacter Character
highlight! link TSBoolean Boolean
highlight TSAttribute guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Normal guifg=#C7C9D1 guibg=#161822 guisp=NONE gui=NONE blend=NONE
highlight LspSignatureActiveParameter guifg=#A092C8 guibg=#292B38 guisp=NONE gui=underline,bold blend=NONE
highlight LspDiagnosticsFloatingHint guifg=#A4BF8D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link MsgSeparator Normal
highlight LspDiagnosticsUnderlineHint guifg=NONE guibg=NONE guisp=#A4BF8D gui=underline blend=NONE
highlight! link LspDiagnosticsVirtualTextHint LspDiagnosticsDefaultHint
highlight SignChange guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsSignInformation guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeGitRenamed guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsFloatingInformation guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight mkdLineBreak guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineInformation guifg=NONE guibg=NONE guisp=#85A0C7 gui=underline blend=NONE
highlight Todo guifg=#E46767 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight! link LspDiagnosticsVirtualTextInformation LspDiagnosticsDefaultInformation
highlight! link TSFunction Function
highlight LspDiagnosticsSignError guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSString String
highlight! link TSConditional Conditional
highlight! link TSKeyword Keyword
highlight LspDiagnosticsUnderlineError guifg=NONE guibg=NONE guisp=#E46767 gui=underline blend=NONE
highlight! link TSProperty TSField
highlight! link LspDiagnosticsVirtualTextError LspDiagnosticsDefaultError
highlight TSVariableBuiltin guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsSignWarning guifg=#EBCA89 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeGitStaged guifg=#A4BF8D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsFloatingWarning guifg=#EBCA89 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight DiffviewVertSplit guifg=#161822 guibg=#161822 guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsUnderlineWarning guifg=NONE guibg=NONE guisp=#EBCA89 gui=underline blend=NONE
highlight NvimTreeOpenedFolderName guifg=#75ACB8 guibg=NONE guisp=NONE gui=italic blend=NONE
highlight! link LspDiagnosticsVirtualTextWarning LspDiagnosticsDefaultWarning
highlight NvimTreeFolderIcon guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeFolderName guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeRootFolder guifg=#577DB2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyERROR guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TelescopeMatching guifg=#E46767 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight TelescopeSelection guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyTRACE guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight HopUnmatched guifg=#414758 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight HopNextKey2 guifg=#2b8db3 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight HopNextKey1 guifg=#00dfff guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight HopNextKey guifg=#ff007c guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspTroubleIndent guifg=#6A6C81 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Substitute Search
highlight StatusLineAccent guifg=#C7C9D1 guibg=#232839 guisp=NONE gui=NONE blend=NONE
highlight Title guifg=#85A0C7 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight NotifyERRORTitle guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyDEBUG guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyINFO guifg=#A4BF8D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyWARN guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link DiffviewFilePanelDeletion SignDelete
highlight! link DiffviewFilePanelInsertion SignAdd
highlight! link DiffviewStatusDeleted SignDelete
highlight! link DiffviewStatusRenamed SignChange
highlight! link DiffviewStatusModified SignChange
highlight! link DiffviewStatusAdded SignAdd
highlight! link DiffviewNormal NvimTreeNormal
highlight CmpDocumentationBorder guifg=NONE guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight CmpDocumentation guifg=NONE guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight WhichKeyFloat guifg=NONE guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight FloatBorder guifg=#828597 guibg=#272835 guisp=NONE gui=NONE blend=NONE
highlight! link TabLineInformation LspDiagnosticsSignInformation
highlight! link TabLineHint LspDiagnosticsSignHint
highlight Comment guifg=#828597 guibg=NONE guisp=NONE gui=italic blend=NONE
highlight LspReferenceRead guifg=NONE guibg=#292B38 guisp=NONE gui=underline blend=NONE
highlight LspReferenceText guifg=NONE guibg=#292B38 guisp=NONE gui=underline blend=NONE
highlight! link TabLineWarning LspDiagnosticsSignWarning
highlight! link TabLineError LspDiagnosticsSignError
highlight! link TSFuncBuiltin Function
highlight PreProc guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TabLine guifg=#C7C9D1 guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight NotifyTRACETitle guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyDEBUGTitle guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyINFOTitle guifg=#A4BF8D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NotifyWARNTitle guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TermCursor Cursor
highlight FlutterWidgetGuides guifg=#6A6C81 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight markdownItalic guifg=NONE guibg=NONE guisp=NONE gui=italic blend=NONE
highlight markdownLinkText guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link markdownIdDelimiter Delimiter
highlight! link markdownLinkDelimiter Delimiter
highlight! link markdownLinkTextDelimiter Delimiter
highlight! link TSTitle Title
highlight Italic guifg=NONE guibg=NONE guisp=NONE gui=italic blend=NONE
highlight! link mkdEscape Delimiter
highlight! link mkdInlineURL mkdLink
highlight mkdHeading guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight mkdLink guifg=#85A0C7 guibg=NONE guisp=NONE gui=underline blend=NONE
highlight! link TSMethod Function
highlight TelescopeBorder guifg=#414758 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSVariable guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeSpecialFile guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeImageFile guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NvimTreeExecFile guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight luaTSConstructor guifg=#8F94A3 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link NvimTreeOpenedFile NvimTreeOpenedFolderName
highlight NvimTreeVertSplit guifg=#161822 guibg=#161822 guisp=NONE gui=NONE blend=NONE
highlight NvimTreeNormal guifg=#BCBFC8 guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight NvimTreeIndentMarker guifg=#828597 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SignDelete guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SignAdd guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TSURI guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight markdownCode guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight NormalFloat guifg=NONE guibg=#272835 guisp=NONE gui=NONE blend=NONE
highlight TSStrike guifg=NONE guibg=NONE guisp=NONE gui=strikethrough blend=NONE
highlight MatchParen guifg=NONE guibg=#1B1F2C guisp=NONE gui=underline blend=NONE
highlight! link lCursor Cursor
highlight TSDanger guifg=#E46767 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight! link MsgArea Normal
highlight! link htmlH1 Title
highlight! link TSTypeBuiltin Type
highlight Identifier guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Repeat guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Conditional guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSParameterReference TSParameter
highlight Ignore guifg=#C7C9D1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Underlined guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight Debug guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SpecialComment guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSParameter TSField
highlight Delimiter guifg=#8F94A3 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link TSKeywordFunction Keyword
highlight Tag guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link SpecialChar Character
highlight Type guifg=#EBCA89 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link PreCondit PreProc
highlight! link Typedef Type
highlight! link Macro PreProc
highlight! link Define PreProc
highlight SpellCap guifg=#C7C9D1 guibg=NONE guisp=#EBCA89 gui=underline blend=NONE
highlight ErrorMsg guifg=#E46767 guibg=#430E0E guisp=NONE gui=NONE blend=NONE
highlight Exception guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Label guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Statement guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Float guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight TabLineSel guifg=#0E1016 guibg=#85A0C7 guisp=NONE gui=NONE blend=NONE
highlight! link Character Constant
highlight Structure guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StorageClass guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight String guifg=#A4BF8D guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight EndOfBuffer guifg=#36384A guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight VertSplit guifg=#36384A guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link SignColumn Normal
highlight! link NormalNC Normal
highlight LspDiagnosticsFloatingError guifg=#E46767 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link IncSearch Search
highlight! link TermCursorNC Cursor
highlight! link Question MoreMsg
highlight! link ModeMsg Normal
highlight DiffAdd guifg=NONE guibg=#0E323A guisp=NONE gui=NONE blend=NONE
highlight LspCodeLensSeparator guifg=#9B9DAB guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight DiffText guifg=NONE guibg=#144B57 guisp=NONE gui=NONE blend=NONE
highlight Pmenu guifg=#66697A guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight LspCodeLens guifg=#9B9DAB guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight PmenuSbar guifg=NONE guibg=#1C1D26 guisp=NONE gui=NONE blend=NONE
highlight LspReferenceWrite guifg=NONE guibg=#292B38 guisp=NONE gui=underline blend=NONE
highlight Error guifg=#E46767 guibg=#430E0E guisp=NONE gui=NONE blend=NONE
highlight! link CursorColumn CursorLine
highlight! link WildMenu PmenuSel
highlight Whitespace guifg=#545664 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link VisualNOS Visual
highlight Visual guifg=NONE guibg=#292B38 guisp=NONE gui=NONE blend=NONE
highlight Boolean guifg=#D18771 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Include PreProc
highlight TabLineFill guifg=#C7C9D1 guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight Keyword guifg=#A092C8 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CursorLine guifg=NONE guibg=#1B1F2C guisp=NONE gui=NONE blend=NONE
highlight StatusLineNC guifg=#828597 guibg=#171B26 guisp=NONE gui=NONE blend=NONE
highlight StatusLine guifg=#9598A7 guibg=#232839 guisp=NONE gui=NONE blend=NONE
highlight SpellRare guifg=#C7C9D1 guibg=NONE guisp=#85A0C7 gui=underline blend=NONE
highlight Folded guifg=#5C5E70 guibg=#0E1016 guisp=NONE gui=NONE blend=NONE
highlight SpellLocal guifg=#C7C9D1 guibg=NONE guisp=#A4BF8D gui=underline blend=NONE
highlight SpellBad guifg=#C7C9D1 guibg=NONE guisp=#E46767 gui=underline blend=NONE
highlight SpecialKey guifg=#85A0C7 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Search guifg=#161822 guibg=#828597 guisp=NONE gui=NONE blend=NONE
highlight! link markdownUrl mkdLink
highlight! link QuickFixLine CursorLine
highlight PmenuThumb guifg=NONE guibg=#272835 guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultHint guifg=#A4BF8D guibg=NONE guisp=NONE gui=underline blend=NONE
highlight PmenuSel guifg=#9DB3D2 guibg=#1C1D26 guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultInformation guifg=#85A0C7 guibg=NONE guisp=NONE gui=underline blend=NONE
highlight! link NonText EndOfBuffer
highlight LspDiagnosticsDefaultWarning guifg=#EBCA89 guibg=NONE guisp=NONE gui=underline blend=NONE
highlight MoreMsg guifg=#89B8C2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsDefaultError guifg=#E46767 guibg=NONE guisp=NONE gui=underline blend=NONE
highlight CursorLineNr guifg=#85A0C7 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight LineNr guifg=#828597 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight FoldColumn guifg=#828597 guibg=#161822 guisp=NONE gui=NONE blend=NONE
highlight TSAnnotation guifg=#85A0C7 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight LspDiagnosticsSignHint guifg=#A4BF8D guibg=NONE guisp=NONE gui=NONE blend=NONE
