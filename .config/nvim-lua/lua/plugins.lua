local utils = require("common/utils")
local autocmd = utils.autocmd
require("lutils")

-- Install Packer if it isn't already
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
local packer_exists = pcall(cmd, [[packadd packer.nvim]])
if not packer_exists then
  fn.system(
      "git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
end

cmd [[packadd packer.nvim]]
local packer = require("packer")
local use = packer.use

-- [[BufWritePost plugins.lua, .config/nvim/lua/plugins-d/*.lua | PackerCompile]],
-- Recompile Packer when the file is saved
autocmd(
    "source_packer",
    { [[BufWritePost plugins.lua source <afile> | PackerSync]] }, true
)

packer.init(
    {
      compile_path = fn.stdpath("config") .. "/lua/compiled.lua",
      auto_clean = true,
      compile_on_sync = true,
      display = {
        title = "Packer",
        prompt_border = "rounded",
        open_fn = function()
          return require("packer.util").float({ border = "rounded" })
        end,
      },
      git = { clone_timeout = 300 },
      profile = { enable = true },
    }
)

return packer.startup(
    function()
      -- Package manager
      use({ "wbthomason/packer.nvim", opt = true })

      -- ============================ Lua Library =========================== [[[
      use({ "nvim-lua/popup.nvim" })
      use({ "nvim-lua/plenary.nvim" })
      use({ "tami5/sqlite.lua" })

      use({ "kyazdani42/nvim-web-devicons" })
      -- ]]] === Lua Library ===

      -- =============================== Icons ============================== [[[
      use({ "ryanoasis/vim-devicons" })
      use({ "wfxr/vizunicode.vim" })
      -- ]]] === Icons ===

      -- =========================== Colorscheme ============================ [[[
      local colorscheme = "kimbox"
      use(
          {
            "lmburns/kimbox",
            config = function()
              require("plugins-d/kimbox")
            end,
          }
      )
      -- ]]] === Colorscheme ===

      -- ============================ Statusline ============================ [[[
      -- use(
      --     {
      --       "nvim-lualine/lualine.nvim",
      --       after = colorscheme,
      --       requires = { "kyazdani42/nvim-web-devicons", opt = true },
      --       config = function()
      --         require("plugins-d/lualine")
      --       end,
      --     }
      -- )
      -- ]]] === Statusline ===

      -- ============================= Highlight ============================ [[[
      use(
          {
            "norcalli/nvim-colorizer.lua",
            event = "VimEnter",
            ft = { "vim", "sh", "zsh", "markdown", "tmux", "yaml", "lua" },
            config = function()
              require("plugins-d/colorizer")
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

      -- ============================= Telescope ============================ [[[
      -- 'numToStr/Comment.nvim'
      -- 'folke/which-key.nvim'
      --
      use {
        {
          "nvim-telescope/telescope.nvim",
          cmd = "Telescope",
          module = "telescope",
          requires = {
            "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim",
            "telescope-github.nvim",
            "telescope-ghq.nvim",
            "telescope-frecency.nvim",
            "telescope-coc.nvim",
            "telescope-ultisnips.nvim",
            "telescope-fzf-native.nvim",
          },
          wants = {
            "popup.nvim",
            "plenary.nvim",
            "telescope-github.nvim",
            "telescope-ghq.nvim",
            "telescope-frecency.nvim",
            "telescope-coc.nvim",
            "telescope-ultisnips.nvim",
            "telescope-fzf-native.nvim",
          },
          after = { "popup.nvim", "plenary.nvim", colorscheme },
          config = function()
            require("plugins-d/telescope")
          end,
        },
        {
          "nvim-telescope/telescope-github.nvim",
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("gh")
          end,
        },
        {
          "nvim-telescope/telescope-ghq.nvim",
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("ghq")
          end,
        },
        {
          "nvim-telescope/telescope-frecency.nvim",
          after = "telescope.nvim",
          requires = "tami5/sqlite.lua",
          config = function()
            require("telescope").load_extension("frecency")
          end,
        },
        { "nvim-telescope/telescope-packer.nvim", after = "telescope.nvim" },
        {
          "fannheyward/telescope-coc.nvim",
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("coc")
          end,
        },
        {
          "fhill2/telescope-ultisnips.nvim",
          after =  "telescope.nvim" ,
          config = function()
            require("telescope").load_extension("ultisnips")
          end,
        },
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          run = "make",
          config = function()
            require("telescope").load_extension("fzf")
          end,
        },
      }

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
      --
      -- ============================= Treesitter ============================ [[[
      use(
          {
            "nvim-treesitter/nvim-treesitter",
            event = { "VimEnter" },
            requires = {
              {
                "nvim-treesitter/nvim-treesitter-refactor",
                after = "nvim-treesitter",
              },
              {
                "nvim-treesitter/nvim-treesitter-textobjects",
                after = "nvim-treesitter",
              },
              { "nvim-treesitter/playground", after = "nvim-treesitter" },
              { "p00f/nvim-ts-rainbow", after = { "nvim-treesitter" } },
              { "nvim-treesitter/nvim-tree-docs", after = { "nvim-treesitter" } },
            },
            run = ":TSUpdate",
            config = function()
              require("plugins-d/tree-sitter")
            end,
          }
      )

      -- use({ "theHamsta/nvim-treesitter-pairs", after = { "nvim-treesitter" } })
      -- ]]] === Treesitter ===

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
      --       requires = {
      --         "hrsh7th/cmp-buffer",
      --         "hrsh7th/cmp-calc",
      --         "hrsh7th/cmp-cmdline",
      --         "hrsh7th/cmp-nvim-lsp",
      --         "hrsh7th/cmp-path",
      --         "hrsh7th/cmp-vsnip",
      --         "hrsh7th/cmp-nvim-lsp-signature-help",
      --         "petertriho/cmp-git",
      --         "hrsh7th/cmp-copilot",
      --         "lukas-reineke/cmp-rg",
      --         { "hrsh7th/vim-vsnip", requires = { "hrsh7th/vim-vsnip-integ" } },
      --       },
      --       config = function()
      --         -- See lspconfig comment on why this is in a function wrapper
      --         require("plugins.cmp").setup()
      --       end,
      --     }
      -- )

      -- use(
      --     {
      --       "hrsh7th/nvim-cmp",
      --       after = { "lspkind-nvim", "LuaSnip", "nvim-autopairs" },
      --       config = function()
      --         require("plugins-d/nvim-cmp")
      --       end,
      --     }
      -- )

      -- use(
      --     {
      --       "onsails/lspkind-nvim",
      --       event = "VimEnter",
      --       config = function()
      --         require("plugins-d/lspkind-nvim")
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
