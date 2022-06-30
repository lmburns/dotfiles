-- ╭──────────────────────────────────────────────────────────╮
-- │                           LSP                            │
-- ╰──────────────────────────────────────────────────────────╯
-- "tami5/lspsaga.nvim",
-- 'folke/lsp-colors.nvim'
-- 'neovim/nvim-lspconfig'
-- 'nvim-lua/lsp-status.nvim'
-- 'onsails/lspkind-nvim'
-- 'ray-x/lsp_signature.nvim', module = 'lsp_signature'
-- "RRethy/vim-illuminate"     => Highlight word under cursor
-- "pechorin/any-jump.vim"     => Definition jumping
-- "j-hui/fidget.nvim"         => Standalone for LSP progress
-- "filipdutescu/renamer.nvim" => Like code action rename
-- "jubnzv/virtual-types.nvim" => Code lens
-- "b0o/SchemaStore.nvim",
-- "EthanJWright/toolwindow.nvim",
-- "kosayoda/nvim-lightbulb",
-- "ericpubu/lsp_codelens_extensions.nvim",
-- "jose-elias-alvarez/nvim-lsp-ts-utils"
-- "folke/lsp-trouble.nvim",
-- "tamago324/nlsp-settings.nvim"
-- "lukas-reineke/lsp-format.nvim"
-- "theHamsta/nvim-semantic-tokens"
-- "onsails/diaglist.nvim" => Show errors in quickfix
-- use({"github/copilot.vim", cmd = {"Copilot"}})
-- use(
--     {
--         "zbirenbaum/copilot.lua",
--         after = "copilot.vim",
--         config = function()
--             vim.schedule(
--                 function()
--                     require("copilot")
--                 end
--             )
--         end
--     }
-- )
-- === Languages ===
-- "simrat39/rust-tools.nvim"
-- "jose-elias-alvarez/typescript.nvim",
-- "ray-x/go.nvim"
-- use(
--     {
--         "williamboman/nvim-lsp-installer",
--         {
--             "neovim/nvim-lspconfig",
--             config = function()
--                 require("plugs.lsp.installer")
--                 require("plugs.lsp")
--             end,
--             wants = {"nvim-cmp", "lua-dev.nvim", "null-ls.nvim"},
--             requires = {"onsails/diaglist.nvim"}
--         },
--         after = {
--             "nvim-lspconfig",
--             "nvim-cmp",
--             "cmp-nvim-lsp",
--             "null-ls.nvim",
--             "lspsaga.nvim",
--             "symbols-outline.nvim"
--         }
--     }
-- )
--
-- use( { "jose-elias-alvarez/null-ls.nvim", requires = {"plenary.nvim"} })
--
-- use({"tami5/lspsaga.nvim"})
-- use({"b0o/SchemaStore.nvim", module = "schemastore"})
-- -- use({"RRethy/vim-illuminate", conf = "illuminate", desc = "Highlight other uses of same word"})
-- use({"ray-x/lsp_signature.nvim", after = "nvim-lspconfig"})
-- use(
--     {
--         "j-hui/fidget.nvim",
--         after = {"nvim-lspconfig"},
--         conf = "fidget",
--         desc = "Standalone UI for nvim-lsp progress"
--     }
-- )
-- use({"weilbith/nvim-code-action-menu", cmd = "CodeActionMenu", keys = {{"n", "<A-CR>"}}})
-- use({"kosayoda/nvim-lightbulb", conf = "lightbulb"})
-- -- use({"theHamsta/nvim-semantic-tokens", conf = "semantic_tokens"})
-- use({"zbirenbaum/neodim"})
--
-- -- ╭──────────────────────────────────────────────────────────╮
-- -- │                        Completion                        │
-- -- ╰──────────────────────────────────────────────────────────╯
-- -- use "tamago324/cmp-zsh"
-- -- use { 'andersevenrud/cmp-tmux', after = 'nvim-cmp' }
-- -- xuse { 'f3fora/cmp-spell', after = 'nvim-cmp' }
--
-- use(
--     {
--         "hrsh7th/nvim-cmp",
--         requires = {
--             {"hrsh7th/cmp-nvim-lsp", after = "nvim-cmp"},
--             {"hrsh7th/cmp-nvim-lua", after = "nvim-cmp"},
--             {"hrsh7th/cmp-buffer", after = "nvim-cmp"},
--             {"hrsh7th/cmp-path", after = "nvim-cmp"},
--             {"hrsh7th/cmp-cmdline", after = "nvim-cmp"},
--             {"hrsh7th/cmp-calc", after = "nvim-cmp"},
--             {"hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp"},
--             {"hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp"},
--             {"lukas-reineke/cmp-rg", after = "nvim-cmp"},
--             {"saadparwaiz1/cmp_luasnip", after = "nvim-cmp"},
--             {"ray-x/cmp-treesitter", after = "nvim-cmp"},
--             {"petertriho/cmp-git", after = "nvim-cmp"},
--             {"tzachar/cmp-tabnine", run = "./install.sh", after = "nvim-cmp"},
--             {"L3MON4D3/LuaSnip", requires = "rafamadriz/friendly-snippets"},
--             {"lukas-reineke/cmp-under-comparator", after = "nvim-lspconfig"}
--         },
--         after = {"nvim-treesitter", "lspkind-nvim"},
--         conf = "plugs.cmp"
--     }
-- )
--
-- use({"onsails/lspkind-nvim", module = "lspkind", desc = "Pictograms for completion"})
--
-- -- Rust
-- use(
--     {
--         "simrat39/rust-tools.nvim",
--         -- ft = "rust",
--         wants = {"nvim-lspconfig", "nvim-dap", "plenary.nvim"},
--         after = {"nvim-lspconfig", "nvim-dap", "plenary.nvim"}
--     }
-- )
--
-- -- Clangd
-- use(
--     {
--         "p00f/clangd_extensions.nvim",
--         wants = {"nvim-lspconfig", "nvim-dap"},
--         after = {"nvim-lspconfig"}
--     }
-- )
--
-- -- Typescript
-- use(
--     {
--         "jose-elias-alvarez/nvim-lsp-ts-utils",
--         wants = {"nvim-lspconfig"},
--         after = {"nvim-lspconfig"}
--     }
-- )
-- use({"vijaymarupudi/nvim-fzf"})
-- use({ "lotabout/skim", run = "./install --bin" })
-- use({"AndrewRadev/splitjoin.vim", keys = {{"n", "gJ"}, {"n", "gS"}}})
