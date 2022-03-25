local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")

local custom_actions = {}

function custom_actions._multiopen(prompt_bufnr, open_cmd)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = #picker:get_multi_selection()
  if num_selections > 1 then
    vim.cmd("bw!")
    for _, entry in ipairs(picker:get_multi_selection()) do
      vim.cmd(string.format("%s %s", open_cmd, entry.value))
    end
    vim.cmd("stopinsert")
  else
    if open_cmd == "vsplit" then
      actions.file_vsplit(prompt_bufnr)
    elseif open_cmd == "split" then
      actions.file_split(prompt_bufnr)
    elseif open_cmd == "tabe" then
      actions.file_tab(prompt_bufnr)
    else
      actions.file_edit(prompt_bufnr)
    end
  end
end

function custom_actions.multi_selection_open_vsplit(prompt_bufnr)
  custom_actions._multiopen(prompt_bufnr, "vsplit")
end
function custom_actions.multi_selection_open_split(prompt_bufnr)
  custom_actions._multiopen(prompt_bufnr, "split")
end
function custom_actions.multi_selection_open_tab(prompt_bufnr)
  custom_actions._multiopen(prompt_bufnr, "tabe")
end
function custom_actions.multi_selection_open(prompt_bufnr)
  custom_actions._multiopen(prompt_bufnr, "edit")
end

require("telescope").setup {
  defaults = {
    mappings = {
      n = {
        ["<esc>"] = actions.close,
        ["<c-t>"] = action_layout.toggle_preview,
        ["<c-s>"] = actions.select_horizontal,

        ["<C-x>"] = false,
        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<C-q>"] = actions.send_selected_to_qflist,
        ["<CR>"] = actions.select_default + actions.center,
        ["<C-g>"] = custom_actions.multi_selection_open,
      },
      i = { ["<c-t>"] = action_layout.toggle_preview },
    },
    vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename", "--line-number",
      "--column", "--smart-case",
    },
    prompt_prefix = "❱ ",
    selection_caret = "❱ ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.85,
      horizontal = {
        mirror = false,
        prompt_position = "bottom",
        preview_cutoff = 120,
        preview_width = 0.5,
      },
      vertical = {
        mirror = false,
        prompt_position = "bottom",
        preview_cutoff = 120,
        preview_width = 0.5,
      },
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "target/.*", ".git/.*", "node_modules/.*" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    use_less = true,
    path_display = {},
    scroll_strategy = "cycle",
    set_env = { ["COLORTERM"] = "truecolor" },
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
  },
  pickers = {
    buffers = {
      preview = true,
      only_cwd = false,
      show_all_buffers = false,
      ignore_current_buffer = true,
      sort_lastused = true,
      theme = "dropdown",
      sorter = require("telescope.sorters").get_substr_matcher(),
      selection_strategy = "closest",
      path_display = { "shorten" },
      layout_strategy = "center",
      winblend = 0,
      layout_config = { width = 70 },
      color_devicons = true,
      mappings = {
        i = { ["<c-d>"] = actions.delete_buffer },
        n = { ["<c-d>"] = actions.delete_buffer },
      },
    },
    live_grep = { grep_open_files = false, theme = "ivy" },
    find_files = { theme = "ivy" },
  },
  mappings = { n = {}, i = {} },
  extensions = {
    bookmarks = {
      selected_browser = "buku",
      url_open_command = "handlr open",
      url_open_plugin = nil,
      full_path = true,
      firefox_profile_name = nil,
    },
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    frecency = { ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" } },
  },
}

local lutils = require('lutils')

local Path = require("plenary.path")

local telescope_builtin = require("telescope.builtin")
local utils = require("telescope.utils")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local themes = require("telescope.themes")

local function join_uniq(tbl, tbl2)
  local res = {}
  local hash = {}
  for _, v1 in ipairs(tbl) do
    res[#res + 1] = v1
    hash[v1] = true
  end

  for _, v in pairs(tbl2) do
    if not hash[v] then
      table.insert(res, v)
    end
  end
  return res
end

local function filter_by_cwd_paths(tbl, cwd)
  local res = {}
  local hash = {}
  for _, v in ipairs(tbl) do
    if v:find(cwd, 1, true) then
      local v1 = Path:new(v):normalize(cwd)
      if not hash[v1] then
        res[#res + 1] = v1
        hash[v1] = true
      end
    end
  end
  return res
end

local function requiref(module)
  require(module)
end

telescope_builtin.cst_mru = function(opts)
  local get_mru = function(opts)
    local res = pcall(requiref, "telescope._extensions.frecency")
    if not res then
      return vim.tbl_filter(
          function(val)
            return 0 ~= vim.fn.filereadable(val)
          end, vim.v.oldfiles
      )
    else
      local db_client = require("telescope._extensions.frecency.db_client")
      db_client.init()
      -- too slow
      -- local tbl = db_client.get_file_scores(opts, vim.fn.getcwd())
      local tbl = db_client.get_file_scores(opts)
      local get_filename_table = function(tbl)
        local res = {}
        for _, v in pairs(tbl) do
          res[#res + 1] = v["filename"]
        end
        return res
      end
      return get_filename_table(tbl)
    end
  end
  local results_mru = get_mru(opts)
  local results_mru_cur = filter_by_cwd_paths(results_mru, vim.loop.cwd())

  local show_untracked = utils.get_default(opts.show_untracked, true)
  local recurse_submodules = utils.get_default(opts.recurse_submodules, false)
  if show_untracked and recurse_submodules then
    error("Git does not suppurt both --others and --recurse-submodules")
  end
  local cmd = {
    "git", "ls-files", "--exclude-standard", "--cached",
    show_untracked and "--others" or nil,
    recurse_submodules and "--recurse-submodules" or nil,
  }
  local results_git = utils.get_os_command_output(cmd)

  local results = join_uniq(results_mru_cur, results_git)

  pickers.new(
      opts, {
        prompt_title = "MRU",
        finder = finders.new_table(
            {
              results = results,
              entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
            }
        ),
        -- default_text = vim.fn.getcwd(),
        sorter = conf.file_sorter(opts),
        previewer = conf.file_previewer(opts),
      }
  ):find()
end

-- Grep a string with a prompt
telescope_builtin.grep_prompt = function(opts)
  opts.search = vim.fn.input("Grep String > ")
  telescope_builtin.cst_grep(opts)
end

telescope_builtin.cst_grep = function(opts)
  require("telescope.builtin").grep_string(
      {
        opts = opts,
        prompt_title = "grep_string: " .. opts.search,
        search = opts.search,
      }
  )
end

telescope_builtin.cst_grep_in_dir = function(opts)
  opts.search = vim.fn.input("Grep String > ")
  opts.search_dirs = {}
  opts.search_dirs[1] = vim.fn.input("Target Directory > ")
  require("telescope.builtin").grep_string(
      {
        opts = opts,
        prompt_title = "grep_string(dir): " .. opts.search,
        search = opts.search,
        search_dirs = opts.search_dirs,
      }
  )
end

-- TODO: Fix showing full path
-- Live grep in the base git repo
telescope_builtin.git_grep = function(opts)
  opts.search_dirs = {}
  opts.search_dirs[1] = lutils.capture("git rev-parse --show-toplevel")
  opts.vimgrep_arguments = {
    "rg", "--color=never", "--no-heading", "--with-filename", "--line-number",
    "--column", "--smart-case",
  }
  telescope_builtin.live_grep(
      {
        mappings = conf.mappings,
        opts = opts,
        prompt_title = "Git Grep",
        search_dirs = opts.search_dirs,
      }
  )
end

-- ============================== Neoclip =============================
-- ====================================================================

require("telescope").load_extension("ultisnips")
require("telescope").load_extension("coc")
require("telescope").load_extension("bookmarks")
require("telescope").load_extension("fzf")
require("telescope").load_extension("frecency")
