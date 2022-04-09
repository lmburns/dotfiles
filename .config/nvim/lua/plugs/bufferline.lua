local M = {}

local utils = require("common.utils")
local map = utils.map

function M.setup()
  local diagnostics_signs = {
    error = "",
    warning = "",
    hint = "",
    info = ""
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

          -- INFO: this will be called a lot so don't do any heavy processing here
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
        highlights = require("kimbox.bufferline").theme()
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

  for i = 1, 9 do
    i = tostring(i)
    map(
        "n", "<Leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>",
        { silent = true }
    )
  end

  M.setup()
end

init()

return M
