; ; extends

;; Keywords

"return" @keyword.return

[
 "goto"
 "in"
 "local"
] @keyword

(break_statement) @keyword

(do_statement
[
  "do"
  "end"
] @keyword)

(while_statement
[
  "while"
  "do"
  "end"
] @repeat)

(repeat_statement
[
  "repeat"
  "until"
] @repeat)

(if_statement
[
  "if"
  "elseif"
  "else"
  "then"
  "end"
] @conditional)

(elseif_statement
[
  "elseif"
  "then"
  "end"
] @conditional)

(else_statement
[
  "else"
  "end"
] @conditional)

(for_statement
[
  "for"
  "do"
  "end"
] @repeat)

(function_declaration
[
  "function"
  "end"
] @keyword.function)

(function_definition
[
  "function"
  "end"
] @keyword.function)

;; Operators

[
 "and"
 "not"
 "or"
] @keyword.operator

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "^"
  "#"
  "=="
  "~="
  "<="
  ">="
  "<"
  ">"
  "="
  "&"
  "~"
  "|"
  "<<"
  ">>"
  "//"
  ".."
] @operator

;; Punctuations

[
  ";"
  ":"
  "::"
  ","
  "."
] @punctuation.delimiter

;; Brackets

[
 "("
 ")"
 "["
 "]"
 "{"
 "}"
] @punctuation.bracket

;; Variables

(identifier) @variable

((identifier) @keyword.coroutine
  (#eq? @keyword.coroutine "coroutine"))

(variable_list
   attribute: (attribute
     (["<" ">"] @punctuation.bracket
      (identifier) @attribute)))

;; Labels

(label_statement (identifier) @label)

(goto_statement (identifier) @label)

;; Constants

((identifier) @constant
 (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

(vararg_expression) @constant

(nil) @constant.builtin

[
  (false)
  (true)
] @boolean

;; Tables

(field name: (identifier) @field)

(dot_index_expression field: (identifier) @field)

(table_constructor
[
  "{"
  "}"
] @constructor)

;; Functions

(parameters (identifier) @parameter)

(function_call name: (identifier) @function.call)
(function_declaration name: (identifier) @function)

(function_call name: (dot_index_expression field: (identifier) @function.call))
(function_declaration name: (dot_index_expression field: (identifier) @function))

(method_index_expression method: (identifier) @method.call)

;(function_call
;  (identifier) @function.builtin
;  (#any-of? @function.builtin
;    ;; built-in functions in Lua 5.1
;    "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs"
;    "load" "loadfile" "loadstring" "module" "next" "pairs" "pcall" "print"
;    "rawequal" "rawget" "rawlen" "rawset" "require" "select" "setfenv" "setmetatable"
;    "tonumber" "tostring" "type" "unpack" "xpcall"
;    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
;    "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
;    "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm"))

;; Others

(comment) @comment @spell

; ((comment) @comment.documentation
;   (#lua-match? @comment.documentation "^[-][-][-]"))
;
; ((comment) @comment.documentation
;   (#lua-match? @comment.documentation "^[-][-](%s?)@"))

(hash_bang_line) @preproc

(number) @number

(string) @string @spell

;; Error
(ERROR) @error

;; ===== CUSTOM =====

; (method_index_expression method:
;     (identifier) @method.call
;     (#set! "priority" 105))

((identifier) @variable.builtin
  (#eq? @variable.builtin "self" "super"))

;; I would like these to be variable.builtin.self but highlighting isn't correct with that
; ((identifier) @keyword.self
;   (#eq? @keyword.self "self")
;  (#set! "priority" 105))
;
; ((identifier) @keyword.super
;   (#eq? @keyword.super "super")
;  (#set! "priority" 105))

((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "debug" "io" "jit" "math" "os" "package" "string" "table" "utf8"))

(function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
    "collectgarbage" "dofile" "getfenv" "ipairs"
    "module" "next" "pairs" "print"
    "setfenv"
    "tonumber" "tostring" "type" "unpack"))

; "select"
; (#set! "priority" 105))

(function_call
  (identifier) @function.meta
  (#any-of? @function.meta
    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
    "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
    "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm"))

(function_call
  (identifier) @function.error
  (#any-of? @function.error
    "assert" "error" "pcall" "xpcall"))

(function_call
  (identifier) @function.table
  (#any-of? @function.table
    "rawequal" "rawget" "rawlen" "rawset"
    "getmetatable" "setmetatable"))

(function_call
  (identifier) @function.import
  (#any-of? @function.import
    "require" "module" "load" "loadfile" "loadstring"))

; (function_call
;   (identifier) @function.iter
;   (#any-of? @function.iter
;    "ipairs" "pairs" "select" "next"))

; (function_call
;   (identifier) @function.type
;   (#any-of? @function.type
;     "tonumber" "tostring" "type"))

(dot_index_expression
  field: (identifier) @field.builtin
 (#any-of? @field.builtin
    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
    "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
    "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm")
 (#set! "priority" 105))

(field
  name: (identifier) @field.builtin
 (#any-of? @field.builtin
    "__add" "__band" "__bnot" "__bor" "__bxor" "__call" "__concat" "__div" "__eq" "__gc"
    "__idiv" "__index" "__le" "__len" "__lt" "__metatable" "__mod" "__mul" "__name" "__newindex"
    "__pairs" "__pow" "__shl" "__shr" "__sub" "__tostring" "__unm")
 (#set! "priority" 105))

;; Change capital letter field names to be constants
((dot_index_expression field: (identifier) @constant)
 (#lua-match? @constant "^[A-Z_][A-Z_0-9]*$"))

((identifier) @constant
  (#eq? @constant "_VERSION"))

((identifier) @constant
  (#eq? @constant "_G" "_"))


((identifier) @function
  (#eq? @function "utils")
  (#set! conceal "")
)

((dot_index_expression
    table: (identifier) @keyword
    (#eq? @keyword  "utils" ))
    (#set! conceal "U")
)
