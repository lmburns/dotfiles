let s:mode_d = {'NORMAL': 0, 'VISUAL': 1}
let s:vm_mappings = []
" let g:usr_err_vm_mappings = []

fun! s:mode() abort
    if get(g:, 'Vm.extend_mode') == 1
        return s:mode_d.VISUAL
    else
        return s:mode_d.NORMAL
    endif
endfu

fun! s:esc_map() abort
    if s:mode() == s:mode_d.VISUAL
        call b:VM_Selection.Global.cursor_mode()
    else
        " execute "norm \<Plug>(VM-Exit)"
        call feedkeys("\<Plug>(VM-Exit)")
    endif
endfu

fun! plugs#vm#map(mode, nore, key, to, ...) abort
    let map = printf('%s%smap <buffer>%s %s %s',
                \ a:mode,
                \ a:nore == 1 ? 'nore' : '',
                \ join(a:000),
                \ a:key,
                \ a:to)
    call add(s:vm_mappings, [a:mode, a:key])
    execute map
endfun

func! plugs#vm#start() abort
    " call wilder#disable()
endf

func! plugs#vm#exit() abort
    " call wilder#enable()

    for [m, k] in s:vm_mappings
        try
            execute m.'unmap <buffer> '.k
        catch /.*/
            " call add(g:usr_err_vm_mappings, [m, k, maparg(k, m)])
        endtry
    endfor
endf

func! plugs#vm#au_mappings() abort
    " call plugs#vm#map('n', 0, 's', '<Plug>(VM-Select-Operator)', '<nowait>')
    call plugs#vm#map('n', 0, '<CR>', '<C-n>')
    call plugs#vm#map('n', 0, 'n', '<C-n>')
    call plugs#vm#map('n', 0, 'N', 'N')
    call plugs#vm#map('n', 0, '"', '"')
    call plugs#vm#map('n', 0, ')', 'n')
    call plugs#vm#map('n', 0, '(', 'N')

    call plugs#vm#map('o', 1, 'f', 'f')
    call plugs#vm#map('o', 1, 'F', 'F')
    call plugs#vm#map('o', 1, 't', 't')
    call plugs#vm#map('o', 1, 'T', 'T')

    call plugs#vm#map('n', 0, '<C-c>', '<Plug>(VM-Exit)', '<silent>')
    call plugs#vm#map('n', 0, ';i', '<Plug>(VM-Show-Regions-Info)', '<silent>')
    call plugs#vm#map('n', 0, ';e', '<Plug>(VM-Filter-Lines)', '<silent>')
    call plugs#vm#map('n', 1, 'v', '<Cmd>call b:VM_Selection.Global.extend_mode()<CR>', '<silent>')

    call plugs#vm#map('i', 1, '<CR>', 'coc#pum#visible() ? "\<C-y>" : "\<Plug>(VM-I-Return)"', '<expr>')
    call plugs#vm#map('n', 1, '<Esc>', '<Cmd>call <SID>esc_map()<CR>', '<nowait>')
endf

fun! plugs#vm#commands() abort
    com! VMClearHl call vm#clearmatches()
endf

fun! plugs#vm#mappings() abort
    " Add-Cursor-Up
    nmap <M-S-i> <Plug>(VM-Add-Cursor-Up)
    " nmap <C-S-i> <Plug>(VM-Add-Cursor-Up)
    " Add-Cursor-Down
    nmap <M-S-o> <Plug>(VM-Add-Cursor-Down)
    " nmap <C-S-o> <Plug>(VM-Add-Cursor-Down)

    " Select-Cursor-Up
    nmap <C-Up> <Plug>(VM-Select-Cursor-Up)
    " Select-Cursor-Down
    nmap <C-Down> <Plug>(VM-Select-Cursor-Down)

    " Select-l
    " nmap <C-M-S-Right> <Plug>(VM-Select-l)
    " Select-h
    " nmap <C-M-S-Left> <Plug>(VM-Select-h)

    " Add-Cursor-At-Pos
    nmap <Leader>\ <Plug>(VM-Add-Cursor-At-Pos)

    " Start-Regex-Search
    nmap <Leader>/ <Plug>(VM-Start-Regex-Search)
    " Visual-Regex
    xmap <Leader>/ <Plug>(VM-Visual-Regex)
    " Find-Under
    nmap <C-n> <Plug>(VM-Find-Under)
    " Find-Subword-Under
    xmap <C-n> <Plug>(VM-Find-Subword-Under)

    " Select-All
    nmap <Leader>A <Plug>(VM-Select-All)
    " Visual-All
    xmap <Leader>A <Plug>(VM-Visual-All)
    " Visual-All
    xmap ;A <Plug>(VM-Visual-All)
    " Visual-Add
    xmap ;a <Plug>(VM-Visual-Add)
    " Visual-Find
    xmap ;F <Plug>(VM-Visual-Find)
    " Visual-Cursors
    xmap ;C <Plug>(VM-Visual-Cursors)

    " Reselect-Last
    nmap <Leader>gs <Plug>(VM-Reselect-Last) " Start VM with last search
    nmap g/ :VMSearch<CR>
endf

fun! plugs#vm#setup() abort
    let g:VM_leader = "<Space>"
    let g:VM_highlight_matches = ""
    let g:VM_show_warnings = 0
    let g:VM_silent_exit = 1
    let g:VM_default_mappings = 0
    let g:VM_set_statusline = 1
    let g:VM_case_setting = "smart"
    " let g:VM_recursive_operations_at_cursors = 1
    " let g:VM_force_maps = 1
    " let g:VM_check_mappings = 1

    let g:VM_Mono_hl = "DiffText"
    let g:VM_Extend_hl = "DiffAdd"
    let g:VM_Cursor_hl = "Visual"
    let g:VM_Insert_hl = "DiffChange"

    let g:VM_custom_motions = {
                \ "L": "$",
                \ "H": "^",
                \ }
    let g:VM_custom_noremaps = {
                \ "==": "==",
                \ "<<": "<<",
                \ ">>": ">>",
                \ }

  let g:VM_plugins_compatibilty = {
            \ 'wilder': {
            \   'test': {-> v:true},
            \   'enable': ':call wilder#enable()',
            \   'disable': ':call wilder#disable()'},
            \}

    let g:VM_user_operators = [
                \ "dss",
                \ {'css': 1},
                \ {'yss': 1},
                \ {'cs': 2},
                \ {'ds': 1},
                \ "gc",
                \ "gb",
                \ {'crt': 2},
                \ {'crc': 2},
                \ "cr",
                \ {'cr': 3},
                \ {'ys': 3},
                \ {'<C-s>': 2},
                \ ]

    " let g:VM_custom_commands = {}

    " "Add Cursor Up":  "<A-S-i>",
    " "Add Cursor Down":  "<A-S-o>",
    " "Select Cursor Up":  "<C-S-Up>",
    " "Select Cursor Down":  "<C-S-Down>",
    " "gIncrease": "<C-S-i>",
    " "gDecrease": "<C-S-o>",

    " let g:VM_unmaps = {}
    let g:VM_maps = {
                \ 'Delete': "d",
                \ 'Yank': "y",
                \ "Select Operator": "s",
                \ "Find Operator": "m",
                \ 'Undo': "u",
                \ 'Redo': "U",
                \ "Switch Mode": ",",
                \ 'i': "i",
                \ 'I': "I",
                \ "Add Cursor At Pos": '<Leader>\',
                \ "Slash Search": "g/",
                \ "Move Left": "<C-S-i>",
                \ "Move Right": "<C-S-o>",
                \ "Find Next": "]",
                \ "Find Prev": "[",
                \ "Goto Next": "}",
                \ "Goto Prev": "{",
                \ "Seek Next": "<C-f>",
                \ "Seek Prev": "<C-b>",
                \ "Skip Region": "q",
                \ "Remove Region": "Q",
                \ "Remove Last Region": "<Leader>q",
                \ "Remove Every n Regions": "<Leader>R",
                \ "Surround": "S",
                \ "Replace Pattern": "R",
                \ "Increase": "<C-A-i>",
                \ "Decrease": "<C-A-o>",
                \ "Invert Direction":  "o",
                \ "Shrink":  "<",
                \ "Enlarge":  ">",
                \ "Transpose":  "<Leader>t",
                \ "Align":  "<Leader>a",
                \ "Align Char":  "<Leader><",
                \ "Align Regex":  "<Leader>>",
                \ "Split Regions":  "<Leader>s",
                \ "Filter Regions":  "<Leader>f",
                \ "Merge Regions":  "<Leader>m",
                \ "Transform Regions":  "<Leader>e",
                \ "Rewrite Last Search":  "<Leader>r",
                \ "Duplicate":  "<Leader>d",
                \ "One Per Line":  "<Leader>L",
                \ "Numbers":  "<Leader>n",
                \ "Numbers Append":  "<Leader>N",
                \ "Zero Numbers":  "<Leader>0n",
                \ "Zero Numbers Append":  "<Leader>0N",
                \ "Run Normal":  "<Leader>z",
                \ "Run Last Normal":  "<Leader>Z",
                \ "Run Visual":  "<Leader>v",
                \ "Run Last Visual":  "<Leader>V",
                \ "Run Ex":  "<Leader>x",
                \ "Run Last Ex":  "<Leader>X",
                \ "Run Macro":  "<Leader>@",
                \ "Run Dot":  "<Leader>.",
                \ "Tools Menu":  "<Leader>`",
                \ "Case Setting":  "<Leader>c",
                \ "Case Conversion Menu":  "<Leader>C",
                \ "Search Menu":  "<Leader>S",
                \ "Show Registers":  '<Leader>"',
                \ "Show Infoline":  "<Leader>l",
                \ "Toggle Whole Word":  "<Leader>w",
                \ "Toggle Block":  "<Leader><BS>",
                \ "Toggle Multiline":  "<Leader>M",
                \ "Toggle Single Region":  "<Leader><CR>",
                \ "Toggle Mappings":  "<Leader><Leader>",
                \ "Visual Subtract":  "<Leader>s",
                \ "Visual Find":  "<Leader>f",
                \ "Visual Add":  "<Leader>a",
                \ "Visual All":  "<Leader>A",
                \ "I Arrow w":  "<C-Right>",
                \ "I Arrow b":  "<C-Left>",
                \ "I Arrow W":  "<C-S-Right>",
                \ "I Arrow B":  "<C-S-Left>",
                \ "I Arrow ge":  "<C-Up>",
                \ "I Arrow e":  "<C-Down>",
                \ "I Arrow gE":  "<C-S-Up>",
                \ "I Arrow E":  "<C-S-Down>",
                \ }

    call plugs#vm#commands()
    call plugs#vm#mappings()

    if exists('*repeat#set')
        sil! call repeat#set("\<Plug>mg979/vim-visual-multi", v:count)
    endif

    augroup lmb__VisualMulti
        autocmd!
        autocmd User visual_multi_start call plugs#vm#start()
        autocmd User visual_multi_exit call plugs#vm#exit()
        autocmd User visual_multi_mappings call plugs#vm#au_mappings()
    augroup END
endf
