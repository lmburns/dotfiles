if !exists('g:colors_name') || g:colors_name !=# 'sonokai'
    finish
endif
if index(g:sonokai_loaded_file_types, 'zsh') ==# -1
    call add(g:sonokai_loaded_file_types, 'zsh')
else
    finish
endif
" ft_begin: sh/zsh {{{
" builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_SH{{{
highlight! link shRange Fg
highlight! link shTestOpr Orange
highlight! link shOption Purple
highlight! link bashStatement Orange
highlight! link shOperator Orange
highlight! link shQuote Yellow
highlight! link shSet Orange
highlight! link shSetList Blue
highlight! link shSnglCase Orange
highlight! link shVariable BlueItalic
highlight! link shVarAssign Red
highlight! link shCmdSubRegion Green
highlight! link shCommandSub Orange
highlight! link shFunctionOne GreenBold
highlight! link shFunctionKey Red
highlight! link shDerefSimple BlueItalic
highlight! link shDerefVar BlueItalic
highlight! link shDerefSpecial BlueItalic
highlight! link shDerefOff BlueItalic

" }}}
" ft_end
" ft_begin: zsh {{{
" builtin: https://github.com/chrisbra/vim-zsh{{{
highlight! link zshOptStart PurpleItalic
highlight! link zshOption BlueItalic
highlight! link zshSubst Orange
highlight! link zshFunction GreenBold
highlight! link zshDeref Blue
highlight! link zshTypes Orange
highlight! link zshVariableDef Blue
highlight! link zshNumber Purple
highlight! link zshSubstDelim Green
highlight! link zshDelim Green

highlight! link rOperator Orange
highlight! link rOTag Blue
" }}}
" ft_end
