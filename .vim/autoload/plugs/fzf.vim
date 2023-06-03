function s:resize_fzf_preview() abort
    try
        let layout = g:fzf_layout.window
        if &columns * layout.width - 2 > 100
            let g:fzf_preview_window = ['right:50%']
        else
            if &lines * layout.height - 2 > 25
                let g:fzf_preview_window = ['down:50%']
            else
                let g:fzf_preview_window = []
            endif
        endif
    catch /^Vim\%((\a\+)\)\=:E/
    endtry
endfunction

function! s:RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading '
                \ . '--color=always --smart-case -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options':
                \ ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1,
                \ fzf#vim#with_preview(spec, 'right:60%:default'), a:fullscreen)
endfunction

function! s:RipgrepTodo()
    let fixmestr =
                \ '(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|HACK|BUG|BUGS):'
    call fzf#vim#grep(
                \ 'rg --column --no-heading --line-number --color=always '.shellescape(fixmestr),
                \ 1,
                \ {'options':  '--delimiter : --nth 4..'}, 0)
endfunction

function! s:plug_help_sink(line)
    let dir = g:plugs[a:line].dir
    for pat in ['doc/*.txt', 'README.md']
        let match = get(split(globpath(dir, pat), "\n"), 0, '')
        if len(match)
            execute 'tabedit' match
            return
        endif
    endfor
    tabnew
    execute 'Explore' dir
endfunction

fun! plugs#fzf#mappings()
    nmap <silent> <Leader>;  :BLines<CR>
    nmap <silent> q: :History:<CR>
    nmap <silent> q/ :History/<CR>
    nmap <silent> <Leader>cs :Colors<CR>
    nmap <silent> <LocalLeader>A  :Files<CR>
    nmap <silent> <LocalLeader>a :Ls<CR>
    nmap <silent> <LocalLeader>r :GFiles<CR>
    nmap <silent> <Leader>e' :Conf<CR>
    nmap <silent> <Leader>e. :Dots<CR>
    nmap <silent> <Leader>e;  :VimFiles<CR>
    nmap <silent> <M-,> :History<CR>
    nmap <silent> <Leader>cm :Commands<CR>
    nmap <silent> <Leader>aa :Helptags<CR>
    nmap <silent> <Leader>ap :Apropos<CR>
    nmap <silent> <LocalLeader>i  :Windows<CR>
    nmap <silent> <LocalLeader>b  :Buffers<CR>

    nmap <silent> <LocalLeader>e :RG<CR>
    nmap <silent> <LocalLeader>E :Rg<CR>
    nmap <silent> <LocalLeader>L :Locate .<CR>
    nmap <silent> <Leader>si :Snippets<CR>
    nmap <silent> <M-/> :Marks<CR>
    nmap <silent> <C-,>k :Maps<CR>

    nmap <C-l>m <plug>(fzf-maps-n)
    xmap <C-l>m <plug>(fzf-maps-x)
    imap <C-l>m <plug>(fzf-maps-i)
    omap <C-l>m <plug>(fzf-maps-o)

    " Line completion (same as :Bline)
    " imap <C-x><C-z> <Plug>(fzf-complete-line)
    " inoremap <expr> <C-x><c-d> fzf#vim#complete('cat /usr/share/dict/words')

    " word completion popup
    " inoremap <expr> <C-x><C-w> fzf#vim#complete#word({
    "             \ 'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

    " word completion window
    " inoremap <expr> <C-x><C-a> fzf#vim#complete({
    "             \ 'source':  'cat /usr/share/dict/words',
    "             \ 'options': '--multi --reverse --margin 15%,0',
    "             \ 'left':    20})

    inoremap <expr> <c-x><c-l> fzf#vim#complete(fzf#wrap({
      \ 'prefix': '^.*$',
      \ 'source': 'rg -n ^ --color always',
      \ 'options': '--ansi --delimiter : --nth 3..',
      \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}))

    inoremap <expr> <M-.> fzf#complete(fzf#wrap({
                \ 'source': 'greenclip print 2>/dev/null \| grep -v "^\s*$" \| nl -w2 -s" "',
                \ 'reducer': { line -> substitute(line[0], '^ *[0-9]\+ ', '', '') }}))

    " mod = mod:gsub(" ", "\n") -- Replace non-breakable space
endfun

fun! plugs#fzf#commands()
    " command! -bang -nargs=? -complete=dir Files
    "             \ call fzf#vim#files(<q-args>,
    "             \ fzf#vim#with_preview(g:fzf_vim_opts, 'right:60%:default'), <bang>0)
    command! -bang Buffers
                \ call fzf#vim#buffers(
                \ fzf#vim#with_preview(g:fzf_vim_opts, 'right:60%:default'), <bang>0)
    command! -bang -complete=dir -nargs=? Ls
                \ call fzf#run(fzf#wrap({'source': 'ls', 'dir': <q-args>}, <bang>0))

    command! -nargs=? -complete=dir FilesAll
                \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
                \ 'source': 'fd --type f --hidden --follow --exclude .git --no-ignore
                \ . '.expand(<q-args>) })))

    command! -nargs=? -complete=dir FilesAll
                \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
                \ 'source': 'fd --type f --hidden --follow --exclude .git
                \ . '.expand(<q-args>) })))

    com! -bang -bar Conf call fzf#vim#files('~/.config', <bang>0)
    com! -bang -bar Projects call fzf#vim#files('~/projects', fzf#vim#with_preview(), <bang>0)
    com! -bang -bar VimFiles call fzf#vim#files('~/.vim', fzf#vim#with_preview(), <bang>0)
    com! -bang -bar -nargs=* Maps call fzf#vim#maps(<q-args>, <bang>0)
    com! -bang Colors call fzf#vim#colors(g:fzf_vim_opts, <bang>0)
    com! -bang -bar Helptags call fzf#vim#helptags(<bang>0)
    com! -nargs=? Apropos call fzf#run(fzf#wrap({
                \ 'source': 'apropos '
                \   . (len(<q-args>) > 0 ? shellescape(<q-args>) : ".")
                \   .' | cut -d " " -f 1',
                \ 'sink': 'tab Man',
                \ 'options': [
                \ '--preview', 'MANPAGER=cat MANWIDTH='.(&columns/2-4).' man {}']}))
    com! PlugHelp call fzf#run(fzf#wrap({
                \ 'source': sort(keys(g:plugs)),
                \ 'sink':   function('s:plug_help_sink')}))

    " \ . '| grep -vE "^.+ \(0\)" | awk ''{print $2 "    " $1}'' | sed -E "s/^\((.+)\)/\1/"',

    com! Dots call fzf#run(fzf#wrap({
                \ 'source': 'dotbare ls-files --full-name --directory "${DOTBARE_TREE}" '
                \ . '| awk -v home="${DOTBARE_TREE}/" "{print home \$0}"',
                \ 'sink': 'e',
                \ 'options': [ '--multi', '--preview', 'cat {}' ]
                \ }))

    com! -bang -nargs=* Rg
                \ call fzf#vim#grep(
                \ 'rg --column --line-number --hidden --smart-case '
                \ . '--no-heading --color=always '
                \ . shellescape(<q-args>),
                \ 1,
                \ {'options':  '--delimiter : --nth 4..'},
                \ 0)

    com! -nargs=* -bang RG call s:RipgrepFzf(<q-args>, <bang>0)
    com! -bang -nargs=0 Rgf call s:RipgrepTodo()
endfun

fun! plugs#fzf#autocmds() abort
    " au BufWipeout <buffer> execute 'bwipeout' s:frame

    augroup lmb__Fzf
        au!
        au VimResized * call <SID>resize_fzf_preview()
        au FileType fzf
                    \ set laststatus& laststatus=0 |
                    \ au BufLeave <buffer> set laststatus&
    augroup END
endfun

" function! s:create_float(hl, opts)
"   let buf = nvim_create_buf(v:false, v:true)
"   let opts = extend({'relative': 'editor', 'style': 'minimal'}, a:opts)
"   let win = nvim_open_win(buf, v:true, opts)
"   call setwinvar(win, '&winhighlight', 'NormalFloat:'.a:hl)
"   call setwinvar(win, '&colorcolumn', '')
"   return buf
" endfunction
"
" function! FloatingFZF()
"   " Size and position
"   let width = float2nr(&columns * 0.9)
"   let height = float2nr(&lines * 0.6)
"   let row = float2nr((&lines - height) / 2)
"   let col = float2nr((&columns - width) / 2)
"
"   " Border
"   let top = '┏━' . repeat('─', width - 4) . '━┓'
"   let mid = '│'  . repeat(' ', width - 2) .  '│'
"   let bot = '┗━' . repeat('─', width - 4) . '━┛'
"   let border = [top] + repeat([mid], height - 2) + [bot]
"
"   " Draw frame
"   let s:frame = s:create_float('Comment',
"         \ {'row': row, 'col': col, 'width': width, 'height': height})
"   call nvim_buf_set_lines(s:frame, 0, -1, v:true, border)
"
"   " Draw viewport
"   call s:create_float('Normal',
"         \ {'row': row + 1, 'col': col + 2, 'width': width - 4, 'height': height - 2})

fun! plugs#fzf#setup()
    " let g:rg_command = 'rg --vimgrep --hidden'
    let g:rg_highlight = 'true'
    let g:rg_format = '%f:%l:%c:%m,%f:%l:%m'

    let g:fzf_preview_quit_map = 1
    let g:fzf_buffers_jump = 1 " [Buffers] Jump to the existing window if possible
    let g:fzf_preview_window = ['right:50%:+{2}-/2,nohidden', '?']
    let g:fzf_commands_expect = 'enter'
    let g:fzf_history_dir = '~/.local/share/fzf-history'
    let g:fzf_vim_opts = {'options': ['--no-separator', '--history=/dev/null', '--reverse']} "
    let g:fzf_action = {
                \   'ctrl-t': 'tab drop',
                \   'ctrl-s': 'split',
                \   'ctrl-m': 'edit',
                \   'alt-v':  'vsplit',
                \   'alt-t':  'tabnew',
                \   'alt-x':  'split',
                \ }
    let g:fzf_layout = {
                \  'window': {
                \      'width': 0.8,
                \      'height': 0.8,
                \      'highlight': "Comment",
                \      'border': "rounded",
                \      'relative': v:true,
                \  },
                \ }
    " let g:fzf_layout = { 'window': 'call FloatingFZF()' }
    " let g:fzf_layout         = { 'down': '~40%' }

    let $FZF_DEFAULT_COMMAND = '(git ls-tree -r --name-only HEAD || rg --files --hidden) 2>/dev/null'
    let $FZF_PREVIEW_PREVIEW_BAT_THEME = 'kimbox'
    " let g:fzf_preview_fzf_preview_window_option = 'nohidden'
    let g:fzf_preview_use_dev_icons = 1
    let g:fzf_preview_dev_icon_prefix_string_length = 3
    let g:fzf_preview_dev_icons_limit = 2000
    let g:fzf_preview_default_fzf_options = {
                \ '--no-separator': v:true,
                \ '--reverse': v:true,
                \ '--history': '/dev/null',
                \ '--preview-window': 'wrap' ,
                \}
    let g:fzf_preview_git_status_preview_command =
                \ '$(git diff --cached -- {-1}) != \"\" ]] && git diff --cached --color=always -- {-1} | delta || ' .
                \ '$(git diff -- {-1}) != \"\" ]] && git diff --color=always -- {-1} | delta'

    call plugs#fzf#mappings()
    call plugs#fzf#commands()
    call plugs#fzf#autocmds()

    call s:resize_fzf_preview()
    call fzf_mru#enable()
    nnoremap <silent> <Leader>fr <Cmd>call fzf_mru#mru()<CR>
    nnoremap <silent> <M-,> <Cmd>call fzf_mru#mru()<CR>
endfun
