return {
  name = "run script",
  builder = function()
    local file = vim.fn.expand("%:p")
    local filep = vim.fn.expand("%:p:r")
    local cmd = {file}

    if vim.bo.filetype == "go" then
      cmd = {"go", "run", file}
    -- elseif vim.bo.filetype == "c" then
      -- cmd = {"gcc", "-std=gnu2x", "-o", filep, file..';', file}
    end

    return {
      cmd = cmd,
      components = {
        {"on_output_quickfix", set_diagnostics = true, open = true},
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = {"sh", "zsh", "python", "go", "c"},
  },
}
