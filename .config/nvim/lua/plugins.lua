-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-26 15:02
-- ==========================================================================
local utils = require("common/utils")
local command = utils.command
local autocmd = utils.autocmd
local map = utils.map
local create_augroup = utils.create_augroup

-- Install Packer if it isn't already
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if not uv.fs_stat(install_path) then
    fn.system("git clone https://github.com/wbthomason/packer.nvim " .. install_path)
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
        snapshot_path = fn.stdpath("cache") .. "/packer.nvim",
        auto_clean = true,
        compile_on_sync = true,
        display = {
            prompt_border = "rounded",
            open_cmd = "tabedit",
            keybindings = {prompt_revert = "R", diff = "D"},
            open_fn = function()
                return require("packer.util").float({border = "rounded"})
            end
        },
        -- log = {level = "debug"},
        profile = {enable = true}
    }
)

packer.set_handler(
    "conf",
    function(plugins, plugin, value)
        local config
        if value:match("^plugs%.") then
            config = ([[require('%s')]]):format(value)
        else
            config = ([[require('plugs.config').%s()]]):format(value)
        end

        plugin.config = config
    end
)

local function prefer_local(url, path)
    if not path then
        local name = url:match("[^/]*$")
        path = "~/projects/nvim/" .. name
    end
    return uv.fs_stat(fn.expand(path)) ~= nil and path or url
end

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
            use({"wbthomason/packer.nvim", opt = true})

            -- Cache startup
            use({"lewis6991/impatient.nvim", rocks = "mpack"})

            -- Faster version of filetype.vim
            use({"nathom/filetype.nvim", conf = "plugs.filetype"})

            -- Have more than one configuration
            -- use({"NTBBloodbath/cheovim", config = [[require("cheovim").setup({})]]})

            -- ============================ Vim Library =========================== [[[
            use({"tpope/vim-repeat"})
            use({"ryanoasis/vim-devicons"})
            -- ]]] === Vim Library ===

            -- ============================ Lua Library =========================== [[[
            use({"nvim-lua/popup.nvim"})
            use({"nvim-lua/plenary.nvim"})
            -- Allows ex commands as functions
            -- vim.api.nvim_<func> => nvim.<func>
            use({"norcalli/nvim.lua"})
            use({"arsham/arshlib.nvim", requires = {"nvim-lua/plenary.nvim"}})
            use({"tami5/sqlite.lua"})
            use({"kyazdani42/nvim-web-devicons"})

            use(
                {
                    "stevearc/dressing.nvim",
                    event = "BufWinEnter",
                    conf = "plugs.dressing"
                }
            )
            -- ]]] === Lua Library ===

            -- ========================== Fixes / Addons ========================== [[[
            use({"antoinemadec/FixCursorHold.nvim", opt = false})
            use({"max397574/better-escape.nvim", config = conf("better_esc")})
            -- numToStr/Navigator.nvim
            use({"mrjones2014/smart-splits.nvim", conf = "smartsplits"})
            use({"fedepujol/move.nvim", config = conf("move")})
            -- Prevent clipboard from being hijacked by snippets and such
            use({"kevinhwang91/nvim-hclipboard"})
            use({"gbprod/yanky.nvim"})
            use({"tversteeg/registers.nvim", conf = "registers"})
            use({"AndrewRadev/bufferize.vim", cmd = "Bufferize"}) -- replace builtin pager

            -- use(
            --     {
            --         "mg979/vim-visual-multi",
            --         setup = [[vim.g.VM_leader = '<Space>']],
            --         keys = {
            --             {"n", "<C-n>"},
            --             {"x", "<C-n>"},
            --             {"n", [[<Leader>\]]},
            --             {"n", "<Leader>A"},
            --             {"x", "<Leader>A"},
            --             {"n", "<M-S-i>"},
            --             {"n", "<M-S-o>"},
            --             {"n", "g/"}
            --         },
            --         cmd = {"VMSearch"},
            --         config = conf("visualmulti"),
            --         wants = {"nvim-hlslens", "nvim-autopairs"}
            --     }
            -- )
            -- ]]] === Fixes ===

            -- ============================== WhichKey ============================ [[[
            use({"folke/which-key.nvim", config = conf("plugs.which-key")})
            use(
                {
                    "mrjones2014/legendary.nvim",
                    config = conf("plugs.legendary"),
                    requires = {"stevearc/dressing.nvim", "folke/which-key.nvim"}
                }
            )
            -- ]]] === WhichKey ===

            -- ======================== Session Management ======================== [[[
            use(
                {
                    "folke/persistence.nvim",
                    event = "BufReadPre", -- this will only start session saving when an actual file was opened
                    module = "persistence",
                    config = conf("persistence")
                }
            )

            -- use({"Shatur/neovim-session-manager", event = "BufReadPre", config = conf("session_manager")})
            -- ]]] === Session ===

            -- ============================== Debugging ============================ [[[
            use(
                {
                    "mfussenegger/nvim-dap",
                    setup = [[require('plugs.dap').setup()]],
                    config = [[require('plugs.dap').config()]],
                    after = "telescope.nvim",
                    wants = "one-small-step-for-vimkind",
                    requires = {
                        {"jbyuki/one-small-step-for-vimkind"},
                        {
                            "nvim-telescope/telescope-dap.nvim",
                            after = "nvim-dap",
                            config = [[require("telescope").load_extension("dap")]]
                        },
                        {
                            "rcarriga/nvim-dap-ui",
                            after = "nvim-dap",
                            config = function()
                                require("dapui").setup()
                            end
                        },
                        {
                            "mfussenegger/nvim-dap-python",
                            after = "nvim-dap",
                            wants = "nvim-dap",
                            config = function()
                                require("dap-python").setup(("%s/shims/python"):format(env.PYENV_ROOT))
                            end
                        }
                    }
                }
            )

            -- use({ "bfredl/nvim-luadev", config = conf("luadev"), ft = "lua" })
            use({"rafcamlet/nvim-luapad", cmd = {"Luapad", "LuaRun"}, ft = "lua"})

            -- Most docs are already available through coc.nvim
            use({"milisims/nvim-luaref", ft = "lua"})
            use({"nanotee/luv-vimdocs", ft = "lua"})
            use({"tjdevries/nlua.nvim", ft = "lua", config = conf("nlua")})
            -- use({"folke/lua-dev.nvim", ft = "lua", config = [[require("lua-dev").setup({}).settings]]})

            -- This works if all references to `lspconfig` are removed
            use({"max397574/lua-dev.nvim", ft = "lua", module = "lua-dev"})

            -- use(
            --     {
            --       "puremourning/vimspector",
            --       setup = [[vim.g.vimspector_enable_mappings = 'HUMAN']],
            --       disable = true,
            --     }
            -- )

            -- ]]] === Debugging ===

            -- ============================ File Manager =========================== [[[
            use({"kevinhwang91/rnvimr", opt = false, config = conf("plugs.rnvimr")})

            use({"ptzz/lf.vim", config = conf("lf")})
            use({prefer_local("lf.nvim"), config = conf("lfnvim")})
            -- use({ "haorenW1025/floatLf-nvim" })

            -- ]]] === File Manager ===

            -- ============================ Neo/Floaterm =========================== [[[
            use(
                {
                    "voldikss/fzf-floaterm",
                    requires = {"voldikss/vim-floaterm"},
                    config = conf("floaterm")
                }
            )

            use(
                {
                    "akinsho/toggleterm.nvim",
                    config = conf("plugs.neoterm"),
                    keys = {"gxx", "gx", "<C-\\>"},
                    cmd = {"T", "TE"}
                }
            )
            -- use({ "kassio/neoterm", config = conf("neoterm") })
            -- ]]] === Floaterm ===

            -- =========================== BetterQuickFix ========================== [[[
            -- romainl/vim-qf

            -- FIX: cclose won't work
            -- use({"stefandtw/quickfix-reflector.vim", ft = {"qf"}, config = conf("qf_reflector")})

            use({"kevinhwang91/nvim-bqf", ft = {"qf"}, config = conf("bqf")})
            use(
                {
                    "arsham/listish.nvim",
                    requires = {
                        "arsham/arshlib.nvim",
                        "norcalli/nvim.lua"
                    },
                    config = conf("listish")
                }
            )
            -- ]]] === BetterQuickFix ===

            -- ============================ EasyAlign ============================= [[[
            use({"junegunn/vim-easy-align", config = conf("plugs.easy-align")})
            -- ]]] === EasyAlign ===

            -- ============================ Open Browser =========================== [[[
            use({"tyru/open-browser.vim", config = conf("open_browser")})
            use({"axieax/urlview.nvim", config = conf("urlview"), after = "telescope.nvim"})
            -- ]]] === Open Browser ===

            -- ============================ Limelight ============================= [[[
            use(
                {
                    "folke/zen-mode.nvim",
                    cmd = "ZenMode",
                    {
                        "folke/twilight.nvim",
                        config = conf("plugs.twilight"),
                        after = "zen-mode.nvim"
                    }
                }
            )
            -- ]]] === Limelight ===

            -- ============================= Vimtex =============================== [[[
            use({"lervag/vimtex", config = conf("plugs.vimtex")})
            -- ]]] === Vimtex ===

            use(
                {
                    "kevinhwang91/suda.vim",
                    keys = {{"n", "<Leader>W"}},
                    cmd = {"SudaRead", "SudaWrite"},
                    config = conf("suda")
                }
            )

            -- ============================== VCooler ============================== [[[
            use(
                {
                    "KabbAmine/vCoolor.vim",
                    keys = {
                        {"n", "<Leader>pc"},
                        {"n", "<Leader>yb"},
                        {"n", "<Leader>yr"}
                    },
                    setup = [[vim.g.vcoolor_disable_mappings = 1 vim.g.vcoolor_lowercase = 1]],
                    config = conf("vcoolor")
                }
            )
            -- ]]] === VCooler ===

            -- =============================== Marks ============================== [[[
            use({"chentau/marks.nvim", config = conf("plugs.marks")})
            -- ]]] === Marks ===

            -- ============================== HlsLens ============================= [[[
            use(
                {
                    "kevinhwang91/nvim-hlslens",
                    config = conf("hlslens"),
                    requires = "haya14busa/vim-asterisk",
                    keys = {
                        {"n", "n"},
                        {"x", "n"},
                        {"o", "n"},
                        {"n", "N"},
                        {"x", "N"},
                        {"o", "N"},
                        {"n", "/"},
                        {"n", "?"},
                        {"n", "*"},
                        {"x", "*"},
                        {"n", "#"},
                        {"x", "#"},
                        {"n", "g*"},
                        {"x", "g*"},
                        {"n", "g#"},
                        {"x", "g#"}
                    }
                }
            )
            -- ]]] === HlsLens ===

            -- ============================== Grepper ============================= [[[
            use(
                {
                    "mhinz/vim-grepper",
                    cmd = "Grepper",
                    keys = {{"n", "gs"}, {"x", "gs"}, {"n", "<Leader>rg"}},
                    config = conf("grepper")
                }
            )
            -- ]]] === Grepper ===

            -- =========================== Colorscheme ============================ [[[
            local colorscheme = "kimbox"
            -- Needed for some themes
            use({"rktjmp/lush.nvim"})

            use({"eddyekofo94/gruvbox-flat.nvim"})
            use({"sainnhe/gruvbox-material"})
            use({"sainnhe/edge"})
            use({"sainnhe/everforest"})
            use({"sainnhe/sonokai"})
            use({"glepnir/oceanic-material"})
            use({"franbach/miramare"})
            use({"pineapplegiant/spaceduck"})
            use({"ackyshake/Spacegray.vim"})
            use({"vv9k/bogster"})
            use({"cocopon/iceberg.vim"})
            use({"metalelf0/jellybeans-nvim", requires = "rktjmp/lush.nvim"})
            use({"wadackel/vim-dogrun"})
            use({"savq/melange"})
            use({"folke/tokyonight.nvim"})
            use({"bluz71/vim-nightfly-guicolors"})
            use({"haishanh/night-owl.vim"})
            use({"rebelot/kanagawa.nvim"})
            use({"KeitaNakamura/neodark.vim"})
            use({"EdenEast/nightfox.nvim"})
            use({"catppuccin/nvim", as = "catppuccin"})
            use({"marko-cerovac/material.nvim"})
            use({"ghifarit53/daycula-vim"})
            use({"rmehri01/onenord.nvim"})
            use({"numToStr/Sakura.nvim"})
            -- use({"b4skyx/serenade"})
            -- use({ "Mofiqul/vscode.nvim" })
            -- use({"AlessandroYorba/Alduin"})
            -- use({ "olimorris/onedarkpro.nvim" })
            -- use({ "kaicataldo/material.vim" })
            -- use({ "tiagovla/tokyodark.nvim" })
            -- use({ 'projekt0n/github-nvim-theme' })

            use({"lmburns/kimbox", config = conf("plugs.kimbox")})
            -- ]]] === Colorscheme ===

            -- ============================ Scrollbar ============================= [[[
            use(
                {
                    "petertriho/nvim-scrollbar",
                    requires = {"kevinhwang91/nvim-hlslens"},
                    after = {colorscheme, "nvim-hlslens"},
                    config = conf("plugs.scrollbar")
                }
            )

            -- use({"karb94/neoscroll.nvim", config = conf("neoscroll"), desc = "Smooth scrolling"})

            use(
                {
                    "edluffy/specs.nvim",
                    -- after = "neoscroll.nvim",
                    config = conf("specs"),
                    desc = "Keep an eye on where the cursor moves"
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

            -- use ({ 'b0o/incline.nvim', config = conf("incline") })
            use(
                {
                    "nvim-lualine/lualine.nvim",
                    after = colorscheme,
                    requires = {"kyazdani42/nvim-web-devicons", opt = true},
                    config = conf("plugs.lualine")
                }
            )

            use(
                {
                    "SmiteshP/nvim-gps",
                    requires = {"nvim-treesitter/nvim-treesitter"},
                    after = "nvim-treesitter",
                    config = [[require("nvim-gps").setup()]]
                }
            )

            use(
                {
                    "akinsho/bufferline.nvim",
                    after = {colorscheme, "lualine.nvim"},
                    config = conf("plugs.bufferline"),
                    requires = "famiu/bufdelete.nvim"
                }
            )
            -- ]]] === Lualine ===

            -- =========================== Indentline ============================= [[[
            -- use({ "yggdroot/indentline", config = conf("plugs.indentline") })

            use(
                {
                    "lukas-reineke/indent-blankline.nvim",
                    after = colorscheme,
                    config = conf("plugs.indent_blankline")
                }
            )
            -- ]]] === Indentline ===

            -- =============================== Fzf ================================ [[[
            use(
                {
                    "junegunn/fzf.vim",
                    requires = {{"junegunn/fzf", run = "./install --bin"}},
                    config = conf("plugs.fzf")
                }
            )

            use(
                {
                    "ibhagwan/fzf-lua",
                    requires = {"kyazdani42/nvim-web-devicons"},
                    config = conf("plugs.fzf-lua")
                }
            )

            -- use({"vijaymarupudi/nvim-fzf"})
            -- use({ "lotabout/skim", run = "./install --bin" })
            -- ]]] === Fzf ===

            -- ====================== Window Picker ======================= [[[
            -- sindrets/winshift.nvim
            -- t9md/vim-choosewin
            use(
                {
                    "https://gitlab.com/yorickpeterse/nvim-window",
                    config = conf("window_picker"),
                    keys = {{"n", "<M-->"}}
                }
            )
            -- ]]] === Window Picker ===

            -- ============================= Operator ============================== [[[
            use(
                {
                    "AckslD/nvim-trevJ.lua",
                    config = conf("trevj"),
                    keys = {{"n", "gJ"}},
                    requires = "nvim-treesitter"
                }
            )

            -- use({"AndrewRadev/splitjoin.vim", keys = {{"n", "gJ"}, {"n", "gS"}}})

            use(
                {
                    "phaazon/hop.nvim",
                    config = conf("plugs.hop"),
                    keys = {
                        {"n", "f"},
                        {"x", "f"},
                        {"o", "f"},
                        {"n", "F"},
                        {"x", "F"},
                        {"o", "F"},
                        {"n", "t"},
                        {"x", "t"},
                        {"o", "t"},
                        {"n", "T"},
                        {"x", "T"},
                        {"o", "T"},
                        {"n", "<Leader><Leader>h"},
                        {"n", "<Leader><Leader>j"},
                        {"n", "<Leader><Leader>k"},
                        {"n", "<Leader><Leader>l"},
                        {"n", "<Leader><Leader>J"},
                        {"n", "<Leader><Leader>K"},
                        {"n", "<Leader><Leader>/"}
                    }
                }
            )

            use(
                {
                    "gbprod/substitute.nvim",
                    config = conf("plugs.substitute"),
                    keys = {
                        {"n", "s"},
                        {"n", "ss"},
                        {"n", "se"},
                        {"n", "sr"},
                        {"n", "<Leader>sr"},
                        {"n", "sS"},
                        {"n", "sx"},
                        {"n", "sxx"},
                        {"n", "sxc"},
                        {"x", "s"},
                        {"x", "X"}
                    }
                }
            )

            -- :Subvert/child{,ren}/adult{,s}/g
            use(
                {
                    "tpope/vim-abolish",
                    cmd = {"S", "Subvert", "Abolish"},
                    keys = {
                        {"n", "cr"}
                    }
                }
            )

            -- ur4ltz/surround.nvim

            -- b = (), B = {}, r = [], a = <>
            -- use(
            --     {
            --         "tpope/vim-surround",
            --         setup = [[vim.g.surround_no_mappings = 1]],
            --         keys = {
            --             {"n", "ds"},
            --             {"n", "cs"},
            --             {"n", "cS"},
            --             {"n", "ys"},
            --             {"n", "ysW"},
            --             {"n", "yS"},
            --             {"n", "yss"},
            --             {"n", "ygs"},
            --             {"x", "S"},
            --             {"x", "gS"}
            --         },
            --         config = conf("surround")
            --     }
            -- )

            use(
                {
                    "machakann/vim-sandwich",
                    config = conf("sandwhich")
                    -- keys = {
                    --     {"n", "ds"},
                    --     {"n", "cs"},
                    --     {"n", "cS"},
                    --     {"n", "ys"},
                    --     {"n", "ysW"},
                    --     {"n", "yS"},
                    --     {"n", "yss"},
                    --     {"n", "ygs"},
                    --     {"x", "S"},
                    --     {"x", "gS"},
                    --     {"v", "sa"},
                    --     {"o", "is"},
                    --     {"o", "as"},
                    --     {"o", "ib"},
                    --     {"o", "ab"}
                    -- }
                }
            )

            -- use({ "lambdalisue/readablefold.vim", event = "VimEnter" })
            use(
                {
                    "pseewald/vim-anyfold",
                    cmd = "AnyFoldActivate",
                    setup = [[vim.g.anyfold_fold_display = 0]]
                }
            )

            use({"anuvyklack/pretty-fold.nvim", config = conf("plugs.pretty-fold")})

            use(
                {
                    "windwp/nvim-autopairs",
                    config = conf("plugs.autopairs"),
                    event = "InsertEnter"
                }
            )

            -- use(
            --     {
            --       "Raimondi/delimitMate",
            --       event = "InsertEnter",
            --       config = conf("delimitmate"),
            --     }
            -- )

            use(
                {
                    "monaqa/dial.nvim",
                    config = conf("plugs.dial"),
                    keys = {
                        {"n", "+"},
                        {"n", "_"},
                        {"v", "+"},
                        {"v", "_"},
                        {"v", "g+"},
                        {"v", "g_"}
                    }
                }
            )
            -- ]]] === Operator ===

            -- =============================== Tags =============================== [[[
            use(
                {
                    "ludovicchabant/vim-gutentags",
                    config = function()
                        local config = fn.stdpath("config")
                        vim.cmd("source " .. config .. "/vimscript/plugins/vim-gutentags.vim")
                    end
                }
            )
            use(
                {
                    "liuchengxu/vista.vim",
                    after = {"vim-gutentags"},
                    config = conf("plugs.vista")
                }
            )
            -- ]]] === Tags ===

            -- ============================= Startify ============================= [[[
            use {"mhinz/vim-startify", config = conf("plugs.startify")}
            -- ]]] === Startify ===

            -- ============================= UndoTree ============================= [[[
            use(
                {
                    "mbbill/undotree",
                    cmd = "UndoTreeToggle",
                    config = conf("plugs.undotree")
                }
            )
            -- ]]] === UndoTree ===

            -- ========================== NerdCommenter =========================== [[[
            -- use({ "preservim/nerdcommenter", config = conf("plugs.nerdcommenter") })
            use({"numToStr/Comment.nvim", config = conf("plugs.comment"), after = "nvim-treesitter"})
            use({"LudoPinelli/comment-box.nvim", config = conf("comment_box")})
            -- ]]] === UndoTree ===

            -- ============================== Targets ============================== [[[
            -- kana/vim-textobj-user
            use({"wellle/targets.vim", config = conf("targets")})
            use({"andymass/vim-matchup", config = conf("matchup")})
            -- ]]] === Neoformat ===

            -- ============================== Nvim-R =============================== [[[
            use(
                {
                    "jalvesaq/Nvim-R",
                    branch = "stable",
                    config = conf("plugs.nvim-r")
                }
            )
            -- ]]] === Nvim-R ===

            -- ========================= VimSlime - Python ========================= [[[
            use({"jpalardy/vim-slime", ft = "python", config = conf("slime")})
            -- ]]] === VimSlime - Python ===

            -- ============================= Vim - Rust ============================ [[[
            use({"rust-lang/rust.vim", ft = "rust", config = conf("plugs.rust")})

            use(
                {
                    "Saecki/crates.nvim",
                    event = {"BufRead Cargo.toml"},
                    config = conf("crates")
                }
            )
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

            -- ============================= Javascript ============================ [[[
            use(
                {
                    "vuki656/package-info.nvim",
                    requires = "MunifTanjim/nui.nvim",
                    config = conf("package_info")
                }
            )

            use(
                {
                    "bennypowers/nvim-regexplainer",
                    requires = {
                        "nvim-lua/plenary.nvim",
                        "MunifTanjim/nui.nvim",
                        {"nvim-treesitter/nvim-treesitter", opt = true}
                    },
                    after = {"nvim-treesitter"},
                    config = conf("regexplainer")
                }
            )
            -- ]]] === Javascript ===

            -- ============================== Vim - Go ============================= [[[
            use({"fatih/vim-go", ft = "go", config = conf("plugs.go")})
            -- ]]] === VimSlime - Python ===

            -- ============================== Markdown ============================= [[[
            -- use(
            --     {
            --       "renerocksai/telekasten.nvim",
            --       after = { "telescope.nvim" },
            --       require = { "renerocksai/calendar-vim" },
            --       config = conf("plugs.telekasten")
            --     }
            -- )

            -- use(
            --     {
            --         "lukas-reineke/headlines.nvim",
            --         config = function()
            --             require("headlines").setup()
            --         end
            --     }
            -- )

            use(
                {
                    "vim-pandoc/vim-pandoc-syntax",
                    ft = {"pandoc", "markdown", "vimwiki"},
                    config = conf("pandoc")
                }
            )

            use(
                {
                    "plasticboy/vim-markdown",
                    ft = {"markdown", "vimwiki"},
                    config = conf("markdown")
                }
            )

            use(
                {
                    "dhruvasagar/vim-table-mode",
                    ft = {"markdown", "vimwiki"},
                    config = conf("table_mode")
                }
            )

            -- FIX: TOC is written each time
            use(
                {
                    "SidOfc/mkdx",
                    ft = {"markdown", "vimwiki"},
                    config = function()
                        vim.cmd("source " .. fn.stdpath("config") .. "/vimscript/plugins/mkdx.vim")
                    end
                }
            )

            use({"vimwiki/vimwiki", config = conf("vimwiki"), after = colorscheme})
            use({"FraserLee/ScratchPad", config = conf("scratchpad")})
            -- ]]] === Markdown ===

            -- ================================ Wilder ============================= [[[
            use(
                {
                    "gelguy/wilder.nvim",
                    run = ":UpdateRemotePlugins",
                    -- rocks = "pcre2",
                    requires = "romgrk/fzy-lua-native",
                    config = conf("plugs.wilder")
                }
            ) -- ]]] === Wilder ===

            -- ========================= Syntax-Highlighting ======================= [[[
            use(
                {
                    "sheerun/vim-polyglot",
                    setup = function()
                        g.polyglot_disabled = {
                            -- "ftdetect",
                            -- "sensible",
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
                            -- "lua",
                            -- "json",
                            -- "kotlin",
                            -- "lua",
                            "make",
                            "perl",
                            "python",
                            "query",
                            "ruby",
                            "rust",
                            "scss",
                            -- "teal",
                            -- "tsx",
                            -- "vue",
                            "zig",
                            "zsh"
                            -- "typescript",
                        }
                    end
                }
            )

            -- use({ "wfxr/dockerfile.vim" })
            use({"rhysd/vim-rustpeg", ft = "rustpeg"})
            use({"nastevens/vim-cargo-make"})
            use({"NoahTheDuke/vim-just", ft = "just"})
            use({"camnw/lf-vim", ft = "lf"})
            use({"ron-rs/ron.vim", ft = "ron"})
            -- ]]] === Syntax-Highlighting ===

            -- =========================== Keymaps - Nest ========================== [[[
            -- use({ "LionC/nest.nvim", config = conf("plugs.keymaps") })
            -- ]]] === Keymaps ===

            -- ============================= File-Viewer =========================== [[[
            use({"mattn/vim-xxdcursor"})
            use(
                {
                    "fidian/hexmode",
                    config = [[vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe']]
                }
            )

            use({"jamessan/vim-gnupg"})
            use({"AndrewRadev/id3.vim"})
            use({"alx741/vinfo"})
            use({"HiPhish/info.vim", config = conf("info")})
            -- ]]] === File Viewer ===

            -- ============================== Snippets ============================= [[[
            use({"SirVer/ultisnips", config = conf("ultisnips")})
            use({"honza/vim-snippets"})
            -- ]]] === Snippets ===

            -- ============================== Minimap ============================== [[[
            use {"wfxr/minimap.vim", config = conf("minimap")}
            -- ]]] === Minimap ===

            -- ============================= Highlight ============================ [[[
            -- use({"rrethy/vim-hexokinase", run = "make hexokinase"})
            use(
                {
                    "norcalli/nvim-colorizer.lua",
                    cmd = "ColorizerToggle",
                    ft = {
                        "gitconfig",
                        "vim",
                        "sh",
                        "zsh",
                        "markdown",
                        "tmux",
                        "yaml",
                        "xml",
                        "css",
                        "typescript",
                        "javascript",
                        "lua"
                    },
                    config = conf("colorizer")
                }
            )
            use(
                {
                    "Pocco81/HighStr.nvim",
                    event = "VimEnter",
                    config = conf("plugs.HighStr")
                }
            )
            use(
                {
                    "folke/todo-comments.nvim",
                    config = conf("plugs.todo-comments"),
                    wants = {"plenary.nvim"},
                    opt = false
                }
            )
            -- ]]] === Highlight ===

            -- ============================= Neoformat ============================= [[[
            use({"sbdchd/neoformat", config = conf("plugs.neoformat")})
            -- ]]] === Neoformat ===

            -- =============================== Coc ================================ [[[
            -- use({ 'tjdevries/coc-zsh', ft = "zsh" })
            -- use({"teal-language/vim-teal", ft = "teal"})
            -- use({ 'ThePrimeagen/refactoring.nvim', opt = true })
            use({"vim-perl/vim-perl", ft = "perl"})

            use(
                {
                    "neoclide/coc.nvim",
                    branch = "master",
                    run = "yarn install --frozen-lockfile",
                    config = [[require('plugs.coc').tag_cmd()]],
                    requires = {
                        {"antoinemadec/coc-fzf", after = "coc.nvim"},
                        {"kevinhwang91/coc-kvs", after = "coc.nvim", run = "yarn install --frozen-lockfile"}
                    }
                }
            )
            -- ]]] === Coc ===

            -- ============================= Treesitter ============================ [[[
            use(
                {
                    -- config = conf("plugs.tree-sitter")
                    "nvim-treesitter/nvim-treesitter",
                    run = ":TSUpdate",
                    requires = {
                        {
                            "nvim-treesitter/nvim-treesitter-refactor",
                            after = "nvim-treesitter",
                            desc = "Refactor module"
                        },
                        {
                            "RRethy/nvim-treesitter-endwise",
                            after = "nvim-treesitter",
                            desc = "Adds 'end' to ruby and lua"
                        },
                        {
                            "nvim-treesitter/nvim-treesitter-textobjects",
                            after = "nvim-treesitter"
                        },
                        {
                            "nvim-treesitter/playground",
                            after = "nvim-treesitter",
                            -- cmd = {"TSHighlightCapturesUnderCursor", "TSPlaygroundToggle"}
                        },
                        {
                            "windwp/nvim-ts-autotag",
                            after = "nvim-treesitter",
                            desc = "Html/Css tagging"
                        },
                        {
                            "JoosepAlviste/nvim-ts-context-commentstring",
                            after = "nvim-treesitter",
                            desc = "Embedded language comment strings"
                        },
                        {
                            "michaeljsmith/vim-indent-object",
                            after = "nvim-treesitter",
                            desc = "ai ii aI iI text objects"
                        },
                        {
                            "haringsrob/nvim_context_vt",
                            after = "nvim-treesitter",
                            desc = "Adds -> context messages"
                        },
                        {
                            "David-Kunz/treesitter-unit",
                            after = "nvim-treesitter",
                            desc = "Adds unit text object"
                        },
                        {
                            "m-demare/hlargs.nvim",
                            after = "nvim-treesitter",
                            desc = "Highlight argument definitions"
                        },
                        {
                            "stevearc/aerial.nvim",
                            after = "nvim-treesitter"
                        },
                        {
                            "danymat/neogen",
                            config = conf("neogen"),
                            after = "nvim-treesitter",
                            keys = {
                                {"n", "<Leader>dg"},
                                {"n", "<Leader>df"},
                                {"n", "<Leader>dc"}
                            }
                        },
                        {
                            "lewis6991/spellsitter.nvim",
                            after = "nvim-treesitter",
                            config = [[require("spellsitter").setup()]]
                        }
                        -- {
                        --     "s1n7ax/nvim-comment-frame",
                        --     after = "nvim-treesitter"
                        -- }
                        -- {
                        --     "mfussenegger/nvim-ts-hint-textobject",
                        --     after = "nvim-treesitter",
                        --     desc = "Similar to hop but highlight"
                        -- }
                        -- {
                        --     "romgrk/nvim-treesitter-context",
                        --     after = "nvim-treesitter"
                        -- },
                        -- {
                        --     "yioneko/nvim-yati",
                        --     after = "nvim-treesitter",
                        --     desc = "Yet another tressitter indent"
                        -- },
                    }
                }
            )

            use({"mizlan/iswap.nvim", requires = "nvim-treesitter/nvim-treesitter", after = "nvim-treesitter"})

            -- use({ "p00f/nvim-ts-rainbow", after = { "nvim-treesitter" } })
            -- use({ "theHamsta/nvim-treesitter-pairs", after = { "nvim-treesitter" } })

            use({"nvim-treesitter/nvim-tree-docs", after = {"nvim-treesitter"}})
            -- ]]] === Treesitter ===

            -- ============================= Telescope ============================ [[[
            use(
                {
                    "nvim-telescope/telescope.nvim",
                    opt = false,
                    config = conf("plugs.telescope"),
                    after = {"popup.nvim", "plenary.nvim", colorscheme},
                    requires = {
                        {
                            "nvim-telescope/telescope-ghq.nvim",
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("ghq")]]
                        },
                        {
                            "nvim-telescope/telescope-github.nvim",
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("gh")]]
                        },
                        {
                            "nvim-telescope/telescope-frecency.nvim",
                            after = "telescope.nvim",
                            requires = "tami5/sqlite.lua",
                            config = [[require("telescope").load_extension("frecency")]]
                        },
                        {
                            "fannheyward/telescope-coc.nvim",
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("coc")]]
                        },
                        {
                            "fhill2/telescope-ultisnips.nvim",
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("ultisnips")]]
                        },
                        {
                            "nvim-telescope/telescope-fzf-native.nvim",
                            after = "telescope.nvim",
                            run = "make",
                            config = [[require("telescope").load_extension("fzf")]]
                        },
                        {
                            "dhruvmanila/telescope-bookmarks.nvim",
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("bookmarks")]]
                        },
                        {
                            "nvim-telescope/telescope-file-browser.nvim",
                            after = {"telescope.nvim"},
                            config = [[require("telescope").load_extension("file_browser")]]
                        },
                        {
                            "nvim-telescope/telescope-ui-select.nvim",
                            after = {"telescope.nvim"},
                            config = [[require("telescope").load_extension("ui-select")]]
                        },
                        {
                            "nvim-telescope/telescope-hop.nvim",
                            after = {"telescope.nvim"},
                            config = [[require("telescope").load_extension("hop")]]
                        },
                        {
                            "crispgm/telescope-heading.nvim",
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("heading")]]
                        },
                        {
                            "nvim-telescope/telescope-smart-history.nvim",
                            requires = {"tami5/sqlite.lua"},
                            after = {"telescope.nvim", "sqlite.lua"},
                            config = [[require("telescope").load_extension("smart_history")]],
                            run = function()
                                local path = Path:new(fn.stdpath("data") .. "/databases/")
                                if not path:exists() then
                                    path:mkdir()
                                end
                            end
                        },
                        {
                            "jvgrootveld/telescope-zoxide",
                            after = {"telescope.nvim"},
                            config = [[require("telescope").load_extension("zoxide")]]
                        },
                        {
                            prefer_local("telescope-rualdi.nvim"),
                            after = {"telescope.nvim"},
                            config = [[require("telescope").load_extension("rualdi")]]
                        }
                    }
                }
            )

            use(
                {
                    "nvim-telescope/telescope-packer.nvim",
                    after = {"telescope.nvim"},
                    requires = {
                        "nvim-telescope/telescope.nvim",
                        "wbthomason/packer.nvim"
                    },
                    wants = {"telescope.nvim", "packer.nvim"},
                    -- FIX: Doesn't work all the time and is hard to configure
                    -- config = [[require("telescope").load_extension("packer")]],
                    config = function()
                        require("telescope.builtin").packer = function(opts)
                            -- if not _G.packer_plugins["packer.nvim"].loaded then
                            ex.packadd("packer.nvim")
                            -- end
                            -- require("plugins").compile()

                            require("telescope").load_extension("packer")
                            require("telescope").extensions.packer.packer(opts)
                        end
                    end
                }
            )

            -- use(
            --     {
            --         "AckslD/nvim-neoclip.lua",
            --         requires = {"nvim-telescope/telescope.nvim", "tami5/sqlite.lua"},
            --         after = {"telescope.nvim", "sqlite.lua"},
            --         config = conf("plugs.nvim-neoclip")
            --     }
            -- )
            -- ]]] === Telescope ===

            -- ================================ Git =============================== [[[
            use(
                {
                    "tpope/vim-fugitive",
                    fn = "fugitive#*",
                    cmd = {
                        "0Git",
                        "G",
                        "GBrowse",
                        "Gcd",
                        "Gclog",
                        "GDelete",
                        "Gdiffsplit",
                        "Gedit",
                        "Ggrep",
                        "Ghdiffsplit",
                        "Git",
                        "Glcd",
                        "Glgrep",
                        "Gllog",
                        "GMove",
                        "Gpedit",
                        "Gread",
                        "GRemove",
                        "GRename",
                        "Gsplit",
                        "Gtabedit",
                        "GUnlink",
                        "Gvdiffsplit",
                        "Gvsplit",
                        "Gwq",
                        "Gwrite"
                    },
                    event = "BufReadPre */.git/index",
                    config = conf("plugs.fugitive")
                }
            )

            use(
                {
                    "rbong/vim-flog",
                    cmd = {"Flog", "Flogsplit"},
                    keys = {
                        {"n", "<Leader>gl"},
                        {"n", "<Leader>gf"}
                    },
                    requires = {{"tpope/vim-fugitive"}},
                    config = conf("plugs.flog")
                }
            )

            use({"tpope/vim-rhubarb"})

            use({"kdheepak/lazygit.nvim", config = conf("lazygit")})

            use(
                {
                    "lewis6991/gitsigns.nvim",
                    config = conf("plugs.gitsigns"),
                    requires = {"nvim-lua/plenary.nvim"}
                }
            )

            use(
                {
                    "TimUntersberger/neogit",
                    config = conf("plugs.neogit"),
                    requires = {"nvim-lua/plenary.nvim"}
                }
            )

            use(
                {
                    "ruanyl/vim-gh-line",
                    keys = {
                        {"n", "<Leader>gO"},
                        {"n", "<Leader>gL"},
                        {"x", "<Leader>gL"}
                    },
                    setup = [[vim.g.gh_line_blame_map_default = 0]],
                    config = conf("ghline")
                }
            )

            use(
                {
                    "sindrets/diffview.nvim",
                    cmd = {
                        "DiffviewClose",
                        "DiffviewFileHistory",
                        "DiffviewFocusFiles",
                        "DiffviewLog",
                        "DiffviewOpen",
                        "DiffviewRefresh",
                        "DiffviewToggleFiles"
                    },
                    config = conf("plugs.diffview"),
                    keys = {
                        {"n", "<Leader>g;"}
                    }
                }
            )

            -- use(
            --     {
            --         "christoomey/vim-conflicted",
            --         cmd = {"Conflicted", "Merger", "GitNextConflict"},
            --         keys = {
            --             "<Plug>DiffgetLocal",
            --             "<Plug>DiffgetUpstream",
            --             "<Plug>DiffgetLocal",
            --             "<Plug>DiffgetUpstream"
            --         }
            --     }
            -- )

            -- ]]] === Git ===

            use(
                {
                    ("%s/%s"):format(fn.stdpath("config"), "lua/plugs/nvim-reload"),
                    config = conf("plugs.nvim-reload"),
                    opt = true
                }
            )

            use({"rcarriga/nvim-notify", config = conf("notify")})
        end
    }
)

-- ============================== Disabled ============================= [[[
-- ╭──────────────────────────────────────────────────────────╮
-- │                           LSP                            │
-- ╰──────────────────────────────────────────────────────────╯
-- ==== Completion ====
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

-- ==== Other ===
-- "RRethy/vim-illuminate" => Highlight word under cursor
-- "pechorin/any-jump.vim" => Definition jumping
-- "j-hui/fidget.nvim" => Standalone for LSP progress
-- "filipdutescu/renamer.nvim" => Like code action rename
-- "jubnzv/virtual-types.nvim" => Code lens

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Disabled                         │
-- ╰──────────────────────────────────────────────────────────╯
-- use(
--     {
--         "nvim-neorg/neorg",
--         config = conf("plugs.norg"),
--         after = "nvim-treesitter",
--         requires = {"plenary.nvim", "nvim-neorg/neorg-telescope"}
--     }
-- )

-- 'jbyuki/venn.nvim'          => Draw ASCII diagrams in Neovim
-- '0styx0/abbreinder.nvim'    => Abbreviation reminders
-- 'mvllow/modes.nvim'         => Highlight cursorline based on mode
-- 'GustavoKatel/sidebar.nvim' => Sidebar with information

-- use(
--     {
--         "windwp/nvim-spectre",
--         cmd = "SpectreOpen",
--         config = conf("spectre")
--     }
-- )

-- use(
--     {
--       "cutlass/gbprod.nvim",
--       config = conf("cutlass"),
--       -- keys = {
--       --   { "n", "c" },
--       --   { "n", "cc" },
--       --   { "n", "C" },
--       --   { "n", "d" },
--       --   { "n", "dd" },
--       --   { "n", "D" },
--       --   { "n", "x" },
--       --   { "n", "X" },
--       -- },
--     }
-- )
-- ]]] === Disabled ===
