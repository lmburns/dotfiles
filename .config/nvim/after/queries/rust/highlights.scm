(
 function_item
 (
  identifier
  )@function_definition
)

;; TODO: Try and replace doc comment symbol with a document icon
;; (
;;  (line_comment) @text
;;   (#lua-match? @text "^//[!/]")
;;   (#set! conceal "")
;; )

(("->" @operator) (#set! conceal ""))
;; (("fn" @keyword.function) (#set! conceal ""))

(("use"    @keyword) (#set! conceal ""))
(("return" @keyword) (#set! conceal ""))
(("break" @keyword) (#set! conceal ""))

; (type_arguments ("<" @punctuation.bracket (#set! conceal "⟨")))
; (type_arguments (">" @punctuation.bracket (#set! conceal "⟩")))
; (type_parameters ("<" @punctuation.bracket (#set! conceal "⟨")))
; (type_parameters (">" @punctuation.bracket (#set! conceal "⟩")))

;; Bolden constants starting with an underscore
;; ((identifier) @type
;;  (#lua-match? @type "^_*[A-Z]"))
((identifier) @constant
 (#lua-match? @constant "^_*[A-Z][A-Z%d_]*$"))

;; Things that have been modified upstream
;;
;; Change macro_rules! back to red
("macro_rules!" @keyword)
;; Change ! in macros back to orange
(macro_invocation "!" @operator)
;; Change |closure| pipes back to orange
((closure_parameters "|"    @operator))
;; Change <> back to orange
(type_arguments  ["<" ">"] @operator)
;; (type_parameters ["<" ">"] @punctuation.closure)
