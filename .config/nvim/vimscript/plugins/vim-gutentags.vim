" autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi
" autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!

" set tags=./.tags;,.tags
" let $GTAGSLABEL = 'native-pygments'
" let $GTAGSCONF = '~/.gtags.conf'

" if &ft=="rust"
"   set tags=rusty-tags.vi,$RUST_SRC_PATH/rusty-tags.vi
"   let g:gutentags_modules = ['rusty-tags']
"   let g:gutentags_ctags_extra_args = ['vi', '--quiet', "--start-dir=" . expand("%:p:h")]
"   let g:gutentags_ctags_tagfile = '.rusty-tags'
" else
set tags=tags,./.tags,.tags
let g:gutentags_modules = ['ctags']
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_tagfile = '.tags'
let g:gutentags_project_root = ['.git']
let g:gutentags_cache_dir = expand('~/.cache/tags')

" let g:gutentags_gtags_dbpath = g:gutentags_cache_dir
" let g:gutentags_generate_on_new = 1
" let g:gutentags_generate_on_missing = 1
" let g:gutentags_generate_on_write = 1
" let g:gutentags_generate_on_empty_buffer = 0
" let g:gutentags_file_list_command = 'rg --files'

" Disable connecting gtags database automatically (gutentags_plus will handle the database connection)
" let g:gutentags_auto_add_gtags_cscope = 0

" Disable default maps
" let g:gutentags_plus_nomap = 1

" let g:gutentags_define_advanced_commands = 1
let g:gutentags_ctags_exclude = [
    \  '*.git', '*.svn', '*.hg',
    \  'cache', 'build', 'dist', 'bin', 'node_modules', 'bower_components', 'target',
    \  '*-lock.json',  '*.lock',
    \  '*.min.*',
    \  '*.bak',
    \  '*.zip',
    \  '*.pyc',
    \  '*.class',
    \  '*.sln',
    \  '*.csproj', '*.csproj.user',
    \  '*.tmp',
    \  '*.cache',
    \  '*.vscode',
    \  '*.pdb',
    \  '*.exe', '*.dll', '*.bin',
    \  '*.mp3', '*.ogg', '*.flac',
    \  '*.swp', '*.swo',
    \  '.DS_Store', '*.plist',
    \  '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png', '*.svg',
    \  '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
    \  '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx', '*.xls',
    \]

if executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope'] "'cscopeprg' will be set to gtags-cscope
endif

function! s:SetupCTags()
    let g:gutentags_ctags_extra_args += ['/usr/include', '/usr/local/include']
endfunction

function! s:SetupCPPTags()
    " set tags+=~/.config/tags/cpp_src
    let g:gutentags_ctags_extra_args += ['/home/lucas/.config/tags/cpp_src']
endfunction

function! s:SetupRubyTags()
    " let g:gutentags_ctags_extra_args += map(split($GEM_PATH, ':'), 'v:val."/gems/*/tags"')
    let g:gutentags_ctags_extra_args += ['/home/lucas/.local/share/rbenv/versions/3.1.0/lib/ruby/3.1.0']
endfunction

function! s:SetupPerlTags()
    let g:gutentags_ctags_extra_args += ['/home/lucas/.local/share/perl5/perlbrew/build/perl-5.35.4/perl-5.35.4']
endfunction

function! s:SetupLuaTags()
    let g:gutentags_ctags_extra_args += [$VIMRUNTIME . "/lua"]
endfunction

augroup gutentags
    autocmd!
    autocmd! User vim-gutentags call gutentags#setup_gutentags()
    autocmd! FileType cpp call <SID>SetupCPPTags()
    autocmd! FileType ruby call <SID>SetupRubyTags()
    autocmd! FileType perl call <SID>SetupPerlTags()
    autocmd! FileType lua call <SID>SetupLuaTags()
augroup END
