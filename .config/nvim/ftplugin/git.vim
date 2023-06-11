if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

setl foldcolumn=2
setl signcolumn=no
setl foldmethod=syntax
setl foldtext=fugitive#Foldtext()
setl nolist
setl cc=
setl nonu nornu

" setl foldmethod=expr
" setl foldexpr=DiffFold()

function! DiffFold()
    let line = getline(v:lnum)
    if line =~# '^\(diff\|index\)' " file
        return '>1'
    elseif line =~# '^--- .*$'
        return '>1'
    elseif line =~# '^==== .*$'
        return '>1'
    elseif line =~# '^@@' " hunk
        return '>2'
    elseif line =~# '^\*\*\* \d\+,\d\+ \*\*\*\*$' " context: file1
        return '>2'
    elseif line =~# '^--- \d\+,\d\+ ----$' " context: file2
        return '>2'
    else
        return '='
    endif
endfunction

if !exists('b:git_dir')
    if expand('%:p') =~# '\.git\>'
        let b:git_dir = matchstr(expand('%:p'),'.*\.git\>')
    elseif $GIT_DIR != ''
        let b:git_dir = $GIT_DIR
    endif
    if (has('win32') || has('win64')) && exists('b:git_dir')
        let b:git_dir = substitute(b:git_dir,'\\','/','g')
    endif
endif

if exists('*shellescape') && exists('b:git_dir') && b:git_dir != ''
    if b:git_dir =~# '/\.git$' " Not a bare repository
        let &l:path = escape(fnamemodify(b:git_dir,':h'),'\, ').','.&l:path
    endif
    let &l:path = escape(b:git_dir,'\, ').','.&l:path
    let &l:keywordprg = 'git --git-dir='.shellescape(b:git_dir).' show'
else
    setlocal keywordprg=git\ show
endif
if has('gui_running')
    let &l:keywordprg = substitute(&l:keywordprg,'^git\>','git --no-pager','')
endif

setlocal includeexpr=substitute(v:fname,'^[^/]\\+/','','')
let b:undo_ftplugin = "setl keywordprg< path< includeexpr<"
