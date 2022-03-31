local M = {}

-- Print text nicely
function _G.put(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
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

-- Capture output of command
function M.capture(cmd, raw)
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

return M
