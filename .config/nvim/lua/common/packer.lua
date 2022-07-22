local M = {}

local log = require("common.log")
local ex = nvim.ex

---Reinstall a plugin. Only the repository name is allowed
---Example: `:PackerReinstall "theme.nvim"`
---@param name string
M.reinstall = function(name)
    if package.loaded["packer"] == nil then
        log.err("Packer not installed or not loaded", true)
        return
    end

    local utils = require("packer.plugin_utils")
    local suffix = "/" .. name

    local opt, start = utils.list_installed_plugins()
    for _, group in pairs({opt, start}) do
        if group ~= nil then
            for dir, _ in pairs(group) do
                if dir:sub(-suffix:len()) == suffix then
                    vim.ui.input(
                        {prompt = ("Remove %s? [Y/n]"):format(dir)},
                        function(confirm)
                            if not confirm or (confirm and confirm:lower() ~= "y") then
                                return
                            end
                            os.execute(("cd %s && git fetch --progress origin && git reset --hard origin"):format(dir))
                            ex.PackerSync()
                        end
                    )
                    return
                end
            end
        end
    end
end

return M
