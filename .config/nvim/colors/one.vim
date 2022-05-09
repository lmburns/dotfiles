if !(exists('g:colors_name') && g:colors_name ==# 'one')
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'one'
highlight Constant guifg=#98c379 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link helpSectionDelim NonText
highlight! link helpHeader Title
highlight! link helpExample Type
highlight! link helpCommand Type
highlight! link DiffLine DiffText
highlight! link DiffAdded DiffAdd
highlight! link DiffRemoved DiffDelete
highlight! link DiffNewFile DiffAdd
highlight! link DiffOldFile DiffDelete
highlight! link DiffFile DiffText
highlight StatusLineWarning guifg=#e5c07b guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight Parameter guifg=#42933d guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineFormat guifg=#528bff guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineFileModified guifg=#8378e1 guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineFileName guifg=#abb2bf guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineHunkRemove guifg=#e06c75 guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineHunkChange guifg=#d19a66 guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineHunkAdd guifg=#98c379 guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineBranch guifg=#56b6c2 guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight WarningMsg guifg=#e5c07b guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Identifier guifg=#e06c75 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineReplace guifg=#30353f guibg=#e06c75 guisp=NONE gui=bold blend=NONE
highlight Number guifg=#d19a66 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Todo guifg=#c678dd guibg=NONE guisp=NONE gui=italic blend=NONE
highlight Question guifg=#61afef guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CurrentWord guifg=NONE guibg=#31435e guisp=NONE gui=bold blend=NONE
highlight Underlined guifg=NONE guibg=NONE guisp=NONE gui=underline blend=NONE
highlight TabLineSel guifg=#202326 guibg=#528bff guisp=NONE gui=bold blend=NONE
highlight TabLine guifg=#abb2bf guibg=#3e4452 guisp=NONE gui=NONE blend=NONE
highlight TermCursor guifg=#202326 guibg=#528bff guisp=NONE gui=NONE blend=NONE
highlight Delimiter guifg=NONE guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight IncSearch guifg=#d19a66 guibg=#202326 guisp=NONE gui=reverse blend=NONE
highlight Comment guifg=#5c6370 guibg=NONE guisp=NONE gui=italic blend=NONE
highlight! link Define Statement
highlight! link Include Function
highlight PreProc guifg=#e5c07b guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Label Identifier
highlight Statement guifg=#c678dd guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Float Number
highlight Normal guifg=#abb2bf guibg=#202326 guisp=NONE gui=NONE blend=NONE
highlight SignColumn guifg=NONE guibg=#202326 guisp=NONE gui=NONE blend=NONE
highlight Error guifg=#e06c75 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight CursorColumn guifg=NONE guibg=#282c34 guisp=NONE gui=NONE blend=NONE
highlight! link manTitle Special
highlight SpellLocal guifg=NONE guibg=NONE guisp=#e06c75 gui=undercurl blend=NONE
highlight Title guifg=#abb2bf guibg=NONE guisp=NONE gui=bold blend=NONE
highlight Visual guifg=NONE guibg=#3e4452 guisp=NONE gui=NONE blend=NONE
highlight! link Whitespace SpecialKey
highlight WildMenu guifg=#abb2bf guibg=#5c6370 guisp=NONE gui=NONE blend=NONE
highlight DiffAdd guifg=NONE guibg=#2a4333 guisp=NONE gui=NONE blend=NONE
highlight! link zshCommands Statement
highlight Special guifg=#56b6c2 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Macro Statement
highlight htmlH1 guifg=#56b6c2 guibg=NONE guisp=NONE gui=bold blend=NONE
highlight! link asciidocListingBlock NonText
highlight StatusLineError guifg=#be5046 guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight StatusLineCommand guifg=#30353f guibg=#56b6c2 guisp=NONE gui=bold blend=NONE
highlight MoreMsg guifg=#abb2bf guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight CursorLine guifg=NONE guibg=#282c34 guisp=NONE gui=NONE blend=NONE
highlight CursorLineNr guifg=#abb2bf guibg=#282c34 guisp=NONE gui=NONE blend=NONE
highlight LineNr guifg=#4b5263 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight FoldColumn guifg=#4b5263 guibg=#202326 guisp=NONE gui=NONE blend=NONE
highlight Folded guifg=#abb2bf guibg=#3e4452 guisp=NONE gui=NONE blend=NONE
highlight DiffText guifg=NONE guibg=#213352 guisp=NONE gui=NONE blend=NONE
highlight StatusLineVisual guifg=#30353f guibg=#c678dd guisp=NONE gui=bold blend=NONE
highlight DiffDelete guifg=NONE guibg=#442d30 guisp=NONE gui=NONE blend=NONE
highlight TabLineFill guifg=#5c6370 guibg=#202326 guisp=NONE gui=NONE blend=NONE
highlight DiffChange guifg=NONE guibg=#333841 guisp=NONE gui=NONE blend=NONE
highlight StatusLineInsert guifg=#30353f guibg=#61afef guisp=NONE gui=bold blend=NONE
highlight StatusLineNC guifg=#202326 guibg=#5c6370 guisp=NONE gui=NONE blend=NONE
highlight StatusLine guifg=#abb2bf guibg=#30353f guisp=NONE gui=NONE blend=NONE
highlight Directory guifg=#61afef guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight StatusLineNormal guifg=#30353f guibg=#98c379 guisp=NONE gui=bold blend=NONE
highlight Cursor guifg=#202326 guibg=#528bff guisp=NONE gui=NONE blend=NONE
highlight Conceal guifg=#4b5263 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight SpecialKey guifg=#3e4452 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Search guifg=#202326 guibg=#e5c07b guisp=NONE gui=NONE blend=NONE
highlight Reverse guifg=NONE guibg=NONE guisp=NONE gui=reverse blend=NONE
highlight QuickFixLine guifg=NONE guibg=#213352 guisp=NONE gui=bold blend=NONE
highlight MatchParen guifg=#8378e1 guibg=NONE guisp=NONE gui=bold,underline blend=NONE
highlight PmenuSbar guifg=NONE guibg=#202326 guisp=NONE gui=NONE blend=NONE
highlight PmenuSel guifg=#abb2bf guibg=#31435e guisp=NONE gui=NONE blend=NONE
highlight Pmenu guifg=#abb2bf guibg=#333841 guisp=NONE gui=NONE blend=NONE
highlight NonText guifg=#5c6370 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Type guifg=#e5c07b guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight Enum guifg=#219992 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link Boolean Number
highlight NameSpace guifg=#8378e1 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight ColorColumn guifg=NONE guibg=#282c34 guisp=NONE gui=NONE blend=NONE
highlight ErrorMsg guifg=#be5046 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight PmenuThumb guifg=NONE guibg=#5c6370 guisp=NONE gui=NONE blend=NONE
highlight ModeMsg guifg=#abb2bf guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight VertSplit guifg=#3e4452 guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link manFooter NonText
highlight Function guifg=#61afef guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link zshVariableDef Number
highlight! link zshSubstDelim NonText
highlight! link zshSubst Identifier
highlight! link zshFunction Function
highlight! link zshShortDeref Identifier
highlight! link zshDeref Identifier
highlight Operator guifg=#528bff guibg=NONE guisp=NONE gui=NONE blend=NONE
highlight! link xmlTagName Identifier
highlight! link xmlTag Identifier
