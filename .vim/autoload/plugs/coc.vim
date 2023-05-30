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

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" use K to show documentation in preview window.
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('definitionHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
endfunction

function! s:coc_confirm() abort
  if pumvisible()
    return coc#_select_confirm()
  else
    return "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
  endif
endfunction

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

    nmap <silent> gd <Plug>(coc-definition)
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
    inoremap <silent><expr> <CR>
                \ coc#pum#visible() ? coc#pum#confirm() :
                \ "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
    inoremap <silent><expr> <Tab>
                \ coc#pum#visible() ? coc#pum#next(1) :
                \ CheckBackspace() ? "\<Tab>" :
                \ coc#refresh()
    inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-d>"
    inoremap <expr><Down> coc#pum#visible() ? coc#pum#next(0) : "\<Down>"
    inoremap <expr><Up> coc#pum#visible() ? coc#pum#prev(0) : "\<Up>"
    inoremap <expr><C-j> coc#pum#visible() ? coc#pum#next(0) : "\<C-j>"
    inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(0) : "\<C-k>"

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

    xmap ;ff <Plug>(coc-format-selected)
    nmap ;fm <Plug>(coc-format-selected)
    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap if <Plug>(coc-funcobj-i)
    omap af <Plug>(coc-funcobj-a)
endfun

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
endfun

fun! plugs#coc#autocmds()
    augroup CocSetup
        au!
        au CursorHold * silent call CocActionAsync('highlight')
        au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        au FileType typescript,json setl formatexpr=CocAction('formatSelected')
        au FileType log :let b:coc_enabled = 0
    augroup end
endfun

fun! plugs#coc#setup() abort
    let g:coc_fzf_opts = ['--layout=reverse-list']
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
endfun
