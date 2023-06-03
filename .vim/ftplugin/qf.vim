if exists('b:current_syntax')
    finish
end

if !empty('w:quickfix_title') && w:quickfix_title =~# '^\*.*[Oo]utline'
    syn match Function /^.\?\s\?\(Function\)\s*/ nextgroup=qfSeparator
    syn match Function /^.\?\s\?\(Method\)\s*/ nextgroup=qfSeparator
    syn match Structure /^.\?\s\?\(Interface\|Struct\|Class\|Enum\)\s*/ nextgroup=qfSeparator
    syn match Statement /^.\?\s\?\(Constructor\)\s*/ nextgroup=qfSeparator
    syn match Normal /^.\?\s\?\(Variable\)\s*/ nextgroup=qfSeparator
    syn match Constant /^.\?\s\?\(Constant\)\s*/ nextgroup=qfSeparator
    syn match Identifier /^.\?\s\?\(Object\)\s*/ nextgroup=qfSeparator
    syn match Identifier /^.\?\s\?\(Field\|Key\|Property\)\s*/ nextgroup=qfSeparator
    syn match Identifier /^.\?\s\?\(EnumMember\)\s*/ nextgroup=qfSeparator
    syn match Number /^.\?\s\?\(Number\)\s*/ nextgroup=qfSeparator
    syn match Conditional /^.\?\s\?\(Package\)\s*/ nextgroup=qfSeparator
    syn match Type /^.\?\s\?\(Type\)\s*/ nextgroup=qfSeparator
    syn match Type /^.\?\s\?\(TypeParameter\)\s*/ nextgroup=qfSeparator
    syn match Boolean /^.\?\s\?\(Null\)\s*/ nextgroup=qfSeparator
    syn match Operator /^.\?\s\?\(Operator\)\s*/ nextgroup=qfSeparator
    syn match String /^.\?\s\?\(String\)\s*/ nextgroup=qfSeparator
    syn match Boolean /^.\?\s\?\(Boolean\)\s*/ nextgroup=qfSeparator
    syn match Type /^.\?\s\?\(Array\)\s*/ nextgroup=qfSeparator
    syn match Include /^.\?\s\?\(Module\)\s*/ nextgroup=qfSeparator
    syn match StorageClass /^.\?\s\?\(Namespace\)\s*/ nextgroup=qfSeparator
    syn match Statement /^.\?\s\?\(Event\)\s*/ nextgroup=qfSeparator
    syn match Title /^.\?\s\?\(File\)\s*/ nextgroup=qfSeparator

    syn match Constant /^\(associated\|constant\)\s*/ nextgroup=qfSeparator
    syn match Identifier /^\(field\)\s*/ nextgroup=qfSeparator
    syn match Function /^\(function\)\s*/ nextgroup=qfSeparator
    syn match Include /^\(import\)\s*/ nextgroup=qfSeparator
    syn match Statement /^\(method\)\s*/ nextgroup=qfSeparator
    syn match HLArgsParam /^\(parameter\)\s*/ nextgroup=qfSeparator
    syn match Label /^\(property\)\s*/ nextgroup=qfSeparator
    syn match Structure /^\(struct\)\s*/ nextgroup=qfSeparator
    syn match Function /^\(var\)\s*/ nextgroup=qfSeparator

    syn match qfSeparator /│/ contained nextgroup=qfLineNr
    syn match qfLineNr /[^│]*/ contained

    hi def link qfSeparator Delimiter
    hi def link qfLineNr LineNr
    hi HLArgsParam guifg=#ea6962
else
    syn match qfFileName /^[^│]*/ nextgroup=qfSeparatorLeft
    syn match qfSeparatorLeft /│/ contained nextgroup=qfLineNr
    syn match qfLineNr /[^│]*/ contained nextgroup=qfSeparatorRight
    syn match qfSeparatorRight '│' contained nextgroup=qfError,qfWarning,qfInfo,qfNote
    syn match qfError / E .*$/ contained
    syn match qfWarning / W .*$/ contained
    syn match qfInfo / I .*$/ contained
    syn match qfNote / [NHZ] .*$/ contained

    hi def link qfFileName Function
    hi def link qfSeparatorLeft Delimiter
    hi def link qfSeparatorRight Delimiter
    hi def link qfLineNr LineNr
    hi def link qfError CocErrorSign
    hi def link qfWarning CocWarningSign
    hi def link qfInfo CocInfoSign
    hi def link qfNote CocHintSign
endif

let b:current_syntax = "qf"
