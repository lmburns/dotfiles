fun! plugs#visualmulti#commands() abort
    com! VMClearHl call vm#clearmathces()
endfun


fun! plugs#visualmulti#mappings() abort
    " FIX: If vim ever allows M-S-o
    " Add-Cursor-Up
    " nmap <M-S-i> <Plug>(VM-Add-Cursor-Up)
    nmap <C-S-i> <Plug>(VM-Add-Cursor-Up)
    " Add-Cursor-Down
    " nmap <M-S-o> <Plug>(VM-Add-Cursor-Down)
    nmap <C-S-o> <Plug>(VM-Add-Cursor-Down)
    " Select-Cursor-Up
    nmap <C-S-Up> <Plug>(VM-Select-Cursor-Up)
    " Select-Cursor-Down
    nmap <C-S-Down> <Plug>(VM-Select-Cursor-Down)
    " Select-l
    nmap <C-M-S-Right> <Plug>(VM-Select-l)
    " Select-h
    nmap <C-M-S-Left> <Plug>(VM-Select-h)
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
endfun

fun! plugs#visualmulti#setup() abort
    let g:VM_leader = '<Space>'
    let g:VM_highlight_matches = ""
    let g:VM_show_warnings = 0
    let g:VM_silent_exit = 1
    let g:VM_default_mappings = 0
    let g:VM_set_statusline = 0
    let g:VM_case_setting = "smart"
    " let g:VM_recursive_operations_at_cursors = 1

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
    " "Alpha-Increase": "<C-S-i>",
    " "Alpha-Decrease": "<C-S-o>",
    " \ "Move Left": "<C-S-i>",
    " \ "Move Right": "<C-S-o>",
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

    call plugs#visualmulti#commands()
    call plugs#visualmulti#mappings()

    if exists('*repeat#set')
        sil! call repeat#set("\<Plug>mg979/vim-visual-multi", v:count)
    endif
endfun
