; extends

((comment) @luadoc
  (#lua-match? @luadoc "[-][-][-][%s]*@")
  (#offset! @luadoc 0 3 0 0))

; string.match("123", "%d+")
(function_call
  (dot_index_expression
    field: (identifier) @_match_fn
    (#any-of? @_match_fn "find" "match"))
  arguments: (arguments (_) . (string content: _ @luap)))

(function_call
  (dot_index_expression
    field: (identifier) @_match_fn
    (#any-of? @_match_fn "gmatch" "gsub"))
  arguments: (arguments (_) (string content: _ @luap)))

; ("123"):match("%d+")
(function_call
  (method_index_expression
    method: (identifier) @_match_method
    (#any-of? @_match_method "find" "match"))
    arguments: (arguments . (string content: _ @luap)))

(function_call
  (method_index_expression
    method: (identifier) @_match_method
    (#any-of? @_match_method "gmatch" "gsub"))
    arguments: (arguments (string content: _ @luap)))

(comment) @comment

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments . (string content: _ @vim)))
  (#any-of? @_vimcmd_identifier "api.nvim_command" "api.nvim_exec" "api.nvim_exec2" "cmd"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @query) .))
  (#any-of? @_vimcmd_identifier "ts.query.set" "ts.query.parse_query" "ts.query.parse"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @query) .))
  (#any-of? @_vimcmd_identifier "query.set" "query.parse_query" "query.parse"))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

; ╭───────────╮
; │ vim.regex │
; ╰───────────╯

; vim.regex([[\d\+]])
((function_call
  name: (_) @_vimregex_id
  arguments: (arguments (string content: _ @regex)))
  (#any-of? @_vimregex_id "vim.regex"))

; string:vmatch("123", [[\d\+]])
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "vmatch"))
  arguments: (arguments (_) . (string content: _ @regex)))

; ("123"):vmatch([[\d\+]])
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "vmatch"))
    arguments: (arguments . (string content: _ @regex)))

; ╭───────────╮
; │ rex.count │
; ╰───────────╯

; rex.count("123", [[\d]])
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @regex)))
  (#any-of? @_rex_id "rex.count" "pcre.count" "require(\"rex_pcre2\").count" "require('rex_pcre2').count"))

; string.rxcount("123", [[\d]])
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxcount"))
  arguments: (arguments (_) . (string content: _ @regex)))

; ("123"):rxcount([[\d]])
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxcount"))
    arguments: (arguments . (string content: _ @regex)))

; ╭───────────╮
; │ rex.split │
; ╰───────────╯

; rex.split("he.ll.oo", [[\.]])
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @regex)))
  (#any-of? @_rex_id "rex.split" "pcre.split" "require(\"rex_pcre2\").split" "require('rex_pcre2').split"))

; string.rxsplit()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxsplit"))
  arguments: (arguments (_) . (string content: _ @regex)))

; str:rxsplit()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxsplit"))
    arguments: (arguments . (string content: _ @regex)))

; ╭──────────╮
; │ rex.find │
; ╰──────────╯

; rex.find("he.ll.oo..", [[\.{2}]])
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @regex)))
  (#any-of? @_rex_id "rex.find" "pcre.find" "require(\"rex_pcre2\").find" "require('rex_pcre2').find"))

; string.rxfind()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxfind"))
  arguments: (arguments (_) . (string content: _ @regex)))

; str:rxfind()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxfind"))
    arguments: (arguments . (string content: _ @regex)))

; ╭──────────╮
; │ rex.gsub │
; ╰──────────╯

; rex.gsub("he.ll.oo..", [[\.]], "repl")
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @regex)))
  (#any-of? @_rex_id "rex.gsub" "pcre.gsub" "require(\"rex_pcre2\").gsub" "require('rex_pcre2').gsub"))

; string.rxsub()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxsub"))
  arguments: (arguments (_) . (string content: _ @regex)))

; str:rxsub()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxsub"))
    arguments: (arguments . (string content: _ @regex)))

; ╭────────────╮
; │ rex.gmatch │
; ╰────────────╯

; rex.gmatch()
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @regex)))
  (#any-of? @_rex_id "rex.gmatch" "pcre.gmatch" "require(\"rex_pcre2\").gmatch" "require('rex_pcre2').gmatch"))

; string.rxgmatch()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxgmatch"))
  arguments: (arguments (_) . (string content: _ @regex)))

; str:rxgmatch()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxgmatch"))
    arguments: (arguments . (string content: _ @regex)))

; ╭───────────╮
; │ rex.match │
; ╰───────────╯

; rex.match()
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @regex)))
  (#any-of? @_rex_id "rex.match" "pcre.match" "require(\"rex_pcre2\").match" "require('rex_pcre2').match"))

; string.rxmatch()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxmatch"))
  arguments: (arguments (_) . (string content: _ @regex)))

; str:rxmatch()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxmatch"))
    arguments: (arguments . (string content: _ @regex)))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

; pcall(exec_lua, [[code]])
(
  (function_call
    (identifier)
    (arguments
      (identifier) @_exec_lua
      (string) @lua
    )
  )
  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^%[%[")
  (#offset! @lua 0 2 0 -2)
)

(
  (function_call
    (identifier) @_exec_lua
    (arguments
      (string) @lua)
  )

  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^%[%[")
  (#offset! @lua 0 2 0 -2)
)

(
  (function_call
    (identifier) @_exec_lua
    (arguments
      (string) @lua)
  )

  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^%[=%[")
  (#offset! @lua 0 3 0 -3)
)

(
  (function_call
    (identifier) @_exec
    (arguments
      (string) @vim)
  )

  (#eq? @_exec "exec")
  (#lua-match? @vim "^%[%[")
  (#offset! @vim 0 2 0 -2)
)

(
  (function_call
    (identifier) @_exec_lua
    (arguments
      (string) @lua)
  )

  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @lua "^[\"']")
  (#offset! @lua 0 1 0 -1)
)

(
  (function_call
    (identifier) @_exec
    (arguments
      (string) @vim)
  )

  (#eq? @_exec "exec")
  (#lua-match? @vim "^[\"']")
  (#offset! @vim 0 1 0 -1)
)
