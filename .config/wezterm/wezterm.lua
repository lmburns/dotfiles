local wezterm = require("wezterm")

local act = wezterm.action
local keybinds = {
    {key = "=", mods = "CTRL", action = "IncreaseFontSize"},
    {key = "-", mods = "CTRL", action = "DecreaseFontSize"},
    {key = "0", mods = "CTRL", action = "ResetFontSize"},
    {key = "c", mods = "SUPER", action = "Copy"},
    -- {key = "v", mods = "Super", action = "Paste"},
    {key = "C", mods = "CTRL|SHIFT", action = act({CopyTo = "Clipboard"})},
    -- {key = "V", mods = "CTRL|SHIFT", action = act {PasteFrom = "Clipboard"}},
    {key = "c", mods = "CTRL|SHIFT", action = {CopyTo = "Clipboard"}},
    {key = "p", mods = "CTRL", action = {PasteFrom = "Clipboard"}},
    {key = "Insert", mods = "SHIFT", action = {PasteFrom = "PrimarySelection"}},
    {key = "=", mods = "CTRL", action = "ResetFontSize"},
    {key = "+", mods = "CTRL", action = "IncreaseFontSize"},
    {key = "-", mods = "CTRL", action = "DecreaseFontSize"},
    {key = "Space", mods = "CTRL", action = "QuickSelect"},
    {key = "H", mods = "SHIFT|CTRL", action = {Search = {Regex = "[a-f0-9]{6,}"}}},
    -- ------
    {key = "1", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x3b\x35\x50"})},
    {key = "2", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x3b\x35\x51"})},
    {key = "3", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x3b\x35\x52"})},
    {key = "4", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x3b\x35\x53"})},
    {key = "5", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x35\x3b\x35\x7e"})},
    {key = "6", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x37\x3b\x35\x7e"})},
    {key = "7", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x38\x3b\x35\x7e"})},
    {key = "8", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x39\x3b\x35\x7e"})},
    {key = "9", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x38\x3b\x35\x7e"})},
    {key = "0", mods = "CTRL", action = act({SendString = "\x1b\x5b\x32\x31\x3b\x35\x7e"})},
    {key = ";", mods = "CTRL", action = act({SendString = "\x1b\x5b\x32\x33\x3b\x35\x7e"})},
    {key = [[']], mods = "CTRL", action = act({SendString = "\x1b\x5b\x32\x34\x3b\x35\x7e"})},
    {key = "1", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x3b\x36\x50"})},
    {key = "2", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x3b\x36\x51"})},
    {key = "3", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x3b\x36\x52"})},
    {key = "4", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x3b\x36\x53"})},
    {key = "5", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x35\x3b\x36\x7e"})},
    {key = "6", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x37\x3b\x36\x7e"})},
    {key = "7", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x38\x3b\x36\x7e"})},
    {key = "8", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x31\x39\x3b\x36\x7e"})},
    {key = "9", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x32\x30\x3b\x36\x7e"})},
    {key = "0", mods = "CTRL|ALT", action = act({SendString = "\x1b\x5b\x32\x31\x3b\x36\x7e"})},
    {key = ",", mods = "CTRL", action = act({SendString = "\x1b\x5b\x32\x33\x3b\x36\x7e"})},
    {key = ".", mods = "CTRL", action = act({SendString = "\x1b\x5b\x32\x34\x3b\x36\x7e"})},
    -- Map Control-[ and Control-m to Alt-Shift-[F1-F2] (F61-F62)
    {key = "[", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x3b\x34\x50"})},
    {key = "M", mods = "CTRL", action = act({SendString = "\x1b\x5b\x31\x3b\x34\x51"})},
    {key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal {domain = "CurrentPaneDomain"}}
}

return {
    check_for_updates = false,
    debug_key_events = false,
    -- font = wezterm.font_with_fallback({{"FiraMono Nerd Font Mono", {weight = "Medium"}}, {"Noto Sans CJK SC"}}),
    font_size = 12.0,
    color_scheme = "kimbox",
    color_scheme_dirs = {"/home/lucas/.config/wezterm/colors/"},
    hide_tab_bar_if_only_one_tab = true,
    adjust_window_size_when_changing_font_size = false,
    custom_block_glyphs = false,
    window_background_opacity = 0.90,
    scrollback_lines = 15000,
    enable_scroll_bar = true,
    initial_rows = 50,
    initial_cols = 120,
    window_padding = {left = 0, right = 0, top = 0, bottom = 0},
    use_ime = true,
    disable_default_key_bindings = true,
    -- colors = colors,
    keys = keybinds,
    hyperlink_rules = {
        -- This is actually the default if you don't specify any hyperlink_rules
        {regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b", format = "$0"},
        -- linkify email addresses
        {regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0"},
        -- file:// URI
        {regex = "\\bfile://\\S*\\b", format = "$0"}
    }
}
