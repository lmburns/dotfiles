(_) @spell

((tag
  (name) @text.todo @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#eq? @text.todo "TODO"))

("text" @text.todo @nospell
 (#eq? @text.todo "TODO"))

((tag
  (name) @text.note @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.note "NOTE" "XXX"))

("text" @text.note @nospell
 (#any-of? @text.note "NOTE" "XXX"))

((tag
  (name) @text.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.warning "HACK" "WARNING"))

("text" @text.warning @nospell
 (#any-of? @text.warning "HACK" "WARNING"))

((tag
  (name) @text.danger @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.danger "FIXME" "BUG"))

("text" @text.danger @nospell
 (#any-of? @text.danger "FIXME" "BUG"))

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
("text" @number
 (#lua-match? @number "^#[0-9]+$"))

; User mention (@user)
("text" @constant @nospell
 (#lua-match? @constant "^[@][a-zA-Z0-9_-]+$")
 (#set! "priority" 95))

;; FIX: These doesn't work with spaces
;((string ("string_content") @query) (#lua-match? @query "^%s*;+%s?query"))

; *Bold* *bold two*
; ("text" @bold (#lua-match? @bold "%*[%w%W%s_-]+%*"))
("text" @bold (#lua-match? @bold "^([*](.+)[*])$"))
; ((tag ((name) @bold)) (#lua-match? @bold "(%b**)"))
; ((comment ("text" @bold)) (#lua-match? @bold "(%b**)"))
; ("text" @bold (#lua-match? @bold "(%b**)"))

; _Underline_ _underline two_
("text" @underline (#lua-match? @underline "^_[%w%s%p]+_$"))
; ("text" @underline (#lua-match? @underline "%b__"))

; `Code` `code two` `g<`
("text" @code (#lua-match? @code "^`[%w%s%p]+`$"))
; ("text" @code (#lua-match? @code "%b``"))

; (tag
;    "*" @conceal (#set! conceal "")
;    text: (_) @label)
