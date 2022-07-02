local reload = require("nvim-reload")

local nvim_reload_dir = fn.stdpath("data") .. "/site/pack/*/opt/nvim-reload"
local plugin_dirs_autoload = fn.stdpath("data") .. "/site/pack/*/start/*"
local plugin_dirs_lazyload = {
    -- fn.stdpath("data") .. "/site/pack/*/opt/lualine.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/fzf-lua",
    fn.stdpath("data") .. "/site/pack/*/opt/telescope.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/toggleterm.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/indent-blankline.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/nvim-dap"
    -- fn.stdpath("data") .. "/site/pack/*/opt/which-key.nvim",
}

reload.vim_reload_dirs = {
    fn.stdpath("config"),
    plugin_dirs_autoload
}

reload.lua_reload_dirs = {
    fn.stdpath("config"),
    nvim_reload_dir,
    plugin_dirs_autoload
}

for _, k in ipairs(plugin_dirs_lazyload) do
    table.insert(reload.lua_reload_dirs, k)
end

reload.modules_reload_external = {"packer"}

reload.lsp_was_loaded = nil
reload.pre_reload_hook = function()
    -- reload.lsp_was_loaded = pcall(require, "lspconfig")
end

reload.post_reload_hook = function()
    require("common.global")
    -- ex.packloadall()
    ex.nohl()

    -- recompile packer
    require("plugins").loader("packer.nvim")
    ex.pa("packer.nvim")
    require("plugins").compile()

    require("plugins").loader("nvim-treesitter")
    require("plugins").loader("iswap.nvim")
    ex.pa("nvim-treesitter")

    -- cmd [[pa coc-kvs]]
    -- cmd [[pa coc.nvim]]
    -- ex.PackerLoad("coc.nvim")

    -- re-source all language specific settings, scans all runtime files under
    -- '/usr/share/nvim/runtime/(indent|syntax)' and 'after/ftplugin'
    local ft = vim.bo.filetype
    vim.tbl_filter(
        function(s)
            for _, e in ipairs({"vim", "lua"}) do
                if ft and #ft > 0 and s:match(("/%s.%s"):format(ft, e)) then
                    local file = fn.expand(s:match("[^: ]*$"))
                    if e == "vim" then
                        ex.source(file)
                    else
                        ex.luafile(file)
                    end
                    return s
                end
            end
            return nil
        end,
        fn.split(fn.execute("scriptnames"), "\n")
    )

    -- ex.PackerLoad("nvim-treesitter")
    -- ex.pa("nvim-treesitter")
    -- ex.pa("iswap.nvim")
    -- require("plugs.treesitter")
    ex.syntax("on")

    -- ex.doautocmd("VimEnter")

    -- local tbl = require("impatient").modpaths.cache
    -- for k, v in pairs(tbl) do
    --     if k:match("^nvim%-treesitter*") then
    --         -- ex.luafile(v)
    --         RELOAD(k)
    --     end
    -- end

    -- cmd("luafile " .. require('packer').config.compile_path)

end

return reload
