" setlocal foldmethod=syntax
" setlocal foldlevel=20
"
" " Handle heredoc syntax in the dosini syntax.
" " Taken from syntax/perl.ini (:%s/perl/dosini/g).
" if exists("dosini_string_as_statement")
"   hi def link dosiniValueStartEnd   Statement
" else
"   hi def link dosiniValueStartEnd   String
" endif
"
" "[Preferences]
" "DefaultText = <<EOT
" "multi
" "line
" "parameter
" "setting
" "EOT
"
" " " These items are interpolated inside "" strings and similar constructs.
" " syn cluster perlInterpDQ	contains=perlSpecialString,perlVarPlain,perlVarNotInMatches,perlVarSlash,perlVarBlock
" " " These items are interpolated inside '' strings and similar constructs.
" " syn cluster perlInterpSQ	contains=perlSpecialStringU,perlSpecialStringU2
"
" syn match   dosiniNotEmptyLine  "^\s\+$" contained
" syn region  dosiniInterpSQ      start=+'+ skip=+\\'+ end=+'+ contains=@Spell transparent
" syn region  dosiniInterpDQ      start=+"+ skip=+\\"+ end=+"+ contains=@Spell transparent
" " start='\%(\%(\\\\\)*\\\)\@<!"' end=+"+
"
" hi def link dosiniHereDoc String
"
" syn region dosiniSection
"       \ start="^\[" end="\(\n\+\[\)\@="
"       \ contains=dosiniLabel,dosiniHeader,dosiniComment
"       \ keepend fold
"
" syn region dosiniHereDoc            matchgroup=dosiniValueStartEnd
"       \ start=+<<\z(\I\i*\)+        end=+^\z1$+
"       \ contains=dosiniInterpDQ
" syn region dosiniHereDoc            matchgroup=dosiniValueStartEnd
"       \ start=+<<\s*"\z(.\{-}\)"+   end=+^\z1$+
"       \ contains=dosiniInterpDQ
" syn region dosiniHereDoc            matchgroup=dosiniValueStartEnd
"       \ start=+<<\s*'\z(.\{-}\)'+   end=+^\z1$+
"       \ contains=dosiniInterpSQ
" syn region dosiniHereDoc            matchgroup=dosiniValueStartEnd
"       \ start=+<<\s*""+             end=+^$+
"       \ contains=dosiniInterpDQ,dosiniNotEmptyLine
" syn region dosiniHereDoc            matchgroup=dosiniValueStartEnd
"       \ start=+<<\s*''+             end=+^$+
"       \ contains=dosiniInterpSQ,dosiniNotEmptyLine
