; Variables

(variable) @variable

((variable) @constant.builtin
 (#eq? @constant.builtin "$ENV"))

((variable) @constant.macro
 (#eq? @constant.macro "$__loc__"))

; Properties

(index
   (identifier) @property)

; Labels

(query
   label: (variable) @label)

(query
   break_statement: (variable) @label)

; Literals

(number) @number

(string) @string

[
   "true"
   "false"
] @boolean

("null") @type.builtin

; Interpolation

["\\(" ")"] @character.special

; Format

(format) @attribute

; Functions

(funcdef
   (identifier) @function)

(funcdefargs
   (identifier) @parameter)

; [
;   "reduce"
;   "foreach"
; ] @function.builtin

; jq -n 'builtins | map(split("/")[0]) | unique | .[]'
((funcname) @function.builtin
 (#any-of? @function.builtin
   "IN"
   "INDEX"
   "JOIN"
   "acos"
   "acosh"
   "add"
   "all"
   "any"
   "ascii_downcase"
   "ascii_upcase"
   "asin"
   "asinh"
   "atan"
   "atan2"
   "atanh"
   "bsearch"
   "capture"
   "cbrt"
   "ceil"
   "contains"
   "copysign"
   "cos"
   "cosh"
   "delpaths"
   "drem"
   "endswith"
   "erf"
   "erfc"
   "exp"
   "exp10"
   "exp2"
   "explode"
   "expm1"
   "fabs"
   "fdim"
   "first"
   "flatten"
   "floor"
   "fma"
   "fmax"
   "fmin"
   "fmod"
   "format"
   "frexp"
   "from_entries"
   "fromdate"
   "fromdateiso8601"
   "fromjson"
   "fromstream"
   "gamma"
   "get_jq_origin"
   "get_prog_origin"
   "get_search_list"
   "getpath"
   "gmtime"
   "group_by"
   "gsub"
   "hypot"
   "implode"
   "index"
   "indices"
   "infinite"
   "input"
   "input_filename"
   "input_line_number"
   "inside"
   "isempty"
   "isfinite"
   "isinfinite"
   "isnan"
   "isnormal"
   "j0"
   "j1"
   "jn"
   "join"
   "keys_unsorted"
   "last"
   "ldexp"
   "leaf_paths"
   "length"
   "lgamma"
   "lgamma_r"
   "limit"
   "localtime"
   "log"
   "log10"
   "log1p"
   "log2"
   "logb"
   "ltrimstr"
   "map"
   "map_values"
   "match"
   "max"
   "max_by"
   "min"
   "min_by"
   "mktime"
   "modf"
   "modulemeta"
   "nan"
   "nearbyint"
   "nextafter"
   "nexttoward"
   "now"
   "path"
   "pow"
   "pow10"
   "range"
   "recurse"
   "recurse_down"
   "remainder"
   "reverse"
   "rindex"
   "rint"
   "round"
   "rtrimstr"
   "scalars_or_empty"
   "scalb"
   "scalbln"
   "scan"
   "select"
   "setpath"
   "significand"
   "sin"
   "sinh"
   "sort"
   "sort_by"
   "split"
   "sqrt"
   "startswith"
   "strflocaltime"
   "strftime"
   "strptime"
   "sub"
   "tan"
   "tanh"
   "tgamma"
   "to_entries"
   "todate"
   "todateiso8601"
   "tojson"
   "tonumber"
   "tostream"
   "tostring"
   "transpose"
   "trunc"
   "truncate_stream"
   "unique"
   "unique_by"
   "utf8bytelength"
   "walk"
   "with_entries"
   "y0"
   "y1"
   "yn"
   ; "arrays"
   ; "booleans"
   ; "builtins"
   ; "combinations"
   ; "finites"
   ; "inputs"
   ; "iterables"
   ; "keys"
   ; "normals"
   ; "nulls"
   ; "numbers"
   ; "objects"
   ; "paths"
   ; "scalars"
   ; "splits"
   ; "strings"
   ; "values"

   ; "debug"
   ; "halt"
   ; "halt_error"
   ; "error"
   ; "stderr"

   ; "del"
   ; "empty"
   ; "has"
   ; "in"
   ; "not"

   "env"
   "nth"
   ))
; leaf_paths indices splits inputs

; Keywords

[
  "def"
  "as"
  "label"
  "break"
] @keyword

[
  "if"
  "then"
  "elif"
  "else"
  "end"
] @conditional

[
  "try"
  "catch"
] @exception

[
  "or"
  "and"
] @keyword.operator

; Operators

[
  "."
  "=="
  "!="
  ">"
  ">="
  "<="
  "<"
  "="
  "+"
  "-"
  "*"
  "/"
  "%"
  "+="
  "-="
  "*="
  "/="
  "%="
  "//="
  "|"
  "?"
  "//"
  "?//"
  (recurse) ; ".."
] @operator

; Punctuation

[
  ";"
  ","
  ":"
] @punctuation.delimiter

[
  "[" "]"
  "{" "}"
  "(" ")"
] @punctuation.bracket

; Comments

(comment) @comment @spell

;; === CUSTOM ===

[
  "import"
  "include"
  "module"
] @include

((funcname) @keyword.builtin
 (#any-of? @keyword.builtin
   "type"
  ))

((funcname) @collections
 (#any-of? @collections
   "arrays"
   "booleans"
   "builtins"
   "combinations"
   "finites"
   "inputs"
   "iterables"
   "keys"
   "normals"
   "nulls"
   "numbers"
   "objects"
   "paths"
   "scalars"
   "splits"
   "strings"
   "values"
 ))

((funcname) @function.error
 (#any-of? @function.error
   "debug"
   "halt"
   "halt_error"
   "error"
   "stderr"
 ))

((funcname) @function.other
 (#any-of? @function.other
   "del"
   "empty"
   "has"
   "in"
   "not"
 ))
 ;   "env"
 ;   "nth"

((funcname) @repeat
 (#any-of? @repeat
   "repeat"
   "until"
   "while"
 ))

[
  "reduce"
  "foreach"
] @repeat

((funcname) @function.test
 (#any-of? @function.test
  "test"
 ))

; ((funcname) @collections
;  (#any-of? @collections
;  ))

; ((funcname) @collections
;  (#any-of? @collections
;  ))
