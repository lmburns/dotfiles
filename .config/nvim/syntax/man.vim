if exists('b:current_syntax')
  finish
endif

" Get the CTRL-H syntax to handle backspaced text
" runtime! syntax/ctrlh.vim

" syn match manReference      display '[^()[:space:]]\+(\%([0-9][a-z]*\|[nlpox]\))'
" syn match manSectionHeading  '^[a-z][a-z0-9& ,.-]*[a-z]$'

syn case ignore
syn match manEscapedChar     '\\.'
syn match manString          '"[^"]*"'
syn match manSectionNumber   '(\zs\([nlpo]\|\d[a-z]*\)\?\ze)' contained
syn match manReference       '\<\zs\(\f\|:\)\+(\([nlpo]\|\d[a-z]*\)\?)\ze\(\W\|$\)' contains=manSectionNumber
syn match manFuncArgs        '\<\h\+(\zs\(\([nlpo]\|\d[a-z]*\)\@!.\{-}\)\ze)' contained contains=manString
syn match manFuncCall        '\<\zs\h\+(\(\([nlpo]\|\d[a-z]*\)\@!.\{-}\))\ze' contains=manFuncArgs
syn match manTitle           '^\(\f\|:\)\+([0-9nlpo][a-z]*).*'
syn match manSectionHeading display '^\S.*$'
syn match manHeader         display '^\%1l.*$'
syn match manSubHeading     display '^ \{3\}\S.*$'
syn match manHeaderFile      '\s\zs<\f\+\.h>\ze\(\W\|$\)'
syn match manEmail           '<\?[a-zA-Z0-9_.+-]\+@[a-zA-Z0-9-]\+\.[a-zA-Z0-9-.]\+>\?'
syn match manHighlight       +`.\{-}''\?+
syn match manFlags           '\v[^a-z0-9]\zs-{1,2}[[:alnum:]-_?]+\ze'
" syn match manOptions         '^\s\{7}\zs\(\(\([^, ]\{-1,2},\s\)\+\)[^, ]\{-1,2}\|[^, ]\{-1,2}\)\ze\(\s\{2,}\|$\)'
syn match manOptions         '^\s\{7}\zs\(\(\([^, ]\{-1,2},\s\)\+\)[^, ]\{-1,2}\ze\(\s\+\|$\)\|[^, ]\{-1,2}\ze\(\s\{3,}\|$\)\)'
syn match manURL
      \ `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^' 	<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^' 	<>"]+)[a-zA-Z0-9/]`

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
  syn match manCFuncDefinition display '\<\h\w*\ze\(\s\|\n\)*(' contained
  syn match manCError           display '^\s\+\zsE\(\u\|\d\)\+' contained
  syn match manSignal           display '\C\<\zs\(SIG\|SIG_\|SA_\)\(\d\|\u\)\+\ze\(\W\|$\)'

  " syn region manSynopsis
  "       \ start='^\(LEGACY \)\?SYNOPSIS'hs=s+8
  "       \ end='^\u[A-Z ]*$'me=e-30 keepend
  "       \ contains=manSectionHeading,@c,manCFuncDefinition,manHeaderFile

  syn match manLowerSentence /\n\s\{7}\l.\+[()]\=\%(\:\|.\|-\)[()]\=[{};]\@<!\n$/
        \ display keepend contained contains=manReference
  syn region manSentence
        \ start=/^\s\{7}\%(\u\|\*\)[^{}=]*/
        \ end=/\n$/ end=/\ze\n\s\{3,7}#/ keepend
        \ contained contains=manReference

  syn region manErrors
        \ start='^ERRORS'hs=s+6
        \ end='^\u[A-Z ]*$'me=e-30 keepend
        \ contains=manSignal,manReference,manSectionHeading,manHeaderFile,manCError
  syn region manSynopsis
        \ start='^\%(SYNOPSIS\|SYNTAX\|SINTASSI\|SKŁADNIA\|СИНТАКСИС\|書式\)$'
        \ end='^\%(\S.*\)\=\S$' keepend
        \ contains=manLowerSentence,manSentence,manSectionHeading,manCFuncDefinition,@c

  syn region manExample
        \ start='^EXAMPLES\=$'
        \ end='^\%(\S.*\)\=\S$' keepend
        \ contains=manLowerSentence,manSentence,manSectionHeading,manSubHeading,manCFuncDefinition,@c

  syn match manTable '\s*[│├└┘┤┼┴┌─┬┐]\+\s*'

  " XXX: groupthere doesn't seem to work
  syn sync minlines=500
  "syn sync match manSyncExample groupthere manExample '^EXAMPLES\=$'
  "syn sync match manSyncExample groupthere NONE '^\%(EXAMPLES\=\)\@!\%(\S.*\)\=\S$'
endif

syn match manFile       display '\s\zs\~\?\/[0-9A-Za-z_*/$.{}<>-]*' contained
syn match manEnvVarFile display '\s\zs\$[0-9A-Za-z_{}]\+\/[0-9A-Za-z_*/$.{}<>-]*' contained
syn match manEnvVar     display '\s\zs\(\u\|_\)\{3,}' contained

syn region manFiles
      \ start='^FILES'hs=s+5
      \ end='^\u[A-Z ]*$'me=e-30 keepend
      \ contains=manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manFile,manEnvVarFile

syn region manFiles
      \ start='^ENVIRONMENT'hs=s+11
      \ end='^\u[A-Z ]*$'me=e-30 keepend
      \ contains=manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manEnvVar

" Prevent everything else from matching the last line
execute 'syntax match manFooter display "^\%'.line('$').'l.*$"'

" hi def link manOptionDesc      Constant
" hi def link manLongOptionDesc  Constant

" hi def link manDeprecated      Title
hi def link manTitle           Title
hi def link manSectionNumber   Number
hi def link manSectionHeading  Statement
hi def link manHeader          Title
hi def link manFooter          Title
hi def link manSubHeading      Function
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
hi def link manEnvVar          Identifier
hi def link manHighlight       Statement
hi def link manTable           WarningMsg
hi def link manEscapedChar     SpecialChar
hi def link manString          String

let b:current_syntax = 'man'

" vim:set ft=vim et sw=2:
