local M = {}

-- General configurations for various themes

require("common.utils")

M.catppuccin = function()
  require("catppuccin").setup(
      {
        transparent_background = false,
        term_colors = false,
        styles = {
          comments = "italic",
          functions = "bold",
          keywords = "none",
          strings = "none",
          variables = "none",
        },
      }
  )

  -- cmd [[colorscheme catppuccin]]
end

M.kanagawa = function()
  require("kanagawa").setup(
      {
        undercurl = true, -- enable undercurls
        commentStyle = "italic",
        functionStyle = "bold",
        keywordStyle = "NONE",
        statementStyle = "NONE",
        typeStyle = "NONE",
        variablebuiltinStyle = "italic",
        specialReturn = true, -- special highlight for the return keyword
        specialException = true, -- special highlight for exception handling keywords
        transparent = false, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        globalStatus = false, -- adjust window separators highlight for laststatus=3
        colors = {},
        overrides = {},
      }
  )

  -- cmd [[colorscheme kanagawa]]
end

M.nightfox = function()
  require("nightfox").setup(
      {
        options = {
          -- Compiled file's destination location
          compile_path = fn.stdpath("cache") .. "/nightfox",
          compile_file_suffix = "_compiled", -- Compiled file suffix
          transparent = false, -- Disable setting background
          terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
          dim_inactive = false, -- Non focused panes set to alternative background
          styles = { -- Style to be applied to different syntax groups
            comments = "none", -- Value is any valid attr-list value `:help attr-list`
            functions = "bold",
            keywords = "bold",
            numbers = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
          },
          inverse = { -- Inverse highlight for different types
            match_paren = true,
            visual = false,
            search = false,
          },
          modules = { -- List of various plugins and additional options
            -- ...
          },
        },
      }
  )

  -- nordfox duskfox terafxo
  -- cmd [[colorscheme nightfox]]
end

-- === Gruvbox ===
M.gruvbox = function()
  g.gruvbox_material_background = "medium"
  -- g.gruvbox_material_background = "hard"
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

-- === Oceanic ===
M.ocean_material = function()
  g.oceanic_material_background = "ocean"
  -- g.oceanic_material_background = "deep"
  -- g.oceanic_material_background = "medium"
  -- g.oceanic_material_background = "darker"
  g.oceanic_material_allow_bold = 1
  g.oceanic_material_allow_italic = 0
  g.oceanic_material_allow_underline = 1

  -- cmd [[colorscheme oceanic_material]]
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
  g.material_style = "deep ocean"
  -- g.material_style = "palenight"
end

M.tokyonight = function()
  -- === Tokyo Night ===
  g.tokyonight_style = "night" -- night day storm
  g.tokyonight_italic_comments = false
  g.tokyonight_italic_keywords = false
  -- g.tokyonight_style = "storm"

  -- cmd [[colorscheme tokyonight]]
end

-- === VSCode ===
M.vscode = function()
  g.vscode_style = "dark"
  g.vscode_transparent = 0
  g.vscode_italic_comment = 0

  cmd [[colorscheme vscode]]
end

-- === OneDark ===
M.onedark = function()
  local od = require("onedarkpro")
  od.setup(
      {
        -- Theme can be overwritten with 'onedark' or 'onelight' as a string
        theme = "onedark",
        colors = {}, -- Override default colors by specifying colors for 'onelight' or 'onedark' themes
        hlgroups = {}, -- Override default highlight groups
        filetype_hlgroups = {}, -- Override default highlight groups for specific filetypes
        plugins = { -- Override which plugins highlight groups are loaded
          native_lsp = true,
          polygot = true,
          treesitter = true,
          -- NOTE: Other plugins have been omitted for brevity
        },
        styles = {
          strings = "NONE", -- Style that is applied to strings
          comments = "NONE", -- Style that is applied to comments
          keywords = "NONE", -- Style that is applied to keywords
          functions = "NONE", -- Style that is applied to functions
          variables = "NONE", -- Style that is applied to variables
          virtual_text = "NONE", -- Style that is applied to virtual text
        },
        options = {
          bold = false, -- Use the themes opinionated bold styles?
          italic = false, -- Use the themes opinionated italic styles?
          underline = false, -- Use the themes opinionated underline styles?
          undercurl = false, -- Use the themes opinionated undercurl styles?
          cursorline = false, -- Use cursorline highlighting?
          transparency = false, -- Use a transparent background?
          terminal_colors = false, -- Use the theme's colors for Neovim's :terminal?
          window_unfocussed_color = false, -- When the window is out of focus, change the normal background?
        },
      }
  )

  -- od.load()
end

-- === NightFly ===
M.nightfly = function()
  g.nightflyItalics = 0
end

-- === Kimbox ===
M.kimbox = function()
  cmd("pa kimbox")
  require("kimbox").setup(
      {
        style = "ocean",
        allow_bold = true,
        allow_italic = false,
        allow_underline = false,
        allow_undercurl = false,
        allow_reverse = false,
        term_colors = true,

        popup = {
          background = false, -- use background color for pmenu
        },

        toggle_style_list = require("kimbox").bgs_list,
      }
  )
  -- require("kimbox").load()
end

local function init()
  M.kimbox()
  M.gruvbox()
  M.everforest()
  M.ocean_material()
  M.miramare()
  M.tokyonight()
  M.kanagawa()
  M.catppuccin()
  M.material()
  M.nightfox()
  -- M.edge()
  -- M.vscode()

  -- cmd [[colorscheme catppuccin]]
  -- cmd [[colorscheme kanagawa]]
  -- cmd [[colorscheme material]]
  -- cmd [[colorscheme tokyonight]]
  -- cmd [[colorscheme everforest]]
  -- cmd [[colorscheme jellybeans-nvim]]
  -- cmd [[colorscheme spaceduck]]
  -- cmd [[colorscheme gruvbox-material]]

  require("kimbox").load()

  -- cmd [[hi VertColumn guibg=#D9AE80]]
  -- cmd [[hi VertSplit guibg=#7E602C]]

  -- cmd [[hi Floaterm guifg=#A06469]]
  -- cmd [[hi FloatermNC guifg=#A06469]]
  cmd [[hi FloatermBorder guifg=#A06469 gui=none]]

  -- cmd [[hi RnvimrNormal guifg=#A06469]]
  -- cmd [[hi RnvimrCurses guifg=#A06469]]
end

init()

return M
