local M = {}

-- TODO: This needs work

local ex = nvim.ex

M.packer_reinstall = function(name) -- usage example => :lua PackerReinstall "yaml.nvim"
    if package.loaded["packer"] == nil then
        p("Packer not installed or not loaded")
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
                        function(confirmation)
                            if confirmation:lower() ~= "y" then
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
