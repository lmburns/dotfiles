[
 (for_statement)
 (if_statement)
 (while_statement)
 (switch_statement)
 (case_statement)
 ; (function_definition)
 (struct_specifier)
 (enum_specifier)
 (comment)
 (preproc_if)
 (preproc_elif)
 (preproc_else)
 (preproc_ifdef)
 (initializer_list)
 (gnu_asm_expression)
 (compound_statement) ; Needed here cause i like return types above funcs
] @fold

 (compound_statement
  (compound_statement) @fold)
