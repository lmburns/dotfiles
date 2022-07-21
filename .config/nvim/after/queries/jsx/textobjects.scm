(jsx_element) @tag.outer
(jsx_element (jsx_opening_element) . (_) @tag.inner . (jsx_closing_element))
((jsx_element (jsx_opening_element) . (_) @_start (_) @_end . (jsx_closing_element))
 (#make-range! "tag.inner" @_start @_end))

;; TODO: jsx_fragment
