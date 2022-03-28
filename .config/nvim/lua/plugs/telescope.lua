-- local sorters = require "telescope.sorters"
-- local previewers = require "telescope.previewers"
-- local lutils = require("lutils")
-- local Path = require("plenary.path")
-- local utils = require("telescope.utils")
-- local pickers = require("telescope.pickers")
-- local finders = require("telescope.finders")
-- local make_entry = require("telescope.make_entry")
-- local conf = require("telescope.config").values
-- local themes = require("telescope.themes")
local telescope = require("telescope")
local actions = require("telescope.actions")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local action_layout = require("telescope.actions.layout")

-- ============================ Config ===========================

require("telescope").setup(
    {
      defaults = {
        prompt_prefix = "❱ ",
        selection_caret = "❱ ",
        entry_prefix = "  ",
        initial_mode = "insert",
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        use_less = true,
        path_display = {},
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-t>"] = action_layout.toggle_preview,
            ["<C-s>"] = actions.select_horizontal,

            ["<C-x>"] = false,
            ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist,
            -- ["<C-g>"] = custom_actions.multi_selection_open,
          },
          n = { ["<ESC>"] = actions.close },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        file_ignore_patterns = {
          "%.jpg",
          "%.jpeg",
          "%.png",
          "%.svg",
          "%.otf",
          "%.ttf",
          "target/.*",
          ".git/.*",
          "node_modules/.*",
        },
        file_sorter = sorters.get_fuzzy_file,
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        selection_strategy = "reset",
        sorting_strategy = "descending",
        -- layout_strategy = "horizontal",
        layout_strategy = "flex",
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
        winblend = 3,
        set_env = { ["COLORTERM"] = "truecolor" },
        color_devicons = true,
        scroll_strategy = "cycle",
      },
      pickers = {
        live_grep = {
          grep_open_files = false,
          only_sort_text = true,
          theme = "ivy",
        },
        find_files = { theme = "ivy" },
      },
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
        frecency = {
          ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
        },
      },
    }
)

-- telescope_builtin.packer = function(opts)
--   require("telescope").extensions.packer.plugins(opts)
-- end

-- ============================ Setup ============================

local options = {
  path_display = {},
  layout_strategy = "horizontal",
  layout_config = { preview_width = 0.65 },
}

function _G.__telescope_files()
  -- Launch file search using Telescope
  if vim.fn.isdirectory ".git" ~= 0 then
    -- if in a git project, use :Telescope git_files
    require("telescope.builtin").git_files(options)
  else
    -- otherwise, use :Telescope find_files
    require("telescope.builtin").find_files(options)
  end
end

function _G.__telescope_buffers()
  require("telescope.builtin").buffers(
      require("telescope.themes").get_dropdown {
        preview = true,
        only_cwd = false,
        sort_mru = true,
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
      }
  )
end

function _G.__telescope_grep()
  require("telescope.builtin").live_grep {
    require("telescope.themes").get_ivy {
      path_display = {},
      layout_strategy = "horizontal",
      grep_open_files = false,
      layout_config = { preview_width = 0.4 },
    },
  }
end

function _G.__telescope_commits()
  require("telescope.builtin").git_commits {
    layout_strategy = "horizontal",
    layout_config = { preview_width = 0.55 },
  }
end

-- telescope.load_extension("ultisnips")
-- telescope.load_extension("coc")
-- telescope.load_extension("bookmarks")
-- telescope.load_extension("fzf")
-- telescope.load_extension("neoclip")
-- telescope.load_extension("frecency")
-- telescope.load_extension("packer")

-- ========================== Mappings ===========================
local map = require("common.utils").map

map("n", ";b", ":Telescope builtin<CR>")
map("n", ";c", ":Telescope commands<CR>")
map("n", ";B", ":Telescope bookmarks<CR>")

map("n", "<Leader>;", ":Telescope current_buffer_fuzzy_find<CR>")
map("n", ";r", ":Telescope git_grep<CR>")
map("n", "<A-.>", ":Telescope frequency<CR>")
map("n", ";fd", ":Telescope fd<CR>")
map("n", ";g", ":Telescope git_files<CR>")

map("n", "<Leader>hc", ":Telescope command_history<CR>")
map("n", "<Leader>hs", ":Telescope search_history<CR>")
map("n", "<Leader>cs", ":Telescope colorscheme<CR>")

map("n", ";s", ":Telescope coc workspace_symbols<CR>")

map("n", "<LocalLeader>c", ":Telescope coc<CR>")
map("n", "<A-c>", ":Telescope coc commands<CR>")
map("n", "<C-x>h", ":Telescope coc diagnostics<CR>")
map("n", "<C-x><C-r>", ":Telescope coc references<CR>")
map("n", "<C-[>", ":Telescope coc definitions<CR>")
map("n", ";n", ":Telescope coc locations<CR>")
map("n", "<A-;>", ":Telescope neoclip<CR>")

-- map("n", "<LocalLeader>f", ":Telescope find_files<CR>")
-- map("n", ";e", ":Telescope live_grep theme=get_ivy<CR>")

map("n", "<LocalLeader>b", ":lua __telescope_buffers()<CR>")
map("n", "<LocalLeader>f", ":lua __telescope_files()<CR>")
map("n", ";e", ":lua __telescope_grep()<CR>")

-- ========================== Highlight ==========================
vim.cmd [[highlight TelescopeSelection  guifg=#FF9500 gui=bold]]
cmd [[highlight TelescopeSelectionCaret guifg=#819C3B]]
cmd [[highlight TelescopeMultiSelection guifg=#4C96A8]]
cmd [[highlight TelescopeMultiIcon      guifg=#7EB2B1]]
cmd [[highlight TelescopeNormal         guibg=#00000]]
cmd [[highlight TelescopeBorder         guifg=#A06469]]
cmd [[highlight TelescopePromptBorder   guifg=#A06469]]
cmd [[highlight TelescopeResultsBorder  guifg=#A06469]]
cmd [[highlight TelescopePreviewBorder  guifg=#A06469]]
cmd [[highlight TelescopeMatching       guifg=#FF5813]]
cmd [[highlight TelescopePromptPrefix   guifg=#EF1D55]]


-- -- ========================== Extra ==========================
--
-- local function join_uniq(tbl, tbl2)
--   local res = {}
--   local hash = {}
--   for _, v1 in ipairs(tbl) do
--     res[#res + 1] = v1
--     hash[v1] = true
--   end
--
--   for _, v in pairs(tbl2) do
--     if not hash[v] then
--       table.insert(res, v)
--     end
--   end
--   return res
-- end
--
-- local function filter_by_cwd_paths(tbl, cwd)
--   local res = {}
--   local hash = {}
--   for _, v in ipairs(tbl) do
--     if v:find(cwd, 1, true) then
--       local v1 = Path:new(v):normalize(cwd)
--       if not hash[v1] then
--         res[#res + 1] = v1
--         hash[v1] = true
--       end
--     end
--   end
--   return res
-- end
--
-- local function requiref(module)
--   require(module)
-- end
--
-- -- ========================== Builtin ==========================
--
-- telescope_builtin.cst_mru = function(opts)
--   local get_mru = function(opts)
--     local res = pcall(requiref, "telescope._extensions.frecency")
--     if not res then
--       return vim.tbl_filter(
--           function(val)
--             return 0 ~= vim.fn.filereadable(val)
--           end, vim.v.oldfiles
--       )
--     else
--       local db_client = require("telescope._extensions.frecency.db_client")
--       db_client.init()
--       -- too slow
--       -- local tbl = db_client.get_file_scores(opts, vim.fn.getcwd())
--       local tbl = db_client.get_file_scores(opts)
--       local get_filename_table = function(tbl)
--         local res = {}
--         for _, v in pairs(tbl) do
--           res[#res + 1] = v["filename"]
--         end
--         return res
--       end
--       return get_filename_table(tbl)
--     end
--   end
--   local results_mru = get_mru(opts)
--   local results_mru_cur = filter_by_cwd_paths(results_mru, vim.loop.cwd())
--
--   local show_untracked = utils.get_default(opts.show_untracked, true)
--   local recurse_submodules = utils.get_default(opts.recurse_submodules, false)
--   if show_untracked and recurse_submodules then
--     error("Git does not suppurt both --others and --recurse-submodules")
--   end
--   local cmd = {
--     "git",
--     "ls-files",
--     "--exclude-standard",
--     "--cached",
--     show_untracked and "--others" or nil,
--     recurse_submodules and "--recurse-submodules" or nil,
--   }
--   local results_git = utils.get_os_command_output(cmd)
--
--   local results = join_uniq(results_mru_cur, results_git)
--
--   pickers.new(
--       opts, {
--         prompt_title = "MRU",
--         finder = finders.new_table(
--             {
--               results = results,
--               entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
--             }
--         ),
--         -- default_text = vim.fn.getcwd(),
--         sorter = conf.file_sorter(opts),
--         previewer = conf.file_previewer(opts),
--       }
--   ):find()
-- end
--
-- -- Grep a string with a prompt
-- telescope_builtin.grep_prompt = function(opts)
--   opts.search = vim.fn.input("Grep String > ")
--   telescope_builtin.cst_grep(opts)
-- end
--
-- telescope_builtin.cst_grep = function(opts)
--   require("telescope.builtin").grep_string(
--       {
--         opts = opts,
--         prompt_title = "grep_string: " .. opts.search,
--         search = opts.search,
--       }
--   )
-- end
--
-- telescope_builtin.cst_grep_in_dir = function(opts)
--   opts.search = vim.fn.input("Grep String > ")
--   opts.search_dirs = {}
--   opts.search_dirs[1] = vim.fn.input("Target Directory > ")
--   require("telescope.builtin").grep_string(
--       {
--         opts = opts,
--         prompt_title = "grep_string(dir): " .. opts.search,
--         search = opts.search,
--         search_dirs = opts.search_dirs,
--       }
--   )
-- end
--
-- -- TODO: Fix showing full path
-- -- Live grep in the base git repo
-- telescope_builtin.git_grep = function(opts)
--   opts.search_dirs = {}
--   opts.search_dirs[1] = lutils.capture("git rev-parse --show-toplevel")
--   opts.vimgrep_arguments = {
--     "rg",
--     "--color=never",
--     "--no-heading",
--     "--with-filename",
--     "--line-number",
--     "--column",
--     "--smart-case",
--   }
--   telescope_builtin.live_grep(
--       {
--         mappings = conf.mappings,
--         opts = opts,
--         prompt_title = "Git Grep",
--         search_dirs = opts.search_dirs,
--       }
--   )
-- end
