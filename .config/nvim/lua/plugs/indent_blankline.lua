local M = {}

-- #A06469 #d3869b #4C96A8
cmd [[highlight IndentBlanklineContextChar guifg=#DC3958 gui=nocombine]]

function M.setup()
  require("indent_blankline").setup(
      {
        debug = true,
        viewport_buffer = 20,
        use_treesitter = true,
        char = "|",
        char_list = { "|", "¦", "┆", "┊" },
        show_first_indent_level = false,
        show_trailing_blankline_indent = false,
        show_current_context = true,
        show_current_context_start = false, -- underlines the start
        context_higlight_list = { "Error", "Warning" },
        show_end_of_line = false,
        context_char = "▏",
        context_patterns = {
          "^do",
          "^for",
          "^if",
          "^object",
          "^switch",
          "^table",
          "^while",
          "arguments",
          "block",
          "catch_clause",
          "class",
          "else_clause",
          "function",
          "if_statement",
          "import_statement",
          "method",
          "operation_type",
          "return",
          "try_statement",
        },
        buftype_exclude = { "nofile", "terminal" },
        filetype_exclude = {
          "",
          "NvimTree",
          "TelescopePrompt",
          "Trouble",
          "alpha",
          "floatline",
          "help",
          "log",
          "man",
          "packer",
          "json",
          "jsonc",
          "undotree",
          "diff",
          "fzf",
          "vimwiki",
          "floaterm",
          "neoterm",
          "toggleterm",
          "markdown",
          "vista",
          "dapui_scopes",
          "dapui_breakpoints",
          "dapui_stacks",
          "dapui_watches",
          "dap-repl",
        },
      }
  )
end

local function init()
  M.setup()
end

init()

return M