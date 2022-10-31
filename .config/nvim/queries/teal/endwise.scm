((do_statement "do" @cursor) @endable @indent (#endwise! "end"))
((generic_for_statement body: (for_body "do" @cursor)) @endable @indent (#endwise! "end"))
((while_statement (while_body "do" @cursor)) @endable @indent (#endwise! "end"))
((if_statement "then" @cursor) @endable @indent (#endwise! "end"))
((function_statement (function_signature (arguments)) @cursor) @endable @indent (#endwise! "end"))
; ((record_declaration name: (_) @cursor record_body: (_)? @cursor) @endable @indent (#endwise! "end"))
;; FIX: Get this to work
((record_declaration name: (_) @cursor) @endable @indent (#endwise! "end"))

; record_declaration [22, 0] - [25, 3]
;   name: identifier [22, 13] - [22, 25]
;   record_body: record_body [23, 2] - [25, 3]
;     field [23, 2] - [23, 19]
;       key: identifier [23, 2] - [23, 10]
;       type: simple_type [23, 12] - [23, 19]
;         name: identifier [23, 12] - [23, 19]
;     field [24, 2] - [24, 15]
;       key: identifier [24, 2] - [24, 7]
;       type: simple_type [24, 9] - [24, 15]
;         name: identifier [24, 9] - [24, 15]

; function_statement [27, 0] - [28, 3]
;   name: identifier [27, 15] - [27, 17]
;   signature: function_signature [27, 17] - [27, 29]
;     arguments: arguments [27, 17] - [27, 29]
;       arg [27, 18] - [27, 28]
;         name: identifier [27, 18] - [27, 20]
;         type: simple_type [27, 22] - [27, 28]
;           name: identifier [27, 22] - [27, 28]
;   body: function_body [28, 0] - [28, 3]

; record_declaration [27, 0] - [31, 5]
;   name: identifier [27, 13] - [27, 16]
;   record_body: record_body [29, 0] - [31, 5]
;     field [29, 0] - [29, 28]

; ERROR [27, 0] - [1148, 8]
;   identifier [27, 15] - [27, 17]
;   function_signature [27, 17] - [27, 29]
;     arguments: arguments [27, 17] - [27, 29]
;       arg [27, 18] - [27, 28]
;         name: identifier [27, 18] - [27, 20]
;         type: simple_type [27, 22] - [27, 28]
;           name: identifier [27, 22] - [27, 28]


((ERROR ("do" @cursor @indent)) (#endwise! "end"))
((ERROR ("for" @indent . "do" @cursor)) (#endwise! "end"))
((ERROR ("while" @indent . "do" @cursor)) (#endwise! "end"))
((ERROR ("if" @indent . (_) . "then" @cursor)) (#endwise! "end"))
((ERROR ("function" . (_)? . (function_signature (arguments)) @cursor) @indent) (#endwise! "end"))

; ((ERROR ("record" . (identifier)? @cursor . (_)?) @indent) (#endwise! "end"))
; ((ERROR ("record" . (_)? . (name: (_) @cursor) @indent)) (#endwise! "end"))
; ((ERROR ("record" . (_)? . (record_body (field)) @cursor) @indent) (#endwise! "end"))

("record" @indent . (_) @cursor (#endwise! "end"))
