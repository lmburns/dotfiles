" FindOccurrence.vim: Extended mappings for :isearch, :ilist and :ijump.
"
" DEPENDENCIES:
"   - ingo/compat.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/query/get.vim autoload script
"   - ingo/regexp.vim autoload script
"
" Copyright: (C) 2008-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:   Ingo Karkat <ingo@karkat.de>
" Source: http://vim.wikia.com/wiki/Search_visually
"
" REVISION      DATE            REMARKS
"   1.01.018    26-Apr-2014     ENH: Add mode "N" that searches for the word
"                               (not the \<word\>) under the cursor, like * and
"                               g*.
"   1.00.017    10-Apr-2014     I18N: Visual reselection is off for multi-byte
"                               characters due to mismatch of byte length and
"                               character count. Use strchars() instead. No need
"                               to consider newlines, :ilist doesn't support
"                               them, anyway.
"       016     20-Jun-2013     FIX: Cannot actually re-use s:EchoError(),
"                               rename s:EchoError() to s:VimExceptionMsg() to
"                               clarify.
"       015     14-Jun-2013     Use ingo/msg.vim, and re-use s:EchoError()
"                               internally.
"       014     31-May-2013     Move ingouserquery#Get...() functions into
"                               ingo-library.
"       013     24-May-2013     Move ingosearch.vim to ingo-library.
"       012     26-Oct-2012     BUG: Undefined a:range in s:DoSplit().
"       011     23-Aug-2012     Use ingouserquery#GetNumber() instead of
"                               input(); this way the query doesn't have to be
"                               concluded with <Enter>, saving one keystroke.
"       010     23-Aug-2012     Split off autoload script and documentation.
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

function! s:VimExceptionMsg()
    " After input(), the next :echo may be off-base. (Is this a Vim bug?)
    " A redraw fixes this.
    redraw

    call ingo#msg#VimExceptionMsg()
endfunction
function! s:DoSearch( isSilent )
    try
        execute s:range . 'isearch' . s:skipComment s:count s:pattern
    catch /^Vim\%((\a\+)\)\=:E389/ " Couldn't find pattern
        if ! a:isSilent
            call s:VimExceptionMsg()
        endif
        return 0
    catch /^Vim\%((\a\+)\)\=:E38[78]/
        call s:VimExceptionMsg()
    endtry
    return 1
endfunction
function! s:DoSplit()
    try
        " Check that the destination exists before splitting the window.
        silent execute s:range . 'isearch' . s:skipComment s:count s:pattern
        split
        execute s:range . 'ijump' . s:skipComment s:count s:pattern
    catch /^Vim\%((\a\+)\)\=:E38[789]/
        call s:VimExceptionMsg()
    endtry
endfunction
function! s:DoList()
    try
        redir => ilistOutput
        execute s:range . 'ilist' . s:skipComment s:pattern
        redir END
    catch /^Vim\%((\a\+)\)\=:E38[789]/
        redir END
        call s:VimExceptionMsg()
        return 0
    endtry

    echo 'Go to: '
    let l:maxCount = len(split(ilistOutput, "\n")) - 1    " Subtract 1 for the header showing the buffer name.
    let s:count = ingo#query#get#Number(l:maxCount)
    if s:count == -1
        " User canceled, there's no error message to show, so don't delay
        " visual reselection.
        let s:reselectionDelay = 0
        return 0
    endif
    redraw      " Somehow need this to avoid the hit-enter prompt.

    return s:DoJump(0)
endfunction
function! s:DoJump( isSilent )
    try
        execute s:range . 'ijump' . s:skipComment s:count s:pattern
        let s:didJump = 1

        " For some unknown reason, the original :ijump command and [ CTRL-I
        " mappings do not open the fold at the match. I prefer to have the fold
        " opened.
        normal! zv

        return 1
    catch /^Vim\%((\a\+)\)\=:E389/ " Couldn't find pattern
        if a:isSilent
            return 0
        else
            call s:VimExceptionMsg()
        endif
    catch /^Vim\%((\a\+)\)\=:E38[78]/
        call s:VimExceptionMsg()
    endtry
    return 1
endfunction

function! FindOccurrence#Find( mode, operation, isEntireBuffer )
    let s:count = v:count1
    let s:skipComment = (v:count ? '!' : '')
    let s:range = (a:isEntireBuffer ? '' : '.+1,$')
    let s:didJump = 0
    let s:reselectionDelay = 1
    let l:selectionLength = 0

    if a:mode ==# 'n' " Normal mode, use \<word\> under cursor.
        let s:pattern = '/' . ingo#regexp#FromLiteralText(expand('<cword>'), 1, '') . '/'
    elseif a:mode ==# 'N' " Normal mode, use word under cursor.
        let s:pattern = '/' . ingo#regexp#FromLiteralText(expand('<cword>'), 0, '') . '/'
    elseif a:mode ==# 'v' " Visual mode, use selection.
        execute 'normal! gvy'
        let s:pattern = '/\V' . substitute(escape(@@, '/\'), "\n", '\\n', 'g') . '/'
        let l:selectionLength = (&selection ==# 'exclusive' && getpos("'<") == getpos("'>") ? 0 : ingo#compat#strchars(@@) - (&selection ==# 'exclusive' ? 0 : 1))
    elseif a:mode ==# '/' " Use current search result.
        let s:pattern = '/' . @/ . '/'
    elseif a:mode ==# '?' " Query for pattern.
        let l:pattern = input('/')
        if empty(l:pattern) | return | endif
        let s:lastPattern = l:pattern
        let s:pattern = '/' . l:pattern . '/'
    elseif a:mode ==# '?R' " Reuse last queried pattern.
        if ! exists('s:lastPattern')
            call ingo#msg#ErrorMsg('No previous pattern, use [/ first')
            return
        endif
        let s:pattern = '/' . s:lastPattern . '/'
    else
        throw 'invalid mode "' . a:mode . '"'
    endif

    if a:operation ==# 'search'
        call s:DoSearch(0)
    elseif a:operation ==# 'search-list'
        if ! s:DoSearch(1)
            call s:DoList()
        endif
    elseif a:operation ==# 'split'
        call s:DoSplit()
    elseif a:operation ==# 'list'
        call s:DoList()
    elseif a:operation ==# 'jump-list'
        if ! s:DoJump(1)
            call s:DoList()
        endif
    elseif a:operation ==# 'jump'
        call s:DoJump(0)
    else
        throw 'invalid operation "' . a:operation . '"'
    endif

    if a:mode ==# 'v'
        if s:didJump
            " We've jumped to a keyword, now select the keyword at the *new* position.
            " Special case for single character visual [<Tab> (l:selectionLength == 0)
            execute 'normal!' visualmode() . (l:selectionLength ? l:selectionLength . "\<Space>" : '')
        else
            " We didn't jump, reselect the current keyword so that any operation
            " can be repeated easily.

            " If there was an error message, or an :iselect command, we must be
            " careful not to immediately overwrite the desired output by
            " re-entering visual mode.
            if &cmdheight == 1
                if s:reselectionDelay
                    redraw
                    execute 'sleep' s:reselectionDelay
                endif
            endif
            normal! gv
        endif
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
