local M = {}

local map = require("common.utils").map

function M.setup()
  -- https://alpha2phi.medium.com/neovim-dap-enhanced-ebc730ff498b
  cmd [[com! BreakpointToggle lua require('dap').toggle_breakpoint()]]
  cmd [[com! Debug lua require('dap').continue()]]
  cmd [[com! DapREPL lua require('dap').repl.open()]]
  cmd [[com! DapLaunch lua require('osv').launch()]]
  cmd [[com! DapRun lua require('osv').run_this()]]

  map("n", "<Leader>dct", [[<cmd>lua require'dap'.continue()<CR>]])
  map("n", "<Leader>dsv", [[<cmd>lua require'dap'.step_over()<CR>]])
  map("n", "<Leader>dsi", [[<cmd>lua require'dap'.step_into()<CR>]])
  map("n", "<Leader>dso", [[<cmd>lua require'dap'.step_out()<CR>]])

  map("n", "<Leader>dtb", [[<cmd>lua require('dap').toggle_breakpoint()<CR>]])
  map("n", "<Leader>dro", [[<cmd>lua require('dap').repl.open()<CR>]])
  map("n", "<Leader>drl", [[<cmd>lua require("dap").run_last()<CR>]])

  map("n", "<Leader>dui", [[<cmd>lua require('dapui').toggle()<CR>]])
  map("n", "<Leader>due", [[<cmd>lua require('dapui').eval()<CR>]])

  map("n", "<Leader>dsc", [[<cmd>lua require('dap.ui.variables').scopes()<CR>]])
  map("n", "<Leader>dhh", [[<cmd>lua require('dap.ui.variables').hover()<CR>]])
  map(
      "v", "<Leader>dhv",
      [[<cmd>lua require('dap.ui.variables').visual_hover()<CR>]]
  )

  map("n", "<Leader>duh", [[<cmd>lua require'dap.ui.widgets'.hover()<CR>]])
  map(
      "n", "<Leader>duf",
      [[<cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>]]
  )
  map(
      "n", "<Leader>dsbr",
      [[<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>]]
  )
  map(
      "n", "<Leader>dsbm",
      [[<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]]
  )

  -- telescope-dap
  map(
      "n", "<Leader>dcc",
      [[<cmd>lua require'telescope'.extensions.dap.commands{}<CR>]]
  )
  map(
      "n", "<Leader>dco",
      [[<cmd>lua require'etelescope'.extensions.dap.configurations{}<CR>]]
  )
  map(
      "n", "<Leader>dlb",
      [[<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>]]
  )
  map(
      "n", "<Leader>dv",
      [[<cmd>lua require'telescope'.extensions.dap.variables{}<CR>]]
  )
  map(
      "n", "<Leader>df",
      [[<cmd>lua require'telescope'.extensions.dap.frames{}<CR>]]
  )
end

function M.config()
  local dap = require "dap"

  -- Debugpy
  dap.adapters.python = {
    type = "executable",
    command = "python",
    args = { "-m", "debugpy.adapter" },
  }

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      pythonPath = function()
        return ("%s/shims/python"):format(env.PYENV_ROOT)
      end,
    },
  }

  -- Neovim Lua
  dap.adapters.nlua = function(callback, config)
    callback { type = "server", host = config.host, port = config.port }
  end

  dap.configurations.lua = {
    {
      type = "nlua",
      request = "attach",
      name = "Attach to running Neovim instance",
      host = function()
        local value = vim.fn.input "Host [127.0.0.1]: "
        if value ~= "" then
          return value
        end
        return "127.0.0.1"
      end,
      port = function()
        local val = tonumber(vim.fn.input "Port: ")
        assert(val, "Please provide a port number")
        return val
      end,
    },
  }

  -- lldb
  dap.adapters.lldb = {
    type = "executable",
    command = "/usr/bin/lldb-vscode",
    name = "lldb",
  }

  dap.configurations.cpp = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input(
            "Path to executable: ", vim.fn.getcwd() .. "/", "file"
        )
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
    },
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end

return M
