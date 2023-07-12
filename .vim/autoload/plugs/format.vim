fun! plugs#format#setup() abort
    let g:neoformat_basic_format_retab = 1
    let g:neoformat_basic_format_trim = 1
    let g:neoformat_basic_format_align = 1

    let g:neoformat_enabled_python = ["black"]
    let g:neoformat_enabled_zsh = ["expand"]
    let g:neoformat_enabled_java = ["prettier"]
    let g:neoformat_enabled_graphql = ["prettier"]
    let g:neoformat_enabled_solidity = ["prettier"]
    let g:neoformat_enabled_javascript = ["prettier"]
    let g:neoformat_enabled_typescript = ["prettier", "clangfmt"]
    let g:neoformat_typescript_clangfmt = {
                \ 'exe': "clang-format",
                \ 'stdin': 1,
                \ 'try_node_exe': 0,
                \ }
    let g:neoformat_enabled_typescriptreact = ["prettier", "clangfmt"]
    let g:neoformat_typescriptreact_clangfmt = {
                \ 'exe': "cat",
                \ 'args': ['"%:p"', "|", "clang-format", "--assume-filename", ".ts"],
                \ 'stdin': 1,
                \ 'no_append': v:true,
                \ 'try_node_exe': 0,
                \ }
    let g:neoformat_enabled_yaml = ["prettier"]
    let g:neoformat_yaml_prettier = {
                \      'exe': "prettier",
                \      'args': ["--stdin-filepath", '"%:p"', "--tab-width=2"],
                \      'stdin': 1,
                \  }
    let g:neoformat_enabled_ruby = ["rubocop"]
    let g:neoformat_ruby_rubocop = {
                \   'exe': "rubocop",
                \   'args': [
                \       "--auto-correct",
                \       "--stdin",
                \       '"%:p"',
                \       "2>/dev/null",
                \       "|",
                \       'sed "1,/^====================$/d"',
                \   ],
                \   'stdin': 1,
                \   'stderr': 1,
                \ }
    let g:neoformat_enabled_sql = ["sqlformatter"]
    let g:neoformat_sql_sqlformatter = {
                \ 'exe': "sql-formatter",
                \ 'args': ["--indent", "4"],
                \ 'stdin': 1,
                \ }
    let g:neoformat_enabled_json = ["prettier", "jq"]
    let g:neoformat_json_jq = {'exe': "jq", 'args': ["--indent", "4"], 'stdin': 1}

    let g:neoformat_enabled_lua = ["luafmtext", "luaformat", "stylua"]
    let g:neoformat_lua_luafmtext = {
                \     'exe': "lua-fmt-ext",
                \     'args': ["--stdin", "--line-width", "100"],
                \     'stdin': 1,
                \ }

    nnoremap ;ff <Cmd>Neoformat<CR>

    augroup lmb__Formatting
        autocmd!
        autocmd FileType vim
                    \ nnoremap <buffer><silent> ;ff <Cmd>call usr#utils#preserve('norm =ie')<CR>|
                    \ xnoremap <buffer><silent> ;ff =
        autocmd FileType lua        nmap <buffer><silent> ;ff <Cmd>Neoformat! lua  luaformat<CR>
        autocmd FileType java       nmap <buffer><silent> ;ff <Cmd>Neoformat! java prettier<CR>
        autocmd FileType perl       nmap <buffer><silent> ;ff <Cmd>Neoformat! perl<CR>
        autocmd FileType sh         nmap <buffer><silent> ;ff <Cmd>Neoformat! sh<CR>
        autocmd FileType python     nmap <buffer><silent> ;ff <Cmd>Neoformat! python black<CR>
        autocmd FileType md,vimwiki nmap <buffer><silent> ;ff <Cmd>Neoformat!<CR>
        autocmd FileType zsh        nmap <buffer><silent> ;ff <Cmd>Neoformat  expand<CR>
    augroup end
endfun
