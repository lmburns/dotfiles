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

-- Create an autocmd with vim commands
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

--- Create an autocmd
-- @param name: augroup name
-- @param commands: autocmd to execute
function M.au(name, commands)
  local group = M.create_augroup(name)

  for _, command in ipairs(commands) do
    local event = command[1]
    local patt = command[2]
    local action = command[3]
    local desc = command[4] or ""

    if type(action) == "string" then
      api.nvim_create_autocmd(
          event,
          { pattern = patt, command = action, group = group, desc = desc }
      )
    else
      api.nvim_create_autocmd(
          event,
          { pattern = patt, callback = action, group = group, desc = desc }
      )
    end
  end
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
--- Return a string for vim from a lua function.
--- Functions are stored in _G.myluafunc.
--- @param func function
--- @return string VimFunctionString
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

  local fallback = function()
    return api.nvim_feedkeys(M.t(lhs), "n", true)
  end

  local _rhs = (function()
    if type(rhs) == "function" then
      opts.noremap = true
      opts.cmd = true
      return func2str(
          function()
            rhs(fallback)
          end
      )
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
function M.t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

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

-- Another command function
function M.cmd(name, action, flags)
  local flag_pairs = {}

  if flags then
    for flag, value in pairs(flags) do
      if value == true then
        table.insert(flag_pairs, "-" .. flag)
      else
        table.insert(flag_pairs, "-" .. flag .. "=" .. value)
      end
    end
  end

  action = action:gsub("\n%s*", " ")

  local def = table.concat(
      { "command!", table.concat(flag_pairs, " "), name, action }, " "
  )

  vim.cmd(def)
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

function M.clear_module(module_name)
  package.loaded[module_name] = nil
end

-- Check whether the current buffer is empty
function M.is_buffer_empty()
  return fn.empty(fn.expand("%:t")) == 1
end

-- Check if the windows width is greater than a given number of columns
function M.has_width_gt(cols)
  return fn.winwidth(0) / 2 > cols
end

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

-- Can also use #T ?
function M.tablelength(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

function M.get_visual_selection()
  -- this will exit visual mode
  -- use 'gv' to reselect the text
  local _, csrow, cscol, cerow, cecol
  local mode = fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    -- if we are in visual mode use the live position
    _, csrow, cscol, _ = unpack(fn.getpos("."))
    _, cerow, cecol, _ = unpack(fn.getpos("v"))
    if mode == "V" then
      -- visual line doesn't provide columns
      cscol, cecol = 0, 999
    end
    -- exit visual mode
    api.nvim_feedkeys(
        api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true
    )
  else
    -- otherwise, use the last known visual position
    _, csrow, cscol, _ = unpack(fn.getpos("'<"))
    _, cerow, cecol, _ = unpack(fn.getpos("'>"))
  end
  -- swap vars if needed
  if cerow < csrow then
    csrow, cerow = cerow, csrow
  end
  if cecol < cscol then
    cscol, cecol = cecol, cscol
  end
  local lines = vim.fn.getline(csrow, cerow)
  -- local n = cerow-csrow+1
  local n = M.tablelength(lines)
  if n <= 0 then
    return ""
  end
  lines[n] = string.sub(lines[n], 1, cecol)
  lines[1] = string.sub(lines[1], cscol)
  return table.concat(lines, "\n")
end

function M.notify(options)
  if type(options) == "string" then
    api.nvim_notify(
        options, vim.log.levels.INFO, { icon = "", title = "Notification" }
    )
    return
  end

  local forced = vim.tbl_extend(
      "force", {
        message = "This is a sample notification.",
        icon = "",
        title = "Notification",
        level = vim.log.levels.INFO,
      }, options or {}
  )
  api.nvim_notify(
      forced.message, forced.level, { title = forced.title, icon = forced.icon }
  )
end

-- ================= Tips ================== [[[
-- Search global variables:
--    filter <pattern> let g:

-- ]]] === Tips ===

-- Allows us to use utils globally
_G.utils = M

return M
