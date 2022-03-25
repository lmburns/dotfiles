-- Set globals
o = vim.opt -- vim options: behaves like `:set`
-- vim.o -- behaves like `:set` (global)
-- vim.opt -- behaves like `:set` (global and local)
-- vim.opt_global -- behaves like `:setglobal`
-- vim.opt_local -- behaves like `:setlocal`

g = vim.g -- vim global variables:

w = vim.wo -- vim window options: behaves like `:setlocal`

b = vim.bo -- vim buffer options: behaves like `:setlocal`

fn = vim.fn -- to call Vim functions e.g. fn.bufnr()

cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')

exec = vim.api.nvim_exec

local M = {}

function M.opt(o, v, scopes)
  scopes = scopes or { vim.o }
  v = v == nil and true or v

  if type(v) == "table" then
    v = table.concat(v, ",")
  end

  for _, s in ipairs(scopes) do
    s[o] = v
  end
end

function M.map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

-- Merge two tables together
function M.merge_tables(a, b)
  if type(a) == "table" and type(b) == "table" then
    for k, v in pairs(b) do
      if type(v) == "table" and type(a[k] or false) == "table" then
        merge(a[k], v)
      else
        a[k] = v
      end
    end
  end
  return a
end

-- Easier mapping
function M.map_lua(mode, keys, action, options)
  local opts = options or { noremap = true }
  -- options = M.merge_tables({
  --     noremap = true
  -- }, options)
  vim.api.nvim_set_keymap(mode, keys, "<cmd>lua " .. action .. "<CR>", opts)
end

-- Easier visual mapping
function M.vmap_lua(keys, action, options)
  local opts = options or { noremap = true }
  -- options = M.merge_tables({
  --     noremap = true
  -- }, options)
  vim.api.nvim_set_keymap("v", keys, "<cmd>'<,'>lua " .. action .. "<CR>", opts)
end

function M.augroup(definitions)
  for group_name, definition in pairs(definitions) do
    cmd("augroup " .. group_name)
    cmd("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten { "autocmd", def }, " ")
      cmd(command)
    end
    cmd("augroup END")
  end
end

function M.autocmd(group, cmds, clear)
  clear = clear == nil and false or clear
  if type(cmds) == "string" then
    cmds = { cmds }
  end
  cmd("augroup " .. group)
  if clear then
    cmd [[au!]]
  end
  for _, c in ipairs(cmds) do
    cmd("autocmd " .. c)
  end
  cmd [[augroup END]]
end

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.is_buffer_empty()
  -- Check whether the current buffer is empty
  return vim.fn.empty(vim.fn.expand("%:t")) == 1
end

function M.has_width_gt(cols)
  -- Check if the windows width is greater than a given number of columns
  return vim.fn.winwidth(0) / 2 > cols
end

-- print/debug helper
function M.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(table.unpack(objects))
end

function M.all(...)
  local args = { ... }
  return function()
    for _, fn in ipairs(args) do
      if not fn() then
        return false
      end
    end
    return true
  end
end

function M.clear_module(module_name)
  package.loaded[module_name] = nil
end

function M.prequire(m)
  local ok, err = pcall(require, m)
  if not ok then
    return nil, err
  end
  return err
end

-- Buffer local mappings
function M.map_buf(mode, keys, action, options, buf_nr)
  options = M.merge_tables({ noremap = true }, options)
  local buf = buf_nr or 0
  vim.api.nvim_buf_set_keymap(buf, mode, keys, action, options)
end

function M.map_lua_buf(mode, keys, action, options, buf_nr)
  options = M.merge_tables({ noremap = true }, options)
  local buf = buf_nr or 0
  vim.api.nvim_buf_set_keymap(
      buf, mode, keys, "<cmd>lua " .. action .. "<CR>", options
  )
end

function M.has_key(table, key)
  return table.key ~= nil
end

-- Allows us to use utils globally
_G.utils = M

return M
