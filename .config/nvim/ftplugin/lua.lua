local shared = require("usr.shared")
local F = shared.F
local it = F.ithunk
local utils = shared.utils
local coc = require("plugs.coc")
local mpi = require("usr.api")
local bmap0 = mpi.bmap0
-- local log = require("usr.lib.log")

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

vim.opt_local.define = [[^\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]]
vim.opt_local.suffixesadd:prepend({".lua", "init.lua"})
vim.opt_local.include =
    [[\v<((do|load)file|(x?p|lazy\.)?]] ..
    [[require|lazy\.(require_on\.(index|modcall|expcall|call_rec)|require_iff))[^''"]*[''"]\zs[^''"]+]]
-- o.matchpairs:append({"if:end", "function:end"})

---
---@param word? string|boolean if true, use cWORD
local function kw_prog(word)
  local iskeyword_og = vim.bo.iskeyword
  vim.bo.iskeyword = vim.bo.iskeyword .. ",."
  word = utils.is.str(word) and word or fn.expand(F.ife_true(word, "<cWORD>", "<cword>"))
  vim.bo.iskeyword = iskeyword_og

  if word:find("vim.api") then
    local _, finish = word:find("vim.api.")
    local api_fn = word:sub(finish + 1)
    cmd.help(api_fn)
  elseif word:find("api") then
    local _, finish = word:find("api.")
    local api_fn = word:sub(finish + 1)
    cmd.help(api_fn)
  elseif word:find("vim.fn") then
    local _, finish = word:find("vim.fn.")
    local api_fn = word:sub(finish + 1) .. "()"
    cmd.help(api_fn)
  else
    local ok, _msg = pcall(cmd.help, word)
    if not ok then
      local split_word = vim.split(word, ".", {plain = true})
      ok, msg = pcall(cmd.help, split_word[#split_word])
      -- if not ok then
      --   -- log.warn(msg --[[@as string]], {title = "keyword helper"})
      -- end
    end
  end
end

bmap0("n", "<Leader>tt", "<Plug>PlenaryTestFile", {desc = "Plenary test"})
bmap0("n", "M", kw_prog, {desc = "Help of <cword>"})
bmap0("n", "<Leader>K", it(kw_prog, true), {desc = "Help of <cWORD>"})
bmap0("n", "<Leader>jR", it(coc.run_command, "sumneko-lua.restart", {}), {desc = "Reload LuaLS"})

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Look at first line of `package.config` for directory separator.
local separator = package.config:match("^[^\n]")

-- Search in Lua `package.path` locations.
local function search_package_path(fname)
  local paths = package.path:gsub("%?", fname)
  for path in (paths):gmatch("[^%;]+") do
    if fn.filereadable(path) == 1 then
      return path
    end
  end
end

-- Search in nvim 'runtimepath' directories.
local function search_runtimepath(fname, ext)
  local candidate
  for _, path in ipairs(api.nvim_list_runtime_paths()) do
    -- Look for "lua/*.lua".
    candidate = table.concat({path, ext, ("%s.%s"):format(fname, ext)}, separator)
    if fn.filereadable(candidate) == 1 then
      return candidate
    end
    -- Look for "lua/*/init.lua".
    candidate = table.concat({path,
      ext, fname, ("init.%s"):format(ext),}, separator)
    if fn.filereadable(candidate) == 1 then
      return candidate
    end
  end
end

-- Global function that searches the path for the required file
function __LuaRequirePath(fname)
  fname = fn.substitute(fname, "\\.", separator, "g")
  return search_package_path(fname)
      or search_runtimepath(fname, "lua")
      or search_runtimepath(fname, "fnl")
end

-- Set options to open require with gf
vim.opt_local.includeexpr = "v:lua.__LuaRequirePath(v:fname)"
-- vim.opt_local.includeexpr = Rc.F.ithunk(__LuaRequirePath, vim.v.fname)
