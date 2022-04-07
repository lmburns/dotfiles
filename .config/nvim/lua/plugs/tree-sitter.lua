local M = {}

local utils = require("common.utils")
local map = utils.map

local ft_enabled
local queries
local parsers
local configs

function M.has_textobj(ft)
  return queries.get_query(parsers.ft_to_lang(ft), "textobjects") ~= nil and
             true or false
end

function M.do_textobj(obj, inner, visual)
  local ret = false
  if queries.has_query_files(vim.bo.ft, "textobjects") then
    require("nvim-treesitter.textobjects.select").select_textobject(
        ("@%s.%s"):format(
            obj, inner and "inner" or "outer"
        ), visual and "x" or "o"
    )
    ret = true
  end
  return ret
end

function M.hijack_synset()
  local ft = fn.expand("<amatch>")
  local bufnr = tonumber(fn.expand("<abuf>"))
  local lcount = api.nvim_buf_line_count(bufnr)
  local bytes = api.nvim_buf_get_offset(bufnr, lcount)

  -- bytes / lcount < 500 LGTM :)
  if bytes / lcount < 500 then
    if ft_enabled[ft] then
      configs.reattach_module("highlight", bufnr)
      vim.defer_fn(
          function()
            configs.reattach_module("textobjects.move", bufnr)
          end, 300
      )
    else
      vim.bo.syntax = ft
    end
  end
end

function M.setup_iswap()
  cmd("packadd iswap.nvim")

  require("iswap").setup {
    grey = "disable",
    hl_snipe = "IncSearch",
    hl_selection = "MatchParen",
    autoswap = true,
  }

  map("n", "<Leader>sp", ":ISwap<CR>")
end

local function init()
  -- M.setup()

  local conf = {
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
      "typescript",
      -- "tsx",
      -- "vue",
      "zig",
    },
    sync_install = false,
    ignore_install = {}, -- List of parsers to ignore installing
    highlight = {
      enable = true, -- false will disable the whole extension
      disable = { "html", "comment", "zsh" }, -- list of language that will be disabled
      additional_vim_regex_highlighting = true,
    },
    autotag = { enable = true },
    autopairs = { enable = true },

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
    indent = { enable = true },
    endwise = { enable = true },
    matchup = { enable = false },
    textobjects = {
      select = { enable = true, disable = { "comment" } },
      move = {
        enable = true,
        disable = { "comment" },
        goto_next_start = { ["]m"] = "@function.outer" },
        goto_next_end = { ["]M"] = "@function.outer",
                          ["]f"] = "@function.outer" },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[f"] = "@function.outer",
        },
        goto_previous_end = { ["[M"] = "@function.outer" },
      },
    },
  }

  cmd("packadd nvim-treesitter")
  cmd("packadd nvim-treesitter-textobjects")

  configs = require("nvim-treesitter.configs")
  parsers = require("nvim-treesitter.parsers")
  configs.setup(conf)

  -- cmd("au! NvimTreesitter FileType *")
  M.setup_iswap()

  map(
      "x", "if",
      [[:<C-u>lua require('common.textobj').select('func', true, true)<CR>]]
  )
  map(
      "x", "af",
      [[:<C-u>lua require('common.textobj').select('func', false, true)<CR>]]
  )
  map("o", "if", [[<Cmd>lua require('common.textobj').select('func', true)<CR>]])
  map(
      "o", "af",
      [[<Cmd>lua require('common.textobj').select('func', false)<CR>]]
  )

  map(
      "x", "ik",
      [[:<C-u>lua require('common.textobj').select('class', true, true)<CR>]]
  )
  map(
      "x", "ak",
      [[:<C-u>lua require('common.textobj').select('class', false, true)<CR>]]
  )
  map(
      "o", "ik",
      [[<Cmd>lua require('common.textobj').select('class', true)<CR>]]
  )
  map(
      "o", "ak",
      [[<Cmd>lua require('common.textobj').select('class', false)<CR>]]
  )

  queries = require("nvim-treesitter.query")
  -- local hl_disabled = conf.highlight.disable
  -- ft_enabled = {}
  -- for _, lang in ipairs(conf.ensure_installed) do
  --   if not vim.tbl_contains(hl_disabled, lang) then
  --     local parser = parsers.list[lang]
  --     local used_by, filetype = parser.used_by, parser.filetype
  --     if used_by then
  --       for _, ft in ipairs(used_by) do
  --         ft_enabled[ft] = true
  --       end
  --     end
  --     ft_enabled[filetype or lang] = true
  --   end
  -- end
end

init()

return M
