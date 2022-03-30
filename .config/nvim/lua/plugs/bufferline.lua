local M = {}

local utils = require("common.utils")
local map = utils.map

function M.setup()
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

          -- diagnostics = "coc", -- false
          -- diagnostics_indicator = function(
          --     count, level, diagnostics_dict, context
          -- ) return "(" .. count .. ")" end,

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
          fill = { guifg = "#A06469", guibg = "#221a0f" },
          background = { guifg = "#e8c097", guibg = "#221a0f" },

          tab = { guifg = "#e8c097", guibg = "#221a0f" },
          tab_selected = { guifg = "#e8c097", guibg = "#5e452b" },
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
          buffer_visible = {
            guifg = "#A06469",
            guibg = "#5e452b",
          },
          buffer_selected = {
            guifg = "#e8c097",
            guibg = "#5e452b",
            gui = "bold,italic",
          },
          -- diagnostic = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- diagnostic_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- diagnostic_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          -- },
          -- info = {
          --   guifg = "#FFFFFF",
          --   guisp = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- info_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- info_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          --   guisp = "#FFFFFF",
          -- },
          -- info_diagnostic = {
          --   guifg = "#FFFFFF",
          --   guisp = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- info_diagnostic_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- info_diagnostic_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          --   guisp = "#FFFFFF",
          -- },
          -- warning = {
          --   guifg = "#FFFFFF",
          --   guisp = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- warning_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- warning_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          --   guisp = "#FFFFFF",
          -- },
          -- warning_diagnostic = {
          --   guifg = "#FFFFFF",
          --   guisp = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- warning_diagnostic_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- warning_diagnostic_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          --   guisp = warning_diagnostic_fg,
          -- },
          -- error = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   guisp = "#FFFFFF",
          -- },
          -- error_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- error_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          --   guisp = "#FFFFFF",
          -- },
          -- error_diagnostic = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   guisp = "#FFFFFF",
          -- },
          -- error_diagnostic_visible = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          -- error_diagnostic_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          --   gui = "bold,italic",
          --   guisp = "#FFFFFF",
          -- },
          modified = {
            guifg = "#EF1D55",
            guibg = "#221a0f",
          },
          modified_visible = {
            guifg = "#EF1D55",
            guibg = "#5e452b",
          },
          modified_selected = {
            guifg = "#EF1D55",
            guibg = "#5e452b",
          },
          -- duplicate_selected = {
          --   guifg = "#FFFFFF",
          --   gui = "italic",
          --   guibg = "#FFFFFF",
          -- },
          -- duplicate_visible = {
          --   guifg = "#FFFFFF",
          --   gui = "italic",
          --   guibg = "#FFFFFF",
          -- },
          -- duplicate = {
          --   guifg = "#FFFFFF",
          --   gui = "italic",
          --   guibg = "#FFFFFF",
          -- },
          separator_selected = {
            guifg = "#221a0f",
            guibg = "#5e452b",
          },
          separator_visible = {
            guifg = "#221a0f",
            guibg = "#5e452b",
          },
          separator = {
            guifg = "#221a0f",
            guibg = "#221a0f",
          },
          -- indicator_selected = {
          --   guifg = "#FFFFFF",
          --   guibg = "#FFFFFF",
          -- },
          pick_selected = {
            guifg = "#DC3958",
            guibg = "#5e452b",
            gui = "bold,italic",
          },
          pick_visible = {
            guifg = "#819C3B",
            guibg = "#221a0f",
            gui = "bold,italic",
          },
          pick = {
            guifg = "#819C3B",
            guibg = "#221a0f",
            gui = "bold,italic",
          },
        },
      }
  )
end

local function init()
  map("n", "<Leader>bu", ":BufferLinePick<CR>", { silent = true })

  map("n", "[b", ":BufferLineCyclePrev<CR>", { silent = true })
  map("n", "]b", ":BufferLineCycleNext<CR>", { silent = true })
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
