--==========================================================================
--   Author: Lucas Burns
--    Email: burnsac@me.com
--  Created: 2022-03-24 19:39
--==========================================================================
require("common.utils")

-- Lua utilities
require('lutils')

require('base')
require('options')
require('autocmds')
-- require('plugins')
require('mapping')
require("functions")

-- cmd([[command! PU packadd packer.nvim | lua require('plugins').update()]])
-- cmd([[command! PI packadd packer.nvim | lua require('plugins').install()]])
-- cmd([[command! PS packadd packer.nvim | lua require('plugins').sync()]])
-- cmd([[command! PC packadd packer.nvim | lua require('plugins').clean()]])

-- Plugins need to be compiled to work it seems
local conf_dir = fn.stdpath('config')
if uv.fs_stat(conf_dir .. '/plugin/packer_compiled.lua') then
    local packer_loader_complete = [[customlist,v:lua.require'packer'.loader_complete]]
    cmd(([[
        com! PI lua require('plugins').install()
        com! PU lua require('plugins').update()
        com! PS lua require('plugins').sync()
        com! PC lua require('plugins').clean()
        com! PackerStatus lua require('plugins').status()
        com! -nargs=? PackerCompile lua require('plugins').compile(<q-args>)
        com! -nargs=+ -complete=%s PackerLoad lua require('plugins').loader(<f-args>)
    ]]):format(packer_loader_complete))
else
    require('plugins').compile()
end

vim.cmd("source ~/.config/nvim/vimscript/plug.vim")

require('highlight')
