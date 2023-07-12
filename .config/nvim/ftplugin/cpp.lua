local fn, cmd = vim.fn, vim.cmd

local mpi = require("usr.api")
local bmap0 = mpi.bmap0
local o = vim.opt_local

o.cinoptions:append({"L0"})

bmap0(
    "n",
    "<Leader>r<CR>",
    function()
        cmd("sil! up")
        cmd("FloatermNew --autoclose=0 gcc -xc++ -std=gnu++2b -g % -o %:r && ./%:r")
    end
)
bmap0(
    "n",
    "M",
    function()
        cmd(("%s %s"):format(vim.o.keywordprg, fn.expand("<cword>")))
    end
)

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "| setl cino<"
