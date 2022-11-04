; inherits: ecma
[
"abstract"
"declare"
"enum"
"export"
"implements"
"interface"
"keyof"
"namespace"
"private"
"protected"
"public"
"type"
"readonly"
"override"
] @keyword

; types

(type_identifier) @type
(predefined_type) @type.builtin

(import_statement "type"
  (import_clause
    (named_imports
      ((import_specifier
          name: (identifier) @type)))))

;; punctuation

(type_arguments
  "<" @punctuation.bracket
  ">" @punctuation.bracket)

(union_type
  "|" @punctuation.delimiter)

(intersection_type
  "&" @punctuation.delimiter)

(type_annotation
  ":" @punctuation.delimiter)

(pair
  ":" @punctuation.delimiter)

"?." @punctuation.delimiter

(property_signature "?" @punctuation.special)
(optional_parameter "?" @punctuation.special)

; Variables

(undefined) @variable.builtin

;;; Parameters
(required_parameter (identifier) @parameter)
(optional_parameter (identifier) @parameter)

(required_parameter
  (rest_pattern
    (identifier) @parameter))

;; ({ a }) => null
(required_parameter
  (object_pattern
    (shorthand_property_identifier_pattern) @parameter))

;; ({ a: b }) => null
(required_parameter
  (object_pattern
    (pair_pattern
      value: (identifier) @parameter)))

;; ([ a ]) => null
(required_parameter
  (array_pattern
    (identifier) @parameter))

;; a => null
(arrow_function
  parameter: (identifier) @parameter)

;; ===== CUSTOM =====
(function_signature name: (identifier) @function)
(index_signature name: (identifier) @field)

;; Change to this an orange highlight group instead of blue
(undefined) @constant.builtin
(override_modifier) @keyword
; (this_type) @variable.builtin
(this_type) @type.builtin

((identifier) @variable.builtin
 (#vim-match? @variable.builtin "^(arguments|module|console|window|document|globalThis)$"))

;; Make anything following `new` highlight as a constructor
(new_expression ((identifier) @constructor
 (#lua-match? @constructor "^[_a-zA-Z]")))
