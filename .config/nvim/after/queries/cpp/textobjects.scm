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
