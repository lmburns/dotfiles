local reload = require("nvim-reload")

local nvim_reload_dir = fn.stdpath("data") .. "/site/pack/*/opt/nvim-reload"
local plugin_dirs_autoload = fn.stdpath("data") .. "/site/pack/*/start/*"
local plugin_dirs_lazyload = {
    fn.stdpath("data") .. "/site/pack/*/opt/fzf-lua",
    fn.stdpath("data") .. "/site/pack/*/opt/nvim-fzf",
    fn.stdpath("data") .. "/site/pack/*/opt/lualine.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/telescope.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/which-key.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/toggleterm.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/indent-blankline.nvim",
    fn.stdpath("data") .. "/site/pack/*/opt/nvim-dap"
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

-- FIX: Treesitter not working when switching files
-- FIX: Motions like `dw` delete way more
reload.post_reload_hook = function()
    cmd [[nohl]]
    -- recompile packer
    cmd [[pa packer.nvim]]
    require("plugins").compile()

    -- cmd [[pa nvim-treesitter]]
    -- require("plugs.tree-sitter")

    ex.PackerLoad("coc.nvim")

    -- if reload.lsp_was_loaded and vim.fn.exists(":PackerLoad") ~= 0 then
    --     vim.cmd("PackerLoad nvim-lspconfig")
    --     vim.cmd("PackerLoad nvim-lsp-installer")
    -- end

    -- re-source all language specific settings, scans all runtime files under
    -- '/usr/share/nvim/runtime/(indent|syntax)' and 'after/ftplugin'
    local ft = vim.bo.filetype
    vim.tbl_filter(
        function(s)
            for _, e in ipairs({"vim", "lua"}) do
                if ft and #ft > 0 and s:match(("/%s.%s"):format(ft, e)) then
                    local file = fn.expand(s:match("[^: ]*$"))
                    ex.source(file)
                    return s
                end
            end
            return nil
        end,
        fn.split(fn.execute("scriptnames"), "\n")
    )
end

return reload
