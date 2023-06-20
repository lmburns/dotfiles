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
syn match    lfVar            '\$f\([xs]\)\@1!\|\$fx\|\$fs\|\$id'
"}}}

"{{{ Keywords
" syn keyword  lfKeyword        set cmd map cmap skipwhite
"}}}

"{{{ Options Keywords
syn keyword  lfOptions
    \ anchorfind          autoquit
    \ bottom
    \ cd                  clear                copy              cursorfmt   cursorpreviewfmt cut cleaner
    \ delete              down                 draw              dircache    dircounts
    \ dirfirst            dironly              dirpreviews       drawbox
    \ echo                echoerr              echomsg           errorfmt
    \ filesep             filter               findlen
    \ find                find-back            find-next         find-prev
    \ globsearch          glob-select          glob-unselect
    \ half-down           half-up              hidden            hiddenfiles history
    \ icons               ifs                  ignorecase        ignoredia
    \ incfilter           incsearch            info              invert      invert-below
    \ jump-prev           jump-next
    \ load
    \ mark-load           mark-remove          mark-save         mouse
    \ number
    \ open
    \ page-down           page-up              paste             push
    \ period              preview              previewer         promptfmt
    \ quit
    \ ratios              relativenumber       reverse           read
    \ redraw              reload               rename            ruler
    \ scrolloff           shell                shellflag         shellopts
    \ smartcase           smartdia             sortby            search
    \ search-back         search-next          search-prev       select
    \ shell               shell-async          shell-pipe        shell-wait
    \ source              sync                 statfmt
    \ tabstop             tag-toggle           tagfmt            tempmarks
    \ timefmt             toggle               top               truncatechar
    \ unselect            up                   updir
    \ waitmsg             wrapscan             wrapscroll
    \ cmd-escape          cmd-complete         cmd-menu-complete cmd-menu-complete-back
    \ cmd-menu-accept     cmd-enter            cmd-interrupt     cmd-history-next
    \ cmd-history-prev    cmd-left             cmd-right         cmd-home
    \ cmd-end             cmd-delete           cmd-delete-back   cmd-delete-home
    \ cmd-delete-end      cmd-delete-unix-word cmd-yank          cmd-transpose
    \ cmd-transpose-word  cmd-word             cmd-word-back     cmd-delete-word
    \ cmd-capitalize-word cmd-uppercase-word   cmd-lowercase-word
    \ noanchorfind        noautoquit           nodircache        nodircounts
    \ nodirfirst          nodironly            nodirpreviews     nodrawbox
    \ noglobsearch        nohidden             noicons           noignorecase
    \ noignoredia         noincsearch          noincfilter       nomouse
    \ nonumber            nopreview            norelativenumber  noreverse
    \ nosmartcase         nosmartdia           nowrapscan        nowrapscroll
"}}}

"{{{ Special Matching
syn match    lfSpecial        '<.*>\|\\.'
"}}}

"{{{ Shell Script Matching for cmd
unlet b:current_syntax
syn include  @Shell           syntax/zsh.vim
let b:current_syntax = "lf"

syn match    lfShell         '\%(\$\|:\|%\|!\|&\)[a-zA-Z[].*$'  transparent contains=@Shell

syn keyword  lfKeyword        set cmap
syn keyword  lfCmd            cmd contained
syn keyword  lfMap            map contained

syn match    lfBrackets             '{{' contained
syn match    lfBrackets             '}}' contained
syn match    lfExternalFuncType     '\%(\$\|:\|%\|!\|&\){{' contained contains=lfBrackets
syn match    lfExternalFuncName     'cmd\s\+\S\{-}\ze\s\+\%(\$\|:\|%\|!\|&\){{\?' skipwhite contains=lfExternalFuncType,lfKeyword,lfCmd
syn match    lfMapKey               'map\s\+\S\{-}\ze\s\+\%(\$\|:\|%\|!\|&\){{\?' skipwhite contains=lfExternalFuncType,lfKeyword,lfMap

" Multi-line
syn region   lfExternalFunc  start="\%(\$\|%\|!\|&\){{\n" end="^}}"
                           \ keepend contains=lfVar,@Shell,lfExternalFuncType,lfBrackets
" Single-line
" cmd name ${{ ... }}
" map key ${{ ... }}
syn region   lfExternalFunc  start="\%(\$\|%\|!\|&\){{" end="}}"
                           \ keepend contains=@Shell,lfExternalFuncType,lfVar,lfBrackets
" Multi-line (lf command function)
syn region   lfExternalFunc  start=":{{\n" end="^}}"
                           \ keepend contains=@Shell,lfExternalFuncType,lfVar,lfBrackets,lfKeyword,lfOptions,lfString,lfComment,lfMapSL
" Single-line (lf command function)
" cmd name :{{ set ctime; }}
" map key :{{ set ctime; }}
syn region   lfExternalFunc  start=":{{" end="}}"
                           \ keepend contains=@Shell,lfExternalFuncType,lfVar,lfBrackets,lfKeyword,lfOptions,lfString,lfComment,lfMap,lfCmd

" Single-line (no brackets)
" cmd name $here
" map key $here

syn match lfMapSL        'map\ze\(.*{{\)\@!'     skipwhite contains=lfMap nextgroup=lfMapKeySL
syn match lfMapKeySL     '\S\+'                  contained skipwhite contains=lfSpecial nextgroup=lfMapTypeSL,lfMapTypeCmdSL,lfMapFuncSL,lfKeyword
syn match lfMapFuncSL    '[^: ]\+'               contained skipwhite contains=lfOptions
syn match lfMapTypeSL    '\%(\$\|%\|!\|&\)'      contained nextgroup=lfMapBodySL,@Shell
syn match lfMapBodySL    '.*$'                   contained contains=@Shell
syn match lfMapTypeCmdSL ':'                     contained nextgroup=lfMapCmdSL
syn match lfMapCmdSL     '.*$'                   contained contains=@Shell,lfVar,lfBrackets,lfKeyword,lfOptions,lfString,lfComment

" syn keyword lfCmd cmd nextgroup=lfExternalFuncNameSL
syn match lfCmdSL                 'cmd\ze\(.*{{\)\@!'    skipwhite contains=lfCmd nextgroup=lfExternalFuncNameSL
syn match lfExternalFuncNameSL    '\S\+'                 contained skipwhite nextgroup=lfExternalFuncTypeSL,lfExternalFuncTypeCmdSL,lfKeyword
syn match lfExternalFuncTypeSL    '\%(\$\|%\|!\|&\)'     contained nextgroup=lfExternalFuncSL
syn match lfExternalFuncSL        '.*$'                  contained contains=@Shell
syn match lfExternalFuncTypeCmdSL ':'                    contained nextgroup=lfExternalFuncCmdSL
syn match lfExternalFuncCmdSL     '.*$'                  contained contains=@Shell,lfVar,lfBrackets,lfKeyword,lfOptions,lfString,lfComment,@lfMapping
"}}}

"{{{ Link Highlighting
hi def link lfComment               Comment
hi def link lfVar                   Type
hi def link lfSpecial               Special
hi def link lfString                String
hi def link lfKeyword               Statement
hi def link lfOptions               Constant
hi def link lfConstant              Constant
hi def link lfCmd                   Statement
hi def link lfCmdSL                 lfCmd
hi def link lfExternalFuncName      Function
hi def link lfExternalFuncNameSL    lfExternalFuncName
hi def link lfExternalFuncType      MoreMsg
hi def link lfExternalFuncTypeSL    lfExternalFuncType
hi def link lfExternalFuncTypeCmdSL lfExternalFuncType
hi def link lfMap                   Statement
hi def link lfMapSL                 lfMap
hi def link lfMapKey                TSConstructor
hi def link lfMapKeySL              lfMapKey
hi def link lfMapFuncSL             lfExternalFuncName
hi def link lfMapTypeSL             lfExternalFuncType
hi def link lfMapTypeCmdSL          lfExternalFuncType
hi def link lfBrackets              FZFVistaTag

" hi def link  lfExternalShell  MoreMsg
" hi def link  lfExternalPatch  Special
" hi def link  lfIgnore         Special
"}}}
