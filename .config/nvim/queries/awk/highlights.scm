; adapted from https://github.com/Beaglefoot/tree-sitter-awk

[
  (identifier)
  (field_ref)
] @variable
(field_ref (_) @variable)

(number) @number

(string) @string
(regex) @string.regex
(escape_sequence) @string.escape

(comment) @comment @spell

(ns_qualified_name (namespace) @namespace)
(ns_qualified_name "::" @punctuation.delimiter)

(func_def name: (_ (identifier) @function) @function)
(func_call name: (_ (identifier) @function) @function)

(func_def (param_list (identifier) @parameter))

[
  "print"
  "printf"
  "getline"
] @function.builtin

[
  (delete_statement)
  (break_statement)
  (continue_statement)
  (next_statement)
  (nextfile_statement)
] @keyword

[
  "func"
  "function"
] @keyword.function

[
  "return"
  "exit"
] @keyword.return

[
  "do"
  "while"
  "for"
  "in"
] @repeat

[
  "if"
  "else"
  "switch"
  "case"
  "default"
] @conditional

[
  "@include"
  "@load"
] @include

"@namespace" @preproc

[
 "BEGIN"
 "END"
 "BEGINFILE"
 "ENDFILE"
] @label

(binary_exp [
  "^"
  "**"
  "*"
  "/"
  "%"
  "+"
  "-"
  "<"
  ">"
  "<="
  ">="
  "=="
  "!="
  "~"
  "!~"
  "in"
  "&&"
  "||"
] @operator)

(unary_exp [
  "!"
  "+"
  "-"
] @operator)

(assignment_exp [
  "="
  "+="
  "-="
  "*="
  "/="
  "%="
  "^="
] @operator)

(ternary_exp [
  "?"
  ":"
] @conditional.ternary)

(update_exp [
  "++"
  "--"
] @operator)

(redirected_io_statement [
  ">"
  ">>"
] @operator)

(piped_io_statement [
  "|"
  "|&"
] @operator)

(piped_io_exp [
  "|"
  "|&"
] @operator)

(field_ref "$" @punctuation.delimiter)

(regex "/" @punctuation.delimiter)
(regex_constant "@" @punctuation.delimiter)

[ ";" "," ] @punctuation.delimiter

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

;; ===== CUSTOM =====

(([
 (identifier)
 (field_ref)
] @variable.builtin)
  (#any-of? @variable.builtin
      "$0"
      "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"

      "BINMODE" "CONVFMT" "FIELDWIDTHS"
      "FPAT"    "FS"      "IGNORECASE"
      "LINT"    "OFMT"    "OFS"
      "ORS"     "PREC"    "ROUNDMODE"
      "RS"      "SUBSEP"  "TEXTDOMAIN"

      "ARGC"    "ARGV"     "ARGIND"
      "ENVIRON" "ERRNO"    "FILENAME"
      "FNR"     "NF"       "FUNCTAB"
      "NR"      "PROCINFO" "RLENGTH"
      "RSTART"  "RT"       "SYMTAB"
   ))

((field_ref (_) @variable.builtin)
  (#any-of? @variable.builtin
      "$0"
      "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"

      "BINMODE" "CONVFMT" "FIELDWIDTHS"
      "FPAT"    "FS"      "IGNORECASE"
      "LINT"    "OFMT"    "OFS"
      "ORS"     "PREC"    "ROUNDMODE"
      "RS"      "SUBSEP"  "TEXTDOMAIN"

      "ARGC"    "ARGV"     "ARGIND"
      "ENVIRON" "ERRNO"    "FILENAME"
      "FNR"     "NF"       "FUNCTAB"
      "NR"      "PROCINFO" "RLENGTH"
      "RSTART"  "RT"       "SYMTAB"
     ))

((func_call
  name: (identifier) @function.builtin)
    (#any-of? @function.builtin
      ;; mathematical
      "atan2"   "cos"      "exp"
      "int"     "log"      "rand"
      "sin"     "sqrt"     "srand"
      ;; manipulation
      "asort"   "asorti"   "gensub"
      "gsub"    "index"    "length"
      "match"   "patsplit" "split"
      "sprintf" "strtonum" "sub"
      "substr"  "tolower"  "toupper"
      ;; output
      "close"  "fflush"   "system"
      ;; time
      "mktime" "strftime" "systime"
      ;; bit
      "and"    "compl"    "lshift"
      "or"     "rshift"   "xor"
      ;; type
      "isarray"        "typeof"
      ;; string-translation
      "bindtextdomain" "dcgettext" "dcngetext"

      "getopt"  "nextfile" "getline"
      "print"   "printf"
                ))

;((identifier) @variable.builtin
;  (#any-of? @variable.builtin "base" "this" "vargv"))
