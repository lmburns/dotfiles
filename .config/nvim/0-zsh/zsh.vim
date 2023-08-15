" Vim syntax file
" Language:             Zsh shell script
" Maintainer:           Christian Brabandt <cb@256bit.org>
" Previous Maintainer:  Nikolai Weibull <now@bitwi.se>
" Latest Revision:      2022-07-26
" License:              Vim (see :h license)
" Repository:           https://github.com/chrisbra/vim-zsh

" Maintainer:           Lucas Burns <burnsac@me.com> (of this file)
" Latest Revision:      2023-07-31
" History:
"   * custom partial rewrite, making it much more colorful

" TODO(1): highlight named file descriptors
"            exec {myfd}>~/logs/mylogfile.txt
"            print This is a log message. >&$myfd
"            exec {myfd}>&-
" TODO(2): highlight different escaped quotes
" TODO(3): highlight date interpolation
" TODO(4): highlight character classes
" TODO(5): highlight test flags [[ -t test ]]
" TODO(6): highlight var assignment inside ${}
"            ${a-b}  ${a+b}  ${a=b}   ${a?b}  ${a#b}  ${a%b}  ${a:^b}  ${a/b/c}  ${a:b}   ${a:#b}
"            ${a:-b} ${a:+b} ${a:=b}  ${a:?b} ${a##b} ${a%%b} ${a:^^b} ${a//b/c} ${a:b:c} ${a:|b}
"                            ${a::=b}                                  ${a:/b/c}          ${a:*b}
" TODO(7): highlight special vars
"        $@    $*    $#     $-     $!    $?    $$    $0
"        $#v   $+v   $~v    $^v    $=v
"        ${#v} ${+v} ${~v}  ${^v}  ${=v}
"                    ${~~v} ${^^v} ${==v}
" TODO(8): highlight builtin variables inside strings when they're prefixed as variables (i.e., $path)
" TODO(9): highlight builtin variables after unset keyword
" TODO(10): don't highlight zshCommands shCommands if they're vars
" FIX(12):  highlight glob pattern. # is not highlighted
" TODO(14): Add all glob qualifiers
" TODO(11): math expressions: $[...], let '...'
" TODO(13): highlights wrong echo $[ [#16_4] 42 ** 10 ]
" TODO(15): range operator

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

function! s:ContainedGroup()
    " needs 7.4.2008 for execute() function
    let result='TOP'
    " vim-pandoc syntax defines the @langname cluster for embedded syntax languages
    " However, if no syntax is defined yet, `syn list @zsh` will return
    " "No syntax items defined", so make sure the result is actually a valid syn cluster
    for cluster in ['markdownHighlight_zsh', 'zsh']
        try
            " markdown syntax defines embedded clusters as @markdownhighlight_<lang>,
            " pandoc just uses @<lang>, so check both for both clusters
            let a=split(execute('syn list @'. cluster), "\n")
            if len(a) == 2 && a[0] =~# '^---' && a[1] =~? cluster
                return  '@'. cluster
            endif
        catch /E392/
            " ignore
        endtry
    endfor
    return result
endfunction

let s:contained=s:ContainedGroup()

" If '-' is added, $a[-1] refuses to highlight number
syn iskeyword @,48-57,_,192-255,:,.,-,+
" syn iskeyword @,48-57,_,192-255,#,-
" syn iskeyword @,48-57,_,192-255,#,-,:,.
if get(g:, 'zsh_fold_enable', 0)
    setlocal foldmethod=syntax
endif

"  ╭──────────────────────────────────────────────────────────╮
"  │                         Strings                          │
"  ╰──────────────────────────────────────────────────────────╯

"  ╭────────────────╮
"  │ String Escapes │
"  ╰────────────────╯
syn match   zshQuoted           '\\.'
syn match   zshPOSIXQuoted      '\\[xX][0-9a-fA-F]\{1,2}'
syn match   zshPOSIXQuoted      '\\[0-7]\{1,3}'
syn match   zshPOSIXQuoted      '\\u[0-9a-fA-F]\{1,4}'
syn match   zshPOSIXQuoted      '\\U[1-9a-fA-F]\{1,8}'

" HERE(2): escaped quotes
" syn match   zshQuoted              '\\[abcfnrtv0e\\]'
" syn match   zshPOSIXQuotedHex      '\\[xX][0-9a-fA-F]\{1,2}'
" syn match   zshPOSIXQuotedOct      '\\[0-7]\{1,3}'
" syn match   zshPOSIXQuotedUni      '\\u[0-9a-fA-F]\{1,4}'
" syn match   zshPOSIXQuotedUni      '\\U[1-9a-fA-F]\{1,8}'
" syn cluster zshPOSIXQuoted         contains=zshPOSIXQuotedHex,zshPOSIXQuotedOct,zshPOSIXQuotedUni
"
"  ╭───────╮
"  │ Dates │
"  ╰───────╯
" HERE(3): date interpolation
" syn match zshStringEscDate
"     \ '\v\%D\{0|a|A|b|B|c|C|d|D|e|E|f|F|g|G|h|H|I|j|k|K|l|L|m|M|n|N|O|p|P|r|R|s|S|t|T|u|U|V|w|W|x|X|y|Y|z|Z|^|-|\.|_\%|#}'
" syn match zshStringEsc            '\v\%(\%|\)|l|M|n|y|#|\?|^|e|h|!|i|I|j|L|N|x|D|T|t|\@|\*|w|W)'
" syn match zshStringEsc            '\v\%(-=\d)=(m|d|\/|_|\~|c|\.|C)'
"
" syn match zshStringEsc          '\v\%(\%|\)|l|M|n|y|#|\?|^|e|h|!|i|I|j|L|N|x|D|T|t|\@|\*|w|W)'
" syn match zshStringEsc          '\v\%(-=\d)=(m|d|\/|_|\~|c|\.|C)'
" syn match zshStringEscDateOther '[^{}]' contained
" syn match zshStringEscDateChars '\v\%(0|\%|I|j|O|^|-|\.|_\%|#|\c[abcdefghklmnprstuwxyz])' contained
" syn match zshStringEscDate      '\v\%D\{((\%(\%|I|j|O|^|-|\.|_\%|#|\c[abcdefghklmnprstuwxyz]))|[^}])+}'
"     \ contains=zshStringEscDateChars,zshStringEscDateOther

" syn match zshStringEscDate      '\v\%D\{\zs[^}]+\ze}' contains=zshStringEscDateChars " %D{%H:%M:%S.%.}
" syn match zshStringEscDate      '\v\%D\{\zs[^}]+\ze}' contains=zshStringEscDateChars " %D{%H:%M:%S.%.}

" HERE(4): character classes
" syn match zshCharClass contained
"     \ "\[:\(backspace\|escape\|return\|xdigit\|alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|tab\):\]"

" syn region  zshString    start=+\z(["'`]\)+ skip=+\\\z1+ end=+\z1+ contains=@Spell
syn region  zshString       matchgroup=zshStringDelimiter start=+'+                      end=+'+
    \ contains=@Spell
    \ fold
syn region  zshString       matchgroup=zshStringDelimiter start='\%(\%(\\\\\)*\\\)\@<!"' end=+"+
    \ contains=@Spell,zshQuoted,@zshDerefs,@zshSubstQuoted,zshCtrlSeq,zshStringEsc,zshStringEscDate,zshPOSIXQuotedUni
    \ fold
syn region  zshPOSIXString  matchgroup=zshStringDelimiter start=+\$'+ skip=+\\[\\']+     end=+'+
    \ contains=zshPOSIXQuoted,zshQuoted

"  ╭──────────────────────────────────────────────────────────╮
"  │                          Number                          │
"  ╰──────────────────────────────────────────────────────────╯

" \%d   match specified decimal character (eg \%d123)
" \%x   match specified hex character (eg \%x2a)
" \%o   match specified octal character (eg \%o040)
" \%u   match specified multibyte character (eg \%u20ac)
" \%U   match specified large multibyte character (eg \%U12345678)
" \d    digit:                  [0-9]
" \D    non-digit:              [^0-9]
" \x    hex digit:              [0-9A-Fa-f]
" \X    non-hex digit:          [^0-9A-Fa-f]
" \o    octal digit:            [0-7]
" \O    non-octal digit:        [^0-7]

" syn match   zshNumber       '[+-]\=\<\d\+\>'
" syn match   zshNumber       '[+-]\=\<[0-9_]\+\>'
" syn match   zshNumber       '[+-]\=\<0x\x\+\>'
" syn match   zshNumber       '[+-]\=\<0\o\+\>'
" syn match   zshNumber       '[+-]\=\d\+#[-+]\=\w\+\>'
" syn match   zshNumber       '[+-]\=\d\+\.\d\+\>'

" syn match   zshNumber           '[+-]\=\<\d\+\>'
syn match zshNumber '\<[-+]\=[0-9_]\+\>'                " number:        44    4_000
syn match zshNumber '\<[-+]\=0x[[:xdigit:]_]\+\>'       " c_bases hex:   0xA0  0x1_000
syn match zshNumber '\<[-+]\=0[0-7_]\+\>'               " octal_zeroes: -077   01_000
syn match zshNumber '[-+]\=\d\+#[-+]\=[[:xdigit:]]\+\>' " octal/hex:     8#77  16#FF
syn match zshNumber '\<[-+]\=\d\+\.\d\+\>'              " decimal
" HERE(12): doesn't highlight #
syn match zshNumber '\[[#]\{1,2}[[:xdigit:]]\+\(_[[:xdigit:]]\)\=\>\]' contains=zshDelim
" \ containedin=zshMathSubst " $(( [##16] ))  $(( [#16] )) $(( [#16_4] ))

"  ╭──────────────────────────────────────────────────────────╮
"  │                         Operator                         │
"  ╰──────────────────────────────────────────────────────────╯

" syn match   zshOperator         '||\|&&\|;\|&!\='
syn match zshOperator     '+\{2}\|-\{2}\|!\|\~' " unary plus/minus, logical NOT, complement, {pre,post}{in,de}crement
syn match zshOperator     '<<\|>>' containedin=zshMathSubst " bitwise shift left, right
syn match zshOperator     '[&^|]' " bitwise AND XOR OR
" exponent, multiplication, division, modulus, add, subtract
syn match zshOperator     '*\{1,2}\|\/\|%\|\(-\|+\)\%(\d\+\)\@!' contained containedin=zshMathSubst
syn match zshOperator     '[<>]=\?' " comparison < > <= >=
syn match zshOperator     '[=!]=' " equality, inequality
syn match zshOperator     '\v%(\&\&|\|\||\^\^)' " logical AND OR XOR
syn match zshOperator     ';\|&!\=\|&|' " ; & &! &|
syn match zshOperator     '\%([-+*/%&^|]\|[<>&|^*]\{2}\)\==' skipwhite nextgroup=zshPattern " assignment (math only)

" logical AND OR XOR
syn match zshTernary          '[?:]\@1<![?:][?:]\@1!' contained
syn match zshSemicolon        ';'                     containedin=zshOperator
syn match zshLinewrapOperator '\\$'
" \S\@1<=::\S\@1=
syn match zshNamespaceSep     '\s\@1<!::\s\@1!' " path separator for funcs like `log::dump`

"  ╭──────╮
"  │ Flag │
"  ╰──────╯
" command --flag
syn match zshFlag     '\s\zs[-+][-_a-zA-Z0-9#@?]\+'
    \ containedin=zshBrackets,zshParentheses nextgroup=zshFlagEnd
" non-ascii --flags
syn match zshFlag     '\s\zs--[^ \t$=`'"|[]();]\+'
    \ containedin=zshBrackets,zshParentheses nextgroup=zshFlagEnd
" command -- extra_args
syn match zshFlagEnd   '\v[[:space:]]+\-\-[[:space:]]+'

" WHAT: ??
syn match zshPattern  '\<\S\+\())\)\@='  contained
    \ contains=@zshDerefs,@zshSubst,zshBrackets,zshQuoted,zshString,zshNumber

"  ╭───────────────╮
"  │ Test Operator │
"  ╰───────────────╯
" HERE(5): [[ -t test ]]
" syn match zshTestOperator '[=!]\==\|=\~\|-\(nt\|ot\|ef\|eq\|ne\|lt\|le\|ge\)\>\|[<>!]' " [[ x OPER pat ]] TODO: add contains
" syn match zshTestOperator '\v\s\zs-(a|b|c|d|e|f|g|h|k|n|p|r|s|u|v|w|x|z|L|O|G|S|N)>'
" syn match zshTestOperator '-t\>' nextgroup=zshNumber
" syn match zshTestOperator '-o\>' nextgroup=zshOption

" NOTE: This must be before zshPrecommand
syn keyword zshKeymapMode containedin=zshKeymapStart
    \ main emacs viins vicmd viopp visual isearch command .safe

"  ╭────────────╮
"  │ Precommand │
"  ╰────────────╯
syn keyword zshPrivilegedPrecommand sudo doas nextgroup=zshPrecommand,zshPrecommandOther,zshCommands,shCommands
syn keyword zshPrecommand           noglob nocorrect exec command builtin - time nextgroup=zshCommands,shCommands,zshOptKeyword
syn keyword zshPrecommandOther      xargs env nohup nice nextgroup=zshCommands,shCommands

"  ╭──────────────────────────────────────────────────────────╮
"  │                       Control Flow                       │
"  ╰──────────────────────────────────────────────────────────╯

syn keyword zshDelimiter   do done end nextgroup=zshSemicolon,zshRedir,zshLinewrapOperator
syn keyword zshConditional if then elif else fi select

" syn keyword zshCase        case nextgroup=zshCaseWord skipwhite
" syn match zshCaseWord      /\S\+/ nextgroup=zshCaseIn skipwhite contained transparent
" syn keyword zshCaseIn      in nextgroup=zshCasePattern skipwhite skipnl contained
" syn match zshCasePattern   /(\=\zs\S[^)]*\ze)/ contained contains=zshParenthesis
" syn match zshCaseEnd       ';[;&|]' nextgroup=zshCasePattern skipwhite skipnl

syn keyword zshCase         case nextgroup=zshCaseWord skipwhite
syn match   zshCaseWord     /\S\+/ nextgroup=zshCaseIn skipwhite contained transparent
syn keyword zshCaseIn       in nextgroup=zshCasePattern,zshComment skipwhite skipnl contained
syn match   zshCasePattern  /(\=\zs[^)]*\s*\ze)/ contained skipwhite contains=zshDelim,@zshDerefs,zshOperator,zshNumber,@zshSubst,zshString
syn match   zshCaseEnd      ';[;&|]' nextgroup=zshCasePattern,zshComment,zshCaseEsac skipwhite skipnl
syn keyword zshCaseEsac     esac skipwhite

syn keyword zshException   always
syn keyword zshKeyword     function nextgroup=zshKSHFunction skipwhite
syn keyword zshRepeat      while until repeat

syn keyword zshRepeat      for foreach nextgroup=zshRepeatVar,zshRepeatC skipwhite
syn match   zshRepeatVar   '\<\h\w*'  nextgroup=zshRepeatVar,zshRepeatIn contains=@zshDerefs,zshVariable skipwhite contained
syn keyword zshRepeatIn    in
syn region  zshRepeatC     contained transparent start='\%(\$\?\)[<=>]\@<!((' end='))'

" syn region zshFor
"       \ start="\<\(for\|foreach\)\_s\s*\%(((\)\@!"
"       \ end="\<in\>"me=e-2
"       \ end="\<do\>"me=e-2
"       \ end="{"me=e-1
"       \ skipwhite contains=zshRepeat,zshDelimiter
"
" syn region zshForAlt matchgroup=zshRepeat
"       \ start='\<\(for\|foreach\)\>\_s*(('
"       \ end='))'

" syn match   zshKSHFunction      contained '\w\S\+'
" syn match   zshFunction         '^\s*\k\+\ze\s*()'

" My modification to allow for functions that start with or contain [:→.@+-]
syn match   zshKSHFunction      contained '\(\w\|[:∞→.@+-/]\)\S\+'
syn match   zshFunction         '^\s*\(\k\|[:∞→.@+-/]\)\+\ze\s*()'

"  ╭──────────────────────────────────────────────────────────╮
"  │                       Redirection                        │
"  ╰──────────────────────────────────────────────────────────╯

" HERE(1): file descriptors
" <<<, <, <>, and variants. Not followed by digit- (i.e., not <0->)
syn match   zshRedir            '\d\=\%(<<<\|<&\s*[0-9p-]\=\|<\%(\d\+-\%(\d\+\)\?>\)\@!\|<>\)'
" >, >>, and variants.
syn match   zshRedir            '\d\=\%(>&\s*[0-9p-]\=\|&>>\?\|\%(\d\+-\%(\d\+\)\)&\?\)\@<!\%(>\%(=\)\@1!>\?\)[|!]\='
" | and |&, but only if it's not preceeded or followed by a | to avoid matching ||.
syn match   zshRedir            '|\@1<!|&\=|\@!'

syn region  zshHereDoc          matchgroup=zshRedir
    \ start='<\@<!<<\s*\z([^<]\S*\)'
    \ end='^\z1$'
    \ contains=@Spell,@zshSubst,@zshDerefs,zshQuoted,zshPOSIXString
syn region  zshHereDoc          matchgroup=zshRedir
    \ start='<\@<!<<\s*\\\z(\S\+\)'
    \ end='^\z1$'
    \ contains=@Spell
syn region  zshHereDoc          matchgroup=zshRedir
    \ start='<\@<!<<-\s*\\\=\z(\S\+\)'
    \ end='^\t*\z1$'
    \ contains=@Spell
syn region  zshHereDoc          matchgroup=zshRedir
    \ start=+<\@<!<<\s*\(["']\)\z(\S\+\)\1+
    \ end='^\z1$'
    \ contains=@Spell
syn region  zshHereDoc          matchgroup=zshRedir
    \ start=+<\@<!<<-\s*\(["']\)\z(\S\+\)\1+
    \ end='^\t*\z1$'
    \ contains=@Spell

"  ╭──────────────────────────────────────────────────────────╮
"  │                         Variable                         │
"  ╰──────────────────────────────────────────────────────────╯

syn match zshVariable      '\<\h\(\w\|[.:∞→.@+-/]\)*'         contained nextgroup=zshVariable
" = += -= *= /= %= &= ˆ= |= <<= >>= &&= ||= ˆˆ= **=
syn match zshVariableDef   '\<\h\(\w\|[.:∞→.@+-/]\)*\ze\%([-+*/%&^|]\|<<\|>>\|&&\|||\|^^\|\*\*\)\==' nextgroup=zshVarAssign contains=zshOperator

" var[idx]+=
syn region  zshVariableDef             oneline
    \ start='\(\${\=\)\@<!\<\h\w*\['   end='\]\ze\%([-+*/%&^|]\|<<\|>>\|&&\|||\|^^\|\*\*\)\==\='
    \ contains=@zshSubst,@zshBuiltins,zshOperator  nextgroup=zshVarAssign

syn cluster zshDerefs     contains=zshShortDeref,@zshBuiltins,zshDeref,zshDollarVar
syn match zshShortDeref   '\$[!#$*@?_-]\w\@!'
syn match zshShortDeref   '\$[=^~]*[#+]*\d\+\>'
syn match zshVarAssign    '+\==' contained

" HERE(6): highlight var assignment inside ${}
" HERE(7): highlight special vars $~v ${~v} ${~~v}
" HERE(8): highlight builtin variables inside strings
" HERE(9): highlight builtin variables after unset keyword
" HERE(10): don't highlight zshCommands shCommands if they're vars

syn keyword zshBuiltinVar PATH FPATH MANPATH INFOPATH CDPATH MAILPATH LIBRARY_PATH
syn keyword zshBuiltinArr path fpath manpath infopath cdpath mailpath
syn keyword zshBuiltinVar ARGC ARGV0 ERRNO
syn keyword zshBuiltinArr argv syn keyword zshBuiltinVar status pipestatus signals errnos sysparams
syn keyword zshBuiltinVar PWD OLDPWD OPTARG OPTIND PPID RANDOM SECONDS ZBEEP
syn keyword zshBuiltinVar IFS COLUMNS LINES LINENO BAUD REPORTMEMORY REPORTTIME
syn keyword zshBuiltinVar FCEDIT FIGNORE
syn keyword zshBuiltinArr fignore
syn keyword zshBuiltinVar TRY_BLOCK_ERROR TRY_BLOCK_INTERRUPT PERIOD MAIL MAILCHECK
syn keyword zshBuiltinVar watch LOGCHECK WATCHFMT
syn keyword zshBuiltinVar MATCH MBEGIN MEND REPLY
syn keyword zshBuiltinArr match mbegin mend reply

syn keyword zshBuiltinVar TTY TTYIDLE STTY CPUTYPE MACHTYPE OSTYPE VENDOR TERMINFO TERMINFO_DIRS
syn keyword zshBuiltinVar HOME ZDOTDIR USERNAME USER HOST LOGNAME UID EUID EGID GID
syn keyword zshBuiltinVar TERM BROWSER SHELL EDITOR VISUAL ENV
syn keyword zshBuiltinVar LANG LC_ALL LC_COLLATE LC_CTYPE LC_CTYPE LC_MESSAGES LC_NUMERIC LC_NUMERIC
syn keyword zshBuiltinVar ZSH_NAME ZSH_VERSION ZSH_SCRIPT ZSH_SUBSHELL ZSH_EXECUTION_STRING ZSH_ARGZERO ZSH_PATCHLEVEL
syn keyword zshBuiltinArr zsh_defer_options zsh_loaded_plugins zsh_eval_context zsh_scheduled_events

syn keyword zshBuiltinVar LISTMAX NULLCMD READNULLCMD TMPPREFIX TMPSUFFIX TMPDIR TIMEFMT TMOUT
syn keyword zshBuiltinVar SAVEHIST HISTSIZE HISTFILE HIST_STAMPS HISTCHARS HISTORY_IGNORE HISTCMD
syn keyword zshBuiltinArr histchars history historywords
syn keyword zshBuiltinVar CORRECT_IGNORE CORRECT_IGNORE_FILE

" ZLE
syn keyword zshBuiltinVar ZLE_REMOVE_SUFFIX_CHARS ZLE_SPACE_SUFFIX_CHARS ZLE_LINE_ABORTED
syn keyword zshBuiltinVar NUMERIC KEYMAP KEYTIMEOUT WORDCHARS KEYS KEYS_QUEUED_COUNT POSTEDIT
syn keyword zshBuiltinVar BUFFER BUFFERLINES LBUFFER RBUFFER PREBUFFER CURSOR MARK REGION_ACTIVE
syn keyword zshBuiltinVar YANK_ACTIVE YANK_START YANK_END PENDING LASTABORTEDSEARCH
syn keyword zshBuiltinVar LASTSEARCH PREDISPLAY POSTDISPLAY LASTWIDGET WIDGET WIDGETFUNC WIDGETSTYLE
syn keyword zshBuiltinVar ZLE_RECURSIVE ZLE_STATE CUTBUFFER HISTNO UNDO_CHANGE_NO UNDO_LIMIT_NO
syn keyword zshBuiltinArr killring registers keymaps widgets zle_highlight

" COMPLETION
syn keyword zshBuiltinVar CURRENT IPREFIX ISUFFIX PREFIX QIPREFIX QISUFFIX SUFFIX
syn keyword zshBuiltinVar PROMPT PROMPT2 PROMPT3 PROMPT4 prompt RPROMPT RPROMPT2 SPROMPT PROMPT_EOL_MARK
syn keyword zshBuiltinVar PS1 PS2 PS3 PS4 psvar RPS1 RPS2

" CONTAINERS
syn keyword zshBuiltinArr dirstack nameddirs userdirs usergroups
syn keyword zshBuiltinArr options commands parameters modules jobdirs jobtexts jobstates
syn keyword zshBuiltinArr dis_functions dis_functions_source
syn keyword zshBuiltinArr functions functions_source funcfiletrace funcsourcetrace functrace funcstack
syn keyword zshBuiltinArr aliases     galiases     saliases      builtins      reswords     patchars
syn keyword zshBuiltinArr dis_aliases dis_galiases dis_saliases  dis_builtins  dis_reswords dis_patchars
syn keyword zshBuiltinVar FUNCNEST SHLVL DIRSTACKSIZE

" CUSTOM
syn keyword zshBuiltinArr histignore

" ZPFX ZSH_CACHE_DIR
" COPROC FUNCNAME
" GROUPS HOSTFILE HOSTNAME HOSTTYPE IFS IGNOREEOF INPUTRC

syn cluster zshBuiltins contains=zshBuiltinArr,zshBuiltinVar

syn match zshDollarVar        '\$\h\w*'
syn match zshDeref            '\$[=^~]*[#+]*\h\w*\>'

syn match   zshCommands         '\%(^\|\s\)[.:]\ze\s'  " matches source (.) and (:)
syn keyword zshCommands
    \ alias        autoload     bg          bindkey       break      bye      cap
    \ cd           chdir        clone       comparguments compcall   compctl
    \ compdescribe compfiles    compgroups  compquote     comptags   comptry
    \ compvalues   continue     dirs        disable       disown     echo
    \ echotc       echoti       emulate     enable        eval       exec
    \ exit         export       false       fc            fg         functions
    \ getcap       getln        getopts     hash          history    jobs
    \ kill         let          limit       log           logout     popd
    \ print        printf       prompt      pushd         pushln     pwd
    \ r            read         rehash      return        sched      set
    \ setcap       shift        source      stat          suspend    test
    \ times        trap         true        ttyctl        type       ulimit
    \ umask        unalias      unfunction  unhash        unlimit    unset
    \ vared        wait         whence      where         which      zcompile
    \ zformat      zftp         zle         zmodload      zparseopts zprof
    \ zpty         zrecompile   zregexparse zsocket       zstyle     ztcp
    \ coproc       zgetattr     zsetattr    zlistattr     zdelattr   zcurses
    \ strftime     ztie         zuntie      zgdbmpath     zf_chgrp   zf_chmod
    \ zf_chown     zf_ln        zf_mkdir    zf_mv         zf_rm      zf_rmdir
    \ zf_sync      pcre_compile pcre_study  pcre_match    zstat      syserror
    \ sysopen      sysread      sysseek     syswrite      zsystem    systell
    \ zselect      defer        zsh         abbr          ztodo      after
    \ compinit     compdef      allopt      zed           zcalc      before
    \ catch        throw        cdr         colors
    \ compaudit    compdump     compinstall bashcompinit
    \ keeper       xtermctl     mere        calendar
    \ add-zle-hook-widget           backward-kill-word-match      backward-word-match
    \ bracketed-paste-magic         bracketed-paste-url-magic     calendar_edit
    \ calendar_lockfiles            calendar_parse                calendar_read
    \ calendar_scandate             calendar_show                 calendar_showdate
    \ calendar_sort                 capitalize-word-match         copy-earlier-word
    \ chpwd_recent_add              chpwd_recent_dirs             chpwd_recent_filehandler
    \ cycle-completion-positions    define-composed-chars         delete-whole-word-match
    \ down-case-word-match          down-line-or-beginning-search edit-command-line
    \ expand-absolute-path          forward-word-match            getjobs
    \ history-beginning-search-menu history-pattern-search        history-search-end
    \ incarg                        incremental-complete-word     insert-composed-char
    \ insert-files                  insert-unicode-char           is-at-least
    \ keymap+widget                 kill-word-match               match-word-context
    \ match-words-by-style          modify-current-argument
    \ move-line-in-buffer           narrow-to-region              narrow-to-region-invisible
    \ nslookup                      pick-web-browser              predict-on
    \ prompt_adam1_setup            prompt_adam2_setup            prompt_bart_setup
    \ prompt_bigfade_setup          prompt_clint_setup            prompt_default_setup
    \ prompt_elite2_setup           prompt_elite_setup            prompt_fade_setup
    \ prompt_fire_setup             prompt_off_setup              prompt_oliver_setup
    \ prompt_pws_setup              prompt_redhat_setup           prompt_restore_setup
    \ prompt_special_chars          prompt_suse_setup             prompt_walters_setup
    \ prompt_zefram_setup           promptinit                    promptnl               quote-and-complete-word
    \ read-from-minibuffer          regexp-replace                relative               replace-argument
    \ replace-string                replace-string-again          run-help-git           run-help-openssl
    \ run-help-p4                   run-help-sudo                 run-help-svk           run-help-svn
    \ select-quoted                 select-word-match             select-word-style
    \ send-invisible                select-bracketed              smart-insert-last-word split-shell-arguments
    \ surround                      tcp_alias                     tcp_close
    \ tcp_command                   tcp_expect                    tcp_fd_handler         tcp_log
    \ tcp_open                      tcp_output                    tcp_point              tcp_proxy
    \ tcp_read                      tcp_rename                    tcp_send               tcp_sess
    \ tcp_shoot                     tcp_spam                      tcp_talk               tcp_wait
    \ tetris                        tetriscurses                  transpose-lines        transpose-words-match
    \ up-case-word-match            up-line-or-beginning-search   url-quote-magic        vcs_info
    \ vcs_info_hookadd              vcs_info_hookdel              vcs_info_lastmsg       vcs_info_printsys
    \ vcs_info_setsys               vi-pipe                       which-command
    \ zargs                         zcalc-auto-insert             zed-set-file-name      zfanon
    \ zfautocheck                   zfcd                          zfcd_match             zfcget
    \ zfdir                         zffcache                      zfgcp                  zfget
    \ zfget_match                   zfgoto                        zfhere                 zfinit
    \ zfls                          zfmark                        zfclose                zfcput
    \ zfopen                        zfparams                      zfpcp                  zfput
    \ zfrglob                       zfrtime                       zfsession              zfstat          zftp_chpwd
    \ zftp_progress                 zftransfer                    zftype                 zfuget
    \ zfuput                        zmathfunc                     zmathfuncdef           zmv
    \ zsh-mime-contexts             zsh-mime-handler              zsh-mime-setup
    \ zsh-newuser-install           zsh_directory_name_cdr        zsh_directory_name_generic
    \ zstyle+                       zsh-defer                     add-zsh-hook

syn keyword shCommands
    \ clear    less      cat     expr
    \ cp       mv        rm      rmdir
    \ b2sum    base32    base64  md5sum   cksum    sha1sum sha2  basenc
    \ basename bash      zsh     sh
    \ chcon    chgrp     chown   chmod    chroot
    \ column   comm      csplit  curl
    \ cut      date      dd      df       du
    \ dir      dircolors dirname
    \ expand   factor    fmt
    \ fold     join      cut     hck
    \ groups   users     uname   who      whoami
    \ hostid   hostname  arch    id
    \ hugo     install   hexdump defaults
    \ killall  logname
    \ head     tail      daemonize
    \ sleep    strip     shred   shuf
    \ link     ln        unlink
    \ mkdir    mkfifo    mknod   mktemp
    \ nl       nproc     numfmt
    \ od       open      paste   pr
    \ printenv printf    ptx
    \ readlink realpath  pathchk
    \ runcon   scutil    seq
    \ split    stat      stdbuf  stty     tty
    \ sum      sync      tac     tee      terminfo
    \ timeout  touch     tput
    \ tr       truncate  sort    tsort
    \ unexpand uniq      uptime  vdir     wc
    \ vim      nvim      vi      ed
    \ tmux     top      htop
    \ git
    \ brew     npm       pacman  rpm
    \ yes      no
    \ yabai    sxhkd     bspwm   bspc
    \ grep     egrep     fgrep   pgrep    vgrep    ugrep   ngrep
    \ find     ls        exa     fd       rg
    \ perl     ruby      awk     sed
    \ gcc

syn match zshKeymapStart
    \ /\v%(builtin\s+)?bindkey\ze\s+.+/
    \ transparent skipwhite
    \ contains=zshKeymapMode,zshCommands,zshFlag,zshPrecommand,@zshSubst,zshSubstQuoted,zshDelim,@zshDerefs

" syn match zshKeymapStart
"           \ /\v^\s*%(builtin\s+)?bindkey\s+%(%(-\a{1,3}\s+){,3}%([[:print:]]+\s+){,2}){,2}/
"           \ skipwhite contains=zshKeymapMode,zshCommands,zshFlag,zshPrecommand,@zshSubst,zshSubstQuoted,zshDelim,@zshDerefs

syn case ignore

syn keyword zshOptKeyword set unset setopt unsetopt nextgroup=zshOption contained
" \ /\v^\s*%(builtin\s+)?\zs%(%(un)?setopt|%(set|emulate\s+%(-[LR]{1,2}\s+)?zsh)\s+[-+]o)/
syn match   zshOptStart
    \ /\v%(%(un)?setopt|%(set|emulate\s+%(-[LR]{1,2}\s+)?zsh)\s+[-+]o)/
    \ nextgroup=zshOption transparent skipwhite contains=zshOptKeyword,zshCommands,zshFlag
syn match   zshOptionMultiLine '\\$\n' contains=zshLinewrapOperator nextgroup=zshOption skipwhite contained
syn keyword zshOption nextgroup=zshOption,zshComment,zshOptionMultiLine,zshOptionCont   skipwhite contained
    \ auto_cd no_auto_cd autocd noautocd auto_pushd no_auto_pushd autopushd noautopushd cdable_vars
    \ no_cdable_vars cdablevars nocdablevars cd_silent no_cd_silent cdsilent nocdsilent chase_dots
    \ no_chase_dots chasedots nochasedots chase_links no_chase_links chaselinks nochaselinks posix_cd
    \ posixcd no_posix_cd noposixcd pushd_ignore_dups no_pushd_ignore_dups pushdignoredups
    \ nopushdignoredups pushd_minus no_pushd_minus pushdminus nopushdminus pushd_silent no_pushd_silent
    \ pushdsilent nopushdsilent pushd_to_home no_pushd_to_home pushdtohome nopushdtohome
    \ always_last_prompt no_always_last_prompt alwayslastprompt noalwayslastprompt always_to_end
    \ no_always_to_end alwaystoend noalwaystoend auto_list no_auto_list autolist noautolist auto_menu
    \ no_auto_menu automenu noautomenu auto_name_dirs no_auto_name_dirs autonamedirs noautonamedirs
    \ auto_param_keys no_auto_param_keys autoparamkeys noautoparamkeys auto_param_slash
    \ no_auto_param_slash autoparamslash noautoparamslash auto_remove_slash no_auto_remove_slash
    \ autoremoveslash noautoremoveslash bash_auto_list no_bash_auto_list bashautolist nobashautolist
    \ complete_aliases no_complete_aliases completealiases nocompletealiases complete_in_word
    \ no_complete_in_word completeinword nocompleteinword glob_complete no_glob_complete globcomplete
    \ noglobcomplete hash_list_all no_hash_list_all hashlistall nohashlistall list_ambiguous
    \ no_list_ambiguous listambiguous nolistambiguous list_beep no_list_beep listbeep nolistbeep
    \ list_packed no_list_packed listpacked nolistpacked list_rows_first no_list_rows_first listrowsfirst
    \ nolistrowsfirst list_types no_list_types listtypes nolisttypes menu_complete no_menu_complete
    \ menucomplete nomenucomplete rec_exact no_rec_exact recexact norecexact bad_pattern no_bad_pattern
    \ badpattern nobadpattern bare_glob_qual no_bare_glob_qual bareglobqual nobareglobqual brace_ccl
    \ no_brace_ccl braceccl nobraceccl case_glob no_case_glob caseglob nocaseglob case_match
    \ no_case_match casematch nocasematch case_paths no_case_paths casepaths nocasepaths csh_null_glob
    \ no_csh_null_glob cshnullglob nocshnullglob equals no_equals noequals extended_glob no_extended_glob
    \ extendedglob noextendedglob force_float no_force_float forcefloat noforcefloat glob no_glob noglob
    \ glob_assign no_glob_assign globassign noglobassign glob_dots no_glob_dots globdots noglobdots
    \ glob_star_short no_glob_star_short globstarshort noglobstarshort glob_subst no_glob_subst globsubst
    \ noglobsubst hist_subst_pattern no_hist_subst_pattern histsubstpattern nohistsubstpattern
    \ ignore_braces no_ignore_braces ignorebraces noignorebraces ignore_close_braces
    \ no_ignore_close_braces ignoreclosebraces noignoreclosebraces ksh_glob no_ksh_glob kshglob nokshglob
    \ magic_equal_subst no_magic_equal_subst magicequalsubst nomagicequalsubst mark_dirs no_mark_dirs
    \ markdirs nomarkdirs multibyte no_multibyte nomultibyte nomatch no_nomatch nonomatch null_glob
    \ no_null_glob nullglob nonullglob numeric_glob_sort no_numeric_glob_sort numericglobsort
    \ nonumericglobsort rc_expand_param no_rc_expand_param rcexpandparam norcexpandparam rematch_pcre
    \ no_rematch_pcre rematchpcre norematchpcre sh_glob no_sh_glob shglob noshglob unset no_unset nounset
    \ warn_create_global no_warn_create_global warncreateglobal nowarncreateglobal warn_nested_var
    \ no_warn_nested_var warnnestedvar no_warnnestedvar append_history no_append_history appendhistory
    \ noappendhistory bang_hist no_bang_hist banghist nobanghist extended_history no_extended_history
    \ extendedhistory noextendedhistory hist_allow_clobber no_hist_allow_clobber histallowclobber
    \ nohistallowclobber hist_beep no_hist_beep histbeep nohistbeep hist_expire_dups_first
    \ no_hist_expire_dups_first histexpiredupsfirst nohistexpiredupsfirst hist_fcntl_lock
    \ no_hist_fcntl_lock histfcntllock nohistfcntllock hist_find_no_dups no_hist_find_no_dups
    \ histfindnodups nohistfindnodups hist_ignore_all_dups no_hist_ignore_all_dups histignorealldups
    \ nohistignorealldups hist_ignore_dups no_hist_ignore_dups histignoredups nohistignoredups
    \ hist_ignore_space no_hist_ignore_space histignorespace nohistignorespace hist_lex_words
    \ no_hist_lex_words histlexwords nohistlexwords hist_no_functions no_hist_no_functions
    \ histnofunctions nohistnofunctions hist_no_store no_hist_no_store histnostore nohistnostore
    \ hist_reduce_blanks no_hist_reduce_blanks histreduceblanks nohistreduceblanks hist_save_by_copy
    \ no_hist_save_by_copy histsavebycopy nohistsavebycopy hist_save_no_dups no_hist_save_no_dups
    \ histsavenodups nohistsavenodups hist_verify no_hist_verify histverify nohistverify
    \ inc_append_history no_inc_append_history incappendhistory noincappendhistory
    \ inc_append_history_time no_inc_append_history_time incappendhistorytime noincappendhistorytime
    \ share_history no_share_history sharehistory nosharehistory all_export no_all_export allexport
    \ noallexport global_export no_global_export globalexport noglobalexport global_rcs no_global_rcs
    \ globalrcs noglobalrcs rcs no_rcs norcs aliases no_aliases noaliases clobber no_clobber noclobber
    \ clobber_empty no_clobber_empty clobberempty noclobberempty correct no_correct nocorrect correct_all
    \ no_correct_all correctall nocorrectall dvorak no_dvorak nodvorak flow_control no_flow_control
    \ flowcontrol noflowcontrol ignore_eof no_ignore_eof ignoreeof noignoreeof interactive_comments
    \ no_interactive_comments interactivecomments nointeractivecomments hash_cmds no_hash_cmds hashcmds
    \ nohashcmds hash_dirs no_hash_dirs hashdirs nohashdirs hash_executables_only
    \ no_hash_executables_only hashexecutablesonly nohashexecutablesonly mail_warning no_mail_warning
    \ mailwarning nomailwarning path_dirs no_path_dirs pathdirs nopathdirs path_script no_path_script
    \ pathscript nopathscript print_eight_bit no_print_eight_bit printeightbit noprinteightbit
    \ print_exit_value no_print_exit_value printexitvalue noprintexitvalue rc_quotes no_rc_quotes
    \ rcquotes norcquotes rm_star_silent no_rm_star_silent rmstarsilent normstarsilent rm_star_wait
    \ no_rm_star_wait rmstarwait normstarwait short_loops no_short_loops shortloops noshortloops
    \ short_repeat no_short_repeat shortrepeat noshortrepeat sun_keyboard_hack no_sun_keyboard_hack
    \ sunkeyboardhack nosunkeyboardhack auto_continue no_auto_continue autocontinue noautocontinue
    \ auto_resume no_auto_resume autoresume noautoresume bg_nice no_bg_nice bgnice nobgnice check_jobs
    \ no_check_jobs checkjobs nocheckjobs check_running_jobs no_check_running_jobs checkrunningjobs
    \ nocheckrunningjobs hup no_hup nohup long_list_jobs no_long_list_jobs longlistjobs nolonglistjobs
    \ monitor no_monitor nomonitor notify no_notify nonotify posix_jobs posixjobs no_posix_jobs
    \ noposixjobs prompt_bang no_prompt_bang promptbang nopromptbang prompt_cr no_prompt_cr promptcr
    \ nopromptcr prompt_sp no_prompt_sp promptsp nopromptsp prompt_percent no_prompt_percent
    \ promptpercent nopromptpercent prompt_subst no_prompt_subst promptsubst nopromptsubst
    \ transient_rprompt no_transient_rprompt transientrprompt notransientrprompt alias_func_def
    \ no_alias_func_def aliasfuncdef noaliasfuncdef c_bases no_c_bases cbases nocbases c_precedences
    \ no_c_precedences cprecedences nocprecedences debug_before_cmd no_debug_before_cmd debugbeforecmd
    \ nodebugbeforecmd err_exit no_err_exit errexit noerrexit err_return no_err_return errreturn
    \ noerrreturn eval_lineno no_eval_lineno evallineno noevallineno exec no_exec noexec function_argzero
    \ no_function_argzero functionargzero nofunctionargzero local_loops no_local_loops localloops
    \ nolocalloops local_options no_local_options localoptions nolocaloptions local_patterns
    \ no_local_patterns localpatterns nolocalpatterns local_traps no_local_traps localtraps nolocaltraps
    \ multi_func_def no_multi_func_def multifuncdef nomultifuncdef multios no_multios nomultios
    \ octal_zeroes no_octal_zeroes octalzeroes nooctalzeroes pipe_fail no_pipe_fail pipefail nopipefail
    \ source_trace no_source_trace sourcetrace nosourcetrace typeset_silent no_typeset_silent
    \ typesetsilent notypesetsilent typeset_to_unset no_typeset_to_unset typesettounset notypesettounset
    \ verbose no_verbose noverbose xtrace no_xtrace noxtrace append_create no_append_create appendcreate
    \ noappendcreate bash_rematch no_bash_rematch bashrematch nobashrematch bsd_echo no_bsd_echo bsdecho
    \ nobsdecho continue_on_error no_continue_on_error continueonerror nocontinueonerror
    \ csh_junkie_history no_csh_junkie_history cshjunkiehistory nocshjunkiehistory csh_junkie_loops
    \ no_csh_junkie_loops cshjunkieloops nocshjunkieloops csh_junkie_quotes no_csh_junkie_quotes
    \ cshjunkiequotes nocshjunkiequotes csh_nullcmd no_csh_nullcmd cshnullcmd nocshnullcmd ksh_arrays
    \ no_ksh_arrays ksharrays noksharrays ksh_autoload no_ksh_autoload kshautoload nokshautoload
    \ ksh_option_print no_ksh_option_print kshoptionprint nokshoptionprint ksh_typeset no_ksh_typeset
    \ kshtypeset nokshtypeset ksh_zero_subscript no_ksh_zero_subscript kshzerosubscript
    \ nokshzerosubscript posix_aliases no_posix_aliases posixaliases noposixaliases posix_argzero
    \ no_posix_argzero posixargzero noposixargzero posix_builtins no_posix_builtins posixbuiltins
    \ noposixbuiltins posix_identifiers no_posix_identifiers posixidentifiers noposixidentifiers
    \ posix_strings no_posix_strings posixstrings noposixstrings posix_traps no_posix_traps posixtraps
    \ noposixtraps sh_file_expansion no_sh_file_expansion shfileexpansion noshfileexpansion sh_nullcmd
    \ no_sh_nullcmd shnullcmd noshnullcmd sh_option_letters no_sh_option_letters shoptionletters
    \ noshoptionletters sh_word_split no_sh_word_split shwordsplit noshwordsplit traps_async
    \ no_traps_async trapsasync notrapsasync interactive no_interactive nointeractive login no_login
    \ nologin privileged no_privileged noprivileged restricted no_restricted norestricted shin_stdin
    \ no_shin_stdin shinstdin noshinstdin single_command no_single_command singlecommand nosinglecommand
    \ beep no_beep nobeep combining_chars no_combining_chars combiningchars nocombiningchars emacs
    \ no_emacs noemacs overstrike no_overstrike nooverstrike single_line_zle no_single_line_zle
    \ singlelinezle nosinglelinezle vi no_vi novi zle no_zle nozle brace_expand no_brace_expand
    \ braceexpand nobraceexpand dot_glob no_dot_glob dotglob nodotglob hash_all no_hash_all hashall
    \ nohashall hist_append no_hist_append histappend nohistappend hist_expand no_hist_expand histexpand
    \ nohistexpand log no_log nolog mail_warn no_mail_warn mailwarn nomailwarn one_cmd no_one_cmd onecmd
    \ noonecmd physical no_physical nophysical prompt_vars no_prompt_vars promptvars nopromptvars stdin
    \ no_stdin nostdin track_all no_track_all trackall notrackall

syn case match

syn keyword zshTypes            float integer local typeset declare private readonly
syn match zshConstant           '\v/dev/\w+'
syn match zshJobSpec            '%\(\d\+\|?\=\w\+\|[%+-]\)'

syn cluster zshSubst            contains=zshSubst,zshOldSubst,zshMathSubst
" NOTE: zshMathSubst here causes problems "'((...))'"
"       equals=$(( ${lf_ratios##*:} == 3 ? (($COLUMNS * 3/6) - ($#class + 2)) / 2 : 18 ))
"       tmp_mode=$(( ( mode % $#histdb_fzf_modes ) + 1 ))

syn cluster zshSubstQuoted      contains=zshSubstQuoted,zshOldSubst,zshMathSubst
exe 'syn region  zshSubst '
    \ . 'matchgroup=zshSubstDelim transparent start=/\$(\%((\)\@1!/ skip=/\\)/ end=/)\%()\)\@1!/ contains='
    \ . s:contained . ' fold'
exe 'syn region  zshSubstQuoted '
    \ . 'matchgroup=zshSubstDelim transparent start=/\$(\%((\)\@1!/ skip=/\\)/ end=/)\%()\)\@1!/ contains='
    \ . s:contained . '  fold'
syn region  zshSubstQuoted      matchgroup=zshSubstDelim
    \ start='\${' skip='\\}' end='}'
    \ contains=@zshSubst,zshBrackets,zshQuoted,zshNumber,zshDelim,zshGlob fold

" syn region  zshGlob             start='(#' end=')'
" syn region  zshDblParenthesis   matchgroup=Operator start="((" end="))" contained contains=zshParentheses
" syn match   zshParenthesis      '(\zs[^]]\{-}\ze)' transparent contained contains=zshDelim

syn region  zshParentheses      start='(' skip='\\)' end=')' contained
" HERE(11): $[...], let '...'

" syn match zshMathSubstInner     '\%(\$\?\)[<=>]\@<!((.\{-}\(\\\)\@1!))' contains=zshDelim contained transparent
" syn region  zshMathSubstInner   matchgroup=zshSubstDelim transparent
"                                 \ start='\%(\$\?\)[<=>]\@<!((' skip='\\)' end='))'
"                                 \ contains=@zshSubst,zshNumber,
"                                 \ @zshDerefs,zshString,zshOperator,zshTernary,zshDelim fold

" syn match zshMathSubstDelim     '\$((\|))' contained
" syn match zshMathSubst          '\%(\$\?\)[<=>]\@<!((.*\(\\\)\@1!))'
"                                 \ transparent
"                                 \ contains=zshMathSubstDelim,@zshSubst,zshNumber,
"                                 \ @zshDerefs,zshString,zshOperator,zshTernary,zshDelim fold

syn region  zshMathSubst        matchgroup=zshSubstDelim transparent
    \ start='\%(\$\?\)[<=>]\@<!((' skip='\\)' end='))'
    \ contains=zshMathSubstInner,@zshSubst,zshNumber,
    \ @zshDerefs,zshString,zshOperator,zshTernary,zshDelim fold

" HERE(13): highlights wrong echo $[ [#16_4] 42 ** 10 ]
syn region  zshMathSubst        matchgroup=zshSubstDelim transparent
    \ start='\$\[' skip='\\]' end='\]'
    \ contains=zshDelim,@zshSubst,zshNumber,
    \ @zshDerefs,zshString,zshOperator,zshTernary fold

" The ms=s+1 prevents matching zshBrackets several times on opening brackets
" (see https://github.com/chrisbra/vim-zsh/issues/21#issuecomment-576330348)
syn region  zshBrackets    contained transparent
    \ start='{'ms=s+1
    \ skip='\\}' end='}'me=e-1 fold
exe 'syn region  zshBrackets    transparent start=/{/ skip=/\\}/ end=/}/ contains='.s:contained. ' fold'

syn region  zshSubst      matchgroup=zshSubstDelim
    \ start='\${' skip='\\}' end='}'
    \ contains=@zshSubst,zshBrackets,zshQuoted,zshString,zshNumber,zshDelim,zshGlob fold
" \ contains=zshSubst,zshBrackets,zshQuoted,zshString,zshNumber,zshDelim,zshGlob fold

exe 'syn region  zshOldSubst    matchgroup=zshSubstDelim start=/`/ skip=/\\[\\`]/ end=/`/ contains='.s:contained. ',zshOldSubst fold'


syn sync    minlines=50 maxlines=90
syn sync    match zshHereDocSync    grouphere   NONE '<<-\=\s*\%(\\\=\S\+\|\(["']\)\S\+\1\)'
syn sync    match zshHereDocEndSync groupthere  NONE '^\s*EO\a\+\>'

syn keyword zshTodo             contained TODO FIXME XXX NOTE

syn region  zshComment          oneline start='\%(^\|\s\+\)#' end='$'
    \ contains=zshTodo,@Spell fold

syn region  zshComment          start='^\s*\%((\)\@<!\zs#' end='^\%(\s*#\)\@!'
    \ contains=zshTodo,@Spell fold

syn match   zshPreProc          '^\%1l#\%(!\|compdef\|autoload\).*$'

syn match zshDelim '\v%(\(|\))' containedin=zshParentheses
syn match zshDelim '\v%(\{|\})' containedin=zshBrackets
syn match zshDelim '\v%(\[|\])' containedin=zshParentheses
" HERE(14): Add all glob qualifiers
syn match zshGlob              '(#\([iIlbBmMsequU]\|c\(\d\+\|\d\+,\d\+\)\|a\d+\)\+)' contains=zshDelim

"  ╭──────────────────────────────────────────────────────────╮
"  │                      Miscellaneous                       │
"  ╰──────────────────────────────────────────────────────────╯

" HERE(15): range operator
" syn match zshRange        '{\zs\w\+\.\.\w\+\ze}' contains=zshDelim
" syn match zshRange        '{\zs\w\+,\w\+\ze}' contains=zshDelim
" hi def link zshRange Operator

syn keyword zshUlimit addressspace aiomemorylocked aiooperations cachedthreads coredumpsize
syn keyword zshUlimit cputime datasize descriptors filesize kqueues maxproc maxpthreads
syn keyword zshUlimit memorylocked memoryuse msgqueue posixlocks pseudoterminals resident
syn keyword zshUlimit sigpending sockbufsize stacksize swapsize vmemorysize

" syn match zshCompletionCtx
"     \ /\v%(-((array)?-value|(assign|brace)?-parameter|command|condition|default|equal|first)-)/
" syn match zshCompletionCtx
"     \ /\v%(-(math|redirect|subscript|tilde)-)/

syn keyword zshCompletionCtx -array-value- -assign-parameter- -brace-parameter- -command-
syn keyword zshCompletionCtx -condition- -default- -equal- -first- -math- -parameter- -redirect-
syn keyword zshCompletionCtx -subscript- -tilde- -value-

" ============================ Highlights ============================
function s:fg(from)
    return synIDattr(synIDtrans(hlID(a:from)), 'fg', 'gui')
endf
function s:fg_bold(group, from)
    exec 'hi ' .. a:group .. ' guifg=' .. s:fg(a:from) .. ' gui=bold'
endf

hi def link zshTodo             Todo
hi def link zshComment          Comment
hi def link zshPreProc          PreProc
hi def link zshHereDoc          String
hi def link zshRedir            Operator
hi def link zshSemicolon        Keyword
hi def link zshLinewrapOperator SpecialChar
hi def link zshNamespaceSep     Operator

hi def link zshQuoted           SpecialChar
hi def link zshPOSIXQuoted      SpecialChar
hi def link zshString           String
hi def link zshPOSIXString      SpecialChar
hi def link zshStringDelimiter  zshString

hi def link zshTypes            Type
hi def link zshNumber           Number
hi def link zshOperator         Operator
" hi def link zshTestOperator   Operator
hi def link zshDelimiter        Keyword
hi def link zshConstant         Constant

hi def link zshCase             zshConditional
hi def link zshCaseIn           zshCase
hi def link zshCaseEnd          zshSemicolon
hi def link zshCaseEsac         zshCase
hi def link zshConditional      Conditional
hi def link zshException        Exception
hi def link zshRepeat           Repeat
hi def link zshRepeatIn         Repeat
hi def link zshKeyword          Keyword

hi def link zshGlob       Constant
hi def link zshOption     Constant
hi def link zshOptKeyword Repeat
" hi def link zshOptStart Keyword
hi def link zshFlag       Special
hi def link zshFlagEnd    Delimiter

hi def link zshJobSpec       Special
hi def link zshUlimit        Special
hi def link zshKeymapMode    Constant
hi def link zshCompletionCtx Constant

call s:fg_bold("zshPrecommand", "Preproc")
hi def link zshPrecommandOther      @constructor
hi def link zshPrivilegedPrecommand Statement
hi def link zshFunction             Function
hi def link zshKSHFunction          zshFunction
hi def link zshTernary              Function
hi def link zshCommands             Keyword
hi def link shCommands              Statement

hi def link zshSubst            PreProc
hi def link zshSubstQuoted      zshSubst
hi def link zshMathSubst        zshSubst
hi def link zshMathSubstDelim   Number
hi def link zshOldSubst         zshSubst
hi def link zshSubstDelim       zshSubst

hi def link zshVarAssign        zshOperator
hi def link zshVariable         None
hi def link zshVariableDef      zshVariable
hi def link zshDereferencing    PreProc
hi def link zshShortDeref       zshDereferencing
hi def link zshDeref            zshDereferencing
hi def link zshDollarVar        zshDereferencing
hi def link zshBuiltinVar       zshDereferencing
call s:fg_bold("zshBuiltinArr", "zshDereferencing")

" hi def link zshPOSIXQuotedOct     SpecialChar
" hi def link zshPOSIXQuotedUni     SpecialChar
" hi def link zshStringEsc          Constant " SpecialChar
" hi def link zshStringEscDate      Constant " SpecialChar
" hi def link zshStringEscDateOther String
" hi def link zshStringEscDateChars Constant " SpecialChar

let b:current_syntax = "zsh"

let &cpo = s:cpo_save
unlet s:cpo_save
