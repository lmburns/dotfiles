(macro_invocation
  (token_tree) @rust)

(macro_definition
  (macro_rule
    left: (token_tree_pattern) @rust
    right: (token_tree) @rust))

[
  (line_comment)
  (block_comment)
] @comment

(
  (macro_invocation
    macro: ((identifier) @_html_def)
    (token_tree) @html)

    (#eq? @_html_def "html")
)

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex (#eq? @_regex "Regex")
    name: (identifier) @_new (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal) @regex))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier (identifier) @_regex (#eq? @_regex "Regex").)
    name: (identifier) @_new (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal) @regex))

;; ===== CUSTOM =====
(
 ((line_comment) @_comment_start
                 (#eq? @_comment_start "/// ```")) @_start

 (line_comment) @rust

 ((line_comment) @_comment_end
                 (#eq? @_comment_end "/// ```")) @_end

 (#offset! @rust 0 4 0 0)
 )

(
 ((line_comment) @_comment_start
                 (#match? @_comment_start "^//(/|\!) ```(rust)?")) @_start

 (line_comment) @rust

 ((line_comment) @_comment_end
                 (#match? @_comment_end "//(/|\!) ```")) @_end

 (#offset! @rust 0 4 0 0)
 )
