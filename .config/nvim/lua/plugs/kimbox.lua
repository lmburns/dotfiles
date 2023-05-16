---@module 'plugs.kimbox'
local M = {}

local D = require("dev")
-- local hl = require("common.color")

local cmd = vim.cmd
local g = vim.g
local uv = vim.loop

-- === Kimbox ===
M.kimbox = function()
    cmd.packadd("kimbox")
    local kimbox = D.npcall(require, "kimbox")
    if not kimbox then
        return
    end

    kimbox.setup({
        style = "cannon",
        langs08 = true,
        allow_bold = true,
        allow_italic = false,
        allow_underline = false,
        allow_undercurl = false,
        allow_reverse = false,
        term_colors = true,
        popup = {
            background = false,     -- use background color for pmenu
        },
        toggle_style_key = "<Leader>tS",
        toggle_style_list = require("kimbox").KimboxBgColors,
    })
    -- require("kimbox").load()
end

-- === Kanagawa ===
M.kanagawa = function()
    local kanagawa = D.npcall(require, "kanagawa")
    if not kanagawa then
        return
    end

    kanagawa.setup(
        {
            theme = "wave", -- "dragon"
            compile = false,
            undercurl = false,
            commentStyle = {italic = false},
            functionStyle = {bold = true, italic = false},
            keywordStyle = {bold = false, italic = false},
            statementStyle = {bold = false, italic = false},
            typeStyle = {bold = true, italic = false},
            variablebuiltinStyle = {italic = false},
            specialReturn = true,    -- special highlight for the return keyword
            specialException = true, -- special highlight for exception handling keywords
            transparent = false,     -- do not set background color
            dimInactive = true,      -- dim inactive window `:h hl-NormalNC`
            globalStatus = true,     -- adjust window separators highlight for laststatus=3
            colors = {
                palette = {},
                theme = {wave = {}, lotus = {}, dragon = {}, all = {ui = {bg_gutter = "none"}}},
            },
            overrides = function(colors)
                local c = colors.palette
                local bg = c.sumiInk1
                local abg = c.sumiInk4
                return {
                    BufferLineFill = {bg = bg},
                    BufferLineBackground = {fg = c.fujiWhite, bg = bg},
                    -- BufferLineDevIcon = {bg = bg},
                    -- BufferLineDevIconSelected = {bg = abg},
                    --
                    BufferLineCloseButton = {fg = c.waveRed, bg = bg},
                    BufferLineCloseButtonSelected = {fg = c.peachRed, bg = abg},
                    BufferLineCloseButtonVisible = {bg = bg},
                    --
                    BufferLineNumbers = {fg = c.springGreen, bg = bg, bold = true},
                    BufferLineNumbersSelected = {
                        fg = c.oniViolet,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineNumbersVisible = {fg = c.springGreen, bg = abg, bold = true},
                    --
                    BufferLineSeparator = {fg = bg, bg = bg},
                    BufferLineSeparatorSelected = {fg = bg, bg = abg},
                    BufferLineSeparatorVisible = {fg = bg, bg = abg},
                    BufferLineOffsetSeparator = {fg = c.peachRed, bg = bg},
                    --
                    BufferLineTabSeparator = {fg = bg, bg = bg},
                    BufferLineTabSeparatorSelected = {fg = bg, bg = abg},
                    --
                    BufferLineTab = {fg = c.fujiWhite, bg = c.bg},
                    BufferLineTabSelected = {fg = c.fujiWhite, bg = abg, bold = true},
                    BufferLineTabClose = {fg = c.waveRed},
                    --
                    BufferLineBuffer = {fg = c.fujiWhite, bg = c.bg, bold = true},
                    BufferLineBufferSelected = {
                        fg = c.fujiWhite,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineBufferVisible = {fg = c.fujiGray, bg = abg},
                    --
                    BufferLineIndicatorSelected = {fg = c.samuraiRed, bg = abg, bold = true},
                    BufferLineIndicatorVisible = {fg = c.samuraiRed, bg = abg, bold = true},
                    --
                    BufferLinePick = {fg = c.oniViolet, bg = bg, bold = true, italic = false},
                    BufferLinePickSelected = {
                        fg = c.sakuraPink,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLinePickVisible = {fg = c.oniViolet, bg = abg, bold = true, italic = false},
                    --
                    BufferLineModified = {fg = c.lotusRed, bg = bg},
                    BufferLineModifiedSelected = {fg = c.lotusRed, bg = abg},
                    BufferLineModifiedVisible = {fg = c.lotusRed, bg = abg},
                    --
                    BufferLineDuplicate = {fg = c.dragonPink, bg = bg, italic = false},
                    BufferLineDuplicateSelected = {
                        fg = c.dragonPink,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineDuplicateVisible = {fg = c.dragonPink, bg = abg, italic = false},
                    --
                    BufferLineDiagnostic = {fg = c.lotusPink, bg = bg},
                    BufferLineDiagnosticSelected = {
                        fg = c.lotusPink,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineDiagnosticVisible = {fg = c.lotusPink, bg = abg},
                    --
                    BufferLineHint = {fg = c.dragonYellow, bg = bg},
                    BufferLineHintSelected = {
                        fg = c.dragonPink,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineHintVisible = {fg = c.dragonYellow, bg = abg},
                    BufferLineHintDiagnostic = {fg = c.dragonPink, bg = bg},
                    BufferLineHintDiagnosticSelected = {
                        fg = c.dragonPink,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineHintDiagnosticVisible = {fg = c.dragonPink, bg = abg},
                    --
                    BufferLineInfo = {fg = c.dragonYellow, bg = bg},
                    BufferLineInfoSelected = {
                        fg = c.lotusTeal1,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineInfoVisible = {fg = c.dragonYellow, bg = abg},
                    BufferLineInfoDiagnostic = {fg = c.lotusTeal1, bg = bg},
                    BufferLineInfoDiagnosticSelected = {
                        fg = c.lotusTeal1,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineInfoDiagnosticVisible = {fg = c.lotusTeal1, bg = abg},
                    --
                    BufferLineWarning = {fg = c.dragonYellow, bg = bg},
                    BufferLineWarningSelected = {
                        fg = c.surimiOrange,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineWarningVisible = {fg = c.dragonYellow, bg = abg},
                    BufferLineWarningDiagnostic = {fg = c.surimiOrange, bg = bg},
                    BufferLineWarningDiagnosticSelected = {
                        fg = c.surimiOrange,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineWarningDiagnosticVisible = {fg = c.surimiOrange, bg = abg},
                    --
                    BufferLineError = {fg = c.dragonYellow, bg = bg},
                    BufferLineErrorSelected = {fg = c.peachRed, bg = abg, bold = true, italic = false},
                    BufferLineErrorVisible = {fg = c.dragonYellow, bg = abg},
                    BufferLineErrorDiagnostic = {fg = c.peachRed, bg = bg},
                    BufferLineErrorDiagnosticSelected = {
                        fg = c.peachRed,
                        bg = abg,
                        bold = true,
                        italic = false,
                    },
                    BufferLineErrorDiagnosticVisible = {fg = c.peachRed, bg = abg},
                    --
                    -- ["@function"] = {fg = c.waveRed, bold = true},
                    ["@keyword.operator"] = {fg = c.sakuraPink, bold = false},
                    ["@keyword.return"] = {bold = true},
                    ["@boolean"] = {fg = c.surimiOrange, bold = false},
                    ["@constant"] = {fg = c.surimiOrange, bold = true},
                    ["@constructor"] = {fg = c.sakuraPink, bold = true},
                    ["@property"] = {fg = c.carpYellow, bold = false},
                    ["@property.tsx"] = {fg = c.carpYellow, bold = false},
                    ["@property.typescript"] = {fg = c.carpYellow, bold = false},
                    ["@parameter"] = {fg = c.springGreen},
                    CocHighlightText = {bg = c.sumiInk4},
                    -- Visual = {bg = c.katanaGray, bold = false},
                    FloatBorder = {fg = c.sakuraPink, bold = true},
                    TelescopeTitle = {fg = c.springGreen, bold = true},
                    TelescopePromptBorder = {fg = c.lotusViolet1},
                    TelescopeResultsBorder = {fg = c.lotusViolet1},
                    TelescopePreviewBorder = {fg = c.lotusViolet1},
                    CocErrorHighlight = {fg = "none", sp = c.peachRed, underline = false},
                    CocWarningHighlight = {fg = "none", sp = c.carpYellow, underline = false},
                    CocInfoHighlight = {fg = "none", sp = c.crystalBlue, underline = false},
                    CocHintHighlight = {fg = "none", sp = c.waveAqua2, underline = false},
                }
            end,
        }
    )

    -- cmd [[colorscheme kanagawa]]
end

-- === catppuccin ===
M.catppuccin = function()
    local catppuccin = D.npcall(require, "catppuccin")
    if not catppuccin then
        return
    end

    local cp = require("catppuccin.palettes").get_palette()

    catppuccin.setup(
        {
            flavour = "mocha", -- frappe, macchiato, mocha
            background = {
                light = "mocha",
                dark = "mocha",
            },
            transparent_background = false,
            term_colors = true,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
            styles = {
                comments = {"italic"},
                conditionals = {},
                loops = {},
                functions = {"bold"},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            integrations = {
                aerial = true,
                bufferline = true,
                coc_nvim = true,
                dap = {
                    enabled = true,
                    enable_ui = true,
                },
                gitsigns = true,
                hop = true,
                indent_blankline = {
                    enabled = true,
                    colored_indent_levels = false,
                },
                lsp_saga = true,
                lsp_trouble = true,
                markdown = true,
                neogit = true,
                neotest = true,
                noice = true,
                notify = true,
                overseer = true,
                semantic_tokens = true,
                symbols_outline = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                ts_rainbow = true,
                vimwiki = true,
                which_key = true,
            },
            color_overrides = {},
            custom_highlights = {
                ["@conditional"] = {fg = cp.red},
                ["@conditional.lua"] = {fg = cp.red},
                ["@conditional.rust"] = {fg = cp.red},
                ["@conditional.tsx"] = {fg = cp.red},
                ["@conditional.typescript"] = {fg = cp.red},
                ["@keyword.operator"] = {fg = cp.teal},
                ["@function"] = {fg = cp.maroon, style = {"bold"}},
                ["@function.lua"] = {fg = cp.maroon, style = {"bold"}},
                ["@function.rust"] = {fg = cp.maroon, style = {"bold"}},
                ["@function.tsx"] = {fg = cp.maroon, style = {"bold"}},
                ["@function.typescript"] = {fg = cp.maroon, style = {"bold"}},
                ["@method"] = {fg = cp.maroon, style = {"bold"}},
                ["@method.lua"] = {fg = cp.maroon, style = {"bold"}},
                ["@method.rust"] = {fg = cp.maroon, style = {"bold"}},
                ["@method.tsx"] = {fg = cp.maroon, style = {"bold"}},
                ["@method.typescript"] = {fg = cp.maroon, style = {"bold"}},
            },
        }
    )

    -- cmd [[colorscheme catppuccin]]
end

-- === Nightfox ===
M.nightfox = function()
    local nightfox = D.npcall(require, "nightfox")
    if not nightfox then
        return
    end

    nightfox.setup(
        {
            options = {
                compile_path = lb.dirs.cache .. "/nightfox",
                compile_file_suffix = "_compiled", -- Compiled file suffix
                transparent = false,               -- Disable setting background
                terminal_colors = true,            -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
                dim_inactive = false,              -- Non focused panes set to alternative background
                styles = {
                    -- Style to be applied to different syntax groups
                    comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
                    conditionals = "NONE",
                    constants = "NONE",
                    functions = "bold",
                    keywords = "NONE",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                    variables = "NONE",
                },
                inverse = {
                    -- Inverse highlight for different types
                    match_paren = true,
                    visual = false,
                    search = false,
                },
                modules = {
                    aerial = true,
                    diagnostic = true,
                    fidget = true,
                    gitsigns = true,
                    hop = true,
                    lsp_saga = true,
                    lsp_trouble = true,
                    neogit = true,
                    notify = true,
                    symbol_outline = true,
                    telescope = true,
                    treesitter = true,
                    tsrainbow = true,
                    whichkey = true,
                },
            },
        }
    )

    -- nordfox duskfox terafxo
    -- cmd [[colorscheme nightfox]]
end

-- === Meliora ===
M.meliora = function()
    local meliora = D.npcall(require, "meliora")
    if not meliora then
        return
    end

    meliora.setup({
        dim_inactive = false,
        styles = {
            comments = "italic",
            conditionals = "NONE",
            folds = "NONE",
            loops = "NONE",
            functions = "bold",
            keywords = "NONE",
            strings = "NONE",
            variables = "NONE",
            numbers = "NONE",
            booleans = "NONE",
            properties = "NONE",
            types = "NONE",
            operators = "NONE",
        },
        transparent_background = {
            enabled = false,
            floating_windows = false,
            telescope = false,
            file_tree = true,
            cursor_line = true,
            status_line = false,
        },
        plugins = {
            cmp = true,
            indent_blankline = true,
            nvim_tree = {
                enabled = true,
                show_root = false,
            },
            telescope = {
                enabled = true,
                nvchad_like = true,
            },
            startify = true,
        },
    })
end

-- === Gruvbox ===
M.gruvbox = function()
    -- g.gruvbox_material_background = "medium"
    g.gruvbox_material_background = "hard"
    g.gruvbox_material_palette = "mix"
    g.gruvbox_material_palette = "material"
    g.gruvbox_material_enable_bold = 1
    g.gruvbox_material_disable_italic_comment = 1
    g.gruvbox_material_current_word = "grey background"
    g.gruvbox_material_visual = "grey background"
    g.gruvbox_material_cursor = "green"
    g.gruvbox_material_sign_column_background = "none"
    g.gruvbox_material_statusline_style = "mix"
    g.gruvbox_material_better_performance = 1
    g.gruvbox_material_diagnostic_text_highlight = 0
    g.gruvbox_material_diagnostic_line_highlight = 0
    g.gruvbox_material_diagnostic_virtual_text = "colored"

    -- cmd [[colorscheme gruvbox-material]]
end

-- === Gruvbox-Flat ===
M.gruvbox_flat = function()
    g.gruvbox_italic_functions = true
    g.gruvbox_sidebars = {"qf", "vista_kind", "terminal", "packer"}
end

-- === Oceanic ===
M.oceanic_material = function()
    g.oceanic_material_background = "ocean"
    -- g.oceanic_material_background = "deep"
    -- g.oceanic_material_background = "medium"
    -- g.oceanic_material_background = "darker"
    g.oceanic_material_allow_bold = 1
    g.oceanic_material_allow_italic = 0
    g.oceanic_material_allow_underline = 1

    -- cmd [[colorscheme oceanic_material]]
end

-- === TokyoDark ===
M.tokyodark = function()
    g.tokyodark_enable_italic_comment = false
    g.tokyodark_enable_italic = false
end

-- === Everforest ===
M.everforest = function()
    g.everforest_disable_italic_comment = 1
    g.everforest_background = "hard"
    g.everforest_enable_italic = 0
    g.everforest_enable_bold = 1
    g.everforest_sign_column_background = "none"
    g.everforest_better_performance = 1

    -- cmd [[colorscheme everforest]]
end

-- === Edge ===
M.edge = function()
    g.edge_style = "aura"
    g.edge_cursor = "blue"
    g.edge_sign_column_background = "none"
    g.edge_better_performance = 1

    -- cmd [[colorscheme edge]]
end

-- === Sonokai ===
M.sonokai = function()
    -- maia atlantis era
    -- g.sonokai_style = 'andromeda'
    g.sonokai_style = "shusia"
    g.sonokai_enable_italic = 1
    g.sonokai_disable_italic_comment = 1
    g.sonokai_cursor = "blue"
    g.sonokai_sign_column_background = "none"
    g.sonokai_better_performance = 1
    g.sonokai_diagnostic_text_highlight = 0

    -- cmd [[colorscheme sonokai]]
end

-- === Miramare ===
M.miramare = function()
    g.miramare_enable_bold = 1
    g.miramare_disable_italic_comment = 1
    g.miramare_cursor = "purple"
    g.miramare_current_word = "grey background"

    -- cmd [[colorscheme miramare]]
end

-- === Material ===
M.material = function()
    local material = D.npcall(require, "material")
    if not material then
        return
    end

    g.material_style = "deep ocean"
    -- g.material_style = "palenight"
    -- g.material_style = "darker"
    material.setup(
        {
            contrast = {
                sidebars = false,            -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
                floating_windows = false,    -- Enable contrast for floating windows
                line_numbers = false,        -- Enable contrast background for line numbers
                sign_column = false,         -- Enable contrast background for the sign column
                cursor_line = false,         -- Enable darker background for the cursor line
                non_current_windows = false, -- Enable darker background for non-current windows
                popup_menu = false,          -- Enable lighter background for the popup menu
            },
            italics = {
                comments = false,  -- Enable italic comments
                keywords = false,  -- Enable italic keywords
                functions = false, -- Enable italic functions
                strings = false,   -- Enable italic strings
                variables = false, -- Enable italic variables
            },
            contrast_filetypes = {
                -- Specify which filetypes get the contrasted (darker) background
                "terminal", -- Darker terminal background
                "packer",   -- Darker packer background
                "qf",       -- Darker qf list background
            },
            high_visibility = {
                lighter = false, -- Enable higher contrast text for lighter style
                darker = false,  -- Enable higher contrast text for darker style
            },
            disable = {
                borders = false,       -- Disable borders between verticaly split windows
                background = false,    -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
                term_colors = false,   -- Prevent the theme from setting terminal colors
                eob_lines = false,     -- Hide the end-of-buffer lines
            },
            lualine_style = "default", -- Lualine style ( can be 'stealth' or 'default' )
            async_loading = true,      -- Load parts of the theme asyncronously for faster startup (turned on by default)
            custom_highlights = {},    -- Overwrite highlights with your own
        }
    )
end

M.tokyonight = function()
    -- === Tokyo Night ===
    -- g.tokyonight_style = "storm" -- night day storm
    g.tokyonight_style = "night" -- night day storm
    g.tokyonight_italic_comments = false
    g.tokyonight_italic_keywords = false
    g.tokyonight_italic_functions = false
    g.tokyonight_sidebars = {"qf", "vista_kind", "terminal", "packer"}
    g.tokyonight_colors = {
        ["bg_dark"] = "#16161F",
        ["bg_popup"] = "#16161F",
        ["bg_statusline"] = "#16161F",
        ["bg_sidebar"] = "#16161F",
        ["bg_float"] = "#16161F",
    }
end

-- === OneNord ===
M.onenord = function()
    local onenord = D.npcall(require, "onenord")
    if not onenord then
        return
    end

    onenord.setup(
        {
            theme = "dark",         -- "dark" or "light". Alternatively, remove the option and set vim.o.background instead
            borders = true,         -- Split window borders
            fade_nc = false,        -- Fade non-current windows, making them more distinguishable
            styles = {
                comments = "NONE",  -- Style that is applied to comments: see `highlight-args` for options
                strings = "NONE",   -- Style that is applied to strings: see `highlight-args` for options
                keywords = "NONE",  -- Style that is applied to keywords: see `highlight-args` for options
                functions = "bold", -- Style that is applied to functions: see `highlight-args` for options
                variables = "NONE", -- Style that is applied to variables: see `highlight-args` for options
                diagnostics =
                "underline",        -- Style that is applied to diagnostics: see `highlight-args` for options
            },
            disable = {
                background = false, -- Disable setting the background color
                cursorline = false, -- Disable the cursorline
                eob_lines = true,   -- Hide the end-of-buffer lines
            },
            custom_highlights = {}, -- Overwrite default highlight groups
            custom_colors = {},     -- Overwrite default colors
        }
    )
end

-- === NightFly ===
M.nightfly = function()
    g.nightflyItalics = 0
end

-- === RosePine ===
M.rose_pine = function()
    local rose = D.npcall(require, "rose-pine")
    if not rose then
        return
    end

    rose.setup({
        --- 'main'|'moon'
        dark_variant = "main",
        bold_vert_split = true,
        dim_nc_background = false,
        disable_background = false,
        disable_float_background = false,
        disable_italics = true,
        ---@usage string hex value or named color from rosepinetheme.com/palette
        groups = {
            background = "base",
            panel = "surface",
            border = "highlight_med",
            comment = "muted",
            link = "iris",
            punctuation = "subtle",
            error = "love",
            hint = "iris",
            info = "foam",
            warn = "gold",
            headings = {
                h1 = "iris",
                h2 = "foam",
                h3 = "rose",
                h4 = "gold",
                h5 = "pine",
                h6 = "foam",
            },
            -- or set all headings at once
            -- headings = 'subtle'
        },
        -- Change specific vim highlight groups
        highlight_groups = {
            TSFunction = {gui = "bold"},
        },
    })
end

local function init()
    local colorscheme = cmd.colorscheme

    M.kimbox()
    M.kanagawa()

    M.catppuccin()
    M.tokyodark()

    M.rose_pine()
    M.edge()
    M.everforest()
    M.gruvbox()
    M.gruvbox_flat()
    M.meliora()
    -- M.material()
    -- M.miramare()
    -- M.nightfox()
    -- M.oceanic_material()
    -- M.nightfly()
    -- M.onenord()
    -- M.tokyonight()

    -- local theme = "jellybeans"
    -- local theme = "vscode"

    -- local theme = "iceberg"
    -- local theme = "gruvbox-material"
    -- local theme = "gruvbox-flat"
    -- local theme = "spaceduck"
    -- local theme = "everforest"
    -- local theme = "onenord"
    -- local theme = "material"
    -- local theme = "tokyodark"
    -- local theme = "night-owl"
    -- local theme = "rose-pine"
    -- local theme = "dusk-fox"
    -- local theme = "oceanic_material"
    -- local theme = "meliora"

    -- local theme = "tokyonight"
    -- local theme = "catppuccin"
    -- local theme = "tundra"
    -- local theme = "kanagawa"
    local theme = "kimbox"
    pcall(colorscheme, theme)

    -- if not pcall(colorscheme, theme) then
    --     if uv.fs_stat(("%s/%s/%s.lua"):format(lb.dirs.config, "lua/lush_theme", theme)) then
    --         require("plugs.lush").dump(theme)
    --     -- else
    --     --     log.err("theme file does not exist")
    --     end
    -- end
end

init()

return M
