;; Add _ to constant
((identifier) @constant
 (#lua-match? @constant "^[_A-Z][A-Z_0-9]*$"))

(
  (identifier) @function
  (#eq? @function "utils")
  (#set! conceal "")
  ; (#set! conceal "U")
)

(
  (dot_index_expression
    table: (identifier) @keyword
    (#eq? @keyword  "utils" )
  )
  (#set! conceal "U")
)

; (
;  (function_call
;    (identifier) @require_call
;    (#match? @require_call "require")
;    )
;  (#set! conceal "")
; )

; ((function_call name: (identifier) @function (#eq? @function "print")) (#set! conceal " "))
; (("function" @keyword) (#set! conceal "func"))
; (("not" @keyword) (#set! conceal "!"))

;; vim.*
; (((dot_index_expression) @keyword (#eq? @keyword "vim.fn")) (#set! conceal " "))

;; (
;;   (dot_index_expression) @keyword
;;     (#eq? @keyword  "vim.keymap.set" )
;;   (#set! conceal "襁")
;; )

;; (
;;   (dot_index_expression) @function
;;     (#eq? @function  "vim.cmd" )
;;   (#set! conceal ">")
;; )

; (
;   (dot_index_expression) @keyword
;     (#eq? @keyword  "vim.opt" )
;   (#set! conceal "opt")
; )

; (
;   (dot_index_expression
;   )@keyword
;     (#eq? @keyword  "vim.keymap.set" )
;   (#set! conceal "")
; )

; (("return" @keyword) (#set! conceal ""))
;; (("local" @keyword) (#set! conceal ""))

; (("local" @keyword) (#set! conceal "L"))
; (("local" @keyword) (#set! conceal ""))
; (("function" @keyword) (#set! conceal ""))

;; (("function" @keyword) (#set! conceal ""))
;; (("then" @keyword) (#set! conceal ""))
;; (("not" @keyword) (#set! conceal ""))
;; (("for" @repeat) (#set! conceal ""))
;; (("while" @repeat) (#set! conceal "∞"))

; for -> circle arrow
;; (
;;   (break_statement)@keyword
;;   (#eq? @keyword  "break" )
;;   (#set! conceal "")
;; )
