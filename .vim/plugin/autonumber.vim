if exists('g:autonumber_loaded') && g:autonumber_loaded | finish | endif

let g:autonumber_loaded = v:true
let g:autonumber_enable = get(g:, 'autonumber_enable', v:true)

let g:autonumber_exclude_filetype = get(g:, 'autonumber_exclude_filetype', [
                  \ 'NeogitCommitMessage',
                  \ 'NvimTree',
                  \ 'Trouble',
                  \ 'coc-explorer',
                  \ 'coc-list',
                  \ 'dap-repl',
                  \ 'fugitive',
                  \ 'gitcommit',
                  \ 'help',
                  \ 'list',
                  \ 'log',
                  \ 'man',
                  \ 'markdown',
                  \ 'netrw',
                  \ 'org',
                  \ 'orgagenda',
                  \ 'startify',
                  \ 'toggleterm',
                  \ 'undotree',
                  \ 'vim-plug',
                  \ 'vimwiki',
                  \ ])
let g:autonumber_exclude_buftype = get(g:, 'autonumber_exclude_buftype', [
                  \ 'quickfix',
                  \ 'terminal'
                  \ ])

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 AutonumberToggle call autonumber#toggle()
command! -nargs=0 AutonumberEnable call autonumber#enable()
command! -nargs=0 AutonumberDisable call autonumber#disable()
command! -nargs=0 AutonumberOnOff call autonumber#toggleAll()

let &cpo = s:save_cpo

if g:autonumber_enable | call autonumber#enable() | endif
