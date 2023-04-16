;; Primitives
(boolean) @boolean
(comment) @comment @spell
((comment) @comment.documentation
  (#lua-match? @comment.documentation "^[-][-][-]"))
((comment) @comment.documentation
  (#lua-match? @comment.documentation "^[-][-](%s?)@"))
(shebang_comment) @preproc
(identifier) @variable
((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))
(number) @number
(string) @string
(table_constructor ["{" "}"] @constructor)
(varargs "..." @constant.builtin)
[ "," "." ":" ";" ] @punctuation.delimiter

(escape_sequence) @string.escape
(format_specifier) @string.escape

;; Basic statements/Keywords
[ "if" "then" "elseif" "else" ] @conditional
[ "for" "while" "repeat" "until" ] @repeat
"return" @keyword.return
[ "in" "local" (break) (goto) "do"] @keyword
(label) @label

;; Global isn't a real keyword, but it gets special treatment in these places
(var_declaration "global" @keyword)
(type_declaration "global" @keyword)
(function_statement "global" @keyword)
(record_declaration "global" @keyword)
(enum_declaration "global" @keyword)

;; Ops
[ "=" "as" ] @operator

;; Functions
; (function_statement
;   "function" @keyword.function
;   . name: (_) @function)
(anon_function
  "function" @keyword.function)
(function_body "end" @keyword.function)

(arg name: (identifier) @parameter)

(function_signature
  (arguments
    . (arg name: (identifier) @variable.builtin))
  (#eq? @variable.builtin "self"))

(typeargs
  "<" @punctuation.bracket
  . (_) @parameter
  . ("," . (_) @parameter)*
  . ">" @punctuation.bracket)

(function_call
  (identifier) @function . (arguments))
(function_call
  (index (_) key: (identifier) @function) . (arguments))

;; Types
(record_declaration
  . "record" @keyword
  name: (identifier) @type)
(anon_record . "record" @keyword)
(record_body
  (record_declaration
    . [ "record" ] @keyword
    . name: (identifier) @type))
(record_body
  (enum_declaration
    . [ "enum" ] @keyword
    . name: (identifier) @type))
(record_body
  (typedef
    . "type" @keyword
    . name: (identifier) @type . "="))
(record_body
  (metamethod "metamethod" @keyword))
(record_body
  (userdata) @keyword)

(enum_declaration
  "enum" @keyword
  name: (identifier) @type)

(type_declaration "type" @keyword)
(type_declaration (identifier) @type)
(simple_type name: (identifier) @type)
(type_index (identifier) @type)
(type_union "|" @operator)

;; The rest of it
(var_declaration
  declarators: (var_declarators
      (var name: (identifier) @variable)))
(var_declaration
  declarators: (var_declarators
    (var
      "<" @punctuation.bracket
      . attribute: (attribute) @attribute
      . ">" @punctuation.bracket)))
[ "(" ")" "[" "]" "{" "}" ] @punctuation.bracket

;; Only highlight format specifiers in calls to string.format
;; string.format('...')
;(function_call
;  called_object: (index
;    (identifier) @base
;    key: (identifier) @entry)
;  arguments: (arguments .
;    (string (format_specifier) @string.escape))
;
;  (#eq? @base "string")
;  (#eq? @entry "format"))

;; ('...'):format()
;(function_call
;  called_object: (method_index
;    (string (format_specifier) @string.escape)
;    key: (identifier) @func-name)
;    (#eq? @func-name "format"))


(ERROR) @error

;; ===== CUSTOM =====
; (function_name
;   base: (identifier) @constant)
; (function_name
;   entry: (identifier) @function)
; (function_name
;   method: (identifier) @function)

; toggle_query_editor = "o",
; toggle_hl_groups = "i",
; toggle_injected_languages = "t",
; toggle_anonymous_nodes = "a",
; toggle_language_display = "I",
; focus_language = "f",
; unfocus_language = "F",
; update = "R",
; goto_node = "<cr>",
; show_help = "?"

(bin_op (op) @keyword)
(unary_op (op) @keyword)
(nil) @operator
["end"] @repeat

((identifier) @constant
 (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

((identifier) @constant
  (#eq? @constant "_G"))

; ((identifier) @constant.blank
;   (#eq? @constant.blank "_"))

;; Change capital letter field names to be constants
; ((dot_index_expression field: (identifier) @constant)
;  (#lua-match? @constant "^[A-Z_][A-Z_0-9]*$"))

((identifier) @keyword.coroutine
  (#eq? @keyword.coroutine "coroutine"))

;; I would like these to be variable.builtin.self but highlighting isn't correct with that
((identifier) @keyword.self
  (#eq? @keyword.self "self")
 (#set! "priority" 105))

((identifier) @keyword.super
  (#eq? @keyword.super "super")
 (#set! "priority" 105))

((identifier) @variable.builtin
 (#any-of? @variable.builtin "_VERSION" "debug" "io" "jit" "math" "os" "package" "table" "utf8")
 (#set! "priority" 105))

; (dot_index_expression
;   field: (identifier) @field.builtin
;  (#any-of? @field.builtin
;     "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
;     "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
;     "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm")
;  (#set! "priority" 105))

(index
  ((identifier)?
   key: (identifier) @field.builtin)+
 (#any-of? @field.builtin
    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
    "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
    "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm")
 (#set! "priority" 105))

; (field
;   name: (identifier) @field.builtin
;  (#any-of? @field.builtin
;     "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
;     "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
;     "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm")
;  (#set! "priority" 105))

; (index
;   (identifier)
;   key: (identifier) @field)

;; idx.one.two
(index ((identifier)? key: (identifier) @field)+)

;; table.insert()
(function_call
  called_object: (index
                   (identifier)
                   key: (identifier) @function))

;; M.func()
(function_statement
  "function" @keyword.function
  . name: (function_name
              base: (identifier) @constant
              entry: (identifier) @function))
;; func()
(function_statement
  "function" @keyword.function
  . name: (identifier) @function)

;; me:method()
(function_call
  (method_index (_) key: (identifier) @method) . (arguments))

;; Two chars doesn't work
; (function_statement
;   signature: (function_signature ":" @conceal (#set! conceal "->")))
(function_statement
  signature: (function_signature ":" @conceal (#set! conceal "")))

;function_statement [195, 0] - [218, 3]
;  name: function_name [195, 9] - [195, 21]
;    base: identifier [195, 9] - [195, 10]
;    entry: identifier [195, 11] - [195, 21]
;  signature: function_signature [195, 21] - [195, 57]

((simple_type name: (identifier) @type.builtin)
 (#any-of? @type.builtin
    "any"
    "boolean"
    "string"
    "number"
    "integer"
    "function"
    "table"
    "thread"
    "userdata"
    "lightuserdata"))
(function_type "function" @type.builtin)
