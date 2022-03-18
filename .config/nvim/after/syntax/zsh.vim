if polyglot#init#is_disabled(expand('<sfile>:p'), 'zinit', 'after/syntax/zsh.vim')
  finish
endif

" Copyright (c) 2019 Sebastian Gniazdowski
"
" Syntax highlighting for Zinit commands in any file of type `zsh'.
" It adds definitions for the Zinit syntax to the ones from the
" existing zsh.vim definitions-file.

" Main Zinit command.
" Should be the only TOP rule for the whole syntax.
syntax match ZinitCommand     /\<\(zinit\|zt\)\>\s/me=e-1
            \ skipwhite
            \ nextgroup=ZinitSubCommands,ZinitPluginSubCommands,ZinitSnippetSubCommands
            \ contains=ZinitSubCommands,ZinitPluginSubCommands,ZinitSnippetSubCommands

" TODO: add options for e.g. light
syntax match ZinitSubCommands /\s\<\%(ice\|compinit\|env-whitelist\|cdreplay\|cdclear\|update\|[0-9][a-c]\)\>\s/ms=s+1,me=e-1
            \ contained

syntax match ZinitPluginSubCommands /\s\<\%(light\|load\)\>\s/ms=s+1,me=e-1
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
syntax match ZinitSnippetShorthands1 /\s\<\%(\%(OMZ\|OMZL\|OMZP\|PZT\)\>::\|\)/hs=s+1,he=e-2
            \ contained
            \ skipwhite
            \ nextgroup=ZinitSnippetUrl1,ZinitSnippetUrl2
            \ contains=ZinitSnippetUrl1,ZinitSnippetUrl2

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
syntax match ZinitIceModifiers  /\s\<\%(svn\|proto\|from\|teleid\|bindmap\|cloneopts\|id-as\|depth\|if\|wait\|subst\|load\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(unload\|blockf\|on-update-of\|subscribe\|pick\|bpick\|src\|as\|ver\|silent\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(lucid\|notify\|mv\|cp\|atinit\|atclone\|atload\|atdelete\|atpull\|nocd\|run-atpull\|has\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(cloneonly\|make\|service\|trackbinds\|multisrc\|extract\|compile\|nocompile\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(nocompletions\|reset-prompt\|wrap-track\|reset\|aliases\|sh\|bash\|ksh\|csh\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(\\!sh\|!sh\|\\!bash\|!bash\|\\!ksh\|!ksh\|\\!csh\|!csh\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(blockf\|silent\|lucid\|trackbinds\|cloneonly\|nocd\|run-atpull\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(\|sh\|\!sh\|bash\|\!bash\|ksh\|\!ksh\|csh\|\!csh\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(nocompletions\|svn\|aliases\|trigger-load\)\>/ms=s+1
syntax match ZinitIceModifiers  /\s\<\%(light-mode\|is-snippet\|countdown\|ps-on-unload\|ps-on-update\)\>/ms=s+1

" Include also ices added by the existing annexes
syntax match ZinitIceModifiers  /\s\<\%(test\|zman\|submod\|dl\|patch\|fbin\|sbin\|fsrc\|ferc\|pip\|fmod\|gem\|node\|rustup\|cargo\)\>/ms=s+1
syntax match ZinitIceModifiers /\s\<\%(lbin\|lman\|submods\|binary\|null\|eval\|check\)\>/ms=s+1

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

" Add other zsh keywords that aren't added by default
syn keyword zshCommands += coproc zgetattr zsetattr zlistattr zdelattr zcurses strftime ztie zuntie zgdbmpath
  \ zf_chgrp zf_chmod zf_chown zf_ln zf_mkdir zf_mv zf_rm zf_rmdir zf_sync pcre_compile pcre_study pcre_match
  \ zstat syserror sysopen sysread sysseek syswrite zsystem systell zselect defer zsh-defer zsh abbr add-zsh-hook

syn keyword shStatement += sxhkd bspwm bspc
