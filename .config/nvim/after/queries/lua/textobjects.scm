(string) @string.outer
(string _ _ @string.inner _)

;; (comment) @komment.outer
;; (comment (comment_content @komment.inner))

(_) @node.outer

(arguments (_) @swappable)
(parameters (_) @swappable)
(field) @swappable
(variable_list (_) @swappable)
(expression_list (_) @swappable)

_ @token.inner
(identifier) @token.inner
; FIXME: sometimes gets children

; TODO: token outer (whitespaces)

_ @token.outer
(identifier) @token.outer

; Generalized argument
; TODO: 

; swappable
; TODO: (for_numeric_cause > start)

; swappable: end
; TODO: c style for loop

(for_numeric_clause
  . (_) @swappable.inner
  . ","? @_end
  (#make-range! "swappable.outer" @swappable.inner @_end))

(arguments
  . (_) @swappable.inner
  . ","? @_end
  (#make-range! "swappable.outer" @swappable.inner @_end))

(parameters
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

(variable_list
  . (_) @swappable.inner
  . ","? @_end
  (#make-range! "swappable.outer" @swappable.inner @_end))

(table_constructor
  . (_) @swappable.inner
  . ","? @_end
  (#make-range! "swappable.outer" @swappable.inner @_end))

(expression_list
  . (_) @swappable.inner
  . ","? @_end
  (#make-range! "swappable.outer" @swappable.inner @_end))

; swappable: start

(for_numeric_clause
  "," @_start
  . (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))

(arguments
  "," @_start
  . (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))

(parameters
  "," @_start
  . (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))

(variable_list
  "," @_start
  . (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))

(table_constructor
  "," @_start
  . (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))

(expression_list
  "," @_start
  . (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
