
fun! usr#core#commands#setup()
    " Remove ANSI escape sequences
    com! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g
    " Remove control characters
    com! -range=% -nargs=0 RmCtrl <line1>,<line2>s/[[:cntrl:]]//g
    " Convert camelCase to snake_case
    com! -range=% -nargs=0 Camel2Snake <line1>,<line2>s/\v\C(<\u[a-z0-9]+|[a-z0-9]+)(\u)/\l\1_\l\2/g
    " Convert SNAKE_CASE to camelCase
    com! -range=% -nargs=0 SnakeScreaming2Camel <line1>,<line2>s/\v_*(\u)(\u*)/\1\L\2/g
    " Convert snake_case to camelCase
    com! -range=% -nargs=0 Snake2Camel <line1>,<line2>s/\v([A-Za-z0-9]+)_([0-9a-z])/\1\U\2/gc
    " Convert snake_case to PascalCase
    com! -range=% -nargs=0 Snake2Pascal <line1>,<line2>s/\v(%(<\l+)%(_)\@=)|_(\l)/\u\1\2/g
    " Convert tags to UPPERCASE
    com! -range=% -nargs=0 Tags2Upper <line1>,<line2>s/<\/\=\(\w\+\)\>/\U&/g
    " Convert tags to lowercase
    com! -range=% -nargs=0 Tags2Lower <line1>,<line2>s/<\/\=\(\w\+\)\>/\L&/g
    " Reverse selected lines
    com! -range=% -nargs=0 -bar Reverse <line1>,<line2>g/^/m<line1>-1<Bar>nohl
    " Convert tabs to spaces
    com! -range=% -nargs=0 Tab2Space
                \ execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')'
    " Convert spaces to tabs
    com! -range=% -nargs=0 Space2Tab
                \ execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')'
    " Write selection to another file
    com! -range=% -nargs=1 -bang -complete=file MoveWrite
                \ <line1>,<line2>write<bang> <args> | <line1>,<line2>delete _
    " Append selection to another file
    com! -range=% -nargs=1 -bang -complete=file MoveAppend
                \ <line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _
    com! -nargs=? -complete=buffer FollowSymlink call usr#utils#follow_symlink(<f-args>)
    com! -nargs=0 CleanEmptyBuf call usr#utils#clean_empty_buf()
    com! -nargs=0 DiffSaved call usr#fn#DiffSaved()
    com! -nargs=0 Jumps call usr#builtin#jumps2qf()
    com! -nargs=0 Jumps2 call usr#builtin#jumps2qf1()

    com! SQ call usr#fn#syntax_query()
endfunction
