(_) @spell

[
 "("
 ")"
] @punctuation.bracket

":" @punctuation.delimiter

(tag (name) @text.note (user)? @constant)

((tag ((name) @text.note))
 (#any-of? @text.note "NOTE"))

("text" @text.note
 (#any-of? @text.note "NOTE"))

((tag ((name) @text.warning))
 (#any-of? @text.warning "TODO" "HACK" "WARNING"))

("text" @text.warning
 (#any-of? @text.warning "TODO" "HACK" "WARNING"))

((tag ((name) @text.danger))
 (#any-of? @text.danger "FIXME" "XXX" "BUG"))

("text" @text.danger
 (#any-of? @text.danger "FIXME" "XXX" "BUG"))

; Issue number (#123)
("text" @number (#lua-match? @number "^#[%d]+$"))

; User mention (@user)
("text" @constant (#lua-match? @constant "^[@][%w_-]+$"))

; Bold
("text" @bold (#lua-match? @bold "^\*[%w_-]+\*$"))

; Underline
("text" @underline (#lua-match? @underline "^\_[%w%s%p]+\_$"))

;; FIX: This doesn't work with spaces
; Code
("text" @code (#lua-match? @code "^`[%w%s%p]*`$"))

; (tag
;    "*" @conceal (#set! conceal "")
;    text: (_) @label)
