" Vim syntax file
" Language:             Zsh shell script
" Maintainer:           Christian Brabandt <cb@256bit.org>
" Previous Maintainer:  Nikolai Weibull <now@bitwi.se>
" Latest Revision:      2022-07-26
" License:              Vim (see :h license)
" Repository:           https://github.com/chrisbra/vim-zsh

" Positive lookahead (?=) (\@=)  - next thing has to be
"   foo\(bar\)\@=  =>  "foo" if followed by "bar"
"   /foo(?=bar)/   =>  "foo" if followed by "bar" (Perl)

" Negative lookahead (?!) (\@!)  - next thing can't be
"   foo\(bar\)\@!  =>  "foo" if not followed by "bar"
"   /foo(?!bar)/   =>  "foo" if not followed by "bar"

" Positive lookbehind (?<=) (\@<=)
"   \(foo\)\@<=bar  =>  "bar" when preceded by "foo"
"   /(?<=foo)bar/   =>  "bar" when preceded by "foo"  foobar

"     Start match         (\K) (\zs)
"       \([a-z]\+\)\zs,\1  =>  ",abc" in "abc,abc"
"       ([a-z]+)\K,\1      =>  ",abc" in "abc,abc"

" Negative lookbehind (?<!) (\@<!)
"   \(foo\)\@<!bar  =>  "bar" when NOT preceded by "foo"
"   /(?<!foo)bar/   =>  "bar" when NOT preceded by "foo"

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

syn iskeyword @,48-57,_,192-255,#,-
if get(g:, 'zsh_fold_enable', 0)
    setlocal foldmethod=syntax
endif

" syn match   zshQuoted           '\\.'
syn match   zshQuoted              '\\[abcfnrtv0e\\]' " TODO: highlight different
syn match   zshPOSIXQuotedHex      '\\[xX][0-9a-fA-F]\{1,2}'
syn match   zshPOSIXQuotedOct      '\\[0-7]\{1,3}'
syn match   zshPOSIXQuotedUni      '\\u[0-9a-fA-F]\{1,4}'
syn match   zshPOSIXQuotedUni      '\\U[1-9a-fA-F]\{1,8}'
syn cluster zshPOSIXQuoted         contains=zshPOSIXQuotedHex,zshPOSIXQuotedOct,zshPOSIXQuotedUni

" syn match   zshStringEscDate
"             \ '\v\%D\{0|a|A|b|B|c|C|d|D|e|E|f|F|g|G|h|H|I|j|k|K|l|L|m|M|n|N|O|p|P|r|R|s|S|t|T|u|U|V|w|W|x|X|y|Y|z|Z|^|-|\.|_\%|#}'
syn match   zshStringEsc     '\v\%(\%|\)|l|M|n|y|#|\?|^|e|h|!|i|I|j|L|N|x|D|T|t|\@|\*|w|W)'
syn match   zshStringEsc     '\v\%(-=\d)=(m|d|\/|_|\~|c|\.|C)'

syn match   zshStringEscDateOther '[^{}]' contained
syn match   zshStringEscDateChars '\v\%(0|\%|I|j|O|^|-|\.|_\%|#|\c[abcdefghklmnprstuwxyz])' contained
syn match   zshStringEscDate     '\v\%D\{((\%(\%|I|j|O|^|-|\.|_\%|#|\c[abcdefghklmnprstuwxyz]))|[^}])+}'
                                 \ contains=zshStringEscDateChars,zshStringEscDateOther
" syn match   zshStringEscDate      '\v\%D\{\zs[^}]+\ze}' contains=zshStringEscDateChars " %D{%H:%M:%S.%.}

" TODO: How to only highlight chars it contains much simpler
" syn match   zshStringEscDateChars '\v(\%(0|\%|I|j|O|^|-|\.|_\%|#|\c[abcdefghklmnprstuwxyz]))+' contained
" syn region  zshStringEscDate     matchgroup=Tag start='%D{' end='}' contained contains=zshStringEscDateChars,zshString
" syn match   zshStringEscDate     '\v\%D\{(\%(\%|I|j|O|^|-|\.|_\%|#|\c[abcdefghklmnprstuwxyz]))+}'


" TODO:
" syn match   zshCharClass contained
"     \ "\[:\(backspace\|escape\|return\|xdigit\|alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|tab\):\]"

" Unicode sequences are allowed in strings "text before \u2345 text after"
syn region  zshString           matchgroup=zshStringDelimiter start=+"+ end=+"+
                                \ contains=@Spell,zshQuoted,@zshDerefs,@zshSubstQuoted,zshCtrlSeq,zshStringEsc,zshStringEscDate,zshPOSIXQuotedUni
                                \ fold
syn region  zshPOSIXString      matchgroup=zshStringDelimiter start=+\$'+
                                \ skip=+\\[\\']+ end=+'+ contains=@zshPOSIXQuoted,zshQuoted
syn region  zshString           matchgroup=zshStringDelimiter start=+'+ end=+'+
                                \ contains=@Spell fold
syn match   zshJobSpec          '%\(\d\+\|?\=\w\+\|[%+-]\)'

" TODO: add decimal
" TODO: Add $(( [##16] ))
" syn match   zshNumber           '[+-]\=\<\d\+\>'
syn match   zshNumber           '[+-]\=\<[0-9_]\+\>'          " number:       44   4_000
syn match   zshNumber           '[+-]\=\<0x[[:xdigit:]_]\+\>' " c_bases hex:  0xA0 0x1_000
syn match   zshNumber           '[+-]\=\<0[0-7_]\+\>'         " octal_zeroes: 077  01_000
syn match   zshNumber           '[+-]\=\d\+#[-+]\=\w\+\>'     " octal:        8#77
syn match   zshNumber           '[+-]\=\d\+\.\d\+\>'
syn match   zshNumber           '\[##\<\d\+\>\]'

syn match zshOperator     '\v%(\+{1,2}|-{1,2}|!|\~)' " unary plus/minus, logical NOT, complement, {pre,post}{in,de}crement
syn match zshOperator     '<<\|>>' " bitwise shift left, right
syn match zshOperator     '[&^|]' " bitwise AND XOR OR
syn match zshOperator     '\v%(\*{1,2}|\/|\%|\+|-)' " exponent, multiplication, division, modulus, add, subtract
syn match zshOperator     '[<>]=\?' " comparison < > <= >=
syn match zshOperator     '[=!]=' " equality, inequality
syn match zshOperator     '\v%(\&\&|\|\||\^\^)' " logical AND OR XOR
syn match zshOperator     ';\|&!\=\|&|' " ; & &! &|
syn match zshOperator     '\%([-+*/%&^|]\|[<>&|^*]\{2}\)\==' skipwhite nextgroup=zshPattern " assignment (math only)

" logical AND OR XOR TODO: Add to $(( )) $[[  ]] -- zshPattern, zshString, zshNumber, zshDeref
syn match zshTernary          '[?:]\@1<![?:][?:]\@!' contained
syn match zshSemicolon        ';'                    containedin=zshOperator
syn match zshWrapLineOperator '\\$'

" Match command flags in zsh
syn match zshFlag '\s\zs[-+][-_a-zA-Z#@?]\+'
                  \ containedin=zshBrackets,zshParentheses nextgroup=zshCmdEnd
syn match zshFlag '\s\zs--[^ \t$=`'"|[]();]\+'
                  \ containedin=zshBrackets,zshParentheses nextgroup=zshCmdEnd
" command -- extra_args
syn match zshCmdEnd '\v[[:space:]]+\-\-[[:space:]]+'

syn match zshPattern      '\<\S\+\())\)\@='  contained contains=@zshDerefs,@zshSubst,zshBrackets,zshQuoted,zshString,zshNumber
",zshOperator
" shExSingleQuote,shSingleQuote,shExDoubleQuote,shDoubleQuote

" Testing [[[
syn match zshTestOperator '[=!]\==\|=\~\|-\(nt\|ot\|ef\|eq\|ne\|lt\|le\|ge\)\>\|[<>!]' " [[ x OPER pat ]] TODO: add contains
syn match zshTestOperator '\v\s\zs-(a|b|c|d|e|f|g|h|k|n|p|r|s|u|v|w|x|z|L|O|G|S|N)>'
syn match zshTestOperator '-t\>' nextgroup=zshNumber
syn match zshTestOperator '-o\>' nextgroup=zshOption
" syn match zshTestOperator     '\[[[^:]\|\]]'

syn region zshExpr  matchgroup=Constant
                    \ start="\[" skip=+\\\\\|\\$\|\[+
                    \ end="\]"   contains=@shTestList,shSpecial

syn region zshTest transparent matchgroup=shStatement
                   \ start="\<test\s" skip=+\\\\\|\\$+
                   \ matchgroup=NONE  end="[;&|]"me=e-1
                   \ end="$"          contains=@shExprList1

syn region zshNoQuote start='\S'    skip='\%(\\\\\)*\\.'
                      \ end='\ze\s' end="\ze['"]"
                      \ contained   contains=shDerefSimple,shDeref,@zshDerefs
syn match  zshAstQuote contained    '\*\ze"'  nextgroup=zshString
syn match  zshTestOpr  contained    '[^-+/%]\zs=' skipwhite
                       \ nextgroup=shTestDoubleQuote,shTestSingleQuote,shTestPattern
" syn match  shTestOpr            contained       "<=\|>=\|!=\|==\|=\~\|-.\>\|-\(nt\|ot\|ef\|eq\|ne\|lt\|le\|gt\|ge\)\>\|[!<>]"
" syn match  shTestPattern        contained       '\w\+'
" syn region shTestDoubleQuote    contained       start='\%(\%(\\\\\)*\\\)\@<!"' skip=+\\\\\|\\"+ end='"'         contains=shDeref,shDerefSimple,shDerefSpecial
" syn match  shTestSingleQuote    contained       '\\.'           nextgroup=shTestSingleQuote
" syn match  shTestSingleQuote    contained       "'[^']*'"
"  syn region  shDblBrace matchgroup=Delimiter start="\[\["       skip=+\%(\\\\\)*\\$+ end="\]\]" contains=@shTestList,shAstQuote,shNoQuote,shComment
"  syn region  shDblParen matchgroup=Delimiter start="(("         skip=+\%(\\\\\)*\\$+ end="))"   contains=@shTestList,shComment

" ]]]

syn keyword zshPrivilegedPrecommand sudo doas nextgroup=zshPrecommand,zshCommands,shCommands
syn keyword zshPrecommand       noglob nocorrect exec command builtin - time nextgroup=zshCommands,shCommands

syn keyword zshDelimiter        do done end nextgroup=zshSemicolon,zshRedir,zshWrapLineOperator

syn keyword zshConditional      if elif nextgroup=zshTestOperator
syn keyword zshConditional      then else fi esac select

syn keyword zshCase             case nextgroup=zshCaseWord skipwhite
syn match zshCaseWord           /\S\+/ nextgroup=zshCaseIn skipwhite contained transparent
syn keyword zshCaseIn           in nextgroup=zshCasePattern skipwhite skipnl contained
syn match zshCasePattern        /(\=\zs\S[^)]*\ze)/ contained
syn match zshCaseEnd            ';[;&|]' nextgroup=zshCasePattern skipwhite skipnl

syn keyword zshRepeat           while until repeat in
syn keyword zshRepeat           for foreach nextgroup=zshVariable skipwhite
syn keyword zshException        always
syn keyword zshKeyword          function nextgroup=zshKSHFunction skipwhite

" syn match   zshKSHFunction      contained '\w\S\+'
" syn match   zshFunction         '^\s*\k\+\ze\s*()'

" My modification to allow for functions that start with or contain [:→.@+-]
syn match   zshKSHFunction      contained '\(\w\|[:→.@+-]\)\S\+'
syn match   zshFunction         '^\s*\(\k\|[:→.@+-]\)\+\ze\s*()'

                                " <<<, <, <>, and variants.
syn match   zshRedir            '\d\=\(<<<\|<&\s*[0-9p-]\=\|<>\?\)'
                                " >, >>, and variants.
syn match   zshRedir            '\d\=\(>&\s*[0-9p-]\=\|&>>\?\|>>\?&\?\)[|!]\='
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

syn match   zshVariable         '\<\h\w*' contained nextgroup=zshVariable
" var+=
syn match   zshVariableDef      '\<\h\w*\ze+\==' nextgroup=zshVarAssign
" var[idx]+=
syn region  zshVariableDef      oneline
                                \ start='\(\${\=\)\@<!\<\h\w*\['   end='\]\ze+\==\='
                                \ contains=@zshSubst,@zshBuiltins  nextgroup=zshVarAssign
syn match  zshVarAssign         '+\=='
                                \ contained
                                " \ nextgroup=shCmdParenRegion,shPattern,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shSingleQuote,shExSingleQuote,shVar

" syn cluster zshDerefs           contains=zshShortDeref,zshDeref,zshDollarVar
syn cluster zshDerefs         contains=zshShortDeref,zshBuiltinArray,zshBuiltinVar,zshDeref,zshDollarVar
syn match zshShortDeref       '\$[!#$*@?_-]\w\@!'
syn match zshShortDeref       '\$[=^~]*[#+]*\d\+\>'
syn match zshDollarVar        '\$\h\w*'
syn match zshDeref            '\$[=^~]*[#+]*\h\w*\>'


syn keyword zshBuiltinArray contained
    \ aliases                 argv              builtins           cdpath              chpwd_functions
    \ commands                comppostfuncs     compprefuncs       compstat            context
    \ dirstack                dis_aliases       dis_builtins       dis_functions       dis_functions_source
    \ dis_galiases            dis_patchars      dis_reswords       dis_saliases        epochtime
    \ errnos                  fignore           fpath              funcfiletrace       funcsourcetrace
    \ funcstack               functions         functions_source   functrace           galiases
    \ histchars               history           historywords       jobdirs             jobstates
    \ jobtexts                keymaps           killring           langinfo            mailpath
    \ manpath                 mapfile           match              mbegin              mend
    \ modules                 module_path       nameddirs          options             parameters
    \ patchars                path              periodic_functions pipestatus          precmd_functions
    \ preexec_functions       prompt            psvar              region_highlight    registers
    \ reply                   reswords          saliases           signals             status
    \ sysparams               tcp_expect_lines  tcp_filter         tcp_lines           tcp_no_spam_list
    \ tcp_on_read             tcp_spam_list     termcap            terminfo            userdirs
    \ usergroups              watch             widgets            words               zcurses_attrs
    \ zcurses_colors          zcurses_keycodes  zcurses_windows    zle_bracketed_paste zle_highlight
    \ zshaddhistory_functions zshexit_functions zsh_eval_context   zsh_scheduled_events

syn keyword zshBuiltinVar contained
    \ ARGC                   ARGV0                BAUD                BUFFER                  BUFFERLINES
    \ CDPATH                 COLUMNS              CONTEXT             CORRECT                 CPUTYPE
    \ CURRENT                CURSOR               CUTBUFFER           DIRSTACKSIZE            EDITOR
    \ EGID                   ENV                  EPOCHREALTIME       EPOCHSECONDS            ERRNO
    \ EUID                   FCEDIT               FIGNORE             FPATH                   FUNCNEST
    \ GID                    HELPDIR              HISTCHARS           HISTCMD                 HISTFILE
    \ HISTNO                 HISTORY_IGNORE       HISTSIZE            HOME                    HOST
    \ IFS                    IPREFIX              ISEARCHMATCH_ACTIVE ISEARCHMATCH_END        ISEARCHMATCH_START
    \ ISUFFIX                KEYBOARD_HACK        KEYMAP              KEYS                    KEYS_QUEUED_COUNT
    \ KEYTIMEOUT             LANG                 LASTABORTEDSEARCH   LASTSEARCH              LASTWIDGET
    \ LBUFFER                LC_ALL               LC_COLLATE          LC_CTYPE                LC_MESSAGES
    \ LC_NUMERIC             LC_TIME              LINENO              LINES                   LISTMAX
    \ LOGCHECK               LOGNAME              MACHTYPE            MAIL                    MAILCHECK
    \ MAILPATH               MANPATH              MARK                MATCH                   MBEGIN
    \ MEND                   MENUSELECT           MODULE_PATH         NULLCMD                 NUMERIC
    \ OLDPWD                 OPTARG               OPTIND              OSTYPE                  PATH
    \ PENDING                PERIOD               POSTDISPLAY         POSTEDIT                PPID
    \ PREBUFFER              PREDISPLAY           PREFIX              PROMPT                  PROMPT2
    \ PROMPT3                PROMPT4              PROMPT_EOL_MARK     PS1                     PS2
    \ PS3                    PS4                  PSVAR               PWD                     QIPREFIX
    \ QISUFFIX               RANDOM               RBUFFER             READNULLCMD             REGION_ACTIVE
    \ REPLY                  REPORTMEMORY         REPORTTIME          RPROMPT                 RPROMPT2
    \ RPS1                   RPS2                 SAVEHIST            SECONDS                 SHLVL
    \ SPROMPT                STTY                 SUFFIX              SUFFIX_ACTIVE           SUFFIX_END
    \ SUFFIX_START           TCP_HANDLER_ACTIVE   TCP_LINE            TCP_LINE_FD             TCP_LOG
    \ TCP_OUTPUT             TCP_PROMPT           TCP_READ_DEBUG      TCP_SECONDS_START       TCP_SESS
    \ TCP_SILENT             TCP_TALK_ESCAPE      TCP_TIMEOUT         TERM                    TERMINFO
    \ TERMINFO_DIRS          TIMEFMT              TMOUT               TMPPREFIX               TMPSUFFIX
    \ TRY_BLOCK_ERROR        TRY_BLOCK_INTERRUPT  TTY                 TTYIDLE                 UID
    \ UNDO_CHANGE_NO         UNDO_LIMIT_NO        USERNAME            VENDOR                  VISUAL
    \ WATCH                  WATCHFMT             WIDGET              WIDGETFUNC              WIDGETSTYLE
    \ WORDCHARS              YANK_ACTIVE          YANK_END            YANK_START              ZBEEP
    \ ZCURSES_COLORS         ZCURSES_COLOR_PAIRS  ZDOTDIR             ZFTP_ACCOUNT            ZFTP_CODE
    \ ZFTP_COUNT             ZFTP_FILE            ZFTP_HOST           ZFTP_IP                 ZFTP_PORT
    \ ZFTP_PREFS             ZFTP_PWD             ZFTP_REPLY          ZFTP_SESSION            ZFTP_SIZE
    \ ZFTP_SYSTEM            ZFTP_TMOUT           ZFTP_TRANSFER       ZFTP_TYPE               ZFTP_USER
    \ ZFTP_VERBOSE           ZLE_LINE_ABORTED     ZLE_RECURSIVE       ZLE_REMOVE_SUFFIX_CHARS ZLE_RPROMPT_INDENT
    \ ZLE_SPACE_SUFFIX_CHARS ZLE_STATE            ZLS_COLORS          ZLS_COLOURS             ZSH_ARGZERO
    \ ZSH_EVAL_CONTEXT       ZSH_EXECUTION_STRING ZSH_NAME            ZSH_PATCHLEVEL          ZSH_SCRIPT
    \ ZSH_VERSION

syn cluster zshBuiltins add=zshBuiltinVar,zshBuiltinArray

" TODO: Combine these somehow

syn match zshBuiltinArray '\$[=^~]*[#+]*\%(aliases\|argv\|builtins\|cdpath\|chpwd_functions\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(commands\|comppostfuncs\|compprefuncs\|compstat\|context\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(dirstack\|dis_aliases\|dis_builtins\|dis_functions\|dis_functions_source\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(dis_galiases\|dis_patchars\|dis_reswords\|dis_saliases\|epochtime\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(errnos\|fignore\|fpath\|funcfiletrace\|funcsourcetrace\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(funcstack\|functions\|functions_source\|functrace\|galiases\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(histchars\|history\|historywords\|jobdirs\|jobstates\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(jobtexts\|keymaps\|killring\|langinfo\|mailpath\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(manpath\|mapfile\|match\|mbegin\|mend\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(modules\|module_path\|nameddirs\|options\|parameters\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(patchars\|path\|periodic_functions\|pipestatus\|precmd_functions\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(preexec_functions\|prompt\|psvar\|region_highlight\|registers\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(reply\|reswords\|saliases\|signals\|status\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(sysparams\|tcp_expect_lines\|tcp_filter\|tcp_lines\|tcp_no_spam_list\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(tcp_on_read\|tcp_spam_list\|termcap\|terminfo\|userdirs\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(usergroups\|watch\|widgets\|words\|zcurses_attrs\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(zcurses_colors\|zcurses_keycodes\|zcurses_windows\|zle_bracketed_paste\|zle_highlight\)'
syn match zshBuiltinArray '\$[=^~]*[#+]*\%(zshaddhistory_functions\|zshexit_functions\|zsh_eval_context\|zsh_scheduled_events\)'

syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ARGC\|ARGV0\|BAUD\|BUFFER\|BUFFERLINES\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(CDPATH\|COLUMNS\|CONTEXT\|CORRECT\|CPUTYPE\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(CURRENT\|CURSOR\|CUTBUFFER\|DIRSTACKSIZE\|EDITOR\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(EGID\|ENV\|EPOCHREALTIME\|EPOCHSECONDS\|ERRNO\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(EUID\|FCEDIT\|FIGNORE\|FPATH\|FUNCNEST\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(GID\|HELPDIR\|HISTCHARS\|HISTCMD\|HISTFILE\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(HISTNO\|HISTORY_IGNORE\|HISTSIZE\|HOME\|HOST\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(IFS\|IPREFIX\|ISEARCHMATCH_ACTIVE\|ISEARCHMATCH_END\|ISEARCHMATCH_START\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ISUFFIX\|KEYBOARD_HACK\|KEYMAP\|KEYS\|KEYS_QUEUED_COUNT\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(KEYTIMEOUT\|LANG\|LASTABORTEDSEARCH\|LASTSEARCH\|LASTWIDGET\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(LBUFFER\|LC_ALL\|LC_COLLATE\|LC_CTYPE\|LC_MESSAGES\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(LC_NUMERIC\|LC_TIME\|LINENO\|LINES\|LISTMAX\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(LOGCHECK\|LOGNAME\|MACHTYPE\|MAIL\|MAILCHECK\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(MAILPATH\|MANPATH\|MARK\|MATCH\|MBEGIN\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(MEND\|MENUSELECT\|MODULE_PATH\|NULLCMD\|NUMERIC\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(OLDPWD\|OPTARG\|OPTIND\|OSTYPE\|PATH\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(PENDING\|PERIOD\|POSTDISPLAY\|POSTEDIT\|PPID\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(PREBUFFER\|PREDISPLAY\|PREFIX\|PROMPT\|PROMPT2\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(PROMPT3\|PROMPT4\|PROMPT_EOL_MARK\|PS1\|PS2\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(PS3\|PS4\|PSVAR\|PWD\|QIPREFIX\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(QISUFFIX\|RANDOM\|RBUFFER\|READNULLCMD\|REGION_ACTIVE\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(REPLY\|REPORTMEMORY\|REPORTTIME\|RPROMPT\|RPROMPT2\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(RPS1\|RPS2\|SAVEHIST\|SECONDS\|SHLVL\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(SPROMPT\|STTY\|SUFFIX\|SUFFIX_ACTIVE\|SUFFIX_END\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(SUFFIX_START\|TCP_HANDLER_ACTIVE\|TCP_LINE\|TCP_LINE_FD\|TCP_LOG\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(TCP_OUTPUT\|TCP_PROMPT\|TCP_READ_DEBUG\|TCP_SECONDS_START\|TCP_SESS\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(TCP_SILENT\|TCP_TALK_ESCAPE\|TCP_TIMEOUT\|TERM\|TERMINFO\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(TERMINFO_DIRS\|TIMEFMT\|TMOUT\|TMPPREFIX\|TMPSUFFIX\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(TRY_BLOCK_ERROR\|TRY_BLOCK_INTERRUPT\|TTY\|TTYIDLE\|UID\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(UNDO_CHANGE_NO\|UNDO_LIMIT_NO\|USERNAME\|VENDOR\|VISUAL\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(WATCH\|WATCHFMT\|WIDGET\|WIDGETFUNC\|WIDGETSTYLE\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(WORDCHARS\|YANK_ACTIVE\|YANK_END\|YANK_START\|ZBEEP\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZCURSES_COLORS\|ZCURSES_COLOR_PAIRS\|ZDOTDIR\|ZFTP_ACCOUNT\|ZFTP_CODE\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZFTP_COUNT\|ZFTP_FILE\|ZFTP_HOST\|ZFTP_IP\|ZFTP_PORT\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZFTP_PREFS\|ZFTP_PWD\|ZFTP_REPLY\|ZFTP_SESSION\|ZFTP_SIZE\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZFTP_SYSTEM\|ZFTP_TMOUT\|ZFTP_TRANSFER\|ZFTP_TYPE\|ZFTP_USER\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZFTP_VERBOSE\|ZLE_LINE_ABORTED\|ZLE_RECURSIVE\|ZLE_REMOVE_SUFFIX_CHARS\|ZLE_RPROMPT_INDENT\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZLE_SPACE_SUFFIX_CHARS\|ZLE_STATE\|ZLS_COLORS\|ZLS_COLOURS\|ZSH_ARGZERO\)'
syn match zshBuiltinVar '\$[=^~]*[#+]*\%(ZSH_EVAL_CONTEXT\|ZSH_EXECUTION_STRING\|ZSH_NAME\|ZSH_PATCHLEVEL\|ZSH_SCRIPT\|ZSH_VERSION\)'

syn match   zshCommands         '\%(^\|\s\)[.:]\ze\s'  " matches source (.) and (:)
syn keyword zshCommands         alias        autoload     bg          bindkey       break      bye cap
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
                              \ zselect      defer        zsh         abbr          zsh-defer  add-zsh-hook

syn keyword shCommands          arch     awk       b2sum   base32   base64
                              \ basename basenc    bash    brew     cat
                              \ chcon    chgrp     chown   chroot   cksum
                              \ column   comm      cp      csplit   curl
                              \ cut      date      dd      defaults df
                              \ dir      dircolors dirname ed       env
                              \ expand   factor    fmt     fold     git
                              \ grep     groups    head    hexdump  hostid
                              \ hostname hugo      id      install  join
                              \ killall  link      ln      logname  md5sum
                              \ mkdir    mkfifo    mknod   mktemp   nice
                              \ nl       nohup     npm     nproc    numfmt
                              \ od       open      paste   pathchk  pr
                              \ printenv printf    ptx     readlink realpath
                              \ rg       runcon    scutil  sed      seq
                              \ sha1sum  sha2      shred   shuf     sort
                              \ split    stat      stdbuf  stty     ls
                              \ sum      sync      tac     tee      terminfo
                              \ timeout  tmux      top     touch    tput
                              \ tr       truncate  tsort   tty      uname
                              \ unexpand uniq      unlink  uptime   users
                              \ vdir     vim       wc      who      whoami
                              \ yabai    yes       sxhkd   bspwm    bspc
                              \ perl

syn keyword zshKeymap contained
            \ main emacs viins vicmd viopp visual isearch command .safe

syn match zshKeymapStart
          \ /\v^\s*%(builtin\s+)?bindkey\s+%(%(-\a{1,3}\s+){,3}%([[:print:]]+\s+){,2}){,2}/
          \ skipwhite contains=zshKeymap,zshCommands,zshFlag,zshPrecommand

" syn match zshZleWidgetStart
"           \ /\v^\s*%(builtin\s+)?zle\s+%(-[DAC]\s+)?/
"           \ nextgroup=zshZleWidget skipwhite contains=zshCommands,zshFlag,zshPrecommand
" syn match zshZleWidget
"           \ /\v/

syn case ignore

" (builtin) (un)setopt extended_glob
" (builtin) set -o extended_glob
" (builtin) emulate (-LR) zsh -o extended_glob
" TODO: [[ -o extended_glob ]]
syn match   zshOptStart
            \ /\v^\s*%(builtin\s+)?%(%(un)?setopt|%(set|emulate\s+%(-[LR]{1,2}\s+)?zsh)\s+[-+]o)/
            \ nextgroup=zshOption skipwhite contains=zshCommands,zshFlag,zshPrecommand
syn keyword zshOption nextgroup=zshOption,zshComment skipwhite contained
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

" TODO: Special files as Constants
syn match Constant "\v/dev/\w+"
            " \ containedin=shFunctionOne,shIf,shCmdParenRegion,shCommandSub

" TODO: add array indexing
" TODO: add builtin hilight of ${#var} etc
" TODO: Match conditional substrings
"       %v
"       %(x.true-text.false-text) (many operators here)
"       %<string<
"       %>string>
"       %[xstring]
" TODO: Match event designators ! !! !n !-n !str !?str !?str? !# !{...}
" TODO: Match word designators
"       0      The first input word (command).
"       n      The nth argument.
"       ^      The first argument.  That is, 1.
"       $      The last argument.
"       %      The word matched by (the most recent) ?str search. (only `!%', `!:%', `!?str?:%', after `!?`)
"       x-y    A range of words; x defaults to 0.
"       *      All the arguments, or a null value if there are none.
"       x*     Abbreviates `x-$'.
"       x-     Like `x*' but omitting word $.
" TODO: Match modifiers ${path:h2}
" TODO: Match glob qualifiers
" TODO: Match glob flags
" TODO: Match glob operators (ksh too)
" TODO: Match array subscripts ${arr[(i)pattern]}
" TODO: Match parameter expansion flags ${(A)arr}
" TODO: Match symbols between vars
"       ${+var} ${#spec} ${^spec} ${^^spec} ${=spec} ${==spec} ${~spec} ${~~spec}
"       ${name-word} ${name:-word}
"       ${name+word} ${name:+word}
"       ${name=word} ${name:=word} ${name::=word}
"       ${name?word} ${name:?word}
"       ${name#word} ${name##word}
"       ${name%word} ${name%%word}
"       ${name:#word}
"       ${name:|word} ${name:*word}
"       ${name:^word} ${name:^^word}
"       ${name:offset} ${name:offset:length}
"       ${name/pattern/repl} ${name//pattern/repl} ${name:/pattern/repl}

" TODO: $[...] is the same as $((...)), so add that as well.
syn cluster zshSubst            contains=zshSubst,zshOldSubst,zshMathSubst
syn cluster zshSubstQuoted      contains=zshSubstQuoted,zshOldSubst,zshMathSubst
exe 'syn region  zshSubst       matchgroup=zshSubstDelim transparent start=/\$(/ skip=/\\)/ end=/)/ contains='.s:contained. '  fold'
exe 'syn region  zshSubstQuoted matchgroup=zshSubstDelim transparent start=/\$(/ skip=/\\)/ end=/)/ contains='.s:contained. '  fold'
syn region  zshSubstQuoted      matchgroup=zshSubstDelim start='\${' skip='\\}' end='}' contains=@zshSubst,zshBrackets,zshQuoted fold
syn region  zshParentheses      transparent start='(' skip='\\)' end=')' fold
syn region  zshGlob             start='(#' end=')'
syn region  zshMathSubst        matchgroup=zshSubstDelim transparent
                                \ start='\%(\$\?\)[<=>]\@<!((' skip='\\)' end='))'
                                \ contains=zshParentheses,@zshSubst,zshNumber,
                                \ @zshDerefs,zshString fold
" The ms=s+1 prevents matching zshBrackets several times on opening brackets
" (see https://github.com/chrisbra/vim-zsh/issues/21#issuecomment-576330348)
syn region  zshBrackets         contained transparent start='{'ms=s+1 skip='\\}'
                                \ end='}' fold
exe 'syn region  zshBrackets    transparent start=/{/ms=s+1 skip=/\\}/ end=/}/ contains='.s:contained. ' fold'

syn region  zshSubst            matchgroup=zshSubstDelim start='\${' skip='\\}' end='}'
                                \ contains=@zshSubst,zshBrackets,zshQuoted,zshString,@zshBuiltins fold
exe 'syn region  zshOldSubst    matchgroup=zshSubstDelim start=/`/ skip=/\\[\\`]/ end=/`/ contains='.s:contained. ',zshOldSubst fold'


" syn region zshCommandSub matchgroup=zshCmdSubRegion
"                          \ start="\$(\ze[^(]"  skip='\\\\\|\\.'
"                          \ end=")"  contains=@zshCommandSubList
" syn region zshCommandSub matchgroup=Error
"                          \ start="\$(" end=")"
"                          \ contains=@zshCommandSubList
" syn region zshCmdParenRegion matchgroup=zshCmdSubRegion
"                             \ start="(\ze[^(]" skip='\\\\\|\\.' end=")"
"                             \ contains=@zshCommandSubList

" syn region  zshDerefVarArray   contained matchgroup=Constant
"                                \ start="\[" end="]"
                               " \ contains=@zshCommandSubList
                               " \ nextgroup=zshDerefOp,zshDerefOpError

" syn cluster zshDerefPatternList contains=zshDerefPattern,zshDerefString
" syn match  zshDerefOpError      contained       ':[[:punct:]]'
" syn match  zshDerefOp           contained       ':\=[-=?]'      nextgroup=@zshDerefPatternList
" syn match  zshDerefOp           contained       ':\=+'          nextgroup=@zshDerefPatternList
" syn match  zshDerefOp           contained       '#\{1,2}'       nextgroup=@zshDerefPatternList
" syn match  zshDerefOp           contained       '%\{1,2}'       nextgroup=@zshDerefPatternList
" syn match  zshDerefOp           contained       '[,^]\{1,2}'    nextgroup=@zshDerefPatternList
" syn match  zshDerefPattern      contained       '[^{}]\+'
"                     \ contains=zshShortDeref,zshDerefPattern,zshDerefString,zshCommandSub,zshDerefEscape
"                     \ nextgroup=zshDerefPattern
" syn region zshDerefPattern      contained
"                                 \ start="{" skip='\\}' end="}"
"                                 \ contains=zshShortDeref,zshDeref,zshDerefString,zshCommandSub
"                                 \ nextgroup=zshDerefPattern
" syn match  zshDerefEscape       contained       '\%(\\\\\)*\\.'


syn sync    minlines=50 maxlines=90
syn sync    match zshHereDocSync    grouphere   NONE '<<-\=\s*\%(\\\=\S\+\|\(["']\)\S\+\1\)'
syn sync    match zshHereDocEndSync groupthere  NONE '^\s*EO\a\+\>'

syn keyword zshTodo             contained TODO FIXME XXX NOTE

syn region  zshComment          oneline start='\%(^\|\s\+\)#' end='$'
                                \ contains=zshTodo,@Spell fold

syn region  zshComment          start='^\s*#' end='^\%(\s*#\)\@!'
                                \ contains=zshTodo,@Spell fold

syn match   zshPreProc          '^\%1l#\%(!\|compdef\|autoload\).*$'


" Found in polyglot. These can be narrowed now
syn match zshDelim '\v%(\(|\))' containedin=zshParentheses
syn match zshDelim '\v%(\{|\})' containedin=zshBrackets
syn match zshDelim '\v%(\[|\])' containedin=zshParentheses
" syn match zshDelim '\(if\)\@<!\[\]'
"   \(foo\)\@<!bar  =>  "bar" when NOT preceded by "foo"

" ╭─────╮
" │ OLD │
" ╰─────╯
" syn match zshLongDeref        '\$\%(ARGC\|argv\|status\|pipestatus\|CPUTYPE\|EGID\|EUID\|ERRNO\|GID\|HOST\|LINENO\|LOGNAME\)'
" syn match zshLongDeref        '\$\%(MACHTYPE\|OLDPWD OPTARG\|OPTIND\|OSTYPE\|PPID\|PWD\|RANDOM\|SECONDS\|SHLVL\|signals\)'
" syn match zshLongDeref        '\$\%(TRY_BLOCK_ERROR\|TTY\|TTYIDLE\|UID\|USERNAME\|VENDOR\|ZSH_NAME\|ZSH_VERSION\|REPLY\|reply\|TERM\)'


hi def link zshTodo               Todo
hi def link zshComment            Comment
hi def link zshPreProc            PreProc
hi def link zshQuoted             SpecialChar
hi def link zshPOSIXQuotedHex     SpecialChar
hi def link zshPOSIXQuotedOct     SpecialChar
hi def link zshPOSIXQuotedUni     SpecialChar
hi def link zshStringEsc          Constant " SpecialChar
hi def link zshStringEscDate      Constant " SpecialChar
hi def link zshStringEscDateOther String
hi def link zshStringEscDateChars Constant " SpecialChar
hi def link zshString             String
hi def link zshStringDelimiter    zshString
hi def link zshPOSIXString        SpecialChar
hi def link zshJobSpec            Special
hi def link zshPrecommand         Special
hi def link zshDelimiter          Keyword
hi def link zshConditional        Conditional
hi def link zshCase               zshConditional
hi def link zshCaseIn             zshCase
hi def link zshException          Exception
hi def link zshRepeat             Repeat
hi def link zshKeyword            Keyword
hi def link zshFunction           Function
hi def link zshKSHFunction        zshFunction
hi def link zshHereDoc            String
hi def link zshOperator           Operator
hi def link zshRedir              Operator
hi def link zshVariable           None
hi def link zshVariableDef        zshVariable
hi def link zshVarAssign          zshOperator
hi def link zshDereferencing      PreProc
hi def link zshShortDeref         zshDereferencing
hi def link zshLongDeref          zshDereferencing
hi def link zshDeref              zshDereferencing
hi def link zshDollarVar          zshDereferencing
hi def link zshBuiltinVar         zshDereferencing
hi def link zshBuiltinArray       zshDereferencing
hi def link zshCommands           Keyword
hi def link zshOptStart           Keyword
hi def link zshOption             Constant
hi def link zshTypes              Type
hi def link zshSwitches           Special
hi def link zshNumber             Number
hi def link zshSubst              PreProc
hi def link zshSubstQuoted        zshSubst
hi def link zshMathSubst          zshSubst
hi def link zshOldSubst           zshSubst
hi def link zshSubstDelim         zshSubst
hi def link zshGlob               zshSubst

hi def link zshKeymap               Constant
hi def link shCommands              Statement
hi def link zshSemicolon            Operator
hi def link zshFlag                 Special
hi def link zshCmdEnd               Delimiter
hi def link zshPrivilegedPrecommand Statement
hi def link zshTestOperator         Operator

let b:current_syntax = "zsh"

let &cpo = s:cpo_save
unlet s:cpo_save
