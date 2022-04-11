local M = {}

local utils = require("common.utils")
local map = utils.map
local command = utils.command
local notify = utils.notify

-- ============================== harpoon =============================

function M.setup()
  require("harpoon").setup(
      {
        global_settings = {
          -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
          save_on_toggle = false,

          -- saves the harpoon file upon every change. disabling is unrecommended.
          save_on_change = true,

          -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
          enter_on_sendcmd = false,

          -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
          tmux_autoclose_windows = false,

          -- filetypes that you want to prevent from adding to the harpoon list menu.
          excluded_filetypes = { "harpoon" },

          -- set marks specific to each git branch inside git repository
          mark_branch = false,
        },
        projects = {
          ["$HOME/projects/github"] = { term = { cmds = { "echo 'testing'" } } },
        },
        -- menu = { width = api.nvim_win_get_width(0) - 4 },
      }
  )
  require("telescope").load_extension("harpoon")
end

local function init()
  M.setup()

  command(
      {
        "",
        "HarpAddFile",
        function()
          require("harpoon.mark").add_file()
          notify("File added")
        end,
      }
  )

  command(
      {
        "",
        "HarpUi",
        function()
          require("harpoon.ui").toggle_quick_menu()
        end,
      }
  )

  map("n", "[h", ":lua require('harpoon.ui').nav_prev()<CR>")
  map("n", "]h", ":lua require('harpoon.ui').nav_next()<CR>")
end

init()

return M
