" Copyright (c) 2019 Sebastian Gniazdowski
"
" Syntax highlighting for Zinit commands in any file of type `zsh'.
" It adds definitions for the Zinit syntax to the ones from the
" existing zsh.vim definitions-file.

" Main Zinit command.
" Should be the only TOP rule for the whole syntax.
syntax match ZinitCommand     /\<\(zinit\|zi\)\>\s/me=e-1
            \ skipwhite
            \ nextgroup=ZinitSubCommands,ZinitPluginSubCommands,ZinitSnippetSubCommands
            \ contains=ZinitSubCommands,ZinitPluginSubCommands,ZinitSnippetSubCommands

syntax match ZinitCommand     /\<\(zt\)\>\s/me=e-1
            \ skipwhite
            \ nextgroup=ZinitSubCommands,ZinitPluginSubCommands,ZinitSnippetSubCommands,ZinitIceModifiers
            \ contains=ZinitSubCommands,ZinitPluginSubCommands,ZinitSnippetSubCommands

" TODO: add options for e.g. light
syntax match ZinitSubCommands /\s\<\%(ice\|compinit\|env-whitelist\|cdreplay\|cdclear\|update\|[0-9][a-c]\)\>\s/ms=s+1,me=e-1
            \ contained

syntax match ZinitPluginSubCommands /\s\<\%(light\|load\|pack\)\>\s/ms=s+1,me=e-1
            \ skipwhite nextgroup=ZinitPlugin1,ZinitPlugin2,ZinitPlugin3
            \ contains=ZinitPlugin1,ZinitPlugin2,ZinitPlugin3

syntax match ZinitSnippetSubCommands /\s\<\%(snippet\)\>\s/ms=s+1,me=e-1
            \ skipwhite
            \ nextgroup=ZinitSnippetShorthands1,ZinitSnippetShorthands3
            \ contains=ZinitSnippetShorthands1,ZinitSnippetShorthands2

" "user/plugin"
syntax match ZinitPlugin1 /\s["]\%([!-_]*\%(\/[!-_]\+\)\+\|[!-_]\+\)["]/ms=s+1,hs=s+2,he=e-1
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

" 'user/plugin'
syntax match ZinitPlugin2 /\s[']\%([!-_]*\%(\/[!-_]\+\)\+\|[!-_]\+\)[']/ms=s+1,hs=s+2,he=e-1
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

" user/plugin
syntax match ZinitPlugin3 /\s\%([!-_]*\%(\/[!-_]\+\)\+\|[!-_]\+\)/ms=s+1,me=e+2
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

" OMZ:: or PZT::
" TODO: 'OMZ:: or 'PZT::
syn iskeyword @,48-57,_,192-255,.,-,+
syntax match ZinitSnippetShorthands1 /\s\<\%(\%(OMZ\|OMZL\|OMZP\|PZT\)\>::\|\)/hs=s+1,he=e-2
            \ contained
            \ skipwhite
            \ nextgroup=ZinitSnippetUrl1,ZinitSnippetUrl2
            \ contains=ZinitSnippetUrl1,ZinitSnippetUrl2
" syn iskeyword @,48-57,_,192-255,.,-,+,:

" "OMZ:: or "PZT::
syntax match ZinitSnippetShorthands2 /\s["]\%(\%(OMZ\|OMZL\|OMZP\|PZT\)\>::\|\)/hs=s+2,he=e-2
            \ contained
            \ skipwhite
            \ nextgroup=ZinitSnippetUrl3,ZinitSnippetUrl4
            \ contains=ZinitSnippetUrl3,ZinitSnippetUrl4

syntax match ZinitSnippetUrl3 /\<\%(http:\/\/\|https:\/\/\|ftp:\/\/\|\$HOME\|\/\)[!-_]\+\%(\/[!-_]\+\)*\/\?["]/he=e-1
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

" TODO: Fix ZinitTrailingWhiteSpace not matching
syntax match ZinitSnippetUrl4 /\%(\%(OMZ\|OMZL\|OMZP\|PZT\)::\)[!-_]\+\%(\/[!-_]\+\)*\/\?["]/hs=s+5,he=e-1
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

" http://… or https://… or ftp://… or $HOME/… or /…
" TODO: Fix $HOME/… and /… not matching
syntax match ZinitSnippetUrl1 /\<\%(http:\/\/\|https:\/\/\|ftp:\/\/\|\$HOME\|\/\)[!-_]\+\%(\/[!-_]\+\)*\/\?/
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

" TODO: Fix ZinitTrailingWhiteSpace not matching
syntax match ZinitSnippetUrl2 /\<\%(\%(OMZ\|OMZL\|OMZP\|PZT\)::\)[!-_]\+\%(\/[!-_]\+\)*\/\?/hs=s+5
            \ contained
            \ nextgroup=ZinitTrailingWhiteSpace
            \ contains=ZinitTrailingWhiteSpace

syntax match ZinitTrailingWhiteSpace /[[:space:]]\+$/ contained

" TODO: differentiate the no-value ices
" TODO: use contained
syntax match ZinitIceSubCommand /\sice\s/ms=s+1,me=e-1 nextgroup=ZinitIceModifiers
" # CLONING
syntax match ZinitIceModifiers  /\s\<\%(proto\|from\|ver\|bpick\|depth\|cloneopts\|pullopts\|svn\)\>/ms=s+1
" # SELCTION
syntax match ZinitIceModifiers  /\s\<\%(pick\|src\|multisrc\)\>/ms=s+1
" # CONDITIONAL
syntax match ZinitIceModifiers  /\s\<\%(wait\|load\|unload\|cloneonly\|if\|has\|subscribe\|on-update-of\|trigger-load\)\>/ms=s+1
" # OUTPUT
syntax match ZinitIceModifiers  /\s\<\%(silent\|lucid\|notify\)\>/ms=s+1
" # COMPLETIONS
syntax match ZinitIceModifiers  /\s\<\%(nocompletions\|blockf\)\>/ms=s+1
" # COMMAND EXEC
syntax match ZinitIceModifiers  /\s\<\%(atclone\|atpull\|atinit\|atload\|atdelete\|run-atpull\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(mv\|cp\|nocd\|make\|configure\|countdown\|reset\)\>/ms=s+1
" # EMULATION
syntax match ZinitIceModifiers  /\s\<\%(\\!sh\|!sh\|\\!bash\|!bash\|\\!ksh\|!ksh\|\\!csh\|!csh\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(sh\|\!sh\|bash\|\!bash\|ksh\|\!ksh\|csh\|\!csh\)\>/ms=s+1
" # OTHER
syntax match ZinitIceModifiers  /\s\<\%(as\|id-as\|compile\|nocompile\|service\|reset-prompt\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(bindmap\|trackbinds\|wrap-track\|aliases\|subst\|autoload\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(light-mode\|extract\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(param\|teleid\|is-snippet\|\|ps-on-unload\|ps-on-update\)\>/ms=s+1

" Include also ices added by the existing annexes
syntax match ZinitIceModifiers  /\s\<\%(test\|zman\|submod\|dl\|patch\|fbin\|sbin\|fsrc\|ferc\|pip\|fmod\|gem\|pipx\|node\|rustup\|cargo\)\>/ms=s+1
syntax match ZinitIceModifiers /\s\<\%(lbin\|lman\|submods\|binary\|null\|eval\|check\|desc\)\>/ms=s+1

" Additional Zsh and Zinit functions
syntax match ZshAndZinitFunctions     /\<\%(compdef\|compinit\|zpcdreplay\|zpcdclear\|zpcompinit\|zpcompdef\|OMZ\|OMZL\|OMZP\|zicompinit\|zicdreplay\|zicompinit_fast\)\>/

" Link
highlight def link ZshAndZinitFunctions    Keyword
highlight def link ZinitCommand            Statement
highlight def link ZinitSubCommands        Title
highlight def link ZinitPluginSubCommands  Title
highlight def link ZinitSnippetSubCommands Title
highlight def link ZinitIceModifiers       Type
highlight def link ZinitSnippetShorthands1 Keyword
highlight def link ZinitSnippetShorthands2 Keyword
highlight def link ZinitPlugin1            Macro
highlight def link ZinitPlugin2            Macro
highlight def link ZinitPlugin3            Macro
highlight def link ZinitSnippetUrl1        Macro
highlight def link ZinitSnippetUrl2        Macro
highlight def link ZinitSnippetUrl3        Macro
highlight def link ZinitSnippetUrl4        Macro
highlight def link ZinitTrailingWhiteSpace Error
