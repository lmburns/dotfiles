local actions = require('telescope.actions')
local action_layout = require('telescope.actions.layout')

require("telescope").setup {
  defaults = {
    mappings = { n = { ["<esc>"] = actions.close } },
    vimgrep_arguments = {
      'rg', '--color=never', '--no-heading', '--with-filename', '--line-number',
      '--column', '--smart-case'
    },
    prompt_prefix = "❱ ",
    selection_caret = "❱ ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = { mirror = false },
      vertical = { mirror = false }
    },
    file_sorter = require('telescope.sorters').get_fuzzy_file,
    file_ignore_patterns = { "target/.*", ".git/.*", "node_modules/.*" },
    generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
    winblend = 0,
    border = {},
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    color_devicons = true,
    use_less = true,
    path_display = {},
    scroll_strategy = "cycle",
    set_env = { ['COLORTERM'] = 'truecolor' },
    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      theme = "ivy",
      -- previewer = true,
      mappings = {
        i = { ["<c-d>"] = actions.delete_buffer },
        n = { ["<c-d>"] = actions.delete_buffer }
      }
    },
    live_grep = { grep_open_files = false },
    find_files = {
      theme = "ivy"
      -- Theme: ivy, cursor, dropdown
    }
  },
  mappings = {
    i = { ["<c-t>"] = action_layout.toggle_preview },
    n = {
      ["<c-t>"] = action_layout.toggle_preview,
      ["<c-s>"] = actions.select_horizontal
    }
  },
  extensions = {
    bookmarks = {
      selected_browser = 'buku',
      url_open_command = 'handlr open',
      url_open_plugin = nil,
      full_path = true,
      firefox_profile_name = nil
    }
  }
}

-- Telescope find_files theme=get_dropdown

require('telescope').load_extension('ultisnips')
require('telescope').load_extension('coc')
require('telescope').load_extension('bookmarks')
