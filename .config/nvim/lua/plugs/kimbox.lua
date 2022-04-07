local M = {}

-- General configurations for various themes

require("common.utils")

local function init()
  -- === Gruvbox ===
  -- g.gruvbox_material_background = 'medium'
  g.gruvbox_material_background = "hard"
  g.gruvbox_material_palette = "mix"
  -- g.gruvbox_material_palette = 'material'
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

  -- === Oceanic ===
  g.oceanic_material_background = "ocean"
  -- g.oceanic_material_background = "deep"
  -- g.oceanic_material_background = "medium"
  -- g.oceanic_material_background = "darker"
  g.oceanic_material_allow_bold = 1
  g.oceanic_material_allow_italic = 1
  g.oceanic_material_allow_underline = 1

  -- === Everforest ===
  g.everforest_disable_italic_comment = 1
  g.everforest_background = "hard"
  g.everforest_enable_italic = 0
  g.everforest_sign_column_background = "none"
  g.everforest_better_performance = 1

  -- === Edge ===
  g.edge_style = "aura"
  g.edge_cursor = "blue"
  g.edge_sign_column_background = "none"
  g.edge_better_performance = 1

  -- === Sonokai ===
  -- maia atlantis era
  -- g.sonokai_style = 'andromeda'
  g.sonokai_style = "shusia"
  g.sonokai_enable_italic = 1
  g.sonokai_disable_italic_comment = 1
  g.sonokai_cursor = "blue"
  g.sonokai_sign_column_background = "none"
  g.sonokai_better_performance = 1
  g.sonokai_diagnostic_text_highlight = 0

  -- === Miramare ===
  g.miramare_enable_bold = 1
  g.miramare_disable_italic_comment = 1
  g.miramare_cursor = "purple"
  g.miramare_current_word = "grey background"

  -- === Material ===
  g.material_style = "deep ocean"

  -- === Kimbox ===

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

        toggle_style_list = require("kimbox").bgs_list,
      }
  )
  require("kimbox").load()

  -- cmd [[colorscheme kimbox]]

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
