" Vim syntax file
" Language:  lf config file
" Maintainer: Cameron Wright https://github.com/VebbNix
" Last Change: 13 June 2021

if exists("b:current_syntax")
    finish
endif

let b:current_syntax = "lf"

"{{{ Comment Matching
syn match    lfComment        '#.*$'
"}}}

"{{{ String Matching
syn match    lfString         "'.*'"
syn match    lfString         '".*"' contains=lfVar,lfSpecial
"}}}

"{{{ Match lf Variables
syn match    lfVar            '\$f\|\$fx\|\$fs\|\$id'
"}}}

"{{{ Keywords
syn keyword  lfKeyword        set cmd map cmap skipwhite
"}}}

"{{{ Options Keywords
syn keyword  lfOptions
    \ anchorfind autoquit noanchorfind noautoquit
    \ bottom
    \ cd clear copy cursorfmt cursorpreviewfmt cut cleaner
    \ cmd-escape cmd-complete cmd-menu-complete cmd-menu-complete-back
    \ cmd-menu-accept cmd-enter cmd-interrupt cmd-history-next cmd-history-prev
    \ cmd-left cmd-right cmd-home cmd-end cmd-delete cmd-delete-back
    \ cmd-delete-home cmd-delete-end cmd-delete-unix-word cmd-yank
    \ cmd-transpose cmd-transpose-word cmd-word cmd-word-back cmd-delete-word
    \ cmd-capitalize-word cmd-uppercase-word cmd-lowercase-word
    \ delete down draw dircounts dirfirst dirpreviews drawbox
    \ echo echoerr echomsg errorfmt
    \ filesep findlen
    \ find find-back find-next find-prev
    \ globsearch glob-select glob-unselect
    \ half-down half-up hidden hiddenfiles history
    \ icons ifs ignorecase ignoredia incfilter incsearch info invert
    \ jump-prev jump-next
    \ load
    \ mark-load mark-remove mark-save mouse
    \ number
    \ open
    \ page-down page-up paste push period preview previewer promptfmt
    \ quit
    \ ratios relativenumber reverse read redraw reload rename
    \ scrolloff shell shellflag shellopts smartcase smartdia sortby
    \ search search-back search-next search-prev
    \ select shell shell-async shell-pipe shell-wait source sync
    \ tabstop tag-toggle tagfmt tempmarks timefmt toggle top truncatechar
    \ unselect up updir
    \ waitmsg wrapscan wrapscroll
"}}}

"{{{ Special Matching
syn match    lfSpecial        '<.*>\|\\.'
"}}}

"{{{ Shell Script Matching for cmd
unlet b:current_syntax
syn include  @Shell           syntax/zsh.vim
let b:current_syntax = "lf"
syn region   lfIgnore         start=".{{\n" end="^}}"
    \ keepend contains=lfExternalShell,lfExternalPatch
syn match    lfShell          '\$[a-zA-Z].*$
    \\|:[a-zA-Z].*$
    \\|%[a-zA-Z].*$
    \\|![a-zA-Z].*$
    \\|&[a-zA-Z].*$'
    \ transparent contains=@Shell,lfExternalPatch
syn match    lfExternalShell  "^.*$" transparent contained contains=@Shell
syn match    lfExternalPatch  "^\s*cmd\ .*\ .{{$\|^}}$" contained
"}}}

"{{{ Link Highlighting
hi def link  lfComment        Comment
hi def link  lfVar            Type
hi def link  lfSpecial        Special
hi def link  lfString         String
hi def link  lfKeyword        Statement
hi def link  lfOptions        Constant
hi def link  lfConstant       Constant
hi def link  lfExternalShell  Normal
hi def link  lfExternalPatch  Special
hi def link  lfIgnore         Special
"}}}
