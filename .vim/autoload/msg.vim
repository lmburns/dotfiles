" Echo something to messages
" @param kind {'echomsg'|'echoerr'|'echo'} kind of echo
" @param hl {string} highlight group
" @param msg {string} message to echo
function! msg#echo_kind(kind, hl, msg) abort
    execute 'echohl' a:hl
    " echomsg join(a:000, "\n")
    try
        if a:kind ==# 'echo'
            echo a:msg
        endif

        for l:m in split(a:msg, "\n")
            execute a:kind string(l:m)
        endfor
    finally
        echohl None
    endtry
endfunction

" Echo something
" @param hl {string} highlight group
" @param msg {string} message to echo
function! msg#echo(hl, msg) abort
    execute 'echohl ' a:hl
    try
        echo a:msg
    finally
        echohl None
    endtry
endfunction

" Echo something to messages
" @param hl {string} highlight group
" @param msg {string} message to echo
function! msg#echomsg(hl, msg) abort
    " execute 'echohl ' a:hl
    " " echomsg join(a:000, "\n")
    " try
    "     for l:m in split(a:msg, "\n")
    "         echomsg l:m
    "     endfor
    " finally
    "     echohl None
    " endtry

    call msg#echo_kind('echomsg', a:hl, a:msg)
endfunction

" Display an error message (not echoerr)
" @param msg {string} error message to echo
function! msg#errmsg(msg) abort
    call msg#echomsg('ErrorMsg', '[ERROR]: '..a:msg)
endfunction

" Display a warning message
" @param msg {string}
function! msg#warnmsg(msg) abort
    call msg#echomsg('WarningMsg', '[WARN]:'..a:msg)
endfunction

" Display an error message (not echoerr)
" @param msg {string} error message to echo
function! msg#error(msg) abort
    call msg#echomsg('ErrorMsg', a:msg)
endfunction

function! msg#capture(command) abort
    try
        redir => out
        silent execute a:command
    finally
        redir END
    endtry
    return out
endfunction

":ec[ho] {expr1} ..
"     Echoes each {expr1}, with a space in between.
"     Use "\n" to start a new line.
"     No comment after, uses echohl.
"       :echo "the value of 'shell' is" &shell
":echon {expr1} ..
"     Echoes each {expr1}, without anything added.
"     No comment after, uses echohl.
"       :echon "the value of 'shell' is " &shell
":echoh[l] {name}
"     Use the highlight group {name} for `:echo`, `:echon`, `:echomsg` commands.
":echom[sg] {expr1} ..
"     Echo the expression(s) as a true message, saving to history.
"     Unprintable characters are displayed, not interpreted.
"     Parsing works slightly different from `:echo`, more like `:execute`.
":[N]echow[indow] {expr1} ..
"     Like :echomsg but when the messages popup window is available the message is displayed there.
"     It will show for three seconds and avoid a |hit-enter| prompt.
":echoe[rr] {expr1} ..
"     Echo the expression(s) as an error message, saving history.
"     When used in a script or function the line number will be added.
":echoc[onsole] {expr1} ..
"     Intended for testing: works like `:echomsg` but when
"     running in the GUI and started from a terminal write
"     the text to stdout.
" try
"   try
"     asdf
"   catch /.*/
"     echoerr v:exception
"   endtry
" catch /.*/
"   echo v:exception
" endtry
