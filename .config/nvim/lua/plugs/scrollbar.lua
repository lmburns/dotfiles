local M = {}

local create_augroup = require("common.utils").create_augroup

function M.setup()
  require("scrollbar").setup(
      {
        show = true,
        set_highlights = true,
        handle = {
          text = " ",
          color = "#7E602C",
          cterm = nil,
          highlight = "CursorColumn",
          hide_if_all_visible = true, -- Hides handle if all lines are visible
        },
        marks = {
          Search = {
            text = { "-", "=" },
            priority = 0,
            color = nil,
            cterm = nil,
            highlight = "Search",
          },
          Error = {
            text = { "-", "=" },
            priority = 1,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextError",
          },
          Warn = {
            text = { "-", "=" },
            priority = 2,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextWarn",
          },
          Info = {
            text = { "-", "=" },
            priority = 3,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextInfo",
          },
          Hint = {
            text = { "-", "=" },
            priority = 4,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextHint",
          },
          Misc = {
            text = { "-", "=" },
            priority = 5,
            color = nil,
            cterm = nil,
            highlight = "Normal",
          },
        },
        excluded_buftypes = { "terminal" },
        excluded_filetypes = { "prompt", "TelescopePrompt", "bufferize" },
        autocmd = {
          render = {
            "BufEnter",
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
          },
        },
        handlers = {
          diagnostic = false, -- FIX: once coc is supported
          search = true, -- Requires hlslens to be loaded, will run require("scrollbar.handlers.search").setup() for you
        },
      }
  )
end

local function init()
  M.setup()

  -- api.nvim_create_autocmd(
  --     "VimEnter", {
  --       callback = function() require("scrollbar").show() end,
  --       pattern = "*",
  --       group = create_augroup("Scrollbar"),
  --     }
  -- )
end

init()

return M
