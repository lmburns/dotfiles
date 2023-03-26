(pattern_matcher (regex_pattern) @regex.inner) @regex.outer

((patter_matcher_m
   (start_delimiter) @_start
   (end_delimiter) @_end) @regex.outer
 (#make-range! "regex.inner" @_start @_end))

((regex_pattern_qr
   (start_delimiter) @_start
   (end_delimiter) @_end) @regex.outer
 (#make-range! "regex.inner" @_start @_end))

;; ====== CUSTOM =======

(function_definition
  (identifier) (_) @function.inside) @function.around

(anonymous_function
  (_) @function.inside) @function.around

(argument
  (_) @parameter.inside)

[
  (comments)
  (pod_statement)
] @comment.inside

(comments) @comment.outer
(comments)+ @comment.around

(pod_statement) @comment.around
