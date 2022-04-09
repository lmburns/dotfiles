-- Create many augroups
function M.augroups(definitions)
  for group_name, definition in pairs(definitions) do
    cmd("augroup " .. group_name)
    cmd("autocmd!")
    for _, def in pairs(definition) do
      local command = table.concat(tbl_flatten { "autocmd", def }, " ")
      cmd(command)
    end
    cmd("augroup END")
  end
end


-- Create a single augroup
function M.augroup(name, commands)
  cmd("augroup " .. name)
  cmd("autocmd!")
  for _, c in ipairs(commands) do
    cmd(
        string.format(
            "autocmd %s %s %s %s", table.concat(c.events, ","),
            table.concat(c.targets or {}, ","),
            table.concat(c.modifiers or {}, " "), c.command
        )
    )
  end
  cmd("augroup END")
end


cmd [[
    function! IsPluginInstalled(name) abort
      return luaeval("_G.packer_plugins['" .. a:name .. "'] ~= nil")
    endfunction
]]


my_packer.is_plugin_installed = function(name)
  return _G.packer_plugins[name] ~= nil
end


function AutocmdLazyConfig(plugin_name)
  local timer = loop.new_timer()
  timer:start(
      1000, 0, schedule_wrap(
          function()
            if _G.packer_plugins[plugin_name].loaded then
              timer:close() -- Always close handles to avoid leaks.
              cmd(
                  string.format("doautocmd User %s", "packer-" .. plugin_name)
              )
            end
          end
      )
  )
end
