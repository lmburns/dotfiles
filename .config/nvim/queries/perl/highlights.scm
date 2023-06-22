; Misc keywords
[
  "next" "last" "redo"
  "goto"
  "package"
;  "do"
;  "eval"
] @keyword

; Keywords for including
[ "use" "no" "require" ] @include

; Keywords that mark conditional statements
[ "if" "elsif" "unless" "else" ] @conditional
(ternary_expression
  ["?" ":"] @conditional.ternary)
(ternary_expression_in_hash
  ["?" ":"] @conditional.ternary)

; Keywords that mark repeating loops
[ "while" "until" "for" "foreach" ] @repeat

; Keyword for return expressions
[ "return" ] @keyword.return

; Keywords for phaser blocks
; TODO: Ideally these would be @keyword.phaser but vim-treesitter doesn't
;   have such a thing yet
; [ "BEGIN" "CHECK" "UNITCHECK" "INIT" "END" ] @keyword.function

; Keywords to define a function
[ "sub" ] @keyword.function

; Lots of builtin functions, except tree-sitter-perl doesn't emit most of
;   these yet
;[
;  "print" "printf" "sprintf" "say"
;  "push" "pop" "shift" "unshift" "splice"
;  "exists" "delete" "keys" "values"
;  "each"
;] @function.builtin


; Variables
[
  (scalar_variable)
  (array_variable)
  (hash_variable)
] @variable

; Special builtin variables
[
  (special_scalar_variable)
  (special_array_variable)
  (special_hash_variable)
  (special_literal)
  (super)
] @variable.builtin

; Integer numbers
[
  (integer)
  (hexadecimal)
] @number

; Float numbers
[
  (floating_point)
  (scientific_notation)
] @float

; version sortof counts as a kind of multipart integer
(version) @constant

; Package names are types
(package_name) @type

; The special SUPER:: could be called a namespace. It isn't really but it
;   should highlight differently and we might as well do it this way
(super) @namespace

; Comments are comments
(comments) @comment
(comments) @spell

((source_file . (comments) @preproc)
  (#lua-match? @preproc "^#!/"))

; POD should be handled specially with its own embedded subtype but for now
;   we'll just have to do this.
(pod_statement) @text

(method_invocation
  function_name: (identifier) @method.call)
(call_expression
  function_name: (identifier) @function.call)

;; ----------

(use_constant_statement
  constant: (identifier) @constant)

(named_block_statement
  function_name: (identifier) @function)

(function_definition
  name: (identifier) @function)

[
(function)
(map)
(grep)
(bless)
] @function

[
"("
")"
"["
"]"
"{"
"}"
] @punctuation.bracket
(standard_input_to_variable) @punctuation.bracket

[
"=~"  "!~"
"!"
"++"  "+="  "+"
"--"  "-="  "-"
"**"  "**="
"*"   "*="
"%"   "%="
"/"   "/="
"."   ".="
".." ; range
"||"
"||="
"&&="
"//" ; logical defined or
"//=" ; logical defined or assign

"=="  "!="  "="
"<="  ">="
"<"   ">"
"<=>" ; comparison
; "~~" ; smart match

"|"  ; bitwise or
"|=" ; bitwise or assign
"|.=" ; bitwise or
"&"  ; bitwise and
"&=" ; bitwise and assign
"&.=" ; bitwise and
"^" ; bitwise xor
"^=" ; bitwise xor assign
"^.="
"~"  ; bitwise negation; always treats arguments as number
">>" ; right shift
">>=" ; right shift assign
"<<" ; left shift
"<<" ; left shift
"<<=" ; left shift assign
"->" ; dereference
"\\" ; creates references
; "~." ; bitwise negation; always treats argument as string
; "x" ; multiply string/number
; "x=" ; multiply string/number assign
(arrow_operator)
(hash_arrow_operator)
(array_dereference)
(hash_dereference)
(to_reference)
(type_glob)
(hash_access_variable)
] @operator

; Keywords that are regular infix operators
[
  "and" "or" "not" "xor"
  "eq" "ne" "lt" "le" "ge" "gt" "cmp" "isa"
] @keyword.operator

[
(regex_option)
(regex_option_for_substitution)
(regex_option_for_transliteration)
] @parameter

(type_glob
  (identifier) @variable)

[
(word_list_qw)
(command_qx_quoted)
(string_single_quoted)
(string_double_quoted)
(string_qq_quoted)
(bareword)
(transliteration_tr_or_y)
] @string

[
(pattern_matcher)
(regex_pattern_qr)
(patter_matcher_m)
(substitution_pattern_s)
] @string.regex

(escape_sequence) @string.escape

[
","
(semi_colon)
(start_delimiter)
(end_delimiter)
(ellipsis_statement)
] @punctuation.delimiter

(function_attribute) @field

(function_signature) @type

;; ===== CUSTOM ======

;; === Scalar ===
; "chop"   "chomp"   "chr"
; "crypt"  "index"   "rindex"
; "lc"     "lcfirst" "length"
; "ord"    "pack"    "sprintf"
; "substr" "uc"      "ucfirst"
;? "fc"

;; === Regex ===
; "pos" "quotemeta" "split" "study"

;; === Numeric ===
; "abs"  "atan2" "cos"
; "hex"  "int"   "log"
; "oct"  "rand"  "sin"
; "sqrt" "srand"
;? "exp"

;; === List ===
; "splice"  "unshift" "shift"
; "push"    "pop"     "join"
; "reverse" "grep"    "map"
; "sort"    "unpack"

;; === Hash ===
; "delete" "each" "exists"
; "keys" "values"

;; === io Func ===
; "syscall" "dbmopen" "dbmclose"

;; === File Desc ===
; "fcntl" "flock" "ioctl"
; "open" "opendir" "read"
; "seek" "seekdir"
; "sysopen" "sysread" "sysseek"
; "syswrite" "truncate" "binmode"
; "close" "closedir" "eof"
; "fileno" "getc" "lstat"
; "print" "printf" "write"
; "readline" "readpipe" "readdir"
; "rewinddir" "say" "select"
; "stat" "tell" "telldir"

;; === Vector ===
; "vec"

;; === Files ===
; "chdir" "chmod" "chown" "chroot"
; "glob" "link" "mkdir" "readlink"
; "rename" "rmdir" "symlink" "umask"
; "unlink" "utime"

;; === Flow ===
; "caller" "die" "dump"
; "eval" "exit" "wantarray"
;? "evalbytes"

(call_expression
  function_name: (identifier) @function.exit
  (#any-of? @function.exit
   "caller" "delete" "die" "dump" "exit"))

;; === Include ===
; "use" "require"
;? import unimport
;; attributes attrs autodie autouse parent base bigint bignum bigrat blib bytes charnames constant diagnostics encoding

;; === Proc ===
; "alarm" "exec" "exit" "fork"
; "getpgrp" "getppid" "getpriority"
; "kill" "pipe" "setpgrp" "setpriority"
; "sleep" "system" "times"
; "wait" "waitpid"

;; === Socket ===
; "accept" "bind" "connect"
; "getpeername" "getsockname" "getsockopt"
; "listen" "recv" "send" "setsockopt"
; "shutdown" "socket" "socketpair"

;; === IPC ===
; "msgctl" "msgget" "msgrcv" "msgsnd"
; "semctl" "semget" "semop"
; "shmctl" "shmget" "shmread" "shmwrite"

;; === Network ===
; "endhostent"       "endnetent"      "endprotoent"   "endservent"
; "gethostent"       "getnetent"      "getnetbyaddr"  "getnetbyname"
; "getprotobynumber" "getprotobyname" "getservbyname" "getservbyport"
; "getgrent"         "gethostbyaddr"  "gethostbyname" "getprotoent"
; "getpwent"         "getservent"     "setpwent"      "setservent"
; "setgrent"         "sethostent"     "setnetent"     "setprotoent"

;; === PWord ===
; "getpwnam" "getpwuid" "getgrgid" "getgrnam"
; "getlogin" "endgrent" "endpwent"

;; === Time ===
; "gmtime" "localtime" "time"

;; === Misc ===
; "warn"   "format" "formline" "reset"
; "scalar" "prototype"
; "tie"    "tied"   "untie"
;? "lock"

; "local" "my" "our" "ref"
; "break" "goto" "return" "not"
; "defined" "redo" "state" "last" "next" "bless"
; "undef"

(call_expression
  function_name: (identifier) @function.other
  (#any-of? @function.other
    "eval" "undef" "defined" "ref"))

(call_expression
  function_name: (identifier) @function.underscore
  (#any-of? @function.underscore
    "_"))

[
  "my" "our" "local" "state"
] @keyword.scope

; allows highlighting 'constant' keyword
(use_constant_statement) @function.other
(use_no_feature_statement) @function.other

(true) @boolean
(false) @boolean

;"import" "unimport"

[ "BEGIN" "CHECK" "UNITCHECK" "INIT" "END" ] @keyword.block

[
(sort)
(push)
] @function

; "AUTOLOAD" "BEGIN" "CHECK"
; "DESTROY"  "END"   "INIT"
; "UNITCHECK"
