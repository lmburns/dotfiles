local M = {}

local K = require("common.keymap")
local wk = require("which-key")

function M.setup()
  wk.setup {
    plugins = {
      marks = true, -- shows a list of your marks on ' and `
      registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      presets = { -- adds help for a bunch of default keybindings
        operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
        motions = false, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = false, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
    },
    operators = { -- add operators that will trigger motion and text object completion
      gc = "Comments",
    },
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows active key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    window = {
      border = "none", -- none, single, double, shadow
      position = "bottom", -- bottom, top
      margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
    hidden = { "lua", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
    triggers = { "auto" }, -- or specifiy a list manually
  }
end

local function init()
  M.setup()

  K.n("<Leader>wh", "<Cmd>WhichKey<CR>")
  K.n("<Leader><Leader><CR>", "<Cmd>WhichKey \\ <CR>")
  K.n("<LocalLeader><CR>", "<Cmd>WhichKey <LocalLeader><CR>")
  K.n("<SubLeader><CR>", "<Cmd>WhichKey <SubLeader><CR>")
  K.n(";<CR>", "<Cmd>WhichKey ;<CR>")
  K.n("g<CR>", "<Cmd>WhichKey g<CR>")
  K.n("[<CR>", "<Cmd>WhichKey [<CR>")
  K.n("]<CR>", "<Cmd>WhichKey ]<CR>")

  -- K.n("<EasyMotion><CR>", "<Cmd>WhichKey <EasyMotion><CR>")
end

init()

return M
