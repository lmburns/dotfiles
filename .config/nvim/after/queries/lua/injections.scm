;; Lua Injections

(comment) @comment

;; Luap
(
 function_call
 (dot_index_expression
   table: (identifier)@_table_name
   field: (identifier)@_field_name
   )
 arguments: (
     arguments (_)(string("string_content")@luap)
     )
 (#eq? @_table_name "string")
 (#any-of? @_field_name "find" "gsub" "gmatch" "match")
 )

((method_index_expression
   table: (identifier)
   method: (identifier)@_method_name
   )
 (arguments(string("string_content")@luap))
 (#any-of? @_method_name "find" "gsub" "match" "gmatch")
 )

; (
;  (function_call
;    (identifier) @_exec_lua
;    (arguments
;      (string) @lua)
;    )
;
;  (#eq? @_exec_lua "exec_lua")
;  (#lua-match? @lua "^%[%[")
;  (#offset! @lua 0 2 0 -2)
;  )
;
; (
;  (function_call
;    (identifier) @_exec_lua
;    (arguments
;      (string) @lua)
;    )
;
;  (#eq? @_exec_lua "exec_lua")
;  (#lua-match? @lua "^[\"']")
;  (#offset! @lua 0 1 0 -1)
;  )

;; Vimscript Injections

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @vim)))
  (#any-of? @_vimcmd_identifier "cmd" "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec"))

((function_call
  name: (_) @_vimcmd_identifier
  arguments: (arguments (string content: _ @query) .))
  (#eq? @_vimcmd_identifier "vim.treesitter.query.set_query"))

;; (
;;   (function_call
;;     (identifier) @_vimcmd_identifier
;;     (arguments
;;       (string) @vim)
;;   )
;;
;;   (#any-of? @_vimcmd_identifier "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec")
;;   (#lua-match? @vim "^[\"']")
;;   (#offset! @vim 0 1 0 -1)
;; )
;;
;; (
;;   (function_call
;;     (identifier) @_vimcmd_identifier
;;     (arguments
;;       (string) @vim)
;;   )
;;
;;   (#any-of? @_vimcmd_identifier "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_exec")
;;   (#lua-match? @vim "^%[%[")
;;   (#offset! @vim 0 2 0 -2)
;; )

;; C Injections

((function_call
  name: [
    (identifier) @_cdef_identifier
    (_ _ (identifier) @_cdef_identifier)
  ]
  arguments: (arguments (string content: _ @c)))
  (#eq? @_cdef_identifier "cdef"))
