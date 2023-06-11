" FindOccurrence.vim: Extended mappings for :isearch, :ilist and :ijump.
"
" DEPENDENCIES:
"   - FindOccurrence.vim autoload script
"
" Copyright: (C) 2008-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:   Ingo Karkat <ingo@karkat.de>
" Source: http://vim.wikia.com/wiki/Search_visually
"
" REVISION      DATE            REMARKS
"   1.01.011    26-Apr-2014     ENH: Add g[I and g[<Tab> mappings that search
"                               for the word (not the \<word\>) under the
"                               cursor, like * and g*.
"   1.00.010    23-Aug-2012     Split off autoload script and documentation.
"       009     15-Jul-2010     BUG: Accidentally removed queried pattern from
"                               the input history if the user cancels out of
"                               selection.
"                               ENH: Added [? ]? CTRL-W_? mappings that
"                               reuse last queried pattern.
"                               Now opening folds at the jump destination, even
"                               though the original :ijump command and [ CTRL-I
"                               mappings do not open the fold at the match.
"       008     05-Jan-2010     BUG: Didn't escape <cword> and didn't check
"                               whether it actually must be enclosed in \<...\>.
"                               Now using
"                               ingosearch#LiteralTextToSearchPattern() for
"                               that.
"       007     06-Oct-2009     Do not define mappings for select mode;
"                               printable characters should start insert mode.
"       006     21-Mar-2009     Simplified handling of v:count.
"       005     16-Jan-2009     Now setting v:errmsg on errors.
"       004     07-Aug-2008     Complete refactoring; split operations into
"                               separate functions.
"                               Two new operations: jump-list and search-list,
"                               which fall back on listing if the first op
"                               didn't find anything.
"                               Added {visual}]i.
"       003     06-Aug-2008     Adopted script; reformatted and refactored
"                               argument handling.
"                               Implemented ]n ]N ]<C-N> mappings for current
"                               search result.
"                               Implemented ]/ mapping for queried pattern.
"       002     08-Jul-2008     Added ] mappings that search only from cursor
"                               position.
"       001     08-Jul-2008     file creation from Wiki page

" Avoid installing twice.
if exists('g:loaded_FindOccurrence') || (v:version < 700)
    finish
endif
let g:loaded_FindOccurrence = 1

nnoremap <silent>  [I        :<C-u>call FindOccurrence#Find('n', 'list', 1)<CR>
nnoremap <silent>  ]I        :<C-u>call FindOccurrence#Find('n', 'list', 0)<CR>
nnoremap <silent> g]I        :<C-u>call FindOccurrence#Find('N', 'list', 0)<CR>
nnoremap <silent> g[I        :<C-u>call FindOccurrence#Find('N', 'list', 1)<CR>
nnoremap <silent>  [<Tab>    :<C-u>call FindOccurrence#Find('n', 'jump', 1)<CR>
nnoremap <silent>  ]<Tab>    :<C-u>call FindOccurrence#Find('n', 'jump', 0)<CR>
nnoremap <silent> g[<Tab>    :<C-u>call FindOccurrence#Find('N', 'jump', 1)<CR>
nnoremap <silent> g]<Tab>    :<C-u>call FindOccurrence#Find('N', 'jump', 0)<CR>
xnoremap <silent>  [i        :<C-u>call FindOccurrence#Find('v', 'search', 1)<CR>
xnoremap <silent>  ]i        :<C-u>call FindOccurrence#Find('v', 'search', 0)<CR>
xnoremap <silent>  [I        :<C-u>call FindOccurrence#Find('v', 'list', 1)<CR>
xnoremap <silent>  ]I        :<C-u>call FindOccurrence#Find('v', 'list', 0)<CR>
xnoremap <silent>  [<Tab>    :<C-u>call FindOccurrence#Find('v', 'jump', 1)<CR>
xnoremap <silent>  ]<Tab>    :<C-u>call FindOccurrence#Find('v', 'jump', 0)<CR>


nnoremap <silent> [n         :<C-u>call FindOccurrence#Find('/', 'search', 1)<CR>
nnoremap <silent> ]n         :<C-u>call FindOccurrence#Find('/', 'search', 0)<CR>
" Disabled because they would overwrite default commands.
"nnoremap <silent> <C-W>n     :<C-u>call FindOccurrence#Find('/', 'split', 1)<CR>
"nnoremap <silent> <C-W><C-N> :<C-u>call FindOccurrence#Find('/', 'split', 1)<CR>
" nnoremap <silent> [N         :<C-u>call FindOccurrence#Find('/', 'list', 1)<CR>
" nnoremap <silent> ]N         :<C-u>call FindOccurrence#Find('/', 'list', 0)<CR>
nnoremap <silent> [<C-N>     :<C-u>call FindOccurrence#Find('/', 'jump', 1)<CR>
nnoremap <silent> ]<C-N>     :<C-u>call FindOccurrence#Find('/', 'jump', 0)<CR>


nnoremap <silent> <C-W>/     :<C-u>call FindOccurrence#Find('?', 'split', 1)<CR>
nnoremap <silent> [/         :<C-u>call FindOccurrence#Find('?', (v:count ? 'jump-list' : 'list'), 1)<CR>
nnoremap <silent> ]/         :<C-u>call FindOccurrence#Find('?', (v:count ? 'jump-list' : 'list'), 0)<CR>

nnoremap <silent> <C-W>?     :<C-u>call FindOccurrence#Find('?R', 'split', 1)<CR>
nnoremap <silent> [?         :<C-u>call FindOccurrence#Find('?R', (v:count ? 'jump-list' : 'list'), 1)<CR>
nnoremap <silent> ]?         :<C-u>call FindOccurrence#Find('?R', (v:count ? 'jump-list' : 'list'), 0)<CR>

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
