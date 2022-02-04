local wezterm = require 'wezterm';

-- use_ime = true,
return {
  font = wezterm.font("FiraMono Nerd Font Mono", { weight = "Medium" }),
  font_size = 12.0,
  color_scheme = "gruvbox",
  color_scheme_dirs = { "/home/lmburns/.config/wezterm/colors/" },
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
  disable_default_key_bindings = true,
  keys = {
    {
      key = "c",
      mods = "CTRL|SHIFT",
      action = wezterm.action { CopyTo = "Clipboard" }
    }, {
      key = "v",
      mods = "CTRL",
      action = wezterm.action { PasteFrom = "Clipboard" }
    }, {
      key = "Insert",
      mods = "SHIFT",
      action = wezterm.action { PasteFrom = "PrimarySelection" }
    }, { key = "=", mods = "CTRL", action = "ResetFontSize" },
    { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
    { key = "-", mods = "CTRL", action = "DecreaseFontSize" }
  }
}
