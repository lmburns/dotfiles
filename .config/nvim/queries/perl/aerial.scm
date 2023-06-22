(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")
) @type

(variable_declaration
  (scope) @modifier
  (single_var_declaration) @name
  (#set! "kind" "Variable")
) @type

(use_no_statement
  (package_name) @name
  (#set! "kind" "Module")
) @type

; ((special_block) @name (#any-of? @name "BEGIN" "END")
;   (#set! "kind" "Constructor")
; ) @type

((special_block) @name @start
  (#set! "kind" "Constructor")
) @type
