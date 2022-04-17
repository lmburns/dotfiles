local M = {}

local utils = require("common.utils")
local bmap = utils.bmap
local config

function M.toggle_deleted()
  require("gitsigns").toggle_deleted()
  vim.notify(
      ("Gitsigns %s show_deleted"):format(
          config.show_deleted and "enable" or "disable"
      )
  )
end

local function mappings(bufnr)
  bmap(
      bufnr, "n", "]c", [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']],
      { noremap = true, expr = true }
  )
  bmap(
      bufnr, "n", "[c", [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']],
      { noremap = true, expr = true }
  )

  bmap(bufnr, "n", "<Leader>he", "<Cmd>Gitsigns stage_hunk<CR>")
  bmap(bufnr, "x", "<Leader>he", ":Gitsigns stage_hunk<CR>")
  bmap(bufnr, "n", "<Leader>hS", "<Cmd>Gitsigns undo_stage_hunk<CR>")
  bmap(bufnr, "n", "<Leader>hu", "<Cmd>Gitsigns reset_hunk<CR>")
  bmap(bufnr, "x", "<Leader>hu", ":Gitsigns reset_hunk<CR>")
  bmap(bufnr, "n", "<Leader>hp", "<Cmd>Gitsigns preview_hunk<CR>")
  bmap(
      bufnr, "n", "<Leader>hv",
      [[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]]
  )
  bmap(bufnr, "o", "ih", ":<C-u>Gitsigns select_hunk<CR>")
  bmap(bufnr, "x", "ih", ":<C-u>Gitsigns select_hunk<CR>")
  bmap(bufnr, "n", '<Leader>hQ', "<Cmd>Gitsigns setqflist all")
  bmap(bufnr, "n", '<Leader>hq', "<Cmd>Gitsigns setqflist")
end

function M.setup()
  require("gitsigns").setup(
      {
        signs = {
          add = {
            hl = "GitSignsAdd",
            text = "▍",
            numhl = "GitSignsAddNr",
            linehl = "GitSignsAddLn",
          },
          change = {
            hl = "GitSignsChange",
            text = "▍",
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn",
          },
          delete = {
            hl = "GitSignsDelete",
            text = "↗",
            show_count = true,
            numhl = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn",
          },
          topdelete = {
            hl = "GitSignsDelete",
            text = "↘",
            show_count = true,
            numhl = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn",
          },
          changedelete = {
            hl = "GitSignsChange",
            text = "▍",
            show_count = true,
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn",
          },
        },
        count_chars = {
          [1] = "",
          [2] = "₂",
          [3] = "₃",
          [4] = "₄",
          [5] = "₅",
          [6] = "₆",
          [7] = "₇",
          [8] = "₈",
          [9] = "₉",
          ["+"] = "₊",
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = { interval = 1000, follow_files = true },
        on_attach = function(bufnr) mappings(bufnr) end,
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
        },
        current_line_blame_formatter_opts = { relative_time = false },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000,
        preview_config = {
          -- Options passed to nvim_open_win
          border = "rounded",
          style = "minimal",
          relative = "cursor",
          noautocmd = true,
          row = 0,
          col = 1,
        },
        show_deleted = false,
        trouble = false,
        yadm = { enable = false },

        -- keymaps = {
        --   -- Default keymap options
        --   noremap = true,
        --   buffer = true,
        --
        --   ["n ]c"] = {
        --     expr = true,
        --     "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
        --   },
        --   ["n [c"] = {
        --     expr = true,
        --     "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
        --   },
        --
        --   ["n <leader>hs"] = "<cmd>lua require\"gitsigns\".stage_hunk()<CR>",
        --   ["v <leader>hs"] = "<cmd>lua require\"gitsigns\".stage_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>",
        --   ["n <leader>hu"] = "<cmd>lua require\"gitsigns\".undo_stage_hunk()<CR>",
        --   ["n <leader>hr"] = "<cmd>lua require\"gitsigns\".reset_hunk()<CR>",
        --   ["v <leader>hr"] = "<cmd>lua require\"gitsigns\".reset_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>",
        --   ["n <leader>hR"] = "<cmd>lua require\"gitsigns\".reset_buffer()<CR>",
        --   ["n <leader>hp"] = "<cmd>lua require\"gitsigns\".preview_hunk()<CR>",
        --   ["n <leader>hb"] = "<cmd>lua require\"gitsigns\".blame_line()<CR>",
        --   ["n <leader>hS"] = "<cmd>lua require\"gitsigns\".stage_buffer()<CR>",
        --   ["n <leader>hU"] = "<cmd>lua require\"gitsigns\".reset_buffer_index()<CR>",
        --
        --   -- Text objects
        --   ["o ih"] = ":<C-U>lua require\"gitsigns.actions\".select_hunk()<CR>",
        --   ["x ih"] = ":<C-U>lua require\"gitsigns.actions\".select_hunk()<CR>",
        -- },
      }
  )
end

local function init()
  cmd("packadd plenary.nvim")
  cmd [[
        hi link GitSignsChangeLn DiffText
        hi link GitSignsAddInline GitSignsAddLn
        hi link GitSignsDeleteInline GitSignsDeleteLn
        hi link GitSignsChangeInline GitSignsChangeLn
    ]]

  M.setup()
end

init()

return M
