local o = vim.opt_local

o.list = false
o.lcs:remove({"trail:•"})
o.buflisted = false

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "| setl list< lcs< buflisted<"
