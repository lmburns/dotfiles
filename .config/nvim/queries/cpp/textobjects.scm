; extends

(class_specifier
  body: (_) @class.inner) @class.outer

(field_declaration
  type: (enum_specifier)
  default_value: (initializer_list) @class.inner) @class.outer

(for_range_loop
  (_)? @loop.inner) @loop.outer

(template_declaration
  (function_definition) @function.outer) @function.outer.start

(template_declaration
  (struct_specifier) @class.outer) @class.outer.start

(template_declaration
  (class_specifier) @class.outer) @class.outer.start

((lambda_capture_specifier
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((lambda_capture_specifier
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((template_argument_list
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((template_argument_list
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((template_parameter_list
  "," @_start . (_) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((template_parameter_list
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((parameter_list
  "," @_start . (optional_parameter_declaration) @parameter.inner)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((parameter_list
  . (optional_parameter_declaration) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

((initializer_list
  "," @_start . (_) @parameter.inner  @_end)
 (#make-range! "parameter.outer" @_start @parameter.inner))
((initializer_list
  . (_) @parameter.inner . ","? @_end)
 (#make-range! "parameter.outer" @parameter.inner @_end))

(new_expression
  (argument_list) @call.inner) @call.outer

;; ===== CUSTOM =====

; Swappable items
(_) @node

(argument_list (_) @swappable)
(parameter_list (_) @swappable)
(field_initializer_list (_) @swappable)
(field_declaration_list (_) @swappable)
(initializer_list (_) @swappable)
(enumerator_list (_) @swappable)

(lambda_expression
  body: (_) @function.inside) @function.around

(class_specifier
  body: (_) @class.inside) @class.around
