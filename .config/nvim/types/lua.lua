---@meta

---@class Array<T>:  { [integer]: T }
---@class Vector<T>: { [integer]: T }
---@class Vec<T>:    { [integer]: T }
---@class Dict<T>:   { [string]: T }
---@class Hash<T>:   { [string]: T }

---@alias module table
---@alias char string
---@alias str string
---@alias bool boolean
---@alias int integer

---@alias tabnr integer unique tab number
---@alias winid integer unique window-ID. refers to win in any tab
---@alias winnr integer window number. only applies to current tab
---@alias bufnr integer unique buffer number
---@alias bufname string buffer name (full path)

---@alias linenr integer line number
---@alias row integer a row
---@alias column integer a column

---@alias tabpage integer unique tab number
---@alias window integer unique window-ID. refers to win in any tab

---@alias blob number
---@alias buffer integer
---@alias channel integer
---@alias float number
---@alias job number
---@alias object any
---@alias sends number
