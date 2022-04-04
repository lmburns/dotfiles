local themes = require("telescope.themes")
local utils = require("telescope.utils")
local Path = require("plenary.path")
local lutils = require("lutils")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local action_layout = require("telescope.actions.layout")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

require("common.utils")
require("lutils")

-- ============================ Config ===========================

require("telescope").setup(
    -- Why is this on?
    ---@diagnostic disable-next-line: redundant-parameter
    {
      defaults = {
        history = {
          path = fn.stdpath("data") .. "/databases/telescope_history.sqlite3",
          limit = 10000,
        },
        prompt_prefix = "❱ ",
        selection_caret = "❱ ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        -- layout_strategy = "flex",
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        use_less = true,
        path_display = {},
        mappings = {
          i = {
            ["<C-x>"] = false,
            -- ["<C-j>"] = actions.move_selection_next,
            -- ["<C-k>"] = actions.move_selection_previous,

            ["<C-k>"] = actions.cycle_history_next,
            ["<C-j>"] = actions.cycle_history_prev,

            -- ["<C-m>"] = action_layout.toggle_mirror,
            ["<C-t>"] = action_layout.toggle_preview,
            ["<M-p>"] = action_layout.toggle_prompt_position,

            ["<C-s>"] = actions.select_horizontal,
            ["<C-d>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.results_scrolling_up,

            ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist,

            ["<C-w>"] = function() vim.api.nvim_input "<c-s-w>" end,
          },
          n = {
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,

            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,

            ["?"] = action_layout.toggle_preview,

            ["<ESC>"] = actions.close,
            ["<C-d>"] = actions.results_scrolling_down,
            ["<C-u>"] = actions.results_scrolling_up,
          },
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
        find_command = {
          "fd",
          "--type=f",
          "--hidden",
          "--follow",
          "--exclude=.git",
          "--strip-cwd-prefix",
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
        layout_config = {
          width = 0.85,
          horizontal = {
            mirror = false,
            prompt_position = "bottom",
            preview_cutoff = 120,
            preview_width = function(_, cols, _)
              if cols > 200 then
                return math.floor(cols * 0.4)
              else
                return math.floor(cols * 0.5)
              end
            end,
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
            n = {
              ["<c-d>"] = actions.delete_buffer,
              ["x"] = function(prompt_bufnr)
                local current_picker = action_state.get_current_picker(
                    prompt_bufnr
                )
                local selected_bufnr = action_state.get_selected_entry().bufnr

                --- get buffers with lower number
                local replacement_buffers = {}
                for entry in current_picker.manager:iter() do
                  if entry.bufnr < selected_bufnr then
                    table.insert(replacement_buffers, 1, entry.bufnr)
                  end
                end

                current_picker:delete_selection(
                    function(selection)
                      local bufnr = selection.bufnr
                      -- get associated window(s)
                      local winids = fn.win_findbuf(bufnr)
                      -- get windows in current tab to check
                      local tabwins = api.nvim_tabpage_list_wins(0)
                      -- fill winids with new empty buffers
                      for _, winid in ipairs(winids) do
                        if vim.tbl_contains(tabwins, winid) then
                          local new_buf = vim.F.if_nil(
                              table.remove(replacement_buffers),
                              api.nvim_create_buf(false, true)
                          )
                          api.nvim_win_set_buf(winid, new_buf)
                        end
                      end
                      -- remove buffer at last
                      api.nvim_buf_delete(bufnr, { force = true })
                    end
                )
              end,
            },
          },
        },

        live_grep = {
          grep_open_files = false,
          only_sort_text = true,
          theme = "ivy",
        },

        find_files = {
          theme = "ivy",
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
          on_input_filter_cb = function(prompt)
            if prompt:sub(#prompt) == "@" then
              vim.schedule(
                  function()
                    local prompt_bufnr = api.nvim_get_current_buf()
                    actions.select_default(prompt_bufnr)
                    builtin.current_buffer_fuzzy_find()
                    -- properly enter prompt in insert mode
                    cmd [[normal! A]]
                  end
              )
            end
          end,
        },

        git_commits = {
          mappings = {
            i = {
              ["<C-l>"] = function(prompt_bufnr)
                R("telescope.actions").close(prompt_bufnr)
                local value = action_state.get_selected_entry().value
                cmd("DiffviewOpen " .. value .. "~1.." .. value)
              end,

              ["<C-s>"] = function(prompt_bufnr)
                R("telescope.actions").close(prompt_bufnr)
                local value = action_state.get_selected_entry().value
                cmd("DiffviewOpen " .. value)
              end,

              ["<C-u>"] = function(prompt_bufnr)
                R("telescope.actions").close(prompt_bufnr)
                local value = action_state.get_selected_entry().value
                local rev = utils.get_os_command_output(
                                { "git", "rev-parse", "upstream/master" },
                                uv.cwd()
                            )[1]
                cmd("DiffviewOpen " .. rev .. " " .. value)
              end,
            },
          },
        },
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

        packer = {
          theme = "ivy",
          layout_config = { height = .5 },
          preview = false,
          mappings = {
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

          },
        },

        file_browser = { theme = "ivy", mappings = { ["i"] = {}, ["n"] = {} } },

        ["ui-select"] = {
          themes.get_dropdown {
            -- even more opts
          },
        },
      },
    }
)

-- builtin.packer = function(opts)
--   require("telescope").extensions.packer.plugins(opts)
-- end

-- ============================ Setup ============================

local options = {
  hidden = true,
  path_display = {},
  layout_strategy = "horizontal",
  layout_config = { preview_width = 0.65 },
  border = {},
  borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

-- ========================== Helper ==========================

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

local function requiref(module) require(module) end

-- ========================== Builtin ==========================

function _G.__telescope_files()
  -- Launch file search using Telescope
  if fn.isdirectory ".git" ~= 0 then
    -- if in a git project, use :Telescope git_files
    builtin.git_files(options)
  else
    -- otherwise, use :Telescope find_files
    builtin.find_files(options)
  end
end

function _G.__telescope_buffers()
  builtin.buffers(
      themes.get_dropdown {
        preview = true,
        only_cwd = false,
        sort_mru = true,
        show_all_buffers = false,
        ignore_current_buffer = true,
        sort_lastused = true,
        theme = "dropdown",
        sorter = sorters.get_substr_matcher(),
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
  builtin.live_grep {
    themes.get_ivy {
      path_display = {},
      layout_strategy = "horizontal",
      grep_open_files = false,
      layout_config = { preview_width = 0.4 },
    },
  }
end

function _G.__telescope_commits()
  builtin.git_commits {
    layout_strategy = "horizontal",
    layout_config = { preview_width = 0.55 },
  }
end

function _G.installed_plugins()
  builtin.find_files { cwd = fn.stdpath("data") .. "/site/pack/packer/" }
end

-- Doesn't work
function _G.__telescope_grep_cword()
  builtin.grep_string {
    path_display = { "absolute" },
    word_match = "-w",
    search = vim.fn.expand("<cword>"),
  }
end

-- Doesn't work
function _G.__telescope_grep_cWORD()
  builtin.grep_string {
    path_display = { "absolute" },
    search = vim.fn.expand("<cWORD>"),
  }
end

-- vim.keymap.set(
--     "n", "<leader>os", function()
--       require("telescope.builtin").live_grep {
--         search_dirs = { lutils.capture("git rev-parse --show-toplevel") },
--       }
--     end
-- )
--
-- gittool.exe_root(...)

builtin.cst_mru = function(opts)
  local get_mru = function(opts)
    local res = pcall(requiref, "telescope._extensions.frecency")
    if not res then
      return vim.tbl_filter(
          function(val) return 0 ~= fn.filereadable(val) end, vim.v.oldfiles
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
    error("Git does not support both --others and --recurse-submodules")
  end
  local cmd = {
    "git",
    "ls-files",
    "--exclude-standard",
    "--cached",
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
builtin.grep_prompt = function(opts)
  opts.search = vim.fn.input("Grep String > ")
  builtin.cst_grep(opts)
end

builtin.cst_grep = function(opts)
  builtin.grep_string(
      {
        opts = opts,
        prompt_title = "grep_string: " .. opts.search,
        search = opts.search,
      }
  )
end

builtin.cst_grep_in_dir = function(opts)
  opts.search = vim.fn.input("Grep String > ")
  opts.search_dirs = {}
  opts.search_dirs[1] = vim.fn.input("Target Directory > ")
  builtin.grep_string(
      {
        opts = opts,
        prompt_title = "grep_string(dir): " .. opts.search,
        search = opts.search,
        search_dirs = opts.search_dirs,
      }
  )
end

builtin.git_grep = function(opts)
  opts.search_dirs = {}
  opts.search_dirs[1] = utils.get_os_command_output{
    "git",
    "rev-parse",
    "--show-toplevel",
  }[1]

  opts.vimgrep_arguments = {
    "rg",
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
  }
  builtin.live_grep(
      {
        mappings = conf.mappings,
        opts = opts,
        prompt_title = "Git Grep",
        search_dirs = opts.search_dirs,
        path_display = { "smart" },
      }
  )
end

-- Frecency messes up with prompt_title
builtin.edit_nvim = function()
  builtin.fd { path_display = { "smart" }, search_dirs = { "~/.config/nvim" } }
end

builtin.edit_zsh = function()
  builtin.find_files {
    path_display = { "absolute" },
    cwd = "~/.config/zsh/",
    prompt = "~ zsh ~",
    hidden = true,

    layout_strategy = "vertical",
    layout_config = {
      horizontal = { width = { padding = 0.15 } },
      vertical = { preview_height = 0.70 },
    },
  }
end

-- ========================= Extensions ==========================
builtin.ultisnips = function(opts) telescope.extensions.ultisnips
    .ultisnips(opts) end

builtin.coc = function(opts) telescope.extensions.coc.coc(opts) end

builtin.ghq = function(opts) telescope.extensions.ghq.list(opts) end

-- ========================== Mappings ===========================
local map = require("common.utils").map

map("n", ";b", ":Telescope builtin<CR>")
map("n", ";c", ":Telescope commands<CR>")
map("n", ";B", ":Telescope bookmarks<CR>")

-- List buffers
map("n", "<Leader>bl", ":Telescope buffers<CR>", { silent = true })

-- vim.keymap.set(
--     "n", "<leader>so", function()
--       require("telescope.builtin").tags { only_current_buffer = true }
--     end
-- )

map("n", "<Leader>;", ":Telescope current_buffer_fuzzy_find<CR>")
map("n", ";r", ":Telescope git_grep<CR>")
map("n", "<A-.>", ":Telescope frecency<CR>")
map("n", "<A-,>", ":Telescope oldfiles<CR>")
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

map("n", "<Leader>si", ":Telescope ultisnips<CR>", { silent = true })

map("n", ";k", ":Telescope keymaps<CR>")

-- map("n", "<LocalLeader>f", ":Telescope find_files<CR>")
-- map("n", ";e", ":Telescope live_grep theme=get_ivy<CR>")

map("n", "<LocalLeader>b", ":lua __telescope_buffers()<CR>")
map("n", "<LocalLeader>f", ":lua __telescope_files()<CR>")
map("n", ";e", ":lua __telescope_grep()<CR>")
map("n", "<Leader>e;", ":Telescope edit_nvim<CR>")

map("n", "<Leader>e,", ":lua __telescope_grep_cWORD<CR>")

-- ========================== Highlight ==========================
cmd [[highlight TelescopeSelection      guifg=#FF9500 gui=bold]]
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

telescope.load_extension("notify")
-- telescope.load_extension("ultisnips")
-- telescope.load_extension("coc")
-- telescope.load_extension("bookmarks")
-- telescope.load_extension("fzf")
-- telescope.load_extension("neoclip")
-- telescope.load_extension("frecency")
-- telescope.load_extension("packer")
