local wez = require("wezterm")

-- local config = {}
-- if wez.config_builder then
--     config = wez.config_builder()
-- end

local act = wez.action
local keybinds = {
    {key = "=", mods = "CTRL", action = "IncreaseFontSize"},
    {key = "-", mods = "CTRL", action = "DecreaseFontSize"},
    {key = "0", mods = "CTRL", action = "ResetFontSize"},
    -- {key = "c", mods = "SUPER", action = "Copy"},
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
    {key = "T", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain")},
    {
        key = "|",
        mods = "LEADER|SHIFT",
        action = act.SplitHorizontal({domain = "CurrentPaneDomain"}),
    },
}

local kanagawa = {
    foreground = "#dcd7ba",
    background = "#1f1f28",
    cursor_bg = "#c8c093",
    cursor_fg = "#c8c093",
    cursor_border = "#c8c093",
    selection_fg = "#c8c093",
    selection_bg = "#2d4f67",
    scrollbar_thumb = "#16161d",
    split = "#16161d",
    ansi = {
        "#090618", -- Black
        "#c34043", -- Red
        "#76946a", -- Green
        "#c0a36e", -- Yellow
        "#7e9cd8", -- Blue
        "#957fb8", -- Magenta
        "#6a9589", -- Cyan
        "#c8c093", -- White
    },
    brights = {
        "#727169", -- Black
        "#e82424", -- Red
        "#98bb6c", -- Green
        "#e6c384", -- Yellow
        "#7fb4ca", -- Blue
        "#938aa9", -- Magenta
        "#7aa89f", -- Cyan
        "#dcd7ba", -- White
    },
}
local gruvbox_dark_hard = {
    foreground = "#f9f5d7",
    background = "#1d2021",
    cursor_bg = "#f9f5d7",
    cursor_fg = "#1d2021",
    cursor_border = "#1d2021",
    selection_fg = "#f9f5d7",
    selection_bg = "#665c54",
    scrollbar_thumb = "#665c54",
    split = "#665c54",
    ansi = {
        "#1d2021",     -- Black
        "#cc241d",     -- Red
        "#98971a",     -- Green
        "#d79921",     -- Yellow
        "#458588",     -- Blue
        "#b16286",     -- Magenta
        "#689d6a",     -- Cyan
        "#f9f5d7",     -- White
    },
    brights = {
        "#7c6f64",     -- Black
        "#fb4934",     -- Red
        "#b8bb26",     -- Green
        "#fabd2f",     -- Yellow
        "#83a598",     -- Blue
        "#d3869b",     -- Magenta
        "#8ec07c",     -- Cyan
        "#ebdbb2",     -- White
    },
}

return {
    check_for_updates = false,
    debug_key_events = false,
    automatically_reload_config = true,
    audible_bell = "Disabled",
    default_prog = {"zsh"},
    enable_csi_u_key_encoding = true,

    adjust_window_size_when_changing_font_size = false,
    alternate_buffer_wheel_scroll_speed = 3,
    scrollback_lines = 15000,
    enable_scroll_bar = true,
    enable_tab_bar = true,
    initial_rows = 50,
    initial_cols = 120,
    cell_width = 1.0,
    use_fancy_tab_bar = false,

    animation_fps = 10,
    cursor_blink_ease_in = "Linear",
    cursor_blink_ease_out = "Linear",
    cursor_blink_rate = 800,

    allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",
    custom_block_glyphs = false,
    anti_alias_custom_block_glyphs = true,

    show_update_window = true,
    exit_behavior = "Close",
    quit_when_all_windows_are_closed = true,
    window_close_confirmation = "NeverPrompt",
    window_background_opacity = 0.90,
    window_padding = {left = 0, right = 0, top = 0, bottom = 0},
    -- window_padding={left='0.1cell', right='0.1cell', top='0.1cell', bottom='0.1cell'},

    bypass_mouse_reporting_modifiers = "SHIFT",
    hide_tab_bar_if_only_one_tab = true,
    use_ime = true,

    font = wez.font("FiraCode Nerd Font Mono", {weight = "Medium"}),
    -- font = wez.font_with_fallback({{"FiraMono Nerd Font Mono", {weight = "Medium"}}, {"Noto Sans CJK SC"}}),
    font_size = 12.0,

    -- colors = colors,
    -- char_select_bg_color = "#333333",
    -- char_select_fg_color = rgba(0.75, 0.75, 0.75, 1.0),
    -- char_select_font_size = 14.0,
    -- command_palette_bg_color = "#333333",
    -- command_palette_fg_color = rgba(0.75, 0.75, 0.75, 1.0),
    -- command_palette_font_size = 14.0,

    color_scheme = "kimbox",
    color_scheme_dirs = {"/home/lucas/.config/wezterm/colors/"},
    bold_brightens_ansi_colors = "BrightAndBold",

    leader = {key = "1", mods = "CTRL", timeout_milliseconds = 1000},
    keys = keybinds,
    disable_default_key_bindings = true,
    use_dead_keys = false,
    hyperlink_rules = {
        -- This is actually the default if you don't specify any hyperlink_rules
        {regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b", format = "$0"},
        -- linkify email addresses
        {regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0"},
        -- file:// URI
        {regex = "\\bfile://\\S*\\b", format = "$0"},
    },

    --   window_frame={
    --     border_left_width='0.1cell',
    --     border_right_width='0.1cell',
    --     border_bottom_height='0.1cell',
    --     border_top_height='0.1cell',
    --     border_left_color='red',
    --     border_right_color='red',
    --     border_bottom_color='red',
    --     border_top_color='red',
    --   },
}
