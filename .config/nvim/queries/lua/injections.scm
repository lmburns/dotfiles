; string.match("123", "%d+")
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "find" "match"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "luap"))))

(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "gmatch" "gsub"))
  arguments: (arguments (_) (string content: _ @injection.content (#set! injection.language "luap"))))

; ("123"):match("%d+")
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "find" "match"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "luap"))))

(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "gmatch" "gsub"))
    arguments: (arguments (string content: _ @injection.content (#set! injection.language "luap"))))

(comment content: (_) @injection.content
  (#set! injection.language "comment"))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; C
((function_call
  name: [
    (identifier) @_cdef_identifier
    (_ _ (identifier) @_cdef_identifier)
  ]
  arguments:
    (arguments
      (string content: _ @injection.content)))
  (#set! injection.language "c")
  (#eq? @_cdef_identifier "cdef"))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Vim

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @injection.content)))
  (#set! injection.language "vim")
  (#any-of? @_vimcmd_identifier "api.nvim_command" "api.nvim_command" "api.nvim_exec2"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @injection.content) .))
  (#set! injection.language "query")
  (#any-of? @_vimcmd_identifier "ts.query.set" "ts.query.parse"))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @injection.content)))
  (#set! injection.language "vim")
  (#any-of? @_vimcmd_identifier "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_command" "vim.api.nvim_exec2"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @injection.content) .))
  (#set! injection.language "query")
  (#any-of? @_vimcmd_identifier "vim.treesitter.query.set" "vim.treesitter.query.parse"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments . (_) . (string content: _ @_method) . (string content: _ @injection.content)))
  (#any-of? @_vimcmd_identifier "vim.rpcrequest" "vim.rpcnotify")
  (#eq? @_method "nvim_exec_lua")
  (#set! injection.language "lua"))
;
; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(string content: _ @injection.content
 (#lua-match? @injection.content "^%s*;+%s?query")
 (#set! injection.language "query"))

(comment content: (_) @injection.content
  (#lua-match? @injection.content "^[-][%s]*@")
  (#set! injection.language "luadoc")
  (#offset! @injection.content 0 1 0 0))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

; ╭───────────╮
; │ vim.regex │
; ╰───────────╯

; vim.regex([[\d\+]])
((function_call
  name: (_) @_vimregex_id
  arguments: (arguments (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_vimregex_id "vim.regex"))

; string:vmatch("123", [[\d\+]])
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "vmatch"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; ("123"):vmatch([[\d\+]])
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "vmatch"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ╭───────────╮
; │ rex.count │
; ╰───────────╯

; rex.count("123", [[\d]])
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_rex_id "rex.count" "pcre.count" "require(\"rex_pcre2\").count" "require('rex_pcre2').count"))

; string.rxcount("123", [[\d]])
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxcount"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; ("123"):rxcount([[\d]])
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxcount"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ╭───────────╮
; │ rex.split │
; ╰───────────╯

; rex.split("he.ll.oo", [[\.]])
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_rex_id "rex.split" "pcre.split" "require(\"rex_pcre2\").split" "require('rex_pcre2').split"))

; string.rxsplit()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxsplit"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; str:rxsplit()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxsplit"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ╭──────────╮
; │ rex.find │
; ╰──────────╯

; rex.find("he.ll.oo..", [[\.{2}]])
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_rex_id "rex.find" "pcre.find" "require(\"rex_pcre2\").find" "require('rex_pcre2').find"))

; string.rxfind()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxfind"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; str:rxfind()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxfind"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ╭──────────╮
; │ rex.gsub │
; ╰──────────╯

; rex.gsub("he.ll.oo..", [[\.]], "repl")
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_rex_id "rex.gsub" "pcre.gsub" "require(\"rex_pcre2\").gsub" "require('rex_pcre2').gsub"))

; string.rxsub()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxsub"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; str:rxsub()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxsub"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ╭────────────╮
; │ rex.gmatch │
; ╰────────────╯

; rex.gmatch()
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_rex_id "rex.gmatch" "pcre.gmatch" "require(\"rex_pcre2\").gmatch" "require('rex_pcre2').gmatch"))

; string.rxgmatch()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxgmatch"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; str:rxgmatch()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxgmatch"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ╭───────────╮
; │ rex.match │
; ╰───────────╯

; rex.match()
((function_call
  name: (_) @_rex_id
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))
  (#any-of? @_rex_id "rex.match" "pcre.match" "require(\"rex_pcre2\").match" "require('rex_pcre2').match"))

; string.rxmatch()
(function_call
  (dot_index_expression
    field: (identifier) @_method
    (#any-of? @_method "rxmatch"))
  arguments: (arguments (_) . (string content: _ @injection.content (#set! injection.language "regex"))))

; str:rxmatch()
(function_call
  (method_index_expression
    method: (identifier) @_method
    (#any-of? @_method "rxmatch"))
    arguments: (arguments . (string content: _ @injection.content (#set! injection.language "regex"))))

; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

; pcall(exec_lua, [[code]])
((function_call
    (identifier)
    (arguments
      (identifier) @_exec_lua
      (string) @injection.content))
  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @injection.content "^%[%[")
  (#set! injection.language "lua")
  (#offset! @injection.content 0 2 0 -2)
)

((function_call
    (identifier) @_exec_lua
    (arguments (string) @injection.content))
  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @injection.content "^%[%[")
  (#set! injection.language "lua")
  (#offset! @injection.content 0 2 0 -2)
)

((function_call
    (identifier) @_exec_lua
    (arguments (string) @injection.content))
  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @injection.content "^%[=%[")
  (#set! injection.language "lua")
  (#offset! @injection.content 0 3 0 -3)
)

((function_call
    (identifier) @_exec
    (arguments (string) @injection.content))
  (#eq? @_exec "exec")
  (#lua-match? @injection.content "^%[%[")
  (#set! injection.language "vim")
  (#offset! @injection.content 0 2 0 -2)
)

((function_call
    (identifier) @_exec_lua
    (arguments (string) @injection.content))
  (#eq? @_exec_lua "exec_lua")
  (#lua-match? @injection.content "^[\"']")
  (#set! injection.language "lua")
  (#offset! @injection.content 0 1 0 -1)
)

((function_call
    (identifier) @_exec
    (arguments (string) @injection.content))
  (#eq? @_exec "exec")
  (#lua-match? @injection.content "^[\"']")
  (#set! injection.language "vim")
  (#offset! @injection.content 0 1 0 -1)
)
