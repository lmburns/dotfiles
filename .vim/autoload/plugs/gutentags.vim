func! plugs#gutentags#setup() abort
  set tags=tags,./tags,./.tags,.tags

  let g:gutentags_enabled = 1
  let g:gutentags_define_advanced_commands = 1
  let g:gutentags_cache_dir = g:lbdirs.cache.'/tags'

  let g:gutentags_generate_on_write = 1
  let g:gutentags_generate_on_new = 1
  let g:gutentags_generate_on_missing = 1
  let g:gutentags_generate_on_empty_buffer = 0
  let g:gutentags_resolve_symlinks = 1

  let g:gutentags_file_list_command = {
        \ 'markers': {
        \   '.git': 'git ls-files',
        \   '.root': 'fd --color=never --strip-cwd-prefix --type f --hidden --follow --exclude=.git --exclude=.github',
        \ }}

  let g:gutentags_modules = ['ctags']
  let g:gutentags_project_root = ['.git', '.root', '.project', 'package.json', 'Cargo.toml', 'go.mod']
  let g:gutentags_exclude_project_root = ['/opt', '/mnt', '/media', '/usr/local', '/etc']
  let g:gutentags_exclude_filetypes = ['text', 'conf', 'markdown', 'vimwiki', 'git', 'gitconfig', 'fugitive']

  let g:gutentags_ctags_tagfile = 'tags'
  let g:gutentags_ctags_auto_set_tags = 1
  let g:gutentags_ctags_extra_args = [
        \ '--fields=+niazS',
        \ '--extras=+q',
        \ '--c++-kinds=+px',
        \ '--c-kinds=+px',
        \ '--rust-kinds=+fPM',
        \ '--guess-language-eagerly'
        \ ]
  let g:gutentags_gtags_dbpath = g:gutentags_cache_dir

  " let g:gutentags_plus_nomap = 1
  let g:gutentags_auto_add_gtags_cscope = 0
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

  augroup lmb__Gutentags
    autocmd!
    autocmd! User vim-gutentags call gutentags#setup_gutentags()
    " autocmd! FileType c call <SID>SetupCTags()
    " autocmd! FileType cpp call <SID>SetupCPPTags()
    " autocmd! FileType perl call <SID>SetupPerlTags()
    autocmd! FileType ruby call <SID>SetupRubyTags()
  augroup END
  " endif
endfu

function! s:SetupCTags()
  let g:gutentags_ctags_extra_args += ['/usr/include', '/usr/local/include']
endfunction

function! s:SetupCPPTags()
  let g:gutentags_ctags_extra_args += ['/home/lucas/.config/nvim/cpp_src']
endfunction

function! s:SetupRubyTags()
  " let g:gutentags_ctags_extra_args += map(split($GEM_PATH, ':'), 'v:val."/gems/*/tags"')
  let g:gutentags_ctags_extra_args += ['/home/lucas/.local/share/rbenv/versions/3.1.0/lib/ruby/3.1.0']
endfunction

function! s:SetupPerlTags()
  let g:gutentags_ctags_extra_args += ['/home/lucas/.local/share/perl5/perlbrew/build/perl-5.35.4/perl-5.35.4']
endfunction
