; extends

((function_call
  name: [
    (identifier) @_cdef_identifier
    (_ _ (identifier) @_cdef_identifier)
  ]
  arguments: (arguments (string content: _ @c)))
  (#eq? @_cdef_identifier "cdef"))

; vim.rcprequest(123, "nvim_exec_lua", "return vim.api.nvim_buf_get_lines(0, 0, -1, false)", false)
((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments . (_) . (string content: _ @_method) . (string content: _ @lua)))
  (#any-of? @_vimcmd_identifier "vim.rpcrequest" "vim.rpcnotify")
  (#eq? @_method "nvim_exec_lua"))

; highlight string as query if starts with `;; query`
(string content: _ @query (#lua-match? @query "^%s*;+%s?query"))

((comment) @luadoc
  (#lua-match? @luadoc "[-][-][-][%s]*@")
  (#offset! @luadoc 0 3 0 0))


; string.match("123", "%d+")
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "find" "match"))
  arguments: (arguments (_) . (string content: _ @luap)))

(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "gmatch" "gsub"))
  arguments: (arguments (_) (string content: _ @luap)))

; ("123"):match("%d+")
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "find" "match"))
    arguments: (arguments . (string content: _ @luap)))

(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "gmatch" "gsub"))
    arguments: (arguments (string content: _ @luap)))

(comment) @comment

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments . (string content: _ @vim)))
  (#any-of? @_vimcmd_identifier "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec" "vim.api.nvim_exec2"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments . (string content: _ @vim)))
  (#any-of? @_vimcmd_identifier "cmd" "api.nvim_command" "api.nvim_exec" "api.nvim_exec2"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @query) .))
  (#any-of? @_vimcmd_identifier "vim.treesitter.query.set" "vim.treesitter.query.parse_query" "vim.treesitter.query.parse"))

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

;; vim.regex([[\d\+]])
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
