if exists('b:current_syntax')
  finish
endif

" Get the CTRL-H syntax to handle backspaced text
" runtime! syntax/ctrlh.vim

syntax case ignore
syn match manSectionNumber      '(\zs\([nlpo]\|\d[a-z]*\)\?\ze)' contained
syntax match manReference       '\<\zs\(\f\|:\)\+(\([nlpo]\|\d[a-z]*\)\?)\ze\(\W\|$\)' contains=manSectionNumber
" syntax match manReference      display '[^()[:space:]]\+(\%([0-9][a-z]*\|[nlpox]\))'
syntax match manTitle           '^\(\f\|:\)\+([0-9nlpo][a-z]*).*'
" syntax match manSectionHeading  '^[a-z][a-z0-9& ,.-]*[a-z]$'
syntax match manSectionHeading display '^\S.*$'
syntax match manHeader         display '^\%1l.*$'
syntax match manSubHeading     display '^ \{3\}\S.*$'
syntax match manHeaderFile      '\s\zs<\f\+\.h>\ze\(\W\|$\)'
syntax match manURL             `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^' 	<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^' 	<>"]+)[a-zA-Z0-9/]`
syntax match manEmail           '<\?[a-zA-Z0-9_.+-]\+@[a-zA-Z0-9-]\+\.[a-zA-Z0-9-.]\+>\?'
syntax match manHighlight       +`.\{-}''\?+
syntax match manOptions         '\v[^a-z0-9]\zs-{1,2}[[:alnum:]-_?]+\ze'
" syntax match manNumberedList    '\v\d+'

" below syntax elements valid for manpages 2 & 3 only
" if getline(1) =~ '^\(\f\|:\)\+([23][px]\?)'
if get(b:, 'man_sect', '') =~# '^[023]'
  syntax case match
  syntax include @c $VIMRUNTIME/syntax/c.vim
  " syntax include @cCode syntax/c.vim
  " syntax match manCFuncDefinition  display '\<\h\w*\>\s*('me=e-1 contained
  syntax match manCFuncDefinition display '\<\h\w*\>\ze\(\s\|\n\)*(' contained
  " syntax match manCError           display '^\s\+\[E\(\u\|\d\)\+\]' contained
  syntax match manCError           display '^\s\+\zsE\(\u\|\d\)\+' contained
  syntax match manSignal           display '\C\<\zs\(SIG\|SIG_\|SA_\)\(\d\|\u\)\+\ze\(\W\|$\)'

  " syntax region manSynopsis start='^\(LEGACY \)\?SYNOPSIS'hs=s+8 end='^\u[A-Z ]*$'me=e-30 keepend contains=manSectionHeading,@c,manCFuncDefinition,manHeaderFile
  syntax region manErrors
        \ start='^ERRORS'hs=s+6
        \ end='^\u[A-Z ]*$'me=e-30 keepend
        \ contains=manSignal,manReference,manSectionHeading,manHeaderFile,manCError

  syntax match manLowerSentence /\n\s\{7}\l.\+[()]\=\%(\:\|.\|-\)[()]\=[{};]\@<!\n$/ display keepend contained contains=manReference
  syntax region manSentence start=/^\s\{7}\%(\u\|\*\)[^{}=]*/ end=/\n$/ end=/\ze\n\s\{3,7}#/ keepend contained contains=manReference
  syntax region manSynopsis
        \ start='^\%(SYNOPSIS\|SYNTAX\|SINTASSI\|SKŁADNIA\|СИНТАКСИС\|書式\)$'
        \ end='^\%(\S.*\)\=\S$' keepend
        \ contains=manLowerSentence,manSentence,manSectionHeading,manCFuncDefinition,@c

  syntax region manExample
        \ start='^EXAMPLES\=$'
        \ end='^\%(\S.*\)\=\S$' keepend
        \ contains=manLowerSentence,manSentence,manSectionHeading,manSubHeading,@c,manCFuncDefinition

  " XXX: groupthere doesn't seem to work
  syntax sync minlines=500
  "syntax sync match manSyncExample groupthere manExample '^EXAMPLES\=$'
  "syntax sync match manSyncExample groupthere NONE '^\%(EXAMPLES\=\)\@!\%(\S.*\)\=\S$'
endif

syntax match manFile       display '\s\zs\~\?\/[0-9A-Za-z_*/$.{}<>-]*' contained
syntax match manEnvVarFile display '\s\zs\$[0-9A-Za-z_{}]\+\/[0-9A-Za-z_*/$.{}<>-]*' contained
syntax region manFiles     start='^FILES'hs=s+5 end='^\u[A-Z ]*$'me=e-30 keepend contains=manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manFile,manEnvVarFile

syntax match manEnvVar     display '\s\zs\(\u\|_\)\{3,}' contained
syntax region manFiles     start='^ENVIRONMENT'hs=s+11 end='^\u[A-Z ]*$'me=e-30 keepend contains=manReference,manSectionHeading,manHeaderFile,manURL,manEmail,manEnvVar

" Prevent everything else from matching the last line
execute 'syntax match manFooter display "^\%'.line('$').'l.*$"'

" hi def link manOptionDesc      Constant
" hi def link manLongOptionDesc  Constant

hi def link manTitle           Title
hi def link manSectionNumber   Number
hi def link manSectionHeading  Statement
hi def link manHeader          Title
hi def link manFooter          Title
hi def link manSubHeading      Function
hi def link manOptions         Constant
hi def link manReference       PreProc
hi def link manCFuncDefinition Function
hi def link manHeaderFile      String
hi def link manURL             Underlined
hi def link manEmail           Underlined
hi def link manCError          Identifier
hi def link manSignal          Identifier
hi def link manFile            Identifier
hi def link manEnvVarFile      Identifier
hi def link manEnvVar          Identifier
hi def link manHighlight       Statement

let b:current_syntax = 'man'

" vim:set ft=vim et sw=2:
