local function setup()

  xplr.config.node_types.special = {
    ["Cargo.toml"] = {meta = {icon = "⚙"}},
    [".git"] = {meta = {icon = ""}},
    node_modules = {meta = {icon = ""}},
    ["docker-compose.yml"] = {meta = {icon = ""}}
  }

  xplr.config.node_types.mime_essence = {
    ["text"] = {["plain"] = {meta = {icon = ""}}},
    ["video"] = {["*"] = {meta = {icon = ""}}},
    ["image"] = {["*"] = {meta = {icon = ""}}}
  }

  xplr.config.node_types.extension = {
    lock = {meta = {icon = ""}},
    md = {meta = {icon = ""}},
    toml = {meta = {icon = ""}},
    rs = {meta = {icon = ""}},
    elm = {meta = {icon = ""}},
    lua = {meta = {icon = ""}},
    nix = {meta = {icon = ""}},
    js = {meta = {icon = ""}},
    py = {meta = {icon = ""}},
    txt = {meta = {icon = ""}},
    csv = {meta = {icon = ""}},
    xlsx = {meta = {icon = ""}},
    odf = {meta = {icon = ""}},
    yml = {meta = {icon = "⚙"}},
    yaml = {meta = {icon = "⚙"}},
    c = {meta = {icon = ""}},
    cc = {meta = {icon = ""}},
    clj = {meta = {icon = ""}},
    ccp = {meta = {icon = ""}},
    coffee = {meta = {icon = ""}},
    cpp = {meta = {icon = ""}},
    css = {meta = {icon = ""}},
    d = {meta = {icon = ""}},
    dart = {meta = {icon = ""}},
    erl = {meta = {icon = ""}},
    exs = {meta = {icon = ""}},
    fs = {meta = {icon = ""}},
    go = {meta = {icon = ""}},
    h = {meta = {icon = ""}},
    hh = {meta = {icon = ""}},
    hpp = {meta = {icon = ""}},
    hs = {meta = {icon = ""}},
    html = {meta = {icon = ""}},
    h = {meta = {icon = ""}},
    java = {meta = {icon = "♨"}},
    kt = {meta = {icon = "🅺"}},
    jl = {meta = {icon = ""}},
    js = {meta = {icon = ""}},
    json = {meta = {icon = ""}},
    php = {meta = {icon = ""}},
    pl = {meta = {icon = ""}},
    pro = {meta = {icon = ""}},
    rb = {meta = {icon = ""}},
    pro = {meta = {icon = ""}},
    scala = {meta = {icon = ""}},
    ts = {meta = {icon = ""}},
    vim = {meta = {icon = ""}},
    cmd = {meta = {icon = ""}},
    ps1 = {meta = {icon = ""}},
    sh = {meta = {icon = ""}},
    zsh = {meta = {icon = ""}},
    bash = {meta = {icon = ""}},
    fish = {meta = {icon = ""}},
    tar = {meta = {icon = ""}},
    tgz = {meta = {icon = ""}},
    arc = {meta = {icon = ""}},
    arj = {meta = {icon = ""}},
    taz = {meta = {icon = ""}},
    lha = {meta = {icon = ""}},
    lz4 = {meta = {icon = ""}},
    lzh = {meta = {icon = ""}},
    tlz = {meta = {icon = ""}},
    txz = {meta = {icon = ""}},
    tzo = {meta = {icon = ""}},
    t7z = {meta = {icon = ""}},
    lzma = {meta = {icon = ""}},
    zip = {meta = {icon = ""}},
    z = {meta = {icon = ""}},
    dz = {meta = {icon = ""}},
    gz = {meta = {icon = ""}},
    lrz = {meta = {icon = ""}},
    lz = {meta = {icon = ""}},
    lzo = {meta = {icon = ""}},
    xz = {meta = {icon = ""}},
    zst = {meta = {icon = ""}},
    tzst = {meta = {icon = ""}},
    bz2 = {meta = {icon = ""}},
    bz = {meta = {icon = ""}},
    tbz = {meta = {icon = ""}},
    tbz2 = {meta = {icon = ""}},
    tz = {meta = {icon = ""}},
    deb = {meta = {icon = ""}},
    rpm = {meta = {icon = ""}},
    jar = {meta = {icon = ""}},
    war = {meta = {icon = ""}},
    ear = {meta = {icon = ""}},
    sar = {meta = {icon = ""}},
    rar = {meta = {icon = ""}},
    alz = {meta = {icon = ""}},
    ace = {meta = {icon = ""}},
    zoo = {meta = {icon = ""}},
    cpio = {meta = {icon = ""}},
    z7z = {
      meta = {icon = ""} -- can't start with number?
    },
    rz = {meta = {icon = ""}},
    cab = {meta = {icon = ""}},
    tbz2 = {meta = {icon = ""}},
    wim = {meta = {icon = ""}},
    swm = {meta = {icon = ""}},
    dwm = {meta = {icon = ""}},
    esd = {meta = {icon = ""}},
    pdf = {meta = {icon = ""}}
  }

  ---- Initial sorting
  xplr.config.general.initial_sorting = {
    {sorter = "ByCanonicalIsDir", reverse = true},
    {sorter = "ByIRelativePath", reverse = false}
  }

  -- xplr.config.general.default_ui.prefix = " "
  -- xplr.config.general.default_ui.suffix = ""

  xplr.config.general.prompt.format = "❯ "
  xplr.config.general.focus_ui.prefix = "▸"
  xplr.config.general.focus_ui.suffix = ""
  -- xplr.config.general.focus_ui.prefix = "▸["
  -- xplr.config.general.focus_ui.suffix = "]"

  -- Hover style
  -- xplr.config.general.focus_ui.style.fg = { Rgb = {170,150,130} }
  xplr.config.general.focus_ui.style.fg = "Magenta"

  xplr.config.general.focus_ui.style.bg = {Rgb = {50, 50, 50}}
  xplr.config.general.focus_ui.style.add_modifiers = {"Bold"}

  xplr.config.general.selection_ui.prefix = " {"
  xplr.config.general.selection_ui.suffix = "}"
  xplr.config.general.selection_ui.style.fg = {Rgb = {70, 70, 70}}
  -- xplr.config.general.selection_ui.style.fg = "LightGreen"
  xplr.config.general.selection_ui.style.add_modifiers = {"Bold", "CrossedOut"}

  xplr.config.general.sort_and_filter_ui.separator.format = " » "
  xplr.config.general.sort_and_filter_ui.separator.style.add_modifiers = {"Dim"}
  xplr.config.general.sort_and_filter_ui.separator.style.bg = nil
  xplr.config.general.sort_and_filter_ui.separator.style.fg = nil
  xplr.config.general.sort_and_filter_ui.separator.style.sub_modifiers = nil

  -- xplr.config.general.panel_ui.default.title.style.bg = { Rgb = {170,150,130} }
  xplr.config.general.panel_ui.default.title.style.fg = {Rgb = {40, 40, 40}}
  xplr.config.general.panel_ui.default.title.style.add_modifiers = {"Bold"}
  xplr.config.general.panel_ui.default.style.fg = {Rgb = {170, 150, 130}}
  -- xplr.config.general.panel_ui.default.style.bg = { Rgb = {33,33,33} }

  xplr.config.general.panel_ui.default.borders = {}
  -- Creates solid background
  -- xplr.config.general.panel_ui.help_menu.style.bg = { Rgb = {26,26,26} }
  -- xplr.config.general.panel_ui.selection.style.bg = { Rgb = {26,26,26} }

  xplr.config.general.sort_and_filter_ui.default_identifier.style.add_modifiers =
      {"Bold"}

  xplr.config.general.sort_and_filter_ui.sort_direction_identifiers.forward
      .format = "↓"
  xplr.config.general.sort_and_filter_ui.sort_direction_identifiers.reverse
      .format = "↑"

  xplr.config.general.panel_ui.default.borders = {
    "Top", "Right", "Bottom", "Left"
  }

  -- xplr.config.general.table.col_widths = {
  --   { Length = 7 },
  --   { Percentage = 50 },
  --   { Percentage = 10 },
  --   { Percentage = 10 },
  --   { Min = 1 },
  -- }

  -- xplr.config.general.table.col_widths = {
  --   { Percentage = 10 },
  --   { Percentage = 50 },
  --   { Percentage = 10 },
  --   { Percentage = 10 },
  --   { Percentage = 20 },
  -- }

  ---- Node types
  ------ Directory
  -- xplr.config.node_types.directory.meta.icon = "ð"
  xplr.config.node_types.directory.meta.icon = ""
  xplr.config.node_types.directory.style.fg = "Blue"
  xplr.config.node_types.directory.style.add_modifiers = {"Bold"}
  xplr.config.node_types.directory.style.sub_modifiers = nil
  xplr.config.node_types.directory.style.bg = nil

  ------ File
  -- xplr.config.node_types.file.meta.icon = "ƒ"
  xplr.config.node_types.file.meta.icon = ""
  xplr.config.node_types.file.style.add_modifiers = {"Dim"}
  xplr.config.node_types.file.style.sub_modifiers = nil
  xplr.config.node_types.file.style.bg = nil
  xplr.config.node_types.file.style.fg = nil

  ------ Symlink
  xplr.config.node_types.symlink.meta.icon = "§"
  -- xplr.config.node_types.symlink.meta.icon = ""
  xplr.config.node_types.symlink.style.add_modifiers = {"Italic"}
  xplr.config.node_types.symlink.style.sub_modifiers = nil
  xplr.config.node_types.symlink.style.bg = nil
  xplr.config.node_types.symlink.style.fg = "Magenta"

end

return {setup = setup}
