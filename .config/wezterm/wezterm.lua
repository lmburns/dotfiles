local wezterm = require 'wezterm';

-- use_ime = true,
return {
  font = wezterm.font("FiraMono Nerd Font Mono", { weight = "Medium" }),
  font_size = 12.0,
  color_scheme = "kimbox",
  color_scheme_dirs = { "/home/lmburns/.config/wezterm/colors/" },
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,
  disable_default_key_bindings = true,
  window_background_opacity = 0.90,
  scrollback_lines = 15000,
  enable_scroll_bar = true,

  keys = {
    { key = "c",      mods = "CTRL|SHIFT", action = { CopyTo = "Clipboard" } },
    { key = "p",      mods = "CTRL",       action = { PasteFrom = "Clipboard" } },
    { key = "Insert", mods = "SHIFT",      action = { PasteFrom = "PrimarySelection" } },
    { key = "=",      mods = "CTRL",       action = "ResetFontSize" },
    { key = "+",      mods = "CTRL",       action = "IncreaseFontSize" },
    { key = "-",      mods = "CTRL",       action = "DecreaseFontSize" },
    -- { key = "Space",  mods="CTRL",         action = "QuickSelect" },
    -- { key = "H",      mods="SHIFT|CTRL",   action = {Search = { Regex = "[a-f0-9]{6,}"} } },
  },

  hyperlink_rules = {
    -- Linkify things that look like URLs
    -- This is actually the default if you don't specify any hyperlink_rules
    { regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b", format = "$0" },

    -- linkify email addresses
    { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" },

    -- file:// URI
    { regex = "\\bfile://\\S*\\b", format = "$0" }

    -- Make task numbers clickable
    --[[
    {
      regex = "\\b[tT](\\d+)\\b"
      format = "https://example.com/tasks/?t=$1"
    }
    ]]
  },
}
