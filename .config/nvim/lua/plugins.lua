-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-26 15:02
-- ==========================================================================
-- Lua utilities
-- require('lutils')
--
-- require('base')
-- require('options')
-- require('autocmds')
local utils = require("common/utils")
local autocmd = utils.autocmd
local map = utils.map

-- Install Packer if it isn't already
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if not vim.loop.fs_stat(install_path) then
  fn.system(
      "git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
end

cmd [[packadd packer.nvim]]
local packer = require("packer")
local use = packer.use

-- Recompile Packer when the file is saved
-- autocmd(
--     "source_packer",
--     { [[BufWritePost plugins.lua source <afile> | PackerSync]] }, true
-- )

packer.init(
    {
      -- compile_path = fn.stdpath("config") .. "/lua/compiled.lua",
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
      profile = { enable = false },
    }
)

return packer.startup(
    {
      config = {
        -- opt_default = true,
        display = {
          open_cmd = "tabedit",
          keybindings = { prompt_revert = "R", diff = "D" },
        },
      },
      function()
        -- Package manager
        use({ "wbthomason/packer.nvim", opt = true })

        -- ============================ Vim Library =========================== [[[
        use({ "tpope/vim-repeat" })
        -- ]]] === Vim Library ===

        -- ============================ Lua Library =========================== [[[
        use({ "nvim-lua/popup.nvim" })
        use({ "nvim-lua/plenary.nvim" })
        use({ "tami5/sqlite.lua" })

        use({ "kyazdani42/nvim-web-devicons" })
        -- ]]] === Lua Library ===

        -- =============================== Icons ============================== [[[
        use({ "ryanoasis/vim-devicons" })
        use(
            {
              "wfxr/vizunicode.vim",
              wants = "vim-devicons",
              setup = autocmd(
                  "vizunicode_custom",
                  "BufEnter coc-settings.json VizUnicodeAll", true
              ),
            }
        )
        -- ]]] === Icons ===

        -- ============================ EasyAlign ============================= [[[
        use(
            {
              "junegunn/vim-easy-align",
              config = function()
                local config = fn.stdpath("config")
                vim.cmd(
                    "source " .. config ..
                        "/vimscript/plugins/vim-easy-align.vim"
                )
              end,
            }
        )
        -- ]]] === EasyAlign ===

        -- ============================ Limelight ============================= [[[
        use(
            {
              "junegunn/goyo.vim",
              {
                "junegunn/limelight.vim",
                config = [[require("plugins-d/limelight")]],
              },
            }
        )
        -- ]]] === Limelight ===

        -- ============================= Vimtex =============================== [[[
        use({ "lervag/vimtex", config = [[require("plugins-d/vimtex")]] })
        -- ]]] === Vimtex ===

        -- use({ })
        -- use({ })

        -- =========================== Colorscheme ============================ [[[
        local colorscheme = "kimbox"
        use({ "lmburns/kimbox", config = [[require("plugins-d/kimbox")]] })
        -- ]]] === Colorscheme ===

        -- ============================= Lualine ============================== [[[
        use(
            {
              "nvim-lualine/lualine.nvim",
              after = colorscheme,
              requires = { "kyazdani42/nvim-web-devicons", opt = true },
              config = [[require("plugins-d/lualine")]],
            }
        )

        use(
            {
              "SmiteshP/nvim-gps",
              requires = { { "nvim-treesitter/nvim-treesitter", opt = true } },
              after = "nvim-treesitter",
              config = [[require("nvim-gps").setup()]],
            }
        )
        -- ]]] === Lualine ===

        -- =========================== Indentline ============================= [[[
        use(
            {
              "yggdroot/indentline",
              config = [[require("plugins-d/indentline")]],
            }
        )
        -- ]]] === Indentline ===

        -- ============================= Operator============================== [[[
        use({ "tpope/vim-surround" })
        use({ "tpope/vim-endwise" })

        use(
            {
              "gbprod/substitute.nvim",
              config = [[require("plugins-d/substitute")]],
            }
        )
        use(
            {
              "machakann/vim-sandwich",
              config = function()
                local config = fn.stdpath("config")
                vim.cmd(
                    "source " .. config ..
                        "/vimscript/plugins/vim-sandwhich.vim"
                )
              end,
            }
        )
        -- use(
        --     { "AndrewRadev/switch.vim",
        --       config = [[require("plugins-d/switch")]] }
        -- )
        -- ]]] === Operator ===

        -- =============================== Tags =============================== [[[
        use(
            {
              "ludovicchabant/vim-gutentags",
              config = function()
                local config = fn.stdpath("config")
                vim.cmd(
                    "source " .. config ..
                        "/vimscript/plugins/vim-gutentags.vim"
                )
              end,
            }
        )
        use({ "liuchengxu/vista.vim", config = [[require("plugins-d/vista")]] })
        -- ]]] === Tags ===

        -- ============================= UndoTree ============================= [[[
        use(
            {
              "mbbill/undotree",
              cmd = "UndoTreeToggle",
              config = [[require("plugins-d/undotree")]],
            }
        )
        -- ]]] === UndoTree ===

        -- ========================== NerdCommenter =========================== [[[
        use(
            {
              "preservim/nerdcommenter",
              config = [[require("plugins-d/nerdcommenter")]],
            }
        )
        -- ]]] === UndoTree ===

        -- =============================== Coc ================================ [[[
        -- use({ 'tjdevries/coc-zsh', ft = "zsh" })
        use({ "vim-perl/vim-perl", ft = "perl" })
        use({ "antoinemadec/coc-fzf" })

        use(
            {
              "neoclide/coc.nvim",
              branch = "master",
              run = "yarn install --frozen-lockfile",
            }
        ) -- ]]] === Coc ===

        -- ============================= Highlight ============================ [[[
        use(
            {
              "norcalli/nvim-colorizer.lua",
              ft = { "vim", "sh", "zsh", "markdown", "tmux", "yaml", "lua" },
              config = function() require("plugins-d/colorizer") end,
            }
        )
        use(
            {
              "Pocco81/HighStr.nvim",
              event = "VimEnter",
              config = function() require("plugins-d/HighStr") end,
            }
        )
        -- TODO: hi
        use(
            {
              "folke/todo-comments.nvim",
              config = function()
                require("plugins-d/todo-comments")
              end,
              wants = { "plenary.nvim" },
              opt = false,
            }
        )
        -- ]]] === Highlight ===

        -- ============================= Treesitter ============================ [[[
        use(
            {
              "nvim-treesitter/nvim-treesitter",
              run = ":TSUpdate",
              config = function() require("plugins-d/tree-sitter") end,
            }
        )

        use(
            {
              "nvim-treesitter/nvim-treesitter-refactor",
              after = "nvim-treesitter",
            }
        )
        use(
            {
              "nvim-treesitter/nvim-treesitter-textobjects",
              after = "nvim-treesitter",
            }
        )
        use(
            {
              "nvim-treesitter/playground",
              cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
            }
        )
        use({ "p00f/nvim-ts-rainbow", after = { "nvim-treesitter" } })
        use({ "nvim-treesitter/nvim-tree-docs", after = { "nvim-treesitter" } })

        -- use({ "theHamsta/nvim-treesitter-pairs", after = { "nvim-treesitter" } })
        -- ]]] === Treesitter ===

        -- ============================= Telescope ============================ [[[
        -- 'numToStr/Comment.nvim'
        -- 'folke/which-key.nvim'
        --
        use {
          "nvim-telescope/telescope.nvim",
          config = [[require('plugins-d/telescope')]],
          after = { "popup.nvim", "plenary.nvim", colorscheme },
          -- wants = { "popup.nvim", "plenary.nvim" },
        }

        use(
            {
              "nvim-telescope/telescope-github.nvim",
              after = "telescope.nvim",
              config = function()
                require("telescope").load_extension("gh")
              end,
            }
        )

        use(
            {
              "nvim-telescope/telescope-ghq.nvim",
              after = "telescope.nvim",
              config = function()
                require("telescope").load_extension("ghq")
              end,
            }
        )

        use(
            {
              "nvim-telescope/telescope-frecency.nvim",
              after = "telescope.nvim",
              requires = "tami5/sqlite.lua",
              config = function()
                require("telescope").load_extension("frecency")
              end,
            }
        )

        -- use(
        --     {
        --       "nvim-telescope/telescope-packer.nvim",
        --       after = "telescope.nvim",
        --       config = function()
        --         require("telescope").load_extension("packer")
        --       end,
        --     }
        -- )

        use(
            {
              "fannheyward/telescope-coc.nvim",
              after = "telescope.nvim",
              config = function()
                require("telescope").load_extension("coc")
              end,
            }
        )

        use(
            {
              "fhill2/telescope-ultisnips.nvim",
              after = "telescope.nvim",
              config = function()
                require("telescope").load_extension("ultisnips")
              end,
            }
        )

        use(
            {
              "nvim-telescope/telescope-fzf-native.nvim",
              after = "telescope.nvim",
              run = "make",
              config = function()
                require("telescope").load_extension("fzf")
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

        -- nvim-neoclip: Clipboard manager
        use(
            {
              "AckslD/nvim-neoclip.lua",
              requires = { "nvim-telescope/telescope.nvim", "tami5/sqlite.lua" },
              after = { "telescope.nvim", "sqlite.lua" },
              config = function() require("plugins-d/nvim-neoclip") end,
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

      end,
    }
)

-- require('mapping')
-- -- require('highlight')
-- require("functions")
--
-- vim.cmd("source ~/.config/nvim/vimscript/plug.vim")
