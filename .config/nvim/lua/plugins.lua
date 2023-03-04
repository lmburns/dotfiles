-- ==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-26 15:02
-- ==========================================================================
local fn = vim.fn
local uv = vim.loop
local cmd = vim.cmd
local dirs = require("common.global").dirs

local install_path = ("%s/%s"):format(dirs.data, "/site/pack/packer/opt/packer.nvim")
if not uv.fs_stat(install_path) then
    fn.system("git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

local Path = require("plenary.path")
local Job = require("plenary.job")

cmd.packadd("packer.nvim")
local packer = require("packer")

packer.on_compile_done = function()
    local fp = assert(io.open(packer.config.compile_path, "r+"))
    local wbuf = {}
    local key_state = 0
    for line in fp:lines() do
        if key_state == 0 then
            table.insert(wbuf, line)
            if line:find("Keymap lazy%-loads") then
                key_state = 1
                table.insert(wbuf, [[vim.defer_fn(function()]])
            end
        elseif key_state == 1 then
            if line == "" then
                key_state = 2
                table.insert(wbuf, ("end, %d)"):format(15))
            end
            local _, e1 = line:find("vim%.cmd")
            if line:find("vim%.cmd") then
                local s2, e2 = line:find("%S+%s", e1 + 1)
                local map_mode = line:sub(s2, e2)
                line = ("pcall(vim.cmd, %s<unique>%s)"):format(map_mode, line:sub(e2 + 1))
            end
            table.insert(wbuf, line)
        else
            table.insert(wbuf, line)
        end
    end

    if key_state == 2 then
        fp:seek("set")
        fp:write(table.concat(wbuf, "\n"))
    end

    fp:close()
    -- vim.cmd [[doautocmd User PackerCompileDone]]
end

-- packer.on_complete = function()
--     cmd("doau User PackerComplete")
--     nvim.p.TSNote("Packer completed")
-- end

packer.init(
    {
        compile_path = ("%s/plugin/packer_compiled.lua"):format(dirs.config),
        snapshot_path = ("%s/snapshot/packer.nvim"):format(dirs.config),
        -- snapshot_path = ("%s/snapshot/packer.nvim"):format(dirs.cache),
        -- opt_default = false,
        auto_clean = true,
        auto_reload_compiled = true, -- Automatically reload the compiled file after creating it.
        autoremove = false,
        compile_on_sync = true, -- During sync(), run packer.compile()
        ensure_dependencies = true, -- Should packer install plugin dependencies?
        transitive_disable = true, -- Automatically disable dependencies of disabled plugins
        display = {
            non_interactive = false,
            header_lines = 2,
            title = " packer.nvim",
            working_sym = " ",
            error_sym = "",
            done_sym = "",
            removed_sym = "",
            moved_sym = " ",
            show_all_info = true,
            prompt_border = "rounded",
            open_cmd = [[tabedit]],
            keybindings = {
                prompt_revert = "R",
                diff = "D",
                retry = "r",
                quit = "q",
                toggle_info = "<CR>"
            },
            open_fn = function()
                return require("packer.util").float({border = "rounded"})
            end
        },
        log = {level = "info"},
        profile = {enable = true}
    }
)

PATCH_DIR = ("%s/patches"):format(dirs.config)

local handlers = {
    conf = function(_plugins, plugin, value)
        if value:match("^plugs%..+%.") then
            local _, _, m1, m2 = value:find("^plugs%.(.+)%.(.+)")
            plugin.config = ([[require('plugs.%s').%s()]]):format(m1, m2)
        elseif value:match("^plugs%.") then
            plugin.config = ([[require('%s')]]):format(value)
        else
            plugin.config = ([[require('plugs.config').%s()]]):format(value)
        end
    end,
    disablep = function(_, plugin, _value)
        -- Do not override plugins that have been disabled with the `disable` key
        if plugin.disable == nil then
            plugin.disable = require("common.control")[plugin.short_name]
        end
    end,
    deb = function(_, plugin, _)
        if plugin.disable == true then
            p(plugin)
        end
    end,
    patch = function(_plugins, plugin, value)
        -- local run_hook = plugin_utils.post_update_hook

        -- This is preferred because you can provide own error message
        vim.validate {
            value = {
                value,
                function(n)
                    local t = type(n)
                    return t == "string" or t == "boolean"
                end,
                ("%s: must be a string or boolean"):format(plugin.short_name)
            }
        }

        if type(value) == "string" then
            value = fn.expand(value)
        else
            value = ("%s/%s.patch"):format(PATCH_DIR, plugin.short_name)
        end

        plugin.run = function()
            if uv.fs_stat(value) then
                nvim.p(("Applying patch: %s"):format(plugin.short_name), "WarningMsg")
                cmd.lcd(plugin.install_path)
                Job:new(
                    {
                        command = "patch",
                        args = {"-s", "-N", "-p1", "-i", value},
                        on_exit = function(_, ret)
                            if ret ~= 0 then
                                nvim.p(
                                    ("Unable to apply patch to %s"):format(plugin.name),
                                    "ErrorMsg"
                                )
                            end
                        end
                    }
                ):start()
            else
                nvim.p("Patch file does not exist", "ErrorMsg")
            end
        end
    end
}

---Specify a configuration in `common.config` or its own file
packer.set_handler("conf", handlers.conf)

---Specify the disable marker for each plugin
---Can be disabled easier in the `control.lua` file
packer.set_handler(1, handlers.disablep)

-- packer.set_handler("deb", handlers.deb)
packer.set_handler(1, handlers.deb)

---Apply a patch to the given plugin
packer.set_handler("patch", handlers.patch)

---Use a local plugin found on the filesystem
---@param url string link to repo
---@param path? string path to repo
---@return string
local function prefer_local(url, path)
    if not path then
        local name = url:match("[^/]*$")
        path = "~/projects/nvim/" .. name
    end
    return uv.fs_stat(fn.expand(path)) ~= nil and path or url
end

-- nacro90/numb.nvim - Peek at line
-- PatschD/zippy.nvim
-- nvim-zh/colorful-winsep.nvim
-- kristijanhusak/line-notes.nvim
-- smjonas/live-command.nvim
-- smjonas/inc-rename.nvim
-- gorbit99/codewindow.nvim

return packer.startup(
    {
        function(use, use_rocks)
            use_rocks("lpeg")
            -- https://rrthomas.github.io/lrexlib/manual.html
            use_rocks("lrexlib-pcre2") -- rex_pcre2

            ---@type fun(v: PackerPlugin)
            local use = use

            -- Package manager
            use(
                {
                    "wbthomason/packer.nvim",
                    opt = true,
                    setup = function()
                        if vim.g.loaded_visual_multi == 1 then
                            vim.schedule(
                                function()
                                    fn["vm#plugs#permanent"]()
                                end
                            )
                        end
                    end
                }
            )

            -- Cache startup
            use({"lewis6991/impatient.nvim"})
            use(
                {
                    "dstein64/vim-startuptime",
                    cmd = "StartupTime",
                    config = function()
                        vim.g.startuptime_tries = 15
                        vim.g.startuptime_exe_args = {"+let g:auto_session_enabled = 0"}
                    end
                }
            )

            -- ╭──────────────────────────────────────────────────────────╮
            -- │                         Library                          │
            -- ╰──────────────────────────────────────────────────────────╯
            use({"tpope/vim-repeat"})
            use({"ryanoasis/vim-devicons"})

            use({"nvim-lua/popup.nvim"})
            use({"nvim-lua/plenary.nvim"})
            use({"kevinhwang91/promise-async"})
            use({"folke/neodev.nvim", conf = "neodev"})
            use({"norcalli/nvim.lua"})
            use({"arsham/arshlib.nvim", requires = {"nvim-lua/plenary.nvim"}})
            use({"tami5/sqlite.lua"})
            use({"kyazdani42/nvim-web-devicons", conf = "devicons"})
            use({"stevearc/dressing.nvim", event = "BufWinEnter", conf = "plugs.dressing"})

            -- ============================= Keybinding =========================== [[[
            use({"folke/which-key.nvim", conf = "plugs.which-key"})
            use(
                {
                    "mrjones2014/legendary.nvim",
                    conf = "plugs.legendary",
                    requires = {"stevearc/dressing.nvim", "folke/which-key.nvim"}
                }
            )
            -- ]]] === Keybinding ===

            -- ========================== Fixes / Addons ========================== [[[
            use({"antoinemadec/FixCursorHold.nvim", opt = false})
            use({"max397574/better-escape.nvim", conf = "better_esc"})
            use(
                {
                    "mrjones2014/smart-splits.nvim",
                    conf = "smartsplits",
                    desc = "Navigate split panes"
                }
            )
            use({"aserowy/tmux.nvim", conf = "tmux"})
            use(
                {
                    "fedepujol/move.nvim",
                    conf = "move",
                    desc = "Move line/character in various modes"
                }
            )
            use({"tversteeg/registers.nvim", conf = "registers"})
            use({"AndrewRadev/bufferize.vim", cmd = "Bufferize"}) -- replace builtin pager
            use({"inkarkat/vim-SpellCheck", requires = {"inkarkat/vim-ingo-library"}})
            use({"m4xshen/smartcolumn.nvim", conf = "smartcolumn"})

            use(
                {
                    "jedrzejboczar/possession.nvim",
                    requires = "nvim-lua/plenary.nvim",
                    after = "telescope.nvim",
                    conf = "plugs.possession",
                    desc = "Session management"
                }
            )

            use(
                {
                    "AndrewRadev/linediff.vim",
                    conf = "linediff",
                    cmd = "Linediff",
                    keys = {{"n", "<Leader>ld"}, {"x", "<Leader>ld"}}
                }
            )

            use(
                {
                    "vim-scripts/UnconditionalPaste",
                    patch = true,
                    keys = {
                        {"n", "gcp"}, -- Paste charwise (newline and indent flattened)
                        {"n", "gcP"},
                        {"n", "glp"}, -- Paste linewise (even if not complete)
                        {"n", "glP"},
                        {"n", "gbp"}, -- Paste blockwise (multiple lines in place, push text to right)
                        {"n", "gbP"},
                        {"n", "ghp"}, -- Paste linewise (like glp but adjust indent) (MODIFIED)
                        {"n", "ghP"},
                        {"n", "g#p"}, -- Paste commented out
                        {"n", "g#P"},
                        {"n", "g>p"}, -- Paste shifted
                        {"n", "g>P"},
                        {"n", "g[p"}, -- Paste linewise (like glp but adjust indent)
                        {"n", "g[P"},
                        {"n", "gsp"}, -- Paste with [count] spaces around lines
                        {"n", "gsP"}
                    }
                }
            )

            use({"arthurxavierx/vim-caser", setup = [[vim.g.caser_prefix = "cr"]], conf = "caser"})

            -- TODO: Get completions to work just as regular S does
            -- :E2v = (\d{1,3})(?=(\d\d\d)+($|\D))
            -- Match = :M/<Items\s+attr="media">.+?<\/Items>/Im
            -- Substitute = :'<,'>S/(\d{1,3})(?=(\d\d\d)+($|\D))/\1,/g
            -- Global = :G/^begin$/+1;/^end$/-1:S/\l+/\U&/g
            -- :V
            use(
                {
                    "othree/eregex.vim",
                    cmd = {"E2v", "S", "M"},
                    setup = [[vim.g.eregex_default_enable = 0]],
                    keys = {{"n", "<Leader>es"}},
                    conf = "eregex",
                    desc = "Ruby/Perl style regex for Vim"
                }
            )

            use(
                {
                    "mg979/vim-visual-multi",
                    setup = [[vim.g.VM_leader = '<Space>']],
                    keys = {
                        {"n", "<C-n>"},
                        {"x", "<C-n>"},
                        {"n", [[<Leader>\]]},
                        {"n", [[<Leader>/]]},
                        {"n", "<Leader>A"},
                        {"n", "<Leader>gs"},
                        {"x", "<Leader>A"},
                        {"n", "<M-S-i>"},
                        {"n", "<M-S-o>"},
                        {"n", "<C-Up>"},
                        {"n", "<C-Down>"},
                        {"n", "g/"}
                    },
                    cmd = {"VMSearch"},
                    conf = "visualmulti",
                    wants = {"nvim-hlslens", "nvim-autopairs"}
                }
            )

            use(
                {
                    "kevinhwang91/suda.vim",
                    keys = {{"n", "<Leader>W"}},
                    cmd = {"SudaRead", "SudaWrite"},
                    conf = "suda"
                }
            )

            use({"skywind3000/asyncrun.vim", cmd = "AsyncRun"})
            -- ]]] === Fixes ===

            -- =========================== Colorscheme ============================ [[[
            local colorscheme = "kimbox"
            -- Needed for some themes
            use({"rktjmp/lush.nvim"})

            use({"kvrohit/mellow.nvim"})
            use({"eddyekofo94/gruvbox-flat.nvim"})
            use({"sainnhe/gruvbox-material"})
            use({"sainnhe/edge"})
            use({"sainnhe/everforest"})
            use({"sainnhe/sonokai"})
            use({"glepnir/oceanic-material"})
            use({"franbach/miramare"})
            use({"pineapplegiant/spaceduck"})
            use({"cocopon/iceberg.vim"})
            use({"savq/melange"})
            use({"folke/tokyonight.nvim"})
            use({"rebelot/kanagawa.nvim"})
            use({"KeitaNakamura/neodark.vim"})
            use({"EdenEast/nightfox.nvim"})
            use({"catppuccin/nvim", as = "catppuccin"})
            use({"rose-pine/neovim", as = "rose-pine"})
            use({"marko-cerovac/material.nvim"})
            use({"meliora-theme/neovim"})
            -- use({"tiagovla/tokyodark.nvim"})
            -- use({"bluz71/vim-nightfly-guicolors"})
            -- use({"haishanh/night-owl.vim"})
            -- Need to make a new theme for this
            -- use({"tyrannicaltoucan/vim-deep-space"})
            -- Need to make a new theme for this
            -- use({"ackyshake/Spacegray.vim"})
            -- use({"vv9k/bogster"})
            -- use({"ghifarit53/daycula-vim"})
            -- use({"rmehri01/onenord.nvim"})
            -- use({"kyazdani42/blue-moon"})
            -- use({"rockyzhang24/arctic.nvim"})

            -- use({"shaunsingh/oxocarbon.nvim", run = "./install.sh"})
            -- use({"levuaska/levuaska.nvim"})
            -- use({"wadackel/vim-dogrun"})
            -- use({"sam4llis/nvim-tundra"})

            use({"lmburns/kimbox", conf = "plugs.kimbox"})
            -- ]]] === Colorscheme ===

            -- ============================== Debugging ============================ [[[
            use(
                {
                    "mfussenegger/nvim-dap",
                    conf = "plugs.dap",
                    after = "telescope.nvim",
                    wants = "one-small-step-for-vimkind",
                    requires = {
                        {"jbyuki/one-small-step-for-vimkind"},
                        {"theHamsta/nvim-dap-virtual-text"},
                        {
                            "nvim-telescope/telescope-dap.nvim",
                            after = "nvim-dap",
                            config = [[require("telescope").load_extension("dap")]]
                        },
                        {
                            "rcarriga/nvim-dap-ui",
                            after = "nvim-dap"
                        },
                        {
                            "mfussenegger/nvim-dap-python",
                            after = "nvim-dap",
                            wants = "nvim-dap"
                        }
                    }
                }
            )

            use(
                {
                    "rcarriga/neotest",
                    conf = "plugs.neotest",
                    module = "neotest",
                    -- wants = "overseer.nvim",
                    requires = {
                        "nvim-lua/plenary.nvim",
                        "nvim-treesitter/nvim-treesitter",
                        "antoinemadec/FixCursorHold.nvim",
                        "nvim-neotest/neotest-python",
                        "nvim-neotest/neotest-go",
                        "nvim-neotest/neotest-plenary",
                        "nvim-neotest/neotest-vim-test"
                        -- "vim-test/vim-test"
                    }
                }
            )

            -- ========================== Task Runner ============================= [[[
            -- use(
            --     {
            --         "stevearc/overseer.nvim",
            --         conf = "plugs.overseer",
            --         after = {"dressing.nvim"},
            --         module = "overseer",
            --         cmd = {
            --             "OverseerOpen",
            --             "OverseerClose",
            --             "OverseerToggle",
            --             "OverseerSaveBundle",
            --             "OverseerLoadBundle",
            --             "OverseerDeleteBundle",
            --             "OverseerRunCmd",
            --             "OverseerRun",
            --             "OverseerBuild",
            --             "OverseerQuickAction",
            --             "OverseerTaskAction"
            --         }
            --     }
            -- )
            -- ]]] === Task Runner ===

            use(
                {
                    "rafcamlet/nvim-luapad",
                    cmd = {"Luapad", "LuaRun"},
                    ft = "lua",
                    conf = "luapad"
                }
            )

            -- Most docs are already available through coc.nvim
            use({"milisims/nvim-luaref", ft = "lua"})
            use({"nanotee/luv-vimdocs", ft = "lua"})
            use({"tjdevries/nlua.nvim", ft = "lua", conf = "nlua", patch = true})

            -- ]]] === Debugging ===

            -- ============================ Neo/Floaterm =========================== [[[
            use({"voldikss/fzf-floaterm", requires = {"voldikss/vim-floaterm"}, conf = "floaterm"})

            use(
                {
                    "akinsho/toggleterm.nvim",
                    conf = "plugs.neoterm"
                    -- keys = {"gzo", "gzz", "<C-\\>"},
                    -- cmd = {"T", "TR", "TP", "VT"}
                }
            )
            -- use({ "kassio/neoterm", conf = "neoterm" })
            -- ]]] === Floaterm ===

            -- ============================ File Manager =========================== [[[
            use({"kevinhwang91/rnvimr", opt = false, conf = "plugs.rnvimr"})
            use(
                {
                    prefer_local("lf.nvim"),
                    conf = "lfnvim",
                    -- cmd = {"Lf"},
                    -- keys = {{"n", "<A-o>"}},
                    after = {colorscheme, "toggleterm.nvim"},
                    wants = "toggleterm.nvim",
                    requires = {"nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim"}
                }
            )
            use({"ptzz/lf.vim", conf = "lf"})

            -- ]]] === File Manager ===

            -- =========================== BetterQuickFix ========================== [[[
            use({"kevinhwang91/nvim-bqf", ft = {"qf"}, conf = "plugs.bqf"})
            use(
                {
                    "arsham/listish.nvim",
                    requires = {"arsham/arshlib.nvim", "norcalli/nvim.lua"},
                    conf = "listish"
                }
            )

            -- use(
            --     {
            --         "cbochs/portal.nvim",
            --         conf = "plugs.portal",
            --         requires = {"cbochs/grapple.nvim"}
            --     }
            -- )
            -- ]]] === BetterQuickFix ===

            -- ============================ EasyAlign ============================= [[[
            use(
                {
                    "junegunn/vim-easy-align",
                    conf = "plugs.easy-align",
                    keys = {
                        {"n", "ga"},
                        {"x", "ga"},
                        {"x", "<Leader>ga"},
                        {"x", "<Leader>gi"},
                        {"x", "<Leader>gs"}
                    },
                    cmd = {"EasyAlign", "LiveEasyAlign"}
                }
            )
            -- ]]] === EasyAlign ===

            -- ============================ Open Browser =========================== [[[
            use({"tyru/open-browser.vim", conf = "open_browser"})
            use({"axieax/urlview.nvim", conf = "urlview", after = "telescope.nvim"})
            use({"xiyaowong/link-visitor.nvim", conf = "link_visitor"})
            -- use({"itchyny/vim-highlighturl"})
            -- ]]] === Open Browser ===

            -- ============================ Limelight ============================= [[[
            use(
                {
                    "folke/zen-mode.nvim",
                    cmd = "ZenMode",
                    keys = {{"n", "<Leader>zm"}},
                    {
                        "folke/twilight.nvim",
                        conf = "plugs.twilight",
                        after = "zen-mode.nvim",
                        cmd = "Twilight",
                        keys = {{"n", "<Leader>li"}, {"n", "<Leader>zm"}}
                    }
                }
            )
            -- ]]] === Limelight ===

            -- =============================== Marks ============================== [[[
            use({"chentoast/marks.nvim", conf = "plugs.marks"})
            -- ]]] === Marks ===

            -- ============================== HlsLens ============================= [[[
            use(
                {
                    "kevinhwang91/nvim-hlslens",
                    conf = "hlslens",
                    requires = {"haya14busa/vim-asterisk"},
                    wants = "nvim-scrollbar"
                    -- FIX: Lazy loading this doesn't work anymore
                    -- keys = {
                    --     {"n", "n"},
                    --     {"x", "n"},
                    --     {"o", "n"},
                    --     {"n", "N"},
                    --     {"x", "N"},
                    --     {"o", "N"},
                    --     {"n", "/"},
                    --     {"n", "?"},
                    --     {"n", "*"},
                    --     {"x", "*"},
                    --     {"n", "#"},
                    --     {"x", "#"},
                    --     {"n", "g*"},
                    --     {"x", "g*"},
                    --     {"n", "g#"},
                    --     {"x", "g#"}
                    -- }
                }
            )
            -- ]]] === HlsLens ===

            -- ============================ Scrollbar ============================= [[[
            use(
                {
                    "petertriho/nvim-scrollbar",
                    requires = "kevinhwang91/nvim-hlslens",
                    after = {colorscheme, "nvim-hlslens"},
                    event = "BufEnter",
                    conf = "plugs.scrollbar"
                }
            )

            -- use({"karb94/neoscroll.nvim", conf = "neoscroll", desc = "Smooth scrolling"})

            use(
                {
                    "edluffy/specs.nvim",
                    conf = "specs",
                    desc = "Keep an eye on where the cursor moves"
                }
            )
            -- ]]] === Scrollbar ===

            -- ============================== Grepper ============================= [[[
            use(
                {
                    "mhinz/vim-grepper",
                    cmd = {"Grepper", "GrepperRg"},
                    keys = {{"n", "gs"}, {"x", "gs"}, {"n", "<Leader>rg"}},
                    conf = "grepper"
                }
            )

            -- use({"nvim-pack/nvim-spectre"})
            -- ]]] === Grepper ===

            -- ============================ Trouble =============================== [[[
            use(
                {
                    "lmburns/trouble.nvim",
                    requires = {"kyazdani42/nvim-web-devicons", opt = true},
                    conf = "plugs.trouble"
                }
            )
            -- ]]] === Trouble ===

            -- =========================== Statusline ============================= [[[

            use({"b0o/incline.nvim", conf = "plugs.incline"})

            use(
                {
                    "nvim-lualine/lualine.nvim",
                    after = colorscheme,
                    requires = {"kyazdani42/nvim-web-devicons", opt = true},
                    conf = "plugs.lualine"
                }
            )

            use(
                {
                    "lmburns/nvim-gps",
                    requires = {"nvim-treesitter/nvim-treesitter"},
                    after = "nvim-treesitter"
                }
            )

            use(
                {
                    "akinsho/bufferline.nvim",
                    after = {colorscheme, "lualine.nvim"},
                    conf = "plugs.bufferline",
                    requires = "kazhala/close-buffers.nvim"
                    -- requires = "famiu/bufdelete.nvim"
                }
            )

            -- ]]] === Statusline ===

            -- =========================== Indentline ============================= [[[
            use({"lukas-reineke/indent-blankline.nvim", conf = "plugs.indent_blankline"})
            -- ]]] === Indentline ===

            -- use(
            --     {
            --         "folke/noice.nvim",
            --         conf = "plugs.noice",
            --         wants = {"nui.nvim", "nvim-notify"},
            --         requires = {
            --             {"MunifTanjim/nui.nvim", module = "nui"},
            --             "rcarriga/nvim-notify"
            --         },
            --         event = {"UIEnter"}
            --     }
            -- )

            -- Eandrju/cellular-automaton.nvim
            -- tamton-aquib/zone.nvim
            -- use(
            --     {
            --         "folke/drop.nvim",
            --         event = "VimEnter",
            --         config = function()
            --             math.randomseed(os.time())
            --             local theme = ({"stars", "snow"})[math.random(1, 2)]
            --             require("drop").setup({theme = theme})
            --         end
            --     }
            -- )

            use({"nullchilly/fsread.nvim", conf = "fsread", cmd = {"FSRead"}})

            -- =============================== Fzf ================================ [[[
            use(
                {
                    "junegunn/fzf.vim",
                    requires = {{"junegunn/fzf", run = "./install --bin"}},
                    conf = "plugs.fzf"
                }
            )

            use(
                {
                    "ibhagwan/fzf-lua",
                    requires = {"kyazdani42/nvim-web-devicons"},
                    conf = "plugs.fzf-lua"
                }
            )
            -- ]]] === Fzf ===

            -- ============================= Operator ============================== [[[
            use({"wellle/targets.vim", conf = "targets"})
            use({"andymass/vim-matchup", conf = "matchup"})

            -- bennypowers/splitjoin.nvim
            -- "AckslD/nvim-trevJ.lua"
            use(
                {
                    "aarondiel/spread.nvim",
                    conf = "spread",
                    keys = {{"n", "gJ"}, {"n", "gS"}},
                    requires = "nvim-treesitter/nvim-treesitter"
                }
            )

            use(
                {
                    "phaazon/hop.nvim",
                    conf = "plugs.hop",
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
                        {"n", "<Leader><Leader>/"},
                        {"n", "<Leader><Leader>o"},
                        {"n", "<C-S-:>"},
                        {"n", "<C-S-<>"}
                    }
                }
            )

            use(
                {
                    "gbprod/substitute.nvim",
                    conf = "plugs.substitute"
                    -- keys = {
                    --     {"n", "s"},
                    --     {"n", "ss"},
                    --     {"n", "se"},
                    --     {"n", "sr"},
                    --     {"n", "s;"},
                    --     {"n", "<Leader>sr"},
                    --     {"n", "sS"},
                    --     {"n", "sx"},
                    --     {"n", "sxx"},
                    --     {"n", "sxc"},
                    --     {"x", "s"},
                    --     {"x", "X"}
                    -- }
                }
            )

            use({"machakann/vim-sandwich", conf = "sandwhich"})

            -- use({"anuvyklack/pretty-fold.nvim", requires = "anuvyklack/nvim-keymap-amend"})
            -- use({"Raimondi/delimitMate", event = "InsertEnter", conf = "delimitmate"})
            use({"kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async"})

            use(
                {
                    "windwp/nvim-autopairs",
                    wants = "nvim-treesitter",
                    conf = "plugs.autopairs",
                    event = "InsertEnter"
                }
            )

            use(
                {
                    "sQVe/sort.nvim",
                    conf = "sort",
                    cmd = {"Sort"},
                    keys = {{"n", "gW"}, {"x", "gW"}, {"v", "gW"}}
                }
            )

            use(
                {
                    "monaqa/dial.nvim",
                    conf = "plugs.dial"
                    -- keys = {
                    --     {"n", "+"},
                    --     {"n", "_"},
                    --     {"v", "+"},
                    --     {"v", "_"},
                    --     {"v", "g+"},
                    --     {"v", "g_"}
                    -- }
                }
            )
            -- ]]] === Operator ===

            -- =============================== Tags =============================== [[[
            use({"ludovicchabant/vim-gutentags", conf = "plugs.gutentags"})
            use({"liuchengxu/vista.vim", after = "vim-gutentags", conf = "plugs.vista"})

            -- use(
            --     {
            --         prefer_local("symbols-outline.nvim"),
            --         -- cmd = {"SymbolsOutline", "SymbolsOutlineOpen"},
            --         -- keys = {{"n", '<A-S-">'}},
            --         -- setup = [[require('plugs.config').outline()]],
            --         conf = "outline"
            --     }
            -- )
            -- ]]] === Tags ===

            -- ============================= UndoTree ============================= [[[
            use(
                {
                    "mbbill/undotree",
                    conf = "plugs.undotree",
                    cmd = "UndoTreeToggle",
                    keys = {{"n", "<Leader>ut"}}
                }
            )

            use(
                {
                    "kevinhwang91/nvim-fundo",
                    requires = "kevinhwang91/promise-async",
                    conf = "fundo",
                    -- run = [[require("fundo").install()]]
                    run = function()
                        require("fundo").install()
                    end
                }
            )
            -- ]]] === UndoTree ===

            -- ============================ Commenter ============================= [[[
            use(
                {
                    "numToStr/Comment.nvim",
                    conf = "plugs.comment",
                    after = "nvim-treesitter",
                    requires = "nvim-treesitter/nvim-treesitter"
                }
            )
            use({"LudoPinelli/comment-box.nvim", conf = "comment_box"})
            -- ]]] === Commenter ===

            -- =============================== Python ============================== [[[
            use({"jpalardy/vim-slime", ft = "python", conf = "slime"})
            -- ]]] === Python ===

            -- ============================= Javascript ============================ [[[
            -- use({"editorconfig/editorconfig-vim", conf = "plugs.editorconf"})
            use(
                {
                    "axelvc/template-string.nvim",
                    conf = "template_string",
                    requires = "nvim-treesitter/nvim-treesitter"
                }
            )
            use(
                {
                    "vuki656/package-info.nvim",
                    requires = {"MunifTanjim/nui.nvim", module = "nui"},
                    event = "BufRead package.json",
                    conf = "package_info"
                }
            )
            -- ]]] === Javascript ===

            -- ============================== Markdown ============================= [[[
            use(
                {
                    "plasticboy/vim-markdown",
                    ft = {"markdown", "vimwiki"},
                    conf = "plugs.markdown.markdown"
                }
            )
            use({"dhruvasagar/vim-table-mode", conf = "plugs.markdown.table_mode"})
            use(
                {
                    "SidOfc/mkdx",
                    config = [[vim.cmd("source ~/.config/nvim/vimscript/plugins/mkdx.vim")]]
                }
            )

            use(
                {
                    "vimwiki/vimwiki",
                    -- After this commit `\` or **\** are no longer highlighted
                    commit = "63af6e72",
                    setup = [[require("plugs.markdown").vimwiki_setup()]],
                    ft = {"markdown", "vimwiki"},
                    conf = "plugs.markdown.vimwiki",
                    after = colorscheme
                }
            )

            use(
                {
                    "FraserLee/ScratchPad",
                    conf = "scratchpad",
                    keys = {{"n", "<Leader>sc"}},
                    cmd = "ScratchPad"
                }
            )
            -- ]]] === Markdown ===

            -- ================================ Wilder ============================= [[[
            use(
                {
                    "gelguy/wilder.nvim",
                    run = ":UpdateRemotePlugins",
                    requires = "romgrk/fzy-lua-native",
                    conf = "plugs.wilder"
                }
            )
            -- ]]] === Wilder ===

            -- ========================= Syntax-Highlighting ======================= [[[
            use(
                {
                    "sheerun/vim-polyglot",
                    setup = function()
                        vim.g.polyglot_disabled = {
                            "ftdetect",
                            -- "sensible",
                            -- "markdown",
                            "rustpeg",
                            "lf",
                            "ron",
                            "cmake",
                            "css",
                            "cpp",
                            "d",
                            "dart",
                            "dockerfile",
                            "go",
                            "gomod",
                            "html",
                            "ini",
                            "java",
                            "julia",
                            -- "lua",
                            -- "json",
                            -- "kotlin",
                            -- "lua",
                            "make",
                            -- "perl",
                            -- "python",
                            "query",
                            -- "ruby",
                            "rust",
                            "scss",
                            -- "vim",
                            -- "solidity",
                            "teal",
                            "tsx",
                            "typescript",
                            "zig"
                        }
                    end
                }
            )

            -- use({"wfxr/dockerfile.vim"})
            -- use({"thesis/vim-solidity"})
            -- use({"tmux-plugins/vim-tmux", event = "BufRead tmux.conf"})
            use({"rhysd/vim-rustpeg", ft = "rustpeg"})
            use({"nastevens/vim-cargo-make"})
            use({"NoahTheDuke/vim-just", ft = "just"})
            use({"camnw/lf-vim", ft = "lf"})
            use({"ron-rs/ron.vim", ft = "ron"})
            -- ]]] === Syntax-Highlighting ===

            -- ============================= File-Viewer =========================== [[[
            use({"mattn/vim-xxdcursor"})
            use({"jamessan/vim-gnupg"})
            use(
                {
                    "fidian/hexmode",
                    config = [[vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe']]
                }
            )
            use(
                {
                    "https://gitlab.com/itaranto/id3.nvim",
                    tag = "*",
                    config = function()
                        require("id3").setup(
                            {
                                mp3_tool = "id3",
                                flac_tool = "metaflac"
                            }
                        )
                    end
                }
            )
            use({"alx741/vinfo", cmd = {"Vinfo", "VinfoClean", "VinfoNext", "VinfoPrevious"}})
            use({"HiPhish/info.vim", cmd = "Info"})
            -- ]]] === File Viewer ===

            -- ============================== Snippets ============================= [[[
            use({"SirVer/ultisnips", conf = "ultisnips"})
            use({"honza/vim-snippets"})
            -- ]]] === Snippets ===

            -- ============================= Highlight ============================ [[[
            use({"NvChad/nvim-colorizer.lua", conf = "colorizer"})

            use(
                {
                    "folke/todo-comments.nvim",
                    conf = "plugs.todo-comments",
                    wants = "plenary.nvim",
                    after = "telescope.nvim"
                }
            )

            -- use(
            --     {
            --         "folke/paint.nvim",
            --         event = "BufReadPre",
            --         conf = "plugs.paint"
            --     }
            -- )

            use(
                {
                    "KabbAmine/vCoolor.vim",
                    keys = {
                        {"n", "<Leader>pc"},
                        {"n", "<Leader>yb"},
                        {"n", "<Leader>yr"}
                    },
                    setup = [[vim.g.vcoolor_disable_mappings = 1 vim.g.vcoolor_lowercase = 1]],
                    conf = "vcoolor"
                }
            )

            -- ]]] === Highlight ===

            -- ============================= Neoformat ============================= [[[
            use({"sbdchd/neoformat", conf = "plugs.format"})
            use({"kdheepak/JuliaFormatter.vim", ft = "julia"})
            -- ]]] === Neoformat ===

            -- ╭──────────────────────────────────────────────────────────╮
            -- │                           Coc                            │
            -- ╰──────────────────────────────────────────────────────────╯

            use({"rust-lang/rust.vim", ft = "rust", conf = "plugs.rust"})
            use({"Saecki/crates.nvim", event = "BufRead Cargo.toml", conf = "plugs.rust.crates"})

            -- use({ 'tjdevries/coc-zsh', ft = "zsh" })
            -- use({ 'ThePrimeagen/refactoring.nvim', opt = true })
            -- use({"rescript-lang/vim-rescript"})
            -- use({"vim-crystal/vim-crystal", ft = "crystal"})

            -- use({"jalvesaq/Nvim-R", ft = {"r"}, branch = "stable", conf = "plugs.nvim-r"})
            use({"lervag/vimtex", conf = "plugs.vimtex"})
            use({"fatih/vim-go", ft = "go", conf = "plugs.go"})
            use({"jlcrochet/vim-crystal", ft = "crystal"})
            use({"vim-perl/vim-perl", ft = "perl"})
            use({"teal-language/vim-teal", ft = "teal"})
            use({"ziglang/zig.vim", ft = "zig", config = [[vim.g.zig_fmt_autosave = 0]]})

            use(
                {
                    "neoclide/coc.nvim",
                    branch = "master",
                    run = "yarn install --frozen-lockfile",
                    config = [[require('plugs.coc').tag_cmd()]],
                    requires = {
                        -- {"xiyaowong/coc-wxy", after = "coc.nvim", run = "yarn install --frozen-lockfile"},
                        {"antoinemadec/coc-fzf", after = "coc.nvim"},
                        {prefer_local("coc-code-action-menu"), after = "coc.nvim"},
                        {"kevinhwang91/coc-kvs", after = "coc.nvim", run = "yarn install"}
                    }
                }
            )

            -- ╭──────────────────────────────────────────────────────────╮
            -- │                        Treesitter                        │
            -- ╰──────────────────────────────────────────────────────────╯

            -- chrisgrieser/nvim-various-textobjs
            use(
                {
                    "mizlan/iswap.nvim",
                    requires = "nvim-treesitter/nvim-treesitter",
                    after = "nvim-treesitter"
                }
            )
            use({"cshuaimin/ssr.nvim", requires = "nvim-treesitter/nvim-treesitter", after = "nvim-treesitter" })
            use(
                {
                    -- conf = "plugs.treesitter"
                    -- commit = "2a63ea56",
                    "nvim-treesitter/nvim-treesitter",
                    run = ":TSUpdate",
                    requires = {
                        {
                            "nvim-treesitter/nvim-treesitter-refactor",
                            patch = true,
                            after = "nvim-treesitter",
                            desc = "Refactor module"
                        },
                        {
                            "RRethy/nvim-treesitter-endwise",
                            desc = "Adds 'end' to ruby and lua",
                            after = "nvim-treesitter"
                        },
                        {
                            "nvim-treesitter/nvim-treesitter-textobjects",
                            after = "nvim-treesitter"
                        },
                        {
                            "nvim-treesitter/playground",
                            after = "nvim-treesitter"
                        },
                        {
                            "windwp/nvim-ts-autotag",
                            desc = "Html/CSS/JSX tagging",
                            after = "nvim-treesitter"
                        },
                        {
                            "michaeljsmith/vim-indent-object",
                            desc = "ai ii aI iI text objects",
                            after = "nvim-treesitter"
                        },
                        {
                            "nvim-treesitter/nvim-treesitter-context",
                            desc = "Ability to see current context on top line",
                            after = "nvim-treesitter"
                        },
                        {
                            "haringsrob/nvim_context_vt",
                            desc = "Adds -> context messages",
                            after = "nvim-treesitter"
                        },
                        {
                            "JoosepAlviste/nvim-ts-context-commentstring",
                            desc = "Embedded language comment strings",
                            after = "nvim-treesitter"
                        },
                        {
                            "David-Kunz/treesitter-unit",
                            desc = "Adds unit text object",
                            after = "nvim-treesitter"
                        },
                        {
                            -- "m-demare/hlargs.nvim",
                            "lmburns/hlargs.nvim",
                            desc = "Highlight argument definitions",
                            after = "nvim-treesitter"
                        },
                        {
                            "stevearc/aerial.nvim",
                            requires = "nvim-treesitter/nvim-treesitter"
                        },
                        {
                            "danymat/neogen",
                            desc = "Code documentation generator",
                            conf = "neogen",
                            after = "nvim-treesitter",
                            cmd = "Neogen",
                            keys = {
                                {"n", "<Leader>dg"},
                                {"n", "<Leader>df"},
                                {"n", "<Leader>dc"}
                            }
                        },
                        {
                            "mrjones2014/nvim-ts-rainbow",
                            desc = "Rainbow parenthesis using treesitter",
                            after = "nvim-treesitter"
                        },
                        {
                            -- "max397574/nvim-treehopper",
                            "mfussenegger/nvim-treehopper",
                            desc = "Region selection with hints on the AST nodes",
                            after = "nvim-treesitter",
                            requires = "nvim-treesitter/nvim-treesitter"
                        },
                        {
                            "ziontee113/syntax-tree-surfer",
                            desc = "Surf through your document and move elements around",
                            after = "nvim-treesitter"
                        },
                        -- {
                        --     "ziontee113/query-secretary",
                        --     desc = "Help create treesitter queries",
                        --     after = "nvim-treesitter"
                        -- },
                        {
                            "vigoux/architext.nvim",
                            desc = "Create treesitter queries",
                            -- cmd = {"Architext", "ArchitextREPL"},
                            after = "nvim-treesitter"
                        }
                    }
                }
            )

            -- ╭──────────────────────────────────────────────────────────╮
            -- │                        Telescope                         │
            -- ╰──────────────────────────────────────────────────────────╯

            use(
                {
                    "nvim-telescope/telescope.nvim",
                    opt = false,
                    conf = "plugs.telescope",
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
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("file_browser")]]
                        },
                        {
                            "nvim-telescope/telescope-hop.nvim",
                            after = "telescope.nvim",
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
                                local path = Path:new(dirs.data .. "/databases/")
                                if not path:exists() then
                                    path:mkdir()
                                end
                            end
                        },
                        {
                            "jvgrootveld/telescope-zoxide",
                            after = "telescope.nvim",
                            requires = "nvim-telescope/telescope.nvim",
                            config = [[require("telescope").load_extension("zoxide")]]
                        },
                        {
                            prefer_local("telescope-rualdi.nvim"),
                            after = "telescope.nvim",
                            config = [[require("telescope").load_extension("rualdi")]]
                        }
                        -- {
                        --     "debugloop/telescope-undo.nvim",
                        --     after = "telescope.nvim",
                        --     config = [[require("telescope").load_extension("undo")]]
                        -- },
                        -- {
                        --     "nvim-telescope/telescope-ui-select.nvim",
                        --     after = {"telescope.nvim"},
                        --     config = [[require("telescope").load_extension("ui-select")]]
                        -- },
                    }
                }
            )

            -- gbprod/yanky.nvim
            use(
                {
                    "AckslD/nvim-neoclip.lua",
                    requires = {"nvim-telescope/telescope.nvim", "tami5/sqlite.lua"},
                    after = {"telescope.nvim", "sqlite.lua"}
                    -- conf = "plugs.neoclip"
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
                    event = "VimEnter",
                    wants = {"telescope.nvim", "packer.nvim"},
                    -- config = [[require("telescope").load_extension("packer")]],
                    config = function()
                        require("telescope.builtin").packer = function(opts)
                            require("plugins").loader("packer.nvim")
                            opts = opts or {}
                            opts.previewer = false
                            require("telescope").load_extension("packer")
                            require("telescope").extensions.packer.packer(opts)
                        end
                    end
                }
            )

            -- ╭──────────────────────────────────────────────────────────╮
            -- │                           Git                            │
            -- ╰──────────────────────────────────────────────────────────╯
            -- For some reason, if this is lazy-loaded, an error occurs when pressing keybinding
            use(
                {
                    "tpope/vim-fugitive",
                    conf = "plugs.fugitive",
                    -- fn = {"fugitive#*", "Fugitive*"},
                    -- event = "BufReadPre */.git/index",
                    -- cmd = {
                    --     "0Git",
                    --     "G",
                    --     "GBrowse",
                    --     "Gcd",
                    --     "Gclog",
                    --     "GDelete",
                    --     "Gdiffsplit",
                    --     "Gedit",
                    --     "Ggrep",
                    --     "Ghdiffsplit",
                    --     "Git",
                    --     "Glcd",
                    --     "Glgrep",
                    --     "Gllog",
                    --     "GMove",
                    --     "Gpedit",
                    --     "Gread",
                    --     "GRemove",
                    --     "GRename",
                    --     "Gsplit",
                    --     "Gtabedit",
                    --     "GUnlink",
                    --     "Gvdiffsplit",
                    --     "Gvsplit",
                    --     "Gwq",
                    --     "Gwrite"
                    -- },
                    -- keys = {
                    --     {"n", "<LocalLeader>gg"},
                    --     {"n", "<LocalLeader>ge"},
                    --     {"n", "<LocalLeader>gR"},
                    --     {"n", "<LocalLeader>gB"},
                    --     {"n", "<LocalLeader>gw"},
                    --     {"n", "<LocalLeader>gW"},
                    --     {"n", "<LocalLeader>gr"},
                    --     {"n", "<LocalLeader>gf"},
                    --     {"n", "<LocalLeader>gF"},
                    --     {"n", "<LocalLeader>gc"},
                    --     {"n", "<LocalLeader>gC"},
                    --     {"n", "<LocalLeader>gd"},
                    --     {"n", "<LocalLeader>gt"}
                    -- },
                    requires = {"tpope/vim-rhubarb"}
                }
            )

            use(
                {
                    "rbong/vim-flog",
                    cmd = {"Flog", "Flogsplit"},
                    keys = {
                        {"n", "<Leader>gl"},
                        {"n", "<Leader>gi"}
                    },
                    wants = "vim-fugitive",
                    requires = "tpope/vim-fugitive",
                    conf = "plugs.flog"
                }
            )

            use({"ahmedkhalf/project.nvim", conf = "project", after = "telescope.nvim"})
            use({"akinsho/git-conflict.nvim", conf = "git_conflict"})
            use({"kdheepak/lazygit.nvim", conf = "lazygit", after = "telescope.nvim"})

            use(
                {
                    "lewis6991/gitsigns.nvim",
                    conf = "plugs.gitsigns",
                    requires = {"nvim-lua/plenary.nvim"},
                    wants = "nvim-scrollbar"
                }
            )
            use(
                {
                    "TimUntersberger/neogit",
                    conf = "plugs.neogit",
                    requires = {"nvim-lua/plenary.nvim"}
                }
            )

            use(
                {
                    "ruanyl/vim-gh-line",
                    keys = {
                        {"n", "<Leader>go"},
                        {"n", "<Leader>gL"}
                    },
                    setup = [[vim.g.gh_line_blame_map_default = 0]],
                    conf = "ghline"
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
                    conf = "plugs.diffview",
                    keys = {
                        {"n", "<Leader>g;"},
                        {"n", "<Leader>g."},
                        {"n", "<Leader>gh"}
                    }
                }
            )

            -- use(
            --     {
            --         "ldelossa/gh.nvim",
            --         requires = {"ldelossa/litee.nvim"},
            --         conf = "plugs.gh"
            --     }
            -- )

            -- ╭──────────────────────────────────────────────────────────╮
            -- │                          Fennel                          │
            -- ╰──────────────────────────────────────────────────────────╯
            use(
                {
                    "rktjmp/paperplanes.nvim",
                    requires = "rktjmp/hotpot.nvim",
                    conf = "paperplanes",
                    cmd = "PP"
                }
            )

            -- use(
            --     {
            --         ("%s/%s"):format(dirs.config, "lua/plugs/nvim-reload"),
            --         conf = "plugs.nvim-reload",
            --         opt = true
            --     }
            -- )

            --  ╭──────────────────────────────────────────────────────────╮
            --  │                          Notify                          │
            --  ╰──────────────────────────────────────────────────────────╯

            use(
                {
                    "rcarriga/nvim-notify",
                    conf = "plugs.notify",
                    after = {colorscheme, "telescope.nvim"}
                }
            )
            use(
                {
                    "simrat39/desktop-notify.nvim",
                    setup = [[pcall(vim.cmd, 'delcommand Notifications')]],
                    config = [[vim.cmd('command! Notifications :lua require("notify")._print_history()<CR>')]]
                }
            )
        end
    }
)
