-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-26 15:02
-- ==========================================================================
local utils = require("common/utils")
local autocmd = utils.autocmd
local map = utils.map
local create_augroup = utils.create_augroup

-- Install Packer if it isn't already
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if not vim.loop.fs_stat(install_path) then
  fn.system(
      "git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
end

cmd [[packadd packer.nvim]]
local packer = require("packer")

-- packer.on_compile_done = function()
--   local fp = assert(io.open(packer.config.compile_path, "rw+"))
--   local wbuf = {}
--   local key_state = 0
--   for line in fp:lines() do
--     if key_state == 0 then
--       table.insert(wbuf, line)
--       if line:find("Keymap lazy%-loads") then
--         key_state = 1
--         table.insert(wbuf, [[vim.defer_fn(function()]])
--       end
--     elseif key_state == 1 then
--       if line == "" then
--         key_state = 2
--         table.insert(wbuf, ("end, %d)"):format(15))
--       end
--       local _, e1 = line:find("vim%.cmd")
--       if line:find("vim%.cmd") then
--         local s2, e2 = line:find("%S+%s", e1 + 1)
--         local map_mode = line:sub(s2, e2)
--         line = ("pcall(vim.cmd, %s<unique>%s)"):format(
--             map_mode, line:sub(e2 + 1)
--         )
--       end
--       table.insert(wbuf, line)
--     else
--       table.insert(wbuf, line)
--     end
--   end
--
--   if key_state == 2 then
--     fp:seek("set")
--     fp:write(table.concat(wbuf, "\n"))
--   end
--
--   fp:close()
-- end

packer.init(
    {
      compile_path = fn.stdpath("config") .. "/plugin/packer_compiled.lua",
      auto_clean = true,
      compile_on_sync = true,
      display = {
        prompt_border = "rounded",
        open_cmd = "tabedit",
        keybindings = { prompt_revert = "R", diff = "D" },
        open_fn = function()
          return require("packer.util").float({ border = "rounded" })
        end,
      },
      git = { clone_timeout = 300 },
      profile = { enable = true },
    }
)

return packer.startup(
    {
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

        -- Cache startup
        use({ "lewis6991/impatient.nvim" })

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
        -- ]]] === Icons ===

        -- ============================== Debugging ============================ [[[
        use(
            {
              "mfussenegger/nvim-dap",
              setup = [[require('plugs.dap').setup()]],
              config = [[require('plugs.dap').config()]],
              after = "telescope.nvim",
              wants = "one-small-step-for-vimkind",
              requires = {
                { "jbyuki/one-small-step-for-vimkind" },
                {
                  "nvim-telescope/telescope-dap.nvim",
                  after = "nvim-dap",
                  config = [[require("telescope").load_extension("dap")]],
                },
                {
                  "rcarriga/nvim-dap-ui",
                  after = "nvim-dap",
                  config = function()
                    require("dapui").setup()
                  end,
                },
                {
                  "mfussenegger/nvim-dap-python",
                  after = "nvim-dap",
                  wants = "nvim-dap",
                  config = function()
                    require("dap-python").setup(
                        ("%s/shims/python"):format(
                            env.PYENV_ROOT
                        )
                    )
                  end,
                },
              },
            }
        )

        use({ "rafcamlet/nvim-luapad", cmd = "Luapad", ft = "lua" })

        -- use(
        --     {
        --       "puremourning/vimspector",
        --       setup = [[vim.g.vimspector_enable_mappings = 'HUMAN']],
        --       disable = true,
        --     }
        -- )

        use({ "tjdevries/nlua.nvim" })
        -- use({ "bfredl/nvim-luadev", config = conf("luadev"), ft = "lua" })
        -- ]]] === Debugging ===

        -- ============================ File Manager =========================== [[[
        use(
            {
              "kevinhwang91/rnvimr",
              opt = false,
              config = [[require("plugs.rnvimr")]],
            }
        )

        use({ "ptzz/lf.vim", config = conf("lf") })
        -- use({ "haorenW1025/floatLf-nvim" })

        -- ]]] === File Manager ===

        -- ============================ Neo/Floaterm =========================== [[[
        use(
            {
              "voldikss/fzf-floaterm",
              requires = { "voldikss/vim-floaterm" },
              config = conf("floaterm"),
            }
        )

        use(
            {
              "akinsho/toggleterm.nvim",
              config = conf("plugs.neoterm"),
              keys = { "gxx", "gx", "<C-\\>" },
              cmd = { "T" },
            }
        )
        -- use({ "kassio/neoterm", config = conf("neoterm") })
        -- ]]] === Floaterm ===

        -- =========================== BetterQuickFix ========================== [[[
        use({ "kevinhwang91/nvim-bqf", ft = { "qf" }, config = conf("bqf") })
        -- ]]] === BetterQuickFix ===

        -- ============================ EasyAlign ============================= [[[
        use({ "junegunn/vim-easy-align", config = conf("plugs.easy-align") })
        -- ]]] === EasyAlign ===

        -- ============================ Open Browser =========================== [[[
        -- FIX: Binding isn't working but function is
        use({ "tyru/open-browser.vim", conf = conf("open_browser") })
        -- ]]] === Open Browser ===

        -- ============================ Limelight ============================= [[[
        use(
            {
              "folke/zen-mode.nvim",
              cmd = "ZenMode",
              {
                "folke/twilight.nvim",
                config = conf("plugs.twilight"),
                after = "zen-mode.nvim",
              },
            }
        )
        -- ]]] === Limelight ===

        -- ============================= Vimtex =============================== [[[
        use({ "lervag/vimtex", config = conf("plugs.vimtex") })
        -- ]]] === Vimtex ===

        use(
            {
              "kevinhwang91/suda.vim",
              keys = { { "n", "<Leader>W" } },
              cmd = { "SudaRead", "SudaWrite" },
              config = conf("suda"),
            }
        )

        -- ============================== VCooler ============================== [[[
        use(
            {
              "KabbAmine/vCoolor.vim",
              keys = {
                { "n", "<Leader>pc" },
                { "n", "<Leader>yb" },
                { "n", "<Leader>yr" },
              },
              setup = [[vim.g.vcoolor_disable_mappings = 1 vim.g.vcoolor_lowercase = 1]],
              config = conf("vcoolor"),
            }
        )
        -- ]]] === VCooler ===

        -- =============================== Marks ============================== [[[
        use({ "chentau/marks.nvim", config = conf("plugs.marks") })
        -- ]]] === Marks ===

        -- ============================== WhichKey ============================ [[[
        use({ "folke/which-key.nvim", config = conf("plugs.which-key") })
        -- ]]] === WhichKey ===

        -- ============================== HlsLens ============================= [[[
        use {
          "kevinhwang91/nvim-hlslens",
          config = conf("hlslens"),
          requires = "haya14busa/vim-asterisk",
        }
        -- ]]] === HlsLens ===

        -- =========================== Colorscheme ============================ [[[
        local colorscheme = "kimbox"

        use({ "sainnhe/gruvbox-material" })
        use({ "sainnhe/edge" })
        use({ "sainnhe/everforest" })
        use({ "sainnhe/sonokai" })
        use({ "glepnir/oceanic-material" })
        use({ "marko-cerovac/material.nvim" })
        use({ "franbach/miramare" })
        use({ "pineapplegiant/spaceduck" })
        use({ "ghifarit53/daycula-vim" })
        use({ "ghifarit53/tokyonight-vim" })
        use({ "nanotech/jellybeans.vim" })
        use({ "savq/melange" })
        -- use({ "kaicataldo/material.vim" })

        use({ "lmburns/kimbox", config = conf("plugs.kimbox") })
        -- ]]] === Colorscheme ===

        -- ============================ Scrollbar ============================= [[[
        use(
            {
              "petertriho/nvim-scrollbar",
              requires = { "kevinhwang91/nvim-hlslens" },
              after = { colorscheme, "nvim-hlslens" },
              config = conf("plugs.scrollbar"),
            }
        )
        -- ]]] === Scrollbar ===

        -- ============================ Trouble =============================== [[[
        -- use(
        --     {
        --       "folke/trouble.nvim",
        --       requires = { "kyazdani42/nvim-web-devicons", opt = true },
        --       config = conf("plugs.trouble"),
        --     }
        -- )
        -- ]]] === Trouble ===

        -- =========================== Statusline ============================= [[[
        use(
            {
              "nvim-lualine/lualine.nvim",
              after = colorscheme,
              requires = { "kyazdani42/nvim-web-devicons", opt = true },
              config = conf("plugs.lualine"),
            }
        )

        use(
            {
              "SmiteshP/nvim-gps",
              requires = { "nvim-treesitter/nvim-treesitter" },
              after = "nvim-treesitter",
              config = [[require("nvim-gps").setup()]],
            }
        )

        use(
            {
              "akinsho/bufferline.nvim",
              after = { colorscheme, "lualine.nvim" },
              config = conf("plugs.bufferline"),
            }
        )
        -- ]]] === Lualine ===

        -- =========================== Indentline ============================= [[[
        use({ "yggdroot/indentline", config = conf("plugs.indentline") })
        -- ]]] === Indentline ===

        -- =============================== Fzf ================================ [[[
        use(
            {
              "junegunn/fzf.vim",
              requires = { { "junegunn/fzf", run = "./install --bin" } },
              config = conf("plugs.fzf"),
            }
        )

        use(
            {
              "ibhagwan/fzf-lua",
              requires = { "kyazdani42/nvim-web-devicons" },
              config = conf("plugs.fzf-lua"),
            }
        )

        -- use({ "lotabout/skim", run = "./install --bin" })
        -- ]]] === Fzf ===

        -- ====================== Window Picker ======================= [[[
        use(
            {
              "https://gitlab.com/yorickpeterse/nvim-window",
              config = conf("window_picker"),
              keys = { { "n", "<Leader>wp" } },
            }
        )
        -- ]]] === Window Picker ===

        -- ============================= Operator ============================== [[[
        use(
            {
              "phaazon/hop.nvim",
              config = conf("hop"),
              keys = {
                { "n", "f" },
                { "x", "f" },
                { "o", "f" },

                { "n", "F" },
                { "x", "F" },
                { "o", "F" },

                { "n", "t" },
                { "x", "t" },
                { "o", "t" },

                { "n", "T" },
                { "x", "T" },
                { "o", "T" },

                { "n", "<Leader><Leader>h" },
                { "n", "<Leader><Leader>j" },
                { "n", "<Leader><Leader>k" },
                { "n", "<Leader><Leader>l" },
                { "n", "<Leader><Leader>J" },
                { "n", "<Leader><Leader>K" },
                { "n", "<Leader><Leader>/" },
              },
            }
        )

        use(
            {
              "gbprod/substitute.nvim",
              config = conf("plugs.substitute"),
              keys = {
                { "n", "s" },
                { "n", "ss" },
                { "n", "se" },
                { "x", "s" },

                { "n", "sx" },
                { "n", "sxx" },
                { "n", "sxc" },
                { "x", "X" },
              },
            }
        )

        -- Similar to vim-sandwhich (I kind of use both)
        use(
            {
              "tpope/vim-surround",
              setup = [[vim.g.surround_no_mappings = 1]],
              keys = {
                { "n", "ds" },
                { "n", "cs" },
                { "n", "cS" },
                { "n", "ys" },
                { "n", "yS" },
                { "n", "yss" },
                { "n", "ygs" },
                { "x", "S" },
                { "x", "gS" },
              },
              config = conf("surround"),
            }
        )

        use(
            {
              "machakann/vim-sandwich",
              config = conf("sandwhich"),
              -- keys = {
              --   { "n", "sd" },
              --   { "n", "sr" },
              --   { "n", "sa" },
              --   { "v", "sa" },
              --   { "o", "is" },
              --   { "o", "as" },
              --   { "o", "ib" },
              --   { "o", "ab" },
              -- },
            }
        )

        use({ "pseewald/vim-anyfold", cmd = "AnyFoldActivate" })

        use(
            {
              "windwp/nvim-autopairs",
              config = conf("plugs.autopairs"),
              event = "InsertEnter",
            }
        )

        -- use(
        --     {
        --       "Raimondi/delimitMate",
        --       event = "InsertEnter",
        --       config = conf("delimitmate"),
        --     }
        -- )

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
        use(
            {
              "liuchengxu/vista.vim",
              after = { "vim-gutentags" },
              config = conf("plugs.vista"),
            }
        )
        -- ]]] === Tags ===

        -- ============================= Startify ============================= [[[
        use { "mhinz/vim-startify", config = conf("plugs.startify") }
        -- ]]] === Startify ===

        -- ============================= UndoTree ============================= [[[
        use(
            {
              "mbbill/undotree",
              cmd = "UndoTreeToggle",
              config = conf("plugs.undotree"),
            }
        )
        -- ]]] === UndoTree ===

        -- ========================== NerdCommenter =========================== [[[
        -- use({ "preservim/nerdcommenter", config = conf("plugs.nerdcommenter") })
        use({ "numToStr/Comment.nvim", config = conf("plugs.comment") })
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
        use({ "jpalardy/vim-slime", ft = "python", config = conf("slime") })
        -- ]]] === VimSlime - Python ===

        -- ============================= Vim - Rust ============================ [[[
        use({ "rust-lang/rust.vim", ft = "rust", config = conf("plugs.rust") })

        -- use(
        --     {
        --       "simrat39/rust-tools.nvim",
        --       ft = "rust",
        --       config = function()
        --         require("rust-tools").setup {}
        --       end,
        --       requires = { "plenary.nvim", "nvim-lspconfig" },
        --     }
        -- )
        -- ]]] === VimSlime - Python ===

        -- ============================== Vim - Go ============================= [[[
        use({ "fatih/vim-go", ft = "go", config = conf("plugs.go") })
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
              after = "fzf.vim",
              config = conf("plugs.mkdx"),
            }
        )

        use({ "vimwiki/vimwiki", config = conf("vimwiki"), after = colorscheme })

        use({ "FraserLee/ScratchPad", config = conf("scratchpad") })
        -- ]]] === Markdown ===

        -- ================================ Wilder ============================= [[[
        use(
            {
              "gelguy/wilder.nvim",
              run = ":UpdateRemotePlugins",
              rocks = "pcre2",
              config = conf("plugs.wilder"),
            }
        ) -- ]]] === Wilder ===

        -- ========================= Syntax-Highlighting ======================= [[[
        g.polyglot_disabled = {
          "markdown",
          "rustpeg",
          "lf",
          "ron",
          "cmake",
          "css",
          "d",
          "dart",
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
          -- "tsx",
          -- "vue",
          "zig",
          "sensible",
          -- "ftdetect",
          -- "typescript",
        }
        -- TODO: Change back when merged
        use({ "nyuszika7h/vim-polyglot" })

        -- use({ "wfxr/dockerfile.vim" })

        use({ "rhysd/vim-rustpeg", ft = "rustpeg" })

        use({ "nastevens/vim-cargo-make" })

        use({ "NoahTheDuke/vim-just", ft = "just" })

        use({ "camnw/lf-vim", ft = "lf" })

        use({ "ron-rs/ron.vim", ft = "ron" })
        -- ]]] === Syntax-Highlighting ===

        -- =========================== Keymaps - Nest ========================== [[[
        -- use({ "LionC/nest.nvim", config = conf("plugs.keymaps") })
        -- ]]] === Keymaps ===

        -- ============================= File-Viewer =========================== [[[
        use({ "mattn/vim-xxdcursor" })
        use(
            {
              "fidian/hexmode",
              config = [[vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe']],
            }
        )

        use({ "jamessan/vim-gnupg" })

        use({ "AndrewRadev/id3.vim" })

        use({ "alx741/vinfo" })

        use({ "HiPhish/info.vim", config = conf("info") })
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
              config = conf("plugs.colorizer"),
            }
        )
        use(
            {
              "Pocco81/HighStr.nvim",
              event = "VimEnter",
              config = conf("plugs.HighStr"),
            }
        )
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

        use(
            {
              "neoclide/coc.nvim",
              branch = "master",
              run = "yarn install --frozen-lockfile",
              config = [[require('plugs.coc').tag_cmd()]],
            }
        )
        use({ "antoinemadec/coc-fzf", after = "coc.nvim" })

        use { "kevinhwang91/coc-kvs", run = "yarn install --frozen-lockfile" }
        -- ]]] === Coc ===

        -- ============================= Treesitter ============================ [[[
        use {
          "danymat/neogen",
          config = conf("neogen"),
          keys = {
            { "n", "<Leader>dg" },
            { "n", "<Leader>df" },
            { "n", "<Leader>dc" },
          },
          requires = "nvim-treesitter/nvim-treesitter",
        }
        use(
            {
              "nvim-treesitter/nvim-treesitter",
              run = ":TSUpdate",
              -- config = conf("plugs.tree-sitter"),
            }
        )

        use(
            {
              "nvim-treesitter/nvim-treesitter-refactor",
              after = "nvim-treesitter",
            }
        )
        -- Adds 'end' to ruby and lua
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
              after = "nvim-treesitter",
              -- cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
            }
        )
        use({ "nvim-treesitter/nvim-tree-docs", after = { "nvim-treesitter" } })
        use({ "nanotee/luv-vimdocs", opt = false })

        use(
            { "mizlan/iswap.nvim", requires = "nvim-treesitter/nvim-treesitter" }
        )

        -- use({ "p00f/nvim-ts-rainbow", after = { "nvim-treesitter" } })
        -- use({ "theHamsta/nvim-treesitter-pairs", after = { "nvim-treesitter" } })
        -- ]]] === Treesitter ===

        -- ============================= Html/Css ============================= [[[
        use { "alvan/vim-closetag" }

        -- use(
        --     {
        --       "windwp/nvim-ts-autotag",
        --       requires = { { "nvim-treesitter/nvim-treesitter", opt = true } },
        --       after = { "nvim-treesitter" },
        --       config = conf("plugs.autotag")
        --     }
        -- )
        -- ]]] === Html ===

        -- ============================= Telescope ============================ [[[
        -- 'folke/which-key.nvim'
        --
        use(
            {
              "nvim-telescope/telescope.nvim",
              opt = false,
              config = conf("plugs.telescope"),
              after = { "popup.nvim", "plenary.nvim", colorscheme },
              requires = {
                {
                  "nvim-telescope/telescope-ghq.nvim",
                  after = "telescope.nvim",
                  config = function()
                    require("telescope").load_extension("ghq")
                    cmd [[com! -nargs=0 Ghq :Telescope ghq list]]
                  end,
                },
                {
                  "nvim-telescope/telescope-github.nvim",
                  after = "telescope.nvim",
                  config = [[require("telescope").load_extension("gh")]],
                },
                {
                  "nvim-telescope/telescope-frecency.nvim",
                  after = "telescope.nvim",
                  requires = "tami5/sqlite.lua",
                  config = [[require("telescope").load_extension("frecency")]],
                },
                {
                  "fannheyward/telescope-coc.nvim",
                  after = "telescope.nvim",
                  config = [[require("telescope").load_extension("coc")]],
                },
                {
                  "fhill2/telescope-ultisnips.nvim",
                  after = "telescope.nvim",
                  config = [[require("telescope").load_extension("ultisnips")]],
                },
                {
                  "nvim-telescope/telescope-fzf-native.nvim",
                  after = "telescope.nvim",
                  run = "make",
                  config = [[require("telescope").load_extension("fzf")]],
                },
                {
                  "dhruvmanila/telescope-bookmarks.nvim",
                  after = "telescope.nvim",
                  config = [[require("telescope").load_extension("bookmarks")]],
                },
                {
                  "nvim-telescope/telescope-file-browser.nvim",
                  after = { "telescope.nvim" },
                  config = [[require("telescope").load_extension("file_browser")]],
                },
                {
                  "nvim-telescope/telescope-ui-select.nvim",
                  after = { "telescope.nvim" },
                  config = [[require("telescope").load_extension("ui-select")]],
                },
                {
                  "nvim-telescope/telescope-hop.nvim",
                  after = { "telescope.nvim" },
                  config = [[require("telescope").load_extension("hop")]],
                },
                {
                  -- TODO: Use or remove; Does this do anything?
                  "nvim-telescope/telescope-smart-history.nvim",
                  requires = { "tami5/sqlite.lua" },
                  after = { "telescope.nvim", "sqlite.lua" },
                  config = [[require("telescope").load_extension("smart_history")]],
                  run = function()
                    os.execute("mkdir -p" .. fn.stdpath("data") .. "/databases/")
                  end,
                },
              },
            }
        )

        -- FIX: Doesn't work all the time and is hard to configure
        use(
            {
              "nvim-telescope/telescope-packer.nvim",
              after = { "telescope.nvim" },
              requires = {
                "nvim-telescope/telescope.nvim",
                "wbthomason/packer.nvim",
              },
              wants = { "telescope.nvim", "packer.nvim" },
              -- config = [[require("telescope").load_extension("packer")]],
              config = function()
                require("telescope.builtin").packer = function(opts)
                  require("telescope").extensions.packer.packer(opts)
                end
              end,
            }
        )

        -- nvim-neoclip: Clipboard manager
        use(
            {
              "AckslD/nvim-neoclip.lua",
              requires = { "nvim-telescope/telescope.nvim", "tami5/sqlite.lua" },
              after = { "telescope.nvim", "sqlite.lua" },
              config = [[require("plugs.nvim-neoclip")]],
            }
        )

        -- ]]] === Telescope ===

        -- ================================ Git =============================== [[[
        use(
            {
              "tpope/vim-fugitive",
              fn = "fugitive#*",
              cmd = {
                "Git",
                "Gedit",
                "Gread",
                "Gwrite",
                "Gdiffsplit",
                "Gvdiffsplit",
              },
              event = "BufReadPre */.git/index",
              config = conf("plugs.fugitive"),
            }
        )

        use({ "tpope/vim-rhubarb" })

        use({ "kdheepak/lazygit.nvim", config = conf("lazygit") })

        use(
            {
              "lewis6991/gitsigns.nvim",
              config = conf("plugs.gitsigns"),
              requires = { "nvim-lua/plenary.nvim" },
            }
        )

        use(
            {
              "TimUntersberger/neogit",
              config = conf("plugs.neogit"),
              requires = { "nvim-lua/plenary.nvim" },
            }
        )

        use(
            {
              "sindrets/diffview.nvim",
              cmd = { "DiffviewOpen", "DiffviewFileHistory" },
              config = conf("plugs.diffview"),
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

        -- use { "farmergreg/vim-lastplace" }

        use({ "rcarriga/nvim-notify", config = conf("notify") })

      end,
    }
)

-- ============================== Disabled ============================= [[[
-- ==> zen-mode; twilight
-- use(
--     {
--       "junegunn/goyo.vim",
--       {
--         "junegunn/limelight.vim",
--         config = conf("plugs.limelight"),
--       },
--     }
-- )

-- ==> hop
-- use(
--     {
--       "justinmk/vim-sneak",
--       after = "vim-surround",
--       keys = { { "n", "f" }, { "n", "F" } },
--       config = conf("sneak"),
--     }
-- )

-- ]]] === Disabled ===
