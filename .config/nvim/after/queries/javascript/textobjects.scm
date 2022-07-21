(
  (comment) @_start
  (function_declaration) @_end
  (#make-range! "function_block" @_start @_end)
)

(number) @number
(_) @node

; With typescript, we will need to add (object_type)

(string) @string.outer
(string _ _ @string.inner _)

(template_string) @string.outer
; inner must be computed manually

(object
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(object
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

(object_pattern
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(object_pattern
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

(array
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(array
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

(array_pattern
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(array_pattern
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

(formal_parameters
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(formal_parameters
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

; If the array/object pattern is the first parameter, treat its elements as the argument list
(formal_parameters
  . (_
    [(object_pattern "," @_start .  (_) @swappable.inner)
    (array_pattern "," @_start .  (_) @swappable.inner)]
    )
 (#make-range! "swappable.outer" @_start @swappable.inner))
(formal_parameters
  . (_
    [(object_pattern . (_) @swappable.inner . ","? @_end)
    (array_pattern . (_) @swappable.inner . ","? @_end)]
    )
 (#make-range! "swappable.outer" @swappable.inner @_end))

(arguments
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(arguments
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))

(named_imports
  "," @_start .
  (_) @swappable.inner
 (#make-range! "swappable.outer" @_start @swappable.inner))
(named_imports
  . (_) @swappable.inner
  . ","? @_end
 (#make-range! "swappable.outer" @swappable.inner @_end))
