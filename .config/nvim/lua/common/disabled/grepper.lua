local M = {}

-- Doesn't work, doesn't open quickfix
local Job = require("plenary.job")
local map = require("common.utils").map

local get_job = function(str, cwd)
  local job = Job:new{
    command = "rg",
    args = { "--color=never", "--vimgrep", str },

    on_stdout = vim.schedule_wrap(
        function(_, line)
          local split_line = vim.split(line, ":")

          local filename = split_line[1]
          local lnum = split_line[2]
          local col = split_line[3]

          vim.fn.setqflist(
              {
                {
                  filename = filename,
                  lnum = lnum,
                  col = col,
                  text = split_line[4],
                },
              }, "a"
          )
        end
    ),

    on_exit = vim.schedule_wrap(
        function()
          vim.cmd [[copen]]
        end
    ),
  }

  return job
end

function M.grep_for_string(str, cwd)
  vim.fn.setqflist({}, "r")
  return get_job(str, cwd):join()
end

function M.replace_string(search, replace, opts)
  opts = opts or {}

  local job = get_job(search, opts.cwd)
  job:add_on_exit_callback(
      vim.schedule_wrap(
          function()
            vim.cmd(string.format("cdo s/%s/%s/g", search, replace))
            vim.cmd [[cdo :update]]
          end
      )
  )

  return job:sync()
end

LB_GREP = M

map(
    "n", "<Leader>gg",
    [[:lua LB_GREP.grep_for_string(vim.fn.input('Grep >'))<CR>]]
)

-- map(
--     "n", "<Leader>gr",
--     [[:lua require('grepper').replace_string(vim.fn.input("Grep > "), vim.fn.input("Replace with > "))<CR>]]
-- )

return M
