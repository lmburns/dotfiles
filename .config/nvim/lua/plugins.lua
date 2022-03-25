require("common/utils")
require("lutils")

-- Install Packer if it isn"t already
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
local packer_exists = pcall(cmd, [[packadd packer.nvim]])
if not packer_exists then
  fn.system(
      "git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
end

cmd [[packadd packer.nvim]]
local _ = require("packer_file")
local packer = require("packer")
local use = packer.use

return packer.startup(
    function()
      -- Package manager
      use({ "wbthomason/packer.nvim", opt = true })

      -- ============================ Lua Library =========================== [[[
      use({ "nvim-lua/popup.nvim" })
      use({ "nvim-lua/plenary.nvim" })
      use({ "tami5/sqlite.lua" })
      -- ]]] === Lua Library ===

      -- ============================= Highlight ============================ [[[
      use(
          {
            "norcalli/nvim-colorizer.lua",
            event = "VimEnter",
            ft = { "vim", "sh", "zsh", "markdown", "tmux", "yaml", "lua" },
            config = function()
              require("colorizer").setup(
                  { "vim", "sh", "zsh", "markdown", "tmux", "yaml", "lua" },
                  { RGB = false }
              )
            end,
          }
      )
      use(
          {
            "Pocco81/HighStr.nvim",
            event = "VimEnter",
            config = function()
              require("plugins-d/HighStr")
            end,
          }
      )
      use(
          {
            "folke/todo-comments.nvim",
            event = "VimEnter",
            config = function()
              require("plugins-d/todo-comments")
            end,
          }
      )
      -- ]]] === Highlight ===

      -- ============================= Treesitter ============================ [[[
      use {
        "nvim-treesitter/nvim-treesitter",
        event = { "VimEnter" },
        -- event = { "BufRead", "BufNewFile" }, -- FIXME
        requires = {
          {
            "nvim-treesitter/nvim-treesitter-refactor",
            after = "nvim-treesitter",
          },
          {
            "nvim-treesitter/nvim-treesitter-textobjects",
            after = "nvim-treesitter",
          },
          { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
          { "p00f/nvim-ts-rainbow", after = { "nvim-treesitter" } },
        },
        run = ":TSUpdate",
        config = function()
          require("plugins-d/tree-sitter")
        end,
      }

      -- use({ "theHamsta/nvim-treesitter-pairs", after = { "nvim-treesitter" } })
      -- ]]] === Treesitter ===

      -- ============================= Telescope ============================ [[[
      -- nvim-neoclip: Clipboard manager
      use(
          {
            "AckslD/nvim-neoclip.lua",
            requires = {
              { "nvim-telescope/telescope.nvim", opt = true },
              { "tami5/sqlite.lua", opt = true },
            },
            after = { "telescope.nvim", "sqlite.lua" },
            config = function()
              require("plugins-d/nvim-neoclip")
            end,
          }
      )

      use(
          {
            "nvim-telescope/telescope.nvim",
            event = "VimEnter",
            requires = {
              { "nvim-lua/plenary.nvim", opt = true },
              { "nvim-lua/popup.nvim", opt = true },
            },
            after = { "popup.nvim", "plenary.nvim" },
            config = function()
              require("plugins-d/telescope")
            end,
          }
      )

      use(
          {
            "nvim-telescope/telescope-github.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("gh")
            end,
          }
      )

      use(
          {
            "nvim-telescope/telescope-ghq.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("ghq")
            end,
          }
      )

      use(
          {
            "nvim-telescope/telescope-fzf-writer.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("fzf_writer")
            end,
          }
      )

      use(
          {
            "nvim-telescope/telescope-frecency.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("frecency")
            end,
          }
      )

      use(
          { "nvim-telescope/telescope-packer.nvim",
            after = { "telescope.nvim" } }
      )

      use(
          {
            "fhill2/telescope-ultisnips.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("frecency")
            end,
          }
      )

      use(
          {
            "fannheyward/telescope-coc.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("coc")
            end,
          }
      )

      use(
          {
            "dhruvmanila/telescope-bookmarks.nvim",
            after = { "telescope.nvim" },
            config = function()
              require("telescope").load_extension("bookmarks")
            end,
          }
      )
      -- ]]] === Telescope ===

      -- ================================ Git =============================== [[[
      use(
          {
            "lewis6991/gitsigns.nvim",
            event = "VimEnter",
            config = function()
              require("plugins-d/gitsigns").config()
            end,
            wants = { "plenary.nvim" },
          }
      )

      use(
          {
            "TimUntersberger/neogit",
            event = "VimEnter",
            module = "neogit",
            config = function()
              require("plugins-d/neogit").config()
            end,
          }
      )

      use(
          {
            "sindrets/diffview.nvim",
            event = "VimEnter",
            cmd = { "DiffviewOpen", "DiffviewFileHistory" },
            config = function()
              require("plugins-d/diffview").config()
            end,
          }
      )
      -- ]]] === Git ===

      -- ================================ LSP =============================== [[[
      -- TODO: lua-dev
      -- Mainly for Lua LSP
      -- use(
      --     {
      --       "neovim/nvim-lspconfig",
      --       event = { "BufRead" },
      --       after = { "nvim-treesitter" },
      --       config = function()
      --         require("plugins-d/nvim-lspconfig")
      --       end,
      --       requires = { { "nvim-lua/lsp-status.nvim", opt = true } },
      --     }
      -- )

      -- Allows managing LSP servers
      -- use(
      --     {
      --       "williamboman/nvim-lsp-installer",
      --       after = { "nvim-lspconfig", "nlsp-settings.nvim" },
      --       config = function()
      --         require("plugins-d/nvim-lsp-installer")
      --       end,
      --     }
      -- )

      -- use(
      --     {
      --       "ray-x/lsp_signature.nvim",
      --       after = "nvim-lspconfig",
      --       config = function()
      --         require("lsp_signature").setup()
      --       end,
      --     }
      -- )
      --
      -- -- JSON/YAML files
      -- use(
      --     {
      --       "tamago324/nlsp-settings.nvim",
      --       after = { "nvim-lspconfig" },
      --       config = function()
      --         require("plugins-d/nlsp-settings")
      --       end,
      --     }
      -- )
      --
      -- use { "jose-elias-alvarez/null-ls.nvim", module = "null-ls" }
      --
      -- -- Neovim Lua
      -- use({ "tjdevries/nlua.nvim", event = "VimEnter" })
      -- use({ "bfredl/nvim-luadev", event = "VimEnter" })
      -- use({ "folke/lua-dev.nvim", after = { "nvim-lspconfig" } })
      -- ]]] === LSP ===

      -- ============================= Completion ============================ [[[
      -- use(
      --     {
      --       "hrsh7th/nvim-cmp",
      --       after = { "lspkind-nvim", "LuaSnip", "nvim-autopairs" },
      --       config = function()
      --         require("plugins/nvim-cmp")
      --       end,
      --     }
      -- )

      -- use(
      --     {
      --       "onsails/lspkind-nvim",
      --       event = "VimEnter",
      --       config = function()
      --         require("plugins/lspkind-nvim")
      --       end,
      --     }
      -- )

      -- use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-copilot", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-calc", after = "nvim-cmp" })
      -- use({ "f3fora/cmp-spell", after = "nvim-cmp" })
      -- use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
      -- use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
      -- ]]] === Completion ===

    end
)

-- require("packer").init({
--   compile_path = vim.fn.stdpath("data") ..
--       "/site/pack/loader/start/my-packer/plugin/packer.lua"
-- })
