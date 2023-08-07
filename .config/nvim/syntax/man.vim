" Vim syntax file
"  Language:           Man
"  Maintainer:         Lucas Burns <burnsac@me.com> (of this file)
"  Latest Revision:    2023-07-31
"
"  History:
"    * 2023-03-21: partial rewrite, making it much more colorful
" ---------------------------------------------------------------------

if exists('b:current_syntax')
  finish
endif

"non-capturing group         \%(atom\) (?:atom)
"positive lookahead          atom\@=   (?=atom)
"negative lookahead          atom\@!   (?!atom)
"positive lookbehind         atom\@<=  (?<=atom)
"negative lookbehind         atom\@<!  (?<!atom)
"atomic group                atom\@>   (?>atom)

" Get the CTRL-H syntax to handle backspaced text
" runtime! syntax/ctrlh.vim

" syn match manReference      display '[^()[:space:]]\+(\%([0-9][a-z]*\|[nlpox]\))'

syn case ignore
" syn match manEscapedCharAny  /\\['"]\@!./ contained
syn match manEscapedChar     /\\['"]\@!./ contained
syn match manEscapedChar
      \ /\(['"]\@1<!\\"\@1!\|['"]\@1<!\\'\@1!\)\([\\abcefnrtv'"]\|[1-9]\d\{,2}\|0\d\{,3}\|\(x\x\{1,2}\|u\x\{4}\|U\x\{8}\)\(\x\+\)\@!\)/

" syn region manString        start=+"+ end=+"+ contains=manEscapedChar
" syn region manPOSIXString   start=+\$'+ skip=+\\[\\']+ end=+'+ contains=manEscapedChar
" syn region manString        start=+'+ excludenl end=+'+

" syn match manSectionHeading  '^[a-z][a-z0-9& ,.-]*[a-z]$'
" syn match manFlags           '\v[^a-z0-9]\zs-{1,2}[[:alnum:]-_?]+\ze'
" syn match manOptions         '^\s\{7}\zs\(\(\([^, ]\{-1,2},\s\)\+\)[^, ]\{-1,2}\|[^, ]\{-1,2}\)\ze\(\s\{2,}\|$\)'

" syn region manDQString      start='[^a-zA-Z"]"[^", )]'lc=1      end='"'     end='^$' contains=manSQString
" syn region manSQString      start="[ \t]'[^', )]"lc=1           end="'"     end='^$'
" syn region manSQString      start="^'[^', )]"lc=1               end="'"     end='^$'
" syn region manBQString      start="[^a-zA-Z`]`[^`, )]"lc=1      end="[`']"  end='^$'
" syn region manBQString      start="^`[^`, )]"                   end="[`']"  end='^$'
" syn region manBQSQString    start="``[^),']"                    end="''"    end='^$'

syn match manString              '"[^"]\{-}"' contains=manEscapedChar
syn match manString              "'[^']\{-}'" contains=manEscapedChar
syn match manPOSIXString         "\$'\(\\\@1<='\|[^' ]\)*'" contains=manEscapedChar
syn match manChar                "'[^']'"
syn match manNumber      display '\d\+' " contained

syn match manHighlightCChar  '[‘’]'          contained conceal
syn match manHighlight       '‘.\{-}’'       contains=manHighlightCChar
syn match manHighlightCChar  '[`']'          contained conceal
syn match manHighlight       +`.\{-}['`]'\?+ contains=manHighlightCChar

" dircolors(1) : the '1'
syn match manSectionNumber   '(\zs\([nlpo]\|\d[a-z]*\)\?\ze)' contained
" dircolors(1) : 'dircolors'
syn match manReference       '\<\zs\(\f\|:\)\+(\([nlpo]\|\d[a-z]*\)\?)\ze\(\W\|$\)' contains=manSectionNumber
syn match manFuncArgs        '\<\h\+(\zs\(\([nlpo]\|\d[a-z]*\)\@!.\{-}\)\ze)' contained contains=manString
syn match manFuncCall        '\<\zs\h\+(\(\([nlpo]\|\d[a-z]*\)\@!.\{-}\))\ze' contains=manFuncArgs

syn match manTitle           '^\(\f\|:\)\+([0-9nlpo][a-z]*).*'
syn match manSectionHeading   display '^\S.*$'
syn match manHeader           display '^\%1l.*$'
syn match manSubHeading3      display '^ \{3\}\S.*$'
syn match manSubHeading2      display '^ \{2\}\S.*$'
syn match manHeaderFile      '\s\zs<\f\+\.h>\ze\(\W\|$\)'
syn match manEmail           '<\?[a-zA-Z0-9_.+-]\+@[a-zA-Z0-9-]\+\.[a-zA-Z0-9-.]\+>\?'

syn include @sh syntax/zsh.vim
syn match manShellDollar     '\$'          contained
syn match manShellCode       '^\s\+\$.\+$' contains=@sh,manShellDollar

" --color=auto : '=auto'
syn match manFlagsDesc       '\v[^a-z0-9](-{1,2}|\+)[[:alnum:]-_?]+\zs(\[\=[[:alnum:]-_]+\]|\=[[:alnum:]-_]+)\ze' contained
" --color=auto : '--color='
syn match manFlags           '\v[^a-z0-9]\zs(-{1,2}|\+)[[:alnum:]-_?]+(\[\=[[:alnum:]-_]+\]|\=[[:alnum:]-_]+)?' contains=manFlagsDesc
syn match manOptions display '^\s\{7}\zs\(\(\([^, ]\{-1,2},\s\)\+\)[^, ]\{-1,2}\ze\(\s\+\|$\)\|[^, ]\{-1,2}\ze\(\s\{3,}\|$\)\)'
syn match manURL
      \ `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^'  <>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^'  <>"]+)[a-zA-Z0-9/]`

syn match manCapital    display '[ <{([]\zs\(\u\|_\|\d\)\{3,}' contains=manNumber,manSignal " contained
syn match manSignal     '\C\<\zs\(SIG\|SIG_\|SA_\)\(NAL\)\@!\(+\?\d\|\u\)\+\ze\(\W\|$\)'
syn match manFile       display '\s\zs\~\?\/[0-9A-Za-z_*/$.{}<>-]*' contained
syn match manEnvVarFile display '\s\zs\$[0-9A-Za-z_{}]\+\/[0-9A-Za-z_*/$.{}<>-]*' contained
syn match manEnvVar     display '[ <{([]\zs\$\(\u\|_\|\d\)\{3,}' contains=manCapital " contained
" syn match manEnvVar     display '\s\zs\(\u\|_\|\d\)\{3,}' contains=manNumber " contained
syn match manCapitalAny    '\u\{2,}' contained

syn match manCurlyBraces display  '{\S.\{-}}' contains=manNumber,manCapitalAny

syn match manLowerSentence /\n\s\{7}\l.\+[()]\=\%(\:\|.\|-\)[()]\=[{};]\@<!\n$/
      \ display keepend contained contains=manReference
syn region manSentence
      \ start=/^\s\{7}\%(\u\|\*\)[^{}=]*/
      \ end=/\n$/ end=/\ze\n\s\{3,7}#/ keepend
      \ contained contains=manReference

" syn match manDeprecated      '\v\[\[deprecated\]\]' contained
" syn match manNumberedList    '\v\d+'

" below syntax elements valid for manpages 2 & 3 only
" if getline(1) =~ '^\(\f\|:\)\+([23][px]\?)'
if get(b:, 'man_sect', '') =~# '^[023]'
  syn case match
  syn include @c $VIMRUNTIME/syntax/c.vim
  " syn include @cCode syntax/c.vim
  " syn match manCError           display '^\s\+\[E\(\u\|\d\)\+\]' contained
  " syn match manCFuncDefinition  display '\<\h\w*\>\s*('me=e-1 contained
  " syn match manSignal           display '\C\<\zs\(SIG\|SIG_\|SA_\)\(\d\|\u\)\+\ze\(\W\|$\)'
  syn match manCFuncDefinition  display '\<\h\w*\ze\(\s\|\n\)*(' contained
  syn match manCError           display '^\s\+\zsE\(\u\|\d\)\+' contained

  " syn region manSynopsis
  "       \ start='^\(LEGACY \)\?SYNOPSIS'hs=s+8
  "       \ end='^\u[A-Z ]*$'me=e-30 keepend
  "       \ contains=manSectionHeading,@c,manCFuncDefinition,manHeaderFile

  " syn region manErrors
  "       \ start='^ERRORS'hs=s+6
  "       \ end='^\u[A-Z ]*$'me=e-30 keepend
  "       \ contains=manSignal,manReference,manSectionHeading,manHeaderFile,manCError

  syn region manErrors
        \ start='^ERRORS'
        \ end='^\%(\S.*\)\=\S$' keepend
        \ contains=manSignal,manReference,manSectionHeading,manHeaderFile,manCError

  syn match manSynopsisHeading '^\%(SYNOPSIS\|SYNTAX\|SINTASSI\|SKŁADNIA\|СИНТАКСИС\|書式\)$' contained
  syn region manSynopsis
        \ start='^\%(SYNOPSIS\|SYNTAX\|SINTASSI\|SKŁADNIA\|СИНТАКСИС\|書式\)$'
        \ end='^\%(\S.*\)\=\S$'me=s-1 keepend
        \ contains=manSynopsisHeading,manLowerSentence,manSentence,manSectionHeading,manCFuncDefinition,@c,manCapitalAny,manEnvVar,manHeaderFile

  syn match manExampleHeading '^EXAMPLES\=$' contained
  syn region manExample
        \ start='^EXAMPLES\=$'
        \ end='^\%(\S.*\)\=\S$'me=s-1 keepend
        \ contains=manExampleHeading,manLowerSentence,manSentence,manSectionHeading,manSubHeading3,manCFuncDefinition,@c

  syn match manTable '\s*[│├└┘┤┼┴┌─┬┐]\+\s*'

  " XXX: groupthere doesn't seem to work
  " syn sync minlines=500
  "syn sync match manSyncExample groupthere manExample '^EXAMPLES\=$'
  "syn sync match manSyncExample groupthere NONE '^\%(EXAMPLES\=\)\@!\%(\S.*\)\=\S$'
endif

syn match manFilesHeading '^FILES' contained
syn region manFiles
      \ start='^FILES'
      \ end='^\%(\S.*\)\=\S$'me=s-1 keepend
      \ contains=manFilesHeading,manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manFile,manEnvVarFile,manNumber

" syn region manEnvironment
"       \ start='^ENVIRONMENT'
"       \ end='^\%(\S.*\)\=\S$' keepend
"       \ contains=manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manEnvVar,manNumber

" syn region manSignals
"       \ start='^SIGNALS'
"       \ end='^\%(\S.*\)\=\S$' keepend
"       \ contains=manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manSignal,manEnvVar,manNumber

" Prevent everything else from matching the last line
execute 'syntax match manFooter display "\%' .. line('$') .. 'l.*$"'

" hi def link manOptionDesc      Constant
" hi def link manLongOptionDesc  Constant

" hi def link manDeprecated      Title
hi def link manTitle           Title
hi def link manSectionNumber   Number
hi def link manSectionHeading  Statement
hi def link manSynopsisHeading Statement
hi def link manExampleHeading  Statement
hi def link manFilesHeading    Statement
hi def link manHeader          Title
hi def link manFooter          Title
hi def link manSubHeading2     Directory
hi def link manSubHeading3     Function
hi def link manFlagsDesc       typescriptTSConstructor
hi def link manFlags           Constant
hi def link manOptions         Constant
hi def link manReference       PreProc
hi def link manCFuncDefinition Function
hi def link manFuncCall        Function
hi def link manHeaderFile      String
hi def link manURL             Underlined
hi def link manEmail           Underlined
hi def link manCError          Identifier
hi def link manSignal          Identifier
hi def link manFile            Identifier
hi def link manEnvVarFile      Identifier
hi def link manEnvVar          Title
hi def link manCapital         MoreMsg
hi def link manHighlight       Statement
hi def link manTable           WarningMsg
hi def link manNumber          Number
hi def link manCurlyBraces     SpecialChar
hi def link manEscapedChar     SpecialChar
hi def link manString          String
hi def link manPOSIXString     String
hi def link manChar            Title
hi def link manShellDollar     Function

let b:current_syntax = 'man'

" vim:set ft=vim et sw=2:
