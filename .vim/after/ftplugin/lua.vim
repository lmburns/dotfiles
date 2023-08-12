setlocal includeexpr=substitute(v:fname,'\\.','/','g').'.lua'
setlocal comments-=:-- comments+=:---,:--
setlocal suffixesadd^=.lua,init.lua
setlocal define=^\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)
" setlocal include=\v<((do|load)file|(x?p|lazy\.)?require|lazy\.(require_on\.(index|modcall|expcall|call_rec)|require_iff))[^'"]*['"]\zs[^'"]+
