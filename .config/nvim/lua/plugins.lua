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

cmd([[packadd packer.nvim]])
local packer = require("packer")
-- local use = packer.use

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
      function(use)
        local function conf(name)
          if name:match("^plugs%.") then
            return ([[require('%s')]]):format(name)
          else
            return ([[require('plugs.config').%s()]]):format(name)
          end
        end

        -- Package manager
        use({ "wbthomason/packer.nvim", opt = true })

        -- ============================ Vim Library =========================== [[[
        use({ "tpope/vim-repeat" })

        -- Prevent clipboard from being hijacked by snippets and such
        -- use({ "kevinhwang91/nvim-hclipboard" })
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
              config = autocmd(
                  "vizunicode_custom",
                  "BufEnter coc-settings.json VizUnicodeAll", true
              ),
            }
        )
        -- ]]] === Icons ===

        -- ============================ File Manager =========================== [[[
        use(
            {
              "kevinhwang91/rnvimr",
              opt = false,
              config = [[require("plugs.rnvimr")]],
            }
        )

        use({ "ptzz/lf.vim", config = conf("lf") })
        -- ]]] === File Manager ===

        -- ============================ Neo/Floaterm =========================== [[[
        use(
            {
              "voldikss/fzf-floaterm",
              requires = { "voldikss/vim-floaterm" },
              config = conf("floaterm"),
            }
        )

        use({ "kassio/neoterm", config = conf("neoterm") })
        -- ]]] === Floaterm ===

        -- =========================== BetterQuickFix ========================== [[[
        use(
            {
              "kevinhwang91/nvim-bqf",
              ft = "qf",
              config = [[require("plugs.bqf")]],
            }
        )
        -- ]]] === BetterQuickFix ===

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
                config = [[require("plugs.limelight")]],
              },
            }
        )
        -- ]]] === Limelight ===

        -- ============================= Vimtex =============================== [[[
        use({ "lervag/vimtex", config = conf("plugs.vimtex") })
        -- ]]] === Vimtex ===

        -- ============================ Open Browser =========================== [[[
        use({ "tyru/open-browser.vim", conf = conf("open_browser") })
        -- ]]] === Open Browser ===

        -- =========================== Colorscheme ============================ [[[
        local colorscheme = "kimbox"
        use({ "lmburns/kimbox", config = [[require("plugs.kimbox")]] })
        -- ]]] === Colorscheme ===

        -- ============================= Lualine ============================== [[[
        use(
            {
              "nvim-lualine/lualine.nvim",
              after = colorscheme,
              requires = { "kyazdani42/nvim-web-devicons", opt = true },
              config = [[require("plugs.lualine")]],
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
        use({ "yggdroot/indentline", config = [[require("plugs.indentline")]] })
        -- ]]] === Indentline ===

        -- =============================== Fzf ================================ [[[
        use(
            {
              "junegunn/fzf.vim",
              requires = { { "junegunn/fzf", run = "./install --bin" } },
              config = conf("plugs.fzf")
            }
        )

        -- use({ "lotabout/skim", run = "./install --bin" })
        -- ]]] === Fzf ===

        -- ============================= Operator============================== [[[
        -- Similar to vim-sandwhich (I kind of use both)
        use({ "tpope/vim-surround" })
        use(
            { "gbprod/substitute.nvim",
              config = [[require("plugs.substitute")]] }
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

        use(
            {
              "Raimondi/delimitMate",
              event = "InsertEnter",
              config = conf("delimitmate"),
            }
        )
        -- use(
        --     { "AndrewRadev/switch.vim",
        --       config = [[require("plugs.switch")]] }
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
        use({ "liuchengxu/vista.vim", config = [[require("plugs.vista")]] })
        -- ]]] === Tags ===

        -- ============================= Startify ============================= [[[
        use { "mhinz/vim-startify", config = conf("plugs.startify") }
        -- ]]] === Startify ===

        -- ============================= UndoTree ============================= [[[
        use(
            {
              "mbbill/undotree",
              cmd = "UndoTreeToggle",
              config = [[require("plugs.undotree")]],
            }
        )
        -- ]]] === UndoTree ===

        -- ========================== NerdCommenter =========================== [[[
        use(
            {
              "preservim/nerdcommenter",
              config = [[require("plugs.nerdcommenter")]],
            }
        )
        -- ]]] === UndoTree ===

        -- ============================== Targets ============================== [[[
        use({ "wellle/targets.vim", config = conf("targets") })
        -- ]]] === Neoformat ===

        -- ============================== Nvim-R =============================== [[[
        use(
            {
              "jalvesaq/Nvim-R",
              branch = "stable",
              config = conf("plugs.nvim-r"),
            }
        )
        -- ]]] === Nvim-R ===

        -- ========================= VimSlime - Python ========================= [[[
        -- use(
        --     {
        --       "jpalardy/vim-slime",
        --       ft = "python",
        --       config = conf("plugs.vim-slime"),
        --     }
        -- )
        -- ]]] === VimSlime - Python ===

        -- ============================= Vim - Rust ============================ [[[
        use({ "rust-lang/rust.vim", ft = "rust", config = conf("plugs.rust") })

        use({ "nastevens/vim-cargo-make" })
        -- ]]] === VimSlime - Python ===

        -- ============================== Vim - Go ============================= [[[
        use({ "fatih/vim-go", ft = "go", config = conf("plugs.vim-go") })
        -- ]]] === VimSlime - Python ===

        -- ============================== Markdown ============================= [[[
        use(
            {
              "vim-pandoc/vim-pandoc-syntax",
              ft = { "pandoc", "markdown", "vimwiki" },
              config = conf("pandoc"),
            }
        )

        use(
            {
              "plasticboy/vim-markdown",
              ft = { "markdown", "vimwiki" },
              config = conf("markdown"),
            }
        )

        use(
            {
              "dhruvasagar/vim-table-mode",
              ft = { "markdown", "vimwiki" },
              config = conf("table_mode"),
            }
        )

        use(
            {
              "SidOfc/mkdx",
              ft = { "markdown", "vimwiki" },
              config = conf("mkdx"),
            }
        )

        use({ "vimwiki/vimwiki", config = conf("vimwiki") })

        cmd [[
          augroup markdown
            autocmd!
            autocmd FileType markdown,vimwiki
              \ setl iskeyword+=-|
              \ vnoremap ``` <esc>`<O<esc>S```<esc>`>o<esc>S```<esc>k$|
              \ nnoremap <buffer> <F4> !pandoc % --pdf-engine=xelatex -o %:r.pdf|
              \ inoremap ** ****<Left><Left>|
              \ inoremap <expr> <right> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"|
              \ vnoremap <Leader>si :s/`/*/g<CR>
          augroup END
        ]]
        -- ]]] === VimSlime - Python ===

        -- ========================= Syntax-Highlighting ======================= [[[
        use(
            {
              "sheerun/vim-polyglot",
              setup = function()
                g.polyglot_disabled = {
                  "markdown",
                  "python",
                  "rust",
                  "java",
                  "lua",
                  "ruby",
                  "zig",
                  "d",
                  "dockerfile",
                  "rustpeg",
                  "lf",
                  "ron",
                }
              end,
            }
        )

        use({ "wfxr/dockerfile.vim" })

        use({ "rhysd/vim-rustpeg" })

        use({ "NoahTheDuke/vim-just" })

        use({ "camnw/lf-vim" })

        use({ "ron-rs/ron.vim" })
        -- ]]] === Syntax-Highlighting ===

        -- ============================= File-Viewer =========================== [[[
        use { "mattn/vim-xxdcursor" }
        use {
          "fidian/hexmode",
          config = [[vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe']],
        }

        use { "jamessan/vim-gnupg" }

        use { "AndrewRadev/id3.vim" }

        use { "alx741/vinfo" }

        use { "HiPhish/info.vim", config = conf("info") }
        -- ]]] === File Viewer ===

        -- ============================== Snippets ============================= [[[
        use({ "SirVer/ultisnips", config = conf("ultisnips") })
        use({ "honza/vim-snippets" })
        -- ]]] === Snippets ===

        -- ============================== Minimap ============================== [[[
        use { "wfxr/minimap.vim", config = conf("minimap") }
        -- ]]] === Minimap ===

        -- ============================= Highlight ============================ [[[
        use(
            {
              "norcalli/nvim-colorizer.lua",
              ft = { "vim", "sh", "zsh", "markdown", "tmux", "yaml", "lua" },
              config = function() require("plugs.colorizer") end,
            }
        )
        use(
            {
              "Pocco81/HighStr.nvim",
              event = "VimEnter",
              config = function() require("plugs.HighStr") end,
            }
        )
        -- TODO: hi
        use(
            {
              "folke/todo-comments.nvim",
              config = conf("plugs.todo-comments"),
              wants = { "plenary.nvim" },
              opt = false,
            }
        )
        -- ]]] === Highlight ===

        -- ============================= Neoformat ============================= [[[
        use({ "sbdchd/neoformat", config = conf("plugs.neoformat") })
        -- ]]] === Neoformat ===

        -- =============================== Coc ================================ [[[
        -- use({ 'tjdevries/coc-zsh', ft = "zsh" })
        use({ "vim-perl/vim-perl", ft = "perl" })
        use({ "antoinemadec/coc-fzf" })

        use(
            {
              "neoclide/coc.nvim",
              branch = "master",
              run = "yarn install --frozen-lockfile",
              config = [[require('plugs.coc').init()]],
            }
        ) -- ]]] === Coc ===

        -- ============================= Treesitter ============================ [[[
        use(
            {
              "nvim-treesitter/nvim-treesitter",
              run = ":TSUpdate",
              config = conf("plugs.tree-sitter"),
            }
        )

        use(
            {
              "nvim-treesitter/nvim-treesitter-refactor",
              after = "nvim-treesitter",
            }
        )
        use({ "RRethy/nvim-treesitter-endwise", after = "nvim-treesitter" })
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
        use(
            {
              "nvim-telescope/telescope.nvim",
              config = [[require('plugs.telescope')]],
              after = { "popup.nvim", "plenary.nvim", colorscheme },
              -- wants = { "popup.nvim", "plenary.nvim" },
            }
        )

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
              config = function() require("plugs.nvim-neoclip") end,
            }
        )

        -- ]]] === Telescope ===

        -- ================================ Git =============================== [[[
        use { "tpope/vim-fugitive", config = conf("fugitive") }

        use(
            {
              "kdheepak/lazygit.nvim",
              config = map("n", "<Leader>lg", ":LazyGit<CR>", { silent = true }),
            }
        )

        use(
            {
              "lewis6991/gitsigns.nvim",
              event = "VimEnter",
              config = function()
                require("plugs.gitsigns").config()
              end,
              wants = { "plenary.nvim" },
            }
        )

        use(
            {
              "TimUntersberger/neogit",
              event = "VimEnter",
              module = "neogit",
              config = function() require("plugs.neogit").config() end,
            }
        )

        use(
            {
              "sindrets/diffview.nvim",
              event = "VimEnter",
              cmd = { "DiffviewOpen", "DiffviewFileHistory" },
              config = function()
                require("plugs.diffview").config()
              end,
            }
        )
        -- ]]] === Git ===

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
        -- ]]] === Completion ===
      end,
    }
)
