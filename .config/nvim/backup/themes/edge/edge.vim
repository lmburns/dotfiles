if !exists('g:colors_name') || g:colors_name !=# 'edge'
    finish
endif
if index(g:edge_loaded_file_types, 'zsh') ==# -1
    call add(g:edge_loaded_file_types, 'zsh')
else
    finish
endif
" ft_begin: sh/zsh {{{
" builtin: http://www.drchip.org/astronaut/vim/index.html#SYNTAX_SH{{{
highlight! link shRange Fg
highlight! link shTestOpr Orange
highlight! link shOption Yellow
highlight! link bashStatement Orange
highlight! link shOperator Orange
highlight! link shQuote Green
highlight! link shSet Orange
highlight! link shSetList Blue
highlight! link shSnglCase Orange
highlight! link shVariable RedItalic
highlight! link shVarAssign Purple
highlight! link shCmdSubRegion Green
highlight! link shCommandSub Orange
highlight! link shFunctionOne Blue
highlight! link shFunctionKey Purple

highlight! link shDerefSimple RedItalic
highlight! link shDerefVar RedItalic
highlight! link shDerefSpecial RedItalic
highlight! link shDerefOff RedItalic
" }}}
" ft_end
" ft_begin: zsh {{{
" builtin: https://github.com/chrisbra/vim-zsh{{{
highlight! link zshOptStart PurpleItalic
highlight! link zshOption RedItalic
highlight! link zshSubst Cyan
highlight! link zshFunction Blue
highlight! link zshDeref Red
highlight! link zshTypes Orange
highlight! link zshVariableDef Blue
highlight! link zshNumber Purple
highlight! link zshSubstDelim Purple
highlight! link zshDelim Purple

highlight! link rOperator Orange
highlight! link rOTag Blue
" }}}
" ft_end
