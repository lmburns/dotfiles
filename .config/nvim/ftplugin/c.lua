local fn, cmd = vim.fn, vim.cmd

-- if fn.exists("b:did_ftplugin") == 1 then
--     goto done
-- end
-- vim.b.did_ftplugin = 1

local mpi = require("usr.api")
local bmap0 = mpi.bmap0

local o = vim.opt_local

o.textwidth = 80
o.comments = {"s1:/*", "mb:*", "ex:*/", "://"}
o.commentstring = "// %s"

o.define = [[^\s*#\s*define]]
o.include = [[^\s*#\s*include]]

o.path:append("/usr/include")
o.path:remove(".")
o.path:append(".")

bmap0(
    "n",
    "<Leader>r<CR>",
    function()
        cmd("sil! up")
        cmd("FloatermNew --autoclose=0 gcc -xc -g -std=gnu2x % -o %:r && ./%:r")
    end
)
bmap0(
    "n",
    "M",
    function()
        cmd(("%s %s"):format(vim.o.keywordprg, fn.expand("<cword>")))
    end
)

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "| setl tw< com< cms< def< inc< path<"
-- ::done::
