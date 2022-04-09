local M = {}

local function inspect(v)
    local s
    local t = type(v)
    if t == 'nil' then
        s = 'nil'
    elseif t ~= 'string' then
        s = vim.inspect(v)
    else
        s = tostring(v)
    end
    return s
end

P = function(...)
  print(vim.inspect(...))
  return ...
end

RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

-- Print text nicely (newline)
function _G.pln(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end

-- Print text nicely
function _G.p(...)
    local argc = select('#', ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, inspect(arg))
    end

    print(table.concat(msg_tbl, ' '))
end

-- Dump table
function M.dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = "\"" .. k .. "\""
      end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

M.join_paths = function(...)
  local separator = "/"
  return table.concat({ ... }, separator)
end

-- Capture output of command
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read("*a"))
  f:close()
  if raw then
    return s
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

-- Capture output of a command using plenary
-- local job = require("plenary.job")
-- job:new(
--     {
--       command = "rg",
--       args = { "--files" },
--       cwd = "~",
--       env = { ["testing"] = "empty" },
--       on_exit = function(j, ret)
--         print(ret)
--         print(j:result())
--       end,
--     }
-- ):sync()

-- Help
-- print(vim.inspect(vim.fn.api_info()))
-- print(vim.inspect(vim))
--
-- print(vim.inspect(vim.loop))
-- Reference: https://github.com/luvit/luv/blob/master/docs.md
-- Examples:  https://github.com/luvit/luv/tree/master/examples

return M
