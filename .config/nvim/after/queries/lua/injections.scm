;; Lua Injections
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
  (#lua-match? @lua "^[\"']")
  (#offset! @lua 0 1 0 -1)
)

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
;; (
;;   (function_call
;;     (field_expression
;;       (property_identifier) @_cdef_identifier)
;;     (arguments
;;       (string) @c)
;;   )
;;
;;   (#eq? @_cdef_identifier "cdef")
;;   (#lua-match? @c "^[\"']")
;;   (#offset! @c 0 1 0 -1)
;; )
;;
;; (
;;   (function_call
;;     (field_expression
;;       (property_identifier) @_cdef_identifier)
;;     (arguments
;;       (string) @c)
;;   )
;;
;;   (#eq? @_cdef_identifier "cdef")
;;   (#lua-match? @c "^%[%[")
;;   (#offset! @c 0 2 0 -2)
;; )

(comment) @comment
