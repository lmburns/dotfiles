local function cmd(name, action, flags)
  local flag_pairs = {}

  if flags then
    for flag, value in pairs(flags) do
      if value == true then
        table.insert(flag_pairs, "-" .. flag)
      else
        table.insert(flag_pairs, "-" .. flag .. "=" .. value)
      end
    end
  end

  action = action:gsub("\n%s*", " ")

  local def = table.concat(
      { "command!", table.concat(flag_pairs, " "), name, action }, " "
  )

  vim.cmd(def)
end
