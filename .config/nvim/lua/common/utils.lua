-- Set globals
o = vim.opt -- vim options: behaves like `:set`
-- o           --  behaves like `:set` (global)
-- opt         --  behaves like `:set` (global and local)
-- opt_global  --  behaves like `:setglobal`
-- opt_local   --  behaves like `:setlocal`

g = vim.g -- vim global variables:
go = vim.go -- vim global options
w = vim.wo -- vim window options: behaves like `:setlocal`
b = vim.bo -- vim buffer options: behaves like `:setlocal`

fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
env = vim.env -- environment variable access
api = vim.api
exec = api.nvim_exec
uv = vim.loop

local M = {}

-- Modify vim options
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

-- Create an augroup with the lua api
function M.create_augroup(name, clear)
  clear = clear == nil and true or clear
  api.nvim_create_augroup(name, { clear = clear })
end

-- Create many augroups
function M.augroups(definitions)
  for group_name, definition in pairs(definitions) do
    cmd("augroup " .. group_name)
    cmd("autocmd!")
    for _, def in pairs(definition) do
      local command = table.concat(tbl_flatten { "autocmd", def }, " ")
      cmd(command)
    end
    cmd("augroup END")
  end
end

-- Create a single augroup
function M.augroup(name, commands)
  cmd("augroup " .. name)
  cmd("autocmd!")
  for _, c in ipairs(commands) do
    cmd(
        string.format(
            "autocmd %s %s %s %s", table.concat(c.events, ","),
            table.concat(c.targets or {}, ","),
            table.concat(c.modifiers or {}, " "), c.command
        )
    )
  end
  cmd("augroup END")
end

-- Create an autocmd
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

-- Create a key mapping
function M.map(modes, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  if type(modes) == "string" then
    modes = { modes }
  end
  for _, mode in ipairs(modes) do
    api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

-- NOTE: Whats the difference between vim.keymap.set and vim.api.nvim_set_keymap?

-- Create a buffer key mapping
M.bmap = function(bufnr, mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

-- This allows for lua function mapping
M.fmap = function(tbl)
  opts = tbl[4] or {}
  opts.noremap = opts.noremap == nil and true or opts.noremap
  vim.keymap.set(tbl[1], tbl[2], tbl[3], opts)
end

-- ========================== Mapping Implentation ==========================
-- ======================== Credit: ibhagwan/nvim-lua =======================
--
-- Credit to uga-rosa@github
-- https://github.com/uga-rosa/dotfiles/blob/main/.config/nvim/lua/utils.lua

---Return a string for vim from a lua function.
---Functions are stored in _G.myluafunc.
---@param func function
---@return string VimFunctionString
_G.myluafunc = setmetatable(
    {}, {
      __call = function(self, idx, args, count)
        return self[idx](args, count)
      end,
    }
)

local func2str = function(func, args)
  local idx = #_G.myluafunc + 1
  _G.myluafunc[idx] = func
  if not args then
    return ("lua myluafunc(%s)"):format(idx)
  else
    -- return ("lua myluafunc(%s, <q-args>)"):format(idx)
    return ("lua myluafunc(%s, <q-args>, <count>)"):format(idx)
  end
end

function M.remap(modes, lhs, rhs, opts)
  modes = type(modes) == "string" and { modes } or modes
  opts = opts or {}
  opts = type(opts) == "string" and { opts } or opts

  local fallback = function() return api.nvim_feedkeys(M.t(lhs), "n", true) end

  local _rhs = (function()
    if type(rhs) == "function" then
      opts.noremap = true
      opts.cmd = true
      return func2str(function() rhs(fallback) end)
    else
      return rhs
    end
  end)()

  for key, opt in ipairs(opts) do
    opts[opt] = true
    opts[key] = nil
  end

  local buffer = (function()
    if opts.buffer then
      opts.buffer = nil
      return true
    end
  end)()

  _rhs = (function()
    if opts.cmd then
      opts.cmd = nil
      return ("<cmd>%s<cr>"):format(_rhs)
    else
      return _rhs
    end
  end)()

  for _, mode in ipairs(modes) do
    if buffer then
      api.nvim_buf_set_keymap(0, mode, lhs, _rhs, opts)
    else
      api.nvim_set_keymap(mode, lhs, _rhs, opts)
    end
  end
end

-- Replace termcodes; e.g., t'<C-n'
function M.t(str) return api.nvim_replace_termcodes(str, true, true, true) end

-- print/debug helper
function M.dump(...)
  local objects = tbl_map(inspect, { ... })
  print(table.unpack(objects))
end

---API for command mappings
-- Supports lua function args
---@param args string|table
function M.command(args)
  if type(args) == "table" then
    for i = 2, #args do
      if fn.exists(":" .. args[2]) == 2 then
        cmd("delcommand " .. args[2])
      end
      if type(args[i]) == "function" then
        args[i] = func2str(args[i], true)
      end
    end
    args = table.concat(args, " ")
  end
  cmd("command! " .. args)
end

-- Expand or minimize current buffer in a more natural direction (tmux-like)
function M.resize(vertical, margin)
  local cur_win = api.nvim_get_current_win()
  -- go (possibly) right
  vim.cmd(string.format("wincmd %s", vertical and "l" or "j"))
  local new_win = api.nvim_get_current_win()

  -- determine direction cond on increase and existing right-hand buffer
  local not_last = not (cur_win == new_win)
  local sign = margin > 0
  -- go to previous window if required otherwise flip sign
  if not_last == true then
    vim.cmd [[wincmd p]]
  else
    sign = not sign
  end

  sign = sign and "+" or "-"
  local dir = vertical and "vertical " or ""
  local cmd = dir .. "resize " .. sign .. math.abs(margin) .. "<CR>"
  vim.cmd(cmd)
end

function M.clear_module(module_name) package.loaded[module_name] = nil end

cmd [[
    function! IsPluginInstalled(name) abort
      return luaeval("_G.packer_plugins['" .. a:name .. "'] ~= nil")
    endfunction
]]

-- my_packer.is_plugin_installed = function(name)
--   return _G.packer_plugins[name] ~= nil
-- end
--
-- function AutocmdLazyConfig(plugin_name)
--   local timer = loop.new_timer()
--   timer:start(
--       1000, 0, schedule_wrap(
--           function()
--             if _G.packer_plugins[plugin_name].loaded then
--               timer:close() -- Always close handles to avoid leaks.
--               cmd(
--                   string.format("doautocmd User %s", "packer-" .. plugin_name)
--               )
--             end
--           end
--       )
--   )
-- end

-- Check whether the current buffer is empty
function M.is_buffer_empty() return fn.empty(fn.expand("%:t")) == 1 end

-- Check if the windows width is greater than a given number of columns
function M.has_width_gt(cols) return fn.winwidth(0) / 2 > cols end

function M.merge(a, b)
  if type(a) == "table" and type(b) == "table" then
    for k, v in pairs(b) do
      if type(v) == "table" and type(a[k] or false) == "table" then
        M.merge(a[k], v)
      else
        a[k] = v
      end
    end
  end
  return a
end

-- Allows us to use utils globally
_G.utils = M

return M
