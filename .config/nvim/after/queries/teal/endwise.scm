;; ((function_statement arguments: (_) @cursor) @endable @indent (#endwise! "end"))
;; ((function_statement parameters: (_) @cursor) @endable @indent (#endwise! "end"))
;; ((while_statement "do" @cursor) @endable @indent (#endwise! "end"))
;; ((generic_for_statement "do" @cursor) @endable @indent (#endwise! "end"))
((if_statement "then" @cursor) @endable @indent (#endwise! "end"))
;; ((do_statement "do" @cursor) @endable @indent (#endwise! "end"))

;; ((ERROR ("function" . (_)? . (arguments) @cursor) @indent) (#endwise! "end"))
;; ((ERROR ("do" @cursor @indent)) (#endwise! "end"))
;; ((ERROR ("while" @indent . (_) . "do" @cursor)) (#endwise! "end"))
;; ((ERROR ("for" @indent . [(for_generic_clause) (for_numeric_clause)] . "do" @cursor)) (#endwise! "end"))
((ERROR ("if" @indent . (_) . "then" @cursor)) (#endwise! "end"))
