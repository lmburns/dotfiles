local M = {}

local utils = require("common.utils")
local map = utils.map

function M.setup()
  local diagnostics_signs = {
    ["error"] = "",
    warning = "",
    default = "",
  }

  local colors = {
    magenta = "#A06469",
    purple = "#98676A",
    dbg = "#221a0f",
    lbg = "#5e452b",
    fg = "#e8c097",
    red = "#EF1D55",
    dred = "#DC3958",
    green = "#819C3B",
    yellow = "#FF9500",
    orange = "#FF5813",
    blue = "#4C96A8",
    cyan = "#7EB2B1",
    dpurple = "#733e8b"
  }

  require("bufferline").setup(
      {
        options = {
          mode = "buffers",
          numbers = function(opts)
            return string.format("%s", opts.raise(opts.ordinal))
          end,
          close_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
          right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
          left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
          middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"

          indicator_icon = "▎",
          buffer_close_icon = "",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 20,
          max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
          tab_size = 20,

          --- *name_formatter* can be used to change the buffer's label in the bufferline.
          -- @param: buf contains a "name", "path" and "bufnr"
          name_formatter = function(buf)
            -- remove extension from markdown files for example
            if buf.name:match("%.md") then
              return vim.fn.fnamemodify(buf.name, ":t:r")
            end
          end,

          diagnostics = "coc", -- false
          diagnostics_indicator = function(
              count, level, diagnostics_dict, context
          )
            local s = " "
            for e, n in pairs(diagnostics_dict) do
              local sym = diagnostics_signs[e] or diagnostics_signs.default
              s = s .. (#s > 1 and " " or "") .. sym .. " " .. n
            end
            return s
          end,

          -- NOTE: this will be called a lot so don't do any heavy processing here
          custom_filter = function(buf_number)
            -- filter out filetypes you don't want to see
            if vim.bo[buf_number].filetype == "qf" then
              return false
            end

            if vim.bo[buf_number].buftype == "terminal" then
              return false
            end

            -- filter out by buffer name
            if vim.fn.bufname(buf_number) == "" or vim.fn.bufname(buf_number) ==
                "[No Name]" then
              return false
            end

            if vim.fn.bufname(buf_number) == "[dap-repl]" then
              return false
            end
            -- -- filter out based on arbitrary rules
            -- -- e.g. filter out vim wiki buffer from tabline in your work repo
            -- if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
            --   return true
            -- end
            return true
          end,

          -- offsets = {
          --   {filetype = "NvimTree", text = "File Explorer", text_align = "left" | "center" | "right"}
          -- },
          show_buffer_icons = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          -- persist_buffer_sort = true, -- whether or not custom sorted buffers should persist

          -- can also be a table containing 2 custom separators
          -- [focused and unfocused]. eg: { '|', '|' }
          separator_style = "slant",
          enforce_regular_tabs = true,

          -- always_show_bufferline = true
          -- sort_by = 'relative_directory'
        },
        highlights = {
          -- Status background
          fill = { guifg = colors.magenta, guibg = colors.dbg },
          background = { guifg = colors.fg, guibg = colors.dbg },

          tab = { guifg = colors.fg, guibg = colors.dbg },
          tab_selected = { guifg = colors.fg, guibg = colors.lbg },
          -- tab_close = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- close_button = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- close_button_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- close_button_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          buffer_visible = { guifg = colors.magenta, guibg = colors.lbg },
          buffer_selected = {
            guifg = colors.fg,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          diagnostic = { guifg = colors.red, guibg = colors.dbg },
          diagnostic_visible = { guifg = colors.red, guibg = colors.lbg },
          diagnostic_selected = {
            guifg = colors.red,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          hint = { guifg = colors.cyan, guibg = colors.dbg },
          hint_visible = { guifg = colors.blue, guibg = colors.lbg },
          hint_selected = {
            guifg = colors.blue,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          hint_diagnostic = { guifg = colors.blue, guibg = colors.dbg },
          hint_diagnostic_visible = { guifg = colors.blue, guibg = colors.lbg },
          hint_diagnostic_selected = {
            guifg = colors.blue,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          info = { guifg = colors.purple, guibg = colors.dbg },
          info_visible = { guifg = colors.purple, guibg = colors.lbg },
          info_selected = {
            guifg = colors.purple,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          info_diagnostic = { guifg = colors.purple, guibg = colors.dbg },
          info_diagnostic_visible = { guifg = colors.purple, guibg = colors.lbg },
          info_diagnostic_selected = {
            guifg = colors.purple,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          warning = { guifg = colors.orange, guibg = colors.dbg },
          warning_visible = { guifg = colors.orange, guibg = colors.lgb },
          warning_selected = {
            guifg = colors.orange,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          warning_diagnostic = { guifg = colors.orange, guibg = colors.dbg },
          warning_diagnostic_visible = {
            guifg = colors.orange,
            guibg = colors.lbg,
          },
          warning_diagnostic_selected = {
            guifg = colors.orange,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          error = { guifg = colors.red, guibg = colors.dbg },
          error_visible = { guifg = colors.red, guibg = colors.lbg },
          error_selected = {
            guifg = colors.red,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          error_diagnostic = { guifg = colors.red, guibg = colors.dbg },
          error_diagnostic_visible = { guifg = colors.red, guibg = colors.lbg },
          error_diagnostic_selected = {
            guifg = colors.red,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          modified = { guifg = colors.red, guibg = colors.dbg },
          modified_visible = { guifg = colors.red, guibg = colors.lbg },
          modified_selected = { guifg = colors.red, guibg = colors.lbg },
          duplicate_selected = {
            guifg = colors.cyan,
            gui = "italic",
            guibg = colors.lbg,
          },
          duplicate_visible = {
            guifg = colors.cyan,
            gui = "italic",
            guibg = colors.lbg,
          },
          duplicate = { guifg = colors.red, gui = "italic", guibg = colors.dbg },
          separator_selected = { guifg = colors.dbg, guibg = colors.lbg },
          separator_visible = { guifg = colors.dbg, guibg = colors.lbg },
          separator = { guifg = colors.dbg, guibg = colors.dbg },
          indicator_selected = { guifg = colors.red, guibg = colors.lbg },
          pick_selected = {
            guifg = colors.dred,
            guibg = colors.lbg,
            gui = "bold,italic",
          },
          pick_visible = {
            guifg = colors.green,
            guibg = colors.dbg,
            gui = "bold,italic",
          },
          pick = { guifg = colors.green, guibg = colors.dbg,
                   gui = "bold,italic" },
        },
      }
  )
end

local function init()
  map("n", "<Leader>bu", ":BufferLinePick<CR>", { silent = true })

  map("n", "[b", ":BufferLineCyclePrev<CR>", { silent = true })
  map("n", "]b", ":BufferLineCycleNext<CR>", { silent = true })
  map("n", "<C-S-Left>", ":BufferLineCyclePrev<CR>")
  map("n", "<C-S-Right>", ":BufferLineCycleNext<CR>")
  -- map("n", "[b", [[:execute(v:count1 . 'bprev')<CR>]])
  -- map("n", "]b", [[:execute(v:count1 . 'bnext')<CR>]])

  map("n", "@", ":BufferLineMovePrev<CR>", { silent = true })
  map("n", "#", ":BufferLineMoveNext<CR>", { silent = true })
  -- map("n", [[<C-S-\<>]], ":BufferLineMovePrev<CR>", { silent = true })
  -- map("n", [[<C-S-\>>]], ":BufferLineMoveNext<CR>", { silent = true })

  map("n", "<Leader>1", ":BufferLineGoToBuffer 1<CR>", { silent = true })
  map("n", "<Leader>2", ":BufferLineGoToBuffer 2<CR>", { silent = true })
  map("n", "<Leader>3", ":BufferLineGoToBuffer 3<CR>", { silent = true })
  map("n", "<Leader>4", ":BufferLineGoToBuffer 4<CR>", { silent = true })
  map("n", "<Leader>5", ":BufferLineGoToBuffer 5<CR>", { silent = true })
  map("n", "<Leader>6", ":BufferLineGoToBuffer 6<CR>", { silent = true })
  map("n", "<Leader>7", ":BufferLineGoToBuffer 7<CR>", { silent = true })
  map("n", "<Leader>8", ":BufferLineGoToBuffer 8<CR>", { silent = true })
  map("n", "<Leader>9", ":BufferLineGoToBuffer 9<CR>", { silent = true })

  -- TODO: Fix this
  -- cmd("packadd bufferline.nvim")
  -- cmd [[hi TabLineSel guibg=#ddc7a1]]
  M.setup()
end

init()

return M
