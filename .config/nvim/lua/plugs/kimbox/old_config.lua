local function load_old_config()
  local opts = {
    "background",
    "transparent_background",
    "allow_bold",
    "allow_italic",
    "allow_underline",
    "allow_reverse",
    "allow_undercurl",
  }

  local cfg = {}
  local using_old_config = false
  local messages = ""

  for _, opt in ipairs(opts) do
    local value = vim.g["kimbox_" .. opt]
    if value ~= nil then
      cfg[opt] = value
      using_old_config = true
      messages = messages .. "kimbox.nvim: option 'kimbox_" .. opt ..
                     "' has been deprecated. See how to use the new configuration in README.md\n"
    end
  end

  if using_old_config then
    vim.schedule(
        function()
          vim.notify(messages, vim.log.levels.WARN, { title = "kimbox.nvim" })
        end
    )

    local new_config = {
      style = cfg.style,
      toggle_style_key = cfg.toggle_style_keymap,
      transparent = cfg.transparent_background,
      term_colors = cfg.disable_terminal_colors,
      ending_tildes = cfg.hide_ending_tildes,

      allow_bold = cfg.allow_bold,
      allow_italic = cfg.allow_italic,
      allow_underline = cfg.allow_underline,
      allow_undercurl = cfg.allow_undercurl,
      allow_reverse = cfg.allow_reverse,

      diagnostics = {
        background = cfg.diagnostics_text_bg,
      },
    }
    return new_config
  else
    return false
  end
end

return load_old_config()
