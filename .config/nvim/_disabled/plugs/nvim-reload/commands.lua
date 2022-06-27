-- These both need to be redone.
-- I've only got them working once and they require a lot of modifications to the config
command(
    "NvimRestart",
    function()
        if not pcall(require, "nvim-reload") then
            require("plugins").loader("nvim-reload")
        end
        local reload = R("plugs.nvim-reload")
        reload.Restart()
        -- ex.PackerSync()
    end,
    {nargs = "*"}
)

command(
    "NvimReload",
    function()
        if not pcall(require, "nvim-reload") then
            require("plugins").loader("nvim-reload")
        end

        require("nvim-reload").Reload()
        ex.colorscheme("kimbox")
    end,
    {nargs = "*"}
)
