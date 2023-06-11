" nnoremap <silent> <Leader>bl :Telescope buffers<cr>
" map ;c :Telescope commands<CR>
" map ;B :Telescope bookmarks<CR>
" nnoremap ;b <cmd>Telescope builtin<CR>
" nmap <silent> <Leader>bu  :Telescope buffers<CR>
" nmap <silent> <LocalLeader>b :Telescope buffers theme=get_dropdown<CR>
" nmap <Leader>; :Telescope current_buffer_fuzzy_find<CR>
" nmap ;e :Telescope live_grep theme=get_ivy<CR>
" nmap ;r :Telescope git_grep<CR>
" nnoremap ;fd <cmd>Telescope fd<CR>
" nmap <LocalLeader>f :Telescope find_files<CR>
" nmap <M-.> :Telescope frecency<CR>
" nmap <M-.> :Telescope oldfiles<CR>
" nmap ;g :Telescope git_files<CR>
" nmap <silent> <LocalLeader>T  :TodoTelescope<CR>
" nmap <silent> <Leader>hc :Telescope command_history<CR>
" nmap <silent> <Leader>hs :Telescope search_history<CR>
" nmap <Leader>cs :Telescope colorscheme<CR>
" nmap <silent> <Leader>si :Telescope ultisnips<CR>

" nnoremap <LocalLeader>c :Telescope coc<CR>
" nnoremap <M-c> :Telescope coc commands<CR>
" nnoremap <C-x>h :Telescope coc diagnostics<CR>
" nnoremap <C-x><C-r> :Telescope coc references<CR>
" nnoremap <C-[> :Telescope coc definitions<CR>
" nnoremap <C-x><C-]> :Telescope coc implementations<CR>
" nnoremap <C-x><C-h> :Telescope coc diagnostics<CR>
" nnoremap ;s :Telescope coc workspace_symbols<CR>
" nnoremap ;n :Telescope coc locations<CR>

let s:diag_qfid = -1
let s:fb_ft_black_list = ['c', 'cpp', 'css']

fun! s:CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endf

" use K to show documentation in preview window.
fun! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('definitionHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
endf

fun! s:coc_confirm() abort
    if coc#pum#visible()
        return coc#pum#confirm()
    else
        return (getline('.') =~ '^\s*$' ? '' : "\<C-g>u")."\<Plug>delimitMateCR"
    endif
endf

fun! s:get_curfunc_symbol() abort
    let sym = CocAction('getCurrentFunctionSymbol')
    echohl WarningMsg |
                \ echo strlen(sym) == 0 ? "N/A" : sym |
                \ echohl None
endf

fun! s:go_to_definition()
    let bufnr = bufnr()
    if &ft == "help"
        " call feedkeys("\<C-]>")
        execute("norm! \<C-]>")
        let w:gtd = "tag"
    else
        silent let ret = CocAction('jumpDefinition')
        if ret
            let w:gtd = 'coc'
        else
            let cword = expand('<cword>')
            try
                execute('ltag ' . cword)
                let view = winsaveview()
                let def_size = getloclist(0, {'size': 0}).size
                let w:gtd = 'ltag'
                if def_size > 1
                    execute("norm! \<C-o>")
                    call winrestview(view)
                    " execute('abo lw ' . def_size)
                    abo lw
                elseif def_size == 1
                    lclose
                    call search(cword, 'c')
                endif
            catch /.*/
                let w:gtd = 'search'
                call searchdecl(cword)
            endtry
        endif
    endif

    if bufnr() != bufnr
        normal zz
    endif
endf

" args: winid?, nr?, skeep?
fun! s:qf_diagnostic(...) abort
    let [winid, nr, skeep] = [get(a:, 1, 0), get(a:, 2, 0), get(a:, 3, v:false)]
    let diagnostic_list = CocAction('diagnosticList')
    let items = []
    let loc_ranges = []
    for d in diagnostic_list
        let type = d.severity[0]
        let text = printf('[%s%s] %s [%s]',
                    \ (empty(d.source) ? 'coc.nvim' : d.source),
                    \ (has_key(d, 'code') ? ' ' . d.code : ''),
                    \ split(d.message, '\n')[0], type)
        let item = {'filename': d.file,
                    \ 'lnum': d.lnum,
                    \ 'end_lnum': d.end_lnum,
                    \ 'col': d.col,
                    \ 'end_col': d.end_col,
                    \ 'text': text,
                    \ 'type': type}
        call add(items, item)
    endfor
    if !winid && !nr
        let id = s:diag_qfid
    else
        let info = getqflist({'id': s:diag_qfid, 'winid': 0, 'nr': 0})
        let [id, winid, nr] = [info.id, info.winid, info.nr]
    endif

    let action = id == 0 ? " " : "r"
    call setqflist([],
                \ action,
                \ {'id': id != 0 ? id : v:null,
                \  'title': 'CocDiagnosticList',
                \  'items': items})

    if id == 0
        let info = getqflist({'id': id, 'nr': 0})
        let [diag_qfid, nr] = [info.id, info.nr]
    endif

    if !skeep
        bo copen
    else
        call win_gotoid(winid)
    endif
    execute("sil ".nr."chi")
endf

" Function to run on `CocDiagnosticChange`
fun! s:diagnostic_change() abort
    if v:exiting
        let info = getqflist({'id': s:diag_qfid, 'winid': 0, 'nr': 0})
        if info.id == s:diag_qfid && info.winid != 0
            call s:qf_diagnostic(info.winid, info.nr, v:true)
        endif
    endif
endf

fun! s:jump2loc(locs, skip) abort
    let locs = deepcopy(empty(a:locs) ? g:coc_jump_locations : a:locs)
    call setloclist(0, [], ' ', {'title': 'CocLocationList', 'items': locs})
    " let loc_ranges = map(deepcopy(a:locs), 'v:val.range')
    " \ 'context': {'bqf': {'lsp_ranges_hl': loc_ranges}}})
    if !skip
        let winid = getloclist(0, {'winid': 0}).winid
        if winid == 0
            aboveleft lwindow
        else
            call win_gotoid(winid)
        endif
    endif
endf

fun! s:get_cur_word()
    let line = getline('.')
    let col = col('.')
    let left = strpart(line, 0, col)
    let right = strpart(line, col - 1, col('$'))
    let word = matchstr(left, '\k*$') . matchstr(right, '^\k*')[1:]
    return '\<' . escape(word, '/\') . '\>'
endf

fun! plugs#coc#highlight_fallback(err, res)
    if &buftype == 'terminal' || index(s:fb_ft_black_list, &filetype) > -1
        return
    endif

    if exists('w:coc_matchids_fb')
        silent! call matchdelete(w:coc_matchids_fb)
    endif

    let w:coc_matchids_fb = matchadd('CocHighlightText', s:get_cur_word(), -1)
endf

fun! plugs#coc#mappings()
    nnoremap <silent> K :call <SID>show_documentation()<CR>
    nnoremap <silent> <Leader>jo :CocDiagnosticsToggleBuf<CR>
    nnoremap <silent> <Leader>jR :CocRestart<CR>
    nnoremap <silent> <Leader>jd :CocDisable<CR>
    nmap <silent> ;fs <Plug>(coc-fix-current)
    nmap <silent> ;fd :CocFixAll<CR>
    nmap <silent> ;fi :OR<CR>
    nmap <silent> ;fc <Plug>(coc-codelens-action)

    nnoremap <silent> <Leader>j; :call coc#rpc#request('fillDiagnostics', [bufnr('%')])<Bar>copen<CR>
    nnoremap <silent> <Leader>j, :CocDiagnostics<CR>

    " nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gd :call <SID>go_to_definition()<CR>
    nmap <silent> gD :call CocActionAsync('jumpDeclaration', 'drop')<CR>
    nmap <silent> gy :call CocActionAsync('jumpTypeDefinition', 'drop')<CR>
    nmap <silent> gi :call CocActionAsync('jumpImplementation', 'drop')<CR>
    nmap <silent> gr :call CocActionAsync('jumpUsed', 'drop')<CR>
    nmap <silent> gR :call CocActionAsync('jumpReferences', 'drop')<CR>
    nmap <silent> ]g :call CocAction('diagnosticNext')<CR>
    nmap <silent> [g :call CocAction('diagnosticPrevious')<CR>
    nmap <silent> ]G :call CocAction('diagnosticNext', 'erro')<CR>
    nmap <silent> [G :call CocAction('diagnosticPrevious', 'error')<CR>
    nmap <silent> ]x :CocCommand document.jumpToNextSymbol<CR>
    nmap <silent> [x :CocCommand document.jumpToPrevSymbol<CR>
    nmap <Leader>jn <Plug>(coc-rename)
    nmap <Leader>j' <Plug>(coc-command-repeat)
    nmap <silent> <Leader>ja :call CocAction('refactor')<CR>
    nmap <silent> <Leader>? :call CocAction('diagnosticInfo')<CR>
    nmap <silent> <Leader>jl :CocCommand workspace.diagnosticRelated<CR>
    nmap <silent> <Leader>jr :call CocActionAsync('diagnosticRefresh', 'drop')<CR>
    nmap <Leader>rn <Plug>(coc-rename)
    nmap <Leader>rp <Plug>(coc-command-repeat)
    nmap <silent> <Leader>rf :call CocAction('refactor')<CR>

    nmap <C-CR>    <Plug>(coc-codeaction-line)
    nmap <M-CR>    <Plug>(coc-codeaction-cursor)
    nmap <C-M-CR>  <Plug>(coc-codeaction)
    xmap <C-CR>    <Plug>(coc-codeaction-selected)

    inoremap <silent><expr> <C-'> coc#refresh()
    " inoremap <silent> <CR> <C-r>=<SID>coc_confirm()<CR>

    " inoremap <C-S-m> <Right>
    " inoremap <silent><expr> <CR>
    "             \ coc#pum#visible() ? coc#pum#confirm() :
    "             \ "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
    inoremap <silent><expr> <Tab>
                \ coc#pum#visible() ? coc#pum#next(1) :
                \ <SID>CheckBackspace() ? "\<Tab>" :
                \ coc#refresh()
    inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-d>"
    inoremap <expr><Down> coc#pum#visible() ? coc#pum#next(0) : "\<Down>"
    inoremap <expr><Up> coc#pum#visible() ? coc#pum#prev(0) : "\<Up>"
    " imap <expr><C-j> coc#pum#visible() ? coc#pum#next(0) : "\<C-j>"
    " imap <expr><C-k> coc#pum#visible() ? coc#pum#prev(0) : "\<C-k>"

    nnoremap <C-x><C-l> :CocFzfList<CR>
    nnoremap <M-s> :CocFzfList symbols<CR>
    nnoremap <M-c> :CocFzfList commands<CR>

    nnoremap <C-x><C-d> :CocCommand fzf-preview.CocDefinition<CR>
    nnoremap <C-x><C-r> :CocCommand fzf-preview.CocReferences<CR>
    nnoremap <C-x><C-t> :CocCommand fzf-preview.CocTypeDefinition<CR>
    nnoremap <C-x><C-]> :CocCommand fzf-preview.CocImplementations<CR>
    nnoremap <C-x><C-h> :CocCommand fzf-preview.CocDiagnostics<CR>
    nnoremap <Leader>fd :CocCommand fzf-preview.CocOutline<CR>

    nmap <silent> <Leader>se :CocFzfList snippets<CR>
    nmap <silent> <M-/>  :CocCommand fzf-preview.Marks<CR>

    " nmap <silent> <Leader>a  :CocCommand fzf-preview.AllBuffers<CR>
    " nmap <silent> <Leader>C  :CocCommand fzf-preview.Changes<CR>
    " nmap <silent> <LocalLeader>;  :CocCommand fzf-preview.Lines<CR>
    " nmap <silent> <LocalLeader>d  :CocCommand fzf-preview.ProjectFiles<CR>
    " nmap <silent> <LocalLeader>g  :CocCommand fzf-preview.GitFiles<CR>
    " nmap <silent> <Leader>;  :CocCommand fzf-preview.BufferLines<CR>
    " nmap <silent> ,d  :CocCommand fzf-preview.DirectoryFiles<CR>
    " nmap <silent> <LocalLeader>r  :CocCommand fzf-preview.MruFiles<CR>
    " nmap <silent> <LocalLeader>T  :CocCommand fzf-preview.TodoComments<CR>
    " nmap <silent> <leader><space><space>so :<C-u>CocCommand snippets.openSnippetFiles<cr>
    " nmap <silent> <Leader>se :<C-u>CocCommand snippets.editSnippets<cr>

    " inoremap <silent><expr> <C-j>
    "       \ coc#jumpable() ? "\<C-R>=coc#rpc#request('snippetNext', [])\<cr>" :
    "       \ pumvisible() ? coc#_select_confirm() :
    "       \ "\<Down>"
    " inoremap <silent><expr> <C-k>
    "       \ coc#jumpable() ? "\<C-R>=coc#rpc#request('snippetPrev', [])\<cr>" :
    "       \ "\<Up>"

    nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
    vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
    inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

    nnoremap <silent> <M-q> <Cmd>call <SID>get_curfunc_symbol()<CR>
    nnoremap <silent> <Leader>j; <Cmd>call <SID>qf_diagnostic()<CR>

    " nmap ;fm <Plug>(coc-format-selected)
    nmap ;fm <Cmd>Format<CR>
    xmap ;ff <Plug>(coc-format-selected)

    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ik <Plug>(coc-classobj-i)
    omap ik <Plug>(coc-classobj-i)
    xmap ak <Plug>(coc-classobj-a)
    omap ak <Plug>(coc-classobj-a)
endf

fun! plugs#coc#commands()
    command! -nargs=0 CocMarket :CocFzfList marketplace
    command! -nargs=0 CocOutput :CocCommand workspace.showOutput
    command! -nargs=0 -range=% CocCodeAction :call CocActionAsync('codeActionRange', <line1>, <line2>, <f-args>)
    command! -nargs=* -range=% CocQuickfix :call CocActionAsync('codeActionRange', <line1>, <line2>, 'quickfix')
    command! -nargs=0 -range=% CocFixAll :call CocActionAsync('fixAll')
    command! -nargs=0 CocDiagnosticsToggleBuf :call CocActionAsync('diagnosticToggleBuffer')
    command! -nargs=0 CocDiagnosticsToggle :call CocActionAsync('diagnosticToggle')
    command! -nargs=0 Prettier :call CocActionAsync('runCommand', 'prettier.formatFile')
    command! -nargs=0 Format :call CocAction('format')
    command! -nargs=? Fold :call CocAction('fold', <f-args>)
    command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
endf

fun! plugs#coc#autocmds()
    augroup CocSetup
        au!
        au FileType typescript,json setl formatexpr=CocAction('formatSelected')
        au FileType log :let b:coc_enabled = 0
        au User CocLocationsChange ++nested call s:jump2loc()
        au User CocDiagnosticChange ++nested call s:diagnostic_change()
        au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        au VimLeavePre * if get(g:, 'coc_process_pid', 0) |
                    \ call system('kill -9 -- -' . g:coc_process_pid) | endif
        " au CursorHold * silent! call CocActionAsync('highlight')
        au CursorHold * silent! call CocActionAsync('highlight',
                    \ '', function('plugs#coc#highlight_fallback'))
    augroup end

    " autocmd User CocNvimInit ++once call <SID>coc_lazy_init()
endf

fun! plugs#coc#setup() abort
    let g:coc_fzf_opts = ['--reverse']
    let g:coc_enable_locationlist = 0
    let g:coc_selectmode_mapping = 0
    let g:coc_global_extensions = [
                \  "coc-sumneko-lua",
                \  "coc-json",
                \  "coc-clangd",
                \  "coc-css",
                \  "coc-go",
                \  "coc-html",
                \  "coc-markdownlint",
                \  "coc-java",
                \  "coc-perl",
                \  "coc-pyright",
                \  "coc-r-lsp",
                \  "coc-rust-analyzer",
                \  "coc-solargraph",
                \  "coc-solidity",
                \  "coc-sql",
                \  "coc-toml",
                \  "coc-vimlsp",
                \  "coc-xml",
                \  "coc-yaml",
                \  "coc-zig",
                \  "coc-tsserver",
                \  "coc-eslint",
                \  "coc-syntax",
                \  "coc-prettier",
                \  "coc-diagnostic",
                \  "coc-fzf-preview",
                \  "coc-marketplace",
                \  "coc-tabnine",
                \  "coc-tag",
                \  "coc-word"
                \ ]

    call plugs#coc#commands()
    call plugs#coc#autocmds()
    call plugs#coc#mappings()
endf
