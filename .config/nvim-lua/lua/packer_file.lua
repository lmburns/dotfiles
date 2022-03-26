local utils = require("common.utils")
local autocmd = utils.autocmd
local my_packer = {}

cmd [[
      function! IsPluginInstalled(name) abort
        return luaeval("_G.packer_plugins['" .. a:name .. "'] ~= nil")
      endfunction
    ]]

my_packer.is_plugin_installed = function(name)
  return _G.packer_plugins[name] ~= nil
end

function AutocmdLazyConfig(plugin_name)
  local timer = vim.loop.new_timer()
  timer:start(
      1000, 0, vim.schedule_wrap(
          function()
            if _G.packer_plugins[plugin_name].loaded then
              timer:close() -- Always close handles to avoid leaks.
              vim.cmd(
                  string.format("doautocmd User %s", "packer-" .. plugin_name)
              )
            end
          end
      )
  )
end

-- require("packer").init({
--   compile_path = vim.fn.stdpath("data") ..
--       "/site/pack/loader/start/my-packer/plugin/packer.lua"
-- })

return my_packer
