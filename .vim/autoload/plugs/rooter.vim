fun! plugs#rooter#setup() abort
    let g:rooter_buftypes = ['']
    let g:rooter_patterns = [
                \ '.git',
                \ '.hg',
                \ '.svn',
                \ '*.sln',
                \ '*.xcodeproj',
                \ 'Makefile',
                \ 'CMakeLists.txt',
                \ 'requirements.txt',
                \ 'Cargo.toml',
                \ 'go.mod',
                \ ]
    let g:rooter_silent_chdir = 1
    let g:rooter_manual_only = 1
endfun
