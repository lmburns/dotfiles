(identifier) @variable
((identifier) @constant
 (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

;; Keywords

[
  "if"
  "else"
  "elseif"
  "endif"
] @conditional

[
  "try"
  "catch"
  "finally"
  "endtry"
  "throw"
] @exception

[
  "for"
  "endfor"
  "in"
  "while"
  "endwhile"
  "break"
  "continue"
] @repeat

[
  "function"
  "endfunction"
] @keyword.function

;; Function related
((function_declaration name: (_) @function)
 (#set! "priority" 101))
; (call_expression function: (identifier) @function.call)
; (call_expression function: (scoped_identifier (identifier) @function.call))
(parameters (identifier) @parameter)
(default_parameter (identifier) @parameter)

[ (bang) (spread) ] @punctuation.special

[ (no_option) (inv_option) (default_option) (option_name) ] @variable.builtin

(([
  (scope)
  "a:"
  "$"
] @namespace)
 (#set! "priority" 101))

;; Commands and user defined commands

[
  "let"
  "unlet"
  "const"
  "call"
  "execute"
  "normal"
  "set"
  "setfiletype"
  "setlocal"
  "silent"
  "echo"
  "echon"
  "echohl"
  "echomsg"
  "echoerr"
  "autocmd"
  "augroup"
  "return"
  "syntax"
  "filetype"
  "source"
  "lua"
  "ruby"
  "perl"
  "python"
  "highlight"
  "command"
  "delcommand"
  "comclear"
  "colorscheme"
  "startinsert"
  "stopinsert"
  "global"
  "runtime"
  "wincmd"
  "cnext"
  "cprevious"
  "cNext"
  "vertical"
  "leftabove"
  "aboveleft"
  "rightbelow"
  "belowright"
  "topleft"
  "botright"
  (unknown_command_name)
  "edit"
  "enew"
  "find"
  "ex"
  "visual"
  "view"
  "eval"
] @keyword
(map_statement cmd: _ @keyword)
(command_name) @function.macro

;; Filetype command

(filetype_statement [
  "detect"
  "plugin"
  "indent"
  "on"
  "off"
] @keyword)

;; Syntax command

(syntax_statement (keyword) @string)
(syntax_statement [
  "enable"
  "on"
  "off"
  "reset"
  "case"
  "spell"
  "foldlevel"
  "iskeyword"
  "keyword"
  "match"
  "cluster"
  "region"
  "clear"
  "include"
] @keyword)

(syntax_argument name: _ @keyword)

[
  "<buffer>"
  "<nowait>"
  "<silent>"
  "<script>"
  "<expr>"
  "<unique>"
] @constant.builtin

(augroup_name) @namespace

(au_event) @constant
(normal_statement (commands) @constant)

;; Highlight command

(hl_attribute
  key: _ @property
  val: _ @constant)

(hl_group) @type

(highlight_statement [
  "default"
  "link"
  "clear"
] @keyword)

;; Command command

(command) @string

(command_attribute
  name: _ @property
  val: (behavior
    name: _ @constant
    val: (identifier)? @function)?)

;; Edit command
(plus_plus_opt
  val: _? @constant) @property
(plus_cmd "+" @property) @property

;; Runtime command

(runtime_statement (where) @keyword.operator)

;; Colorscheme command

(colorscheme_statement (name) @string)

;; Literals

(string_literal) @string
(integer_literal) @number
(float_literal) @float
(comment) @comment @spell
(line_continuation_comment) @comment @spell
(pattern) @string.special
(pattern_multi) @string.regex
(filename) @string
(heredoc (body) @string)
(heredoc (parameter) @keyword)
[ (marker_definition) (endmarker) ] @label
(literal_dictionary (literal_key) @label)

;; Operators

[
  "||"
  "&&"
  "&"
  "+"
  "-"
  "*"
  "/"
  "%"
  ".."
  "is"
  "isnot"
  "=="
  "!="
  ">"
  ">="
  "<"
  "<="
  "=~"
  "!~"
  "="
  "+="
  "-="
  "*="
  "/="
  "%="
  ".="
  "..="
  "<<"
  "=<<"
  (match_case)
] @operator

; Some characters have different meanings based on the context
(unary_operation "!" @operator)
(binary_operation "." @operator)


;; Punctuation

[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
  "#{"
] @punctuation.bracket

(field_expression "." @punctuation.delimiter)

[
  ","
  ":"
] @punctuation.delimiter

(ternary_expression ["?" ":"] @conditional.ternary)

; Options
((set_value) @number
 (#lua-match? @number "^[%d]+(%.[%d]+)?$"))

(inv_option "!" @operator)
(set_item "?" @operator)

((set_item
   option: (option_name) @_option
   value: (set_value) @function)
  (#any-of? @_option
    "tagfunc" "tfu"
    "completefunc" "cfu"
    "omnifunc" "ofu"
    "operatorfunc" "opfunc"))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

((identifier) @variable.self
  (#eq? @variable.self "self")
  (#set! "priority" 102))

((scoped_identifier
  (scope) @_scope . (identifier) @type)
 (#eq? @_scope "v:")
 (#any-of? @type
    "t_bool" "t_dict" "t_float" "t_func" "t_list" "t_number" "t_string" "t_blob"
    "_null_blob" "_null_dict" "_null_list" "_null_string"
  ))

((scoped_identifier
  (scope) @_scope . (identifier) @boolean)
 (#eq? @_scope "v:")
 (#any-of? @boolean "true" "false" "null"))

; (call_expression
;    function: (field_expression
;      value: (_) @_value
;       (#not-has-type? @_value string_literal)) @function.call
;    (#set! "priority" 101))

(call_expression
   function: (field_expression
     value: (_)
     field: (_) @function.call)
   (#set! "priority" 101))

; (call_expression
;    function: (field_expression
;      value: (scoped_identifier)))

((call_expression
  function: (identifier) @function.call))

(call_expression
  function: (scoped_identifier
              (identifier) @function.call))

(field_expression
      value: (_)
      field: (identifier) @field)
