; (operation operator: ["p" "pick" "r" "reword" "e" "edit" "s" "squash" "m" "merge" "d" "drop" "b" "break" "x" "exec"] @keyword)
; (operation operator: ["l" "label" "t" "reset"] @function)
; (operation operator: ["f" "fixup"] @function.special)

(label) @string.special.symbol
((command) @keyword
  (label)? @constant
  (message)? @text @spell)

(option) @operator

(comment) @comment


(ERROR) @error
