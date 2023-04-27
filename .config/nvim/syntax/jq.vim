" ==============================================================================
" Vim syntax file
" Language:     jq (Command-line JSON processor)
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-jq
" Last Change:  May 9, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if exists('b:current_syntax')
    finish
endif

let s:keepcpo = &cpoptions
set cpoptions&vim

" Comments
syntax match jqComment "#.*$" display contains=jqTodo,@Spell
syntax keyword jqTodo contained TODO FIXME XXX

" Shebang lines:
"   #!/usr/bin/jq -f
"   #!/usr/bin/env -S jq -f
syntax match jqRun "\%^#!.*$"

" Strings and string interpolation
syntax region jqString start='"' skip='\\"' end='"' contains=jqStringInterpol,jqStringParen
syntax region jqStringInterpol matchgroup=jqOperator start='\\(' end=')' contains=jqStringParen contained
syntax region jqStringParen start='(' end=')' contains=jqStringParen contained

" Numbers
syntax match jqNumber "\<\d\+\>"

" Language keywords
syn keyword jqImport      import include module modulemeta
syn keyword jqStatement   reduce foreach while repeat until
syn keyword jqConditional if then elif else end
syn keyword jqOperator    and or not
syn keyword jqException   try catch
syn keyword jqBoolean     true false
syn keyword jqConstant    null
syn keyword jqDef         def nextgroup=jqFunction skipwhite
syn keyword jqError       error stderr debug halt halt_error
syn keyword jqOtherFunc   env nth has in del
syn keyword jqKeyword     as label break empty

" User defined functions
syntax match jqFunction "\<\w\+\>" display contained

" Variables
syntax match jqVariable "\$" nextgroup=jqVariableName
syntax match jqVariableName "\<\w\+\>" display contained

" Format strings (@json, @html, etc.)
syntax match jqFormat "@" nextgroup=jqFormatName
syntax keyword jqFormatName text json html uri csv tsv sh base64 base64d display contained

" Special operators
syntax match jqPipe "|=\||"
syntax match jqAlternate "//=\|//"

" Type keyword
syntax keyword jqType type

" Default highlightings
hi def link jqRun            PreProc
hi def link jqComment        Comment
hi def link jqTodo           Todo
hi def link jqString         String
hi def link jqStringParen    String
hi def link jqStringInterpol String
hi def link jqNumber         Number
hi def link jqStatement      Statement
hi def link jqOperator       Operator
hi def link jqDef            Statement
hi def link jqConditional    Conditional
hi def link jqException      Exception
hi def link jqBoolean        Boolean
hi def link jqConstant       Constant
hi def link jqImport         Statement
hi def link jqFunction       Function
hi def link jqFormat         Macro
hi def link jqFormatName     Macro
hi def link jqVariable       Identifier
hi def link jqVariableName   Identifier
hi def link jqPipe           Operator
hi def link jqAlternate      Operator
hi def link jqType           Keyword
hi def link jqKeyword        Keyword
hi def link jqOtherFunc      Keyword
hi def link jqConstant       Title

" Builtin functions
" List is obtained by running: echo {} | jq -r builtins[]
if get(g:, 'jq_highlight_builtin_functions', 1)
    syn keyword jqBuiltinFunction length utf8length keys keys_unsorted map map_values path
    syn keyword jqBuiltinFunction getpath setpath delpaths to_entries from_entries with_entries select
    syn keyword jqBuiltinFunction leaf_paths

    " length index select contains
    " keys values map
    " first last reverse indices
    " test
    " isfinite isnan isfinite isnormal isempty
    " to_entries tonumber tostring tojson todate todateiso8601 tostream
    " from_entries                  fromjson fromdate fromdateiso8601 fromstream
    " sub gsub match

    " "to_entries" "todate" "todateiso8601" "tojson" "tonumber" "tostream" "tostring"

    syn keyword jqBuiltinFunction arrays booleans builtins combinations finites iterables keys
    syn keyword jqBuiltinFunction normals nulls numbers objects paths scalars strings values
    " leaf_paths indices splits inputs

    " syn keyword jqBuiltinFunction empty

    syn keyword jqBuiltinFunction add any all flatten range floor sqrt tonumber tostring
    syn keyword jqBuiltinFunction infinite nan isinfinite isnan isfinite isnormal sort sort_by
    syn keyword jqBuiltinFunction group_by min max min_by max_by unique unique_by reverse indices
    syn keyword jqBuiltinFunction index rindex inside startswith endswith ltrimstr
    syn keyword jqBuiltinFunction rtrimstr explode implode split join ascii_downcase ascii_upcase
    syn keyword jqBuiltinFunction recurse recurse_down walk transpose bsearch tojson
    syn keyword jqBuiltinFunction fromjson fromdateiso8601 todateiso8601 fromdate todate now
    syn keyword jqBuiltinFunction strptime strftime strflocaltime mktime gmtime localtime test match
    syn keyword jqBuiltinFunction capture scan splits sub gsub isempty limit first last acos
    syn keyword jqBuiltinFunction acosh asin asinh atan atanh cbrt ceil cos cosh erf erfc exp exp10
    syn keyword jqBuiltinFunction exp2 expm1 fabs gamma j0 j1 lgamma log log10 log1p log2 logb
    syn keyword jqBuiltinFunction nearbyint pow10 rint round significand sin sinh sqrt tan tanh
    syn keyword jqBuiltinFunction tgamma trunc y0 y1 atan2 copysign drem fdim fmax fmin fmod frexp
    syn keyword jqBuiltinFunction hypot jn ldexp modf nextafter nexttoward pow remainder scalb
    syn keyword jqBuiltinFunction scalbln yn fma input inputs input_filename
    syn keyword jqBuiltinFunction input_line_number truncate_stream fromstream tostream
    syn keyword jqBuiltinFunction INDEX JOIN IN
    syn keyword jqBuiltinFunction format get_jq_origin get_prog_origin get_search_list
    syn keyword jqBuiltinFunction scalars_or_empty utf8bytelength lgamma_r __loc__

    highlight default link jqBuiltinFunction Function
    syntax keyword jqBuiltinFunctionContains contains
    highlight default link jqBuiltinFunctionContains Function
endif

" Module prefix (similar to namespaces in C++), e.g. mymodule::add(. + 1)
if get(g:, 'jq_highlight_module_prefix', 1)
    syntax match jqModuleName "\<\w\+\>::"me=e-2
    highlight default link jqModuleName PreProc
endif

" Imported JSON file aliases
if get(g:, 'jq_highlight_json_file_prefix', 1)
    syntax match jqJsonName "\$\<\w\+\>::"me=e-2
    highlight default link jqJsonName PreProc
endif

" Objects like .foo
if get(g:, 'jq_highlight_objects', 1)
    syntax match jqObject "\.\<\w\+\>"
    " highlight default link jqObject Type
    highlight default link jqObject Constant
endif

" Highlight user function calls, like foo(.xyz)
if get(g:, 'jq_highlight_function_calls', 1)
    syntax match jqUserFunction "\<\w\+\>("me=e-1
    highlight default link jqUserFunction Function
endif

let b:current_syntax = 'jq'

let &cpoptions = s:keepcpo
unlet s:keepcpo
