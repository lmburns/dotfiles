
(
 function_definition
 (identifier)@function_definition
)

; decorator
(decorator) @function.decorator
((decorator (identifier) @function.decorator)
 (#vim-match? @function.decorator "^([A-Z])@!.*$"))


; Function/method docstring
((function_definition
  body: (block . (expression_statement (string) @rst)))
 (#offset! @rst 0 3 0 -3))

((expression_statement (string) @docstring)
 (#vim-match? @docstring "^\"\"\".*\"\"\"$"))


; Attribute docstring
(((expression_statement (assignment)) . (expression_statement (string) @rst))
 (#offset! @rst 0 3 0 -3))
