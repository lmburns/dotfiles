;; kinda seems like these sometimes work and sometimes don't
;; maybe it is something to do with the way I have my plugins run

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
