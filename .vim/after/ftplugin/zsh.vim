
let b:coc_additional_keywords = ["-"]

setlocal keywordprg=:RunHelp
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal formatoptions+=tcroql

setlocal autoindent
setlocal smartindent
setlocal cindent
setlocal preserveindent          " preserve most indent structure as possible when reindenting line
setlocal breakindent             " each wrapped line will continue same indent level
setlocal breakindentopt=sbr      " display 'showbreak' value before applying indent
setlocal breakindentopt+=list:2  " add additional indent for lines matching 'formatlistpat'
setlocal breakindentopt+=min:20  " min width kept after breaking line
setlocal breakindentopt+=shift:2 " all lines after break are shifted N
setlocal linebreak               " lines wrap at words rather than random characters
" setlocal breakat=\t !@*-+;:,./? " which chars cause break with 'linebreak'

setlocal cinoptions=>1s  " any: amount added for "normal" indent
setlocal cinoptions+=L0  " placement of jump labels
setlocal cinoptions+==1s " ? case: statement after case label: N chars from indent of label
setlocal cinoptions+=l1  " N!=0 case: align w/ case label instead of statement after it on same line
setlocal cinoptions+=b1  " N!=0 case: align final "break" w/ case label so it looks like block (0=break cinkeys)
setlocal cinoptions+=g1s " ? C++ scope decls: N chars from indent of block they're in
setlocal cinoptions+=h1s " ? C++: after scope decl: N chars from indent of label
setlocal cinoptions+=N0  " ? C++: inside namespace: N chars extra
setlocal cinoptions+=E0  " ? C++: inside linkage specifications: N chars extra
setlocal cinoptions+=p1s " ? K&R: function decl: N chars from margin
setlocal cinoptions+=t0  " K&R: return type of function decl: N chars from margin
setlocal cinoptions+=i1s " ? C++: base class decl/constructor init if they start on newline
setlocal cinoptions+=+0  " line continuation: N chars extra inside function; 2*N outside func if line end = '\'
setlocal cinoptions+=c1s " comment lines: N chars from comment opener if no other text to align with
setlocal cinoptions+=(1s " inside unclosed paren: N chars from line ('sw' for every unclosed paren)
setlocal cinoptions+=u1s " same as (N but one level deeper
setlocal cinoptions+=U1  " N!=0 : do not ignore nested parens that are on line by themselves
setlocal cinoptions+=k1s " unclosed paren in 'if' 'for' 'while' override '(N'
setlocal cinoptions+=m1  " N!=0 line up line starting w/ closing paren w/ 1st char of line w/ opening
setlocal cinoptions+=j1  " java: anon classes
setlocal cinoptions+=J1  " javascript: object classes
setlocal cinoptions+=)40 " search for parens N lines away
setlocal cinoptions+=*70 " search for unclosed comments N lines away
setlocal cinoptions+=#0  " N!=0 recognized '#' comments otherwise preproc (toggle this for files)
setlocal cinoptions+=P1  " N!=0 format C pragmas

" -- keys in insert mode that cause reindenting of current line 'cinkeys-format'
" setlocal cinkey=0{,0},0],:,!^F,o,O,e
setlocal cinkeys-=0),0#,0}

" Join lines & remove backslash
nmap <buffer><silent> J gW

" Prev parenthesis
nnoremap <buffer><silent> [a [(
" Next parenthesis
nnoremap <buffer><silent> ]a ])
" Prev curly brace
nnoremap <buffer><silent> [b [{
" Next curly brace
nnoremap <buffer><silent> ]b ]}

" Prev parenthesis
nnoremap <buffer><silent> ( [(
" Next parenthesis
nnoremap <buffer><silent> ) ])
" Prev curly brace
nnoremap <buffer><silent> [[ [{
" Next curly brace
nnoremap <buffer><silent> ]] ]}

" Prev start of method
nnoremap <buffer><silent> { [m
" Next start of method
nnoremap <buffer><silent> } ]m
" Prev start of method
nnoremap <buffer><silent> [f [m
" Next start of method
nnoremap <buffer><silent> ]f ]m
" Prev end of method
nnoremap <buffer><silent> [F [M
" Next end of method
nnoremap <buffer><silent> ]F ]M

" Prev line with keyword
nnoremap <buffer><silent> [d [<C-i> P
" Next line with keyword
nnoremap <buffer><silent> ]d ]<C-i> N
" Disp prev line w/ keyword
nnoremap <buffer><silent> [r [i
" Disp next line w/ keyword
nnoremap <buffer><silent> ]r ]i
" Tag: previous
nnoremap <buffer><silent> [x <Cmd>tp<CR>
" Tag: next
nnoremap <buffer><silent> ]x <Cmd>tn<CR>

" Tag: fill stack
nnoremap <buffer><silent> gD :tag <C-r><C-w><CR>

let b:match_words =
    \ "\<if\>\ze\s.\{-}\%())\|]]\)\s\={:\<elif\>\ze\s.\{-}\%())\|]]\)\s\={:\<else\>\ze\s\={" ..
    \ ",\<if\>:\<\%(then\|else\|elif\)\>:\<fi\>" ..
    \ ",\<if\>:\<fi\>" ..
    \ ",\<function\>:\<return\>" ..
    \ ",\<case\>:^\s*([^)]*):\<esac\>" ..
    \ ",\<\%(select\|while\|until\|repeat\|for\%(each\)\=\)\>:\<\%(continue\|break\)\>:\<done\>"

let b:match_skip = "s:comment\|string\|heredoc\|subst\(delim\)\@!"
let b:match_ignorecase = 0

let b:undo_ftplugin = "unlet! b:match_ignorecase b:match_words b:match_skip"
