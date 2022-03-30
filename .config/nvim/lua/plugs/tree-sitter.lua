require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "cmake",
    "css",
    "d",
    -- "dart",
    "dockerfile",
    "go",
    "gomod",
    "html",
    "java",
    -- "json",
    -- "kotlin",
    "lua",
    "make",
    "python",
    "query",
    "ruby",
    "rust",
    "scss",
    -- "teal",
    -- "typescript",
    -- "tsx",
    -- "vue",
    "zig",
  },
  sync_install = false,
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "html", "comment", "zsh" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = false,
  },
  autotag = { enable = true },

  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { "BufWrite", "CursorHold" },
  },
  incremental_selection = { enable = true },
  indent = { enable = false },
  endwise = { enable = true },
  matchup = { enable = false },
  textobjects = {
    select = { enable = true, disable = { "comment" } },
    move = {
      enable = true,
      disable = { "comment" },
      goto_next_start = { ["]m"] = "@function.outer" },
      goto_next_end = { ["]M"] = "@function.outer", ["]f"] = "@function.outer" },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[f"] = "@function.outer",
      },
      goto_previous_end = { ["[M"] = "@function.outer" },
    },
  },
}
